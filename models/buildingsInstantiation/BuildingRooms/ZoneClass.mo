within BuildingRooms;
class ZoneClass
  extends ExternalObject;

  function constructor
    input String name "Name of the zone";
    input Modelica.SIunits.Time startTime;
    output ZoneClass adapter;
  external "C" adapter=ZoneAllocate(name)
    annotation (Include="#include <thermalZone.c>",
                IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
  end constructor;

  function destructor
    input ZoneClass adapter;
  external "C" ZoneFree(adapter)
    annotation (Include="#include <thermalZone.c>",
                IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
  end destructor;

end ZoneClass;
