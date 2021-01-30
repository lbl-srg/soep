Ambiguity in when constructors of ExternalObjects are called
------------------------------------------------------------

The specification (https://specification.modelica.org/master/functions.html#external-function-interface) says

> The constructor function is called exactly once before the first use of the object. ... The constructor shall initialize the object, and must not require any other calls to be made for the initialization to be complete (e.g., from an initial algorithm or initial equation). ...
```

This does not prescribe whether all constructors in a model need to be called before
statements in the `initial equation` or `initial algorithm` are processed,
unless a "call" also means a parameter assignment.

My suggestion is therefore to rephrase
> The constructor function is called exactly once before the first use of the object

to
> The constructor function is called exactly once before any other instance of an `ExternalObject` is
  used in any function call.

This should be easy to ensure by the sorting algorithm because the specification already says that constructors
"must not require any other calls to be made for the initialization to be complete".

Let me explain below the reason for this clarification that would ensure deterministic behavior across tools.
I have a model that only works if the following is true:
If there are `n` instances of constructors that use a `ExternalObject`,
then a tool must call all `n` constructors
before any one of the constructed instance is
used in a function in the `initial equation` section.

It turns out that this is what OpenModelica 1.16, Dymola 2021 and OPTIMICA r19089 are doing
if the constructor has no argument that is a `parameter`.
However, if the constructor has an argument that is a `parameter` whose value
is assigned in the `initial equation` section
(of which I am not sure whether it is legal because of "...must not require any other calls to be made for the initialization to be complete...")
then tools behave differently.

For my code, I am fine with the situation where the constructor has only arguments
that are `constant` rather than `parameter`.
Being able to set a parameter value as an argument in the constructor call
would be better, but is not required.
But I need to rely on the same behavior across tools,
which the language definition does not guarantee.


The Modelica code is as follows:
```modelica
within ;
package BuildingRooms

  model ThermalZone
    constant String name=getInstanceName();
    ZoneClass adapter = ZoneClass(name);
    //--ZoneClass adapter = ZoneClass(name, startTime) "THIS WILL LEAD TO WRONG RESULTS";

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
    extends ExternalObject;

    function constructor
      input String name "Name of the zone";
      //--input Modelica.SIunits.Time startTime "THIS WILL LEAD TO WRONG RESULTS";
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
    output Integer nZ "THIS VALUE IS NOT GUARANTEED TO BE CORRECT";
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

  model Building "Buildings with two thermal zones, e.g., nZ=2"
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
#include <stdbool.h>

#include "thermalZone.h"

static int nZon = 0;     /* Number of zones in building */
static bool buildingIsInstantiated = false;     /* Number of buildings that are initialized */

void* ZoneAllocate(const char* name){
  Zone* ptrZone;

   /* Allocate zone and assign name */
  ptrZone = (Zone*) malloc(sizeof(Zone));
  ptrZone->name = malloc((strlen(name)+1) * sizeof(char));
  strcpy(ptrZone->name, name);
  nZon++; /* Increment counter for number of zones */

  ModelicaFormatMessage("Allocated zone %s\n", name);
  return (void*) ptrZone;
}

void ZoneInitialize(void* object, double startTime, int* nZ){
    Zone* zone = (Zone*) object;
    *nZ = nZon;
    if (!buildingIsInstantiated){
        /* Here, the actual implementation constructs an FMU that is shared by all zones
           using a pointer to a C structure.
           This requires that all zones executed ZoneAllocate().
        */
        buildingIsInstantiated = true;
        ModelicaFormatMessage("Initialized zone %s. Instantiated building with %d zones.\n", zone->name, nZon);
    }
    else{
        ModelicaFormatMessage("Initialized zone %s, nZon = %d\n", zone->name, nZon);
    }
}

void ZoneExchange(void* object, double time, double T, double* tNext, double* Q_flow){
    Zone* zone = (Zone*) object;
    /* In the actual implementation, this is computed in an FMU that has models for all nZ zones
       which exchange heat among each other.
    */
    *Q_flow = 283.15-T;
    *tNext = time + 1;
    ModelicaFormatMessage("Exchanged with zone %s at time=%f, nZon = %d\n", zone->name, time, nZon);
}

void ZoneFree(void* object){
    Zone* zone = (Zone*) object;
}

#endif
```

and
```C
#ifndef thermalZone_h
#define thermalZone_h

typedef struct Zone
{
  char* name;
} Zone;

#endif
```

(The complete files with C code is uploaded in the zip file.)

I made two tests, one with the code above, and one with the change below to
enable a `parameter` as an argument of the constructor.
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

The expected behavior are the runs that contain
```
Instantiated building with 2 zones.
```
as in these, both constructors were called before any of the objects
is used in another function call.
If `Instantiated building with 1 zones.` the result will be wrong.

Here is the result of the three tools:


Optimica produces
```
Allocated zone Building.t1
Allocated zone Building.t2
Exchanged with zone Building.t1 at time=0.000000, nZon = 2
Exchanged with zone Building.t2 at time=0.000000, nZon = 2
Initialized zone Building.t1. Instantiated building with 2 zones.
Initialized zone Building.t2, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2

```

and if `startTime` is an argument of the constructor:
```
Allocated zone Building.t1
Exchanged with zone Building.t1 at time=0.000000, nZon = 1  // <- This can be handled (in my code)
Allocated zone Building.t2
Exchanged with zone Building.t2 at time=0.000000, nZon = 2  // <- This can be handled (in my code)
Initialized zone Building.t1. Instantiated building with 2 zones.
Initialized zone Building.t2, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2

```

Dymola produces
```
Allocated zone Building.t1
Allocated zone Building.t2
Initialized zone Building.t1. Instantiated building with 2 zones.
Initialized zone Building.t2, nZon = 2
Exchanged with zone Building.t1 at time=0.000000, nZon = 2
Exchanged with zone Building.t2 at time=0.000000, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
```
and if `startTime` is an argument of the constructor:
```
Allocated zone Building.t1
Initialized zone Building.t1. Instantiated building with 1 zones.  // <- This is wrong.
Allocated zone Building.t2
Initialized zone Building.t2, nZon = 2
Exchanged with zone Building.t1 at time=0.000000, nZon = 2
Exchanged with zone Building.t2 at time=0.000000, nZon = 2
Exchanged with zone Building.t1 at time=1.000000, nZon = 2
Exchanged with zone Building.t2 at time=1.000000, nZon = 2
```

OpenModelica produces

```
Allocated zone BuildingRooms.Building.t1
Allocated zone BuildingRooms.Building.t2
Exchanged with zone BuildingRooms.Building.t1 at time=0.000000, nZon = 2
Exchanged with zone BuildingRooms.Building.t2 at time=0.000000, nZon = 2
Initialized zone BuildingRooms.Building.t2. Instantiated building with 2 zones.
Initialized zone BuildingRooms.Building.t1, nZon = 2

```

and if `startTime` is an argument of the constructor:
```
Allocated zone BuildingRooms.Building.t1
Initialized zone BuildingRooms.Building.t1. Instantiated building with 1 zones.  // <- This is wrong.
Exchanged with zone BuildingRooms.Building.t1 at time=0.000000, nZon = 1
Allocated zone BuildingRooms.Building.t2
Initialized zone BuildingRooms.Building.t2, nZon = 2
Exchanged with zone BuildingRooms.Building.t2 at time=0.000000, nZon = 2
```


In my actual implementation (at https://github.com/lbl-srg/modelica-buildings/tree/master/Buildings/ThermalZones/EnergyPlus)
it would be impractical to implement a work-around that guards against the situation
where the initialization is called before all constructors are called.
This would require the user to specify how many instances of `ThermalZone` there are,
which can be hundreds, and it would give wrong results (or a segmentation fault) if this number
is not set correctly by the user. It would also require specifying the names of
hundreds of zones in two places of the Modelica model.
Hence, ensuring that all constructors are called first seems to be the only practical way.
