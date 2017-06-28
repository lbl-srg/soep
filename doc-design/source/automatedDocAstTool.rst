Automated Documentation/AST Support Tool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section describes an agreed-upon workflow, toolchain and process to
generate automated SOEP "documentation" and abstract syntax trees from Modelica
libraries; in particular, the Modelica Buildings Library (MBL).

The goal of this effort is to build a computer program that makes the `abstract
syntax tree (AST) <https://en.wikipedia.org/wiki/Abstract_syntax_tree>`_ of the
Modelica Buildings Library (MBL) [#fn_mbl]_ available to other tools via an XML
file. Specifically, this work should be of use to the OpenStudio team for
discovering available models and their parameters and other metadata for use
from the OpenStudio interface for SOEP.

Background
""""""""""

Modelica source code contains quite a lot of meta-data in addition to the
mathematical model itself. An annotation system exists within Modelica and
custom annotations can be written to pass data to tools. Annotations were
designed to be an extensible mechanism for capturing meta-data related to a
model including html-documentation, vendor-specific data, and graphical
annotations. Parameters, variables, equations, and models can contain
documentation strings and annotations. Furthermore, packages can be documented
and the display order of sub-packages, models, classes, functions, connectors
and other objects can be specified. Modelica libraries have a hierarchical
structure consisting mainly of packages which contain models and other objects
as well as sub-packages. Models themselves can be composed of multiple (possibly
replaceable) components. Much of this information will be required by the
OpenStudio tool in order to understand which component models are available,
where they reside in the library's package structure (i.e., their fully
qualified name), what parameters they have, how they can be configured, how to
display them, and what other meta-data are available (such as documentation
strings and full-on HTML documentation).

This section is concerned about making the AST of Modelica source files,
including the metadata mentioned above, available to OpenStudio. We
will specifically focus on the Modelica Buildings Library (MBL), though as we
discuss later, the tool should also be able to work with other Modelica
packages and blocks.

The intent of the AST representation is *primarily* to be consumed by the
OpenStudio application for identification of models, model documentation, model
connecting points, inputs/outputs, and parameters and related meta-data.

Presumably, an OpenStudio application will consume some or all of the above
information, use it to provide an interface to the user, and ultimately write
out a Modelica file which connects the various library components, configures
various components and packages (for example, setting the "media" or working
fluid of fluid component models in various HVAC loops), and assigning
values to parameters.

To create models, information from other libraries, most notably, the Modelica
Standard Library (MSL) itself, may need to be made available. Typical
applications and examples from the MBL use
component models from both the MSL and MBL. There is also interest in being
able to support additional third party libraries over and above the MSL and
MBL. Therefore, it will be important that this tool is not limited to just
parsing/processing the MBL.

Also, related to meta-data, it has been proposed that the MBL add any
OpenStudio-specific metadata to the MBL files themselves. It was originally
envisioned that Modelica's annotations should support just such a use-case.
It has been noted that if components from other libraries need to be made
available to OpenStudio, they could be pulled into the MBL and annotated
(for example, components from Modelica.Blocks).

Proposed Workflow, Process, and Toolchain
"""""""""""""""""""""""""""""""""""""""""

We propose to build a stand-alone batch-process program that will transform any
Modelica input file or library (specifically, the Modelica Buildings Library in
particular) into an XML document. The XML document will contain:

- identification of which models, classes, connectors, functions, etc. exist
- identification of the relative hierarchy of the above components within the
  package structure of the library
- for each package, to know
    - what models are available
    - what connection "ports" are available
    - for fluid ports, which ports carry the same fluid (so that media
      assignments can be propagated through a circuit)
    - what control inputs/outputs are available
    - what parameters are available
    - what configuration management options exist (i.e., replaceable components
      and packages and which parameters belong to which component)
    - including meta-data and attributes for all the above such as graphics
      annotations, vendor annotations, html documentation, etc.

Although we intend to build a stand-alone tool, there is interest from the
OpenStudio team in using this tool directly and/or incorporating the algorithms
into the OpenStudio interface to import new Modelica libraries and files. As
such, there are some upstream constraints such as a desire to minimize
dependencies. We will discuss this more below when we talk about programming
language.

We believe the `JModelica
<http://www.jmodelica.org/api-docs/usersguide/JModelicaUsersGuide-1.17.0.pdf>`_
tool suite will be able to provide the proper parsing tools for the AST we
need. Specifically, we must ensure that the AST we derive from JModelica meets
all of our needs -- most notably, we must ensure we have access to all
annotations. Specifically, we are looking to JModelica for the following:

1. Provide programmatic access to the full AST of Modelica libraries
2. Provide that access through the Java and/or Python API.

We have confirmed with preliminary work that we can walk a source AST of a
single Modelica file using the Python API of JModelica 1.17. We have also
determined that the AST information does include annotation data.
The OpenStudio team has expressed a preference for
using the Java API directly in hopes of reducing the dependencies required for
packaging. Therefore, we will use the Java API and develop a Java application
for accessing the AST parser.

The signature of the batch program we will write will be::

    ast_doc_gen <options> --out <outputfile-path> <path_to_modelica_library>

Or looking at this as a data-flow diagram::

    modelica-library-on-filesystem ==> xml-file

The `ast_doc_gen` tool will generate an XML file at ``outputfile-path`` based
on the library available at ``path_to_modelica_library``. We propose that there
should only be one library documented per XML file. If additional library data
is generated, (for example, the MSL), each library should get its own file.

Options could include flags to allow turning off/on the reporting of various
constructs in the source library and for selecting only certain packages to
import. For example, the OpenStudio team may need to make the `Modelica.Block`
package of the MSL available for use with the MBL but would not necessarily
need to include other packages such as `Modelica.Magnetic`,
`Modelica.Electrical`, or `Modelica.Mechanics`.

An additional feature of the tool will be to perform a "diff" (i.e., logical
differences) between two generated XML files. The signature for this
application would be::

    ast_doc_diff <options> --out <path_to_diff_report> <path1> <path2>

The data-flow diagram would be::

    (path1, path2) ==> xml-file

The purpose of the `ast_doc_diff` tool would be to detect non-trivial
differences between two generated XML files that hold the AST of a Modelica
library and report those changes out to another XML file. The content of the
"difference" XML file would explicitly show the differences between the two
input manifests. The options here would allow for tweaking the meaning of what
it means to be "different".

The following two lists attempt to list out examples of changes that
cannot be ignored as well as changes that can be ignored.

*Significant Changes (Cannot be Ignored)*

- changes to names of any public model/block, public parameters, variables,
  connectors, or subcomponents
- addition/subtraction of any public parameters, variables, connectors,
  or subcomponents
- addition/subtraction of packages/models/blocks/functions meant to be consumed
  by OpenStudio
- moving a model/block/function between packages (i.e., changing the path)

*Changes that may be Ignored*

- changes in style without changes in meaning (addition or removal of
  whitespace, windows newlines to linux newlines or vice versa, reordering
  within a section)
- changes to documentation strings
- changes to text in embedded HTML documentation
- changes to revision notes
- changes to graphical annotations
- changes in ordering of models/blocks/functions within a package
- changes to `protected` sections of code
- changes to `equation` or `algorithm` sections of code
- changes to some models/blocks/functions may be completely ignored if, by
  convention, we deem certain paths as "not directly consumable" by OpenStudio.
  For example, we may wish to not consume paths under a `BaseClasses`,
  `Examples`, or `Functions` designation.

To summarize, the creation of or changes to the "public API" (public
parameters, variables, subcomponents, connectors) of models, blocks, or
functions must be compared for change detection. Documentation (HTML)/
documentation strings/graphics annotations will not affect the model interface
or semantics. Changes to protected properties or equations will not affect
the interface (but may affect the actual numeric output quantities).

Annotations could be used to signal status changes such as "deprecation".

The `ast_doc_diff` tool would be of use in particular when new versions of the
MBL are released and the OpenStudio team would like to check if there are
non-trivial changes they need to integrate.


Literature review
"""""""""""""""""

There have been several attempts to represent or use XML in relation to
Modelica in the past (:cite:`Landin2014`, :cite:`Fritzson2003G`, :cite:`Pop2003`, :cite:`Pop2005`, and :cite:`Reisenbichler2006`).

In particular, N. Landin did work with Modelon using JModelica to export XML for
the purpose of model exchange :cite:`Landin2014` -- this is very similar to our use case.
Unfortunately, this work deals only with "flattened" models -- Modelica models
that have been instantiated with all of the hierarchy removed. For our use
case, the hierarchy must be preserved so that the OpenStudio team can
build a new model through instantiation of models from the MBL.

The paper by Reisenbichler 2006 motivates the usage of XML in association with
Modelica without getting into specifics :cite:`Reisenbichler2006`. The remaining work by Pop and Fritzson
is thus the only comprehensive work on an XML representation of Modelica
*source* AST that appears in the literature (:cite:`Pop2003`, :cite:`Pop2005`, and :cite:`Fritzson2003G`). The purpose of the XML work by Pop
and Fritzson was to create a complete XML representation of the entire Modelica
source. It is generally a good reference but we note that it is, perhaps
unnecessarily, verbose for our current needs. As such, although we will refer
to this work, we do not plan to duplicate it.


Discussion and Details
""""""""""""""""""""""

.. todo:: We are currently evaluating whether to use the commercial JModelica API
          directly to do the following or whether to generate XML. We will
          leave the discussion in as-is for now as it captures some elements
          of the design work but it needs to be updated once a decision is made.

A key area of work will be on designing the data model of the XML output.
Specifically, we need to think through how to represent the models in the MBL
in such a way that they can be consumed by the *OpenStudio* toolchain. At the
planning meeting on February 1, 2017, it was discussed that we generally want
all of the information from the source AST *except* equation and algorithm
sections. All annotations should be made available.

One consideration will be: which version of the AST should be used to represent
packages, classes, models, etc. The `JModelica User's Guide 1.17
<http://www.jmodelica.org/api-docs/usersguide/JModelicaUsersGuide-1.17.0.pdf>`_
in Chapter 9 talks about three kinds of AST: source level, instance level, and
flattened. The flattened AST is not relevant for us (it corresponds to a fully
flattened model instance ready to be compiled; our interest is in browsing all
objects for potential configuration).

The source level AST corresponds 1:1 to the original files in both structure
and content. Although the source AST is what we need, it does not expand out
components and extended classes and thus may require additional processing by
consumers.

An instance level AST, in contrast, represents the fully expanded instance of a
given model or class, including configurations. Although this is tempting to
use, we must remember that we are dealing with a library, not a model
*instance*. It will be *OpenStudio*'s job to build and specify a model class to
instantiate. Especially due to Modelica's configuration mechanism, it would be
dangerous to treat object *classes* as *instances*.

Therefore, we delivered something closer to the source AST but
with a mind to construct the data model such that it is easy to trace
dependencies such as class extensions (i.e., inheritance) and replaceable
components.

For an example, consider the following model

.. code-block:: modelica

   within Buildings.Fluid.HeatExchangers;
   model HeaterCooler_T
     "Ideal heater or cooler with a prescribed outlet temperature"
     extends Buildings.Fluid.Interfaces.PartialTwoPortInterface;
     extends Buildings.Fluid.Interfaces.TwoPortFlowResistanceParameters(
       final computeFlowResistance=(abs(dp_nominal) > Modelica.Constants.eps));
     extends Buildings.Fluid.Interfaces.PrescribedOutletStateParameters(
       T_start=Medium.T_default);
   
     parameter Boolean homotopyInitialization = true "= true, use homotopy method"
       annotation(Evaluate=true, Dialog(tab="Advanced"));
   
     Modelica.Blocks.Interfaces.RealInput TSet(unit="K", displayUnit="degC")
       "Set point temperature of the fluid that leaves port_b"
       annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
   
     Modelica.Blocks.Interfaces.RealOutput Q_flow(unit="W")
       "Heat added to the fluid (if flow is from port_a to port_b)"
       annotation (Placement(transformation(extent={{100,50},{120,70}})));
   
   protected
     Buildings.Fluid.FixedResistances.PressureDrop preDro(
       redeclare final package Medium = Medium,
       final m_flow_nominal=m_flow_nominal,
       final deltaM=deltaM,
       final allowFlowReversal=allowFlowReversal,
       final show_T=false,
       final from_dp=from_dp,
       final linearized=linearizeFlowResistance,
       final homotopyInitialization=homotopyInitialization,
       final dp_nominal=dp_nominal) "Flow resistance"
       annotation (Placement(transformation(extent={{-50,-10},{-30,10}})));
   
     Buildings.Fluid.Interfaces.PrescribedOutletState heaCoo(
       redeclare final package Medium = Medium,
       final allowFlowReversal=allowFlowReversal,
       final m_flow_small=m_flow_small,
       final show_T=false,
       final show_V_flow=false,
       final Q_flow_maxHeat=Q_flow_maxHeat,
       final Q_flow_maxCool=Q_flow_maxCool,
       final m_flow_nominal=m_flow_nominal,
       final tau=tau,
       final T_start=T_start,
       final energyDynamics=energyDynamics) "Heater or cooler"
       annotation (Placement(transformation(extent={{20,-10},{40,10}})));
   equation
     connect(port_a, preDro.port_a) annotation (Line(
         points={{-100,0},{-50,0}},
         color={0,127,255}));
     connect(preDro.port_b, heaCoo.port_a) annotation (Line(
         points={{-30,0},{20,0}},
         color={0,127,255}));
     connect(heaCoo.port_b, port_b) annotation (Line(
         points={{40,0},{100,0}},
         color={0,127,255}));
     connect(heaCoo.TSet, TSet) annotation (Line(
         points={{18,8},{0,8},{0,60},{-120,60}},
         color={0,0,127}));
     connect(heaCoo.Q_flow, Q_flow) annotation (Line(
         points={{41,8},{72,8},{72,60},{110,60}},
         color={0,0,127}));
     annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,
               -100},{100,100}}), graphics={
           Rectangle(
             extent={{-70,60},{60,-60}},
             lineColor={0,0,255},
             pattern=LinePattern.None,
             fillColor={95,95,95},
             fillPattern=FillPattern.Solid),
           Rectangle(
             extent={{-102,5},{99,-5}},
             lineColor={0,0,255},
             pattern=LinePattern.None,
             fillColor={0,0,0},
             fillPattern=FillPattern.Solid),
           Rectangle(
             extent={{-100,60},{-70,58}},
             lineColor={0,0,255},
             pattern=LinePattern.None,
             fillColor={0,0,127},
             fillPattern=FillPattern.Solid),
           Text(
             extent={{-106,98},{-62,70}},
             lineColor={0,0,127},
             textString="T"),
           Rectangle(
             extent={{60,60},{100,58}},
             lineColor={0,0,255},
             pattern=LinePattern.None,
             fillColor={0,0,127},
             fillPattern=FillPattern.Solid),
           Text(
             extent={{72,96},{116,68}},
             lineColor={0,0,127},
             textString="Q_flow")}),
   defaultComponentName="hea",
   Documentation(info="<html>
   <p>
   Model for an ideal heater or cooler with a prescribed outlet temperature.
   </p>
   <p>
   This model forces the outlet temperature at <code>port_b</code> to be equal to the temperature
   of the input signal <code>TSet</code>, subject to optional limits on the
   heating or cooling capacity <code>Q_flow_max</code> and <code>Q_flow_min</code>.
   For unlimited capacity, set <code>Q_flow_maxHeat = Modelica.Constant.inf</code>
   and <code>Q_flow_maxCool=-Modelica.Constant.inf</code>.
   </p>
   <p>
   The output signal <code>Q_flow</code> is the heat added (for heating) or subtracted (for cooling)
   to the medium if the flow rate is from <code>port_a</code> to <code>port_b</code>.
   If the flow is reversed, then <code>Q_flow=0</code>.
   The outlet temperature at <code>port_a</code> is not affected by this model.
   </p>
   <p>
   If the parameter <code>energyDynamics</code> is not equal to
   <code>Modelica.Fluid.Types.Dynamics.SteadyState</code>,
   the component models the dynamic response using a first order differential equation.
   The time constant of the component is equal to the parameter <code>tau</code>.
   This time constant is adjusted based on the mass flow rate using
   </p>
   <p align=\"center\" style=\"font-style:italic;\">
   &tau;<sub>eff</sub> = &tau; |m&#775;| &frasl; m&#775;<sub>nom</sub>
   </p>
   <p>
   where
   <i>&tau;<sub>eff</sub></i> is the effective time constant for the given mass flow rate
   <i>m&#775;</i> and
   <i>&tau;</i> is the time constant at the nominal mass flow rate
   <i>m&#775;<sub>nom</sub></i>.
   This type of dynamics is equal to the dynamics that a completely mixed
   control volume would have.
   </p>
   <p>
   Optionally, this model can have a flow resistance.
   If no flow resistance is requested, set <code>dp_nominal=0</code>.
   </p>
   <p>
   For a model that uses a control signal <i>u &isin; [0, 1]</i> and multiplies
   this with the nominal heating or cooling power, use
   <a href=\"modelica://Buildings.Fluid.HeatExchangers.HeaterCooler_u\">
   Buildings.Fluid.HeatExchangers.HeaterCooler_u</a>
   </p>
   <h4>Limitations</h4>
   <p>
   This model only adds or removes heat for the flow from
   <code>port_a</code> to <code>port_b</code>.
   The enthalpy of the reverse flow is not affected by this model.
   </p>
   <p>
   This model does not affect the humidity of the air. Therefore,
   if used to cool air below the dew point temperature, the water mass fraction
   will not change.
   </p>
   <h4>Validation</h4>
   <p>
   The model has been validated against the analytical solution in
   the examples
   <a href=\"modelica://Buildings.Fluid.HeatExchangers.Validation.HeaterCooler_T\">
   Buildings.Fluid.HeatExchangers.Validation.HeaterCooler_T</a>
   and
   <a href=\"modelica://Buildings.Fluid.HeatExchangers.Validation.HeaterCooler_T_dynamic\">
   Buildings.Fluid.HeatExchangers.Validation.HeaterCooler_T_dynamic</a>.
   </p>
   </html>",
   revisions="<html>
   <ul>
   <li>
   December 1, 2016, by Michael Wetter:<br/>
   Updated model as <code>use_dh</code> is no longer a parameter in the pressure drop model.<br/>
   This is for
   <a href=\"https://github.com/ibpsa/modelica/issues/480\">#480</a>.
   </li>
   <li>
   November 11, 2014, by Michael Wetter:<br/>
   Revised implementation.
   </li>
   <li>
   March 19, 2014, by Christoph Nytsch-Geusen:<br/>
   First implementation.
   </li>
   </ul>
   </html>"));
   end HeaterCooler_T;


When parse to a json representation, the output of its public declarations is as follows:

.. code-block:: javascript

   "Buildings.Fluid.HeatExchangers.HeaterCooler_T": {
       "name": "Buildings.Fluid.HeatExchangers.HeaterCooler_T",
       "comment": "Ideal heater or cooler with a prescribed outlet temperature",
       "qualifiers": [
           "model"
       ],
       "superClasses": [
           {
               "nameOfExtendedClass": "Buildings.Fluid.Interfaces.PartialTwoPortInterface"
           },
           {
               "nameOfExtendedClass": "Buildings.Fluid.Interfaces.TwoPortFlowResistanceParameters",
               "modifications": [
                   {
                       "name": "computeFlowResistance",
                       "qualifiers": [
                           "final"
                       ],
                       "value": "abs(dp_nominal)>Modelica.Constants.eps"
                   }
               ]
           },
           {
               "nameOfExtendedClass": "Buildings.Fluid.Interfaces.PrescribedOutletStateParameters",
               "modifications": [
                   {
                       "name": "T_start",
                       "value": "Medium.T_default"
                   }
               ]
           }
       ],
       "components": [
           {
               "className": "Boolean",
               "qualifiers": [
                   "parameter"
               ],
               "name": "homotopyInitialization",
               "comment": "= true, use homotopy method",
               "value": "true",
               "annotations": {
                   "dialog": "Dialog(tab = \"Advanced\")"
               }
           },
           {
               "className": "Modelica.Blocks.Interfaces.RealInput",
               "name": "TSet",
               "comment": "Set point temperature of the fluid that leaves port_b",
               "modifications": [
                   {
                       "name": "unit",
                       "value": "\"K\""
                   },
                   {
                       "name": "displayUnit",
                       "value": "\"degC\""
                   }
               ],
               "annotations": {
                   "placement": "Placement(transformation(extent = {{-140,40},{-100,80}}))"
               }
           },
           {
               "className": "Modelica.Blocks.Interfaces.RealOutput",
               "name": "Q_flow",
               "comment": "Heat added to the fluid (if flow is from port_a to port_b)",
               "modifications": [
                   {
                       "name": "unit",
                       "value": "\"W\""
                   }
               ],
               "annotations": {
                   "placement": "Placement(transformation(extent = {{100,50},{120,70}}))"
               }
           }
       ],
       "annotations": {
           "documentationInfo": "info = \"<html>\n<p>\nModel for an ideal heater or cooler with 
           a prescribed outlet temperature.\n</p>\n<p>\nThis model forces the outlet temperature at <code>port_b</code> 
           [further text has been omitted]
           </html>\"",
           "icon": "Icon(coordinateSystem(preserveAspectRatio = false, 
                          extent = {{-100,-100},{100,100}}), 
                          graphics = {Rectangle(),Rectangle(),Rectangle(),Text(),Rectangle(),Text()})"
       }
   }


Hence, OpenStudio can reads its parameters from the json file. Note that it also will need to parse the json
representation from the ``superClasses``, for example
to obtain the connectors and parameters, including their modifications, from
``Buildings.Fluid.Interfaces.PartialTwoPortInterface``.



Summary of Questions and Next Steps
"""""""""""""""""""""""""""""""""""

**Questions**:

- What pre-processing on the extracted data would be useful?

**Next Steps**:

- Make a decision as to the JModelica API to use
- Determine what constitutes a significant difference between different versions of the
  Modelica Buildings Library and how to communicate those
- Write the proposed programs using JModelica to extract AST data from Modelica
  Models in a library and write that data out as XML.
- Create diff tool for comparing versions of the MBL in a meaningful way

.. rubric:: Footnotes

.. [#fn_mbl] Our main focus is to support the Modelica Buildings Library but
             the tool should also work for other Modelica libraries.
