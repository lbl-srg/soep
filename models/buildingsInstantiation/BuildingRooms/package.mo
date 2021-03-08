within ;
package BuildingRooms

  package Synchronize
    connector SynchronizeConnector "Connector to synchronize Spawn objects"
      Real do "Potential variable";
      flow Real done "Flow variable";
    end SynchronizeConnector;

    model SyncronizeModel "Model to synchronize the Spawn objects"
      SynchronizeConnector synchronize "Connector that is used to synchronize objects";
    end SyncronizeModel;

    model ObjectSynchronizer "Block that synchronizes an object"
      outer Building building;
      SyncronizeModel sync;
    equation
      connect(building.synchronize, sync.synchronize);
    end ObjectSynchronizer;
  end Synchronize;
  ///////////////////////////////////////////////////////////////////
  model ThermalZone
    extends Synchronize.ObjectSynchronizer;
    constant String name=getInstanceName();
    ZoneClass adapter = ZoneClass(name, startTime);

    parameter Modelica.SIunits.Time startTime(fixed=false);
    parameter Integer nZ(fixed=false, start=0) "Total number of zones in building";
    constant Real k=1;
    Modelica.SIunits.Time tNext(start=startTime, fixed=true);
    Modelica.SIunits.Temperature T(start=293.15, fixed=true);
    Modelica.SIunits.HeatFlowRate Q_flow;

  initial equation
    startTime=time;
    nZ=initialize(
      adapter=adapter,
      startTime=time,
      isSynchronized=building.isSynchronized);
  equation
    when {initial(), time >= pre(tNext)} then
      (tNext, Q_flow) =exchange(
        adapter,
        time,
        T);
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
  ///////////////////////////////////////////////////////////////////
annotation (uses(Modelica(version="3.2.3")));
end BuildingRooms;
