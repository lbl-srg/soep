.. _sec_soft_arch:

Software Architecture
---------------------

OpenStudio integration
^^^^^^^^^^^^^^^^^^^^^^


:numref:`fig_overall_software_architecture_one_editor`
shows the overall
software architecture of SOEP.

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
Our integration will generate a representation of the
Modelica library that allows OpenStudio to
dynamic load models for the SOEP mode.
Note that the JModelica distribution includes a C++ compiler.

.. note::

   #. Whether the `Conversion Script` and the `Schematic Editor`
      access `JModelica` to get the AST, or whether they read
      the AST from `Modelica Library AST` does not affect
      the functionality, but it affects the architecture.
      In :numref:`fig_overall_software_architecture_two_editors`
      we show the architecture if the `Modelica Library AST` is parsed
      directly using JModelica rather than storing it in a file.


.. _fig_overall_software_architecture_one_editor:

.. uml::
   :caption: Overall software architecture.

   title Overall software architecture

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

   package SOEP {
   [HVAC Systems Editor\n(SOEP Mode)] ..> [JModelica] : parses\nAST
   [SOEP\nModel Library] <.. [Conversion Script]: augments library\nby generating C++ code

   [Conversion Script] ..> [JModelica]: parses\nAST
   [SOEP\nSimulator Interface] ..> [JModelica] : writes inputs,\nruns simulation,\nreads outputs
   database "Modelica\nLibrary AST" as mod_AST
   mod_AST <- [Conversion Script] : generates
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

   EnergyPlus <.. [EnergyPlus\nSimulator Interface]: writes inputs,\nruns simulation,\nreads outputs
   package EnergyPlus {
     [in.idf] -> [EnergyPlus.exe]
     [EnergyPlus.exe] -> [eplusout.sql]
   }

   note left of mod_AST
     Used as an intermediate format and
     to verify incompatible changes.
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

   note right of Application
     Application that uses
     the OpenStudio SDK.
   end note




**fixme: more design to be added**

.. include:: automatedDocAstTool.rst

JModelica Integration
^^^^^^^^^^^^^^^^^^^^^

This section describes the integration of the QSS solver in JModelica.
For this discussion, we consider a system of initial value ODEs of the form

.. math::
   :label: eqn_ini_val

   \dot x(t) & = f(x(t), d(t), u(t), t), \\
   y(t)      & = g(x(t), u(t), t), \\
   0         & = z(x(t), u(t), t, d(t)), \\
   x(0)      & = x_0,

where :math:`x(\cdot)` is the vector of continuous state variables,
:math:`d(\cdot)` is a discrete variable,
:math:`u(\cdot)` is an external input,
:math:`f(\cdot, \cdot, \cdot, \cdot)` is the derivative function,
:math:`g(\cdot, \cdot, \cdot, \cdot)` is the output function,
:math:`z(\cdot, \cdot, \cdot)` is the event indicator function (sometimes called zero crossing function) and
:math:`d(t)` is a discrete state. For example, for a thermostat,
:math:`d(t) \in \{0, \, 1\}` depending on the controlled temperature.

Because we anticipate that the FMU can have
direct feed-through from the input
:math:`u(t)` to the output :math:`y(t)`, we use
FMI for Model-Exchange (FMI-ME) version 2.0, because the Co-Simulation
standard does not allow a zero time step size as needed for direct feed-through.


The QSS solvers require the derivatives shown in :numref:`tab_qss_der`.

.. _tab_qss_der:

.. table:: Derivatives required by QSS algorithms. One asteriks indicates
           that they are provided by FMI-ME 2.0, and two asteriks indicate
           that they can optionally be computed exactly if directional
           derivative are provided by the FMU.
           The others cannot be provided through the FMI API.


   +-------------+-----------------------------------------------------------+-----------------------------------------------------+
   | Type of QSS | State derivative                                          | Event indicator function derivative                 |
   +=============+===========================================================+=====================================================+
   | QSS1        | :math:`dx/dt` *                                           | :math:`dz/dt`                                       |
   +-------------+-----------------------------------------------------------+-----------------------------------------------------+
   | QSS2        | :math:`dx/dt` * , :math:`d^2x/dt^2` **                    | :math:`dz/dt` , :math:`d^2z/dt^2`                   |
   +-------------+-----------------------------------------------------------+-----------------------------------------------------+
   | QSS3        | :math:`dx/dt` * , :math:`d^2x/dt^2` ** , :math:`d^3x/dt^3`| :math:`dz/dt` , :math:`d^2z/dt^2`, :math:`d^3z/dt^3`|
   +-------------+-----------------------------------------------------------+-----------------------------------------------------+

Because the FMI API does not provide access to the required derivatives,
we discuss two proposals that are needed for an efficient implementation of QSS.
The first proposal requires an extension of the FMI specification whereas the second
proposal requires a modification of the specification as well as a refactoring
of Modelica models or a customization of the JModelica code generator. Both proposals
are discussed in the next sections.

Proposal of LBNL
~~~~~~~~~~~~~~~~

QSS generally requires to only update a subset of the state vector. We therefore
introduce the following function:

.. code-block:: c

  fmi2Status fmi2SetSpecificContinuousStates(fmi2Component c,
                                             const fmi2Real x[],
                                             const fmi2ValueReference vr[],
                                             size_t nx);

This function is similar to ``fmi2SetContinuousStates()``. However, it takes
as additional arguments

 * the value references ``vr`` of the state variables that need to be updated, and
 * the length ``nx`` of the state vector ``x``.

Similar to ``fmi2SetContinuousStates()``, this function should re-initialize caching
of all variables which depend on the *updated* states.

.. note::

  The currently implemented function ``fmi2SetContinuousStates()`` forces to update
  the entire state vector. This re-initializes ``caching`` of all variables
  which depend on the state variables. This is inefficient for QSS solvers.

To retrieve individual state derivatives, we introduce the following extensions
to the ``modelDescription.xml`` file. [In the code below, ``ScalarVariables``
is given to provide context, it remains unchanged from the FMI 2.0 standard.]

.. code-block:: xml

          <ScalarVariables>
            ...
            <ScalarVariable name="x1",      ...> ... </ScalarVariable> <!—- index="5" -->
            ...
            <ScalarVariable name="der(x1)", ...> ... </ScalarVariable> <!-— index="8" -->
           </ScalarVariables>

          <Derivatives>
            <!-- The ScalarVariable with index 8 is der(x) -->
            <Unknown     index="8" dependencies="6" />
            <HigherOrder index="5" order="2" value_reference="124" /> <!-- This is d^2 x/dt^2 -->
            <HigherOrder index="5" order="3" value_reference="125" /> <!-- This is d^3 x/dt^3 -->
          </Derivatives>

For efficiency, QSS requires to know what states trigger
which element of the event indicator function. Also, it will need to
have access to, or else approximate numerically, the time derivatives of the
event indicators. FMI 2.0 outputs an array of real-valued event indicators,
but no variable dependencies.
Therefore, we introduce the following xml section, which assumes we have
three event indicator functions.

.. code-block:: xml

          <ModelStructure>
            <EventIndicators>
              <!-- This is z[0] which depends on ScalarVariable with index 2 and 3 -->
              <Element index="1" order="0" dependencies="2 3" value_reference="200" />
              <!-- This is z[1] which declares no dependencies, hence it may depend on everything -->
              <Element index="2" order="0" value_reference="201" />
               <!-- This is z[2] which declares that it depends only on time -->
              <Element index="3" order="0" dependencies="" value_reference="202" />

              <!-- With order > 0, higher order derivatives can be specified. -->
              <!-- This is dz[0]/dt whch depends on scalar variable 2 -->
              <Element index="1" order="1" dependencies="2" value_reference="210" />
            </EventIndicators>
          </ModelStructure>



:numref:`fig_sof_arc_qss_jmod2` shows the software architecture
with the extended FMI API.
For simplicity the figure only
shows single FMUs, but we anticipated having multiple interconnected FMUs.

.. _fig_sof_arc_qss_jmod2:

.. uml::
   :caption: Software architecture for QSS integration with JModelica
             with extended FMI API.

   title Software architecture for QSS integration with JModelica with extended FMI API

   skinparam componentStyle uml2

   package FMU-ME {
     [QSS solver] as qss_sol
     [FMU-ME] as FMU_QSS
   }

   package PyFMI {
   [Master algorithm] -> qss_sol : "inputs, time"
   [Master algorithm] <- qss_sol : "next event time, states"
   [Master algorithm] -- [Sundials]
   }

   [Sundials] --> [FMU-ME] : "(x, t)"
   [Sundials] <-- [FMU-ME] : "dx/dt"
   [Master algorithm] --> [FMU-CS] : "hRequested"
   [Master algorithm] <-- [FMU-CS] : "(x, hMax)"

   package Optimica {
   [JModelica compiler] as jmc
   }

   jmc --> FMU_QSS

   FMU_QSS --> qss_sol : "derivatives"
   qss_sol --> FMU_QSS : "inputs, time, states"


.. note::

   We still need to design how to handle algebraic loops inside the FMU
   (see also Cellier's and Kofman's book) and algebraic loops that
   cross multiple FMUs.


To avoid having to change the FMI specification,
Modelon proposes an alternative approach which is 
discussed in the next sections.

Proposal of Modelon
~~~~~~~~~~~~~~~~~~~

**Use the fmi2SetReal() to set continuous states**:

In this approach, we use ``fmi2SetReal()`` to set individual state variable.
This approach requires a modification of the FMI standard
and is equivalent to ``fmi2SetSpecificContinuousStates()``.

**Add Time as a state variable**:

JModelica provides directional derivatives.
If ``Time`` is added as a state variable, then the directional 
derivatives will allow to get second derivative of states
with respect to time.

This approach has following drawbacks:

  * It can not be used to get higher order derivatives (e.g. 3rd derivative) with a single FMU call.
  * For QSS solvers, ``Time`` will need to be a hidden state 
    so they do not mistakenly integrate it.

**Add event indicators and first derivative of event indicators as output variables**:

To achieve the proposed solution we see two implementation options

*Option 1*

The Modelica modeler has to a) explicitely model the event indicator function
with its derivative in the Modelica model, b) add two output variables, 
one for the event indicator and one for its derivative, 
and c) annotate the variables so the master knows how they should be used.
This is illustrated in the example below.

Given a model such as  

.. code-block:: modelica

   model Test
     Real x;
   equation 
     if (x > 2) then
       der(x) = 1;
     else
       der(x) = 3;
     end if;
   end Test;

The modeler has to extend the model to 
include two new variables ``z`` and ``der_z``
for the event indicator function and its derivative.
``z`` will be computed as :math:`z = x - 2`,
and ``der_z`` will be the first derivative of ``z``
with respect to time.

The refactored model will be 

.. code-block:: modelica

   model Test
     Real x;
     Modelica.Blocks.Interfaces.RealOutput z 
       annotation(JModelica(z="Zero crossing")); 
     Modelica.Blocks.Interfaces.RealOutput der_z 
       annotation(JModelica(der_z="First derivative of zero crossing"));
   equation 
     z = x - 2;
     der_z = der (z);
     if (x > 2) then
       der(x) = 1;
     else
       der(x) = 3;
     end if;
   end Test;

A major drawback of this approach is that the modeler will need to 
make sure that it implements all event indicator functions.
The modeler will also need to implement the derivatives of
the event indicator functions. This is error prone, unpracticable,
and will need additional variables/equations for higher order QSS such 
as Qss3.

*Option 2*

An alternative approach is to let the JModelica
compiler expands the Modelica model or the code generated
by the compiler to a) include these additional variables/
equations, and b) make them available in the XML file of the FMU.

The drawback here is that this approach will
have to be implemented in any Modelica compiler
which needs to support the QSS libraries.
Since we are not in control of Modelica tool vendors, 
we can not predict whether this approach will be 
widely adopted.

If the proposal of Modelon is accepted, then we recommend to implement Option 2.

.. note::

   In both cases, a challenge arises 
   if the event indicator function depends on the 
   inputs of the model. In which case without further modification
   of the model, the event indicator will not be able 
   to be differentiated. This is illustrated in the next example.

Given our slighly modified previous model where the event indicator 
is a function of the input u 

.. code-block:: modelica

  model Test
    Real x;
    Modelica.Blocks.Interfaces.RealInput u; 
  equation 
    if (x > u) then
      der(x) = 1;
    else
      der(x) = 3;
    end if;
  end Test;

The refactored model will be 

.. code-block:: modelica

  model Test
    Real x;
    Modelica.Blocks.Interfaces.RealInput u;
    Modelica.Blocks.Interfaces.RealOutput z 
      annotation(JModelica(z="Zero crossing")); 
    Modelica.Blocks.Interfaces.RealOutput der_z 
      annotation(JModelica(der_z="First derivative of zero crossing"));
  equation 
    z = x - u;
    der_z = der( x-u);
    if (x > u) then
      der(x) = 1;
    else
      der(x) = 3;
    end if;
  end Test;

This model will not compile unless we introduce a new variable ``du_dt`` which
is the derivative of the input with respect to time.
This variable will be used to calculate the expression ``der_z``.
The modeler will either have to introduce such a variable or 
the JModelica compiler will have to address this at compilation time.






