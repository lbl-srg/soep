// advance time for whole EnergyPlus model if not yet done
if EnergyPlus.time <> Modelica.time then
  fmi2EnterContinuousTimeMode(bld)
  M_fmi2SetTime(bld, Modelica.time)
  fmi2EnterEventMode(bld)
end if
// Since Modelica.time is the time that EnergyPlus requested to be invoked next
// there won't be any time events between the last and the current EnergyPlus invocation
// Hence, we don't call M_fmi2GetEventIndicators(m, z, nz)
// We don't call
// M_fmi2CompletedIntegratorStep(m, fmi2True, &enterEventMode, &terminateSimulation)
// because all states in EnergyPlus are discrete states

fmi2SetReal(bld, scheduleValue/actuatorValue/variableValue)

// EnergyPlus to return with newDiscreteStateNeeded=false if and only if
// all input for schedules, actuators and variables have been obtained,
// and all rooms have been called
eventInfo = fmi2NewDiscreteStates(bld, fmi2EventInfo)
if eventInfo.terminateSimulation then goto TERMINATE_MODEL
