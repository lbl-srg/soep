within QSS.Generic;
model ExponentialDecay
  "This model simulates the exponential decay"
extends Modelica.Icons.Example;
Real x(start=1.0, fixed=true) "State variable";
equation
der(x) = -x;
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
</html>",
        info="<html>
<p>
This model simulates the exponential decay.
</p>
</html>"));
end ExponentialDecay;
