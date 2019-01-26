// terminate simulation and retrieve final values
TERMINATE_MODEL:
M_fmi2Terminate(m)
M_fmi2GetReal/Integer/Boolean/String(m, ...)

// cleanup
M_fmi2FreeInstance(m)
