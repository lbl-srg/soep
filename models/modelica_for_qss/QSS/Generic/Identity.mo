within QSS.Generic;
model Identity "This model simulates the identity function"
  extends Modelica.Icons.Example;
  Real x(start=0, fixed=true) "State variable";
equation
  der(x) = 1;
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
This model simulates the identity function.
</p>
</html>"));
end Identity;
