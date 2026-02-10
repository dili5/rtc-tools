# Two-reservoir flood routing simulation (RTC-Tools)

This example implements a flood-routing simulation for two reservoirs:

- **Reservoir A** receives local runoff `Q_in_a`.
- When `level_a > 38.14 m`, water spills from A to B over a weir.
- Reservoir A has a gated outlet, max discharge **20 m3/s**.
- Reservoir B has:
  - a downstream release gate, max discharge **394 m3/s**;
  - a water-supply outlet, max discharge **5 m3/s**.

## Model equations

- Storage-elevation relation (linearized):
  - `level_a = z_ref_a + V_a / A_surface_a`
  - `level_b = z_ref_b + V_b / A_surface_b`
- Spillway from A to B:
  - `Q_spill_ab = weir_coefficient * (level_a - 38.14)^1.5`, if `level_a > 38.14`; else `0`.
- Mass balances:
  - `dV_a/dt = Q_in_a - Q_gate_a - Q_spill_ab`
  - `dV_b/dt = Q_in_b + Q_gate_a + Q_spill_ab - Q_release_b - Q_supply_b`
- All gate flows are saturated by their physical maxima.

## Files

- `model/TwoReservoirFloodModel.mo`: Modelica model.
- `src/run_two_reservoir_simulation.py`: RTC-Tools simulation class and run entry point.
- `input/parameters.csv`: model/controller parameters.
- `input/timeseries_import.csv`: inflow and demand timeseries.

## Run

```bash
cd examples/two_reservoir_flood_simulation/src
python run_two_reservoir_simulation.py
```

Simulation output is written to:

- `examples/two_reservoir_flood_simulation/output/timeseries_export.csv`
