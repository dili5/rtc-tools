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
    vh_curve_objects = (
        "shiyan_shengtaiku",
        "baoshihu_shengtaiku",
        "yingrenshi_shengtaiku_storage",
        "jiuwei_shengtaiku",
        "shiyan_storage",
        "tiegang_storage",
        "xixianghe_junction",
    )
    # Object -> allowed sheet names (in order of preference).
    vh_curve_sheet_aliases = {
        "yingrenshi_shengtaiku_storage": (
            "yingrenshi_shengtaiku_storageZ-V",
            "yingrenshi_shengtaiku_storagZ-V",
        ),
    }
    # Missing sheets for these objects are acceptable and will use defaults.
    vh_curve_optional_objects = {"xixianghe_junction"}
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
        "yingrenshi_shengtaiku_storage": np.array(
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
        "xixianghe_junction": np.array(
            [
                [0.0, 2.0],
                [5.0e3, 2.2],
                [1.0e4, 2.35],
                [2.0e4, 2.5],
                [4.0e4, 2.7],
            ],
            dtype=float,
        ),
    }

    def __init__(self, **kwargs):
        self._vh_model_folder = kwargs.get("model_folder")
        self._vh_curves_cache = None
        super().__init__(**kwargs)

    def pre(self):
        super().pre()
        # Simulation/optimization IO mixins read parameters from self.io.
        # Inject V-H curve points there so model parameter variables are assigned
        # before initialization/transcription.
        if hasattr(self, "io"):
            self._inject_vh_curve_parameters_into_io()

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

        for key in self.get_parameter_variables().keys():
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
        if target_count <= 1 or len(vh_pairs) == target_count:
            return vh_pairs

        v_values = vh_pairs[:, 0]
        h_values = vh_pairs[:, 1]

        target_v = np.linspace(v_values[0], v_values[-1], target_count)
        target_h = np.interp(target_v, v_values, h_values)
        return np.column_stack((target_v, target_h))

    def _load_vh_curves(self):
        if self._vh_curves_cache is not None:
            return self._vh_curves_cache

        curves = {name: np.array(values, dtype=float) for name, values in self.vh_curve_defaults.items()}
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

                    curves[object_name] = vh_pairs
        except Exception as error:
            logger.warning(
                f"Failed to read V-H curves from workbook {workbook_path}: {error}. "
                "Python default V-H parameters will be used."
            )
            curves = {name: np.array(values, dtype=float) for name, values in self.vh_curve_defaults.items()}

        self._vh_curves_cache = curves
        return self._vh_curves_cache

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
