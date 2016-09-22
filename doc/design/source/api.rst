Application Programming Interface
---------------------------------

This chapter defines the Application Programming Interface (API)
for generating SOEP models, and for retrieving the outputs of simulations.

It only contains rough initial ideas.

Generating OpenStudio Models
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section sketches how to add vendor annotations [#ven_ann]_ in the Modelica code
to allow automatic generation of OpenStudio models, such as the ones at
https://github.com/NREL/OpenStudio/blob/develop/openstudiocore/src/model/BoilerHotWater.hpp and
https://openstudio-sdk-documentation.s3.amazonaws.com/cpp/OpenStudio-1.12.3-doc/model/html/classopenstudio_1_1model_1_1_pipe_adiabatic.html.



.. code-block:: modelica

  model Boiler "Hot water boiler"
  parameter Modelica.SIunits.Power(min=0) Q_flow_nominal "Nominal heating power";
    annotation(__EnergyPlus(set_get_function("Capacity")));

  annotation(__EnergyPlus(extends="StraightComponent"),
     documentation=...);

end Boiler;


This annotation allows to generate the OpenStudio model
(

.. code-block:: C++

   class MODEL_API Boiler : public StraightComponent {
     public:
       void setCapacity(double Q_flow_nominal); /// Set nominal heating power in Watts
                                                /// and verify that Q_flow_nominal >= 0
       double getCapacity(){
         return get("BoilerHotWater").Q_flow_nominal;
     } /// Get nominal heating power in Watts
   }

.. rubric:: Footnotes

.. [#ven_ann] Vendor annotations are annotations in the Modelica code that are
              typically ignored by Modelica tools other than the tool from
              the vendor who introduced the vendor annotation.
              They allow augmenting the code with information
              that are processed by a particular tool,
              in our case by EnergyPlus and OpenStudio.
