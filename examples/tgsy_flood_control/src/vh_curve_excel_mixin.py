import logging
import re
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

import numpy as np

logger = logging.getLogger("rtctools")


class VhCurveExcelMixin:
    """
    Load V-H curves for Integrator objects from model/Z-V-Q.xlsx.

    Workbook convention:
    - One sheet per Integrator object.
    - Sheet name: <object_name>Z-V (e.g. baoshihu_shengtaikuZ-V).
    - Column A: Z (water level), Column B: V (storage volume).

    Model convention:
    - Parameter names in Modelica can be either:
      1) <object_name>_vh_curve[i,j], with j=1 for V and j=2 for H, or
      2) <object_name>_vh_v1..vN and <object_name>_vh_h1..hN.
    """

    vh_curve_workbook = "Z-V-Q.xlsx"
    vh_curve_sheet_suffix = "Z-V"
    # Excel V is provided in 10^4 m3 for this project, convert to m3.
    vh_curve_volume_multiplier = 1.0e4
    vh_curve_log_diagnostics = True
    vh_curve_enforce_monotonic_h = True
    vh_curve_objects = (
        "shiyan_shengtaiku",
        "baoshihu_shengtaiku",
        "yingrenshi_shengtaiku",
        "jiuwei_shengtaiku",
        "shiyan_storage",
        "tiegang_storage",
    )
    # Object -> allowed sheet names (in order of preference).
    vh_curve_sheet_aliases = {
        "yingrenshi_shengtaiku": (
            "yingrenshi_shengtaikuZ-V",
            "yingrenshi_shengtaiku_storageZ-V",
            "yingrenshi_shengtaiku_storagZ-V",
        ),
    }
    # Missing sheets for these objects are acceptable and will use defaults.
    vh_curve_optional_objects = set()
    vh_curve_defaults = {
        "shiyan_shengtaiku": np.array(
            [
                [2.0e5, 11.0],
                [8.0e5, 11.8],
                [2.0e6, 12.7],
                [3.8e6, 13.7],
                [5.8e6, 14.8],
            ],
            dtype=float,
        ),
        "baoshihu_shengtaiku": np.array(
            [
                [3.8e4, 7.3],
                [1.0e5, 7.8],
                [2.0e5, 8.4],
                [3.2e5, 8.9],
                [3.8e5, 9.2],
            ],
            dtype=float,
        ),
        "yingrenshi_shengtaiku": np.array(
            [
                [1.0e5, 7.0],
                [4.0e5, 7.6],
                [8.0e5, 8.1],
                [1.2e6, 8.5],
                [1.7e6, 8.9],
            ],
            dtype=float,
        ),
        "jiuwei_shengtaiku": np.array(
            [
                [2.0e5, 6.5],
                [6.0e5, 7.0],
                [1.0e6, 7.4],
                [1.6e6, 7.9],
                [2.2e6, 8.3],
            ],
            dtype=float,
        ),
        "shiyan_storage": np.array(
            [
                [2.6e6, 10.2],
                [8.0e6, 10.9],
                [1.6e7, 11.6],
                [2.4e7, 12.3],
                [3.2e7, 13.0],
            ],
            dtype=float,
        ),
        "tiegang_storage": np.array(
            [
                [2.1e5, 5.5],
                [1.0e7, 6.0],
                [3.0e7, 6.8],
                [6.0e7, 7.8],
                [1.0e8, 9.0],
            ],
            dtype=float,
        ),
    }

    def __init__(self, **kwargs):
        self._vh_model_folder = kwargs.get("model_folder")
        self._vh_curves_cache = None
        self._vh_curve_sources = {}
        super().__init__(**kwargs)

    def pre(self):
        super().pre()
        # Simulation/optimization IO mixins read parameters from self.io.
        # Inject V-H curve points there so model parameter variables are assigned
        # before initialization/transcription.
        if hasattr(self, "io"):
            self._inject_vh_curve_parameters_into_io()
        self._log_curve_initial_state_diagnostics()

    def parameters(self, *args, **kwargs):
        parameters = super().parameters(*args, **kwargs)
        self._inject_vh_curve_parameters(parameters)
        return parameters

    def _inject_vh_curve_parameters_into_io(self):
        curves = self._load_vh_curves()
        if not curves:
            return

        for object_name, vh_pairs in curves.items():
            scalar_names = self._scalar_parameter_names(object_name)
            if scalar_names:
                point_count = len(scalar_names["v"])
                fitted_curve = self._resample_curve(vh_pairs, point_count)
                for i, key in enumerate(scalar_names["v"], start=1):
                    self.io.set_parameter(key, float(fitted_curve[i - 1, 0]))
                for i, key in enumerate(scalar_names["h"], start=1):
                    self.io.set_parameter(key, float(fitted_curve[i - 1, 1]))
                if self.vh_curve_log_diagnostics:
                    src = self._vh_curve_sources.get(object_name, "unknown")
                    logger.info(
                        f"Injected V-H[{object_name}] from {src}: "
                        f"V1={fitted_curve[0, 0]:.3f}, V{point_count}={fitted_curve[-1, 0]:.3f}, "
                        f"H1={fitted_curve[0, 1]:.3f}, H{point_count}={fitted_curve[-1, 1]:.3f}"
                    )

    def _inject_vh_curve_parameters(self, parameters):
        curves = self._load_vh_curves()
        if not curves:
            return

        for object_name, vh_pairs in curves.items():
            self._assign_curve_parameters(parameters, object_name, vh_pairs)

    def _scalar_parameter_names(self, object_name):
        names_v = []
        names_h = []
        key_pattern_v = re.compile(rf"^{re.escape(object_name)}_vh_v(\d+)$")
        key_pattern_h = re.compile(rf"^{re.escape(object_name)}_vh_h(\d+)$")

        for key in self._parameter_variable_names():
            match_v = key_pattern_v.match(key)
            if match_v:
                names_v.append((int(match_v.group(1)), key))
            match_h = key_pattern_h.match(key)
            if match_h:
                names_h.append((int(match_h.group(1)), key))

        if not names_v or not names_h:
            return None

        names_v.sort(key=lambda x: x[0])
        names_h.sort(key=lambda x: x[0])
        n = min(len(names_v), len(names_h))
        return {
            "v": [k for _, k in names_v[:n]],
            "h": [k for _, k in names_h[:n]],
        }

    def _parameter_variable_names(self):
        # SimulationProblem exposes get_parameter_variables(); optimization
        # problems expose parameter symbols via dae_variables["parameters"].
        get_parameter_variables = getattr(self, "get_parameter_variables", None)
        if callable(get_parameter_variables):
            parameter_variables = get_parameter_variables()
            return parameter_variables.keys()

        dae_variables = getattr(self, "dae_variables", None)
        if isinstance(dae_variables, dict):
            return [symbol.name() for symbol in dae_variables.get("parameters", [])]

        return []

    def _assign_curve_parameters(self, parameters, object_name, vh_pairs):
        assigned = False

        # 1) Legacy/array form: <object_name>_vh_curve[i,j]
        parameter_prefix = f"{object_name}_vh_curve"
        pattern = re.compile(rf"^{re.escape(parameter_prefix)}\[(\d+),(\d+)\]$")
        indexed_keys = []

        for key in parameters:
            match = pattern.match(key)
            if match:
                indexed_keys.append((key, int(match.group(1)), int(match.group(2))))

        if indexed_keys:
            point_count = max(i for _, i, _ in indexed_keys)
            fitted_curve = self._resample_curve(vh_pairs, point_count)

            for key, i, j in indexed_keys:
                if j in (1, 2):
                    parameters[key] = float(fitted_curve[i - 1, j - 1])
            assigned = True
        elif parameter_prefix in parameters:
            parameters[parameter_prefix] = vh_pairs
            assigned = True

        # 2) Scalar form: <object_name>_vh_v1..vN and <object_name>_vh_h1..hN
        scalar_v = []
        scalar_h = []
        for key in parameters:
            match_v = re.match(rf"^{re.escape(object_name)}_vh_v(\d+)$", key)
            if match_v:
                scalar_v.append((key, int(match_v.group(1))))
            match_h = re.match(rf"^{re.escape(object_name)}_vh_h(\d+)$", key)
            if match_h:
                scalar_h.append((key, int(match_h.group(1))))

        if scalar_v and scalar_h:
            max_v = max(i for _, i in scalar_v)
            max_h = max(i for _, i in scalar_h)
            point_count = min(max_v, max_h)
            fitted_curve = self._resample_curve(vh_pairs, point_count)

            v_dict = dict(scalar_v)
            h_dict = dict(scalar_h)
            for i in range(1, point_count + 1):
                key_v = v_dict.get(i)
                key_h = h_dict.get(i)
                if key_v is not None:
                    parameters[key_v] = float(fitted_curve[i - 1, 0])
                if key_h is not None:
                    parameters[key_h] = float(fitted_curve[i - 1, 1])
            assigned = True

        if not assigned:
            logger.debug(f"No Modelica V-H parameters found for {object_name}.")

    @staticmethod
    def _resample_curve(vh_pairs, target_count):
        if len(vh_pairs) == 0:
            return vh_pairs
        if target_count <= 1:
            return vh_pairs[:1, :]
        if len(vh_pairs) == target_count:
            return vh_pairs

        # The model uses a small fixed number of V-H nodes (e.g. 5 points).
        # Sampling by V-range can over-compress low-volume regions when V spans
        # multiple orders of magnitude. Sampling uniformly in source-point index
        # preserves the shape implied by the original curve density.
        sample_indices = np.linspace(0, len(vh_pairs) - 1, target_count)
        lower = np.floor(sample_indices).astype(int)
        upper = np.ceil(sample_indices).astype(int)
        alpha = sample_indices - lower

        target_v = (1.0 - alpha) * vh_pairs[lower, 0] + alpha * vh_pairs[upper, 0]
        target_h = np.interp(target_v, vh_pairs[:, 0], vh_pairs[:, 1])
        return np.column_stack((target_v, target_h))

    def _load_vh_curves(self):
        if self._vh_curves_cache is not None:
            return self._vh_curves_cache

        curves = {name: np.array(values, dtype=float) for name, values in self.vh_curve_defaults.items()}
        self._vh_curve_sources = {name: "python_default" for name in self.vh_curve_objects}
        workbook_path = self._resolve_workbook_path()
        if not workbook_path.exists():
            logger.warning(
                f"V-H workbook not found at {workbook_path}. "
                "Python default V-H parameters will be used."
            )
            self._vh_curves_cache = curves
            return self._vh_curves_cache

        try:
            with zipfile.ZipFile(workbook_path, "r") as workbook:
                shared_strings = self._read_shared_strings(workbook)
                sheet_map = self._sheet_name_to_xml_path(workbook)

                for object_name in self.vh_curve_objects:
                    sheet_names = self._candidate_sheet_names(object_name)
                    sheet_name = None
                    sheet_xml_path = None
                    for candidate in sheet_names:
                        sheet_xml_path = sheet_map.get(candidate)
                        if sheet_xml_path is not None:
                            sheet_name = candidate
                            break

                    if sheet_xml_path is None:
                        log_message = (
                            f"Sheet {sheet_names[0]} not found in {workbook_path.name}; "
                            f"falling back to Python default curve for {object_name}."
                        )
                        if object_name in self.vh_curve_optional_objects:
                            logger.info(log_message)
                        else:
                            logger.warning(log_message)
                        continue

                    vh_pairs = self._read_sheet_vh_pairs(workbook, sheet_xml_path, shared_strings)
                    if vh_pairs is None:
                        logger.warning(
                            f"Sheet {sheet_name} has insufficient numeric data; "
                            f"falling back to Python default curve for {object_name}."
                        )
                        continue
                    if not np.all(np.isfinite(vh_pairs)):
                        logger.warning(
                            f"Sheet {sheet_name} contains non-finite values; "
                            f"falling back to Python default curve for {object_name}."
                        )
                        continue

                    vh_pairs, modified = self._sanitize_vh_pairs(vh_pairs)
                    if modified:
                        logger.warning(
                            f"Sheet {sheet_name} for {object_name} was sanitized "
                            "(enforced finite/monotonic V-H consistency)."
                        )

                    curves[object_name] = vh_pairs
                    self._vh_curve_sources[object_name] = f"excel:{sheet_name}"
        except Exception as error:
            logger.warning(
                f"Failed to read V-H curves from workbook {workbook_path}: {error}. "
                "Python default V-H parameters will be used."
            )
            curves = {name: np.array(values, dtype=float) for name, values in self.vh_curve_defaults.items()}
            self._vh_curve_sources = {name: "python_default(exception)" for name in self.vh_curve_objects}

        self._log_curve_quality_diagnostics(curves)
        self._vh_curves_cache = curves
        return self._vh_curves_cache

    def _log_curve_quality_diagnostics(self, curves):
        if not self.vh_curve_log_diagnostics:
            return
        for object_name in self.vh_curve_objects:
            curve = curves.get(object_name)
            if curve is None or len(curve) < 2:
                logger.warning(f"V-H[{object_name}] missing or too short after loading.")
                continue

            source = self._vh_curve_sources.get(object_name, "unknown")
            dv = np.diff(curve[:, 0])
            dh = np.diff(curve[:, 1])
            mono_v = bool(np.all(dv > 0))
            mono_h = bool(np.all(dh >= 0))
            finite = bool(np.all(np.isfinite(curve)))

            logger.info(
                f"V-H[{object_name}] source={source}, points={len(curve)}, "
                f"V_range=[{curve[0, 0]:.3f}, {curve[-1, 0]:.3f}], "
                f"H_range=[{curve[:, 1].min():.3f}, {curve[:, 1].max():.3f}], "
                f"finite={finite}, monotonic_V={mono_v}, monotonic_H={mono_h}"
            )

            if not mono_v:
                bad = np.where(dv <= 0)[0]
                logger.warning(
                    f"V-H[{object_name}] has {len(bad)} non-increasing V steps; "
                    f"min_dV={dv.min():.6g}, first_bad_indices={bad[:5].tolist()}"
                )
            if not mono_h:
                bad = np.where(dh < 0)[0]
                logger.warning(
                    f"V-H[{object_name}] has {len(bad)} decreasing H steps; "
                    f"min_dH={dh.min():.6g}, first_bad_indices={bad[:5].tolist()}"
                )

    def _log_curve_initial_state_diagnostics(self):
        if not self.vh_curve_log_diagnostics:
            return

        curves = self._load_vh_curves()
        if not hasattr(self, "_SimulationProblem__start"):
            logger.debug("Skipping V-H initial-state diagnostics before simulation start is defined.")
            return
        try:
            initial_state = self.initial_state()
        except Exception as error:
            logger.warning(f"Failed to inspect initial_state() for V-H diagnostics: {error}")
            return

        for object_name in self.vh_curve_objects:
            state_name = f"{object_name}.V"
            if state_name not in initial_state:
                continue
            v0 = float(initial_state[state_name])
            curve = curves.get(object_name)
            if curve is None or len(curve) < 2:
                continue
            v_min = float(curve[0, 0])
            v_max = float(curve[-1, 0])
            in_range = v_min <= v0 <= v_max
            message = (
                f"Initial state check for {state_name}: V0={v0:.3f}, "
                f"curve_range=[{v_min:.3f}, {v_max:.3f}], in_range={in_range}"
            )
            if in_range:
                logger.info(message)
            else:
                logger.warning(message)

    def _sanitize_vh_pairs(self, vh_pairs):
        """
        Sanitize V-H points to improve numerical robustness.
        """
        modified = False
        arr = np.array(vh_pairs, dtype=float)

        # Keep finite rows only.
        finite_mask = np.isfinite(arr[:, 0]) & np.isfinite(arr[:, 1])
        if not np.all(finite_mask):
            arr = arr[finite_mask]
            modified = True

        # Sort by V and collapse duplicate V by keeping highest H.
        arr = arr[np.argsort(arr[:, 0])]
        unique_v = []
        unique_h = []
        for v, h in arr:
            if unique_v and np.isclose(v, unique_v[-1]):
                if h > unique_h[-1]:
                    unique_h[-1] = h
                    modified = True
            else:
                unique_v.append(v)
                unique_h.append(h)
        arr = np.column_stack((np.array(unique_v, dtype=float), np.array(unique_h, dtype=float)))

        # Enforce non-decreasing H for physical V-H relations.
        if self.vh_curve_enforce_monotonic_h and len(arr) >= 2:
            h_mono = np.maximum.accumulate(arr[:, 1])
            if np.any(h_mono != arr[:, 1]):
                arr[:, 1] = h_mono
                modified = True

        return arr, modified

    def _candidate_sheet_names(self, object_name):
        aliases = list(self.vh_curve_sheet_aliases.get(object_name, ()))
        default_name = f"{object_name}{self.vh_curve_sheet_suffix}"
        if default_name not in aliases:
            aliases.insert(0, default_name)
        return tuple(aliases)

    def _resolve_workbook_path(self):
        if self._vh_model_folder is not None:
            return Path(self._vh_model_folder) / self.vh_curve_workbook

        if hasattr(self, "_input_folder"):
            return Path(self._input_folder).parent / "model" / self.vh_curve_workbook

        return Path(self.vh_curve_workbook)

    @staticmethod
    def _read_shared_strings(workbook):
        try:
            xml_content = workbook.read("xl/sharedStrings.xml")
        except KeyError:
            return []

        root = ET.fromstring(xml_content)
        strings = []
        for item in root.findall(".//{*}si"):
            strings.append("".join(item.itertext()))
        return strings

    @staticmethod
    def _sheet_name_to_xml_path(workbook):
        workbook_root = ET.fromstring(workbook.read("xl/workbook.xml"))
        relationships_root = ET.fromstring(workbook.read("xl/_rels/workbook.xml.rels"))

        relationship_targets = {}
        for relationship in relationships_root.findall(".//{*}Relationship"):
            relationship_targets[relationship.get("Id")] = relationship.get("Target")

        name_to_path = {}
        rel_ns = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id"
        for sheet in workbook_root.findall(".//{*}sheet"):
            sheet_name = sheet.get("name")
            rel_id = sheet.get(rel_ns)
            target = relationship_targets.get(rel_id)
            if not sheet_name or not target:
                continue
            name_to_path[sheet_name] = "xl/" + target.lstrip("/")

        return name_to_path

    def _read_sheet_vh_pairs(self, workbook, sheet_xml_path, shared_strings):
        sheet_root = ET.fromstring(workbook.read(sheet_xml_path))
        vh_pairs = []

        for row in sheet_root.findall(".//{*}row"):
            row_values = {}
            for cell in row.findall("{*}c"):
                reference = cell.get("r", "")
                column_index = self._column_index(reference)
                if column_index not in (1, 2):
                    continue
                row_values[column_index] = self._cell_to_text(cell, shared_strings)

            z_value = self._to_float(row_values.get(1))
            v_value = self._to_float(row_values.get(2))
            if z_value is not None and v_value is not None:
                vh_pairs.append((v_value * self.vh_curve_volume_multiplier, z_value))

        if len(vh_pairs) < 2:
            return None

        vh_pairs = np.array(vh_pairs, dtype=float)
        vh_pairs = vh_pairs[np.argsort(vh_pairs[:, 0])]
        _, unique_indices = np.unique(vh_pairs[:, 0], return_index=True)
        vh_pairs = vh_pairs[np.sort(unique_indices)]

        if len(vh_pairs) < 2:
            return None

        return vh_pairs

    @staticmethod
    def _column_index(cell_reference):
        match = re.match(r"([A-Za-z]+)", cell_reference)
        if match is None:
            return None

        letters = match.group(1).upper()
        index = 0
        for letter in letters:
            index = index * 26 + (ord(letter) - ord("A") + 1)
        return index

    @staticmethod
    def _cell_to_text(cell, shared_strings):
        cell_type = cell.get("t")
        if cell_type == "inlineStr":
            inline = cell.find("{*}is")
            return "".join(inline.itertext()) if inline is not None else None

        value = cell.find("{*}v")
        if value is None or value.text is None:
            return None

        text = value.text
        if cell_type == "s":
            index = int(float(text))
            return shared_strings[index] if index < len(shared_strings) else None
        return text

    @staticmethod
    def _to_float(value):
        if value is None:
            return None
        value = str(value).strip()
        if not value:
            return None
        try:
            return float(value)
        except ValueError:
            return None
