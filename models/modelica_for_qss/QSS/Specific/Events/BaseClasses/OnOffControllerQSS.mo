within QSS.Specific.Events.BaseClasses;
block OnOffControllerQSS "On-off controller"
  extends Modelica.Blocks.Icons.PartialBooleanBlock;
  Modelica.Blocks.Interfaces.RealInput reference
    "Connector of Real input signal used as reference signal"
    annotation (Placement(transformation(extent={{-140,80},{-100,40}})));
  Modelica.Blocks.Interfaces.RealInput u
    "Connector of Real input signal used as measurement signal"
    annotation (Placement(transformation(extent={{-140,20},{-100,-20}})));
  discrete Modelica.Blocks.Interfaces.RealOutput y(start=0.0, fixed=true)
    "Connector of Real output signal used as actuator signal"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));

  parameter Real bandwidth(start=0.1) "Bandwidth around reference signal";
  parameter Boolean pre_yBoo_start=false "Value of pre(y) at initial time";

  Modelica.Blocks.Interfaces.RealInput der_u
    "Connector of Real input derivative of signal used as measurement signal"
    annotation (Placement(transformation(extent={{-140,-40},{-100,-80}})));
    Boolean yBoo "Boolean output signal";
    Modelica.Blocks.Interfaces.RealOutput _zc_z2 "Zero crossing variable"
    annotation (Placement(transformation(extent={{100,10},{120,30}})));
  Modelica.Blocks.Interfaces.RealOutput _zc_der_z2
    "Derivative of zero crossing variable"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
    Modelica.Blocks.Interfaces.RealOutput _zc_z1 "Zero crossing variable"
    annotation (Placement(transformation(extent={{100,30},{120,50}})));
  Modelica.Blocks.Interfaces.RealOutput _zc_der_z1
    "Derivative of zero crossing variable"
    annotation (Placement(transformation(extent={{100,-48},{120,-28}})));
initial equation
  pre(yBoo) = pre_yBoo_start;
equation
  // Define zero crossing functions
  _zc_z1 = u - (reference + bandwidth/2);
  _zc_z2 = u - (reference - bandwidth/2);
  // Define the derivatives of the zero crossing functions
  _zc_der_z1 = der_u;
  _zc_der_z2 = der_u;
  when (not pre(yBoo)) and (u >= reference + bandwidth/2) then
    yBoo = true;
    y = 1.0;
  elsewhen pre(yBoo) and (u < reference - bandwidth/2) then
    yBoo = false;
    y = 0.0;
  end when;
  annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{100,
            100}}), graphics={
        Text(
          extent={{-92,74},{44,44}},
          lineThickness=0.5,
          textString="reference"),
        Text(extent={{-94,-48},{-34,-70}},
          textString="der_u",
          lineColor={0,0,0}),
        Line(points={{-76.0,-32.0},{-68.0,-6.0},{-50.0,26.0},{-24.0,40.0},{-2.0,42.0},
              {16.0,36.0},{32.0,28.0},{48.0,12.0},{58.0,-6.0},{68.0,-28.0}}, color={
              0,0,127}),
        Line(points={{-78.0,-2.0},{-6.0,18.0},{82.0,-12.0}}, color={255,0,0}),
        Line(points={{-78.0,12.0},{-6.0,30.0},{82.0,0.0}}),
        Line(points={{-78.0,-16.0},{-6.0,4.0},{82.0,-26.0}}),
        Line(points={{-82.0,-18.0},{-56.0,-18.0},{-56.0,-40.0},{64.0,-40.0},{64.0,-20.0},
              {90.0,-20.0}}, color={255,0,255}),
        Text(extent={{-108,16},{-48,-6}},  textString="u")}),
                                                   Documentation(info="<html>
<p>The block OnOffController sets the output signal <b>y</b> to <b>false</b> when
the input signal <b>u</b> falls below the <b>reference</b> signal minus half of
the bandwidth and sets the output signal <b>y</b> to <b>true</b> when the input
signal <b>u</b> exceeds the <b>reference</b> signal plus half of the bandwidth.</p>
</html>"));
end OnOffControllerQSS;
