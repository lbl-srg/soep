.. _sec_soft_arch:

*********************
Software Architecture
*********************

This section describes the overall software architecture (:numref:`sec_ove_sof_arc`),
the coupling of Modelica with EnergyPlus (:numref:`sec_cou_ene_mod`),
the integration of the QSS solver with JModelica (:numref:`sec_qss_jmo_int`), and
the OpenStudio integration (:numref:`sec_int_ope_stu`).

.. _sec_ove_sof_arc:

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


.. _sec_cou_ene_mod:

Coupling of EnergyPlus with Modelica
====================================

This section describes the coupling of EnergyPlus with Modelica.
The coupling allows two types of interactions between the two tools:

1. The EnergyPlus envelope model can be coupled with the Modelica room model,
   which in turn is coupled to Modelica HVAC and interzone air exchange.
   This is described in :numref:`sec_cou_env`.
2. EnergyPlus output variables and energy management system output variables
   can be sent from EnergyPlus to Modelica.
   This is described in :numref:`sec_out_var`.
3. The values of EnergyPlus schedules, EMS variables and EMS actuators can be set
   from Modelica.
   This is described in :numref:`sec_sen_var`.

Users will set up this data exchange by instantiating corresponding
Modelica models or blocks. These Modelica instances will then
communicate with EnergyPlus, using Modelica C function calls.
EnergyPlus will be called using a dynamically linked library, with
C functions that conform to the FMI 2.0 for Model Exchange standard
as far as possible. The main difference between our implementation
and FMI 2.0 for Model Exchange is that EnergyPlus is not writing
a ``modelDescription.xml`` file and is not packaged as a zip file.
Rather, we load directly the EnergyPlus library and set up the
data I/O by sending from Modelica the objects required from EnergyPlus.


Assumptions and limitations
---------------------------

To implement the coupling, will make the following assumption:

1. Only the lumped room air model will be refactored, not the
   room model with stratified room air.
   The reason is to keep focus and make progress before increasing complexity.
2. The HVAC and the pressure driven air exchange (airflow network) are
   either in Modelica or EnergyPlus.
   The two methods cannot be combined.
   The reason is that the legacy EnergyPlus computes in its "predictor/corrector"
   the room temperature as follows:

   a. It computes the HVAC power required to meet the temperature set point.
   b. It simulates the HVAC system to see whether it can meet this load.
   c. It updates the room temperature using the HVAC power from step (b).

   This is fundamentally different from the ODE solver used by SOEP who sets the new
   room temperature and time, computes the time derivative, and then recomputes
   the new time step.
3. In each room, mass, as opposed to volume, is conserved.
   The reason is that this does not induce an air flow in the HVAC system if
   the room temperature changes. Hence, it decouples the thermal and the mass balance.

Unit system
-----------

Modelica and EnergyPlus each have their own unit systems. The unit conversion
will be done in the C functions that call the EnergyPlus library. These
C functions will convert between the units shown in :numref:`tab_uni_spe`.
The table also shows unit strings that are allowed to use by EnergyPlus
to tell Modelica the unit of the exchanged inputs and outputs.
The C functions will then convert the quantity as needed to represent
it in the units shown in the column `Modelica Unit`.

For composed units, EnergyPlus uses in the output dictonary unit strings
such as ``W/m2-K``. Therefore, we make the following conventions for the
EnergyPlus unit string that is sent to Modelica:

1. First, all units in the numerator are listed, and then all
   units in the denominator, separated by a slash, such as ``W/m``.
2. In the EnergyPlus unit string, multiplications of units are denoted by a dash, such as in ``m-K``.
3. Exponents are denoted by an integer that follows the quantity, such as ``m2``.
4. No brackets are allowed, e.g., use ``W/m2-K`` to denote :math:`\mathrm{W/(m^2 \, K)`.
5. No prefixes are allowed such as ``m`` for milli, other than for mass, which is reported as
   ``kg``.

.. _tab_uni_spe:

.. table:: Unit specification of EnergyPlus I/O.

   +------------------------+------------------+---------------------------------+
   | Quantity               | EnergyPlus       | Modelica Unit                   |
   |                        | Unit String      |                                 |
   +========================+==================+=================================+
   | Angle (rad)            | rad              | rad                             |
   +------------------------+------------------+---------------------------------+
   | Angle (deg)            | deg              | rad                             |
   +------------------------+------------------+---------------------------------+
   | Energy                 | J                | J                               |
   +------------------------+------------------+---------------------------------+
   | Illuminance            | lux              | lm/m2                           |
   +------------------------+------------------+---------------------------------+
   | Humidity (absolute)    | kgWater/kgDryAir | 1 (converted to mass fraction   |
   |                        |                  | per total mass of moist air)    |
   +------------------------+------------------+---------------------------------+
   | Humidity (relative)    | %                | 1                               |
   +------------------------+------------------+---------------------------------+
   | Luminous flux          | lum              | cd.sr                           |
   +------------------------+------------------+---------------------------------+
   | Mass                   | kg               | kg                              |
   +------------------------+------------------+---------------------------------+
   | Mass flow rate         | kg/s             | kg/s                            |
   +------------------------+------------------+---------------------------------+
   | Power                  | W                | W                               |
   +------------------------+------------------+---------------------------------+
   | Pressure               | Pa               | Pa                              |
   +------------------------+------------------+---------------------------------+
   | Status (e.g., rain)    | (no character)   | 1                               |
   +------------------------+------------------+---------------------------------+
   | Temperature            | K                | C                               |
   +------------------------+------------------+---------------------------------+
   | Temperature (absolute) | K                | K                               |
   +------------------------+------------------+---------------------------------+
   | Time                   | s                | s                               |
   +------------------------+------------------+---------------------------------+
   | Transmittance,         | (no character,   | 1                               |
   | reflectance, and       | specified as a   |                                 |
   | absorptance            | value between 0  |                                 |
   |                        | and 1)           |                                 |
   +------------------------+------------------+---------------------------------+
   | Volume                 | m3               | m3                              |
   +------------------------+------------------+---------------------------------+
   | Volume flow rate       | m3/s             | m3/s                            |
   +------------------------+------------------+---------------------------------+

If a unit is sent that is not in this list or can be composed of using
multiplications and divisions of units in this list,
the simulation will stop with an error.
For example, if EnergyPlus were to specify ``N`` for Newton, the simulation
will stop. Rather, EnergyPlus should specify the quantity in its base unit ``kg-m/s2``.

Partitioning of the models
--------------------------

To link EnergyPlus and Modelica, we partition the models
as shown in :num:`Figure #fig-partition-envelop-room-hvac`.

.. _fig-partition-envelop-room-hvac:

.. figure:: img/envelop-room-hvac.*
   :scale: 100 %

   Partitioning of the envelope, room and HVAC model.

The EnergyPlus API conforms to the FMI for Model Exchange 2.0 specification.
However, additional function calls are needed during the instantiation
to allow us to declare in Modelica the types of objects that are needed
to be instantiated by EnergyPlus. Without this additional function,
one would have to declare these objects in the idf file,
which would be an additional burden on the user and increase
the complexity of the tool coupling.

We will now describe how to couple the room model and the controls inputs and
outputs.

.. _sec_cou_env:

Coupling of envelope model
^^^^^^^^^^^^^^^^^^^^^^^^^^

To couple the Modelica room model to the EnergyPlus envelope model,
the following parameters are sent from EnergyPlus to Modelica. These are sent only once during the initialization for each thermal zone.

+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| Variable                  | Quantity                                                                                                    | Unit            |
+===========================+=============================================================================================================+=================+
| *From Modelica to EnergyPlus*                                                                                                                             |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| Type                      | String with value ``Zone``.                                                                                 |                 |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| Zone name                 | String with the name of an EnergyPlus zone. This name must be present in the idf file.                      |                 |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| String for volume         | String with value ``V``, specifying that EnergyPlus needs to return the volume of the zone.                 |                 |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| String for floor area     | String with value ``AFlo``, specifying that EnergyPlus needs to return the floor area of the zone.          |                 |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| String for mSenFac        | String with value ``mSenFac``, specifying that EnergyPlus needs to return the scaling factor for the        |                 |
|                           | sensible thermal mas of the zone air volume.                                                                |                 |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| *From EnergyPlus to Modelica*                                                                                                                             |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| V                         | Volume of the zone air.                                                                                     |   m3            |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| AFlo                      | Floor area of the zone.                                                                                     |   m2            |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| mSenFac                   | Factor for scaling the sensible thermal mass of the zone air volume.                                        |   1             |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+

The above string arguments will be used as described in :numref:`sec_int_c_api`.

The following time-dependent variables are exchanged between EnergyPlus and Modelica during the time integration
for each thermal zone.

+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| Variable                  | Quantity                                                                                                    | Unit            |
+===========================+=============================================================================================================+=================+
| *From Modelica to EnergyPlus*                                                                                                                             |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| T                         | Temperature of the zone air.                                                                                |   degC          |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| X                         | Water vapor mass fraction per total air mass of the zone.                                                   |   kg/kg         |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| mInlets_flow              | Sum of positive mass flow rates into the zone for all air inlets (including infiltration).                  |   kg/s          |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| TInlet                    | Average of inlets medium temperatures carried by the mass flow rates.                                       |   degC          |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| QGaiRad_flow              | Radiative sensible heat gain added to the zone.                                                             |   W             |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| t                         | Model time at which the above inputs are valid, with :math:`t=0` defined as January 1, 0 am local time,     |   s             |
|                           | and with                                                                                                    |                 |
|                           | no correction for daylight savings time.                                                                    |                 |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| *From EnergyPlus to Modelica*                                                                                                                             |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| TRad                      | Average radiative temperature in the room.                                                                  |   degC          |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| QConSen_flow              | Convective sensible heat added to the zone, e.g., from surface convection and from                          |   W             |
|                           | the EnergyPlus' ``People`` or ``Equipment`` schedule.                                                       |                 |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| QLat_flow                 | Latent heat gain added to the zone, e.g., from mass transfer with moisture buffering material and           |   W             |
|                           | from EnergyPlus' ``People`` schedule.                                                                       |                 |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| QPeo_flow                 | Heat gain due to people (only to be used to optionally compute CO2 emitted by people).                      |   W             |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+
| nextEventTime             | Model time :math:`t` when EnergyPlus needs to be called next (typically the next zone time step).           |   s             |
+---------------------------+-------------------------------------------------------------------------------------------------------------+-----------------+

Note that the EnergyPlus object ``ZoneAirContaminantBalance`` either allows CO2 concentration modeling,
or a generic contaminant modeling (such as from material outgasing),
or no contaminant modeling, or both. To avoid ambiguities regarding what contaminant
is being modeled, we do not receive the contaminant emission from EnergyPlus.
Instead, we obtain the heat gain due to people, which is then used to optionally compute the
CO2 emitted by people.

For this coupling, all zones of EnergyPlus will be accessed from Modelica.
For example, if a building has two zones, then both zones need to be modeled in Modelica.

The calling sequences of the functions that send data to EnergyPlus and read data from EnergyPlus is
as for any :term:`continuous-time variable` in FMI. That is, at any time instant,
variables can be set multiple times, and the values returned by EnergyPlus must reflect
to updated input variables. (Multiple calls within a time step are used to compute
the derivative of ``QConSen_flow`` with respect to ``T``.)


.. _sec_out_var:

Retrieving output variables from EnergyPlus
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section describes how to retrieve in Modelica values from the EnergyPlus objects
``Output:Variable`` and ``EnergyManagementSystem:OutputVariable``.

For reference, although not required to be specified for this coupling,
we state how to instantiate the EnergyPlus object that exposes a variable
at the FMI API of EnergyPlus. The idf snippet is as follows:

.. code::

   ExternalInterface:FunctionalMockupUnitExport:From:Variable,
     Environment,                           !- EnergyPlus Key Value
     Site Outdoor Air Drybulb Temperature,  !- EnergyPlus Variable Name
     TDryBul;                               !- FMU Variable Name

For the Modelica coupling, this need not be specified in the idf file,
and the last argument is not needed.
The following parameters are sent from Modelica to EnergyPlus. These are sent only once during the instantiation of EnergyPlus.
No entry in the idf file is required.

+---------------------------+--------------------------------------------------------------------------------------------------+
| Variable                  | Quantity                                                                                         |
+===========================+==================================================================================================+
| *From Modelica to EnergyPlus*                                                                                                |
+---------------------------+--------------------------------------------------------------------------------------------------+
| Type                      | String with value ``From:Output``.                                                               |
+---------------------------+--------------------------------------------------------------------------------------------------+
| Key value                 | String, if it is an ``Output:Variable``, its values will be as in the ``.rdd`` or ``.mdd`` file. |
|                           | If it is an ``EnergyManagementSystem:OutputVariable``, its value will be ``EMS``.                |
+---------------------------+--------------------------------------------------------------------------------------------------+
| Variable name             | String, if it is an ``Output:Variable``, its values will be as in the Input Output Reference.    |
|                           | If it is an ``EnergyManagementSystem:OutputVariable`` its value will be                          |
|                           | the name of the ``EnergyManagementSystem:OutputVariable``.                                       |
+---------------------------+--------------------------------------------------------------------------------------------------+
| *From EnergyPlus to Modelica*                                                                                                |
+---------------------------+--------------------------------------------------------------------------------------------------+
| EnergyPlus unit string    | String with the unit of this quantity (see :numref:`tab_uni_spe`).                               |
+---------------------------+--------------------------------------------------------------------------------------------------+

There will be a Modelica block called ``From.OutputVariable`` with parameters

+---------------------------+--------------------------------------------------------------------------------------------------+
| Name                      | Comment                                                                                          |
+===========================+==================================================================================================+
| key                       | EnergyPlus key value, as defined by the EnergyPlus .rdd or .mdd file                             |
+---------------------------+--------------------------------------------------------------------------------------------------+
| name                      | EnergyPlus variable name, as defined in the EnergyPlus Input Output Reference                    |
+---------------------------+--------------------------------------------------------------------------------------------------+

There will also be a block called ``From.EnergyManagementOutputVariable`` with parameters

+---------------------------+--------------------------------------------------------------------------------------------------+
| Name                      | Comment                                                                                          |
+===========================+==================================================================================================+
| name                      | Name of the ``EnergyManagementSystem:OutputVariable``                                            |
+---------------------------+--------------------------------------------------------------------------------------------------+

At each invocation of the function ``fmi2GetReal``, EnergyPlus will send the output variable that is computed for
the current time and all the values set with ``fmi2SetReal``.
During the initialization, EnergyPlus will send an initial value to Modelica.

.. note:: The EnergyPlus Runtime Language (ERL) has no notion of real versus integer (or boolean) variables. Therefore,
          we retrieve only real values.
          While the ERL has built-in variables ``True`` and ``False`` and ``On`` and ``Off``, ERL represents them
          as a real value.

For Modelica, reading variables will be done using a block with no input and one output.

We assume that these variables are :term:`discrete-time variables<discrete-time variable>`
and hence change their values only at events. Specifically, if
:math:`y(\cdot)` is a variable of time that is computed in EnergyPlus
that is sampled at some time instant :math:`t`,
then Modelica will retrieve :math:`y(t^+)`, where
:math:`t^+ = (\lim_{\epsilon \to 0} (t+\epsilon), t_{I_{max}})` and
:math:`I_{max}` is the largest occurring integer of :term:`superdense time`.

The Modelica pseudo-code is

.. code-block:: modelica

   when {initial(), time >= pre(tNext)} then
     (y, tNext) = readFromEnergyPlus(adapter, time);
   end when;

where ``adapter`` stores the data structure used to communicate with EnergyPlus.


.. _sec_sen_var:

Sending input to EnergyPlus
^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section describes how to send Modelica values to the EnergyPlus objects
``ExternalInterface:FunctionalMockupUnitExport:To:Schedule``,
``ExternalInterface:FunctionalMockupUnitExport:To:Actuator``, and
``ExternalInterface:FunctionalMockupUnitExport:To:Variable``.

For reference, examples of instances in EnergyPlus for these objects are
as follows.

.. code::

   ExternalInterface:FunctionalMockupUnitExport:To:Schedule,
     OfficeSensibleGain,                           !- EnergyPlus Schedule Name
     Any Number,                                   !- Schedule Type Limits Names
     QSensible,                                    !- FMU Variable Name
     0;                                            !- Initial Value

   ExternalInterface:FunctionalMockupUnitExport:To:Actuator,
     Zn001_Wall001_Win001_Shading_Deploy_Status,   !- EnergyPlus Variable Name
     Zn001:Wall001:Win001,                         !- Actuated Component Unique Name
     Window Shading Control,                       !- Actuated Component Type
     Control Status,                               !- Actuated Component Control Type
     yShade,                                       !- FMU Variable Name
     6;                                            !- Initial Value

   ExternalInterface:FunctionalMockupUnitExport:To:Variable,
     Shade_Signal,                                 !- EnergyPlus Variable Name
     yShade,                                       !- FMU Variable Name
     1;                                            !- Initial Value

For the Modelica coupling, these objects need not be declared in the idf file.

For Modelica, exchanging variables with these objects will be done
using a Modelica block that has only one input and no output,
or no input and only one output.

As in :numref:`sec_out_var`,
we assume that these variables are :term:`discrete-time variables<discrete-time variable>`
and hence change their values only at events. Specifically, if
:math:`u(\cdot)` is a variable of time that is computed in Modelica
that is sampled at some time instant :math:`t`,
then Modelica will send :math:`u(\mathbin{^-t})`, where
:math:`\mathbin{^-t} = (\lim_{\epsilon \to 0} (t-\epsilon), 0)`.

With this construct, there is no iteration needed if a control loop is closed
between Modelica and EnergyPlus that uses outputs from :numref:`sec_out_var`
and inputs from this section.
To see this, consider
a controller in Modelica that will send
a control signal :math:`u(t)` and retrieve from EnergyPlus a measured
quantity :math:`y(t)`, such as a PI controller in Modelica that actuates
the shade slat angle in EnergyPlus based on indoor illuminance reported by EnergyPlus.
Then, at the time instant :math:`t`,
Modelica will send :math:`u(\mathbin{^-t})`
and it will retrieve :math:`y(t^+)`. Hence, no iteration
across the tools is required. At the next sample time, Modelica will
send the update control action that depends on :math:`y(t^+)` to EnergyPlus.
This simple example also illustrates that inputs and outputs need for certain
applications be exchanged at a sampling rate that is below the EnergyPlus zone time step.


.. _sec_inp_sch:

Schedules
"""""""""

For writing to schedules,
the following parameters are sent from Modelica to EnergyPlus. These are sent only once during the instantiation of EnergyPlus.
No entry in the idf file is required.

+---------------------------+--------------------------------------------------------------------------------------------------+
| Variable                  | Quantity                                                                                         |
+===========================+==================================================================================================+
| *From Modelica to EnergyPlus*                                                                                                |
+---------------------------+--------------------------------------------------------------------------------------------------+
| Type                      | String with value ``To:Schedule``.                                                               |
+---------------------------+--------------------------------------------------------------------------------------------------+
| Schedule name             | String with the value of an EnergyPlus schedule.                                                 |
+---------------------------+--------------------------------------------------------------------------------------------------+
| *From EnergyPlus to Modelica*                                                                                                |
+---------------------------+--------------------------------------------------------------------------------------------------+
| EnergyPlus unit string    | String with the unit of this quantity (see :numref:`tab_uni_spe`).                               |
+---------------------------+--------------------------------------------------------------------------------------------------+


.. note:: As EnergyPlus has no notion of real versus integer (or boolean) variables,
          values will be sent as doubles.

Modelica will send the initial value to EnergyPlus as in the following pseudo-code:

.. code-block:: C

   ...
   M_fmi2SetTime(m, time)
   // set all variable start values (of "ScalarVariable / <type> / start") and
   // set the input values at time = Tstart
   M_fmi2SetReal(m, ...)
   // initialize
   // determine continuous and discrete states
   M_fmi2SetupExperiment(m, fmi2False, 0.0, Tstart, fmi2True, Tend)
   ...


There will be a Modelica block called ``To.Schedule`` with parameters

+---------------------------+--------------------------------------------------------------------------------------------------+
| Name                      | Comment                                                                                          |
+===========================+==================================================================================================+
| idfName                   | Name of the idf file that contains this schedule.                                                |
+---------------------------+--------------------------------------------------------------------------------------------------+
| name                      | Name of an EnergyPlus schedule that is present in the idf file.                                  |
+---------------------------+--------------------------------------------------------------------------------------------------+

.. todo:: Do we really need an instance of a schedule in the idf file in order to write to EnergyPlus?
          Would a user really set up a schedule, just to overwrite it?

The Modelica pseudo-code is

.. code-block:: modelica

   when sample(t0, samplePeriod) then
      sendScheduleToEnergyPlus(pre(u), adapter);
   end when;

where
``t0`` is the start of the simulation,
``samplePeriod`` is the sample period if this block, and
``pre(u)`` is the value of the input before ``sample(t0, samplePeriod)`` becomes ``true``.


Actuators
"""""""""

For writing to EMS actuators,
the following parameters are sent from Modelica to EnergyPlus. These are sent only once during the instantiation of EnergyPlus.
No entry in the idf file is required.


+---------------------------------+--------------------------------------------------------------------------------------------+
| Variable                        | Quantity                                                                                   |
+=================================+============================================================================================+
| *From Modelica to EnergyPlus*                                                                                                |
+---------------------------------+--------------------------------------------------------------------------------------------+
| Type                            | String with value ``To:Actuator``.                                                         |
+---------------------------------+--------------------------------------------------------------------------------------------+
| Variable name                   | String with the value of the EnergyPlus variable name.                                     |
+---------------------------------+--------------------------------------------------------------------------------------------+
| Component name                  | String with the actuated component unique name.                                            |
+---------------------------------+--------------------------------------------------------------------------------------------+
| Actuated component type         | String with the actuated component type.                                                   |
+---------------------------------+--------------------------------------------------------------------------------------------+
| Actuated component control type | String with the actuated component control type.                                           |
+---------------------------------+--------------------------------------------------------------------------------------------+
| *From EnergyPlus to Modelica*                                                                                                |
+---------------------------------+--------------------------------------------------------------------------------------------+
| EnergyPlus unit string          | String with the unit of this quantity (see :numref:`tab_uni_spe`).                         |
+---------------------------------+--------------------------------------------------------------------------------------------+


.. todo:: Why is the *Variable name* needed? Should this be left out?

.. note:: As the ERL has no notion of real versus integer (or boolean) variables,
          values will be sent as doubles.

Modelica will send the initial value as for ``To:Schedule``.


There will be a Modelica block called ``To.Actuator`` with parameters

+---------------------------+--------------------------------------------------------------------------------------------------+
| Name                      | Comment                                                                                          |
+===========================+==================================================================================================+
| idfName                   | Name of the idf file that contains this actuator.                                                |
+---------------------------+--------------------------------------------------------------------------------------------------+
| variableName              | Name of the EnergyPlus variable.                                                                 |
+---------------------------+--------------------------------------------------------------------------------------------------+
| componentName             | Name of the actuated component unique name.                                                      |
+---------------------------+--------------------------------------------------------------------------------------------------+
| componentType             | Actuated comonent type.                                                                          |
+---------------------------+--------------------------------------------------------------------------------------------------+
| controlType               | Actuated component control type.                                                                 |
+---------------------------+--------------------------------------------------------------------------------------------------+

The Modelica pseudo-code is

.. code-block:: modelica

   when sample(t0, samplePeriod) then
      sendActuatorToEnergyPlus(pre(u), adapter);
   end when;

where ``pre(u)`` is the value of the input before ``sample(t0, samplePeriod)`` becomes ``true``.


Variables
"""""""""

For writing to EMS variables,
the following parameters are sent from Modelica to EnergyPlus. These are sent only once during the instantiation of EnergyPlus.
No entry in the idf file is required.


+---------------------------------+--------------------------------------------------------------------------------------------+
| Variable                        | Quantity                                                                                   |
+=================================+============================================================================================+
| *From Modelica to EnergyPlus*                                                                                                |
+---------------------------------+--------------------------------------------------------------------------------------------+
| Type                            | String with value ``To:Variable``                                                          |
+---------------------------------+--------------------------------------------------------------------------------------------+
| Variable name                   | String with the value of the EnergyPlus variable name                                      |
+---------------------------------+--------------------------------------------------------------------------------------------+
| *From EnergyPlus to Modelica*                                                                                                |
+---------------------------------+--------------------------------------------------------------------------------------------+
| EnergyPlus unit string          | String with the unit of this quantity (see :numref:`tab_uni_spe`).                         |
+---------------------------------+--------------------------------------------------------------------------------------------+


.. note:: As EnergyPlus has no notion of real versus integer (or boolean) variables,
          values will be sent as doubles.

Modelica will send the initial value as for ``To:Schedule``.


There will be a Modelica block called ``To.Variable`` with parameters

+---------------------------+--------------------------------------------------------------------------------------------------+
| Name                      | Comment                                                                                          |
+===========================+==================================================================================================+
| idfName                   | Name of the idf file that contains this variable.                                                |
+---------------------------+--------------------------------------------------------------------------------------------------+
| variableName              | Name of the EnergyPlus variable                                                                  |
+---------------------------+--------------------------------------------------------------------------------------------------+

The Modelica pseudo-code is

.. code-block:: modelica

   when sample(t0, samplePeriod) then
      sendVariableToEnergyPlus(pre(u), adapter);
   end when;

where ``pre(u)`` is the value of the input before ``sample(t0, samplePeriod)`` becomes ``true``.


.. todo:: General question: Is reusing these EnergyPlus objects the right approach?
          E.g., why instantiating a schedule, just to overwrite it? While this was fine
          when we had an external interface to overwrite values, now we want a tighter
          coupling.

.. _sec_time_sync:

Time synchronization
--------------------

.. todo:: Verify that this is what the C code does.

.. _fig-fmi-me-20-state-machine:

.. figure:: img/StateMachineModelExchange.*
   :scale: 100 %

   Calling sequence of Model Exchange C functions in form of an UML 2.0 state machine (Figure
   reproduced from :cite:`modelisar2014`.

:numref:`fig-fmi-me-20-state-machine` shows the state machine for calling an FMU 2.0 for Model Exchange.
To communicate with EnergyPlus, we are using the same API and calling sequence.
As shown in :numref:`fig-partition-envelop-room-hvac`, the EnergyPlus FMU is invoked
at a variable time step.
Therefore, data is exchanged within the mode labelled *Continuous Time Mode* in :numref:`fig-fmi-me-20-state-machine`.
Internally, EnergyPlus samples its heat conduction model at the envelope time step :math:`\Delta t_z`.
EnergyPlus needs to report this to the FMI interface. To report such time events,
the FMI interface uses a C structure called ``fmi2EventInfo`` which is implemented as follows:

.. code-block:: c

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

In contrast, reading outputs and sending inputs to schedule, EMS variables and EMS actuators,
happens in the mode labelled *EventMode*.
This allows to avoid algebraic loops that may be formed by adding a controller
between an EnergyPlus output and an EnergyPlus input, as described in :numref:`sec_sen_var`.


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

   - the variable described as ``t`` in the table of section :numref:`sec_cou_env`,
   - a monotonically increasing variable.

.. note::

    Monotonically increasing means that if a function has as argument ``time`` and is called at time ``t1``, then its next call must happen at time ``t2`` with ``t2`` >= ``t1``.
    For efficiency reasons, if a function which updates internal variables is called at the same time instant multiple times,
    then only the first call will update the variables, subsequent calls will cause the functions to return the same variable values.


.. _sec_int_c_api:

Instantiation
^^^^^^^^^^^^^

.. code-block:: c

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

This function will read the ``idf`` file and sets up the data structure in EnergyPlus.

It returns zero if there was no error, or else a positive non-zero integer.


We will now describe how to the exchanged variables are configured.

Envelope model
""""""""""""""

To configure the variables to be exchanged for the envelope model described in :numref:`sec_cou_env`,
the following data structures will be used for a building with a zone called ``basement`` and a zone called ``office``.

.. code-block:: c

   const char ** parameterNames = {"zone,basement,V",
                                   "zone,basement,AFlo",
                                   "zone,basement,mSenFac",
                                   "zone,office,V",
                                   "zone,office,AFlo",
                                   "zone,office,mSenFac"};
   const unsigned int parameterValueReferences[] = {0, 1, 2, 3, 4, 5, 6};

The inputs into EnergyPlus will be

.. code-block:: c

   const char ** inputNames = {"zone,basement,T", "zone,basement,X", "zone,basement,mInlets_flow",
                               "zone,basement,TInlet", "zone,basement,QGaiRad_flow",
                               "zone,office,T", "office,X", "zone,office,mInlets_flow",
                               "zone,office,TInlet", "zone,office,QGaiRad_flow"};
   const unsigned int inputValueReferences[] = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16};

The outputs of EnergyPlus will be

.. code-block:: c

   const char ** outputNames = {"zone,basement,TRad",      "zone,basement,QConSen_flow",
                                "zone,basement,QLat_flow", "zone,basement,QPeo_flow",
                                "zone,office,TRad",        "zone,office,QConSen_flow",
                                "zone,office,QLat_flow",   "zone,office,QPeo_flow"};
   const unsigned int outputValueReferences[] = {17, 18, 19, 20, 21, 22, 23, 24};


Output variables
""""""""""""""""

To configure the data exchange for output variables, as described in :numref:`sec_out_var`,
consider an example where one wants to retrieve the outdoor drybulb temperature from EnergyPlus.
Then, the following functions will be called during the instantiation, where we added the suffix
``,Unit`` or ``,Value`` to indicate what quantity to return.

.. code-block:: c

   const char ** parameterNames = {"From:Output,Environment,Site Outdoor Air Drybulb Temperature,Unit"};
   const unsigned int parameterValueReferences[] = {0};

   const char ** outputNames = {"From:Output,Environment,Site Outdoor Air Drybulb Temperature,Value"};
   const unsigned int outputValueReferences[] = {1};

Schedules, EMS actuators and EMS variables
""""""""""""""""""""""""""""""""""""""""""

To configure the data exchange with a schedule, as described in :numref:`sec_inp_sch`,
consider the example where we want to write to a schedule called ``OfficeSensibleGain``.
Then, the following functions will be called during the instantiation, where we added the suffix
``,Unit`` or ``,Value`` to indicate what quantity to return.

.. code-block:: c

   const char ** parameterNames = {"To:Schedule,OfficeSensibleGain,Unit"};
   const unsigned int parameterValueReferences[] = {0};

   const char ** inputNames = {"To:Schedule,OfficeSensibleGain,Value"};
   const unsigned int inputValueReferences[] = {1};

EMS actuators and EMS variables have a similar configuration.

Setting up the experiment time
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: c

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

.. code-block:: c

   unsigned int setTime(double time,
                        const char *log);

- ``time``: Model time.
- ``log``: Logging message returned on error.

This function sets a new time in EnergyPlus. This time becomes the current model time.

It returns zero if there was no error, or else a positive non-zero integer.

Sending parameters and variables to EnergyPlus
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: c

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

.. code-block:: c

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

.. code-block:: c

   unsigned int getNextEventTime(fmi2EventInfo *eventInfo,
                                 const char *log);

- ``eventInfo``: A structure with event info as defined in section :ref:`sec_time_sync`
- ``log``: Logging message returned on error.

This function writes a structure which contains among its variables a non-zero flag to indicate that the next event time is defined, and the next event time in EnergyPlus.

It returns zero if there was no error, or else a positive non-zero integer.

Terminating the EnergyPlus simulation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: c

   unsigned int terminate(const char *log);

- ``log``: Logging message returned on error.

This function must free all allocated variables in EnergyPlus.

Any further call to the EnergyPlus shared library is prohibited after call to this function.

It returns zero if there was no error, or else a positive non-zero integer.

Writing EnergyPlus output files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: c

   unsigned int writeOutputFiles(const char *log);

- ``log``: Logging message returned on error.


This function writes the output to the EnergyPlus output files.

It returns zero if there was no error, or else a positive non-zero integer.


Pseudo Code Example
-------------------

In the next section, the usage of the FMI functions along with the equivalent EnergyPlus functions are used in a typical calling sequence.
This should clarify the need of the EnergyPlus equivalent functions and show how these functions will be used in a simulation environment.
In the pseudo code, ``->`` points to the EnergyPlus equivalent FMI functions. ``NA`` indicates that the FMI functions do not require EnergyPlus equivalent.

.. todo:: The code below needs to be revised.

.. literalinclude:: models/pseudo/pseudo.c
   :language: C
   :linenos:


.. _sec_qss_jmo_int:

Integration of QSS solver with JModelica
========================================

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

.. code-block:: XML
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
^^^^^^^^^^^^^^

.. _subsec_se:

State Events
""""""""""""

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
"""""""""""""""""""""""""""""""""""""""""


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

Workaround for implementing event indicators
""""""""""""""""""""""""""""""""""""""""""""

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

We therefore propose that JModelica turns all time events into state events,
add new event indicators generated by those state events to the ``<EventIndicators>``
element, and include those event indicators to the ``eventIndicatorsDependencies`` attribute
of state derivatives which depend on them.

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

.. _sec_int_ope_stu:

Integration with OpenStudio
===========================

.. note:: This section needs to be revised in view of the move towards a json-driven architecture.

.. include:: automatedDocAstTool.rst
