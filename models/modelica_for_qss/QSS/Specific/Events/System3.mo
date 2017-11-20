within QSS.Specific.Events;
model System3
  "Third part of the system model with air supply and closed loop control"
  extends Modelica.Icons.Example;

  replaceable package MediumA = Buildings.Media.Air "Medium for air";
  replaceable package MediumW = Buildings.Media.Water "Medium for water";

  Buildings.Fluid.MixingVolumes.MixingVolume vol(
    redeclare package Medium = MediumA,
    m_flow_nominal=mA_flow_nominal,
    V=V,
    nPorts=2,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial,
    mSenFac=3)
    annotation (Placement(transformation(extent={{60,20},{80,40}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor theCon(G=10000/30)
    "Thermal conductance with the ambient"
    annotation (Placement(transformation(extent={{20,40},{40,60}})));
  parameter Modelica.SIunits.Volume V=6*10*3 "Room volume";
  //////////////////////////////////////////////////////////
  // Heat recovery effectiveness
  parameter Real eps = 0.8 "Heat recovery effectiveness";

  /////////////////////////////////////////////////////////
  // Air temperatures at design conditions
  parameter Modelica.SIunits.Temperature TASup_nominal = 273.15+18
    "Nominal air temperature supplied to room";
  parameter Modelica.SIunits.Temperature TRooSet = 273.15+24
    "Nominal room air temperature";
  parameter Modelica.SIunits.Temperature TOut_nominal = 273.15+30
    "Design outlet air temperature";
  parameter Modelica.SIunits.Temperature THeaRecLvg=
    TOut_nominal - eps*(TOut_nominal-TRooSet)
    "Air temperature leaving the heat recovery";

  /////////////////////////////////////////////////////////
  // Cooling loads and air mass flow rates
  parameter Modelica.SIunits.HeatFlowRate QRooInt_flow=
     1000 "Internal heat gains of the room";
  parameter Modelica.SIunits.HeatFlowRate QRooC_flow_nominal=
    -QRooInt_flow-10E3/30*(TOut_nominal-TRooSet)
    "Nominal cooling load of the room";
  parameter Modelica.SIunits.MassFlowRate mA_flow_nominal=
    1.3*QRooC_flow_nominal/1006/(TASup_nominal-TRooSet)
    "Nominal air mass flow rate, increased by factor 1.3 to allow for recovery after temperature setback";
  parameter Modelica.SIunits.TemperatureDifference dTFan = 2
    "Estimated temperature raise across fan that needs to be made up by the cooling coil";
  parameter Modelica.SIunits.HeatFlowRate QCoiC_flow_nominal=4*
    (QRooC_flow_nominal + mA_flow_nominal*(TASup_nominal-THeaRecLvg-dTFan)*1006)
    "Cooling load of coil, taking into account economizer, and increased due to latent heat removal";

  /////////////////////////////////////////////////////////
  // Water temperatures and mass flow rates
  parameter Modelica.SIunits.Temperature TWSup_nominal = 273.15+16
    "Water supply temperature";
  parameter Modelica.SIunits.Temperature TWRet_nominal = 273.15+12
    "Water return temperature";
  parameter Modelica.SIunits.MassFlowRate mW_flow_nominal=
    QCoiC_flow_nominal/(TWRet_nominal-TWSup_nominal)/4200
    "Nominal water mass flow rate";

  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature
                                                         TOut
    "Outside temperature"
    annotation (Placement(transformation(extent={{-20,40},{0,60}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow preHea(Q_flow=
        QRooInt_flow) "Prescribed heat flow"
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  Buildings.Fluid.Movers.FlowControlled_m_flow fan(
    redeclare package Medium = MediumA,
    m_flow_nominal=mA_flow_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState) "Supply air fan"
    annotation (Placement(transformation(extent={{40,-30},{60,-10}})));
  Buildings.Fluid.HeatExchangers.ConstantEffectiveness hex(redeclare package
      Medium1 =
        MediumA, redeclare package Medium2 = MediumA,
    m1_flow_nominal=mA_flow_nominal,
    m2_flow_nominal=mA_flow_nominal,
    dp1_nominal=200,
    dp2_nominal=200,
    eps=eps) "Heat recovery"
    annotation (Placement(transformation(extent={{-110,-36},{-90,-16}})));
  Buildings.Fluid.HeatExchangers.WetCoilCounterFlow cooCoi(redeclare package
      Medium1 =
        MediumW, redeclare package Medium2 = MediumA,
    m1_flow_nominal=mW_flow_nominal,
    m2_flow_nominal=mA_flow_nominal,
    dp1_nominal=6000,
    UA_nominal=-QCoiC_flow_nominal/
        Buildings.Fluid.HeatExchangers.BaseClasses.lmtd(
        T_a1=THeaRecLvg,
        T_b1=TASup_nominal,
        T_a2=TWSup_nominal,
        T_b2=TWRet_nominal),
    dp2_nominal=200,
    show_T=true,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    waterSideFlowDependent=false,
    airSideFlowDependent=false)                                "Cooling coil"
                                                               annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-30,-26})));
  Buildings.Fluid.Sources.Outside out(nPorts=2, redeclare package Medium = MediumA)
    annotation (Placement(transformation(extent={{-140,-32},{-120,-12}})));
  Buildings.Fluid.Sources.MassFlowSource_T souWat(
    nPorts=1,
    redeclare package Medium = MediumW,
    use_m_flow_in=true,
    T=TWSup_nominal) "Source for water flow rate"
    annotation (Placement(transformation(extent={{-22,-110},{-2,-90}})));
  Buildings.Fluid.Sources.FixedBoundary sinWat(nPorts=1, redeclare package
      Medium =
        MediumW) "Sink for water circuit"
    annotation (Placement(transformation(extent={{-80,-74},{-60,-54}})));
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    pAtmSou=Buildings.BoundaryConditions.Types.DataSource.Parameter,
    TDryBul=TOut_nominal,
    TDryBulSou=Buildings.BoundaryConditions.Types.DataSource.File,
    filNam=
        "modelica://QSS/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos")
    "Weather data reader"
    annotation (Placement(transformation(extent={{-160,40},{-140,60}})));
  Buildings.BoundaryConditions.WeatherData.Bus weaBus
    annotation (Placement(transformation(extent={{-120,40},{-100,60}})));
  Modelica.Blocks.Sources.Constant mAir_flow(k=mA_flow_nominal)
    "Fan air flow rate"
    annotation (Placement(transformation(extent={{0,0},{20,20}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemHXOut(redeclare package
      Medium =
        MediumA, m_flow_nominal=mA_flow_nominal)
    "Temperature sensor for heat recovery outlet on supply side"
    annotation (Placement(transformation(extent={{-76,-26},{-64,-14}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTemSupAir(redeclare package
      Medium =
        MediumA, m_flow_nominal=mA_flow_nominal)
    "Temperature sensor for supply air"
    annotation (Placement(transformation(extent={{6,-26},{18,-14}})));
  Modelica.Blocks.Sources.Constant TRooSetPoi(k=TRooSet)
    "Room temperature set point"
    annotation (Placement(transformation(extent={{-160,-90},{-140,-70}})));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTemRoo
    "Room temperature sensor"
    annotation (Placement(transformation(extent={{70,70},{90,90}})));
  QSS.Specific.Events.BaseClasses.OnOffControllerQSS2 onOffCon(
      bandwidth=1) annotation (Placement(transformation(extent={{-90,-108},{-70,
            -88}})));
  Modelica.Blocks.Continuous.Der der1
    annotation (Placement(transformation(extent={{-160,-130},{-140,-110}})));
  Modelica.Blocks.Math.Gain gai(k=mW_flow_nominal)
    "Conversion from boolean to real for water flow rate" annotation (
      Placement(transformation(extent={{-54,-110},{-34,-90}})));
  Modelica.Blocks.Interfaces.RealOutput __zc_z1 "Zero crossing variable"
    annotation (Placement(transformation(extent={{120,-10},{140,10}})));
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z1
    "Derivative of zero crossing variable"
    annotation (Placement(transformation(extent={{120,-30},{140,-10}})));
  Modelica.Blocks.Interfaces.RealOutput __zc_z2 "Zero crossing variable"
    annotation (Placement(transformation(extent={{120,-90},{140,-70}})));
  Modelica.Blocks.Interfaces.RealOutput TRooK "Room temperature"
    annotation (Placement(transformation(extent={{120,-70},{140,-50}})));
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z2
    "Derivative of zero crossing variable"
    annotation (Placement(transformation(extent={{120,-130},{140,-110}})));
equation
  connect(theCon.port_b, vol.heatPort) annotation (Line(
      points={{40,50},{50,50},{50,30},{60,30}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(preHea.port, vol.heatPort) annotation (Line(
      points={{40,80},{50,80},{50,30},{60,30}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(fan.port_b, vol.ports[1]) annotation (Line(
      points={{60,-20},{68,-20},{68,20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(vol.ports[2], hex.port_a2) annotation (Line(
      points={{72,20},{72,-46},{-90,-46},{-90,-32}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(out.ports[1], hex.port_a1) annotation (Line(
      points={{-120,-20},{-110,-20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(out.ports[2], hex.port_b2) annotation (Line(
      points={{-120,-24},{-110,-24},{-110,-32}},
      color={0,127,255},
      smooth=Smooth.None));

  connect(souWat.ports[1], cooCoi.port_a1)   annotation (Line(
      points={{-2,-100},{20,-100},{20,-32},{-20,-32}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(cooCoi.port_b1, sinWat.ports[1])    annotation (Line(
      points={{-40,-32},{-48,-32},{-48,-64},{-60,-64}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(weaDat.weaBus, out.weaBus) annotation (Line(
      points={{-140,50},{-128,50},{-128,4},{-148,4},{-148,-21.8},{-140,-21.8}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None));
  connect(weaDat.weaBus, weaBus) annotation (Line(
      points={{-140,50},{-110,50}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(weaBus.TDryBul, TOut.T) annotation (Line(
      points={{-110,50},{-22,50}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}}));
  connect(fan.m_flow_in, mAir_flow.y) annotation (Line(
      points={{50,-8},{50,10},{21,10}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(hex.port_b1, senTemHXOut.port_a) annotation (Line(
      points={{-90,-20},{-76,-20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senTemHXOut.port_b, cooCoi.port_a2) annotation (Line(
      points={{-64,-20},{-40,-20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(cooCoi.port_b2, senTemSupAir.port_a) annotation (Line(
      points={{-20,-20},{6,-20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(senTemSupAir.port_b, fan.port_a) annotation (Line(
      points={{18,-20},{40,-20}},
      color={0,127,255},
      smooth=Smooth.None));
  connect(TOut.port, theCon.port_a) annotation (Line(
      points={{5.55112e-16,50},{20,50}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(vol.heatPort, senTemRoo.port) annotation (Line(
      points={{60,30},{50,30},{50,80},{70,80}},
      color={191,0,0},
      smooth=Smooth.None));
  connect(onOffCon.reference, TRooSetPoi.y) annotation (Line(points={{-92,-92},{
          -120,-92},{-120,-80},{-139,-80}},           color={0,0,127}));
  connect(onOffCon.u, senTemRoo.T) annotation (Line(points={{-92,-98},{-120,-98},
          {-120,-140},{100,-140},{100,80},{90,80}},             color={
          0,0,127}));
  connect(der1.y, onOffCon.der_u) annotation (Line(points={{-139,-120},{-100,-120},
          {-100,-104},{-92,-104}},             color={0,0,127}));
  connect(der1.u, senTemRoo.T) annotation (Line(points={{-162,-120},{
          -174,-120},{-174,-140},{102,-140},{102,80},{90,80}}, color={0,
          0,127}));
  connect(onOffCon.y, gai.u) annotation (Line(points={{-69,-98},{-64,-100},{-56,
          -100}},            color={0,0,127}));
  connect(gai.y, souWat.m_flow_in) annotation (Line(points={{-33,-100},
          {-28,-100},{-28,-92},{-22,-92}}, color={0,0,127}));
  connect(onOffCon._zc_z1, __zc_z1) annotation (Line(points={{-69,-94},{-60,-94},
          {-60,-80},{84,-80},{84,0},{130,0}},           color={0,0,127}));
  connect(__zc_z1, __zc_z1)
    annotation (Line(points={{130,0},{130,0}}, color={0,0,127}));
  connect(onOffCon._zc_der_z1, __zc_der_z1) annotation (Line(points={{-69,-101.8},
          {-60,-101.8},{-60,-120},{94,-120},{94,-20},{130,-20}},
                 color={0,0,127}));
  connect(onOffCon._zc_der_z2, __zc_der_z2) annotation (Line(points={{-69,-104},
          {-66,-104},{-66,-120},{130,-120}},           color={0,0,127}));
  connect(onOffCon._zc_z2, __zc_z2) annotation (Line(points={{-69,-96},{-58,-96},
          {-58,-80},{114,-80},{130,-80}},           color={0,0,127}));
  connect(TRooK, senTemRoo.T) annotation (Line(points={{130,-60},{112,
          -60},{112,80},{90,80}}, color={0,0,127}));
  annotation (Documentation(info="<html>
<p>
This model is a modified version of 
<a href=\"modelica://Buildings.Examples.Tutorial.SpaceCooling.System3\">
Buildings.Examples.Tutorial.SpaceCooling.System3</a>
where the on/off controller is adapted to expose
its zero crossing functions for QSS.
When simulated in Dymola 2017 FD01 (Ubuntu), 
the model has 56 state events which are all triggered 
by the on/off controller.
</p>

</p>
</html>", revisions="<html>
<ul>
<li>
January 28, 2015 by Michael Wetter:<br/>
Added thermal mass of furniture directly to air volume.
This avoids an index reduction.
</li>
<li>
December 22, 2014 by Michael Wetter:<br/>
Removed <code>Modelica.Fluid.System</code>
to address issue
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/311\">#311</a>.
</li>
<li>
January 11, 2012, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-180,-160},{120,
            100}})),
    experiment(StartTime=15552000, Tolerance=1e-6, StopTime=15638400));
end System3;
