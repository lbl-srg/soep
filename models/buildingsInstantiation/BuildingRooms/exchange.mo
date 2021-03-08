within BuildingRooms;
function exchange
  input ZoneClass adapter;
  input Real t;
  input Real T;
  input Integer nZ;
  output Real tNext;
  output Real Q_flow;
  external "C" ZoneExchange(adapter, t, T, tNext, Q_flow)
  annotation (Include="#include <thermalZone.c>",
              IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
end exchange;
