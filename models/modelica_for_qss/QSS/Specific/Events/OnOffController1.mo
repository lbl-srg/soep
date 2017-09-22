within QSS.Specific.Events;
model OnOffController1
  extends Modelica.Icons.Example;
  replaceable package MediumA = Buildings.Media.Air "Medium for air";
  BaseClasses.OnOffControllerQSS1 conQSS(bandwidth=1)
    "Controller for sensible heat flow rate"
    annotation (Placement(transformation(extent={{-72,4},{-52,24}})));
  Modelica.Thermal.HeatTransfer.Sensors.TemperatureSensor senTemRoo
    "Room temperature sensor"
    annotation (Placement(transformation(extent={{-154,-30},{-134,-10}})));
  Modelica.Blocks.Sources.Constant TRooSetPoi(k=20 + 273.15)
    "Room temperature set point"
    annotation (Placement(transformation(extent={{-160,10},{-140,30}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature TOut
    "Outside temperature"
    annotation (Placement(transformation(extent={{-80,50},{-60,70}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor theCon(G=1000)
    "Thermal conductance with the ambient"
    annotation (Placement(transformation(extent={{-20,50},{0,70}})));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor vol(C=10000, T(start=293.15, fixed=true))
    annotation (Placement(transformation(extent={{46,62},{74,90}})));
  parameter Modelica.SIunits.Volume V=6*10*3 "Room volume";
  //////////////////////////////////////////////////////////
  // Heat recovery effectiveness
  parameter Real eps=0.8 "Heat recovery effectiveness";

  /////////////////////////////////////////////////////////
  // Air temperatures at design conditions
  parameter Modelica.SIunits.Temperature TASup_nominal=273.15 + 18
    "Nominal air temperature supplied to room";
  parameter Modelica.SIunits.Temperature TRooSet=273.15 + 24
    "Nominal room air temperature";
  parameter Modelica.SIunits.Temperature TOut_nominal=273.15 + 30
    "Design outlet air temperature";
  parameter Modelica.SIunits.Temperature THeaRecLvg=TOut_nominal - eps*(
      TOut_nominal - TRooSet) "Air temperature leaving the heat recovery";

  /////////////////////////////////////////////////////////
  // Cooling loads and air mass flow rates
  parameter Modelica.SIunits.HeatFlowRate QRooInt_flow=1000
    "Internal heat gains of the room";
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow preHea2
    annotation (Placement(transformation(extent={{0,-10},{20,10}})));
  Modelica.Blocks.Continuous.Der der1
    annotation (Placement(transformation(extent={{-114,-52},{-90,-28}})));
  Modelica.Blocks.Math.Gain QSen(k=1e6) "Sensible heat flow rate"
    annotation (Placement(transformation(extent={{-28,-10},{-8,10}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow preHea1(Q_flow=1000)
    "Prescribed heat flow"
    annotation (Placement(transformation(extent={{-22,70},{-2,90}})));

  Modelica.Blocks.Interfaces.RealOutput __zc_z2 "Zero crossing variable"
    annotation (Placement(transformation(extent={{100,-50},{120,-30}})));
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z2
    "Derivative of zero crossing variable"
    annotation (Placement(transformation(extent={{100,-90},{120,-70}})));

  Modelica.Blocks.Interfaces.RealOutput TRooK "Room temperature"
    annotation (Placement(transformation(extent={{100,-30},{120,-10}})));
  Modelica.Blocks.Sources.Constant TRooSetPoi1(k=5 + 273.15)
    "Room temperature set point"
    annotation (Placement(transformation(extent={{-160,50},{-140,70}})));
  Modelica.Blocks.Interfaces.RealOutput __zc_z1 "Zero crossing variable"
    annotation (Placement(transformation(extent={{100,30},{120,50}})));
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z1
    "Derivative of zero crossing variable"
    annotation (Placement(transformation(extent={{100,10},{120,30}})));
  Modelica.Blocks.Interfaces.BooleanOutput pre_yBoo "Boolean for zero crossing"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
equation
  connect(TOut.port, theCon.port_a)
    annotation (Line(points={{-60,60},{-20,60}}, color={191,0,0}));
  connect(TRooSetPoi.y, conQSS.reference)
    annotation (Line(points={{-139,20},{-74,20}},        color={0,0,127}));
  connect(senTemRoo.T, conQSS.u) annotation (Line(points={{-134,-20},{-96,-20},{
          -96,14},{-74,14}}, color={0,0,127}));
  connect(der1.u, conQSS.u) annotation (Line(points={{-116.4,-40},{-120,-40},{-120,
          14},{-74,14}},            color={0,0,127}));
  connect(der1.y, conQSS.der_u) annotation (Line(points={{-88.8,-40},{-82,-40},{
          -82,8},{-74,8}},                color={0,0,127}));
  connect(QSen.y, preHea2.Q_flow)
    annotation (Line(points={{-7,0},{0,0}},    color={0,0,127}));
  connect(QSen.u, conQSS.y)
    annotation (Line(points={{-30,0},{-42,0},{-42,14},{-51,14}},
                                                 color={0,0,127}));
  connect(conQSS._zc_der_z2, __zc_der_z2) annotation (Line(points={{-51,8},{-50,
          8},{-50,-80},{110,-80}},   color={0,0,127}));
  connect(TRooK, senTemRoo.T) annotation (Line(points={{110,-20},{-134,-20}},
                            color={0,0,127}));
  connect(preHea2.port, vol.port)
    annotation (Line(points={{20,0},{60,0},{60,62}},   color={191,0,0}));
  connect(preHea1.port, vol.port) annotation (Line(points={{-2,80},{40,80},{40,62},
          {60,62}},     color={191,0,0}));
  connect(senTemRoo.port, vol.port) annotation (Line(points={{-154,-20},{-154,-60},
          {60,-60},{60,62}}, color={191,0,0}));
  connect(TRooSetPoi1.y, TOut.T)
    annotation (Line(points={{-139,60},{-82,60}},           color={0,0,127}));
  connect(conQSS._zc_z1, __zc_z1) annotation (Line(points={{-51,18},{-48,18},{-48,
          40},{110,40}}, color={0,0,127}));
  connect(conQSS._zc_z2, __zc_z2) annotation (Line(points={{-51,16},{-46,16},{-46,
          -40},{110,-40}}, color={0,0,127}));
  connect(conQSS._zc_der_z1, __zc_der_z1) annotation (Line(points={{-51,10.2},{-44,
          10.2},{-44,20},{110,20}}, color={0,0,127}));
  connect(theCon.port_b, vol.port) annotation (Line(points={{0,60},{32,60},{32,62},
          {60,62}}, color={191,0,0}));
  connect(conQSS.pre_yBoo, pre_yBoo) annotation (Line(points={{-51,6},{-36,6},{
          -36,-60},{110,-60}}, color={255,0,255}));
  annotation (
    experiment(Tolerance=1e-6, StopTime=2),
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-160,-100},{100,100}})),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-160,-100},{100,
            100}})),
    Documentation(info="<html>
<p>
This model simulates an on/off controller which 
controls the room temperature of a simple room
modeled using a capacitor.
</p>
<p>
If simulated from 0 to 2s, 
then the model generates 5 state events
at t=0.00507228, 0.719569, 0.729711, 1.44419, 1.45433.
</p>
<p>
This model requires to modify the XML, and add
the dependency of conQSS.y on the zero crossing function __zc_z1
and __zc_z2 as well as the dependency of der(vol.T) on conQSS.y.
A different approach is to extend the dependency of der(vol.T) on
__zc_z1 and __zc_z2.
</p>

</html>"));
end OnOffController1;
