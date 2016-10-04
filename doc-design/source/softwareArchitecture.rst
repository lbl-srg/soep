.. _sec_soft_arch:

Software Architecture
---------------------

:numref:`fig_overall_software_architecture_one_editor`
and 
:numref:`fig_overall_software_architecture_two_editors` show the overall
software architecture of SOEP, either with one or with two
HVAC and control editors.

The `Application` on top of the figure may be an
equipment sales tool that uses an open, or a proprietary,
Modelica model library of their product line, which allows
a sales person to test and size equipment for a particular customer.

The `HVAC Systems Editor` allows drag and drop of components
from the `Model Library`,
similar to what can be done in today's OS schematic editor.
In contrast, the `Schematic Editor` allows to freely place
and graphically connect Modelica components.
Once models have been manipulated in the
`Schematic Editor`, OS can only simulate them, but not apply
OS Measures to it, as models may have become incompatible
with the OS Measures. (This could in the future be changed
by parsing the AST of the model.)

In the `Schematic Editor`, user-provided Modelica libraries
can be loaded (for example, if a company has their own
control sequence library), manipulated and stored again
in the user-provided Modelica library. This functionality is also
needed for the OpenBuildingControl project.

Currently, the OpenStudio Model Library is compiled C++ code.
Our integration either generates C++ code that would need to
compiled which a C++ compiler, or the OpenStudio Model Library
could be changed to allow dynamic loading of models for
the SOEP mode.
Note that the JModelica distribution includes a C++ compiler.

.. note::

   #. Whether the `Conversion Script` and the `Schematic Editor`
      access `JModelica` to get the AST, or whether they read
      the AST from `Modelica Library AST` does not affect
      the functionality, but it affects the architecture.
      In :numref:`fig_overall_software_architecture_two_editors`
      we show the architecture if the `Modelica Library AST` is parsed
      directly using JModelica rather than storing it in a file.


   #. The architecture shows two graphical editors for HVAC systems.
      Ideally, we would combine them into one graphical editor. Whether this
      is feasible will depend on the modeling support that the refactored
      OpenStudio `HVAC System Editor` will provide.
         

.. _fig_overall_software_architecture_two_editors:

.. uml::
   :caption: Overall software architecture (with two editors for the SOEP mode).

   title Overall software architecture (with two editors for the SOEP mode).

   skinparam componentStyle uml2

   package OpenStudio {
   interface API
   API -- [Core]
   package Legacy-Mode {
   database "Legacy\nModel Library"
   [Core] --> [Legacy\nModel Library]: integrates
   [Core] --> [HVAC Systems Editor\n(Legacy Mode)]: integrates
   [Core] --> [EnergyPlus\nSimulator Interface]: integrates
   }

   package SOEP-Mode {
   database "SOEP\nModel Library"
   [Core] --> [SOEP\nModel Library]: integrates
   [Core] --> [HVAC Systems Editor\n(SOEP Mode)]: integrates
   [Core] --> [SOEP\nSimulator Interface]: integrates
   }
   }

   actor Developer as epdev
   [Legacy\nModel Library] <.. epdev : updates

   EnergyPlus <.. [EnergyPlus\nSimulator Interface]: writes inputs,\nruns simulation,\nreads outputs
   package EnergyPlus {
     [in.idf] -> [EnergyPlus.exe]
     [EnergyPlus.exe] -> [eplusout.sql]
   }

   package SOEP {
   [Schematic Editor] ..> [JModelica] : parses\nAST
   [HVAC Systems Editor\n(SOEP Mode)] ..> [Schematic Editor]: calls editor,\nwhich returns\n.mo file
   [SOEP\nModel Library] <.. [Conversion Script]: augments library\nby generating C++ code

   [Conversion Script] ..> [JModelica]: parses\nAST
   [SOEP\nSimulator Interface] ..> [JModelica] : writes inputs,\nruns simulation,\nreads outputs
   database "Modelica\nLibrary AST"
   database "Modelica\nBuildings Library"
   [HVAC Systems Editor\n(SOEP Mode)] ..> [Modelica\nLibrary AST]: reads AST
   [Modelica\nLibrary AST] <.. [Conversion Script] : generates\nAST
   [JModelica] --> [Modelica\nBuildings Library]: imports
   }

   actor "Developer or User" as modev
   [Conversion Script] <.. modev : invokes

   actor Developer as budev
   [Modelica\nBuildings Library] <.. budev : adds annotations

   actor User as mouse
   [User-Provided\nModelica Library] <.. mouse : adds annotations


   [Application] ..> () API : uses
   [Measures] ..> () API : uses

   database "User-Provided\nModelica Library"
   [JModelica] --> [User-Provided\nModelica Library]: imports



   note right of [Schematic Editor]
     Allows free graphical editing
     of Modelica models. However,
     after editing, many OS Measures
     cannot be applied anymore
     (as models may be incompatible
     with the Measures).
     However, OS can still simulate
     these models and parse their
     outputs.
   end note

   note bottom of [User-Provided\nModelica Library]
     Allows companies to use
     their own Modelica libraries
     with custom HVAC systems and
     control sequences, or
     to integrate an electronic
     equipment catalog or a
     library used for an equipment
     sales tool.
   end note

   note left of OpenStudio
     Not yet shown is
     how to integrate
     the building model.
   end note

   note right of Application
     Application that uses
     the OpenStudio SDK.
   end note





.. _fig_overall_software_architecture_one_editor:

.. uml::
   :caption: Overall software architecture (with one editor for the SOEP mode).

   title Overall software architecture (with one editor for the SOEP mode).

   skinparam componentStyle uml2

   package OpenStudio {
   interface API
   API -- [Core]

   package Legacy-Mode {
   database "Legacy\nModel Library"
   [Core] --> [Legacy\nModel Library]: integrates
   [Core] --> [HVAC Systems Editor\n(Legacy Mode)]: integrates
   [Core] --> [EnergyPlus\nSimulator Interface]: integrates
   }

   package SOEP-Mode {
   database "SOEP\nModel Library"
   [Core] --> [SOEP\nModel Library]: integrates
   [Core] --> [HVAC Systems Editor\n(SOEP Mode)]: integrates
   [Core] --> [SOEP\nSimulator Interface]: integrates
   }
   }

   actor Developer as epdev
   [Legacy\nModel Library] <.. epdev : updates

   EnergyPlus <.. [EnergyPlus\nSimulator Interface]: writes inputs,\nruns simulation,\nreads outputs
   package EnergyPlus {
     [in.idf] -> [EnergyPlus.exe]
     [EnergyPlus.exe] -> [eplusout.sql]
   }

   package SOEP {
   [HVAC Systems Editor\n(SOEP Mode)] ..> [JModelica] : parses\nAST
   [SOEP\nModel Library] <.. [Conversion Script]: augments library\nby generating C++ code

   [Conversion Script] ..> [JModelica]: parses\nAST
   [SOEP\nSimulator Interface] ..> [JModelica] : writes inputs,\nruns simulation,\nreads outputs
   database "Modelica\nLibrary AST"
   database "Modelica\nBuildings Library"
   [JModelica] --> [Modelica\nBuildings Library]: imports
   }

   actor "Developer or User" as modev
   [Conversion Script] <.. modev : invokes

   actor Developer as budev
   [Modelica\nBuildings Library] <.. budev : adds annotations

   actor User as mouse
   [User-Provided\nModelica Library] <.. mouse : adds annotations


   [Application] ..> () API : uses
   [Measures] ..> () API : uses

   database "User-Provided\nModelica Library"
   [JModelica] --> [User-Provided\nModelica Library]: imports



   note right of [HVAC Systems Editor\n(SOEP Mode)]
     Allows free graphical editing
     of Modelica models. However,
     after editing, many OS Measures
     cannot be applied anymore
     (as models may be incompatible
     with the Measures).
     However, OS can still simulate
     these models and parse their
     outputs.
   end note

   note bottom of [User-Provided\nModelica Library]
     Allows companies to use
     their own Modelica libraries
     with custom HVAC systems and
     control sequences, or
     to integrate an electronic
     equipment catalog or a
     library used for an equipment
     sales tool.
   end note

   note left of OpenStudio
     Not yet shown is
     how to integrate
     the building model.
   end note

   note right of Application
     Application that uses
     the OpenStudio SDK.
   end note




**fixme: more design to be added**
