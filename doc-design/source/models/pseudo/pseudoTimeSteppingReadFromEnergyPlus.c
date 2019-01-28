// advance time for whole EnergyPlus model if not yet done
if EnergyPlus.bld.time <> Modelica.time then
  fmi2EnterContinuousTimeMode(bld)
  M_fmi2SetTime(bld, Modelica.time)
  fmi2EnterEventMode(bld)
end if
// Get the value of the output variable
fmi2GetReal(bld, outputVariable);

// EnergyPlus to return with newDiscreteStateNeeded=false if and only if
// all input for schedules, actuators and variables have been obtained,
// and all rooms have been called
eventInfo = fmi2NewDiscreteStates(bld, fmi2EventInfo)
if eventInfo.terminateSimulation then goto TERMINATE_MODEL

// If EnergyPlus knows that the output will never change, it
// can set nextEventTimeDefined = false.
// Otherwise, it needs to set nextEventTime to the time when
// it will report the output again
if eventInfo.nextEventTimeDefined then
  Tnext = eventInfo.nextEventTime
else
  Tnext = infinity
end if
