.. only:: html

   The Spawn of EnergyPlus, called SOEP, is a next-generation simulation engine,
   for building and control energy systems. SOEP will combine

    * The `OpenStudio <https://www.openstudio.net/>`_ front-end for model authoring, simulation
      and as a workflow automation tool,
    * the `Modelica Buildings Library <http://simulationresearch.lbl.gov/modelica>`_
      as a repository of models,
    * `OPTIMICA <https://www.modelon.com/products-services/modelon-creator-suite/optimica-compiler-toolkit/>`_
      as a translator that
      translate models from the
      `Modelica <https://modelica.org/>`_ standard to the
      `Functional Mockup Interface <http://fmi-standard.org/>`_ standard
      for simulation and for execution on control systems,
    * `QSS solvers <https://github.com/NREL/SOEP-QSS>`_,
      a class of new solvers that we develop for Spawn,
    * `PyFMI <https://pypi.python.org/pypi/PyFMI>`_ as a suite of
      state-of-the-art numerical solvers
      that conduct a time domain simulation.

   The intent is for SOEP and EnergyPlus to live side-by-side,
   with the OpenStudio software development kit providing access to both
   and insulating users and client vendors from implementation differences.
   Equation-based models allow SOEP to unify building energy modeling
   with control workflows, and allow users and manufacturers to insert
   their own models into SOEP.

   .. figure:: img/spawnArchitecture.*
      :width: 1000px

      Spawn-of-EnergyPlus (SOEP) is a next-generation BEM engine that
      leverages open standards for equation-based modeling (Modelica)
      and co-simulation (FMI).

   This documentation is a working document for the design, development
   and implementation of the Spawn of EnergyPlus (SOEP).

   To cite Spawn of EnergyPlus, use
   
   | Michael Wetter, Kyle Benne, Hubertus Tummescheit and Christian Winther.
   | `Spawn: coupling Modelica Buildings Library and EnergyPlus to enable new energy system and control applications. <https://doi.org/10.1080/19401493.2023.2266414>`_
   | Journal of Building Performance Simulation. Pages 1-19. 2023.



.. only:: html

   Table of Contents
   =================


.. toctree::
   :numbered:
   :maxdepth: 4

   preample
   download
   conventions
   requirements
   softwareArchitecture
   numericalMethods
   benchmarks
   acknowledgments
   glossary
   zreferences
