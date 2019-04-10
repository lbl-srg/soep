if not instantiatedEnergyPlus then
  // Call instantiate exactly once per building.

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

// Get the parameters from EnergyPlus
// For each room, call
fmi2GetReal(...)


// Enter initialization mode
if not fmuEnteredInitializationMode then
  fmi2EnterInitializationMode(...)
  fmuEnteredInitializationMode = true
end if

// Set the inputs and get the outputs for the room
fmi2SetReal(...)
fmi2GetReal(...)

// Update data that tracks that all outputs and inputs have been
// retrieved or set during the initialization.
// This tracker is used so that calledAllGetGet() returns true
// if all get and set is called on all data that is exchanged.
updateGetSetTracker(...)

if calledAllGetSet() then
fmi2ExitInitializationMode(...) // FMU enters implicitely Event Mode
end if
