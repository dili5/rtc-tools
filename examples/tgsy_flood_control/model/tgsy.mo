model tgsy
  import SI = Modelica.Units.SI;

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
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal maozhouhe annotation(
    Placement(transformation(origin = {65, 115}, extent = {{5, 5}, {-5, -5}})));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal shiyan_gongshui annotation(
    Placement(transformation(origin = {34, 50}, extent = {{4, -4}, {-4, 4}})));
  Deltares.ChannelFlow.SimpleRouting.BoundaryConditions.Terminal tiegang_gongshui annotation(
    Placement(transformation(origin = {86, -26}, extent = {{-4, -4}, {4, 4}})));

  Deltares.ChannelFlow.SimpleRouting.Storage.Storage shiyan_shengtaiku annotation(
    Placement(transformation(origin = {95, 95}, extent = {{5, -5}, {-5, 5}})));
  Deltares.ChannelFlow.SimpleRouting.Storage.Storage baoshihu_shengtaiku annotation(
    Placement(transformation(origin = {106, 14}, extent = {{-4, 4}, {4, -4}}, rotation = 90)));
  Deltares.ChannelFlow.SimpleRouting.Storage.Storage yingrenshi_shengtaiku_storage annotation(
    Placement(transformation(origin = {94, 26}, extent = {{-4, -4}, {4, 4}}, rotation = 180)));
  Deltares.ChannelFlow.SimpleRouting.Storage.Storage jiuwei_shengtaiku annotation(
    Placement(transformation(origin = {26, 6}, extent = {{-4, -4}, {4, 4}})));
  Deltares.ChannelFlow.SimpleRouting.Storage.Storage shiyan_storage annotation(
    Placement(transformation(origin = {50, 66}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
  Deltares.ChannelFlow.SimpleRouting.Storage.Storage tiegang_storage annotation(
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

  input SI.VolumeFlowRate shiyanhe_Q_in(fixed = true);
  input SI.VolumeFlowRate baoshihu_Q_in(fixed = true);
  input SI.VolumeFlowRate yingrenshi_Q_in(fixed = true);
  input SI.VolumeFlowRate jiuwei_Q_in(fixed = true);
  input SI.VolumeFlowRate shiyan_else_Q_in(fixed = true);
  input SI.VolumeFlowRate tiegang_else_Q_in(fixed = true);

  input SI.VolumeFlowRate jiuwei_liantongzha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate yingrenshi_xieshuizha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate yingrenshi_liantongzha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate jiuwei_xieshuizha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate tiegang_yihongdao_gate_Q(fixed = false, min = 0.0, max = 2000.0);
  input SI.VolumeFlowRate baoshihu_xieshuizha_Q(fixed = false, min = 0.0, max = 1500.0);
  input SI.VolumeFlowRate baoshihu_yihongdao_Q(fixed = false, min = 0.0, max = 1500.0);
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
  output SI.VolumeFlowRate xixianghe_Q = xixianghe.QIn.Q;
  output SI.VolumeFlowRate maozhouhe_Q = maozhouhe.QIn.Q;
  output SI.VolumeFlowRate shiyan_gongshui_Q = shiyan_gongshui.QIn.Q;
  output SI.VolumeFlowRate tiegang_gongshui_Q = tiegang_gongshui.QIn.Q;

equation
  shiyanhe_inflow.Q = shiyanhe_Q_in;
  baoshihu_inflow.Q = baoshihu_Q_in;
  yingrenshi_inflow.Q = yingrenshi_Q_in;
  jiuwei_inflow.Q = jiuwei_Q_in;
  shiyan_else_inflow.Q = shiyan_else_Q_in;
  tiegang_else_inflow.Q = tiegang_else_Q_in;

  jiuwei_liantongzha.Q = jiuwei_liantongzha_Q;
  yingrenshi_xieshuizha.Q = yingrenshi_xieshuizha_Q;
  yingrenshi_liantongzha.Q = yingrenshi_liantongzha_Q;
  jiuwei_xieshuizha.Q = jiuwei_xieshuizha_Q;
  tiegang_yihongdao_gate.Q = tiegang_yihongdao_gate_Q;
  baoshihu_xieshuizha.Q = baoshihu_xieshuizha_Q;
  baoshihu_yihongdao.Q = baoshihu_yihongdao_Q;
  shiyan_yihongdaozha.Q = shiyan_yihongdaozha_Q;
  shengyanshengtaiku_yan.Q = shengyanshengtaiku_yan_Q;
  shiyan_shengtaiku_xieshuizha.Q = shiyan_shengtaiku_xieshuizha_Q;

  connect(shiyan_storage.QOut, shiyan_gongshui.QIn) annotation(
    Line(points = {{50, 50}, {37, 50}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyanhe_inflow.QOut, shiyan_shengtaiku.QIn) annotation(
    Line(points = {{111, 95}, {99, 95}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_else_inflow.QOut, shiyan_storage.QIn) annotation(
    Line(points = {{37.2, 90}, {50.2, 90}, {50.2, 82}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_inflow.QOut, baoshihu_shengtaiku.QIn) annotation(
    Line(points = {{106, 5.2}, {106, 11.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_inflow.QOut, jiuwei_shengtaiku.QIn) annotation(
    Line(points = {{17.2, 6}, {23.2, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_storage.QOut, tiegang_gongshui.QIn) annotation(
    Line(points = {{70, -26}, {83, -26}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_else_inflow.QOut, tiegang_storage.QIn) annotation(
    Line(points = {{57.2, 14}, {64.7, 14}, {64.7, 6}, {70, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_shengtaiku.QOut, jiuwei_liantongzha.QIn) annotation(
    Line(points = {{29.2, 6}, {43.2, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_liantongzha.QOut, tiegang_storage.QIn) annotation(
    Line(points = {{49.2, 6}, {70, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_shengtaiku_storage.QOut, yingrenshi_xieshuizha.QIn) annotation(
    Line(points = {{90.8, 26}, {87.6, 26}, {87.6, 34}, {80.8, 34}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_xieshuizha.QOut, jiuwei_shengtaiku.QIn) annotation(
    Line(points = {{74.8, 34}, {22.6, 34}, {22.6, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_shengtaiku_storage.QOut, yingrenshi_liantongzha.QIn) annotation(
    Line(points = {{90.8, 26}, {87.8, 26}, {87.8, 22}, {80.8, 22}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_liantongzha.QOut, tiegang_storage.QIn) annotation(
    Line(points = {{74.8, 22}, {69.8, 22}, {69.8, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_shengtaiku.QOut, jiuwei_xieshuizha.QIn) annotation(
    Line(points = {{29.2, 6}, {34.2, 6}, {34.2, -3}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(jiuwei_xieshuizha.QOut, xixianghe.QIn) annotation(
    Line(points = {{34, -9.2}, {34, -30.7}, {55, -30.7}, {55, -51.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_storage.QOut, tiegang_yihongdao_gate.QIn) annotation(
    Line(points = {{70, -26}, {70, -34}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(tiegang_yihongdao_gate.QOut, xixianghe.QIn) annotation(
    Line(points = {{70, -41.2}, {55, -41.2}, {55, -50.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_shengtaiku.QOut, baoshihu_xieshuizha.QIn) annotation(
    Line(points = {{106, 17.2}, {106, 20.3}, {109, 20.3}, {109, 26.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_xieshuizha.QOut, yingrenshi_shengtaiku_storage.QIn) annotation(
    Line(points = {{102.8, 26}, {96.8, 26}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_shengtaiku.QOut, baoshihu_yihongdao.QIn) annotation(
    Line(points = {{106, 17.2}, {103, 17.2}, {103, 14.2}, {97, 14.2}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_storage.QOut, shiyan_yihongdaozha.QIn) annotation(
    Line(points = {{50, 50}, {61, 50}, {61, 43}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_yihongdaozha.QOut, tiegang_storage.QIn) annotation(
    Line(points = {{61, 38.6}, {70, 38.6}, {70, 5.6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_shengtaiku.QOut, shengyanshengtaiku_yan.QIn) annotation(
    Line(points = {{91, 95}, {82, 95}, {82, 93}, {66, 93}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shengyanshengtaiku_yan.QOut, shiyan_storage.QIn) annotation(
    Line(points = {{66, 86.8}, {66, 81.6}, {50, 81.6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_shengtaiku.QOut, shiyan_shengtaiku_xieshuizha.QIn) annotation(
    Line(points = {{91, 95}, {85, 95}, {85, 101}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(shiyan_shengtaiku_xieshuizha.QOut, maozhouhe.QIn) annotation(
    Line(points = {{85, 109}, {81.5, 109}, {81.5, 115}, {69, 115}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(baoshihu_yihongdao.QOut, tiegang_storage.QIn) annotation(
    Line(points = {{90.8, 14}, {69.8, 14}, {69.8, 6}}, arrow = {Arrow.None, Arrow.Filled}));
  connect(yingrenshi_inflow.QOut, yingrenshi_shengtaiku_storage.QIn) annotation(
    Line(points = {{94, 32.8}, {98, 32.8}, {98, 25.8}}, arrow = {Arrow.None, Arrow.Filled}));

  annotation(
    Diagram(coordinateSystem(extent = {{0, 120}, {120, -80}})));
end tgsy;
