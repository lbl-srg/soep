within QSS.Specific.Events;
model StateEventWithIf2
 "This model tests state event detection"
  extends Modelica.Icons.Example;
  Real x1(start=1, fixed=true);
  Real x2(start=-2.5, fixed=true);
  Modelica.Blocks.Interfaces.RealOutput y;
  Modelica.Blocks.Interfaces.RealOutput y1;
  Modelica.Blocks.Interfaces.RealOutput __zc_z
    "Zero crossing";
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z
    "Derivative of Zero crossing";
equation
  der(x1) = -1;
  der(x2) = 1;
  __zc_z = x1 - x2;
  __zc_der_z = der(x1 - x2);
  if ((x1 > x2)) then
    y = 1;
  else
    y = -1;
  end if;

  if (time > 1) then
    y1 = 10;
  else
    y1 = 3;
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
This model has 2 state events at t=1.0s, and
1.75s when simulated from 0 to 10s.
At state event times, the output y, y1 switch
from 1 to -1, and 3 to 10 respectively.
</p>
<p>
This model requires to modify the XML, and add
the dependency of y on the zero crossing function __zc_z.
</p>
</html>"));
end StateEventWithIf2;
