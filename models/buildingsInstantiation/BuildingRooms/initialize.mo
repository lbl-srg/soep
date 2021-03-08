within BuildingRooms;
function initialize
  input ZoneClass adapter "External object";
  input Modelica.SIunits.Time startTime "Start time of the simulation";
  input Real isSynchronized;
  output Integer nZ "Number of zones";
  external "C" ZoneInitialize(adapter, startTime, nZ)
  annotation (Include="#include <thermalZone.c>",
              IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
end initialize;
