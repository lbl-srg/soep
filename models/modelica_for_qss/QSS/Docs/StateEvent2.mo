within QSS.Docs;
model StateEvent2 "This model tests state event detection"
  extends Modelica.Icons.Example;
  Real x(start=-0.5, fixed=true) "State variable";
  discrete Real y(start=1.0, fixed=true "Discrete variable");
  Modelica.Blocks.Interfaces.RealInput u "Input variable"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
equation
  der(x) = y;
  when (u > x) then
    y = -1.0;
  end when;
  annotation (experiment(StopTime=1), Documentation(info="<html>
<p>
This model has a state event
when u becomes bigger than x.
</p>
</html>"));
end StateEvent2;
