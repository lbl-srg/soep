within QSS.Docs;
model TimeEvent "This model tests time event detection"
  extends Modelica.Icons.Example;
  Real x1(start=0.0, fixed=true)
                                "State variable";
  Real x2(start=0.0, fixed=true) "State variable";
  discrete Modelica.Blocks.Interfaces.RealOutput y(start=1.0, fixed=true)
    "Output variable";
equation
  der(x1) = y + 1;
  der(x2) = -x2;
  when (time >= 0.5) then
    y = x2;
  end when;
  annotation (experiment(StopTime=1), Documentation(info="<html>
<p>
This model has 1 time event at t=0.5s
when simulated from 0 to 1s.
</p>
</html>"));
end TimeEvent;
