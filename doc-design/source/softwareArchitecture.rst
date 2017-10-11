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

We will first introduce terminology.
Consider the code-snippet

.. code-block:: modelica

   ...
   when (x > a) then
     ...
   end when;
   ...

We will say that :math:`z = a - x` is the *event indicator*.


For the discussion, we consider a system of initial value ODEs of the form

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
:math:`z(\cdot, \cdot, \cdot, \cdot, \cdot, \cdot)` is the event indicator (sometimes called zero crossing function).

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

   package FMU-QSS {
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
   | Type of QSS | Continuous-time state derivative                                | event indicator derivative                          |
   +=============+=================================================================+=====================================================+
   | QSS1        | :math:`dx_c/dt` *                                               | :math:`dz/dt`                                       |
   +-------------+-----------------------------------------------------------------+-----------------------------------------------------+
   | QSS2        | :math:`dx_c/dt` * , :math:`d^2x_c/dt^2` **                      | :math:`dz/dt` , :math:`d^2z/dt^2`                   |
   +-------------+-----------------------------------------------------------------+-----------------------------------------------------+
   | QSS3        | :math:`dx_c/dt` * , :math:`d^2x_c/dt^2` ** , :math:`d^3x_c/dt^3`| :math:`dz/dt` , :math:`d^2z/dt^2`, :math:`d^3z/dt^3`|
   +-------------+-----------------------------------------------------------------+-----------------------------------------------------+

Because the FMI API does not provide access to the required derivatives,
and FMI has limited support for QSS, we discuss extensions
that are needed for an efficient implementation of QSS.

FMI Changes for QSS
~~~~~~~~~~~~~~~~~~~

QSS generally requires to only update a subset of the continuous-time state vector. We therefore
propose to use the function

.. code-block:: c

  fmi2Status fmi2SetReal(fmi2Component c,
                         const fmi2Real x[],
                         const fmi2ValueReference vr[],
                         size_t nx);

to set a subset of the continuous-time state vector.
This function exists in FMI-ME 2.0, but the standard only allows to call it for
continuous-time state variables during the initialization.

We therefore propose that the standard is being changed as follows:

   ``fmi2SetReal`` can be called during the continuous time mode
   and during event mode not only for inputs,
   as is allowed in FMI-ME 2.0, but also for continuous-time states.

To retrieve individual state derivatives, we introduce the extensions
shown in :numref:`fig_der_ext`
to the ``<Derivatives>`` element of the ``modelDescription.xml`` file.

.. _fig_der_ext:

.. code-block:: xml
   :caption: Extensions for obtaining higher order state derivatives. XML additions are marked yellow.
   :emphasize-lines: 12,13

    <ModelVariables> <!-- Remains unchanged -->
      ...
      <ScalarVariable name="x",      ...> ... </ScalarVariable> <!-- index="5" -->
      ...
      <ScalarVariable name="der(x)", ...> ... </ScalarVariable> <!-- index="8" -->
    </ModelVariables>

    <Derivatives>
      <!-- The ScalarVariable with index 8 is der(x) -->
      <Unknown     index="8" dependencies="6" />
      <!-- index 5 is the index of the state variable x -->
      <HigherOrder index="5" order="2" value_reference="124" /> <!-- This is d^2 x/dt^2 -->
      <HigherOrder index="5" order="3" value_reference="125" /> <!-- This is d^3 x/dt^3 -->
    </Derivatives>

Event Handling
""""""""""""""

.. _subsec_se:

State Events
............

For efficiency, QSS requires to know the dependencies
of event indicators. Also, it will need to
have access to, or else approximate numerically, the time derivatives of the
event indicator. FMI 2.0 outputs an array of real-valued event indicators,
but no variable dependencies.

Therefore, we introduce the following xml section, which assumes we have
three event indicators.

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
              <Element index="1" order="1" value_reference="210" />
            </EventIndicators>
          </ModelStructure>

The attribute ``dependencies`` is optional. However, if it is not specified,
a tool would need to assume that the event indicator depends on all variables.
Write ``dependencies=""`` to declare that this event indicator depends on no variable
(other than possibly time).
Note that for performance reasons, for QSS ``dependencies`` should be declared
for ``order="0"``. For higher order, QSS does not use the dependencies.

.. note::

   The ``index`` uses in the ``<EventIndicators>`` element is different from the ``index``
   used in the ``<ModelVariables>`` element. The first event indicator has an ``index`` 1,
   the second has an ``index`` 2, and so on. A new index is introduced because the event
   indicators do not show up in the list of ``<ModelVariables>``.

   The dependencies variables of event indicators are

   - inputs (variables with causality = "input")
   - continuous-time states
   - independent variable (usually time; causality = "independent")

Consider the following model


.. literalinclude:: ../../models/modelica_for_qss/QSS/Docs/StateEvent1.mo
   :language: modelica

For efficiency reason, QSS requires the FMU which exports this model to indicate in its model description file
the dependency of ``der(x1)`` on ``y``. This allows ``der(x1)`` to update when ``y`` changes.
However, ``y`` can only change when an event indicator changes its domain. Hence,
rather than declaring the dependency on ``y``, it suffices to declare the dependency on
the event indicator.
Therefore, we propose to
include event indicators to the list of state derivative dependencies.

However, FMI states on page 61 that ``dependencies`` are optional attributes
defining the dependencies of the unknown (directly or indirectly via auxiliary variables)
with respect to known.
For state derivatives and outputs, known variables are

- inputs (variables with causality = "input")
- continuous-time states
- independent variable (usually time; causality = "independent")

Therefore we require to extend the ``<Derivatives>`` element
with a new attribute ``ei_dependencies`` which lists
all event indicator variables which trigger
changes to state derivative trajectories.

An excerpt of such a ``<Derivatives>`` element with the new addition is
shown in :numref:`fig_hig_der`.


.. _fig_hig_der:

.. code-block:: xml
  :caption: Extensions with inclusion of a new attribute for event indicator dependencies. XML additions are marked yellow.
  :emphasize-lines: 3

    <Derivatives>
      <!-- The ScalarVariable with index 8 is der(x) -->
      <!-- ei_dependencies="1" declares that der(x) depends on the event indicator with index 1  -->
      <Unknown     index="8" dependencies="6" ei_dependencies="1"/>
      <!-- index 5 is the index of the state variable x -->
      <HigherOrder index="5" order="2" value_reference="124" /> <!-- This is d^2 x/dt^2 -->
      <HigherOrder index="5" order="3" value_reference="125" /> <!-- This is d^3 x/dt^3 -->
    </Derivatives>

For the elements ``Unknown`` and ``HigherOrder``, the
attributes ``dependencies`` and ``ei_dependencies`` are optional.
However, if ``dependencies`` is not declared,
a tool would need to assume that they
depend on all variables.
Similarly, if ``ei_dependencies`` is not declared,
a tool would need to assume that they
depend on all event indicators.
Write ``dependencies=""`` to declare that this derivative depends on no variable.
Similarly,
write ``ei_dependencies=""`` to declare that this derivative depends on no event indicator.
Note that for performance reasons, for QSS ``dependencies`` and ``ei_dependencies`` should be declared
for ``Unknown``. For ``HigherOrder``, QSS does not use the
``dependencies`` and ``ei_dependencies``.


In :numref:`fig_hig_der`, the higher order derivatives depend on the event indicator.

.. note::

  The indexes of ``ei_dependencies`` are the indexes of the
  event indicators specified in the ``<EventIndicators>`` element.

.. _subsec_te:

Event indicators that depend on the input
.........................................


Consider following model

.. literalinclude:: ../../models/modelica_for_qss/QSS/Docs/StateEvent2.mo
   :language: modelica

This model has one event indicator :math:`z = u-x`.
The derivative of the event indicator is :math:`\frac{dz}{dt} = \frac{du}{dt} - \frac{dx}{dt}`.

Hence, a tool will need the derivative of the input ``u``
to compute the derivative of the event indicator.
Since the derivative of the input ``u`` is unkown in the FMU,
we propose for cases where the event indicator
has a direct feedthrough on the input to exclude
event indicator derivatives from the ``<EventIndicators>``
element. In this situation, the QSS solver will detect the missing
information from the XML file and numerically approximate
the event indicator derivatives.


Handling of variables reinitialized with ``reinit()``
.....................................................


Consider following model

.. literalinclude:: ../../models/modelica_for_qss/QSS/Docs/StateEvent3.mo
   :language: modelica

This model has a variable ``x1`` which 
is reinitialized with the ``reinit()`` function. 
Such variables have in the model description file 
an attribute ``reinit`` which can be set to 
``true`` or ``false`` depending on whether they can 
be reinitialized at an event or not.
Since  a ``reinit()`` statement is only valid 
in a ``when-equation`` block, we propose for 
variables with ``reinit`` set to true,
that at every state event, the QSS solver gets the value of 
the variable, updates variables which depend on it, and proceeds 
with its calculation.

Workaround for implementing event indicators
............................................

While waiting for the implementation of the FMI extensions in JModelica,
LBNL will refactor some Modelica models to expose event indicators and 
their first derivatives as FMU output variables.

The names of event indicators variables will start with ``__zc_``. The names of derivatives of event
indicators will start with ``__zc_der_``.  As an example, ``__zc_z1`` and ``__zc_der_z1``
are the names of the event indicator ``z1`` with its derivative ``der_z1``.

If the number of event indicators is equal to the ``numberOfEventIndicators`` attribute,
then only ``__zc_`` and ``__zc_der_`` need to be used by QSS.
If the number of event indicators does not match, the FMU needs to be rejected with an error message.

.. note::

  Per design, Dymola (2018) generates twice as many event indicators as actually existing in the model.
  Hence the master algorithm needs to detect if the tool which exported the FMU is Dymola, and if it is, the
  number of event indicators must be equal to half the value of the ``numberOfEventIndicators`` attribute.

Time Events
...........

This section discusses additional requirements for handling time events with QSS.

Consider following model

.. literalinclude:: ../../models/modelica_for_qss/QSS/Docs/TimeEvent.mo
   :language: modelica

This model has a time event at :math:`t \ge 0.5`.
For efficiency, QSS requires the FMU which exports
this model to indicate in its model description file
the dependency of ``der(x1)`` on ``y``.
However, since ``y`` updates when a time event happens
but a time event is not described with event indicator,
it is not possible to use the same approach as done for
``StateEvent1`` without further modificaton.

We therefore propose that JModelica turns all time events into state events,
add new event indicators generated by those state events to the ``<EventIndicators>`` 
element, and include those event indicators to the ``ei_dependencies`` attribute
of state derivatives which depend on them. 

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

To parametrize the smooth token, we propose to extend the FMI for model exchange specification to include
``fmi2SetRealInputDerivatives`` and ``fmi2GetRealOutputDerivatives``. These two functions exist in the FMI for
co-simulation API.

.. note::

   - If a tool can not provide the derivative of an output variable with respect to time,
     ``fmi2GetRealOutputDerivatives`` then a master algorithm could approximate
     the output derivative as follows:

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


Summary of Proposed Changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is a list with a summary of proposed changes

- ``fmi2SetReal`` can be called during the continuous, and event time mode for continuous-time states.

- The ``<Derivatives>`` element of the model description file will
  be extended to include higher order derivatives information.

- A new ``<EventIndicators>`` element wil be added to the model description file.
  This element will expose event indicators with their ``dependencies`` and time derivatives.

- If a model has an event indicator, and the event indicator has a direct
  feedthrough on an input variable, then JModelica will exclude the derivatives
  of that event indicator from the model description file.

- A new dependency attribute ``ei_dependencies`` will be added to state derivatives listed
  in the ``<Derivatives>`` element to include event indicators on which the state derivatives depend on.

- JModelica will convert time event into state events, generate event indicators
  for those state events, and add those event indicators to the ``ei_dependencies``
  of state derivatives which depend on them.

- A new function ``fmi2SetRealInputDerivatives`` will be included to parametrize smooth token.

- A new function ``fmi2GetRealOutputDerivatives`` will be included to parametrize smooth token.

.. note::

  - We need to determine when to efficiently call ``fmi2CompletedIntegratorStep()`` to signalize that
    an integrator step is complete.
  - We need to determine how an FMU deals with state selection, detect it, and reject it 
    on the QSS side.


Open Topics
~~~~~~~~~~~

This section includes a list of measures which could further improve the efficiency of QSS.
Some of the measures should be implemented and benchmarked to ensure their necessity for QSS.

Atomic API
""""""""""

A fundamental property of QSS is that variables are advanced at different time rates.
To make this practically efficient with FMUs, an API for individual values and derivatives is essential.

XML/API
"""""""

All variables with non-constant values probably need to be exposed via the xml
with all their interdependencies. The practicality and benefit of trying
to hide some variables such as algebraic variables by short-circuiting
their dependencies in the xml (or doing this short-circuiting on the QSS side)
should be considered for efficiency reasons.

Higher Derivatives
""""""""""""""""""

Numerical differentiation significantly complicates and slows the QSS code:
automatic differentiation provided by the FMU will be a major improvement
and allows practical development of 3rd order QSS solvers.

Input Variables
"""""""""""""""

- Input functions with discontinuities up to the QSS order need to be exposed to 
  QSS and provide next event time access to the master algorithm.

- Input functions need to be true (non-path-dependent) functions for 
  QSS use or at least provide a way to evaluate without "memory" 
  to allow numeric differentiation and event trigger stepping.

Annotations
"""""""""""

Some per-variable annotations that will allow for more efficient solutions by overriding global settings (which are also needed as annotations) include:

- Various time steps: ``dt_min``, ``dt_max``, ``dt_inf``, ...
- Various flags: QSS method/order (or traditional ODE method for mixed solutions), inflection point requantization, ...
- Extra variability flags: constant, linear, quadratic, cubic, variable, ...

Conditional Expressions and Event Indicators
""""""""""""""""""""""""""""""""""""""""""""

- How to reliably get the FMU to detect an event at the time QSS predicts one?
 
  QSS predicts zero-crossing event times that, even with Newton refinement, 
  may be slightly off. To get the FMU to "detect" these events with its 
  "after the fact" event indicators the QSS currently bumps the time forward 
  by some epsilon past the predicted event time in the hopes that the FMU will detect it. 
  Even if made smarter about how big a step to take this will never be robust. 
  Missing events can invalidate simulations. If there is no good and efficient FMU API 
  solution we may need to add the capability for the QSS to handle "after the fact" detected 
  events but with the potential for large QSS time steps and without rollback 
  capability this would give degraded results at best.

- How much conditional structure should we expose to QSS?
 
  Without full conditional structure information the QSS must fire events 
  that aren't relevant in the model/FMU. This will be inefficient 
  for models with many/complex conditionals. These non-event events also 
  alter the QSS trajectories so, for example, adding a conditional 
  clause that never actually fires will change the solution somewhat, which is non-ideal.

- QSS needs a mechanism similar to zero crossing functions to deal with Modelica's event generating functions (such as
  ``div(x,y)`` See http://book.xogeny.com/behavior/discrete/events/#event-generating-functions) to avoid missing solution discontinuities.

- Discrete and non-smooth internal variables need to be converted to input variables or exposed (with dependencies) to QSS.

- QSS need dependency information for algebraic and boolean/discrete variables 
  either explicitly or short-circuited through the exposed variables for those the QSS won't track. 

- The xml needs to expose the structure of each conditional block:
  if or when, sequence order of if/when/else conditionals,
  and all the (continuous and discrete/boolean) variables appearing in each conditional.

- Non-input boolean/discrete/integer variables should ideally be altered
  only by event indicator handlers or *time events* that are exposed by the FMU
  (during loop or by direct query?). Are there other ways that
  such variables can change that are only detectable after the fact?
  If so, this leaves the QSS with the bad choices of late detection
  (due to large time steps) or forcing regular time step value checks on them.

- QSS needs the dependencies of conditional expressions on variables appearing in them.

- QSS needs the dependencies of variables altered when each conditional fires on the conditional expression variables.

- It is not robust for the QSS to try and guess a time point where the FMU will
  reliably detect a zero crossing so we need an API to tell the
  FMU that a zero crossing occurred at a given time (and maybe with crossing direction information).

- If the xml can expose the zero crossing directions of interest that will allow for more efficiency.
