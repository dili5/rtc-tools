model TwoReservoirFloodModel
  // Initial storage
  parameter Modelica.Units.SI.Volume V_a_init = 1.45e6;
  parameter Modelica.Units.SI.Volume V_b_init = 1.00e6;

  // Storage-elevation relation: h = z_ref + V / A_surface
  parameter Modelica.Units.SI.Area A_surface_a = 2.0e5;
  parameter Modelica.Units.SI.Area A_surface_b = 3.0e5;
  parameter Modelica.Units.SI.Height z_ref_a = 30.0;
  parameter Modelica.Units.SI.Height z_ref_b = 30.0;

  // A -> B spillway relation
  parameter Modelica.Units.SI.Height spill_crest_a_to_b = 38.14;
  parameter Real weir_coefficient(unit = "m3/s/m^(3/2)") = 120.0;

  // Gate capacities
  parameter Modelica.Units.SI.VolumeFlowRate max_gate_a = 20.0;
  parameter Modelica.Units.SI.VolumeFlowRate max_release_b = 394.0;
  parameter Modelica.Units.SI.VolumeFlowRate max_supply_b = 5.0;

  // Optional controller parameters used in Python update()
  parameter Modelica.Units.SI.Height level_a_target = 37.8;
  parameter Modelica.Units.SI.Height level_b_target = 34.5;
  parameter Real Kp_gate_a(unit = "m2/s") = 120.0;
  parameter Real Kp_release_b(unit = "m2/s") = 280.0;
  parameter Real Kff_release_b = 1.0;

  // Inputs
  input Modelica.Units.SI.VolumeFlowRate Q_in_a(fixed = true);
  input Modelica.Units.SI.VolumeFlowRate Q_in_b(fixed = true);
  input Modelica.Units.SI.VolumeFlowRate Q_supply_demand(fixed = true);
  input Modelica.Units.SI.VolumeFlowRate Q_gate_a_cmd(fixed = true);
  input Modelica.Units.SI.VolumeFlowRate Q_release_b_cmd(fixed = true);
  input Modelica.Units.SI.VolumeFlowRate Q_supply_cmd(fixed = true);

  // Dynamic states
  Modelica.Units.SI.Volume V_a(start = V_a_init, fixed = true, min = 0.0, nominal = 1e6);
  Modelica.Units.SI.Volume V_b(start = V_b_init, fixed = true, min = 0.0, nominal = 1e6);

  // Internal variables
  Modelica.Units.SI.Height h_a;
  Modelica.Units.SI.Height h_b;
  Modelica.Units.SI.VolumeFlowRate Q_spill_ab;
  Modelica.Units.SI.VolumeFlowRate Q_gate_a;
  Modelica.Units.SI.VolumeFlowRate Q_release_b;
  Modelica.Units.SI.VolumeFlowRate Q_supply_b;

  // Outputs
  output Modelica.Units.SI.Volume storage_a = V_a;
  output Modelica.Units.SI.Volume storage_b = V_b;
  output Modelica.Units.SI.Height level_a = h_a;
  output Modelica.Units.SI.Height level_b = h_b;
  output Modelica.Units.SI.VolumeFlowRate Q_spill_ab_out = Q_spill_ab;
  output Modelica.Units.SI.VolumeFlowRate Q_gate_a_out = Q_gate_a;
  output Modelica.Units.SI.VolumeFlowRate Q_release_b_out = Q_release_b;
  output Modelica.Units.SI.VolumeFlowRate Q_supply_b_out = Q_supply_b;
equation
  // Stage-storage relation
  h_a = z_ref_a + V_a / A_surface_a;
  h_b = z_ref_b + V_b / A_surface_b;

  // Spill only activates when level of reservoir A exceeds 38.14 m
  Q_spill_ab = if h_a > spill_crest_a_to_b then
      weir_coefficient * (h_a - spill_crest_a_to_b) ^ 1.5
    else
      0.0;

  // Gate limits
  Q_gate_a = min(max(Q_gate_a_cmd, 0.0), max_gate_a);
  Q_release_b = min(max(Q_release_b_cmd, 0.0), max_release_b);
  Q_supply_b = min(max(Q_supply_cmd, 0.0), max_supply_b);

  // Mass balance
  der(V_a) = Q_in_a - Q_gate_a - Q_spill_ab;
  der(V_b) = Q_in_b + Q_gate_a + Q_spill_ab - Q_release_b - Q_supply_b;
end TwoReservoirFloodModel;
