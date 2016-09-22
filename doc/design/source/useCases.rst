.. _sec_use_cases:

Use Cases
---------

This section describes use cases for end-users that interact with SOEP
through OpenStudio, and use cases for developers of SOEP.

.. note::

   I think OpenStudio components which map to Modelica models will need to be
   annotated somehow so that OpenStudio knows how to handle them automatically.
   The reasoning is because I believe we should still be able to support the
   old way OpenStudio deals with HVAC. We need a way to let OpenStudio knows
   whether we are doing SOEP or the old way.

OpenStudio Integration
^^^^^^^^^^^^^^^^^^^^^^

Measures
~~~~~~~~

This use case describes how measures are processed between OpenStudio and
the Modelica model. We distinguish two types of measures, these who do a simple
parameter assignment, and these who require changes to multiple parts of the model.


An example which requires changes to a single parameters of the model is to
set in a Modelica model of the form

.. code-block:: modelica

   ...
   parameter Real eta(min=0) = 0.8 "Boiler efficiency";
   ...

the top-level parameter for the boiler efficiency :math:`\eta = 0.9`.


The use case description is as follows:

===========================  ===================================================
**Use case name**            **Apply OS measure to a single parameter**
===========================  ===================================================
Related Requirements         n/a
---------------------------  ---------------------------------------------------
Goal in Context              A user wants to modify a parameter in a model
                             from an OS measure.
---------------------------  ---------------------------------------------------
Preconditions                A Modelica model.
---------------------------  ---------------------------------------------------
Successful End Condition     The parameter is set to its new value.
---------------------------  ---------------------------------------------------
Failed End Condition         The script returns with an error if no such
                             parameter exist, or if the parameter is set to
                             ``final`` (and hence cannot be modified).
---------------------------  ---------------------------------------------------
Primary Actors               An end-user, or an application that is built on
                             OpenStudio.
---------------------------  ---------------------------------------------------
Secondary Actors             A Modelica model that is loaded in OpenStudio.
---------------------------  ---------------------------------------------------
Trigger                      A ruby script is executed.
---------------------------  ---------------------------------------------------
**Main Flow**                **Action**
---------------------------  ---------------------------------------------------
1                            The ruby script is invoked.
---------------------------  ---------------------------------------------------
2                            The script searches for the parameter value
                             and returns a flag to show whether it
                             has been found (return value ``0``),
                             it has been found but is final (return value
                             ``1``),
                             or it has not been found (return value ``2``).
---------------------------  ---------------------------------------------------
3                            If the return value is non-zero, the script
                             terminates with an error.
---------------------------  ---------------------------------------------------
4                            If the return value is zero, the ruby script
                             makes a new model of the form
                             ``model modifiedModel extends
                             buiding(eta=0.9);
                             end modifiedModel;``
                             (or similar if the efficiency is part of a
                             Modelica ``record``).
---------------------------  ---------------------------------------------------
**Extensions**
---------------------------  ---------------------------------------------------
4.1                          The parameter assignment could be done directly
                             in the model `building`, as long as it is not
                             part of a write-protected library. Then, the
                             assignment looks like
                             ``parameter Real eta(min=0) = 0.9 "Efficiency";``
===========================  ===================================================

The sequence diagram for this as shown in :numref:`fig_use_case_os_single_par`.

.. _fig_use_case_os_single_par:

.. uml::
   :caption: Applying an OS measure to a single parameter.

   title Apply OS measure to a single parameter

   Measure -> "Model Editor": getInstanceAST()
   "Model Editor" -> JModelica: getInstanceAST()
   "Model Editor" <- JModelica
   Measure <- "Model Editor"
   |||
   Measure -> Measure: searchParameter()
   Measure -> Measure: validate()
   alt found parameter
     Measure -> "Model Editor": setValue()
   else
     Measure -> Measure: reportError()
   end



An example which requires changes to multiple parts of the model is the following
measure.

.. code-block:: ruby

   new_lights_def = OpenStudio::Model::LightsDefinition.new(model)
   new_lights_def.setWattsperSpaceFloorArea(10.0)
   new_lights_def.setName("10 W/m^2 Lights Definition")

   space_types = model.getSpaceTypes
   space_types.each do |space_type|
     if space_type.name.match("Enclosed Office")
       lights = space_type.lights
       lights.each do |light|
         light.setLightsDefinition(new_lights_def)
       end
     end
   end

The use case description is as follows:

===========================  ===================================================
**Use case name**            **Apply OS measure to set of models**
===========================  ===================================================
Related Requirements         n/a
---------------------------  ---------------------------------------------------
Goal in Context              A user wants to modify a model.
---------------------------  ---------------------------------------------------
Preconditions                A Modelica model.
---------------------------  ---------------------------------------------------
Successful End Condition     All thermal zones are updated.
---------------------------  ---------------------------------------------------
Failed End Condition         The script returns with an error if no thermal
                             zone has been found.
---------------------------  ---------------------------------------------------
Primary Actors               An end-user, or an application that is built on
                             OpenStudio.
---------------------------  ---------------------------------------------------
Secondary Actors             A Modelica model that is loaded in OpenStudio.
---------------------------  ---------------------------------------------------
Trigger                      A ruby script is executed.
---------------------------  ---------------------------------------------------
**Main Flow**                **Action**
---------------------------  ---------------------------------------------------
1                            The ruby script is invoked.
---------------------------  ---------------------------------------------------
2                            The instance AST is obtained.
---------------------------  ---------------------------------------------------
3                            The script searches for all model instances that
                             are thermal zones, and within them, it searches for
                             all lighting power densities.
                             It returns two lists
                             of model names, one list (``l1``) containing only
                             the parameters (or records) that are not final, and
                             one list (``l2``) that contains the parameters
                             (or records) that are final.
---------------------------  ---------------------------------------------------
4                            If ``l1`` is empty, the script triggers an error
                             and stops.
---------------------------  ---------------------------------------------------
5                            If ``l2`` is non-empty, the script triggers a
                             warning and continues.
---------------------------  ---------------------------------------------------
6                            A JSON file that lists all components
                             that are lighting power densities is being red,
                             and a code snippet that
                             shows how to change the lighting power density
                             parameter or the data record that contains the
                             lighting power density is returned.
---------------------------  ---------------------------------------------------
7                            The ruby script makes a new model of the form
                             ``model modifiedModel extends
                             buiding(zone1(pLig=0.8), zone2(pLig=0.8));
                             end modifiedModel;``
                             (or similar if the efficiency is part of a
                             Modelica ``record``).
===========================  ===================================================

The sequence diagram for this as shown in :numref:`fig_use_case_os_zones`.

.. _fig_use_case_os_zones:

.. uml::
   :caption: Applying an OS measure to a set of models.

   title Apply OS measure to set of models.

   Measure -> "Model Editor": getInstanceAST()
   "Model Editor" -> JModelica: getInstanceAST()
   "Model Editor" <- JModelica
   Measure <- "Model Editor"
   |||
   Measure -> Measure: searchParameter()
   Measure -> Measure: validate()

   alt no non-final parameter found

       Measure -> Measure: reportError()
       Measure -> Measure: stop

   else

       alt found final parameter

         Measure -> Measure: reportWarning()
         note right: This alerts users that not all parameters have been set.

       end

       Measure -> Measure: getCodeSnippet()
       Measure -> "Model Editor": setValue()

   end




Modelica Buildings Library Integration in OpenStudio
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This use case describes how to synchronize the Modelica library with its
OpenStudio representation. The OpenStudio representation will be used
for integrating OpenStudio measures, and other OpenStudio code
that interacts with the Modelica representation such as the graphical
editor. The problem being addressed is that the Modelica library is frequently
updated, and we want to have *one* representation of the model connectors,
parameters, documenation and graphical layout.


===========================  ===================================================
**Use case name**            **Loading a Modelica library into OpenStudio**
===========================  ===================================================
Related Requirements         n/a
---------------------------  ---------------------------------------------------
Goal in Context              Updating an OpenStudio HVAC and controls library
                             after changes have been made to the Modelica
                             library.
---------------------------  ---------------------------------------------------
Preconditions                The Modelica library passes the regression tests
                             and an AST of the OpenStudio object representation
                             for the library already exists (otherwise
                             it will be generated).
---------------------------  ---------------------------------------------------
Successful End Condition     An HVAC and controls library for use in OpenStudio.
---------------------------  ---------------------------------------------------
Failed End Condition         Library creation failed due to incompatible
                             changes in the Modelica library that have not
                             been confirmed to be propagated to OpenStudio.
---------------------------  ---------------------------------------------------
Primary Actors               A software developer.
---------------------------  ---------------------------------------------------
Secondary Actors             The Modelica Buildings library.

                             The OpenStudio HVAC and controls library.
---------------------------  ---------------------------------------------------
Trigger                      The software developer executes an update script.
---------------------------  ---------------------------------------------------
**Main Flow**                **Action**
---------------------------  ---------------------------------------------------
1                            The software developer runs an update script
                             to initiate updating the OpenStudio HVAC
                             and controls library.
---------------------------  ---------------------------------------------------
2                            The Modelica library is parsed and an abstract
                             syntax tree (AST) including the vendor annotations
                             is created. (See also
                             http://www.jmodelica.org/api-docs/usersguide/1.17.0/ch09s01.html.)
---------------------------  ---------------------------------------------------
3                            If the AST representation of OpenStudio exists
                             for this library, then the AST is compared
                             with the previous AST
                             representation to detect and report incompatible
                             changes.
---------------------------  ---------------------------------------------------
4                            If the AST representation of OpenStudio does
                             not exist for this library, it is generated.
---------------------------  ---------------------------------------------------
5                            The AST is converted to OpenStudio object
                             models.
---------------------------  ---------------------------------------------------
**Extensions**
---------------------------  ---------------------------------------------------
5.1                          OpenStudio integration tests are run.
===========================  ===================================================

The sequence diagram for this as shown in :numref:`fig_use_case_loading_modelica_lib`.

.. _fig_use_case_loading_modelica_lib:

.. uml::
   :caption: Loading a Modelica library into OpenStudio.

   title Apply OS measure to set of models.

   "Update Script" -> JModelica: getInstanceAST()
   JModelica -> "Modelica Library": getInstanceAST()
   JModelica <- "Modelica Library"
   "Update Script" <- JModelica
   |||
   "Update Script" -> "OpenStudio Library": getInstanceAST()
   "Update Script" <- "OpenStudio Library"

   alt no OpenStudio Library has been populated
     "Update Script" -> "OpenStudio Library": createLibrary()
   else Update the existing library
     "Update Script" -> "Update Script" : validate()
     alt incompatible changes exist
       "Update Script" -> "Update Script" : reportIncompatibilities()
       alt accept incompatible changes
         "Update Script" -> "OpenStudio Library": createLibrary()
       end
     end
   end



HVAC System Modeling in OpenStudio
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This use case describes how to build an HVAC system in OpenStudio
which uses component models of the Modelica Buildings library.


===========================  ===================================================
**Use case name**            **Modeling a boiler plant in OpenStudio**
===========================  ===================================================
Related Requirements         n/a
---------------------------  ---------------------------------------------------
Goal in Context              A user wants to model a boiler plant in OpenStudio
                             using component models of the Buildings library,
                             and optionally connect it to pre-configured
                             air handler unit from the OpenStudio library.
---------------------------  ---------------------------------------------------
Preconditions                Component models of the boiler pant
                             exist as OpenStudio and Modelica models.

                             Measures for converting
                             the OpenStudio models to Modelica models exist.
---------------------------  ---------------------------------------------------
Successful End Condition     An AHU for use in OpenStudio.
---------------------------  ---------------------------------------------------
Failed End Condition         Conversion from OpenStudio component model to
                             Modelica model failed because of non-existence
                             of corresponding Modelica model.
---------------------------  ---------------------------------------------------
Primary Actors               An end user.
---------------------------  ---------------------------------------------------
Secondary Actors             The Modelica Buildings library.

                             The OpenStudio HVAC and controls library.
---------------------------  ---------------------------------------------------
Trigger                      The user drags and drops component models of an
                             HVAC system.
---------------------------  ---------------------------------------------------
**Main Flow**                **Action**
---------------------------  ---------------------------------------------------
1                            The user open the OpenStudio GUI and selects the
                             SOEP mode.
---------------------------  ---------------------------------------------------
2                            The OpenStudio GUI shows an HVAC and controls
                             library for which Modelica components exist.
---------------------------  ---------------------------------------------------
3                            The user drags and drops OpenStudio component
                             models for an AHU (fan, heating and cooling coils,
                             dampers, etc.) from the OpenStudio HVAC library
                             into the schematic editor.
---------------------------  ---------------------------------------------------
4                            As a component is dropped into the editor,
                             code is generated that specifies the component
                             location. For example, dropping a boiler generates
                             code such
                             as ``Buildings.Fluid.Boilers.BoilerPolynomial
                             boi "Boiler"
                             annotation (Placement(
                             transformation(extent={{-10,0},{10,20}})));``
---------------------------  ---------------------------------------------------
5                            The user sets the efficiency of the boiler by
                             double-clicking on its icon, which changes the
                             above declaration
                             to ``Buildings.Fluid.Boilers.BoilerPolynomial boi(
                             eta = 0.9) "Boiler"
                             annotation (Placement(
                             transformation(extent={{-10,0},{10,20}})));``
---------------------------  ---------------------------------------------------
6                            The user connects the inlet to a boiler to a
                             temperature sensor (which has previously been placed
                             and given the name `temSen`) by drawing a line
                             between its ports. This generates the
                             code ``connect(senTem.port_b, boi.port_a)
                             annotation (Line(points={{-10,0},{0,0},{0,10}}));``
---------------------------  ---------------------------------------------------
**Extensions**
---------------------------  ---------------------------------------------------
7                            To connect the boiler to the air handler unit,
                             the user drags a complete air handler unit
                             into the schematic editor.
---------------------------  ---------------------------------------------------
8                            The editor asks whether the components should be
                             instantiated as a component (displaying
                             its Modelica icon and hence its structure can only
                             be changed by changing the library), or
                             exploded so that all its top-level components are
                             instantiated and hence can be modified.
---------------------------  ---------------------------------------------------
9                            The user connects the boiler output to the
                             air handler heating coil inlets as in Step 6
===========================  ===================================================
