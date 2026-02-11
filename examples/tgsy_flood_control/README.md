# tgsy: RTC-Tools real-time flood dispatch template

This folder shows how to turn an OMEdit topology model into an RTC-Tools
simulation/optimization workflow.

## 0) Prerequisites

Before running, make sure your Python environment already contains the
RTC-Tools runtime dependencies (including `casadi` and `pymoca`).

## 1) What was bound in `model/tgsy.mo`

### Exogenous inflows (forecast/measurement)

These are set as `fixed = true` inputs and read from
`input/timeseries_import.csv`:

- `shiyanhe_Q_in`
- `baoshihu_Q_in`
- `yingrenshi_Q_in`
- `jiuwei_Q_in`
- `shiyan_else_Q_in`
- `tiegang_else_Q_in`

### Dispatch controls (decision variables)

These are set as `fixed = false` inputs and mapped to each
`DischargeControlledStructure.Q`:

- `jiuwei_liantongzha_Q`
- `yingrenshi_xieshuizha_Q`
- `yingrenshi_liantongzha_Q`
- `jiuwei_xieshuizha_Q`
- `tiegang_yihongdao_gate_Q`
- `baoshihu_xieshuizha_Q`
- `baoshihu_yihongdao_Q`
- `shiyan_yihongdaozha_Q`
- `shengyanshengtaiku_yan_Q`
- `shiyan_shengtaiku_xieshuizha_Q`

### Outputs (for flood-control evaluation)

- Storage volumes:
  - `shiyan_shengtaiku_V`
  - `baoshihu_shengtaiku_V`
  - `yingrenshi_shengtaiku_V`
  - `jiuwei_shengtaiku_V`
  - `shiyan_storage_V`
  - `tiegang_storage_V`
- Key outflows:
  - `xixianghe_Q`
  - `maozhouhe_Q`
- Water-supply outflows:
  - `shiyan_gongshui_Q`
  - `tiegang_gongshui_Q`

## 2) Property binding strategy

Use these three layers:

1. **Modelica static properties** (component declaration):
   - physical limits, nominal values, constant geometry/efficiency;
   - input min/max bounds (for gate discharge, etc.).
2. **`initial_state.csv`**:
   - initial storage states (e.g. `shiyan_storage.V`).
3. **`timeseries_import.csv`**:
   - inflow hydrographs, optional baseline gate schedules (for simulation),
     and operational targets:
     - `xixianghe_Q_max`, `maozhouhe_Q_max`
     - `*_V_min`, `*_V_max`
     - `shiyan_gongshui_Q_min`, `tiegang_gongshui_Q_min`
     - `shiyan_gongshui_Q_set`, `tiegang_gongshui_Q_set` (supply branch setpoints)

## 2.1) Important: avoid over-constrained topology

If multiple structures are connected directly to the same `Storage.QIn` or
`Storage.QOut`, the model can become over-constrained (`Not_Enough_Degrees_Of_Freedom`).

In this template, multi-in/multi-out nodes are modeled as
`SimpleRouting.Branches.Integrator(n_QLateral = ...)` so each incoming/outgoing
branch has its own connector (`QIn`, `QOut`, `QLateral[i]`).

## 3) Run flood-process simulation

```bash
cd examples/tgsy_flood_control/src
python3 simulation.py
```

Simulation writes results to:

- `examples/tgsy_flood_control/output/timeseries_export.csv`

## 4) Run real-time optimization dispatch

```bash
cd examples/tgsy_flood_control/src
python3 optimization.py
```

Optimization script (`src/optimization.py`) uses four priority layers:

1. Minimize downstream flood risk (`xixianghe_Q`, `maozhouhe_Q`);
2. Meet water-supply minimum flows;
3. Keep storage volumes inside operational bands;
4. Smooth gate movement (`dQ/dt`) to avoid abrupt operations.

## 5) Suggested real-time loop

For each RTC cycle:

1. Update `timeseries_import.csv` with newest rainfall-runoff forecasts;
2. Update current observed storage in `initial_state.csv`;
3. Run `optimization.py` to compute gate discharge trajectories;
4. Apply first control step to field operation;
5. Repeat at next cycle (rolling horizon).

## 6) How to model weirs and gates more accurately

`DischargeControlledStructure` is a practical abstraction when discharge is
directly controlled. For better physical fidelity, use head-dependent formulas.

### 6.1 Sluice gate (orifice-like)

Use gate opening as control variable (`u_gate`), not discharge:

- `Q = C_d * b * a(u_gate) * sqrt(2 * g * max(H_up - H_down, 0))`

where:

- `b`: gate width
- `a(u_gate)`: opening height from control command
- `C_d`: discharge coefficient (calibrated)

### 6.2 Weir

For free overflow:

- `Q = C_w * b * H_eff^(3/2)`

For drowned/submerged conditions, apply a submergence correction factor.

### 6.3 Practical RTC-Tools setup

1. Keep the network topology in Modelica as now;
2. Replace pure `Q` controls by structure opening controls where needed;
3. Implement discharge equations in Modelica (or use lookup tables);
4. In optimization, constrain opening rates (`du/dt`) for actuator realism;
5. Calibrate `C_d`, `C_w`, and submergence corrections against measurements.

For very nonlinear regime switching, start with smooth approximations to avoid
solver instability, then add regime logic if needed.
