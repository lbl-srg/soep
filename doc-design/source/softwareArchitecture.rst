.. _sec_soft_arch:

Software Architecture
---------------------

Overall software architecture
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:numref:`fig_overall_software_architecture`
shows the overall software architecture of SOEP.

The `Application` on top of the figure may be an
equipment sales tool that uses an open, or a proprietary,
Modelica model library of their product line, which allows
a sales person to test and size equipment for a particular customer.

The `HVAC Systems Editor` allows drag and drop of components,
which are read dynamically from the `Modelica Library AST`,
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

   [Core] --> [Model Library]: integrates
   [Core] --> [HVAC Systems Editor\n(SOEP Mode)]: integrates
   [Core] --> [SOEP\nSimulator Interface]: integrates
   }
   }

   package SOEP {
   database "Modelica\nLibrary AST" as mod_AST
   database "Modelica\nBuildings Library"

   [Model Library] --> mod_AST : parses json\nAST

   [HVAC Systems Editor\n(SOEP Mode)] ..> mod_AST : parses json\nAST

   [Conversion Script] .> [JModelica]: parses\nAST
   [SOEP\nSimulator Interface] .> [JModelica] : writes inputs,\nruns simulation,\nreads outputs

   [Conversion Script] -> mod_AST: generates
   [JModelica] -> [Modelica\nBuildings Library]: imports
   }


   actor Developer as epdev
   [Legacy\nModel Library] <.. epdev : updates

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



Coupling of EnergyPlus envelope and room with Modelica-based HVAC and control
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section describes the refactoring of the
EnergyPlus room model, which will remain in the C/C++ implementation
of EnergyPlus, to a form that exposes the time derivative of its room model.
EnergyPlus will be exported as an FMU for model exchange.

The time integration of the room air temperature, moisture and
trace substance concentrations will be done by the master algorithm.

EnergyPlus will synchronize the room model and the envelope model.

We will use the following terminology: By `envelope model`, we mean
the model for the heat and moisture transfer through opaque constructions
and through windows.
By `room model`, we mean the room air heat, mass and trace substance balance.
By `HVAC model`, we mean the HVAC and control model.

The physical quantities that need to be exchanged are as follows.
For a convective HVAC system, the convective and latent heat gain added
by the HVAC system,
the mass flow rates of trace substances such as CO2 and VoC, and
the state of the return air, e.g., temperature, relative humidity and pressure.
For radiant systems, the temperature of the radiant surface,
and the heat flow rates due to conduction, short-wave and long-wave radiation.


Assumptions and limitations
~~~~~~~~~~~~~~~~~~~~~~~~~~~

For the current implementation, we will make the following assumption:

1. Only the lumped room air model will be refactored, not the
   room model with stratified room air.
   The reason is to keep focus and make progress before increasing complexity.
2. The HVAC and the pressure driven air exchange (airflow network) are
   either in legacy EnergyPlus or in FMUs of the SOEP.
   The two methods cannot be combined.
   The reason is that the legacy EnergyPlus computes in its "predictor/corrector"
   the room temperature as follows:

   a. It computes the HVAC power required to meet the temperature set point.
   b. It simulates the HVAC system to see whether it can meet this load.
   c. It updates the room temperature using the HVAC power from step (b).

   This is fundamentally different from the ODE solver used by SOEP who sets the new
   room temperature and time, requests its time derivative, and then recomputes
   the new time step.
3. In each room, mass, as opposed to volume, is conserved.
   The reason is that this does not induce an air flow in the HVAC system if
   the room temperature changes. Hence, it decouples the thermal and the mass balance.


Partitioning of the models
~~~~~~~~~~~~~~~~~~~~~~~~~~

To link the envelope model, the room model and the HVAC model, we partition the simulation
as shown in :num:`Figure #fig-partition-envelop-room-hvac`.

.. _fig-partition-envelop-room-hvac:

.. figure:: img/envelop-room-hvac.*
   :scale: 100 %

   Partitioning of the envelope, room and HVAC model.

The EnergyPlus FMU is for model exchange and contains the
envelope and the room model.
All of the HVAC system and other pressure driven mass flow
rates, such as infiltration due to wind pressure or static
pressure differences, are computed in the HVAC FMUs.
There can be one or several HVAC FMUs, which is irrelevant
as EnergyPlus will only see one set of variables that it
exchanges with the master algorithm.

.. _sec_data_exchange:

Data exchange
~~~~~~~~~~~~~

The communication occurs through the EnergyPlus external interface.
The following variables are sent between the master algorithm
and the EnergyPlus FMU for each room.

+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| Variable                  | Dimension                   | Quantity                                                                                                   | Unit            |
+===========================+=============================+============================================================================================================+=================+
| *From master algorithm to EnergyPlus FMU*                                                                                                                                              |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| mInlet_flow               | :math:`n`                   | Mass flow rate into the zone for the :math:`n`, :math:`n \ge 0`, air inlets (including infiltration)       |   kg/s          |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| TInlet                    | :math:`n`                   | Temperature of the medium carried by the mass flow rate                                                    |   degC          |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| XInlet                    | :math:`n`                   | Water vapor mass fraction per total air mass of the medium carried by the mass flow rate                   |   kg/kg         |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| CInlet                    | :math:`n \times m`          | Concentration of each :math:`m`, :math:`m \ge 0`, trace substance per unit mass of the medium              | unspecified     |
|                           |                             | carried by the mass flow rate                                                                              |                 |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| T                         | :math:`1`                   | Temperature of the zone air                                                                                |   degC          |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| X                         | :math:`1`                   | Water vapor mass fraction per total air mass of the zone                                                   |   kg/kg         |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| C                         | :math:`m`                   | Concentration of each :math:`m`, :math:`m \ge 0`, trace substance per unit mass of the zone air            | unspecified     |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| QGaiConSen_flow           | :math:`1`                   | Convective sensible heat gain added to the zone, and not already part of the flow mInlet_flow              |   W             |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| QGaiRadSen_flow           | :math:`1`                   | Radiative sensible heat gain added to the zone                                                             |   W             |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| QGaiLat_flow              | :math:`1`                   | Latent heat gain added to the zone, and not already part of the flow mInlet_flow                           |   W             |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| t                         | :math:`1`                   | Model time at which the above inputs are valid, with :math:`t=0` defined as January 1, 0 am local time,    |   s             |
|                           |                             | and with                                                                                                   |                 |
|                           |                             | no correction for daylight savings time                                                                    |                 |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| *From EnergyPlus FMU to master algorithm*                                                                                                                                              |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| dT_dt                     | :math:`1`                   | Time derivative of room air temperature                                                                    |   K/s           |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| dX_dt                     | :math:`1`                   | Time derivative of water vapor mass fraction                                                               |   kg/(kg.s)     |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| dC_dt                     | :math:`m`                   | Time derivative of the trace substance concentration                                                       |   1/s           |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| TRad                      | :math:`1`                   | Average radiative temperature in the room                                                                  |   degC          |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+
| nextEventTime             | :math:`1`                   | Model time :math:`t` when EnergyPlus needs to be called next (typically the next zone time step)           |   s             |
+---------------------------+-----------------------------+------------------------------------------------------------------------------------------------------------+-----------------+

There can be zero or multiple air inlet flows, and the quantity :math:`\dot m_{inlet}^i`,
for any :math:`i \in \{0, \ldots, n\}`, can be negative. Hence, the energy equation needs
to be formulated as

.. math::

   C \, \frac{dT}{dt} = \sum_{i=0}^n \max(0, \dot m_{inlet}^i) \, c_p \, (T_{inlet}^i - T) + \text{ other terms}.


The trace substance concentration :math:`C` has unspecified units as it may be
modeled with units of mass fraction or PPM, depending on the magnitude of the concentration.
Also, there may be any number of trace substances.

How to connect variables from the External Interface to the EnergyPlus zone is defined by using an object in the idf file
of the form

.. code::

   ExternalInterface:FunctionalMockupUnitExport:Zone,
   South Office, !- EnergyPlus name of the zone
   3,            !- 0 <= n, number of air flow inlets from the External Interface
   2;            !- 0 <= m, number of trace substances

The External Interface then maps the data from the above variable table to data structure in EnergyPlus.

.. _sec_time_sync:

Time synchronization
~~~~~~~~~~~~~~~~~~~~

As shown in :num:`Figure #fig-partition-envelop-room-hvac`, the EnergyPlus FMU is invoked
at a variable time step.
Internally, it samples its heat conduction model at the envelope time step :math:`\Delta t_z`.
EnergyPlus needs to report this to the FMI interface. To report such time events,
the FMI interface uses a C structure called ``fmi2EventInfo`` which is implemented as follows:

.. code:: c

   typedef struct{
     fmi2Boolean newDiscreteStatesNeeded;
     fmi2Boolean terminateSimulation;
     fmi2Boolean nominalsOfContinuousStatesChanged;
     fmi2Boolean valuesOfContinuousStatesChanged;
     fmi2Boolean nextEventTimeDefined;
     fmi2Real
     nextEventTime; // next event if nextEventTimeDefined=fmi2True
     } fmi2EventInfo;

The variable ``nextEventTime`` needs to be set to the time when the next event happens
in EnergyPlus. This is, for example, whenever the envelope model advances time,
or when a schedule changes its value and this change affects the variables
that are sent from the EnergyPlus FMU to the master algorithm.
Such a schedule could for example be a time schedule for internal heat gains,
which may change at times that do not coincide with the zone time step :math:`\Delta t_z`.

Requirements for Exporting EnergyPlus as an FMU for model exchange
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To export EnergyPlus as an FMU for model exchange, EnergyPlus must be compiled as a shared library.
The shared library must export the functions which are described in the next section.
These functions are then used by the FMI for model exchange wrapper that LBL is developing.

.. note::

  In the current implementation, we assume that EnergyPlus does not support roll back in time.
  This will otherwise require EnergyPlus to be able to save and restore its complete internal state.
  This internal state consists especially of the values of the continuous-time states,
  iteration variables, parameter values, input values, delay buffers, file identifiers and internal status information.
  This limitation is indicated in the model description file with the capability flag ``canGetAndSetFMUstate``
  being set to ``false``. If this capability were supported, then EnergyPlus could be used
  with ODE solvers which can reject and repeat steps. Rejecting steps is needed by ODE solvers
  such as DASSL or even Euler with step size control (but not for QSS)
  as they may reject a step size if the error is too large.
  Also, rejecting steps is needed to identify state events (but not for QSS solvers).

In the remainder of this section, we note that ``time`` is

   - the variable described as ``t`` in the table of section :numref:`sec_data_exchange`,
   - a monotonically increasing variable.

.. note::

    Monotonically increasing means that if a function has as argument ``time`` and is called at time ``t1``, then its next call must happen at time ``t2`` with ``t2`` >= ``t1``.
    For efficiency reasons, if a function which updates internal variables is called at the same time instant multiple times then only the first call will update the variables, subsequent calls will cause the functions to return the same variable values.

.. code:: c

   unsigned int instantiate(const char const *input,
                            const char const *weather,
                            const char const *idd,
                            const char const *instanceName,
                            const unsigned int valueReferences[],
                            double* variablePointers[],
                            size_t nVars,
                            const char *log);

- ``input``: Absolute or relative path to an EnergyPlus input file with file name.
- ``weather``: Absolute or relative path to an EnergyPlus weather file with file name.
- ``idd``: Absolute or relative path to an EnergyPlus IDD file with file name.
- ``instanceName``: String to uniquely identify an EnergyPlus instance. This string must be non-empty and will be used for logging message.
- ``valueReferences``: A vector of value references. Value references uniquely identify values of variables
    defined in the model description file of an EnergyPlus FMU.
- ``variablePointers``: A vector of pointers to variables whose value references are defined in ``valueReferences``.
- ``nVars``: Number of elements of ``valueReferences`` and ``variablePointers``.
- ``log``: Logging message returned on error.


This function will read the ``idf`` file, sets up the data structure in EnergyPlus, gets
a vector of value references (as in ``modelDescription.xml``)
and returns a vector of pointers to the aforementioned value references.
The ordering of the value references must match the ordering of the vector of pointers.

It returns zero if there was no error, or else a positive non-zero integer.

.. code:: c

   unsigned int setupExperiment(double tStart,
                                bool stopTimeDefined,
                                double tEnd,
                                const char *log);

- ``tStart``: Start of simulation in seconds.
- ``stopTimeDefined``: If ``false``, then the value of ``tEnd`` must be ignored.
  If ``stopTimeDefined = true`` and the environment tries to compute past ``tEnd``,
  then ``setTime()`` has to return an error message.
  (Setting ``stopTimeDefined = false`` allows use of the simulator as part of a controller.)
- ``tEnd``: End of simulation in seconds.
- ``log``: Logging message returned on error.

This functions sets the start and end time of EnergyPlus to the values ``tStart`` and ``tEnd``.
There is no warm-up simulation.

It returns zero if there was no error, or else a positive non-zero integer.

.. note::

   The EnergyPlus start and stop time is as retrieved from the arguments of
   ``setupExperiment(...)``. The ``RunPeriod`` in the ``idf`` file is only
   used to determine the day of the week.

   *Complications*:

   a) Users may set ``tStart`` and ``tEnd``
      to times other than midnight. We think EnergyPlus cannot yet handle an arbitrary start
      and end time. In this case, it should return an error.
   b) Users may set ``tStart=tEnd``, which is valid in some simulators. Can EneryPlus
      handle this or should it return an error?


.. code:: c

   unsigned int setTime(double time,
                        const char *log);

- ``time``: Model time.
- ``log``: Logging message returned on error.

This function sets a new time in EnergyPlus. This time becomes the current model time.

It returns zero if there was no error, or else a positive non-zero integer.

.. code:: c

   unsigned int setVariables(const unsigned int valueReferences[],
                             const double* const variablePointers[],
                             size_t nVars1,
                             const char *log);

- ``valueReferences``: Vector of value references.
- ``variablePointers``: Vector of pointers to variables.
- ``nVars1``: Number of elements of ``valueReferences``, and ``variablePointers``.
- ``log``: Logging message returned on error.

This function sets the value of variables in EnergyPlus.
The vector ``variablePointers`` could be a subset of the pointer ``variablePointers``
that was setup in ``instantiate(...)``, i.e., ``nVars1 <= nVars``
(to allow updating only specific variables
as needed by QSS).

It returns zero if there was no error, or else a positive non-zero integer.

.. code:: c

   unsigned int getVariables(const unsigned int valueReferences[],
                             const double* variablePointers[],
                             size_t nVars2,
                             const char *log);

- ``valueReferences``: Vector of value references.
- ``variablePointers``: Vector of pointers to variables.
- ``nVars2``: Number of elements of ``valueReferences``, and ``variablePointers``.
- ``log``: Logging message returned on error.


This function gets the value of variables in EnergyPlus.
EnergyPlus must write the values to the elements that are setup in ``variablePointers``
during the ``instantiate(...)`` call.
``nVars2 <= nVars`` if only certain output variables are required.

It returns zero if there was no error, or else a positive non-zero integer.

.. code:: c

   unsigned int setContinuousStates(const unsigned int valueReferences[],
                                    const double variablePointers[],
                                    size_t nVars3,
                                    const char *log);

- ``valueReferences``: Vector of value references.
- ``variablePointers``: Vector of pointers to state variables.
- ``nVars3``: Number of elements of ``valueReferences``, and ``variablePointers``.
- ``log``: Logging message returned on error.

This function sets a new state vector in EnergyPlus.

It returns zero if there was no error, or else a positive non-zero integer.

.. code:: c

   unsigned int getContinuousStates(const unsigned int valueReferences[],
                                    const double* variablePointers[],
                                    size_t nVars4,
                                    const char *log);

- ``valueReferences``: Vector of value references.
- ``variablePointers``: Vector of pointers to state variables.
- ``nVars4``: Number of elements of ``valueReferences``, and ``variablePointers``.
- ``log``: Logging message returned on error.

This function returns the new state vector from EnergyPlus.

It returns zero if there was no error, or else a positive non-zero integer.


.. code:: c

   unsigned int getTimeDerivatives(const unsigned int valueReferences[],
                                   const double* variablePointers[],
                                   size_t nVars5,
                                   const char *log);

- ``valueReferences``: Vector of value references.
- ``variablePointers``: Vector of pointers to state derivatives.
- ``nVars5``: Length of vector of state derivatives.
- ``log``: Logging message returned on error.

This function returns a vector of state derivatives.

It returns zero if there was no error, or else a positive non-zero integer.

.. code:: c

   unsigned int getNextEventTime(fmi2EventInfo *eventInfo,
                                 const char *log);

- ``eventInfo``: A structure with event info as defined in section :ref:`sec_time_sync`
- ``log``: Logging message returned on error.

This function writes a structure which contains among its variables a non-zero flag to indicate that the next event time is defined, and the next event time in EnergyPlus.

It returns zero if there was no error, or else a positive non-zero integer.

.. code:: c

   unsigned int terminate(const char *log);

- ``log``: Logging message returned on error.

This function must free all allocated variables in EnergyPlus.

Any further call to the EnergyPlus shared library is prohibited after call to this function.

It returns zero if there was no error, or else a positive non-zero integer.

.. code:: c

   unsigned int writeOutputFiles(const char *log);

- ``log``: Logging message returned on error.


This function writes the output to the EnergyPlus output files.

It returns zero if there was no error, or else a positive non-zero integer.


Pseudo Code Example
~~~~~~~~~~~~~~~~~~~

In the next section, the usage of the FMI functions along with the equivalent EnergyPlus functions are used in a typical calling sequence.
This should clarify the need of the EnergyPlus equivalent functions and show how these functions will be used in a simulation environment.
In the pseudo code, ``->`` points to the EnergyPlus equivalent FMI functions. ``NA`` indicates that the FMI functions do not require EnergyPlus equivalent.


.. literalinclude:: models/pseudo/pseudo.c
   :language: C
   :linenos:

Tool for Exporting EnergyPlus as an FMU
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To export EnergyPlus as an FMU, a utility is needed which will get as inputs
the paths to the EnergyPlus IDF, IDD, and weather files.
The utility will parse the IDF file and write an XML model description file
which contains the inputs, outputs, and states of EnergyPlus to be exposed
through the FMI interface.
The utility will compile the EnergyPlus FMI functions into a shared library,
and package the library with the IDF, IDD, and weather file in the
``resources`` folder of the FMU.
An approach to develop such a utility is to extend EnergyPlusToFMU
(http://simulationresearch.lbl.gov/fmu/EnergyPlus/export/index.html)
to support FMI 2.0 for model exchange.
Another approach is to extend SimulatorToFMU (https://github.com/LBNL-ETA/SimulatorToFMU)
to support the export of EnergyPlus.


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
   [Master algorithm] <- qss_sol : "next event time, discrete states"
   [Master algorithm] - [Sundials]
   }

   [FMU-ME] as ode

   [Sundials] -> ode : "(x, t)"
   [Sundials] <- ode : "dx/dt"

   [FMU-ME (envelope)] as ep_env
   [Master algorithm] -> ep_env : "h"
   [Master algorithm] <- ep_env : "(next event time, discrete states)"

   package Optimica {
   [JModelica compiler] as jmc
   }

   jmc -> FMU_QSS

   FMU_QSS -down-> qss_sol : "derivatives"
   qss_sol -down-> FMU_QSS : "inputs, time, states"


In :numref:`fig_sof_arc_qss_jmod2`, ``FMU-ME (envelope)`` is the envelop
model that uses a refactored version of the EnergyPlus code. In earlier
design, this was an FMU-CS. However, the PyFMI master algorithm requires
either all FMU-ME, or all FMU-CS, but if the latter were used, then
direct feedthrough would not be allowed. Hence, we are using FMU-ME
for EnergyPlus, but similiar as the ``FMU-QSS``, the ``FMU-ME (envelope)``
has only discrete states, and the time instant when these states are updated
is constant and equal to the EnergyPlus CTF time step.

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
      <HigherOrder index="5" order="2" valueReference="124" /> <!-- This is d^2 x/dt^2 -->
      <HigherOrder index="5" order="3" valueReference="125" /> <!-- This is d^3 x/dt^3 -->
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
              <Element index="1" order="0" dependencies="2 3" valueReference="200" />
              <!-- This is z[1] which declares no dependencies, hence it may depend on everything -->
              <Element index="2" order="0" valueReference="201" />
               <!-- This is z[2] which declares that it depends only on time -->
              <Element index="3" order="0" dependencies="" valueReference="202" />

              <!-- With order > 0, higher order derivatives can be specified. -->
              <!-- This is dz[0]/dt -->
              <Element index="1" order="1" valueReference="210" />
            </EventIndicators>
          </ModelStructure>

The attribute ``dependencies`` is optional. However, if it is not specified,
a tool shall assume that the event indicator depends on all variables.
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
with a new attribute ``eventIndicatorsDependencies`` which lists
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
      <!-- eventIndicatorsDependencies="1" declares that der(x)
           depends on the event indicator with index 1  -->
      <Unknown     index="8" dependencies="6" eventIndicatorsDependencies="1"/>
      <!-- index 5 is the index of the state variable x -->
      <HigherOrder index="5" order="2" valueReference="124" /> <!-- This is d^2 x/dt^2 -->
      <HigherOrder index="5" order="3" valueReference="125" /> <!-- This is d^3 x/dt^3 -->
    </Derivatives>

For the elements ``Unknown`` and ``HigherOrder``, the
attributes ``dependencies`` and ``eventIndicatorsDependencies`` are optional.
However, if ``dependencies`` is not declared,
a tool shall assume that they
depend on all variables.
Similarly, if ``eventIndicatorsDependencies`` is not declared,
a tool shall assume that they
depend on all event indicators.
Write ``dependencies=""`` to declare that this derivative depends on no variable.
Similarly,
write ``eventIndicatorsDependencies=""`` to declare that this derivative depends on no event indicator.
Note that for performance reasons, for QSS ``dependencies`` and ``eventIndicatorsDependencies`` should be declared
for ``Unknown``. For ``HigherOrder``, QSS does not use the
``dependencies`` and ``eventIndicatorsDependencies``.


In :numref:`fig_hig_der`, the higher order derivatives depend on the event indicator.

.. note::

  The indexes of ``eventIndicatorsDependencies`` are the indexes of the
  event indicators specified in the ``<EventIndicators>`` element.

.. _subsec_te:

Event indicators that depend on the input
.........................................


Consider following model

.. literalinclude:: ../../models/modelica_for_qss/QSS/Docs/StateEvent2.mo
   :language: modelica

This model has one event indicator :math:`z = u-x`.
The derivative of the event indicator is :math:`{dz}/{dt} = {du}/{dt} - {dx}/{dt}`.

Hence, a tool requires the derivative of the input ``u``
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
If the number of event indicators does not match, the FMU shall be rejected with an error message.

.. note::

  Per design, Dymola (2018) generates twice as many event indicators as actually existing in the model.
  Hence the master algorithm shall detect if the tool which exported the FMU is Dymola, and if it is, the
  number of event indicators shall be equal to half the value of the ``numberOfEventIndicators`` attribute.

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
element, and include those event indicators to the ``eventIndicatorsDependencies`` attribute
of state derivatives which depend on them.

.. note::

   All proposed XML changes will be initially implemented
   in the ``VendorAnnotation`` element of the model description file until
   they got approved and included in the FMI standard.

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

- A new dependency attribute ``eventIndicatorsDependencies`` will be added to state derivatives listed
  in the ``<Derivatives>`` element to include event indicators on which the state derivatives depend on.

- JModelica will convert time event into state events, generate event indicators
  for those state events, and add those event indicators to the ``eventIndicatorsDependencies``
  of state derivatives which depend on them.

- A new function ``fmi2SetRealInputDerivatives`` will be included to parametrize smooth token.

- A new function ``fmi2GetRealOutputDerivatives`` will be included to parametrize smooth token.

- All proposed XML changes will be initially implemented in the ``VendorAnnotation``
  element of the model description file until they got approved and included in the FMI standard.

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

OpenStudio integration
^^^^^^^^^^^^^^^^^^^^^^

.. note:: This section needs to be revised in view of the move towards a json-driven architecture.

.. include:: automatedDocAstTool.rst
