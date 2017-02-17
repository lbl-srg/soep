This repository contains Modelica models and FMUs generated using Dymola.

Buildings_ThermalZones_Detailed_Validation_BESTEST_Case600FF.fmu is the FMU 
exported from the BESTEST model Case 600FF (Case600FF.mo).
Case600FF.mo can not be directly exported as an FMU. This needs to be done 
from the Buildings library (master branch).
I tried to export and save the Case600FF.mo as a total model. However, when I tried to 
translate the total model, the translation fails because of missing libraries.
Hence I put the original Modelica model here for future reference ntil I sort out the translation issue.
