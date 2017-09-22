within QSS.Specific.Events;
model StateEvent3
  "This model tests state event detection"
  extends Modelica.Icons.Example;
  Real x1(start=1.0, fixed=true);
  Real x2(start=-2.5, fixed=true);
  discrete Modelica.Blocks.Interfaces.RealOutput y(start=1.0, fixed=true);
  Modelica.Blocks.Interfaces.RealOutput __zc_z
    "Zero crossing";
  Modelica.Blocks.Interfaces.RealOutput __zc_der_z
    "Derivative of Zero crossing";
equation
  der(x1) = cos(2*3.14*time/2.5);
  der(x2) = 1;
  __zc_z = x1 - 1;
  __zc_der_z = der(x1 - 1);
  when (x1 > 1) then
    y = 1;
  elsewhen (x1 <= 1) then
    y = -1;
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
The model is similar to StateEvent2
with the only difference that the start
value of x1 is 1.0 instead of 1.1.
This allows to test case where the zero
crossing has a zero derivative at start time. 
</p>
<p>
This model has 8 state events at 
t = 0.0, 1.25087s, 2.50071, 3.75188s, 
5.00069, 6.25444, 7.50286, 8.75344
when simulated from 0 to 10s.
At state event times,
the output y switches from 
1 to -1.
</p>
</html>"));
end StateEvent3;
