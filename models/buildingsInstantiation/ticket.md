Ambiguity in when

The specification (https://specification.modelica.org/master/functions.html#external-function-interface) says

> The constructor function is called exactly once before the first use of the object. ... The constructor shall initialize the object, and must not require any other calls to be made for the initialization to be complete (e.g., from an initial algorithm or initial equation). ...
```

This does not prescribe whether all constructors in a model need to be called before
statements in the `initial equation` or `initial algorithm` are processed.

I have a model that only works if the following is true:
If there are `n` instances, then a tool must call all `n` constructors
before any one of the constructed instance derived from ExternalObject is
used in a function in the `initial equation` section.

It turns out that this is what OpenModelica, Dymola 2021 and OPTIMICA are doing,
*except* if the constructor has an argument that is a `parameter` whose value
is assigned in the `initial equation` section
(of which I am not sure whether it is legal because of "...must not require any other calls to be made for the initialization to be complete...").

The Modelica code is as follows:
```modelica
within ;
package BuildingRooms

  model ThermalZone
    constant String name=getInstanceName();
    ZoneClass adapter = ZoneClass(name);
    //--ZoneClass adapter = ZoneClass(name, startTime);

    parameter Modelica.SIunits.Time startTime(
      fixed=false)
      "Simulation start time";
    parameter Integer nZ(fixed=false) "Total number of zones in Building";
    constant Real k=1;
    Modelica.SIunits.Time tNext(start=startTime, fixed=true) "Next sampling time";
    Modelica.SIunits.Temperature T(start=293.15, fixed=true);
    Modelica.SIunits.HeatFlowRate Q_flow;

  initial equation
    startTime=time;
    nZ=zoneInitialize(adapter=adapter, startTime=time);
  equation
    when {initial(), time >= pre(tNext)} then
      (tNext, Q_flow) = zoneExchange(adapter, time, T);
    end when;
    k*der(T) = Q_flow;
  end ThermalZone;
  ///////////////////////////////////////////////////////////////////
  class ZoneClass
  "Class used to couple the FMU to interact with a thermal zone"
  extends ExternalObject;
  function constructor
    input String name "Name of the zone";
   //-- input Modelica.SIunits.Time startTime "THIS WILL LEAD TO THE WRONG EXECUTION";
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
  ///////////////////////////////////////////////////////////////////
  function zoneInitialize
    input ZoneClass adapter
      "External object";
    input Modelica.SIunits.Time startTime "Start time of the simulation";
    output Integer nZ "Number of zones in building (obtained from common FMU)";
    external "C" ZoneInitialize(adapter, startTime, nZ)
    annotation (Include="#include <thermalZone.c>",
                IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
  end zoneInitialize;
  ///////////////////////////////////////////////////////////////////
  function zoneExchange
    input ZoneClass adapter
      "External object";
    input Modelica.SIunits.Time t;
    input Modelica.SIunits.Temperature T;
    output Modelica.SIunits.Time tNext;
    output Modelica.SIunits.HeatFlowRate Q_flow;
    external "C" ZoneExchange(adapter, t, T, tNext, Q_flow)
    annotation (Include="#include <thermalZone.c>",
                IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
  end zoneExchange;

  model Building
    ThermalZone t1;
    ThermalZone t2;
  end Building;
end BuildingRooms;
```

The C code is
```C
#ifndef thermalZone_c
#define thermalZone_c

#include <string.h>

#include "thermalZone.h"

static int nZon = 0;     /* Number of zones in building */

void* ZoneAllocate(const char* name){
  Zone* ptrZone;

   /* Allocate zone and assign name */
  ptrZone = (Zone*) malloc(sizeof(Zone));
  ptrZone->name = malloc((strlen(name)+1) * sizeof(char));
  strcpy(ptrZone->name, name);
  nZon++;

  ModelicaFormatMessage("Allocated zone %s\n", name);
  return (void*) ptrZone;
}

void ZoneInitialize(void* object, double startTime, int* nZ){
    Zone* zone = (Zone*) object;
    *nZ = nZon;
    ModelicaFormatMessage("Initialized zone %s, nZon = %d\n", zone->name, nZon);
}

void ZoneExchange(void* object, double time, double T, double* tNext, double* Q_flow){
    Zone* zone = (Zone*) object;
    *Q_flow = 283.15-T;
    *tNext = time + 1;
    ModelicaFormatMessage("Exchanged with zone %s at time=%f, nZon = %d\n", zone->name, time, nZon);
}

void ZoneFree(void* object){
    Zone* zone = (Zone*) object;
    ModelicaFormatMessage("Freeing memory for %s\n", zone->name);
}

#endif
```
and
```
C
#ifndef thermalZone_h
#define thermalZone_h

typedef struct Zone
{
  char* name;
} Zone;

#endif
```

(The complete files with C code is uploaded in the zip file.)

I made two tests, one with the code above, and one with
```modelica
...
    //-- ZoneClass adapter = ZoneClass(name);
    ZoneClass adapter = ZoneClass(name, startTime);
...
  function constructor
    input String name "Name of the zone";
    input Modelica.SIunits.Time startTime "THIS WILL LEAD TO THE WRONG EXECUTION";
    output ZoneClass adapter;
...

```
The results of the three tools is below. If `startTime` is *not* an argument
in the constructor, then all tools call both constructors as expected
before calling any other function.
If `startTime` is used as a constructor, then all three tools call
another function before calling the 2nd constructor.

My expected behavior are the runs that contain `nZon = 2` in
```
Initialized zone BuildingRooms.Building.t1, nZon = 2
Initialized zone BuildingRooms.Building.t2, nZon = 2
```

Here is the result of the three tools:


Optimica produces
```
Allocated zone Building.t1
Allocated zone Building.t2
Exchanged with zone Building.t1 at time=0.000000, nZon = 2
Exchanged with zone Building.t2 at time=0.000000, nZon = 2
Initialized zone Building.t1, nZon = 2
Initialized zone Building.t2, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
Freeing memory for Building.t1
Freeing memory for Building.t2
```

and if `startTime` is an argument of the constructor:
```
Allocated zone Building.t1
Exchanged with zone Building.t1 at time=0.000000, nZon = 1
Allocated zone Building.t2
Exchanged with zone Building.t2 at time=0.000000, nZon = 2
Initialized zone Building.t1, nZon = 2
Initialized zone Building.t2, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
Freeing memory for Building.t1
Freeing memory for Building.t2
```

Dymola produces
```
Allocated zone Building.t1
Allocated zone Building.t2
Initialized zone Building.t1, nZon = 2
Initialized zone Building.t2, nZon = 2
Exchanged with zone Building.t1 at time=0.000000, nZon = 2
Exchanged with zone Building.t2 at time=0.000000, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
Freeing memory for Building.t2
Freeing memory for Building.t1
```
and if `startTime` is an argument of the constructor:
```
Allocated zone Building.t1
Initialized zone Building.t1, nZon = 1
Allocated zone Building.t2
Initialized zone Building.t2, nZon = 2
Exchanged with zone Building.t1 at time=0.000000, nZon = 2
Exchanged with zone Building.t2 at time=0.000000, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
Freeing memory for Building.t2
Freeing memory for Building.t1
```

OMEdit produces

```
Allocated zone BuildingRooms.Building.t1
Allocated zone BuildingRooms.Building.t2
Exchanged with zone BuildingRooms.Building.t1 at time=0.000000, nZon = 2
Exchanged with zone BuildingRooms.Building.t2 at time=0.000000, nZon = 2
Initialized zone BuildingRooms.Building.t2, nZon = 2
Initialized zone BuildingRooms.Building.t1, nZon = 2
Freeing memory for BuildingRooms.Building.t1
Freeing memory for BuildingRooms.Building.t2

```

and if `startTime` is an argument of the constructor:
```
Allocated zone BuildingRooms.Building.t1
Initialized zone BuildingRooms.Building.t1, nZon = 1
Exchanged with zone BuildingRooms.Building.t1 at time=0.000000, nZon = 1
Allocated zone BuildingRooms.Building.t2
Initialized zone BuildingRooms.Building.t2, nZon = 2
Exchanged with zone BuildingRooms.Building.t2 at time=0.000000, nZon = 2
Freeing memory for BuildingRooms.Building.t1
Freeing memory for BuildingRooms.Building.t2
```


In my actual implementation (at https://github.com/lbl-srg/modelica-buildings/tree/master/Buildings/ThermalZones/EnergyPlus)
it would be impractical to work-around this, or requesting the user
to specify how many instances of `ThermalZone` there are as there can be hundreds,
and their ports need to be connected graphically for the model to be of use to most users.



My suggestion is therefore to rephrase
> The constructor function is called exactly once before the first use of the object

to
> The constructor function is called exactly once before any other instance of an `ExternalObject` is
  used in any function call.