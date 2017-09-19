within QSS.Specific.Events;
model ZCBoolean1
  "This model tests state event detection with boolean zero crossing"
  extends Modelica.Icons.Example;
  Real x(start=1, fixed=true);
  Real u "Internal input signal";
  Boolean yBoo "Boolean variable";
  discrete Modelica.Blocks.Interfaces.RealOutput y(start=1.0, fixed=true);
  Modelica.Blocks.Interfaces.RealOutput __zc_z1 "Zero crossing";
   Modelica.Blocks.Interfaces.RealOutput __zc_der_z1
     "Derivative of Zero crossing";
  Modelica.Blocks.Interfaces.RealOutput __zc_z2 "Zero crossing";
   Modelica.Blocks.Interfaces.RealOutput __zc_der_z2
     "Derivative of Zero crossing";
initial equation
  pre(yBoo) = true;
equation
  u = Modelica.Math.sin(time);
  der(x) = y;
  when (pre(yBoo) and u >= 0.5) then
    y = 1.0;
    yBoo = false;
  elsewhen (not pre(yBoo) and u <= -0.5) then
    y = -1.0;
    yBoo = true;
  end when;
  // Defining zero crossing to be exported as output variables
  // First zero crossing function
   __zc_z1 = u - 0.5;
   // Second zero crossing function
   __zc_z2 = u + 0.5;
   // Derivative of first zero crossing function
   __zc_der_z1 = der(u - 0.5);
   // Derivative of first zero crossing function
   __zc_der_z2 = der(u + 0.5);
  annotation (
    experiment(StopTime=10),
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
This model has 4 state events at  
t=0.5235s, 3.66519s, 6.80678s 
9.94838s when simulated from 0 to 10s.
</p>
</html>"));
end ZCBoolean1;
