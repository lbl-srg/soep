if not instantiatedEnergyPlus then
  // Call instantiate exactly once per building.
  instantiate(bld) // This differs from FMI2

  // Call instantiate exactly once per building.
  m = fmi2Instantiate(idf_name, ...)
  fmi2SetDebugLogging(...)
  TStart = time     // Start time from the Modelica simulation
  fmi2SetupExperiment(
    bld,
    toleranceDefined=fmi2False,
    tolerance = 0.0,
    startTime = Tstart,
    stopTimeDefined = fmi2False,
    stopTime = 0)
    instantiatedEnergyPlus = true
end if

// initialize
// determine continuous and discrete states
if not fmuEnteredInitializationMode then
  fmi2EnterInitializationMode(...)
  fmuEnteredInitializationMode = true
end if

// Get the output for the schedule
fmi2GetReal(bld, ...)

// Update data that tracks that all outputs and inputs have been
// retrieved or set during the initialization
updateGetSetTracker(bld, ...)

if calledAllGetSet() then
  M_fmi2ExitInitializationMode(...)
  // Enter event mode
  fmi2EnterEventMode(bld)
end if
