within QSS.Specific.Events;
model BouncingBall "This model simulates the bouncing ball"
  extends Modelica.Icons.Example;
  type Height = Real (unit="m");
  type Velocity = Real (unit="m/s");
  parameter Real e=0.8 "Coefficient of restitution";
  parameter Height h0=1.0 "Initial height";
  Height h;
  Velocity v(start=0.0, fixed=true);
  Modelica.Blocks.Interfaces.RealOutput __zc_z "Zero crossing function"
    annotation (Placement(transformation(extent={{100,10},{120,30}})));
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z
    "Derivative of zero crossing function"
    annotation (Placement(transformation(extent={{100,-30},{120,-10}})));
initial equation
  h = h0;
equation
  v = der(h);
  der(v) = -9.81;
  __zc_z = h;
  __zc_der_z = v;
  when h < 0 then
    reinit(v, -e*pre(v));
  end when;
  annotation (
    experiment(StopTime=3),
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
June 20, 2017, by Thierry S. Nouidui:<br/>
Implemented first version.
</li>
</ul>
</html>", info="<html>
<p>
This model simulates the bouncing ball. 
</p>
<p>
This model has 12 state events when simulated form 0 to 3s.
The state events are at t=0.4515236395553223, 0.4515236396127245,
1.173961461717483, 1.173961461790002, 1.751911718232403, 
1.751911718323203, 2.214271923191991, 2.214271923304014, 
2.584160083998069, 2.584160084137565, 2.880070609653692,
2.880070609827924.
</p>
<p>
This model requires to modify the XML file to include
the dependency of v on the zero crossing variable __zc_z.
</p>
</html>"));
end BouncingBall;
