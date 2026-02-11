model tgsy
  import SI = Modelica.Units.SI;

  function level_from_v_curve
    input SI.Volume V;
    input Real[:, 2] vh_curve;
    output SI.Position H;
  protected
    Integer n;
  algorithm
    n := size(vh_curve, 1);
    H := vh_curve[1, 2];
    if V <= vh_curve[1, 1] then
      H := vh_curve[1, 2];
    elseif V >= vh_curve[n, 1] then
      H := vh_curve[n, 2];
    else
      for i in 1:n - 1 loop
        if V >= vh_curve[i, 1] and V <= vh_curve[i + 1, 1] then
          H := vh_curve[i, 2] + (vh_curve[i + 1, 2] - vh_curve[i, 2]) * (V - vh_curve[i, 1]) / (vh_curve[i + 1, 1] - vh_curve[i, 1]);
        end if;
      end for;
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

  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal xixianghe annotation(
    Placement(transformation(origin = {55, -55}, extent = {{-5, -5}, {5, 5}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.Branches.Integrator xixianghe_junction(n_QLateral = 1) annotation(
    Placement(transformation(origin = {55, -44}, extent = {{-4, -4}, {4, 4}}, rotation = -90)));
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

  parameter Real[5, 2] shiyan_shengtaiku_vh_curve = [2.0e5, 11.0; 8.0e5, 11.8; 2.0e6, 12.7; 3.8e6, 13.7; 5.8e6, 14.8];
  parameter Real[5, 2] baoshihu_shengtaiku_vh_curve = [3.8e4, 7.3; 1.0e5, 7.8; 2.0e5, 8.4; 3.2e5, 8.9; 3.8e5, 9.2];
  parameter Real[5, 2] yingrenshi_shengtaiku_storage_vh_curve = [1.0e5, 7.0; 4.0e5, 7.6; 8.0e5, 8.1; 1.2e6, 8.5; 1.7e6, 8.9];
  parameter Real[5, 2] jiuwei_shengtaiku_vh_curve = [2.0e5, 6.5; 6.0e5, 7.0; 1.0e6, 7.4; 1.6e6, 7.9; 2.2e6, 8.3];
  parameter Real[5, 2] shiyan_storage_vh_curve = [2.6e6, 10.2; 8.0e6, 10.9; 1.6e7, 11.6; 2.4e7, 12.3; 3.2e7, 13.0];
  parameter Real[5, 2] tiegang_storage_vh_curve = [2.1e5, 5.5; 1.0e7, 6.0; 3.0e7, 6.8; 6.0e7, 7.8; 1.0e8, 9.0];
  parameter Real[5, 2] xixianghe_junction_vh_curve = [0.0, 2.0; 5.0e3, 2.2; 1.0e4, 2.35; 2.0e4, 2.5; 4.0e4, 2.7];

  parameter Real baoshihu_yihongdao_weir_coefficient = 1.7;
  parameter SI.Length baoshihu_yihongdao_weir_width = 10.0;
  parameter SI.Position baoshihu_yihongdao_crest_level = 8.8;
  parameter SI.VolumeFlowRate baoshihu_yihongdao_q_max = 1500.0;

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
  output SI.Position xixianghe_junction_H;
  output SI.VolumeFlowRate xixianghe_Q = xixianghe.QIn.Q;
  output SI.VolumeFlowRate maozhouhe_Q = maozhouhe.QIn.Q;
  output SI.VolumeFlowRate shiyan_gongshui_Q = shiyan_gongshui.QIn.Q;
  output SI.VolumeFlowRate tiegang_gongshui_Q = tiegang_gongshui.QIn.Q;
  output SI.VolumeFlowRate baoshihu_yihongdao_Q_calc;

equation
  // Junction to outfall is modeled without local storage dynamics.
  der(xixianghe_junction.V) = 0;

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

  shiyan_shengtaiku_H = level_from_v_curve(shiyan_shengtaiku.V, shiyan_shengtaiku_vh_curve);
  baoshihu_shengtaiku_H = level_from_v_curve(baoshihu_shengtaiku.V, baoshihu_shengtaiku_vh_curve);
  yingrenshi_shengtaiku_H = level_from_v_curve(yingrenshi_shengtaiku_storage.V, yingrenshi_shengtaiku_storage_vh_curve);
  jiuwei_shengtaiku_H = level_from_v_curve(jiuwei_shengtaiku.V, jiuwei_shengtaiku_vh_curve);
  shiyan_storage_H = level_from_v_curve(shiyan_storage.V, shiyan_storage_vh_curve);
  tiegang_storage_H = level_from_v_curve(tiegang_storage.V, tiegang_storage_vh_curve);
  xixianghe_junction_H = level_from_v_curve(xixianghe_junction.V, xixianghe_junction_vh_curve);

  baoshihu_yihongdao_Q_calc = min(
    baoshihu_yihongdao_q_max,
    baoshihu_yihongdao_weir_coefficient * baoshihu_yihongdao_weir_width * noEvent(max(baoshihu_shengtaiku_H - baoshihu_yihongdao_crest_level, 0.0)) ^ (3.0 / 2.0)
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
  connect(jiuwei_xieshuizha.QOut, xixianghe_junction.QIn) annotation(
    Line(points = {{34, -9.2}, {34, -30.7}, {55, -30.7}, {55, -40.8}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_storage.QOut, tiegang_yihongdao_gate.QIn) annotation(
    Line(points = {{70, -26}, {70, -34}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_yihongdao_gate.QOut, xixianghe_junction.QLateral[1]) annotation(
    Line(points = {{70, -41.2}, {58.2, -41.2}, {58.2, -44}}, arrow = {Arrow.None, Arrow.Filled}));
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
  connect(xixianghe_junction.QOut, xixianghe.QIn) annotation(
    Line(points = {{55, -47.2}, {55, -51.2}}, arrow = {Arrow.None, Arrow.Filled}));

  annotation(
    Diagram(coordinateSystem(extent = {{0, 120}, {120, -80}})));
end tgsy;
