within ;
package SOEP_QSS
  "This is a package with models 
  for testing the standalone QSS solvers"
  model ConstantSlope "Model with constant slope"
    parameter Real slope = 1 "slope";
    Real x(start=0.0) "state variable";
    Modelica.Blocks.Interfaces.RealOutput y "output";
  equation
    der(x) = slope;
    y = x;
    annotation (Documentation(info="<html>
Model with constant slope. This model
has one state variable and one output
which is equal to the state variable.
</html>"));
  end ConstantSlope;

  model ExponentialDecay "Model of the exponential decay curve"
    parameter Real x0 = 1.0 "State start value";
    Real x(start=x0) "state variable";
    Modelica.Blocks.Interfaces.RealOutput y "output";
  equation
    der(x) = -x;
    y = x;
    annotation (Documentation(info="<html>
Model of exponential decay curve. This model
has one state variable and one output
which is equal to the state variable.
</html>"));
  end ExponentialDecay;

end SOEP_QSS;
