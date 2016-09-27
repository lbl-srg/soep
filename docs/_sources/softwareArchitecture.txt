.. _sec_soft_arch:

Software Architecture
---------------------

:numref:`fig_overall_software_architecture` shows the overall
software architecture of SOEP.
The figure indicates an application which may be an
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
by iterating through a Modelica model instance.)

In the `Schematic Editor`, user-provided Modelica libraries
can be loaded (for example, if a company has their own
control sequence library), manipulated and stored again
in the user-provided Modelica library. This functionality is also
needed for the OpenBuildingControl project.

.. note::

   Whether the `Conversion Script` and the `Schematic Editor`
   access `JModelica` to get the AST, or whether they read
   the AST from `Modelica Library AST` does not affect
   the functionality.
         

.. _fig_overall_software_architecture:

.. uml::
   :caption: Overall software architecture.

   title Overall software architecture

   skinparam componentStyle uml2

   package OpenStudio {
   API -- [Core]
   [Core] --> [Model Library]: integrates
   [Core] --> [HVAC Systems Editor]: integrates
   [Core] --> [Simulator Interface]: integrates
   }

   package SOEP {
   [Schematic Editor] ..> [JModelica] : parses\nAST
   [HVAC Systems Editor] ..> [Schematic Editor]: calls editor,\nwhich returns\n.mo file
   [Model Library] <.. [Conversion Script]: augments library\nby generating C++ code

   [Conversion Script] ..> [JModelica]: parses\nAST
   [Simulator Interface] ..> [JModelica] : runs simulation,\nreads outputs
   [HVAC Systems Editor] ..> [Modelica Library AST]: reads AST
   [Modelica Library AST] <.. [Conversion Script] : generates\nAST
   [JModelica] --> [Modelica\nBuildings Library]: imports
   }
   [Application] ..> () API : uses

   [JModelica] --> [User-Provided\nModelica Library]: imports

   note left of [Schematic Editor]
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
     Not yet shown is how
     to integrate building
     model
   end note

   note right of Application
     Application that uses
     the OpenStudio SDK.
   end note

**fixme: more design to be added**
