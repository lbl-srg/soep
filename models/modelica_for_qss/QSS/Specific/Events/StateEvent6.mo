within QSS.Specific.Events;
model StateEvent6 "This model tests state event detection"
  extends Modelica.Icons.Example;
  Real x(start=0.0, fixed=true);
  discrete Modelica.Blocks.Interfaces.RealOutput y(start=1.0, fixed=true);
  Modelica.Blocks.Interfaces.RealOutput __zc_z
    "Zero crossing";
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z
    "Derivative of Zero crossing";
equation
  der(x) = y;
  __zc_z = time - 1;
  __zc_der_z = der(time - 1);
  when (time > 5) then
    y = 0;
  end when;
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
This model has 1 state event at t=5s
when simulated from 0 to 10s.
At state event times,the output y switches 
from 1 to 0.
</p>
<p>
This model requires to modify the XML, and add
the dependency of y on the zero crossing function __zc_z
as well as the dependency of der(x) on y.
</p>
</html>"));
end StateEvent6;
