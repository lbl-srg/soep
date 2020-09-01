.. _sec_requirements:

Requirements
------------

This section describes the functional, mathematical and software requirements.

OpenStudio integration
^^^^^^^^^^^^^^^^^^^^^^

Below is an initial list of requirements for the OpenStudio integration.

#. *Translation of legacy models*: It need not be possible to translate
   legacy OpenStudio HVAC models to SOEP.

   The reason is that the control semantics is too different between the
   load-based control of EnergyPlus and the control of Modelica that
   is based on measurable states such as a room temperature.

#. *Measures*: OpenStudio measures and the OpenStudio editor shall work,
   after some extensions or adaptions,
   with models that are authored in Modelica and subsequently
   integrated in OpenStudio.

   A use case is that a design firm creates a Modelica library
   of HVAC systems and control sequences they frequently use,
   and want to use them with Measures and with a schematic editor
   to adapt them for a particular project.

   Another use case is that an equipment vendor creates an OpenStudio
   application for equipment selection and sizing.

#. *Opening and saving a model*:
   It shall be possible to open in the editor a model that is declared in Modelica
   syntax, manipulate it, and save it again in Modelica syntax. Only items
   that have been changed should be updated in the Modelica syntax.

   A use case is that a design firm builds custom models of air handler units,
   improves them during a project, and wants to save the improvements in the
   library for use in the next project. As the custom library is stored in
   git, only the items of the model that have been manipulated should be changed.

#. *Hierarchical modeling*: The editor shall support hierarchical modeling.

   A use case is that a user builds a VAV system with 50 terminal units
   with custom control by creating a composite model of a VAV box plus
   its controller, instantiates it 50 times, and later wants to change the
   VAV controller once and propagate these changes to all instances.

#. *Adding model inputs, outputs and ports*:
   The editor shall allow enabling a conditional input to a model and connect
   it to the output of another model.

   A use case is that a user instantiates a weather data reader, sets
   a parameter that enables an input signal port for the dry bulb temperature,
   and connects this input to a temperature signal to model heat island effects.

   Another use case is that a user instantiates a room controller that has
   the measured room temperature as an input, and then
   adds a demand response signal as an input to reset the temperature
   setpoint based on the demand response signal.

#. *Typed ports*:
   To support Modelica-type connections such as Real, Integer or Boolean
   control signals, and fluid ports, the OpenStudio HVAC editor
   shall have typed ports.

   A use case is that connecting a control output to a fluid port
   shall be rejected by the OpenStudio model and the graphical editor.


Mathematics
^^^^^^^^^^^

In SOEP, models are implemented in the form of Modelica models. These models
may call FMUs or C-functions for certain algorithms.
When connecting models, differential algebraic systems of equations may be formed.
Solving the algebraic equations and integrating the differential equations in time requires the equations for the continuous time
dynamics to satisfy certain smootheness properties in order for solutions to exist and to be unique.
These smoothness properties are also required for convergence and
computational efficiency of the iterative solution methods.
The next sections describe these mathematical properties that
need to be satisfied by the model equations.


Differentiability
~~~~~~~~~~~~~~~~~

Building simulation problems can be formulated as a semi-explicit
nonlinear DAE system with index one
:cite:`BrenanCampbellPetzold1989`, coupled to the discrete variables
:math:`x_d(\cdot)` and :math:`u_d(\cdot)`.
The general form is :cite:`Wetter2005:1`

.. math::
   :label: eq_DAEPhy

   \left[\dot x_c(t), x_d(t)\right] & = f(x_c(t), x_d(t^-), u_c(t), u_d(t), p, t),

   \left[y_c(t), y_d(t)\right] & = g(x_c(t), x_d(t), u_c(t), u_d(t), p, t),

   0 & = \gamma\bigl(u_c(t), y_c(t), y_d(t) \bigr),

   \left[x_c(t_0), x_d(t_0)\right] & = (x_{c,0}, x_{d,0}),

where
:math:`x(\cdot)` is the state vector, with superscript
:math:`c` denoting continuous and :math:`d` denoting discrete states,
:math:`u(\cdot)` is the control input,
:math:`p` are parameters,
:math:`f(\cdot, \cdot, \cdot, \cdot, \cdot, \cdot)` is the state transitions function,
:math:`g(\cdot, \cdot, \cdot, \cdot, \cdot, \cdot)` is the output function and
:math:`0 = \gamma(\cdot, \cdot, \cdot)` are the algebraic constraints.
This represents algebraic loops that can be formed when connecting FMUs in a loop.

We will now present requirements for
existence of a unique smooth solution of the DAE System :eq:`eq_DAEPhy`.
For simplicity, we assume in the analysis
:math:`x_d(\cdot)` and
:math:`y_d(\cdot)` to only depend on time but not on
:math:`x_c(\cdot)` or :math:`y_c(\cdot)`. Otherwise,
the analysis would get considerably more involved.
This allows us to simplify :eq:`eq_DAEPhy` to

.. math::
   :label: eq_DAEPhyCon

   \dot x(t) & = f(x(t), \mu(t), p, t),

   0 & = \gamma(x(t), \mu(t)),

   x(t_0) & = x_{0},

where we omitted the subscript :math:`c` as all variables are continuous.

First, we will state the requirement that allows to
establish existence, uniqueness and differentiability of
the solution :math:`x(t_f)` to :eq:`eq_DAEPhyCon`.

**Requirement:**
Let
:math:`\gamma \colon \Re^n \times \Re^m \to \Re^m`
be defined as in :eq:`eq_DAEPhyCon`.
We assume that
:math:`\gamma(\cdot,\cdot)` is once continuously differentiable,
and we assume that
for all
:math:`x \in \Re^n`,
:math:`\gamma(x(t), \cdot)=0`
has a unique solution
:math:`\mu^*(x) \in \Re^m` and
that the matrix with partial derivatives
:math:`\partial \gamma(x, \mu^*(x))/ \partial \mu \in \Re^{m \times m}`
is non-singular.


With this assumption and the use of the
Implicit Function Theorem :cite:`Pol97:1`, one can show that
the solution
:math:`\mu^*(x)` that satisfies
:math:`\gamma(x, \mu^*(x) )=0`,
is unique and once continuously differentiable in
:math:`x`.

Therefore, to establish existence, uniqueness and differentiability
of :math:`x(t_f)`, we can reduce the DAE system :eq:`eq_DAEPhyCon`
to an ordinary differential
equation, which will allow us to use standard results from the
theory of ordinary differential equations.
To do so, we define for :math:`t \in [t_0, \, t_f]`
the function

.. math::
   :label: eq_tilFDef

   \widetilde f(x(t), p, t) \triangleq f(x(t), \mu^*(x), p, t)

and write the DAE system :eq:`eq_DAEPhyCon` in the form

.. math::
   :label: eq_tilFSys

   \dot x(t) & = \widetilde f(x(t), p, t),

   x(t_0) & = x_{0}.


We will use the notation
:math:`\widetilde f_{x}(x(t), p, t)` and
:math:`\widetilde f_{p}(x(t), p, t)`
for the partial derivatives
:math:`(\partial/\partial x)(\widetilde f(x(t), p, t)` and
:math:`(\partial/\partial p)(\widetilde f(x(t), p, t)`, respectively.

**Requirement:**
With :math:`\widetilde f(\cdot, \cdot, \cdot)`
as in
:eq:`eq_tilFSys`, we require that

 #. The initial condition :math:`x_{0}` is once continuously differentiable in :math:`p`.

 #. There exists a constant :math:`K \in [1, \, \infty)` such that for all
    :math:`x', x'' \in \Re^n`, for all :math:`p', p'' \in \Re^l` and for all :math:`t`, the following relations hold:

    .. math::

       \| \widetilde f(x', p', t) - \widetilde f(x'', p'', t) \| &
       \le K \, (\| x' - x'' \| + \| p' - p'' \| ),

       \| \widetilde f_{x}(x', p', t) - \widetilde f_{x}(x'', p'', t) \| &
       \le K \, (\| x' - x'' \| + \| p' - p'' \| ),

    and

    .. math::

       \| \widetilde f_p(x', p', t) - \widetilde f_p(x'', p'', t) \|
       \le K \, (\| x' - x'' \| + \| p' - p'' \| ).

With these conditions, it follows as a special case of Corollary 5.6.9 in :cite:`Pol97:1`,
that the solution
:math:`x(t_f)` to :eq:`eq_DAEPhyCon` exists and is once continuously differentiable with
respect to the parameter :math:`p` on bounded sets.

.. note:: Differentiability with respect to :math:`p` is important
          if the HVAC system
          is sized by solving an optimization problem.


Control of Numerical Noise
~~~~~~~~~~~~~~~~~~~~~~~~~~

Evaluating the functions
:math:`f(\cdot, \cdot, \cdot, \cdot, \cdot, \cdot)`,
:math:`g(\cdot, \cdot, \cdot, \cdot, \cdot, \cdot)` and
:math:`F(\cdot, \cdot, \cdot, \cdot, \cdot, \cdot, \cdot)`
may require iterations inside the component, which may be realized as an FMUs,
that implement these functions.
These iterations typically terminate when a convergence test is satisfied.
In such cases, the state derivatives
:math:`\dot x_c(t)` and
the outputs
:math:`y_c(t)` may not be computed exactly.
For example, if :math:`z(t)` denotes a continuous state (or state derivative or output), one can only compute a numerical approximation
:math:`z^*(t; \epsilon)`, where :math:`\epsilon` is the tolerance setting of the numerical solver.
The precision of these inner iterations need to be controlled

 #. when these FMUs are part of an algebraic loop, and
 #. when SOEP is used to evaluate the cost function of an optimization problem.

We therefore impose the following requirement.

**Requirement:**
We require that the FMUs allow controlling the numerical precision.
Specifically, for any :math:`t \in [t_0, t_f]`, there need to exist
an :math:`\epsilon' > 0` and a strictly monotone increasing function
:math:`\varphi \colon \Re \to \Re`, such that

.. math::
	:label: eq_errBouSol

        \| z(t) - z^*(t, \epsilon) \| \le \varphi(\epsilon)

for all :math:`0 < \epsilon < \epsilon'`.

Note that this means that as the tolerance of the solver is decreased, the numerical error decreases.
This requirement allows proving convergence to a first order
optimal point for a class of derivative-free optimization
algorithms :cite:`PolakWetter2006`.


.. _sec-fmu-cap:

FMU Requirements
^^^^^^^^^^^^^^^^

The FMI standard contains various properties that it declares optional to implement.

FMU Capabilities
~~~~~~~~~~~~~~~~

For computing efficiency, FMUs that are used in the SOEP must support
the following optional properties of the FMI 2.0 standard.

#. The optional function ``fmi2GetDirectionalDerivative`` must be
   implemented. This is required in the following situations:

   #. To compute Jacobian matrices without requiring numerical
      differentiation.
   #. By numerical integrators for stiff differential equation,
      other than the LIQSS methods discussed below.
   #. If an FMU is part of an algebraic loop.
   #. If an FMU, or a composition of FMUs, shall be linearized,
      such as for controls design.

#. The optional output dependency must be provided in the section
   ``<ModelStructure><Outputs>`` of the model description file.
   This is required to determine the existence of algebraic loops
   between FMUs.

#. The optional derivative dependency must be provided in the section
   ``<ModelStructure><Derivatives>`` of the model description file.
   This information declares the dependencies of the state derivatives
   on the knowns at the current time instant for model exchange and at
   the current communication point for co-simulation.
   This is required to create an incidence matrix which can be used by
   an integrator.

#. The optional attribute ``canGetAndSetFMUstate`` must be ``true``
   in the model description file. This implies that the
   functions ``fmi2GetFMUstate``, ``fmi2SetFMUstate`` and
   ``fmi2FreeFMUstate`` must be implemented. This is required
   for the following situations:

   #. To implement rollback in time when an FMU was not able to
      complete the time step, maybe due to an event, or if the
      integration error was too large.
   #. To provide a state initialization when solving a
      model predictive control problem or when doing an
      input-output linearization.

#. If an FMU for co-simulation accepts a certain communication time
   step :math:`h` (i.e., it returns that it can simulate to
   :math:`h' = h` ), or at least makes partial progress until
   :math:`h' < h`, then it must accept any time step
   :math:`h''` smaller than or equal to :math:`h'`,
   provided the FMU is started from the same state.
   This is required for proving termination of the master algorithm.
   See :cite:`Broman2013`.

#. If an FMU for co-simulation is asked to integrate for some
   :math:`0 < h`, but it returns that it can only integrate until some
   :math:`0 < h' < h`, then if it is asked to integrate
   to some :math:`h''>h'`, it will again only integrate until
   :math:`h'`.
   This property is required for FMUs to make maximum progress
   in each time step. See :cite:`Broman2013`.

#. FMUs distributed with SOEP must run on Windows 64 bit, Linux 64 bit
   and Mac OS X 64 bit.


QSS Implementation
^^^^^^^^^^^^^^^^^^

This section describes the requirements for the QSS solver implementation.
The development code for QSS is at https://github.com/NREL/SOEP-QSS.

#. The implementation shall support the ability to mix traditional discrete time
   simulation of some subsystems with QSS solution of others.
#. For different subsystems, it shall be possible to use different QSS solvers,
   such as QSS1, 2, 3, or LIQSS1, 2 or 3.
#. It shall be possible to specify absolute and relative tolerances for the quantization.
   (Note: In Modelica, vendor annotations could be used to specify tolerances.)
#. If multiple variables end up triggering the next advance with the exact same time,
   then these shall be handled simultaneously.
   An example are distributed discrete time controls.
#. Near zero time steps shall be handled without modification.
   If these pose a problem, we may want to avoid them at a later stage in the solver.
#. Algebraic loops shall be supported (without the use of micro-delays).


Master Algorithm
^^^^^^^^^^^^^^^^

The master algorithm must satisfy the following requirements:

#. The master algorithm must be using the BSD license. Hence,
   it must not use any GPL or LGPL licensed code.
   However, calls to such licensed code may be permitted
   as long as it does not affect the license of the master
   algorithm.

#. It must be possible to spawn simulations to a server farm
   in order to increase the parallelism. By default,
   the computations run locally.

#. It must be possible to simulate very large buildings,
   such as high rise buildings with about 10,000 thermal zones.
   This is required to be able to simulate models that
   are received from a Building Information Model.
   We therefore expect to have models with 100,000 to 1,000,000
   state variables, or more if 2-dimensional heat transfer,
   dynamic moisture transfer, or computational fluid
   dynamics is used.

#. If an FMU that computes some part of a building
   does not converge, then the master algorithm must
   be able to use some default output, log an appropriate
   warning, and proceed with the computation. This must be
   the default behavior. However, it must be possible
   to disable this error handling so that a completion of
   the simulation is only possible if all FMUs
   simulated without error.

#. The master algorithm must run on Windows 64 bit,
   Linux 64 bit, and Mac OS X 64 bit.
