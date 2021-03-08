within BuildingRooms;
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
  nZ =synBui.synchronize.done;
end ThermalZone;
