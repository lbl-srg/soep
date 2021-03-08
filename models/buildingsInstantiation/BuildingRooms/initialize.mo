within BuildingRooms;
function initialize
  input ZoneClass adapter;
  input Real startTime;
  input Real isSynchronized;
  output Integer nZ "Number of zones";
  external "C" ZoneInitialize(adapter, startTime, nZ)
  annotation (
    Include="#include <thermalZone.c>",
    IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
end initialize;
