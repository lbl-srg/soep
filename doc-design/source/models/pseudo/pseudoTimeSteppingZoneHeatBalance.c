// advance time for whole EnergyPlus model if not yet done
if EnergyPlus.bld.time <> Modelica.time then
  fmi2EnterContinuousTimeMode(bld)
  M_fmi2SetTime(bld, Modelica.time)
  fmi2EnterEventMode(bld)
end if
// set inputs at t = time
// Compute output and its derivatives
fmi2SetReal(bld, room.TAir+dT,...) // Set air temperature, humidity, etc.
fmi2GetReal(bld, room.Q(TAir+dT)...); // Get heat flow rates and radiative temperature
fmi2SetReal(bld, room.TAir,...) // Set air temperature, humidity, etc.
fmi2GetReal(bld, room.Q(TAir)...); // Get heat flow rates and radiative temperature

// EnergyPlus to return with newDiscreteStateNeeded=false if and only if
// all input for schedules, actuators and variables have been obtained,
// and all rooms have been called
eventInfo = fmi2NewDiscreteStates(bld, fmi2EventInfo)
if eventInfo.terminateSimulation then goto TERMINATE_MODEL

if eventInfo.nextEventTimeDefined then
  Tnext = eventInfo.nextEventTime
else
  goto TERMINATE_MODEL
end if
