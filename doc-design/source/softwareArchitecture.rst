.. _sec_soft_arch:

*********************
Software Architecture
*********************

Overall software architecture
=============================

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
=============================================================================

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
---------------------------

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
--------------------------

To link the envelope model, the room model and the HVAC model, we partition the simulation
as shown in :num:`Figure #fig-partition-envelop-room-hvac`.

.. _fig-partition-envelop-room-hvac:

.. figure:: img/envelop-room-hvac.*
   :scale: 100 %

   Partitioning of the envelope, room and HVAC model.

The EnergyPlus FMU is for model exchange and contains the
envelope and the room surfaces.
All of the HVAC system and other pressure driven mass flow
rates, such as infiltration due to wind pressure or static
pressure differences, are computed in the HVAC FMUs.
There can be one or several HVAC FMUs, which is irrelevant
as EnergyPlus will only see one set of variables that it
exchanges with the master algorithm.

.. _sec_data_exchange:

Data exchange
-------------

The following parameters are sent from EnergyPlus to Modelica. These are sent only once during the initialization for each thermal zone.

+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| Variable                  | Dimension                   | Quantity                                                                                                    | Unit            |
+===========================+=============================+=============================================================================================================+=================+
| *From EnergyPlus to Modelica*                                                                                                                                                           |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| V                         | :math:`1`                   | Volume of the zone air                                                                                      |   m3            |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| AFlo                      | :math:`1`                   | Floor area of the zone                                                                                      |   m2            |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| mSenFac                   | :math:`1`                   | Factor for scaling the sensible thermal mass of the zone air volume                                         |   1             |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+

The following time-dependent variables are exchanged between EnergyPlus and Modelica during the time integration
for each thermal zone.

+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| Variable                  | Dimension                   | Quantity                                                                                                    | Unit            |
+===========================+=============================+=============================================================================================================+=================+
| *From Modelica to EnergyPlus*                                                                                                                                                           |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| T                         | :math:`1`                   | Temperature of the zone air                                                                                 |   degC          |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| X                         | :math:`1`                   | Water vapor mass fraction per total air mass of the zone                                                    |   kg/kg         |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| mInlets_flow              | :math:`1`                   | Sum of positive mass flow rates into the zone for all air inlets (including infiltration)                   |   kg/s          |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| TInlet                    | :math:`1`                   | Average of inlets medium temperatures carried by the mass flow rates                                        |   degC          |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| QGaiRad_flow              | :math:`1`                   | Radiative sensible heat gain added to the zone                                                              |   W             |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| t                         | :math:`1`                   | Model time at which the above inputs are valid, with :math:`t=0` defined as January 1, 0 am local time,     |   s             |
|                           |                             | and with                                                                                                    |                 |
|                           |                             | no correction for daylight savings time                                                                     |                 |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| *From EnergyPlus to Modelica*                                                                                                                                                           |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| TRad                      | :math:`1`                   | Average radiative temperature in the room                                                                   |   degC          |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| QConSen_flow              | :math:`1`                   | Convective sensible heat added to the zone, e.g., as entered in                                             |   W             |
|                           |                             | the EnergyPlus' ``People`` or ``Equipment`` schedule                                                        |                 |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| QLat_flow                 | :math:`1`                   | Latent heat gain added to the zone, e.g., from mass transfer with moisture buffering material and           |   W             |
|                           |                             | from EnergyPlus' ``People`` schedule                                                                        |                 |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| QPeo_flow                 | :math:`1`                   | Heat gain due to people (only to be used to optionally compute CO2 emitted by people)                       |   W             |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| nextEventTime             | :math:`1`                   | Model time :math:`t` when EnergyPlus needs to be called next (typically the next zone time step)            |   s             |
+---------------------------+-----------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+

Note that the EnergyPlus object ``ZoneAirContaminantBalance`` either allows CO2 concentration modeling,
or a generic contaminant modeling (such as from material outgasing),
or no contaminant modeling, or both. To allow ambiguities regarding what contaminant
is being modeled, we do not receive the contaminant emission from EnergyPlus.
Instead, we obtain the heat gain due to people, which is then used to optionally computed the
CO2 emitted by people.

For this coupling, all zones of EnergyPlus will be accessed from Modelica.
For example, if a building has two zones, then both zones need to be modeled in Modelica.

.. _sec_time_sync:

Time synchronization
--------------------

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
------------------------------------------------------------------

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
    For efficiency reasons, if a function which updates internal variables is called at the same time instant multiple times,
    then only the first call will update the variables, subsequent calls will cause the functions to return the same variable values.


Instantiation
^^^^^^^^^^^^^

.. code:: c

   unsigned int instantiate(const char const *input,
                            const char const *weather,
                            const char const *idd,
                            const char const *instanceName,
                            const char ** parameterNames,
                            const unsigned int parameterValueReferences[],
                            size_t nPar,
                            const char ** inputNames,
                            const unsigned int inputValueReferences[],
                            size_t nInp,
                            const char ** outputNames,
                            const unsigned int outputValueReferences[],
                            size_t nOut,
                            const char *log);

- ``input``: Absolute or relative path to an EnergyPlus input file with file name.
- ``weather``: Absolute or relative path to an EnergyPlus weather file with file name.
- ``idd``: Absolute or relative path to an EnergyPlus idd file with file name.
- ``instanceName``: String to uniquely identify an EnergyPlus instance. This string must be non-empty and will be used for logging message.
- ``parameterNames``: A vector of ``nPar`` strings that identifies the names of the parameters that are to be retrieved from EnergyPlus.
- ``parameterValueReferences``: A vector of value references for the quantities in ``parameterNames``.
  Value references uniquely identify the variables, and are used in the ``setVariables``
  and ``getVariables`` calls below.
- ``nPar``: Number of elements of the parameter vector, e.g.,
  length of ``parameterNames`` and ``parameterValueReferences``.
- ``inputNames``: A vector of ``nInp`` strings that identifies the names of the inputs sent to EnergyPlus.
- ``inputValueReferences``: A vector of value references for the quantities in ``inputNames``.
- ``nInp``: Number of elements of the input vector, e.g.,
  length of ``inputNames`` and ``inputValueReferences``.
- ``outputNames``: A vector of ``nOut`` strings that identifies the names of the outputs to be
  retrieved from EnergyPlus.
- ``outputValueReferences``: A vector of value references for the quantities in ``outputNames``.
- ``nOut``: Number of elements of the output vector, e.g.,
  length of ``outputNames`` and ``outputValueReferences``.
- ``log``: Logging message returned on error.

For example, if a building has two zones called ``basement`` and ``office``, then the parameter names are


Configuring variables to be exchanged
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To configure the variables to be exchanged, the following data structures will be used.

.. code:: c

   const char ** parameterNames = {"basement,V", "basement,AFlo", "basement,mSenFac", "office,V", "office,AFlo", "office,mSenFac"};
   const unsigned int parameterValueReferences[] = {0, 1, 2, 3, 4, 5, 6};

The inputs into EnergyPlus will be

.. code:: c

   const char ** inputNames = {"basement,T", "basement,X", "basement,mInlets_flow", "basement,TInlet", "basement,QGaiRad_flow",
                               "office,T", "office,X", "office,mInlets_flow", "office,TInlet", "office,QGaiRad_flow"};
   const unsigned int inputValueReferences[] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16};

The outputs of EnergyPlus will be

.. code:: c

   const char ** outputNames = {"basement,TRad", "basement,QConSen_flow", "basement,QLat_flow", "basement,QPeo_flow",
                                "office,TRad", "office,QConSen_flow", "office,QLat_flow", "office,QPeo_flow"};
   const unsigned int outputValueReferences[] = {17, 18, 19, 20, 21, 22, 23, 24};

This function will read the ``idf`` file and sets up the data structure in EnergyPlus.

It returns zero if there was no error, or else a positive non-zero integer.

Setting up the experiment time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: c

   unsigned int setupExperiment(double tStart,
                                const char *log);

- ``tStart``: Start of simulation in seconds.
- ``log``: Logging message returned on error.

This functions sets the start time of EnergyPlus to the value ``tStart``.
There is no warm-up simulation. EnergyPlus will continue the simulation until
``terminate(const char *)`` (see below) is called.

It returns zero if there was no error, or else a positive non-zero integer.

.. note::

   The EnergyPlus start time is as retrieved from the argument of
   ``setupExperiment(...)``. The ``RunPeriod`` in the ``idf`` file is only
   used to determine the day of the week.

   *Possible complication*:

   Users may set ``tStart``
   to a time other than midnight. We think EnergyPlus cannot yet handle an arbitrary start time.
   In this case, it should return an error.

Setting the current time
^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: c

   unsigned int setTime(double time,
                        const char *log);

- ``time``: Model time.
- ``log``: Logging message returned on error.

This function sets a new time in EnergyPlus. This time becomes the current model time.

It returns zero if there was no error, or else a positive non-zero integer.

Sending parameters and variables to EnergyPlus
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
The vector ``valueReferences`` could be a subset of the pointer ``inputValueReferences``
that was setup in ``instantiate(...)``, i.e., ``nVars1 <= nInp``
(to allow updating only specific variables
as needed by QSS).

It returns zero if there was no error, or else a positive non-zero integer.

Retrieving parameters and variables from EnergyPlus
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
EnergyPlus must write the values to the elements that are setup in ``outputValueReferences``
during the ``instantiate(...)`` call.
``nVars2 <= nOut`` if only certain output variables are required.

It returns zero if there was no error, or else a positive non-zero integer.

Retrieving the next event time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: c

   unsigned int getNextEventTime(fmi2EventInfo *eventInfo,
                                 const char *log);

- ``eventInfo``: A structure with event info as defined in section :ref:`sec_time_sync`
- ``log``: Logging message returned on error.

This function writes a structure which contains among its variables a non-zero flag to indicate that the next event time is defined, and the next event time in EnergyPlus.

It returns zero if there was no error, or else a positive non-zero integer.

Terminating the EnergyPlus simulation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: c

   unsigned int terminate(const char *log);

- ``log``: Logging message returned on error.

This function must free all allocated variables in EnergyPlus.

Any further call to the EnergyPlus shared library is prohibited after call to this function.

It returns zero if there was no error, or else a positive non-zero integer.

Writing EnergyPlus output files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: c

   unsigned int writeOutputFiles(const char *log);

- ``log``: Logging message returned on error.


This function writes the output to the EnergyPlus output files.

It returns zero if there was no error, or else a positive non-zero integer.


Pseudo Code Example
-------------------

In the next section, the usage of the FMI functions along with the equivalent EnergyPlus functions are used in a typical calling sequence.
This should clarify the need of the EnergyPlus equivalent functions and show how these functions will be used in a simulation environment.
In the pseudo code, ``->`` points to the EnergyPlus equivalent FMI functions. ``NA`` indicates that the FMI functions do not require EnergyPlus equivalent.


.. literalinclude:: models/pseudo/pseudo.c
   :language: C
   :linenos:

Tool for Exporting EnergyPlus as an FMU
---------------------------------------

To export EnergyPlus as an FMU, a utility is needed which will get as inputs
the paths to the EnergyPlus idf, idd, and weather files.
The utility will parse the idf file and write an XML model description file
which contains the inputs, outputs, and states of EnergyPlus to be exposed
through the FMI interface.
The utility will compile the EnergyPlus FMI functions into a shared library,
and package the library with the idf, idd, and weather file in the
``resources`` folder of the FMU.
An approach to develop such a utility is to extend EnergyPlusToFMU
(http://simulationresearch.lbl.gov/fmu/EnergyPlus/export/index.html)
to support FMI 2.0 for model exchange.
Another approach is to extend SimulatorToFMU (https://github.com/LBNL-ETA/SimulatorToFMU)
to support the export of EnergyPlus.


JModelica Integration
=====================

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

   \left[\dot x_c(t), x_d(t)\right] = f(x_c(t), x_d(t^-), u_c(t), u_d(t), p, t),

   \left[y_c(t), y_d(t)\right]  = g(x_c(t), x_d(t), u_c(t), u_d(t), p, t),\\

   0          = z(x_c(t), x_d(t), u_c(t), u_d(t), p, t),\\

   \left[x_c(t_0), x_d(t_0)\right]  = [x_{c,0}, x_{d,0}],

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

   package Optimica {
   [JModelica compiler] as jmc
   }

   jmc -l-> FMU_QSS

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
-------------------

Setting individual elements of the state vector
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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

Getting derivatives of state variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First order derivatives of state variables :math:`\dot x_c(t)` in :eq:`eqn_ini_val`
can be obtained with the existing
``fmi2GetReal`` function.

Second order derivatives of state variables :math:`\ddot x_c(t)` can be obtained using directional
derivatives as

.. math::


   \ddot x_c(t) = \frac{d^2 x_c(t)}{dt^2} = \frac{\partial \dot x_c(t)}{\partial x_c} \, \dot x_c(t).


How to obtain third order derivatives of state variables :math:`\dddot x_c(t)` is not yet specified.


Event Handling
^^^^^^^^^^^^^^

.. _subsec_se:

State Events
""""""""""""

For this discussion, consider the simple model

.. code-block:: modelica

   model StateEvent2 "This model tests state event detection"
     Real x(start=-0.5, fixed=true) "State variable";
     discrete Real y(start=1.0, fixed=true "Discrete variable");
     Modelica.Blocks.Interfaces.RealInput u "Input variable";
   equation
     der(x) = y;
     when (u > x) then
       y = -1.0;
     end when;
   end StateEvent2;

with an associated entry in the ``modelDescription.xml`` file that looks like

.. code-block:: xml

   <VendorAnnotations>
     <Tool name="OCT_StateEvents">
       <EventIndicators>
         <Element index="10" reverseDependencies="44" />
       </EventIndicators>
     </Tool>
   </VendorAnnotations>

   <ModelVariables>
     <!-- Not all elements shown -->
     <!-- Variable with index #10 -->
     <ScalarVariable name="_eventIndicator_1" valueReference="42" causality="output" variability="continuous" initial="calculated">
       <Real relativeQuantity="false" />
     </ScalarVariable>
     <!-- Not all elements shown -->
     <!-- Variable with index #42 -->
     <ScalarVariable name="u" valueReference="41" description="Input variable" causality="input" variability="continuous">
       <Real relativeQuantity="false" start="0.0" />
     </ScalarVariable>
     <!-- Variable with index #43 -->
     <ScalarVariable name="x" valueReference="40" description="State variable" causality="local" variability="continuous" initial="exact">
       <Real relativeQuantity="false" start="-0.5" />
     </ScalarVariable>
     <!-- Variable with index #44 -->
     <ScalarVariable name="der(x)" valueReference="39" causality="local" variability="continuous" initial="calculated">
       <Real relativeQuantity="false" derivative="43" />
     </ScalarVariable>
     <!-- Variable with index #45 -->
       <ScalarVariable name="y" valueReference="45" causality="local" variability="discrete" initial="exact">
       <Real relativeQuantity="false" start="1.0" />
     </ScalarVariable>

   </ModelVariables>

   <ModelStructure>
     <Outputs>
       <Unknown index="10" dependencies="42 43" />
     </Outputs>
    <Derivatives>
       <Unknown index="44" dependencies="42 43" />
     </Derivatives>
     <InitialUnknowns>
       <Unknown index="10" dependencies="42 43" />
       <Unknown index="44" dependencies="" />
     </InitialUnknowns>
   </ModelStructure>

.. note:: In ``EventIndicators``, I removed ``dependencies="42 43"`` because this is already stated for the new output that
          was added for the event indicator function.

.. note:: In ``EventIndicators``, ``45`` is not part of the ``reverseDependencies`` because ``y`` is an internal variable.
          If ``y`` were declared with ``causality = output``, then it would be listed in ``reverseDependencies``.
          As a consequence, a master algorithm is only allowed to connect variables that declare ``causality = output``.


For efficiency, QSS requires knowledge of what variables an event indicator depends on,
and what variables need to be updated when an event fires.
Furthermore, QSS will need to
have access to, or else approximate numerically, the time derivatives of the
event indicator. FMI 2.0 outputs an array of real-valued event indicators,
but no variable dependencies. Therefore, JModelica added the output

.. code-block:: xml

   <!-- Variable with index #10 -->
   <ScalarVariable name="_eventIndicator_1" valueReference="42" causality="output"
                   variability="continuous" initial="calculated">
      <Real relativeQuantity="false" />
   </ScalarVariable>

This causes event indicators to become output variables, and therefore their dependency can be reported
using existing FMI 2.0 conventions.

Furthermore, JModelica added in the ``<VendorAnnotations>`` the section ``<Tool name="OCT_StateEvents">``.
The meaning of the entries in this section is as follows:

 - The section ``EventIndicators`` lists all event indicators in an ``<Element>`` section.
   Its entries are defined as follows:

   - The attribute ``index`` points to the index of the event indicator, which JModelica will add as an output
     of the FMU.
   - The attribute ``reverseDependencies`` lists the index of the variables and state derivatives that need to be updated when this
     event fires.

Note that for the event indicator, the ``dependencies`` can be obtained from the section
``<ModelStructure><Outputs>...</ModelStructure></Outputs>`` because JModelica added the event indicator as
an output variable.


Getting derivatives of event indicator functions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For some :math:`n,m \in \mathbb N`, let :math:`z \colon \Re^n \times \mathbb Z^m \times \Re \to \Re` be an event indicator function.
(For simplicity, we omitted the input and parameter dependency of :math:`z(\cdot, \cdot, \cdot)` in :eq:`eqn_ini_val`.)
Then the first order time derivative of the event indicator :math:`\dot z`
can be obtained using directional derivatives as

.. math::
   :label: eq_der_eve_ind


   \dot z(x_c(t), x_d(t), t) = \frac{\partial z(x_c(t), x_d(t), t)}{\partial x_c} \, \dot x_c(t) + \frac{\partial z(x_c(t), x_d(t), t)}{\partial t}.

.. note:: To get :math:`\frac{\partial z(x_c(t), x_d(t), t)}{\partial t}`, we need to add an output :math:`\frac{\partial z(x_c(t), x_d(t), t)}{\partial t}`
          unless it requires a derivative of an input. In this situation, the QSS solver will detect the missing
          derivative information from the XML file and numerically approximate
          the event indicator derivatives.

How to obtain second order derivatives of the event indicator functions :math:`\ddot z(x_c(t), x_d(t), t)` is not yet specified.


Test models
^^^^^^^^^^^

This section lists test cases that are corner cases for QSS.

Model with two conditions that fire an event
""""""""""""""""""""""""""""""""""""""""""""

Consider the following model


.. literalinclude:: ../../models/modelica_for_qss/QSS/Docs/StateEvent1.mo
   :language: modelica


In this model, two conditions need to be satisfied
for an event to fire.

.. _subsec_te:

Event indicators that depend on the input
"""""""""""""""""""""""""""""""""""""""""

Consider the following model

.. literalinclude:: ../../models/modelica_for_qss/QSS/Docs/StateEvent2.mo
   :language: modelica

This model has one event indicator :math:`z = u-x`.
The derivative of the event indicator is :math:`{dz}/{dt} = {du}/{dt} - {dx}/{dt}`.

Hence, a tool requires the derivative of the input ``u``
to compute the derivative of the event indicator.
Since the derivative of the input ``u`` is unkown in the FMU,
we propose for cases where the event indicator
has a direct feedthrough on the input to not add time derivatives of
event indicators as outputs.
In this situation, the QSS solver will detect the missing
information from the XML file and numerically approximate
the event indicator derivatives.


Handling of variables reinitialized with ``reinit()``
"""""""""""""""""""""""""""""""""""""""""""""""""""""


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


.. note::

  Per design, Dymola (2018) generates twice as many event indicators as actually existing in the model.
  Hence the master algorithm shall detect if the tool which exported the FMU is Dymola, and if it is, the
  number of event indicators shall be equal to half the value of the ``numberOfEventIndicators`` attribute.

Time Events
"""""""""""

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

We therefore propose that JModelica turns all time events into state events and
adds new event indicators as output variables.

.. note::

   All proposed XML changes will be initially implemented
   in the ``VendorAnnotation`` element of the model description file until
   they got approved and included in the FMI standard.

SmoothToken for QSS
^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^

**To be updated**

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
^^^^^^^^^^^

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
======================

.. note:: This section needs to be revised in view of the move towards a json-driven architecture.

.. include:: automatedDocAstTool.rst
