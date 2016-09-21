.. _sec_use_cases:

Use Cases
---------

This section describes use cases for end-users that interact with SOEP
through OpenStudio, and use cases for developers of SOEP.

Use Cases for OpenStudio Integration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Use Case for OpenStudio Measures
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This use case describes how measures are processed between OpenStudio and
the Modelica model. We distinguish two types of measures, these who do a simple
parameter assignment, and these who require changes to multiple parts of the model.


An example which requires changes to a single parameters of the model is as
follows: Consider that a top-level parameter for the boiler efficiency `eta`
needs to be set to ``0.9``.

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
2                            A JSON file that lists all components that are
                             lighting power densities is being red,
                             and a code snippet that
                             shows how to change the lighting power density
                             parameter or the data record that contains the
                             lighting power density is returned.
---------------------------  ---------------------------------------------------
3                            The script searches for all model instances that
                             are lighting power densities, and returns two lists
                             of model names, one list (``l1``) containing only
                             the parameters (or records) that are not final, and
                             one list (``l2``) that contains the parameters
                             (or records) that are final.
---------------------------  ---------------------------------------------------
4                            If ``l1`` is empty, the script triggers an error
                             and stops.
---------------------------  ---------------------------------------------------
5                            If ``l2`` is non-empty, the script triggers a
                             warning.
---------------------------  ---------------------------------------------------
6                            The ruby script makes a new model of the form
                             ``model modifiedModel extends
                             buiding(zone1(pLig=0.8), zone2(pLig=0.8));
                             end modifiedModel;``
                             (or similar if the efficiency is part of a
                             Modelica ``record``).
===========================  ===================================================



Use Case for Modelica Buildings Library Integration in OpenStudio
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This use case describes how to synchronize the Modelica library with its
OpenStudio representation. The OpenStudio representation will be used
for integration OpenStudio measures, and other OpenStudio code
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
                             it will be generated.)
---------------------------  ---------------------------------------------------
Successful End Condition     An HVAC and controls library for use in OpenStudio.
---------------------------  ---------------------------------------------------
Failed End Condition         Library creation failed due to incompatible
                             changes in the Modelica library that have not
                             been confirmed to be propagated to OpenStudio.
---------------------------  ---------------------------------------------------
Primary Actors               A software developer.
---------------------------  ---------------------------------------------------
Secondary Actors             The OpenStudio HVAC and controls library.
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

Template is below

===========================  ===================================================
**Use case name**            **Loading a Modelica library into OpenStudio**
===========================  ===================================================
Related Requirements
---------------------------  ---------------------------------------------------
Goal in Context
---------------------------  ---------------------------------------------------
Preconditions
---------------------------  ---------------------------------------------------
Successful End Condition
---------------------------  ---------------------------------------------------
Failed End Condition
---------------------------  ---------------------------------------------------
Primary Actors
---------------------------  ---------------------------------------------------
Secondary Actors
---------------------------  ---------------------------------------------------
Trigger
---------------------------  ---------------------------------------------------
**Main Flow**                **Action**
---------------------------  ---------------------------------------------------
1                            xxxx
---------------------------  ---------------------------------------------------
2                            xxxx
---------------------------  ---------------------------------------------------
3                            xxxx
---------------------------  ---------------------------------------------------
**Extensions**
---------------------------  ---------------------------------------------------
1                            xxxx
---------------------------  ---------------------------------------------------
2                            xxxx
===========================  ===================================================
