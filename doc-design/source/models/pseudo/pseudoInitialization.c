instantiate(...) // This differs from FMI2

m = M_fmi2Instantiate("m", ...)  // "m" is the instance name
                                 // "M_" is the MODEL_IDENTIFIER
nx = ...         // number of states, from XML file
nz = ...         // number of event indicators, from XML file
Tstart = time     // Start time from the Modelica simulation
** fixme: not known Tend = ...        // could also be retrieved from XML file
dt = ...         // fixed step size of 10 milli-seconds

// set the start time
M_fmi2SetTime(m, time)

// set all variable start values (of "ScalarVariable / <type> / start") and
// set the input values at time = Tstart
M_fmi2SetReal(m, ...)

// initialize
   // determine continuous and discrete states
   M_fmi2SetupExperiment(m,fmi2False,0.0, Tstart, fmi2True,Tend)
   M_fmi2EnterInitializationMode(m)
   M_fmi2ExitInitializationMode(m)

   // event iteration
   eventInfo.newDiscreteStatesNeeded = true;
   while eventInfo.newDiscreteStatesNeeded loop
     // update discrete states
     M_fmi2NewDiscreteStates(m, &eventInfo)
     if eventInfo.terminateSimulation then goto TERMINATE_MODEL
   end while

// enter Continuous-Time Mode
M_fmi2EnterContinuousTimeMode(m)

// retrieve initial state x and
// nominal values of x (if absolute tolerance is needed)
M_fmi2GetContinuousStates(m, x, nx)
M_fmi2GetNominalsOfContinuousStates(m, x_nominal, nx)

// retrieve solution at t=Tstart, for example for outputs
M_fmi2GetReal/Integer/Boolean/String(m, ...)
