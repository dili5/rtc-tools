model tgsy
  import SI = Modelica.Units.SI;

  function level_from_v_curve
    input SI.Volume V;
    input Real V1;
    input Real V2;
    input Real V3;
    input Real V4;
    input Real V5;
    input Real H1;
    input Real H2;
    input Real H3;
    input Real H4;
    input Real H5;
    output SI.Position H;
  protected
    Real eps_v;
  algorithm
    eps_v := 1e-6;
    if V <= V1 then
      H := H1;
    elseif V <= V2 then
      H := H1 + (H2 - H1) * (V - V1) / max(V2 - V1, eps_v);
    elseif V <= V3 then
      H := H2 + (H3 - H2) * (V - V2) / max(V3 - V2, eps_v);
    elseif V <= V4 then
      H := H3 + (H4 - H3) * (V - V3) / max(V4 - V3, eps_v);
    elseif V <= V5 then
      H := H4 + (H5 - H4) * (V - V4) / max(V5 - V4, eps_v);
    else
      H := H5;
    end if;
  end level_from_v_curve;

  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow shiyanhe_inflow annotation(
    Placement(transformation(origin = {115, 95}, extent = {{5, -5}, {-5, 5}})));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow baoshihu_inflow annotation(
    Placement(transformation(origin = {106, 2}, extent = {{4, -4}, {-4, 4}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow yingrenshi_inflow annotation(
    Placement(transformation(origin = {94, 36}, extent = {{-4, -4}, {4, 4}}, rotation = 270)));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow jiuwei_inflow annotation(
    Placement(transformation(origin = {14, 6}, extent = {{-4, -4}, {4, 4}})));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow shiyan_else_inflow annotation(
    Placement(transformation(origin = {34, 90}, extent = {{-4, -4}, {4, 4}})));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Inflow tiegang_else_inflow annotation(
    Placement(transformation(origin = {54, 14}, extent = {{-4, -4}, {4, 4}})));

  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal xixianghe_from_jiuwei annotation(
    Placement(transformation(origin = {48, -55}, extent = {{-5, -5}, {5, 5}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal xixianghe_from_tiegang annotation(
    Placement(transformation(origin = {62, -55}, extent = {{-5, -5}, {5, 5}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal maozhouhe annotation(
    Placement(transformation(origin = {65, 115}, extent = {{5, 5}, {-5, -5}})));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal shiyan_gongshui annotation(
    Placement(transformation(origin = {34, 50}, extent = {{4, -4}, {-4, 4}})));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal tiegang_gongshui annotation(
    Placement(transformation(origin = {86, -26}, extent = {{-4, -4}, {4, 4}})));

  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator shiyan_shengtaiku(n_QLateral = 1) annotation(
    Placement(transformation(origin = {95, 95}, extent = {{5, -5}, {-5, 5}})));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator baoshihu_shengtaiku(n_QLateral = 1) annotation(
    Placement(transformation(origin = {106, 14}, extent = {{-4, 4}, {4, -4}}, rotation = 90)));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator yingrenshi_shengtaiku_storage(
    n_QLateral = 2
  ) annotation(
    Placement(transformation(origin = {94, 26}, extent = {{-4, -4}, {4, 4}}, rotation = 180)));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator jiuwei_shengtaiku(n_QLateral = 2) annotation(
    Placement(transformation(origin = {26, 6}, extent = {{-4, -4}, {4, 4}})));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator shiyan_storage(n_QLateral = 2) annotation(
    Placement(transformation(origin = {50, 66}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator tiegang_storage(n_QLateral = 5) annotation(
    Placement(transformation(origin = {70, -10}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));

  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure jiuwei_liantongzha annotation(
    Placement(transformation(origin = {46, 6}, extent = {{-4, -4}, {4, 4}})));
  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure yingrenshi_xieshuizha annotation(
    Placement(transformation(origin = {78, 34}, extent = {{4, -4}, {-4, 4}})));
  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure yingrenshi_liantongzha annotation(
    Placement(transformation(origin = {78, 22}, extent = {{4, -4}, {-4, 4}})));
  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure jiuwei_xieshuizha annotation(
    Placement(transformation(origin = {34, -6}, extent = {{-4, -4}, {4, 4}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure tiegang_yihongdao_gate annotation(
    Placement(transformation(origin = {70, -38}, extent = {{-4, -4}, {4, 4}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure baoshihu_xieshuizha annotation(
    Placement(transformation(origin = {106, 26}, extent = {{-4, -4}, {4, 4}}, rotation = 180)));
  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure baoshihu_yihongdao annotation(
    Placement(transformation(origin = {94, 14}, extent = {{-4, -4}, {4, 4}}, rotation = 180)));
  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure shiyan_yihongdaozha annotation(
    Placement(transformation(origin = {61, 41}, extent = {{-3, -3}, {3, 3}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure shengyanshengtaiku_yan annotation(
    Placement(transformation(origin = {66, 90}, extent = {{-4, -4}, {4, 4}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.Structures.DischargeControlledStructure shiyan_shengtaiku_xieshuizha annotation(
    Placement(transformation(origin = {85, 105}, extent = {{5, -5}, {-5, 5}}, rotation = -90)));

  // V-H curves are injected at runtime from Python mixin (Excel/defaults).
  parameter Real shiyan_shengtaiku_vh_v1 = 2.0e5;
  parameter Real shiyan_shengtaiku_vh_v2 = 8.0e5;
  parameter Real shiyan_shengtaiku_vh_v3 = 2.0e6;
  parameter Real shiyan_shengtaiku_vh_v4 = 3.8e6;
  parameter Real shiyan_shengtaiku_vh_v5 = 5.8e6;
  parameter Real shiyan_shengtaiku_vh_h1 = 11.0;
  parameter Real shiyan_shengtaiku_vh_h2 = 11.8;
  parameter Real shiyan_shengtaiku_vh_h3 = 12.7;
  parameter Real shiyan_shengtaiku_vh_h4 = 13.7;
  parameter Real shiyan_shengtaiku_vh_h5 = 14.8;

  parameter Real baoshihu_shengtaiku_vh_v1 = 3.8e4;
  parameter Real baoshihu_shengtaiku_vh_v2 = 1.0e5;
  parameter Real baoshihu_shengtaiku_vh_v3 = 2.0e5;
  parameter Real baoshihu_shengtaiku_vh_v4 = 3.2e5;
  parameter Real baoshihu_shengtaiku_vh_v5 = 3.8e5;
  parameter Real baoshihu_shengtaiku_vh_h1 = 7.3;
  parameter Real baoshihu_shengtaiku_vh_h2 = 7.8;
  parameter Real baoshihu_shengtaiku_vh_h3 = 8.4;
  parameter Real baoshihu_shengtaiku_vh_h4 = 8.9;
  parameter Real baoshihu_shengtaiku_vh_h5 = 9.2;

  parameter Real yingrenshi_shengtaiku_storage_vh_v1 = 1.0e5;
  parameter Real yingrenshi_shengtaiku_storage_vh_v2 = 4.0e5;
  parameter Real yingrenshi_shengtaiku_storage_vh_v3 = 8.0e5;
  parameter Real yingrenshi_shengtaiku_storage_vh_v4 = 1.2e6;
  parameter Real yingrenshi_shengtaiku_storage_vh_v5 = 1.7e6;
  parameter Real yingrenshi_shengtaiku_storage_vh_h1 = 7.0;
  parameter Real yingrenshi_shengtaiku_storage_vh_h2 = 7.6;
  parameter Real yingrenshi_shengtaiku_storage_vh_h3 = 8.1;
  parameter Real yingrenshi_shengtaiku_storage_vh_h4 = 8.5;
  parameter Real yingrenshi_shengtaiku_storage_vh_h5 = 8.9;

  parameter Real jiuwei_shengtaiku_vh_v1 = 2.0e5;
  parameter Real jiuwei_shengtaiku_vh_v2 = 6.0e5;
  parameter Real jiuwei_shengtaiku_vh_v3 = 1.0e6;
  parameter Real jiuwei_shengtaiku_vh_v4 = 1.6e6;
  parameter Real jiuwei_shengtaiku_vh_v5 = 2.2e6;
  parameter Real jiuwei_shengtaiku_vh_h1 = 6.5;
  parameter Real jiuwei_shengtaiku_vh_h2 = 7.0;
  parameter Real jiuwei_shengtaiku_vh_h3 = 7.4;
  parameter Real jiuwei_shengtaiku_vh_h4 = 7.9;
  parameter Real jiuwei_shengtaiku_vh_h5 = 8.3;

  parameter Real shiyan_storage_vh_v1 = 2.6e6;
  parameter Real shiyan_storage_vh_v2 = 8.0e6;
  parameter Real shiyan_storage_vh_v3 = 1.6e7;
  parameter Real shiyan_storage_vh_v4 = 2.4e7;
  parameter Real shiyan_storage_vh_v5 = 3.2e7;
  parameter Real shiyan_storage_vh_h1 = 10.2;
  parameter Real shiyan_storage_vh_h2 = 10.9;
  parameter Real shiyan_storage_vh_h3 = 11.6;
  parameter Real shiyan_storage_vh_h4 = 12.3;
  parameter Real shiyan_storage_vh_h5 = 13.0;

  parameter Real tiegang_storage_vh_v1 = 2.1e5;
  parameter Real tiegang_storage_vh_v2 = 1.0e7;
  parameter Real tiegang_storage_vh_v3 = 3.0e7;
  parameter Real tiegang_storage_vh_v4 = 6.0e7;
  parameter Real tiegang_storage_vh_v5 = 1.0e8;
  parameter Real tiegang_storage_vh_h1 = 5.5;
  parameter Real tiegang_storage_vh_h2 = 6.0;
  parameter Real tiegang_storage_vh_h3 = 6.8;
  parameter Real tiegang_storage_vh_h4 = 7.8;
  parameter Real tiegang_storage_vh_h5 = 9.0;

  parameter Real baoshihu_yihongdao_weir_coefficient = 1.7;
  parameter SI.Length baoshihu_yihongdao_weir_width = 10.0;
  parameter SI.Position baoshihu_yihongdao_crest_level = 8.8;
  parameter SI.VolumeFlowRate baoshihu_yihongdao_q_max = 1500.0;
  parameter SI.Length baoshihu_yihongdao_head_smoothing = 1e-2;
  parameter SI.Length baoshihu_yihongdao_head_floor = 1e-6;
  parameter SI.VolumeFlowRate baoshihu_yihongdao_q_smoothing = 1e-2;

  input SI.VolumeFlowRate shiyanhe_Q_in(fixed = true);
  input SI.VolumeFlowRate baoshihu_Q_in(fixed = true);
  input SI.VolumeFlowRate yingrenshi_Q_in(fixed = true);
  input SI.VolumeFlowRate jiuwei_Q_in(fixed = true);
  input SI.VolumeFlowRate shiyan_else_Q_in(fixed = true);
  input SI.VolumeFlowRate tiegang_else_Q_in(fixed = true);
  input SI.VolumeFlowRate shiyan_gongshui_Q_set(fixed = false, min = 0.0, max = 1000.0);
  input SI.VolumeFlowRate tiegang_gongshui_Q_set(fixed = false, min = 0.0, max = 1000.0);

  input SI.VolumeFlowRate jiuwei_liantongzha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate yingrenshi_xieshuizha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate yingrenshi_liantongzha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate jiuwei_xieshuizha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate tiegang_yihongdao_gate_Q(fixed = false, min = 0.0, max = 2000.0);
  input SI.VolumeFlowRate baoshihu_xieshuizha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate shiyan_yihongdaozha_Q(fixed = false, min = 0.0, max = 2000.0);
  input SI.VolumeFlowRate shengyanshengtaiku_yan_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate shiyan_shengtaiku_xieshuizha_Q(
    fixed = false,
    min = 0.0,
    max = 1500.0
  );

  output SI.Volume shiyan_shengtaiku_V = shiyan_shengtaiku.V;
  output SI.Volume baoshihu_shengtaiku_V = baoshihu_shengtaiku.V;
  output SI.Volume yingrenshi_shengtaiku_V = yingrenshi_shengtaiku_storage.V;
  output SI.Volume jiuwei_shengtaiku_V = jiuwei_shengtaiku.V;
  output SI.Volume shiyan_storage_V = shiyan_storage.V;
  output SI.Volume tiegang_storage_V = tiegang_storage.V;
  output SI.Position shiyan_shengtaiku_H;
  output SI.Position baoshihu_shengtaiku_H;
  output SI.Position yingrenshi_shengtaiku_H;
  output SI.Position jiuwei_shengtaiku_H;
  output SI.Position shiyan_storage_H;
  output SI.Position tiegang_storage_H;
  output SI.VolumeFlowRate xixianghe_Q = xixianghe_from_jiuwei.QIn.Q + xixianghe_from_tiegang.QIn.Q;
  output SI.VolumeFlowRate maozhouhe_Q = maozhouhe.QIn.Q;
  output SI.VolumeFlowRate shiyan_gongshui_Q = shiyan_gongshui.QIn.Q;
  output SI.VolumeFlowRate tiegang_gongshui_Q = tiegang_gongshui.QIn.Q;
  output SI.Length baoshihu_yihongdao_head_raw;
  output SI.VolumeFlowRate baoshihu_yihongdao_Q_calc;
  output SI.Length baoshihu_yihongdao_head_eff;
  output SI.VolumeFlowRate baoshihu_yihongdao_Q_free;

equation
  shiyanhe_inflow.Q = shiyanhe_Q_in;
  baoshihu_inflow.Q = baoshihu_Q_in;
  yingrenshi_inflow.Q = yingrenshi_Q_in;
  jiuwei_inflow.Q = jiuwei_Q_in;
  shiyan_else_inflow.Q = shiyan_else_Q_in;
  tiegang_else_inflow.Q = tiegang_else_Q_in;
  shiyan_storage.QLateral[1].Q = shiyan_gongshui_Q_set;
  tiegang_storage.QLateral[5].Q = tiegang_gongshui_Q_set;

  jiuwei_liantongzha.Q = jiuwei_liantongzha_Q;
  yingrenshi_xieshuizha.Q = yingrenshi_xieshuizha_Q;
  yingrenshi_liantongzha.Q = yingrenshi_liantongzha_Q;
  jiuwei_xieshuizha.Q = jiuwei_xieshuizha_Q;
  tiegang_yihongdao_gate.Q = tiegang_yihongdao_gate_Q;
  baoshihu_xieshuizha.Q = baoshihu_xieshuizha_Q;
  shiyan_yihongdaozha.Q = shiyan_yihongdaozha_Q;
  shengyanshengtaiku_yan.Q = shengyanshengtaiku_yan_Q;
  shiyan_shengtaiku_xieshuizha.Q = shiyan_shengtaiku_xieshuizha_Q;

  shiyan_shengtaiku_H = level_from_v_curve(
    shiyan_shengtaiku.V,
    shiyan_shengtaiku_vh_v1,
    shiyan_shengtaiku_vh_v2,
    shiyan_shengtaiku_vh_v3,
    shiyan_shengtaiku_vh_v4,
    shiyan_shengtaiku_vh_v5,
    shiyan_shengtaiku_vh_h1,
    shiyan_shengtaiku_vh_h2,
    shiyan_shengtaiku_vh_h3,
    shiyan_shengtaiku_vh_h4,
    shiyan_shengtaiku_vh_h5
  );
  baoshihu_shengtaiku_H = level_from_v_curve(
    baoshihu_shengtaiku.V,
    baoshihu_shengtaiku_vh_v1,
    baoshihu_shengtaiku_vh_v2,
    baoshihu_shengtaiku_vh_v3,
    baoshihu_shengtaiku_vh_v4,
    baoshihu_shengtaiku_vh_v5,
    baoshihu_shengtaiku_vh_h1,
    baoshihu_shengtaiku_vh_h2,
    baoshihu_shengtaiku_vh_h3,
    baoshihu_shengtaiku_vh_h4,
    baoshihu_shengtaiku_vh_h5
  );
  yingrenshi_shengtaiku_H = level_from_v_curve(
    yingrenshi_shengtaiku_storage.V,
    yingrenshi_shengtaiku_storage_vh_v1,
    yingrenshi_shengtaiku_storage_vh_v2,
    yingrenshi_shengtaiku_storage_vh_v3,
    yingrenshi_shengtaiku_storage_vh_v4,
    yingrenshi_shengtaiku_storage_vh_v5,
    yingrenshi_shengtaiku_storage_vh_h1,
    yingrenshi_shengtaiku_storage_vh_h2,
    yingrenshi_shengtaiku_storage_vh_h3,
    yingrenshi_shengtaiku_storage_vh_h4,
    yingrenshi_shengtaiku_storage_vh_h5
  );
  jiuwei_shengtaiku_H = level_from_v_curve(
    jiuwei_shengtaiku.V,
    jiuwei_shengtaiku_vh_v1,
    jiuwei_shengtaiku_vh_v2,
    jiuwei_shengtaiku_vh_v3,
    jiuwei_shengtaiku_vh_v4,
    jiuwei_shengtaiku_vh_v5,
    jiuwei_shengtaiku_vh_h1,
    jiuwei_shengtaiku_vh_h2,
    jiuwei_shengtaiku_vh_h3,
    jiuwei_shengtaiku_vh_h4,
    jiuwei_shengtaiku_vh_h5
  );
  shiyan_storage_H = level_from_v_curve(
    shiyan_storage.V,
    shiyan_storage_vh_v1,
    shiyan_storage_vh_v2,
    shiyan_storage_vh_v3,
    shiyan_storage_vh_v4,
    shiyan_storage_vh_v5,
    shiyan_storage_vh_h1,
    shiyan_storage_vh_h2,
    shiyan_storage_vh_h3,
    shiyan_storage_vh_h4,
    shiyan_storage_vh_h5
  );
  tiegang_storage_H = level_from_v_curve(
    tiegang_storage.V,
    tiegang_storage_vh_v1,
    tiegang_storage_vh_v2,
    tiegang_storage_vh_v3,
    tiegang_storage_vh_v4,
    tiegang_storage_vh_v5,
    tiegang_storage_vh_h1,
    tiegang_storage_vh_h2,
    tiegang_storage_vh_h3,
    tiegang_storage_vh_h4,
    tiegang_storage_vh_h5
  );

  // Smooth positive-part head to avoid singular Hessian at crest level.
  baoshihu_yihongdao_head_raw = 0.5 * (
    (baoshihu_shengtaiku_H - baoshihu_yihongdao_crest_level) + sqrt((baoshihu_shengtaiku_H - baoshihu_yihongdao_crest_level) ^ 2 + baoshihu_yihongdao_head_smoothing ^ 2)
  );
  // Guard against tiny negative values from floating-point cancellation.
  baoshihu_yihongdao_head_eff = max(baoshihu_yihongdao_head_raw, baoshihu_yihongdao_head_floor);
  baoshihu_yihongdao_Q_free = baoshihu_yihongdao_weir_coefficient * baoshihu_yihongdao_weir_width * baoshihu_yihongdao_head_eff * sqrt(baoshihu_yihongdao_head_eff);
  // Smooth min(Q_free, Q_max) to keep equations differentiable.
  baoshihu_yihongdao_Q_calc = baoshihu_yihongdao_q_max - 0.5 * (
    (baoshihu_yihongdao_q_max - baoshihu_yihongdao_Q_free) + sqrt((baoshihu_yihongdao_q_max - baoshihu_yihongdao_Q_free) ^ 2 + baoshihu_yihongdao_q_smoothing ^ 2)
  );
  baoshihu_yihongdao.Q = baoshihu_yihongdao_Q_calc;

  connect(shiyan_storage.QLateral[1], shiyan_gongshui.QIn) annotation(
    Line(points = {{50, 63.2}, {44, 63.2}, {44, 50}, {37, 50}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyanhe_inflow.QOut, shiyan_shengtaiku.QIn) annotation(
    Line(points = {{111, 95}, {99, 95}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_else_inflow.QOut, shiyan_storage.QIn) annotation(
    Line(points = {{37.2, 90}, {50.2, 90}, {50.2, 82}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_inflow.QOut, baoshihu_shengtaiku.QIn) annotation(
    Line(points = {{106, 5.2}, {106, 11.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_inflow.QOut, jiuwei_shengtaiku.QIn) annotation(
    Line(points = {{17.2, 6}, {23.2, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_storage.QLateral[5], tiegang_gongshui.QIn) annotation(
    Line(points = {{76.5, -9.7}, {80, -9.7}, {80, -26}, {83, -26}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_else_inflow.QOut, tiegang_storage.QIn) annotation(
    Line(points = {{57.2, 14}, {64.7, 14}, {64.7, 6}, {70, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_shengtaiku.QOut, jiuwei_liantongzha.QIn) annotation(
    Line(points = {{29.2, 6}, {43.2, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_liantongzha.QOut, tiegang_storage.QLateral[1]) annotation(
    Line(points = {{49.2, 6}, {63.5, 6}, {63.5, -9.7}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_shengtaiku_storage.QOut, yingrenshi_xieshuizha.QIn) annotation(
    Line(points = {{90.8, 26}, {87.6, 26}, {87.6, 34}, {80.8, 34}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_xieshuizha.QOut, jiuwei_shengtaiku.QLateral[1]) annotation(
    Line(points = {{74.8, 34}, {22.6, 34}, {22.6, 6.3}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_liantongzha.QOut, tiegang_storage.QLateral[2]) annotation(
    Line(points = {{74.8, 22}, {68, 22}, {68, -9.7}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_shengtaiku.QLateral[2], jiuwei_xieshuizha.QIn) annotation(
    Line(points = {{26.3, 9.2}, {34.2, 9.2}, {34.2, -3}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_xieshuizha.QOut, xixianghe_from_jiuwei.QIn) annotation(
    Line(points = {{34, -9.2}, {34, -30.7}, {48, -30.7}, {48, -51.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_storage.QOut, tiegang_yihongdao_gate.QIn) annotation(
    Line(points = {{70, -26}, {70, -34}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_yihongdao_gate.QOut, xixianghe_from_tiegang.QIn) annotation(
    Line(points = {{70, -41.2}, {62, -41.2}, {62, -51.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_shengtaiku.QOut, baoshihu_xieshuizha.QIn) annotation(
    Line(points = {{106, 17.2}, {106, 20.3}, {109, 20.3}, {109, 26.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_xieshuizha.QOut, yingrenshi_shengtaiku_storage.QLateral[1]) annotation(
    Line(points = {{102.8, 26}, {98, 26}, {98, 29.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_shengtaiku.QLateral[1], baoshihu_yihongdao.QIn) annotation(
    Line(points = {{106.3, 17.2}, {103, 17.2}, {103, 14.2}, {97, 14.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_storage.QOut, shiyan_yihongdaozha.QIn) annotation(
    Line(points = {{50, 50}, {61, 50}, {61, 43}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_yihongdaozha.QOut, tiegang_storage.QLateral[3]) annotation(
    Line(points = {{61, 38.6}, {72, 38.6}, {72, -9.7}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_shengtaiku.QOut, shengyanshengtaiku_yan.QIn) annotation(
    Line(points = {{91, 95}, {82, 95}, {82, 93}, {66, 93}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shengyanshengtaiku_yan.QOut, shiyan_storage.QLateral[2]) annotation(
    Line(points = {{66, 86.8}, {66, 81.6}, {53.2, 81.6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_shengtaiku.QLateral[1], shiyan_shengtaiku_xieshuizha.QIn) annotation(
    Line(points = {{91.8, 95}, {85, 95}, {85, 101}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_shengtaiku_xieshuizha.QOut, maozhouhe.QIn) annotation(
    Line(points = {{85, 109}, {81.5, 109}, {81.5, 115}, {69, 115}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_yihongdao.QOut, tiegang_storage.QLateral[4]) annotation(
    Line(points = {{90.8, 14}, {74, 14}, {74, -9.7}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_inflow.QOut, yingrenshi_shengtaiku_storage.QIn) annotation(
    Line(points = {{94, 32.8}, {94, 29.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_shengtaiku_storage.QLateral[2], yingrenshi_liantongzha.QIn) annotation(
    Line(points = {{91.2, 29.2}, {84, 29.2}, {84, 22}, {80.8, 22}}, arrow = {Arrow.None, Arrow.Filled}));

  annotation(
    Diagram(coordinateSystem(extent = {{0, 120}, {120, -80}})));
end tgsy;
