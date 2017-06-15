# General

Models for the end-to-end tests have been developed in Modelica and OpenStudio and are located in the folders ``/Modelica`` and ``/OpenStudio`` respectively.  The Modelica models can be found in the ``SOEPDemo.Examples`` and ``SOEPDemo.MVP`` packages in the ``SOEPDemo.mo`` file and are compatible with the *Buildings Library* v5.0.  The ``/Modelica`` folder also contains .mos scripts to simulate the Modelica models for a year.  The models for each platform have been developed simultaneously, with each model having a corresponding counterpart in the other platform.  For the end-to-end minimum viable product (MVP), the ``SOEPDemo.MVP.SingleZoneVAV`` modelica and ``SingleZoneVAV_MVP OpenStudio models should be used.
<br>

# Single Zone Models

All models contain an HVAC system that supplies air to a single Case 600 BESTEST room model.  Simulations are run in Dymola 2017 for one year using the ``DRYCOLD.tmy`` weather file, which is used for BESTESTs.  Development started with CASE 600 free-float examples.  Then, ideal air HVAC systems were added with constant cooling and heating setpoints.  Then, VAV systems with variable speed fan, single-speed air-cooled DX coils, electric resistance heat, and full return air recirculation were added.  Then, constant outside air mixing was added.  Then, time-varying heating and cooling setpoints and time-varying internal loads were added.  Then, the single-speed air-cooled DX cooling coil was replaced by a dry chilled water cooling coil served by an air-cooled chiller and chilled water system with coil bypass.  Then, economizer control was added based on outside air drybulb temperature.  Below is a summary of the models.

## 1) Case 600 Free Float

*Modelica Model* : SOEPDemo.Examples.FreeFloat_SingleZone

*OpenStudio Model* : Case600FF.osm

## 2) Ideal Air System

*Modelica Model* : SOEPDemo.Examples.IdealHVAC_SingleZone

*OpenStudio Model* : Case600FF_IdealAirSystem.osm

## 3) VAV with Single-Speed Air-Cooled DX Cooling Coil and Constant Outside Air Mixing

*Modelica Model* : SOEPDemo.Examples.VAV_SingleZone_dxCoil_fan_mix

*OpenStudio Model* : Case600FF_dxCoil_Fan_mix_setsched_int.osm

## 4) VAV with Dry Cooling Coil, Air-Cooled Chiller, and Constant Outside Air Mixing

*Modelica Model* : SOEPDemo.Examples.VAV_SingleZone_drycoil_fan_mix_chiller

*OpenStudio Model* : Case600FF_drycoil_Fan_mix_setsched_int_chw.osm

## 5) VAV with Dry Cooling Coil, Air-Cooled Chiller, and Dynamic Economizer Outside Air Mixing

*Modelica Model* : SOEPDemo.Examples.VAV_SingleZone_drycoil_fan_mix_chiller

*OpenStudio Model* : Case600FF_drycoil_Fan_mix_setsched_int_chw.osm

## 6) Minimum Viable Product

*Modelica Model* : SOEPDemo.MVP.SingleZoneVAV

*OpenStudio Model* : SingleZoneVAV_MVP.osm

<br>

# FMI Containers

*Modelica Model* : SOEPDemo.Examples.FMI

This section uses model 4) to test use of the FMU containers added in the *Buildings Library* v4.0., giving insight into how the model may be split into FMUs for simulation within SOEP.  For this, the model ``SOEPDemo.HVACSystems.VAV_SingleZone_drycoil_fan_mix_chiller`` was packaged inside an FMI Container by extending ``Buildings.Fluid.FMI.ExportContainers.HVACZone`` and connecting ports as necessary.  Similarly, ``SOEPDemo.ThermalEnvelope.Case600_AirHVAC`` was packaged inside an FMI container by extending ``Buildings.Fluid.FMI.ExportContainers.ThermalZone`` and connecting ports as necessary.  The two resulting FMI containers were connected in the model ``SOEPDemo.Examples.FMI``.
<br>

# HVAC System Isolation

*Modelica Model* : SOEPDemo.Examples.FMI_T_X_Only

This section looks to isolate the HVAC system simulation from the thermal envelope simulation and benchmark the performance.  To do this, the values of zone air mean air temperature and humidity ratio were recorded from the simulation in 4) at an interval of 3600 s.  Then, an FMI container of the type ``Buildings.Fluid.FMI.ExportContainers.HVACZone`` was created that contained only fluid boundaries; a fixed boundary that serves as sink for the HVAC supply air flow and a boundary with variable temperature and humidity ratio that serves as a source for the HVAC return air flow.  The temperature and humidity ratio in the source boundary is loaded using a table from a file with the recorded values from the original simulation.  This FMI container replaced the thermal zone container used in the previous case, creating the model ``SOEPDemo.Examples.FMI_T_X_Only``.



