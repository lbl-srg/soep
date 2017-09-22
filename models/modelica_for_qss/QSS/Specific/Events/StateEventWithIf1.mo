within QSS.Specific.Events;
model StateEventWithIf1
 "This model tests state event detection"
  extends Modelica.Icons.Example;
  Real x1(start=1.1, fixed=true);
  Real x2(start=-2.5, fixed=true);
  Real x3(start=4, fixed=true);
  Modelica.Blocks.Interfaces.RealOutput y;
  Modelica.Blocks.Interfaces.RealOutput __zc_z
    "Zero crossing";
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z
    "Derivative of Zero crossing";
equation
  der(x1) = cos(2*3.14*time/2.5);
  der(x2) = 1;
  der(x3) = y;
  __zc_z = x1 - 1;
  __zc_der_z = der(x1 - 1);
  if (x1 > 1) then
    y = 1;
  else
    y = 0;
  end if;
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
This model has 8 state events a t=1.35209s, 
2.39944s, 3.85248s, 4.90162s, 6.35112s, 
7.40536s, 8.85144s, 9.90760s when simulated from 0 to 10s.
At state event times, the output y switches 
from 1 to 0.
</p>
<p>
This model requires to modify the XML, and add
the dependency of y on the zero crossing function __zc_z
as well as the dependency of der(x3) on y.
</p>
</html>"));
end StateEventWithIf1;
