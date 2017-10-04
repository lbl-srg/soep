within QSS.Docs;
model StateEvent3 "This model tests state event detection"
  extends Modelica.Icons.Example;
  Real x1(start=0.0, fixed=true) "State variable";
  Real x2(start=0.0, fixed=true) "State variable";
equation
  der(x1) = 1;
  der(x2) = x1;
when time > 0.5 then
  reinit(x1, 0);
end when;
  annotation (experiment(StopTime=1), Documentation(info="<html>
<p>
This model has 1 state event at t=0.5s
when simulated from 0 to 1s.
</p>
</html>"));
end StateEvent3;
