within ;
model System5
  extends Modelica.Icons.Example;
  replaceable package MediumA = Buildings.Media.Air "Medium for air";
  OnOffControllerQSS conQSS(bandwidth=1)
    "Controller for sensible heat flow rate"
    annotation (Placement(transformation(extent={{-78,-16},{-58,4}})));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTemRoo
    "Room temperature sensor"
    annotation (Placement(transformation(extent={{-154,-46},{-134,-26}})));
  Modelica.Blocks.Sources.Constant TRooSetPoi(k=20 + 273.15)
    "Room temperature set point"
    annotation (Placement(transformation(extent={{-160,-10},{-140,10}})));
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3
                                            weaDat(
    pAtmSou=Buildings.BoundaryConditions.Types.DataSource.Parameter,
    TDryBulSou=Buildings.BoundaryConditions.Types.DataSource.File,
    TBlaSkySou=Buildings.BoundaryConditions.Types.DataSource.File,
    filNam=Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"))
    "Weather data reader"
    annotation (Placement(transformation(extent={{-160,30},{-140,50}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TOut
    "Outside temperature"
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor theCon(G=10000/30)
    "Thermal conductance with the ambient"
    annotation (Placement(transformation(extent={{-22,30},{-2,50}})));
  Buildings.Fluid.MixingVolumes.MixingVolume vol(
    redeclare package Medium = MediumA,
    m_flow_nominal=mA_flow_nominal,
    V=V,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    mSenFac=3)
    annotation (Placement(transformation(extent={{70,30},{90,50}})));
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
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow
    annotation (Placement(transformation(extent={{34,-16},{54,4}})));
  Modelica.Blocks.Continuous.Der der1
    annotation (Placement(transformation(extent={{-114,-68},{-90,-44}})));
  Modelica.Blocks.Math.Gain QSen(k=1e6) "Sensible heat flow rate"
    annotation (Placement(transformation(extent={{-40,-16},{-20,4}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow preHea(Q_flow=QRooInt_flow*10)
                      "Prescribed heat flow"
    annotation (Placement(transformation(extent={{18,70},{38,90}})));

protected
    Buildings.BoundaryConditions.WeatherData.Bus
                                     weaBus
    annotation (Placement(transformation(extent={{-128,30},{-108,50}})));
public
  Modelica.Blocks.Interfaces.RealOutput __zc_z1 "Zero crossing variable"
    annotation (Placement(transformation(extent={{100,-50},{120,-30}})));
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z1
    "Derivative of zero crossing variable"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
public
  Modelica.Blocks.Interfaces.RealOutput TRooK "Room temperature"
    annotation (Placement(transformation(extent={{100,-30},{120,-10}})));
equation
  connect(TOut.port, theCon.port_a)
    annotation (Line(points={{-60,40},{-42,40},{-22,40}},
                                                      color={191,0,0}));
  connect(theCon.port_b, vol.heatPort)
    annotation (Line(points={{-2,40},{-2,40},{70,40}}, color={191,0,0}));
  connect(TOut.T, weaBus.TDryBul) annotation (Line(points={{-82,40},{-82,40},{-118,40}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(weaDat.weaBus, weaBus) annotation (Line(
      points={{-140,40},{-140,40},{-118,40}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(TRooSetPoi.y, conQSS.reference)
    annotation (Line(points={{-139,0},{-139,0},{-80,0}}, color={0,0,127}));
  connect(senTemRoo.T, conQSS.u) annotation (Line(points={{-134,-36},{-96,-36},{
          -96,-6},{-80,-6}}, color={0,0,127}));
  connect(senTemRoo.port, vol.heatPort) annotation (Line(points={{-154,-36},{-160,-36},
          {-160,-80},{20,-80},{20,40},{70,40}},color={191,0,0}));
  connect(prescribedHeatFlow.port, vol.heatPort)
    annotation (Line(points={{54,-6},{60,-6},{60,40},{70,40}}, color={191,0,0}));
  connect(der1.u, conQSS.u) annotation (Line(points={{-116.4,-56},{-120,-56},{-120,
          -36},{-120,-6},{-80,-6}}, color={0,0,127}));
  connect(der1.y, conQSS.der_u) annotation (Line(points={{-88.8,-56},{-88.8,-56},
          {-84,-56},{-84,-12},{-80,-12}}, color={0,0,127}));
  connect(QSen.y, prescribedHeatFlow.Q_flow)
    annotation (Line(points={{-19,-6},{7.5,-6},{34,-6}}, color={0,0,127}));
  connect(QSen.u, conQSS.y)
    annotation (Line(points={{-42,-6},{-57,-6}}, color={0,0,127}));
  connect(preHea.port, vol.heatPort) annotation (Line(points={{38,80},{60,80},{60,76},
          {60,40},{70,40}}, color={191,0,0}));
  connect(conQSS._zc_z1, __zc_z1) annotation (Line(points={{-57,-2},{-48,-2},{-48,
          -40},{110,-40}}, color={0,0,127}));
  connect(conQSS._zc_der_z1, __zc_der_z1) annotation (Line(points={{-57,-10},{-54,
          -10},{-54,-60},{110,-60}}, color={0,0,127}));
  connect(TRooK, senTemRoo.T) annotation (Line(points={{110,-20},{-20,-20},{-20,
          -36},{-134,-36}}, color={0,0,127}));
  annotation (experiment(Tolerance=1e-6, StopTime=691200), Icon(coordinateSystem(preserveAspectRatio=false, extent={{-160,
            -100},{100,100}})),                                  Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-160,-100},{100,100}})),
    uses(Modelica(version="3.2.2"), Buildings(version="5.0.0")));
end System5;
