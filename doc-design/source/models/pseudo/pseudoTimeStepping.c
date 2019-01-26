
// compute derivatives
M_fmi2GetDerivatives(m, der_x, nx)
// advance time
h = min(dt, Tnext-time)
time = time + h
M_fmi2SetTime(m, time)
// set inputs at t = time
M_fmi2SetReal/Integer/Boolean/String(m, ...)
// set states at t = time and perform one step
x = x + h*der_x  // forward Euler method
M_fmi2SetContinuousStates(m, x, nx)
// get event indicators at t = time
M_fmi2GetEventIndicators(m, z, nz)
// detect  events, if any
time_event = abs(time - Tnext) <= eps
state_event = ...          // compare sign of z with previous z
// inform the model about an accepted step
M_fmi2CompletedIntegratorStep(m, fmi2True, &enterEventMode, &terminateSimulation)
if terminateSimulation then goto TERMINATE_MODEL
// handle events
if entertEventMode or time_event or state_event then
  M_fmi2EnterEventMode(m)
  // event iteration
  eventInfo.newDiscreteStatesNeeded = true;
  while eventInfo.newDiscreteStatesNeeded loop
    // update discrete states
    M_fmi2NewDiscreteStates(m, &eventInfo)
    if eventInfo.terminateSimulation then goto TERMINATE_MODEL
  end while
  // enter Continuous-Time Mode
  M_fmi2EnterContinuousTimeMode(m)
  // retrieve solution at simulation restart
  M_fmi2GetReal/Integer/Boolean/String(m, ...)
  if eventInfo.valuesOfContinuousStatesChanged == fmi2True then
    //the model signals a value change of states, retrieve them
    M_fmi2GetContinuousStates(m, x, nx)
  end if
  if eventInfo.nominalsOfContinuousStatesChanged = fmi2True then
    //the meaning of states has changed; retrieve new nominal values
    M_fmi2GetNominalsOfContinuousStates(m, x_nominal, nx)
  end if
  if eventInfo.nextEventTimeDefined then
    Tnext = min(eventInfo.nextEventTime, Tend)
  else
    Tnext = Tend
  end if
end if
