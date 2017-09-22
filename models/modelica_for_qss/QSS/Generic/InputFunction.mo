within QSS.Generic;
model InputFunction "This model simulates a first order ODE with an input"
  extends Modelica.Icons.Example;
  Real x(start=0, fixed=true) "State variable";
  input Real u(start=1.0, fixed=true) "Input variable";
equation
  der(x) = u;
  annotation (
    experiment(StopTime=10),
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
July 26, 2017, by Thierry S. Nouidui:<br/>
Implemented first version.
</li>
</ul>
</html>", info="<html>
<p>
This model simulates a first order ODE with an input.
</p>
</html>"));
end InputFunction;
