within ;
model TestOnOffController
  extends Modelica.Icons.Example;

  OnOffControllerQSS conQSS(bandwidth=0.1)
    "Controller for sensible heat flow rate"
    annotation (Placement(transformation(extent={{18,-10},{38,10}})));
  Modelica.Blocks.Sources.Constant TRooSetPoi(k=20 + 273.15)
    "Room temperature set point"
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
  Modelica.Blocks.Sources.Sine sine(freqHz=1, amplitude=315.15)
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  Modelica.Blocks.Sources.Sine sine1(freqHz=1, amplitude=315.15)
    annotation (Placement(transformation(extent={{-80,-60},{-60,-40}})));
  Modelica.Blocks.Continuous.Der der1
    annotation (Placement(transformation(extent={{-40,-60},{-20,-40}})));
equation
  connect(TRooSetPoi.y, conQSS.reference) annotation (Line(points={{-59,40},{-20,
          40},{-20,6},{16,6}}, color={0,0,127}));
  connect(sine.y, conQSS.u)
    annotation (Line(points={{-59,0},{-59,0},{16,0}}, color={0,0,127}));
  connect(der1.y, conQSS.der_u) annotation (Line(points={{-19,-50},{-14,-50},{-14,
          -6},{16,-6}}, color={0,0,127}));
  connect(der1.u, sine1.y)
    annotation (Line(points={{-42,-50},{-48,-50},{-59,-50}}, color={0,0,127}));
  annotation (experiment(Tolerance=1e-6, StopTime=10),
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    uses(Modelica(version="3.2.2")));
end TestOnOffController;
