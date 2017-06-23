.. _sec_soft_arch:

Software Architecture
---------------------

OpenStudio integration
^^^^^^^^^^^^^^^^^^^^^^


:numref:`fig_overall_software_architecture`
shows the overall software architecture of SOEP.

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


.. _fig_overall_software_architecture:

.. uml::
   :caption: Overall software architecture.

   title Overall software architecture

   scale max 1024 width

   skinparam componentStyle uml2

   package OpenStudio {
   interface API
   API - [Core]

   package Legacy-Mode {
   database "Legacy\nModel Library"
   [Core] -> [Legacy\nModel Library]: integrates
   [Core] -> [HVAC Systems Editor\n(Legacy Mode)]: integrates
   [Core] -> [EnergyPlus\nSimulator Interface]: integrates
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

   [Conversion Script] .> [JModelica]: parses\nAST
   [SOEP\nSimulator Interface] .> [JModelica] : writes inputs,\nruns simulation,\nreads outputs
   database "Modelica\nLibrary AST" as mod_AST
   [Conversion Script] -> mod_AST: generates
   database "Modelica\nBuildings Library"
   [JModelica] -> [Modelica\nBuildings Library]: imports
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
     [EnergyPlus.exe]
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
we discuss below two proposals that are needed for an efficient implementation of QSS.

.. The first proposal requires an extension of the FMI specification whereas the second
   proposal requires a modification of the specification as well as a refactoring
   of Modelica models or a customization of the JModelica code generator.
   Both proposals are discussed in the next sections.

Proposal of LBNL
~~~~~~~~~~~~~~~~

QSS generally requires to only update a subset of the state vector. We therefore
propose to use the function

.. code-block:: c

  fmi2Status fmi2SetReal(fmi2Component c,
                         const fmi2Real x[],
                         const fmi2ValueReference vr[],
                         size_t nx);

This function exists in FMI-ME 2.0, but the standard only allows to call it for
state variables during the initialization.

We therefore propose that the standard is being changed as follows:

 * ``fmi2SetReal`` can be called during the continuous time mode
   and during event mode not only for inputs,
   as is allowed in FMI-ME 2.0, but also for continuous time and discrete states.
 * ``fmi2SetReal`` shall re-initialize caching
   of all variables which depend on the arguments of the function.

.. note:: Calling ``fmi2SetReal`` for discrete states is needed if an FMU-ME
          contains the QSS solver, in which cases it exposes discrete states.
          Because discrete states can only be changed during event mode,
          it must be allowed to call ``fmi2SetReal`` during event mode.

To retrieve individual state derivatives, we introduce the following extensions
to the ``modelDescription.xml`` file. [In the code below, ``ScalarVariables``
is given to provide context, it remains unchanged from the FMI 2.0 standard.]

.. code::

          <ScalarVariables>
            ...
            <ScalarVariable name="x1",      ...> ... </ScalarVariable> <!-- index="5" -->
            ...
            <ScalarVariable name="der(x1)", ...> ... </ScalarVariable> <!-- index="8" -->
           </ScalarVariables>

          <Derivatives>
            <!-- The ScalarVariable with index 8 is der(x) -->
            <Unknown     index="8" dependencies="6" />
            <HigherOrder index="5" order="2" value_reference="124" /> <!-- This is d^2 x/dt^2 -->
            <HigherOrder index="5" order="3" value_reference="125" /> <!-- This is d^3 x/dt^3 -->
          </Derivatives>

Events Handling
"""""""""""""""

.. _subsec_se:

State Events
<<<<<<<<<<<<

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
              <!-- This is dz[0]/dt which depends on scalar variable 2 -->
              <Element index="1" order="1" dependencies="2" value_reference="210" />
            </EventIndicators>
          </ModelStructure>


For efficiency, FMUs need to expose variables which depend on event indicators
in the model description file. We call these variables **event indicator handler**.
The rationale is illustrated in the following model

.. code-block:: modelica

    model StateEvent1
      Real x(start=1.1, fixed=true);
      discrete Real y;
    equation
      der(x) = cos(2*3.14*time/2.5);
      when (x > 1) then
        y = 1;
      elsewhen (x <= 1) then
        y = 0;
      end when;
    end StateEvent1;

This model has one implicit event indicator ``z``  which equals ``x-1``.

For QSS, the FMU which exports this model must declare
in the model description file that the event indicator handler ``y``
depends on the event indicator variable ``z``. This is needed so ``y``
can be updated when a state event happens.

Therefore we require that all variables which depend
on event indicator variables are listed in the
model description file with their dependencies information.

We propose to introduce the following xml section which lists these variables.

.. code-block:: xml

          <ModelStructure>
            <EventIndicatorHandlers>
              <!-- This is variable with index 9 which depends on
                   event indicator variables with index 1 and 2 -->
              <Unknown index="9" dependencies="1 2" value_reference="300" />
            </EventIndicatorHandlers>
          </ModelStructure>


For efficiency, FMUs need to add additional variables to
dependencies list of state variables.
This is illustrated with the following model

.. code-block:: modelica

  model StateEvent4
    Real x(start=0.0, fixed=true);
    discrete Real y(start=0.0, fixed=true);
  equation
    der(x) = y + 1;
    when (x > 0.5) then
      y = -1.0;
    end when;
  end StateEvent4;

QSS requires the FMU which exports this model to declare in its model description file
the dependency of ``der(x)`` on ``y``. This allows ``der(x)`` to update when ``y`` changes.
This information should be encoded in the ``dependencies`` attribute of ``der(x)``.
However, FMI states on page 61 that ``dependencies`` are optional attribute
defining the dependencies of the unknown (directly or indirectly via auxiliary variables)
with respect to known.
For state derivatives and outputs, known variables are

- inputs (variables with causality = "input")
- continuous-time states
- independent variable (usually time; causality = "independent")

Since ``y`` does not fuflill any of the above requirements,
it is not allowed to show up in the ``dependencies`` list of ``der(x)``.

Therefore, we require the FMU to expose in the model description file
the dependency for any variable (discrete or continuous) modified by
a zero crossing condition. That is, for the ``StateEvent4`` example, variable ``y``
should appear in the dependencies list of ``der(x)``.

Time Events
<<<<<<<<<<<<

The next section discusses additional requirements for handling time events with QSS.

Consider the following model

.. code-block:: modelica

  model TimeEvent
    Real x(start=0.0, fixed=true);
    Real y;
  equation
    der(x) = y + 1;
    if (time >= 2.0) then
      y = -x + time;
    else
      y = -x - time;
    end if;
  end TimeEvent;

Similar to the case with ``StateEvent4``, QSS requires the FMU which exports
this model to declare in its model description file the dependency of
``der(x)`` on ``y``.
This is addressed by the requirement proposed for  ``StateEvent4``.

Furthermore, QSS needs to know that ``y`` needs to be updated
when a time event happens. It also needs to know the dependent variables of ``y``
so it can update them especially if they are are continuous state variables.

We therefore propose to add time event handlers along with their dependencies
to the ``EventIndicatorHandlers`` introduced in :ref:`subsec_se`.

.. note::

  How do we distinguish between time event handler, and state event handler?
  Should we have an attribute (``se`` for state event and ``te`` for time event to distinguish them?).

  QSS needs to know the exact handler which will be trigger when there is a time event.
  The ordering of the time event handler could be used to return the index of the
  time event handler which is to be updated. I added this to the optimization Measures section.


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
   [Master algorithm] - [Sundials]
   }

   [Sundials] -> [FMU-ME] : "(x, t)"
   [Sundials] <- [FMU-ME] : "dx/dt"
   [Master algorithm] -> [FMU-CS] : "hRequested"
   [Master algorithm] <- [FMU-CS] : "(x, hMax)"

   package Optimica {
   [JModelica compiler] as jmc
   }

   jmc -> FMU_QSS

   FMU_QSS -down-> qss_sol : "derivatives"
   qss_sol -down-> FMU_QSS : "inputs, time, states"


.. note::

   We still need to design how to handle algebraic loops inside the FMU
   (see also Cellier's and Kofman's book) and algebraic loops that
   cross multiple FMUs.


To avoid having to change the FMI specification,
Modelon proposes an alternative approach which is
discussed in the next sections.

Proposal of Modelon
~~~~~~~~~~~~~~~~~~~

Modelon proposes to allow setting ``fmi2SetReal()`` on continuous states (as
we do above), adding ``Time`` as a state (which we believe is not needed)
and adding event indicators and first derivative of event indicators as output variables.

Below we summarize and comment on these three changes.

**Use the fmi2SetReal() to set continuous states**:

It shall be allowed to call ``fmi2SetReal()`` for individual state variables.
This approach requires a modification of the FMI standard,
and is identical with our proposed change above.


**Add Time as a state variable**:

JModelica provides directional derivatives.
If ``Time`` (used with capital ``T`` as ``time`` is a reserved Modelica keyword)
is added as a state variable, then the directional
derivatives will allow to get second derivative of states
with respect to time.

This approach has following drawbacks:

  * It can not be used to get higher order derivatives (e.g. 3rd derivative) with a single FMU call.
  * QSS solvers need to know that they need not integrate the state called ``Time``.
    This probably needs a new attribute in the ``modelDescription.xml`` file.

.. note::

  The FMI specification says on page 26 that If a variable with
  ``causality= "independent"`` is explicitely defined under
  ScalarVariables, a directional derivative with
  respect to this variable can be computed.
  Hence if ``Time`` has ``causality= "independent"``,
  then the directional derivative of the derivative function
  with respect to time (second derivative of the state) can be computed.
  Therefore, LBNL sees no reason to add ``Time`` as a state variable.


**Add event indicators and first derivative of event indicators as output variables**:

To get access to the event indicator functions and their derivatives,
the JModelica
compiler would need to introduce additional variables and
make them available in the ``modelDescription.xml`` file.

For example, consider

.. code-block:: modelica

    model StateEvent2
      Real x(start=1.1, fixed=true);
      discrete Real y(start=0.0, fixed=true);
    equation
      der(x) = cos(2*3.14*time/2.5);
      when (x > 1) then
        y = 1;
      elsewhen (x <= 1) then
        y = 0;
      end when;
    end StateEvent2;

For such a model, JModelica would

 1. need to add an equation of the form
    ``z = x - 1`` and ``der_z = der(x)``,
 2. expose ``z`` and ``der_z`` as output variables, and
 3. annotate in ``modelDescription.xml`` that

      a. ``z`` is an event indicators and
      b. ``der_z`` is its derivative

    [in order for QSS to schedule an event at zero crossing, rather than simply integrating it].


Event indicators that depend on the input
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A challenge arises if the event indicator function depends on the
inputs of the model. Consider

.. code-block:: modelica

   model StateEvent3
    input Real u;
    output Real y;
   equation
     if (u > 0) then
       y = 1;
     else
       y = 0;
     end if;
   end StateEvent3;

Then, ``z = u`` and ``der_z = der(u)``. Hence,
it is not possible to create an FMU of this model unless an additional
input ``der_u`` is added, which needs to be set by the master to be equal to
:math:`du/dt`.

Workaround for implementing event indicators
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While waiting for the implementation of one of the two proposals,
LBNL will refactor some Modelica models to expose event indicators and derivatives as FMU output variables.

The names of event indicators variables will start with ``__zc_``. The names of derivatives of event
indicators will start with ``__zc_der_``.  As an example, ``__zc_z1`` and ``__zc_der_z1``
are the names of the event indicator ``z1`` with its derivative ``der_z1``.

If the number of event indicators variables matches the ``numberOfEventIndicators`` attribute,
then only __zc_ and __zc_der_ need to be used by QSS,
If the number of event indicators does not match, the FMU need to be rejected with an error message.

.. note::

  Per design, Dymola (2017 FD01) generates twice as many event indicators as actually existing in the model.
  Hence the master algorithm needs to detect if the tool which exported the FMU is Dymola
  to adapt the check on the number of event indicators variables.

QSS Optimization Measures
~~~~~~~~~~~~~~~~~~~~~~~~~

This section lists a number of measures which should improve the performance of QSS.
These measure will be investigated, prioritized, and implemented in SOEP.

Consider the following model,

.. code-block:: modelica

    model StateEvent5
      Real x(start=1.1, fixed=true);
      discrete Real y(start=0.0, fixed=true);
    equation
      der(x) = cos(2*3.14*time/2.5);
    when (x > 1) then
      y = 1;
    elsewhen (x > -2) then
      y = 2;
    elsewhen (x > 5) then
      y = 0;
    reinit(x, 3);
    end when;
    end StateEvent5;

which has three implicit event indicators ``z1 =x-1``,
``z2 =x+1``, ``z3 =x-5``.

For QSS efficiency, the FMI specification should provide an API which allows to
trigger the update of ``y`` when its event indicator dependent variable change.
This will remove the need of calling ``fmi2EnterEventMode()`` and ``fmi2NewDiscreteStates()``,
and ensure that ``y`` is updated when a state event happens.

Furthermore, the FMU must declare in the XML the priority sequence of the event indicators
which is dicated in the Modelica model by the priority of ``when``/``elsewhen``.
This is required to trigger the computation of the "right" ``y`` when a state event happens.
This could be done by requiring the index of the EventIndicators to be the order of the priority sequence.

For efficiency, QSS needs to know the time event handler which will be trigger when there is a time event.
The ordering of the time event handler in the EventIndicatorhandlers could be used to return the index of the
time event handler which is to be updated.

The ``EventIndicatorHandlers`` will need to have a list
of event indicators handlers for state events followed by a list
with event indicator handlers for time events.
