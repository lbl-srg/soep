================================================================
Spawn of EnergyPlus -- Design and Implementation (Working Draft)
================================================================

.. only:: html

   The Spawn of EnergyPlus, called SOEP, is a next-generation simulation engine,
   for building and control energy systems. SOEP will combine

    * The `OpenStudio <https://www.openstudio.net/>`_ front-end for model authoring, simulation
      and as a workflow automation tool,
    * the `Modelica Buildings Library <http://simulationresearch.lbl.gov/modelica>`_
      as a repository of models,
    * `JModelica <http://www.jmodelica.org/>`_ as a translator that
      translate models from the
      `Modelica <https://modelica.org/>`_ standard to the
      `Functional Mockup Interface <http://fmi-standard.org/>`_ standard
      for simulation and for execution on control systems,
    * `PyFMI <https://pypi.python.org/pypi/PyFMI>`_ as a master algorithm
      that conducts a time domain simulation.

   The intent is for SOEP and EnergyPlus to live side-by-side,
   with the OpenStudio software development kit providing access to both
   and insulating users and client vendors from implementation differences.
   Equation-based models allow SOEP to unify building energy modeling
   with control workflows, and allow users and manufacturers to insert
   their own models into SOEP.

   .. figure:: img/bto_modelica_030917.png
      :scale: 50%

      Spawn-of-EnergyPlus (SOEP) is a next-generation BEM engine that
      leverages open standards for equation-based modeling (Modelica)
      and co-simulation (FMI).

   This documentation is a working document for the design, development
   and implementation of the Spawn of EnergyPlus (SOEP).
   The document is work in progress, used as a discussion basis,
   and any of the design may change.




.. only:: html

   Table of Contents
   =================


.. toctree::
   :numbered:
   :maxdepth: 4

   preample
   conventions
   useCases
   requirements
   softwareArchitecture
   numericalMethods
   api
   benchmarks
   acknowledgments
   zreferences
