within QSS.Generic;
model Achilles
  "This model simulates Achilles and the tortoise"
  extends Modelica.Icons.Example;
  Real x1(start=0, fixed=true) "State variable";
  Real x2(start=2.0, fixed=true) "State variable";
equation
  der(x1) = -0.5*x1 + 1.5*x2;
  der(x2) = -x1;
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
This model simulates Achilles and the Tortoise.
</p>
</html>"));
end Achilles;
