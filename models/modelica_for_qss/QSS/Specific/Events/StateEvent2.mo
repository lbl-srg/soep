within QSS.Specific.Events;
model StateEvent2
  "This model tests state event detection"
  extends Modelica.Icons.Example;
  Real x1(start=1.1, fixed=true);
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
This model has 8 state events 
at t=1.35186s, 2.39967s, 3.85206s, 4.90201s, 
6.35128s, 7.40546s, 8.85154s, 9.90757s
when simulated from 0 to 10s.
At state event times,
the output y switches from 
1 to -1.
</p>
</html>"));
end StateEvent2;
