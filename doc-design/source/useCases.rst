.. _sec_use_cases:

Use Cases
---------

This section describes use cases for end-users that interact with SOEP
through OpenStudio, and use cases for developers of SOEP.

In the use cases, we call components the
`HVAC System Editor`, the `Schematic Editor`.
This terminology is the same as is used in the
software architecture diagram
:numref:`fig_overall_software_architecture`.


OpenStudio Integration
^^^^^^^^^^^^^^^^^^^^^^


Modelica Buildings library integration in OpenStudio
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This use case describes how to synchronize the Modelica library with
the data structure used by the OpenStudio Model Library.
The OpenStudio Model Library will be used
for integrating OpenStudio measures, and other OpenStudio code
such as its graphical editor that interacts with the Modelica models.
The problem being addressed is that the Modelica library is frequently
updated, and we want to have *one* representation of the connectors,
parameters, documenation and graphical layout of the models, and
also check for potential incompatible model changes during the development
of the Modelica Library.


===========================  ===================================================
**Use case name**            **Updating an OpenStudio Model Library**
===========================  ===================================================
Related Requirements         n/a
---------------------------  ---------------------------------------------------
Goal in Context              Updating an OpenStudio HVAC and controls library
                             after changes have been made to the Modelica
                             library.
---------------------------  ---------------------------------------------------
Preconditions                The Modelica library passes the regression tests.

                             An AST of the OpenStudio object representation
                             for the library already exists (otherwise
                             it will be generated).
---------------------------  ---------------------------------------------------
Successful End Condition     An HVAC and controls library for use in the
                             OpenStudio `HVAC System Editor`.
---------------------------  ---------------------------------------------------
Failed End Condition         Library creation failed due to incompatible
                             changes in the `Modelica Buildings Library`
                             that have not
                             been confirmed to be propagated to OpenStudio.
---------------------------  ---------------------------------------------------
Primary Actors               A software developer.
---------------------------  ---------------------------------------------------
Secondary Actors             The OpenStudio HVAC and controls `Model Library`.

                             JModelica which returns the AST.

                             The `Modelica Buildings Library`.
---------------------------  ---------------------------------------------------
Trigger                      The software developer executes a
                             conversion script.
---------------------------  ---------------------------------------------------
**Main Flow**                **Action**
---------------------------  ---------------------------------------------------
1                            The software developer runs a conversion script
                             to initiate updating the OpenStudio HVAC
                             and controls `Model Library`.
---------------------------  ---------------------------------------------------
2                            `JModelica` loads the `Modelica Buildings Library`
                             and returns its AST. (See also
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
   :caption: Updating an OpenStudio Model Library.

   title Updating an OpenStudio Model Library.

   "Conversion Script" -> "JModelica": getInstanceAST()
   "JModelica" -> "Modelica Buildings Library": loadLibrary()
   "JModelica" <- "Modelica Buildings Library"
   "Conversion Script" <- "JModelica"
   |||
   "Conversion Script" -> "OpenStudio Model Library": getInstanceAST()
   "Conversion Script" <- "OpenStudio Model Library"

   alt no OpenStudio Model Library has been populated
     "Conversion Script" -> "OpenStudio Model Library": createLibrary()
   else Update the existing library
     "Conversion Script" -> "Conversion Script" : validate()
     alt incompatible changes exist
       "Conversion Script" -> "Conversion Script" : reportIncompatibilities()
       alt accept incompatible changes
         "Conversion Script" -> "OpenStudio Model Library": createLibrary()
       end
     end
   end



Modeling of an AHU with custom control
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This use case describes how to instantiate an AHU with
pre-configured control sequence in OpenStudio,
and then customize the control sequence.

.. note::

   The use case assumes two graphical editors for HVAC systems.
   Ideally, we would combine them into one graphical editor. Whether this
   is feasible will depend on the modeling support that the refactored
   OpenStudio `HVAC System Editor` will provide.

===========================  ===================================================
**Use case name**            **Modeling of an AHU with custom control**
===========================  ===================================================
Related Requirements         n/a
---------------------------  ---------------------------------------------------
Goal in Context              A user wants to model an AHU in OpenStudio
                             using component models of the
                             OpenStudio Model Library, and add custom control.
---------------------------  ---------------------------------------------------
Preconditions                Preconfigured system model of the AHU
                             exist in the OpenStudio Model Library.

                             Controls component exist in the Modelica Buildings
                             library.
---------------------------  ---------------------------------------------------
Successful End Condition     Created an AHU with custom control.
---------------------------  ---------------------------------------------------
Failed End Condition         n/a
---------------------------  ---------------------------------------------------
Primary Actors               An end user.
---------------------------  ---------------------------------------------------
Secondary Actors             The OpenStudio HVAC and controls library.

                             The Modelica Buildings library.
---------------------------  ---------------------------------------------------
Trigger                      The user drags and drops an AHU model with
                             pre-configured control sequence.
---------------------------  ---------------------------------------------------
**Main Flow**                **Action**
---------------------------  ---------------------------------------------------
1                            The user opens the OpenStudio `HVAC System Editor`
                             and selects the SOEP mode.
---------------------------  ---------------------------------------------------
2                            The OpenStudio GUI shows an HVAC and controls
                             library.
---------------------------  ---------------------------------------------------
3                            The user drags and drops the OpenStudio AHU
                             model, which is connected to an OpenStudio
                             control model, into the `HVAC System Editor`.
---------------------------  ---------------------------------------------------
4                            As a component is dropped into the editor,
                             code is generated that specifies the component
                             location. For example, dropping the control
                             sequence generates
                             code such
                             as ``Buildings.Controls.AHU.VAV
                             conVav "VAV control"
                             annotation (Placement(
                             transformation(extent={{-10,0},{10,20}})));``
---------------------------  ---------------------------------------------------
5                            The user right-clicks on the ``conVav`` instance
                             and selects "Edit in Modelica editor".
---------------------------  ---------------------------------------------------
6                            The `Schematic Editor` opens and the user
                             customizes the controls.
---------------------------  ---------------------------------------------------
7                            The user saves the control model as the
                             ``Custom/ControlVAV.mo`` Modelica model.
---------------------------  ---------------------------------------------------
8                            The user switches to the `HVAC System Editor`,
                             which changed the `conVAV` instance to a new
                             Modelica class such as
                             ``Custom.ControlVAV
                             conVav "VAV control"
                             annotation (Placement(
                             transformation(extent={{-10,0},{10,20}})));``
---------------------------  ---------------------------------------------------
9                            The user adds a new control sensor input, changes
                             a control input/output block, and connects
                             the new control sensor input to the new control
                             input/output block.
---------------------------  ---------------------------------------------------
10                           As the ``Custom.ControlVAV`` has an additional
                             sensor input, the user connects this sensor input
                             in the `HVAC Systems Editor` to an output
                             of a model.
---------------------------  ---------------------------------------------------
**Extensions**
---------------------------  ---------------------------------------------------
5.1                          Rather than selecting a single component for
                             editing in the `Schematic Editor`, a user
                             could select multiple OpenStudio components
                             (that are connected), and they would then
                             be grouped to form one Modelica model. The grouping
                             would essentially consist of writing ``connect``
                             statements between the ports of the components.
===========================  ===================================================


The sequence diagram for this as shown in :numref:`fig_use_case_custom_control`.

.. _fig_use_case_custom_control:

.. uml::
   :caption: Modeling of an AHU with custom control.

   title Modeling of an AHU with custom control

   "User" -> "HVAC System Editor" : setSOEPMode()
   "User" <- "HVAC System Editor"
   "User" -> "HVAC System Editor" : drag & drop AHU model
   |||
   "HVAC System Editor" -> "HVAC System Editor" : instantiates model
   "User" <- "HVAC System Editor"
   "User" -> "HVAC System Editor" : select "Edit in Modelica editor"
   "User" <- "HVAC System Editor"
   "User" -> "Schematic Editor" : customize model
   "Schematic Editor" -> "Schematic Editor" : write Custom/ControlVAV.mo file
   "User" <- "Schematic Editor"
   |||
   "User" -> "Schematic Editor" : switch to HVAC System Editor
   "HVAC System Editor" -> "HVAC System Editor" : read Custom/ControlVAV.mo file to get new I/O
   "User" -> "HVAC System Editor": Connect new inputs & outputs
   "User" <- "HVAC System Editor"

.. note::

   Getting the new inputs and outputs of ``Custom/ControlVAV.mo`` requires
   parsing its AST, which would be easiest if JModelica would be invoked
   to get the AST.

Measures
^^^^^^^^

These use cases describe how measures are processed between OpenStudio and
the Modelica model. We distinguish two types of measures, these who do a simple
parameter assignment on the Modelica model, and these who require changes
to multiple parts of the Modelica model. We assume that users
edited a model in the SOEP `Schematic Editor`.

.. note::

   If users simply edit a model in the OpenStudio `HVAC Systems Editor`,
   then measures will work as they do now, because the `HVAC System editor`
   uses the OpenStudio `Model Library` only.

Simple parameter assignment
~~~~~~~~~~~~~~~~~~~~~~~~~~~

An example which requires changes to a single parameters of the model is to
set in a Modelica model of the form

.. code-block:: modelica

   ...
   parameter Real eta(min=0) = 0.8 "Boiler efficiency";
   ...

the top-level parameter for the boiler efficiency :math:`\eta = 0.9`.


The use case description is as follows:

===========================  ===================================================
**Use case name**            **Apply OpenStudio measure to a single parameter**
===========================  ===================================================
Related Requirements         n/a
---------------------------  ---------------------------------------------------
Goal in Context              A user wants to modify a parameter in a model
                             from an OpenStudio measure.
---------------------------  ---------------------------------------------------
Preconditions                A Modelica model that has been edited in the
                             SOEP `Schematic Editor`.
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
   :caption: Applying an OpenStudio measure to a single parameter.

   title Apply OpenStudio measure to a single parameter

   Measure -> "OpenStudio Model Library": getInstanceAST()
   "OpenStudio Model Library" -> JModelica: getInstanceAST()
   "OpenStudio Model Library" <- JModelica
   Measure <- "OpenStudio Model Library"
   |||
   Measure -> Measure: searchParameter()
   Measure -> Measure: validate()
   alt found parameter
     Measure -> "OpenStudio Model Library": setValue()
   else
     Measure -> Measure: reportError()
   end


Changes to multiple parts of the Modelica model
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
**Use case name**            **Apply OpenStudio measure to set of models**
===========================  ===================================================
Related Requirements         n/a
---------------------------  ---------------------------------------------------
Goal in Context              A user wants to modify a model.
---------------------------  ---------------------------------------------------
Preconditions                A Modelica model that has been edited in the
                             SOEP `Schematic Editor`.
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
   :caption: Applying an OpenStudio measure to a set of models.

   title Apply OpenStudio measure to set of models.

   Measure -> "OpenStudio Model Library": getInstanceAST()
   "OpenStudio Model Library" -> JModelica: getInstanceAST()
   "OpenStudio Model Library" <- JModelica
   Measure <- "OpenStudio Model Library"
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
       Measure -> "OpenStudio Model Library": setValue()

   end




