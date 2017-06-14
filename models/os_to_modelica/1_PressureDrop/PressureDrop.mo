within ;
model PressureDrop
  "Example model for flow resistance with nominal pressure drop as parameter"
  extends Modelica.Icons.Example;

 package Medium = Buildings.Media.Air "Medium model";

  Buildings.Fluid.Sources.Boundary_pT sou(
    redeclare package Medium = Medium,
    T=273.15 + 20,
    nPorts=1)
    "Pressure boundary condition"
    annotation (Placement(transformation(extent={{-50,-10},{-30,10}})));

  Buildings.Fluid.Sources.Boundary_pT sin(
    redeclare package Medium = Medium,
    T=273.15 + 10,
    nPorts=1,
    p = 101325)
    "Pressure boundary condition"
    annotation (Placement(transformation(extent={{50,-10},{30,10}})));

  Buildings.Fluid.FixedResistances.PressureDrop res(
    redeclare package Medium = Medium,
    m_flow_nominal=0.2,
    dp_nominal=10)
    "Fixed resistance"
    annotation (Placement(transformation(extent={{-8,-10},{12,10}})));

equation
  connect(sou.ports[1], res.port_a)
    annotation (Line(points={{-30,0},{-8,0}}, color={0,127,255}));
  connect(res.port_b, sin.ports[1])
    annotation (Line(points={{12,0},{12,0},{30,0}}, color={0,127,255}));
  annotation (experiment(Tolerance=1e-6, StopTime=1.0),
  Documentation(info="<html>
<p>
Add any documentation here that you think would be useful to dump into the model,
or remove the <code>info</code> section.
</p>
</html>", revisions="<html>
<ul>
<li>
Here we could add revisions, or when the model was exported from OpenStudio.
</li>
</ul>
</html>"),
    uses(Modelica(version="3.2.2"), Buildings(version="4.0.0")));
end PressureDrop;
