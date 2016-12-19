.. _sec_soft_arch:

Software Architecture
---------------------

OpenStudio integration
^^^^^^^^^^^^^^^^^^^^^^

:numref:`fig_overall_software_architecture_one_editor`
and 
:numref:`fig_overall_software_architecture_two_editors` show the overall
software architecture of SOEP, either with one or with two
HVAC and control editors.

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
Our integration either generates C++ code that would need to
compiled which a C++ compiler, or the OpenStudio Model Library
could be changed to allow dynamic loading of models for
the SOEP mode.
Note that the JModelica distribution includes a C++ compiler.

.. note::

   #. Whether the `Conversion Script` and the `Schematic Editor`
      access `JModelica` to get the AST, or whether they read
      the AST from `Modelica Library AST` does not affect
      the functionality, but it affects the architecture.
      In :numref:`fig_overall_software_architecture_two_editors`
      we show the architecture if the `Modelica Library AST` is parsed
      directly using JModelica rather than storing it in a file.


   #. The architecture shows two graphical editors for HVAC systems.
      Ideally, we would combine them into one graphical editor. Whether this
      is feasible will depend on the modeling support that the refactored
      OpenStudio `HVAC System Editor` will provide.
         

.. _fig_overall_software_architecture_two_editors:

.. uml::
   :caption: Overall software architecture (with two editors for the SOEP mode).

   title Overall software architecture (with two editors for the SOEP mode).

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

   EnergyPlus <.. [EnergyPlus\nSimulator Interface]: writes inputs,\nruns simulation,\nreads outputs
   package EnergyPlus {
     [in.idf] -> [EnergyPlus.exe]
     [EnergyPlus.exe] -> [eplusout.sql]
   }

   package SOEP {
   [Schematic Editor] ..> [JModelica] : parses\nAST
   [HVAC Systems Editor\n(SOEP Mode)] ..> [Schematic Editor]: calls editor,\nwhich returns\n.mo file
   [SOEP\nModel Library] <.. [Conversion Script]: augments library\nby generating C++ code

   [Conversion Script] ..> [JModelica]: parses\nAST
   [SOEP\nSimulator Interface] ..> [JModelica] : writes inputs,\nruns simulation,\nreads outputs
   database "Modelica\nLibrary AST"
   database "Modelica\nBuildings Library"
   [HVAC Systems Editor\n(SOEP Mode)] ..> [Modelica\nLibrary AST]: reads AST
   [Modelica\nLibrary AST] <.. [Conversion Script] : generates\nAST
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



   note right of [Schematic Editor]
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
     Not yet shown is
     how to integrate
     the building model.
   end note

   note right of Application
     Application that uses
     the OpenStudio SDK.
   end note





.. _fig_overall_software_architecture_one_editor:

.. uml::
   :caption: Overall software architecture (with one editor for the SOEP mode).

   title Overall software architecture (with one editor for the SOEP mode).

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

   EnergyPlus <.. [EnergyPlus\nSimulator Interface]: writes inputs,\nruns simulation,\nreads outputs
   package EnergyPlus {
     [in.idf] -> [EnergyPlus.exe]
     [EnergyPlus.exe] -> [eplusout.sql]
   }

   package SOEP {
   [HVAC Systems Editor\n(SOEP Mode)] ..> [JModelica] : parses\nAST
   [SOEP\nModel Library] <.. [Conversion Script]: augments library\nby generating C++ code

   [Conversion Script] ..> [JModelica]: parses\nAST
   [SOEP\nSimulator Interface] ..> [JModelica] : writes inputs,\nruns simulation,\nreads outputs
   database "Modelica\nLibrary AST"
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



   note right of [HVAC Systems Editor\n(SOEP Mode)]
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
     Not yet shown is
     how to integrate
     the building model.
   end note

   note right of Application
     Application that uses
     the OpenStudio SDK.
   end note




**fixme: more design to be added**


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

This section introduces API of functions to be provided by JModelica for an efficient implementation of QSS.
We use the ``types`` which are used in the FMI specifications version 2.0 to define the functions. 
Details about the ``types`` can be found in the FMI specification.

.. code:: c

  typedef unsigned int fmi2ValueReference;
  typedef int fmi2Integer; 
  typedef double fmi2Real;
  typedef void* fmi2Component;
  typedef enum{fmi2OK,
	       fmi2Warning, 
               fmi2Discard,
               fmi2Error,
               fmi2Fatal,
               fmi2Pending}fmi2Status;

.. note:: 

  ``fmi2Component`` is a pointer to an FMU
  specific data structure that contains the information needed to 
  process the model equations or to process the cosimulation of the respective slave.


.. code:: c
  
  fmi2Status fmi2SetSpecificContinuousStates(fmi2Component c, 
                                             const fmi2Real x[], 
                                             const fmi2ValueReference vr[],
                                             size_t nx);

This function is similar to ``fmi2SetContinuousStates()``. The only difference
is that it gets the value references ``vr`` of the state variables that need to be set.
Argument ``nx`` is the length of the state vector ``x`` and is provided for checking purposes.
Similar to ``fmi2SetContinuousStates()``, this function should re-initialize caching 
of all variables which depend on the states set. 

The FMI specification defines ``caching`` as a mechanism which requires 
that the model evaluation can detect when the input arguments
of a function have changed so the function can be updated. 

.. note::
  
  We note that current ``fmi2SetContinuousStates()`` forces to set the entire
  state vectors. This re-initializes ``caching`` of all variables which depend on the state
  variables. This is inefficient for QSS solvers. 

.. code:: c

  fmi2Status fmi2GetSpecificDerivatives(fmi2Component c, 
                                        fmi2Real val[][], 
                                        const fmi2ValueReference vr[],
                                        size_t nvr, const fmi2Integer ord);

This function is similar to ``fmi2GetDerivatives()``. 
The only difference is that it gets a vector of value references ``vr[]``, 
and the maximum order ``ord`` of the state derivatives to be retrieved. It returns 
an ``nvr x ord`` array of state derivatives ``val[] []``. 
Argument ``nvr`` is the length of the state derivative vector.

If ``ord==2`` then, ``val[0:nvr-1] [0]`` is the vector of first derivatives 
of the state vector, and ``val[0:nvr-1] [1]`` is the vector of second derivatives.

.. note::
  
  ``fmi2GetReal()`` could be used to retrieve specific state derivatives. But
  The function will also need to include the order of the state derivative
  to be retrieved. Since such information is only relevant for
  state derivative, we recommend to use the new function ``fmi2GetSpecificDerivatives()``
  instead.

.. code:: c

  fmi2Status fmi2GetExtendedEventIndicators(fmi2Component c, 
                                    fmi2Real val[][], 
                                    const fmi2Integer ord,
                                    size_t ni);

This function is similar to ``fmi2GetEventIndicators()``. 
The only difference is that it gets the maximum derivative order ``ord`` 
of the vector of event indicators,  and returns an ``ni x ord+1`` array of 
event indicators with their derivatives ``val[][]``.
Argument ``ni`` is the length of the vector of event indicators. 

We note that the ``return`` value ``val[][]`` includes the vector of event indicators as well.

If ``ord==2`` then, ``val[0:ni-1][0]`` is the vector of event indicators, 
``val[0:ni-1][1]`` is the vector of first derivatives of the vector of event indicators, 
and ``val[0:ni-1][2]`` is the vector of second derivatives.

.. note:: 

  We note that the event indicator functions do not provide information
  about state variables which trigger the state events. Good will be to 
  provide such information so that a QSS solver does not have to 
  requantize all variables when such an event happens. This information should be best
  provided in the ``ModelStructure`` of the model description file of an FMU.
  Since we do not want to change the model structure of the FMU at this time, 
  we propose to implement a function ``fmi2GetExtendedEventIndicators()`` 
  which will be called at initialization once to provide 
  the dependencies information between event indicators and state variables on 
  which the event indicators depend on. 

.. code:: c

  fmi2Status fmi2GetDependentEventIndicators(fmi2Component c, 
                                    fmi2ValueReference vr[][], 
                                    size_t ni,
                                    size_t nx
                                    );

This function returns an ``ni x nx`` array of value 
references ``vr[][]`` of state variables on which the event indicators depend on.
Argument ``ni`` is the length of the vector of event indicators. 
Argument ``nx`` is the length of the state vector. 

The ordering of the elements of the array of value references 
must match the ordering of the vector of event indicators 
returned in ``fmi2GetExtendedEventIndicators()``.  
Thus ``vr[0][0:nx-1]`` must be the vector of value references of 
dependent state variables of the first event indicator. 

.. note:: 

   Although we do not anticipate each event indicator to depend on 
   all state variables, we used for simplicity
   the length of the state vector ``nx`` in the array declaration. 


Because the FMI API does not provide access to many required derivatives,
and to avoid having to numerically approximate derivatives,
we will implement the QSS solver with the generated C code
when creating the FMU. This leads to the suggested software architecture
shown in :numref:`fig_sof_arc_qss_jmod`. For simplicity the figure only
shows single FMUs, but we anticipated having multiple interconnected FMUs.

.. _fig_sof_arc_qss_jmod:

.. uml::
   :caption: Software architecture for QSS integration with JModelica.

   title Software architecture for QSS integration with JModelica

   skinparam componentStyle uml2

   [FMU-ME] as FMU_QSS

   package Optimica {
   [QSS library] as qss_lib
   qss_lib    --> [JModelica compiler]
   }

   [Modelica model] --> [JModelica compiler]

   [JModelica compiler] -> FMU_QSS

   package PyFMI {
   [Master algorithm] -> FMU_QSS : "inputs, time"
   [Master algorithm] <- FMU_QSS : "next event time"
   [Master algorithm] -- [Sundials]
   }

   [Sundials] --> [FMU-ME] : "(x, t)"
   [Sundials] <-- [FMU-ME] : "dx/dt"
   [Master algorithm] --> [FMU-CS] : "hRequested"
   [Master algorithm] <-- [FMU-CS] : "(x, hMax)"


   note left of FMU_QSS
      FMU-ME 2.0 API, sends
      next event time, but
      exposes no state derivatives
   end note
      
.. note::

   We still need to design how to handle algebraic loops inside the FMU
   (see also Cellier's and Kofman's book) and algebraic loops that 
   cross multiple FMUs.
