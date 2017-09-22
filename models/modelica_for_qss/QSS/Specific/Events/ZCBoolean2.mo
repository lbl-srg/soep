within QSS.Specific.Events;
model ZCBoolean2
  "This model tests state event detection with boolean zero crossing"
  extends Modelica.Icons.Example;
  function booToRea "This function converts a Boolean to a Real"
    input Boolean u "Boolean input";
    output Real y "Real output";
  algorithm
    y := if u then 1.0 else 0.0;
  end booToRea;
  Real x(start=1, fixed=true);
  Real u "Internal input signal";
  Boolean yBoo "Boolean variable";
  Boolean yBooPre "Boolean variable for pre(yBoo)";
  discrete Modelica.Blocks.Interfaces.RealOutput y(start=1.0, fixed=true);
  Modelica.Blocks.Interfaces.RealOutput __zc_z1 "Zero crossing";
   Modelica.Blocks.Interfaces.RealOutput __zc_der_z1
     "Derivative of Zero crossing";
  Modelica.Blocks.Interfaces.RealOutput __zc_z2 "Zero crossing";
   Modelica.Blocks.Interfaces.RealOutput __zc_der_z2
     "Derivative of Zero crossing";
initial equation
  pre(yBoo) = true;
equation
  u = Modelica.Math.sin(time);
  der(x) = y;
  when (pre(yBoo) and u >= 0.5) then
    y = 1.0;
    yBoo = false;
  elsewhen (not pre(yBoo) and u <= -0.5) then
    y = -1.0;
    yBoo = true;
  end when;
  // Defining the boolean conditional
  // variable for the zero crossing variables
  yBooPre = pre(yBoo);
  // Defining zero crossing to be exported as output variables
  // First zero crossing function
   __zc_z1 = booToRea(yBooPre)*(u - 0.5);
   // Second zero crossing function
   __zc_z2 = booToRea(not yBooPre)*(u + 0.5);
   // Derivative of first zero crossing function
   __zc_der_z1 = booToRea(yBooPre) * der(u - 0.5);
   // Derivative of first zero crossing function
   __zc_der_z2 = booToRea(not yBooPre)* der(u + 0.5);
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
This model has 4 state events at 
t=0.5235s, 3.66519s, 6.80678s,  
9.94838s when simulated from 0 to 10s.
This model has a variable <code>yBooPre</pre>
which is used to multiply the zero crossing 
variables so they can be updated when the correct 
conditions are met.
</p>
</html>"));
end ZCBoolean2;
