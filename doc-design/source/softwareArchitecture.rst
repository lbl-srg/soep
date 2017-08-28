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

   [\dot x_c(t), x_d(t)] & = f(x_c(t), x_d(t^-), u_c(t), u_d(t), p, t),

   [y_c(t), y_d(t)] & = g(x_c(t), x_d(t), u_c(t), u_d(t), p, t),\\

   0         & = z(x_c(t), x_d(t), u_c(t), u_d(t), p, t),\\

   [x_c(t_0), x_d(t_0)] & = [x_{c,0}, x_{d,0}],

where
:math:`x(\cdot)` is the continuous-time state vector, with superscript
:math:`c` denoting continuous-time states and :math:`d` denoting discrete variables or states,
:math:`u(\cdot)` is the external input,
:math:`p` are parameters,
:math:`f(\cdot, \cdot, \cdot, \cdot, \cdot, \cdot)` is the state transitions function,
:math:`g(\cdot, \cdot, \cdot, \cdot, \cdot, \cdot)` is the output function,
:math:`z(\cdot, \cdot, \cdot, \cdot, \cdot, \cdot)` is the event indicator function (sometimes called zero crossing function).

Because we anticipate that the FMU can have
direct feed-through from the input
:math:`u(t)` to the output :math:`y(t)`, we use
FMI for Model-Exchange (FMI-ME) version 2.0, because the Co-Simulation
standard does not allow a zero time step size as needed for direct feed-through.


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


The QSS solvers require the derivatives shown in :numref:`tab_qss_der`.

.. _tab_qss_der:

.. table:: Derivatives required by QSS algorithms. One asteriks indicates
           that they are provided by FMI-ME 2.0, and two asteriks indicate
           that they can optionally be computed exactly if directional
           derivatives are provided by the FMU.
           The others cannot be provided through the FMI API.


   +-------------+-----------------------------------------------------------------+-----------------------------------------------------+
   | Type of QSS | Continuous-time state derivative                                | Event indicator function derivative                 |
   +=============+=================================================================+=====================================================+
   | QSS1        | :math:`dx_c/dt` *                                               | :math:`dz/dt`                                       |
   +-------------+-----------------------------------------------------------------+-----------------------------------------------------+
   | QSS2        | :math:`dx_c/dt` * , :math:`d^2x_c/dt^2` **                      | :math:`dz/dt` , :math:`d^2z/dt^2`                   |
   +-------------+-----------------------------------------------------------------+-----------------------------------------------------+
   | QSS3        | :math:`dx_c/dt` * , :math:`d^2x_c/dt^2` ** , :math:`d^3x_c/dt^3`| :math:`dz/dt` , :math:`d^2z/dt^2`, :math:`d^3z/dt^3`|
   +-------------+-----------------------------------------------------------------+-----------------------------------------------------+

Because the FMI API does not provide access to the required derivatives,
we discuss below two proposals that are needed for an efficient implementation of QSS.

.. The first proposal requires an extension of the FMI specification whereas the second
   proposal requires a modification of the specification as well as a refactoring
   of Modelica models or a customization of the JModelica code generator.
   Both proposals are discussed in the next sections.

Proposal of LBNL
~~~~~~~~~~~~~~~~

QSS generally requires to only update a subset of the continuous-time state vector. We therefore
propose to use the function

.. code-block:: c

  fmi2Status fmi2SetReal(fmi2Component c,
                         const fmi2Real x[],
                         const fmi2ValueReference vr[],
                         size_t nx);

This function exists in FMI-ME 2.0, but the standard only allows to call it for
continuous-time state variables during the initialization.

We therefore propose that the standard is being changed as follows:

   ``fmi2SetReal`` can be called during the continuous time mode
   and during event mode not only for inputs,
   as is allowed in FMI-ME 2.0, but also for continuous-time states and discrete output variables.

.. note:: Calling ``fmi2SetReal`` for discrete output variables is needed if an FMU-ME
          contains the QSS solver, in which cases it exposes the quantized states as
          discrete output variables.

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

Event Handling
""""""""""""""

.. _subsec_se:

State Events
............

For efficiency, QSS requires to know what states trigger
which element of the event indicator function. Also, it will need to
have access to, or else approximate numerically, the time derivatives of the
event indicator. FMI 2.0 outputs an array of real-valued event indicators,
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

.. note::

   The ``index`` uses in the ``<EventIndicators>`` element is different from the ``index``
   used in the ``<ModelVariables>`` element. The first event indicator has an ``index`` 1,
   the second has an ``index`` 2, and so on.

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

This model has one event indicator function :math:`z=x-1`.

For QSS, the FMU which exports this model must declare
in the model description file that the event indicator handler ``y``
depends on the event indicator function ``z``. This is needed so ``y``
can be updated when a state event happens.

Therefore we require that all variables which depend
on event indicator variables are listed in the
model description file with their dependencies information.

We propose to introduce the following xml section which lists these variables.

.. code-block:: xml

          <ModelStructure>
            <EventIndicatorHandlers>
              <!-- This is variable with index 9 in the ModelVariables section
                   which depends on event indicator variables with index 1 and 2.
                   The event_type is a list which specifies the type of event.
                   event_type can be "state" for state event, "time", for time event,
                   "step" for step event, or any combination of the three (e.g. "time state"
                   indicates that the event indicator handler is for both time and state event) -->
              <Unknown index="9" dependencies="1 2" value_reference="300" event_type="state" />
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
However, FMI states on page 61 that ``dependencies`` are optional attributes
defining the dependencies of the unknown (directly or indirectly via auxiliary variables)
with respect to known.
For state derivatives and outputs, known variables are

- inputs (variables with causality = "input")
- continuous-time states
- independent variable (usually time; causality = "independent")

Since ``y`` does not fulfill any of the above requirements,
it is not allowed to show up in the ``dependencies`` list of ``der(x)``.
Therefore, we require the FMU to declare in the model description file
the dependency for all event indicator handlers.
That is, for the ``StateEvent4`` example, variable ``y``
should appear in the dependencies list of ``der(x)``.

.. _subsec_te:

Time Events
...........

This section discusses additional requirements for handling time events with QSS.

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
when :math:`t \ge 2`. It also needs to know what variables depend on ``y``
so it can update them.

We therefore propose to add time event handlers along with their dependencies
to the ``EventIndicatorHandlers`` introduced in :numref:`subsec_se`.


Events with boolean expressions
...............................

Further investigation is needed to understand how JModelica deals
with zero crossing functions which have boolean expressions such as

.. code-block:: modelica

  model ZCBoolean
    "This model tests state event detection with boolean zero crossing"
    extends Modelica.Icons.Example;
    Real x(start=1, fixed=true);
    Real u "Internal input signal";
    Boolean yBoo "Boolean variable";
    discrete Modelica.Blocks.Interfaces.RealOutput y(start=1.0, fixed=true);
  initial equation
    pre(yBoo) = true;
  equation
    u = Modelica.Math.sin(time);
    der(x) = y;
    when (pre(yBoo) and u >= 0.5) then
      y = 1.0;
      yBoo = false;
    elsewhen (not pre(yBoo) and u <= -0.5) then
      y = 1.0;
      yBoo = true;
    end when;
  end ZCBoolean;

Does JModelica generate two zero crossing functions which represent the
conditionals?

SmoothToken for QSS
"""""""""""""""""""

This section discusses a proposal for a new data type which should be used for input and output variables of FMU-QSS.
FMU-QSS is an FMU for Model Exchange (FMU-ME) which uses QSS to integrate an imported FMU-ME.
We propose that FMU-QSS communicates with other FMUs using a SmoothToken data type.

A smooth token is a time-stamped event that has a real value (approximated as a ``double``)
that represents the current sample of a real-valued smooth signal. But in addition to the sample value,
the smooth token contains zero or more time-derivatives of the signal at the stored time stamp.
For example, in the figure below, FMU-ME has a real input :math:`u` and a real output :math:`y`.
A smooth token of the input variable will be a variable :math:`u^* \triangleq [u, n, du/dt, ...,  d^n u/dt^n, t_u]`,
where :math:`n \in \{0, 1, 2, \ldots \}` is a parameter that defines the number of time derivatives that are present in the smooth token and
:math:`t_u` is the timestamp of the smooth token.
If :math:`u^*` has a discontinuity at :math:`t_u`,
then the derivatives are the derivatives from above, e.g., :math:`du/dt \triangleq \lim_{s \downarrow 0} (u(t_u+s)-u(t_u))/s`.

At simulation time :math:`t`, FMU-QSS will receive :math:`u^*` and convert it to a real signal
using the Taylor expansion

.. math::

   y_s(t) = \frac{u^{(n)}(t_u)}{n!} \, (t-t_u)^n,

where :math:`u^{(n)}` denotes the :math:`n`-th derivative. As shown in :numref:`fig-fmu-qss`, the FMU-ME will receive
the value :math:`y_s(t)`.


.. _fig-fmu-qss:

.. figure:: img/fmu-qss.*
   :scale: 55 %

   Conversion of input signal between FMU-QSS and FMU-ME.

To avoid frequent changes in the input signal, each input signal will have a quantum defined.
The quantum :math:`\delta q` will be computed at runtime as

.. math::

    \delta q = \max(\epsilon_{rel} \, |u^-|, \epsilon_{abs}),

where :math:`\epsilon_{rel}` is the relative tolerance,
:math:`u^-` is the last value seen at the input of FMU-ME, and
:math:`\epsilon_{abs} \triangleq \epsilon_{rel} \, |u_{nom}|`,
where :math:`u_{nom}` is the nominal value of the variable :math:`u`.
During initialization, we set :math:`u^- = u_0`.
The input signal will be updated only if it has changed by more than a quantum,

.. math::

   |y_s(t) - u^-| \ge \delta q.


To support the smooth token data type, we propose to add following data type to the FMI specification

.. code::

    typedef struct {
      fmi2ValueReference vr;
      size_t n;
      fmi2Real value;
      fmi2Real derivatives[];
      fmi2Real t;
     } fmi2SmoothToken;

where
``vr`` is the value reference of the FMU-ME scalar variable for which a smooth token is constructed,
``n`` is is the number of time derivatives of a smooth signal,
``value`` is the sample of the smooth signal at time ``t``,
``derivatives`` are the time derivatives of the FMU-ME scalar variable (e.g. ``derivatives[0]`` is the first time derivative, ``derivatives[1]`` is the second time derivative) at the time ``t``,
and ``t`` is the time-stamp of the smooth token.

To set the value of a smooth token, we propose to add a new function ``fmi2SetSmoothToken`` defined as

.. code-block:: c

  fmi2Status fmi2SetSmoothToken(fmi2Component c,
                                const fmi2SmoothToken val);

where ``val`` is the value of the smooth token to be set.

To get the value of a smooth token, we propose to add a new function ``fmi2GetSmoothToken`` defined as

.. code-block:: c

  fmi2Status fmi2GetSmoothToken(fmi2Component c,
                                const fmi2ValueReference vr,
                                fmi2SmoothToken val);

where ``vr`` is the value reference of the FMU-ME variable to be retrieved, and ``val`` is its corresponding smooth token.

We will now propose an extension to the FMI specification to get time derivatives of outputs.
In the above section, we proposed to use ``fmi2SmoothToken`` for input and output variables of FMU-QSS.
Since ``fmi2SmoothToken`` can include derivatives information, we propose to extend the FMI specification to provide
a function which can be used to get derivatives of FMU-ME output variables which will be used as inputs
of other FMUs. These derivatives can be used to parametrize ``fmi2SmoothToken`` of the FMU input variables.
We propose to extend the FMI for ME API to include the function ``fmi2GetRealOutputDerivatives`` which exists
for the FMI for co-simulation API.

.. note::

   - If a tool can not provide the derivative of an output variable with respect to time,
     ``fmi2GetRealOutputDerivatives`` should return an error.
     In this case, a master algorithm could approximate the output derivative as follows:

     - If there was no event, then the time derivatives from below and above are equal, and
       hence past and current output values can be used, e.g.,

       .. math::

          dy/dt \approx \frac{y(t_k)-y(t_{k-1})}{t_k - t_{k-1}}.

     - If there was an event, then the derivative from above need to be approximated.
       This could be done by assuming first :math:`dy/dt =0` and then building up derivative
       information in the next step, or by evaluating the FMU for :math:`t=t_k+\epsilon`, where
       :math:`\epsilon` is a small number, and then computing

       .. math::

          dy/dt \approx \frac{y(t_k+\epsilon)-y(t_{k})}{\epsilon}.

   - For FMU-ME, if there is a direct feedthrough, e.g., :math:`y=f(u)`,
     then :math:`dy/dt` cannot be computed, because by the chain rule,

     .. math::

        \frac{df(u)}{dt} = \frac{df(u)}{du} \, \frac{du}{dt}

     but :math:`du/dt` is not available in the FMU.


Proposal of Modelon
~~~~~~~~~~~~~~~~~~~

To avoid having to change the FMI specification,
Modelon proposes an alternative approach which is
discussed in the next sections.


Modelon proposes to allow setting ``fmi2SetReal()`` on continuous states (as
we do above), adding ``Time`` as a state (which we believe is not needed),
and adding event indicators and first derivative of event indicators as output variables.

Below we summarize and comment on these three changes.

**Use the fmi2SetReal() to set continuous states**:

It shall be allowed to call ``fmi2SetReal()`` for individual state variables.
This approach requires a modification of the FMI standard,
and is identical with our proposed change above.

.. note::

    ``fmi2SetReal`` must be extended to be called during the continuous time mode
    and during event mode not only for inputs,
    as is allowed in FMI-ME 2.0, but also for discrete output variables.


**Add Time as a state variable**:

JModelica provides directional derivatives.
If ``Time`` (used with capital ``T`` as ``time`` is a reserved Modelica keyword)
is added as a state variable, then the directional
derivatives will allow to get second derivative of continuous states
with respect to time.

This approach has following drawbacks:

  * It can not be used to get higher order derivatives (e.g. 3rd derivative) with a single FMU call.
  * QSS solvers need to know that they need not integrate the state called ``Time``.
    This probably needs a new attribute in the ``modelDescription.xml`` file.

.. note::

  The FMI specification says on page 26 that If a variable with
  ``causality= "independent"`` is explicitely defined under
  ``ScalarVariables``, a directional derivative with
  respect to this variable can be computed.
  Hence if ``Time`` has ``causality= "independent"``,
  then the time derivative of the derivative function can be computed.
  Therefore, LBNL sees no reason to add ``Time`` as a state variable.


**Add event indicators and first derivative of event indicators as output variables**:

To get access to the event indicator functions and their derivatives,
the JModelica compiler would need to introduce additional variables and
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

.. note::

   This approach will work but will require to add additional equations
   and variables to the Modelica model, annotate the variables,
   include them in the XML with correct dependency information,
   and develop custom code to extract the annotated encoded information.
   LBNL hence believes that extending the XML file is the correct path to follow.

.. note::

  While developping the QSS solver, LBNL added additional requirements for the
  FMI specification (see :ref:`subsec_se` and :ref:`subsec_te` sections).
  These requirements haven't been reviewed by Modelon yet and
  hence do not not have any alternative proposal from Modelon.

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

If the number of event indicators functions is equal to the ``numberOfEventIndicators`` attribute,
then only ``__zc_`` and ``__zc_der_`` need to be used by QSS,
If the number of event indicators does not match, the FMU needs to be rejected with an error message.

.. note::

  Per design, Dymola (2017 FD01) generates twice as many event indicators as actually existing in the model.
  Hence the master algorithm needs to detect if the tool which exported the FMU is Dymola, and if it is, the
  number of event indicator functions must be equal to half the value of the ``numberOfEventIndicators`` attribute.


Open Topics
~~~~~~~~~~~

This section includes a list of measures which could further improve the efficiency of QSS.
Some of the measures should be implemented and benchmarks to ensure their necessity for QSS.

Atomic API
""""""""""

A fundamental property of QSS is that variables are advanced at different time rates. To make this practically efficient with FMUs an API for individual values and derivatives is essential.

XML/API
"""""""

All variables with non-constant values probably need to be exposed via the xml with all their interdependencies. The practicality and benefit of trying to hide some variables such as algebraic variables by short-circuiting their dependencies in the xml (or doing this short-circuiting on the QSS side) should be considered for efficiency reasons.
Higher Derivatives
Numerical differentiation significantly complicates and slows the QSS code: automatic differentiation provided by the FMU will be a major improvement and allow practical development of 3rd order QSS solvers.

Input Variables
"""""""""""""""

.. note::
   
   Stuart wrote "QSS probably needs input variables limited to deterministic, non-path-dependent functions since it needs to query their value at possibly forward and backward time steps around the current simulation time. Is this an issue in ME?"
  
   I (Thierry) think, this shouldn't be a problem for ME FMU.


Annotations
"""""""""""

Some per-variable annotations that will allow for more efficient solutions by overriding global settings (which are also needed as annotations) include:

- Various time steps: ``dt_min``, ``dt_max``, ``dt_inf``, …
- Various flags: QSS method/order (or traditional ODE method for mixed solutions), inflection point requantization, …
- Variable extra variability flags: constant, linear, quadratic, cubic, variable, …

Conditional Expressions and Zero Crossing Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""

- The xml needs to expose the structure of each conditional block: if or when, sequence order of if/when/else conditionals, and all the (continuous and discrete/boolean) variables appearing in each conditional.
- Non-input boolean/discrete/integer variables should ideally be altered only by zero-crossing handlers or “time events” that are exposed by the FMU (during loop or by direct query?). Are there other ways that such variables can change that are only detectable after the fact? If so, this leaves the QSS with the bad choices of late detection (due to large time steps) or forcing regular time step value checks on them.
- QSS needs non-input boolean/discrete/integer variable dependencies in both directions.
- QSS needs the dependencies of conditional expressions on variables appearing in them.
- QSS needs the dependencies of variables altered when each conditional fires on the conditional expression variables.
- It is not robust for the QSS to try and guess a time point where the FMU will reliably detect a zero crossing so we need an API to tell the FMU that a zero crossing occurred at a given time (and maybe with crossing direction information)
- If the xml can expose the zero crossing directions of interest that will allow for more efficiency.


