.. _sec_soft_arch:

Software Architecture
---------------------

:numref:`fig_overall_software_architecture` shows the overall
software architecture of SOEP.
The figure indicates an application which may be an
equipment sales tool that uses an open, or a proprietary,
Modelica model library of their product line, which allows
a sales person to test and size equipment for a particular customer.

.. _fig_overall_software_architecture:

.. uml::
   :caption: Overall software architecture.

   title Overall software architecture

   skinparam componentStyle uml2

   package SOEP {
   package OpenStudio {
   API -- [Core]
   [Core] --> [Model Library]: integrates
   [Core] --> [Schematic Editor]: integrates
   [Core] --> [Simulator Interface]: integrates
   }

   [Model Library] <.. [Conversion Script]: augments library

   [Conversion Script] ..> [Modelica Library]: parses AST
   [Simulator Interface] ..> [JModelica]
   [Schematic Editor] ..> [JModelica]: accesses AST
   [JModelica] --> [Modelica Buildings Library]: imports
   }
   [Application] ..> () API : uses

   [JModelica] --> [User-Provided Modelica Library]: imports
   [Conversion Script] ..> [User-Provided Modelica Library]: parses AST

   note bottom of [User-Provided Modelica Library]
     Allows companies to use
     their own Modelica libraries
     with custom HVAC systems and
     control sequences, or
     to integrate an electronic
     equipment catalog or a
     library used for an equipment
     sales tool.
   end note

   note right of OpenStudio
     Not yet shown is how
     to integrate building
     model
   end note

   note right of Application
     Application that uses
     the OpenStudio SDK.
   end note

**fixme: more design to be added**
