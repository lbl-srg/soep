// terminate simulation and retrieve final values
TERMINATE_MODEL:
if not fmi2Fatal then
  if not fmi2Error then
    fmi2Terminate(bld)
  end if

  fmi2GetReal(bld, ...)
  if receivedAllFinalOutputAndRoomHeatFlows then
    fmi2FreeInstance(bld)
  end if
end if
