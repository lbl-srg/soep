within QSS.Docs;
model StateEvent1 "This model tests state event detection"
  extends Modelica.Icons.Example;
  Real x1(start=0.0, fixed=true) "State variable";
  Real x2(start=0.5, fixed=true) "State variable";
  discrete Modelica.Blocks.Interfaces.RealOutput y(start=1.0, fixed=true)
    "Ouput variable";
equation
  der(x1) = y + 1;
  der(x2) = x2;
  when (x1 > 0.5 and x2 > 1.0) then
    y = -1.0;
  end when;
  annotation (experiment(StopTime=1), Documentation(info="<html>
<p>
This model has 2 state event at t=0.25s
and t=0.6924 when simulated from 0 to 1s.
</p>
</html>"));
end StateEvent1;
