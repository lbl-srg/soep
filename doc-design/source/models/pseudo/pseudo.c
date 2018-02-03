 // instantiate
    m = M_fmi2Instantiate(...) -> instantiate(...) 

    tStart = 0     
    tEnd   = 10    
    dt     = 0.01  
    
    // set the start time
    time  = tStart
    
    // set the input values and the initial values for the states at time = tStart
    M_fmi2SetReal(m, ...) -> setVariables (...) 
        
    // initialize    
    M_fmi2SetupExperiment(m,fmi2False,0.0, Tstart, fmi2True,Tend) -> NA 
    M_fmi2EnterInitializationMode(m) -> initialize(...)
    M_fmi2ExitInitializationMode(m) -> NA
    
    initialEventMode = fmi2True
    enterEventMode = fmi2False
    timeEvent = fmi2False
    stateEvent = fmi2False
    previous_z = zeros(nz)
    
    // The time in EnergyPlus is now at Tstart
    
    do
      // handle events
      if initialEventMode or enterEventMode or timeEvent or stateEvent then
        if not initialEventMode then
          M_fmi2EnterEventMode(...) -> NA
        end if
    
        // event iteration
        eventInfo.newDiscreteStatesNeeded = fmi2True;
        M_valuesOfContinuousStatesChanged = fmi2False;
         while eventInfo.newDiscreteStatesNeeded loop
           // update discrete states
           M_fmi2NewDiscreteStates(eventInfo, ...) -> getNextEventTime(eventInfo, ...) 
           // See specification on page 80
           M_fmi2SetReal(...) -> setVariables (...)
           M_fmi2GetReal(...) -> getVariables (...)
           if eventInfo.terminateSimulation then goto TERMINATE_MODEL
        end while
    
        // enter Continuous-Time Mode
        M_fmi2EnterContinuousTimeMode(m) -> NA
    
        // retrieve solution at simulation (re)start
        M_fmi2GetReal(...) -> getVariables (...)
        if initialEventMode or eventInfo.valuesOfContinuousStatesChanged then
          //the model signals a value change of states, retrieve them
          M_fmi2GetContinuousStates(...) -> getContinuousStates(...)
        end if
    
        if initialEventMode or eventInfo.nominalsOfContinuousStatesChanged then
          //the meaning of states has changed; retrieve new nominal values
          M_fmi2GetNominalsOfContinuousStates(...) -> NA
        end if
    
        if eventInfo.nextEventTimeDefined then
           tNext = min(eventInfo.nextEventTime, tEnd)
        else
           tNext = tEnd
        end if
    
        initialEventMode = fmi2False
      end if
    
      if time >= tEnd then
        goto TERMINATE_MODEL
      end if
    
      // compute derivatives
      M_fmi2GetDerivatives(...) -> getTimeDerivatives(...)
      // Note we might have to compute time derivatives at different time instants
      // to approximate higher order derivatives for QSS integration methods.
    
      // Note that a forward Euler method with event detection, or more sophisticated
      // methods such as dassl, will not work with EnergyPlus.
      // The reason is that EnergyPlus does not allow rollback (and this limitation 
      // is indicated in the model description file with the capability flag
      // canGetAndSetFMUstate=false.
   
      // When using QSS numerical methods,
      // compute minimal next quantization time tq
      time_old = time
      time = min (tq, tNext) // tq is the next predicted quantization time
      
      M_fmi2SetTime(...) -> setTime(...)
    
      // set inputs at t = time
      M_fmi2SetReal(m, ...) -> setVariables (...)
    
      // do a time integration up to t = time
      x = integral(x, der_x, time_old, time)  
      M_fmi2SetContinuousStates(...) -> setContinuousStates(...)
  
      // get event indicators for state events detection at t = time
      M_fmi2GetEventIndicators(...) -> NA 
    
      // EnergyPlus has no zero crossing functions, hence
      // there is no state event detection for this FMU.
    
      // inform the model about an accepted step
      // To ensure that EnergyPlus call getNextEventTime(...),
      // enterEventMode will be set to true in M_fmi2CompletedIntegratorStep().
      // Furthermore, the capability flag completedIntegratorStepNotNeeded
      // will be set to false to ensure that this function is called
      // after an accepted step.
      M_fmi2CompletedIntegratorStep(enterEventMode...) -> writeOutputFiles(...)
      
      // get the outputs
      M_fmi2GetReal(m, ...) -> getVariables (...)
      
    until terminateSimulation
    
    // terminate simulation and retrieve final values
    TERMINATE_MODEL:
    M_fmi2GetReal(m, ...) -> getVariables()
    M_fmi2Terminate(m) -> terminate(...)

    
    // cleanup
    M_fmi2FreeInstance(m) -> NA
