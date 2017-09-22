within QSS.Generic;
model CoupledSystem "This model simulates a coupled system of ODEs"
  extends Modelica.Icons.Example;
  Real x1(start=10, fixed=true) "State variable";
  Real x2(start=10, fixed=true) "State variable";
  Real x3(start=10, fixed=true) "State variable";
equation
  der(x1) = -x1;
  der(x2) = -2*x1;
  der(x3) = -2*(2*x2 + x3);
  annotation (
    experiment(StopTime=0.1),
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
This model simulates a coupled system of ODEs.
</p>
<p>
Running this model with QSS1 
with a quantum of 1 and 
a simulation stopTime of 0.1 
must lead to 
<ul>
<li>
x1 will transition to 9 at t=0.1 
</li>
<li>
x2 will transition to 9 at t=0.05
</li>
<li>
x2 will transition to 8 at t=0.1
</li>
<li>
x3 will transition to 9 at t=0.0167
</li>
<li>
x3 will transition to 8 at t=0.0339
</li>
<li>
x3 will transition to 7 at t=0.0519
</li>
<li>
x3 will transition to 6 at t=0.0719
</li>
<li>
x3 will transition to 5 at t=0.0927
</li>
</ul>

</p>
</html>"));
end CoupledSystem;
