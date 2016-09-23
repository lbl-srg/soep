Application Programming Interface
---------------------------------

This chapter defines the Application Programming Interface (API)
for generating SOEP models, and for retrieving the outputs of simulations.

It only contains rough initial ideas.

Generating OpenStudio Models
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The purpose of this section is to design how to keep the OpenStudio
Model API and the Modelica section synchronized, while requiring
only one place where information is declared.

A solution for this is to use so-called
vendor annotations [#ven_ann]_ in the Modelica code,
and encode in these vendor annotations the information required
to generate the OpenStudio Model API that corresponds to the
library. [#os_mod_api]_
For a boiler, model, vendor annotation in the ``EnergyPlus``
namespace may look as shown below.


.. code-block:: modelica

  model Boiler "Hot water boiler"
    extends extends Interfaces.TwoPortHeatMassExchanger(...);

  parameter Modelica.SIunits.Power(min=0) Q_flow_nominal
    "Nominal heating power";
    annotation(__EnergyPlus(set_get_function("Capacity")));
  ...
  equation
  ...
  annotation(__EnergyPlus(
               MODEL_API(
                 extends="public StraightComponent")),
     documentation=...);

  end Boiler;


From such a Modelica model, the OpenStudio model API below
could be generated.

.. code-block:: C++

   class MODEL_API Boiler : public StraightComponent {
     public:
       void setCapacity(double Q_flow_nominal); /// Set nominal heating power
                                                /// in Watts, and verify
                                                /// that Q_flow_nominal >= 0
       double getCapacity(){
         return get("BoilerHotWater").Q_flow_nominal;
     } /// Get nominal heating power in Watts

      std::string getCapacityDocumentation(); /// Returns "Nominal heating power"
      std::string getCapacityUnit();          /// Returns "W"
      double getCapacityMin();                /// Returns 0 (the value of
                                              ///   the 'min' attribute)
      std::string getCapacityQuantity();      /// Returns "Power"
   }

.. rubric:: Footnotes

.. [#ven_ann]    Vendor annotations are annotations in the Modelica code that are
                 typically ignored by Modelica tools other than the tool from
                 the vendor who introduced the vendor annotation.
                 They allow augmenting the code with information
                 that are processed by a particular tool,
                 in our case by EnergyPlus and OpenStudio.

.. [#os_mod_api] For an example OpenStudio Model API, see
                 https://github.com/NREL/OpenStudio/blob/develop/openstudiocore/src/model/BoilerHotWater.hpp
                 and
                 https://openstudio-sdk-documentation.s3.amazonaws.com/cpp/OpenStudio-1.12.3-doc/model/html/classopenstudio_1_1model_1_1_pipe_adiabatic.html.
