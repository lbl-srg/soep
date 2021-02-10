within ;
package BuildingRooms

  package Synchronize
    connector SynchronizeConnector
      Real do;
      flow Real done;
    end SynchronizeConnector;

    model SyncronizeModel
      SynchronizeConnector synchronize;
    end SyncronizeModel;

    model CollidingObject
      outer CollidingWorld collidingWorld;
      SyncronizeModel sync;
    equation
      connect(collidingWorld.synchronize, sync.synchronize);
    end CollidingObject;
  end Synchronize;

  model CollidingWorld
    // ExternalScene scene=ExternalScene(id="s");
    Synchronize.SynchronizeConnector synchronize;
    Real bodyMoved = synchronize.done;
    Real forceCalculated;
    Real dummy;
  equation
    synchronize.do = 0;
  algorithm
    dummy := bodyMoved;
    // calculateForces(scene);
    forceCalculated := 0;
  end CollidingWorld;
  ///////////////////////////////////////////////////////////////////
  model ThermalZone
    extends Synchronize.CollidingObject;
    constant String name=getInstanceName();
    // ZoneClass adapter = ZoneClass(name);
    ZoneClass adapter = ZoneClass(name, startTime);

    parameter Modelica.SIunits.Time startTime(fixed=false) "Simulation start time";
    parameter Integer nZ(fixed=false, start=0) "Total number of zones in Building";
    constant Real k=1;
    Modelica.SIunits.Time tNext(start=startTime, fixed=true) "Next sampling time";
    Modelica.SIunits.Temperature T(start=293.15, fixed=true);
    Modelica.SIunits.HeatFlowRate Q_flow;

  initial equation
    startTime=time;
    nZ=zoneInitialize(adapter=adapter, startTime=time, forceCalculated=collidingWorld.forceCalculated);
  equation
    when {initial(), time >= pre(tNext)} then
      (tNext, Q_flow) = zoneExchange(adapter, time, T);
    end when;
    k*der(T) = Q_flow;
    nZ = sync.synchronize.done;
  end ThermalZone;
  ///////////////////////////////////////////////////////////////////
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
  ///////////////////////////////////////////////////////////////////
  function zoneInitialize
    input ZoneClass adapter "External object";
    input Modelica.SIunits.Time startTime "Start time of the simulation";
    input Real forceCalculated;
    output Integer nZ "THIS VALUE IS NOT GUARANTEED TO BE CORRECT";
    external "C" ZoneInitialize(adapter, startTime, nZ)
    annotation (Include="#include <thermalZone.c>",
                IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
  end zoneInitialize;
  ///////////////////////////////////////////////////////////////////
  function zoneExchange
    input ZoneClass adapter "External object";
    input Modelica.SIunits.Time t;
    input Modelica.SIunits.Temperature T;
    output Modelica.SIunits.Time tNext;
    output Modelica.SIunits.HeatFlowRate Q_flow;
    external "C" ZoneExchange(adapter, t, T, tNext, Q_flow)
    annotation (Include="#include <thermalZone.c>",
                IncludeDirectory="modelica://BuildingRooms/Resources/C-Sources");
  end zoneExchange;

  model Building "Buildings with two thermal zones, e.g., nZ=2"
    inner CollidingWorld collidingWorld;
    ThermalZone t1;
    ThermalZone t2;
  end Building;
end BuildingRooms;