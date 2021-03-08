within BuildingRooms;
function exchange
  input ZoneClass adapter "External object";
  input Modelica.SIunits.Time t;
  input Modelica.SIunits.Temperature T;
  output Modelica.SIunits.Time tNext;
  output Modelica.SIunits.HeatFlowRate Q_flow;
  external "C" ZoneExchange(adapter, t, T, tNext, Q_flow)
  annotation (Include="#include <thermalZone.c>",
              IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
end exchange;
