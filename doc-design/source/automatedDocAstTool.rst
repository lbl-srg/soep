Automated Documentation/AST Support Tool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section describes an agreed-upon workflow, toolchain and process to
generate automated SOEP "documentation" and abstract syntax trees from Modelica
libraries; in particular, the Modelica Buildings Library (MBL).

The goal of this project is to make the `abstract syntax tree (AST)
<https://en.wikipedia.org/wiki/Abstract_syntax_tree>`_ of the Modelica
Buildings Library (MBL) [#fn_mbl]_ available to other tools. Specifically, this
work should be of use to the OpenStudio team for discovering available models
and their parameters and other metadata for use from the OpenStudio interface.

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
and other objects can be specified. Modelica Models also have a hierarchical
structure of packages, models, and models can be composed of multiple (possibly
replaceable) components. Much of this information will be required by the
OpenStudio tool in order to understand which components are available, where
they reside in the library structure, what parameters they have, how they can
be configured, how to display them, and what other meta-data are available
(such as documentation).

From initial discussion with Michael Wetter (LBNL) on this task, we've
identified the main focus will be to make the AST of Modelica source files
including the metadata mentioned above available to the OpenStudio team. We
will specifically focus on the Modelica Buildings Library (MBL), though as we
discuss later, the tool should also be able to work over other Modelica files
and libraries.

The intent of the AST "documentation" is *primarily* to be consumed by the
OpenStudio application for identification of models, model documentation, model
connecting points, inputs/outputs, and parameters and related meta-data.

Presumably, an OpenStudio application will consume some or all of the above
information, use it to provide an interface to the user, and ultimately write
out a Modelica file which connects the various library components, configures
various components and packages (for example, setting the "media" or working
fluid of fluid component models in various HVAC loops), and sets the various
parameter values.

To create models, information from other libraries, most notably, the Modelica
Standard Library (MSL) itself, may need to be made available. Typical
applications and examples from the Modelica Buildings Library (MBL) use
component models from both the MSL and MBL. There is also interest in being
able to support additional third party libraries over and above the MSL and
MBL. Therefore, it will be important that this tool is not limited to just
parsing/processing the MBL.

Also, related to meta-data, it has been proposed that the MBL add any
OpenStudio-specific metadata to the MBL files themselves. However, although
this may be easy and feasible for MBL, it may not be practical to consider
annotating the MSL or other third party libraries as we have no direct control
over that library and any custom annotations would have to be re-applied with
future MSL versions. Because of this, to the extent possible, it may be better
to not rely upon custom vendor-specific annotations where possible.

Proposed Workflow, Process, and Toolchain
"""""""""""""""""""""""""""""""""""""""""

We propose to build a stand-alone batch-process program that will transform any
Modelica input file or library (specifically, the Modelica Buildings Library in
particular although we have identified the need to possibly parse the MSL as
well) into an XML document. The XML document will contain:

- identification of which models, classes, connectors, functions, etc. exist
- identification of the relative hierarchy of the above components within the
  package structure of the library
- for each model, to know
    - what connection "ports" are available
    - what control inputs/outputs are available
    - what parameters are available
    - what configuration management options exist (ie, replaceable components
      and packages)
    - including meta-data and attributes for all the above such as graphics
      annotations, vendor annotations, html documentation, etc.

We believe the `JModelica
<http://www.jmodelica.org/api-docs/usersguide/JModelicaUsersGuide-1.17.0.pdf>`_
tool suite will be able to provide the proper parsing tools for the AST we
need. Specifically, we must ensure that the AST we derive from JModelica meets
all of our needs -- most notably, we must ensure we have access to all
annotations from a model. Thus, there are two key questions we must answer
before deciding whether we can embrace the JModelica toolchain for the current
effort:

1. Does the JModelica toolchain provide sufficient access to the full AST?
2. Is that access available through the Python interface?

We have confirmed with preliminary work that we can walk a source AST using the
Python API of JModelica 1.17. We have also determined that the AST information
does include annotation data. As such, our recommendation would be to build the
tool in Python.

The Python interface to JModelica appears the most logical choice as it is the
most developed, documented, and user-facing of the APIs for JModelica -- in
fact, it is the only user-facing interface to the open-source JModelica
toolsuite at the moment. We have used and have demonstrated that the JModelica
interface does indeed expose at least some of the main hooks into the compiler
including, most notably, access to the AST including annotations (using version
1.17). Python is well known and loved by many developers, most notably those in
the engineering domain and offers quite a few tools and libraries (including
XML libraries) that can be used/added if needed.

The signature of the batch program we will write will be::

    ast_doc_gen <options> --out <outputfile-path> <path_to_modelica_library>

Or looking at this as a data-flow diagram::

    modelica-library-on-filesystem ==> xml-file

The `ast_doc_gen` tool will generate an XML file at ``outputfile-path`` based
on the library available at ``path_to_modelica_library``. We propose that there
should only be one library documented per XML file. If additional library data
is generated, (for example, the MSL), each library should get its own file.

Options could include flags to allow turning off/on the reporting of various
constructs in the source library.

An additional feature of the tool will be to perform a "diff" (i.e., logical
differences) between two generated XML files. The signature for this
application would be::

    ast_doc_diff <options> --out <path_to_diff_report> <path1> <path2>

The data-flow diagram would be::

    (path1, path2) ==> xml-file

The purpose of this tool would be to detect any non-trivial differences between
two generated XML files that hold the AST of a Modelica library and report
those changes out to another XML file. The content of this XML file would
explicitly show the differences between the two input manifests. The options
here would allow for tweaking the meaning of what it means to be "different".
For example, depending on the context, the following types of changes may be
ignored:

- changes to text in embedded HTML document
- changes in ordering of classes/models in a package
- addition of new functions (assuming functions would not be directly consumed
  by the OpenStudio tool)

Discussion and Details
""""""""""""""""""""""

A key area of agreement will need to be reached on what data gets put into the
XML output. Specifically, we need to think through how to represent the
models in the MBL in such a way that they can be consumed by the *OpenStudio*
toolchain. At the planning meeting on February 1, 2017, it was discussed that
we generally want all of the information from the source AST *except* equation
and algorithm sections. All annotations should be made available.

One consideration will be: which version of the AST should be used to represent
packages, classes, models, etc. The `JModelica User's Guide 1.17
<http://www.jmodelica.org/api-docs/usersguide/JModelicaUsersGuide-1.17.0.pdf>`_
in Chapter 9 talks about three kinds of AST: source level, instance level, and
flattened.  The flattened AST is not relevant for us (it corresponds to a fully
flattened model instance ready to be compiled; our interest is in browsing all
objects for potential configuration).

The source level AST corresponds 1:1 to the original files in both structure
and content. Although the source AST is what we need, it does not expand out
components and extended classes and thus may require additional processing by
consumers.

An instance level AST, in contrast, represents the fully expanded instance of a
given model or class, including configurations. Although this is tempting to
use, we are dealing with a library, not a model *instance*. It will be
*OpenStudio*'s job to build and specify a model class to instantiate.
Especially due to Modelica's configuration mechanism, it would be dangerous to
treat object *classes* as *instances*.

For an example, consider the following model (adapted from `Modelica by
Example: Electrical Components
<http://book.xogeny.com/components/components/elec_comps/>`_):

::

    package Ex1
      connector PositivePin "Positive pin of an electric component"
        Modelica.SIunits.Voltage v "Potential at the pin";
        flow Modelica.SIunits.Current i "Current flowing into the pin";
      end PositivePin;

      connector NegativePin "Negative pin of an electric component"
        Modelica.SIunits.Voltage v "Potential at the pin";
        flow Modelica.SIunits.Current i "Current flowing into the pin";
      end NegativePin;

      partial model TwoPin "Common elements of two pin electrical components"
        parameter Bool useTheMod=false "If true, use thermal model";
        PositivePin p
          annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
        NegativePin n
          annotation (Placement(transformation(extent={{90,-10},{110,10}})));
      protected
        Modelica.SIunits.Voltage v = p.v-n.v;
        Modelica.SIunits.Current i = p.i;
      equation
        p.i + n.i = 0 "Conservation of charge";
      end TwoPin;

      model Resistor "A DRY resistor model"
        extends TwoPin;
        parameter Modelica.SIunits.Resistance R;
      equation
        v = i*R "Ohm's law";
      end Resistor;
    end Example1;

In this (very simple) model described above, a possible XML representation might be::

    <?xml version="1.0" encoding="UTF-8"?>
    <!--
      A library could be given a different ID than the top level package
      name. For example, the "Modelica Buildings Library"'s top level package
      is "Buildings". Here, we use Example1 for the library name and
      "Ex1" for the top-level package name. Presumably, the "Example1" meta
      data has been passed in out-of-band or via the annotation mechanism.
    -->
    <lib id="Example1">
      <package id="Ex1">
        <!-- specify package order by top-level model ids -->
        <order>Ex1.PositivePin,Ex1.NegativePin,Ex1.TwoPin,Ex1.Resistor</order>
        <connectors>
          <!--
            below, we derive a unique "hash-key" for the type that will allow
            us to identify that PositivePin connectors can be connected to
            NegativePin connectors

            Note: we use the fully qualified names for IDs both because XML
            requires unique ids and also for our identification purposes.

            The "f:" and "p:" prefixes indicate f: as "flow" and p as
            "potential" variables. An "s:" prefix would indicate a "stream"
            variable. The hash is the listing of all types in a connection with
            prefixes put together in alphabetical order separated by
            semicolons. Comparing on these type hashes would allow a tool to
            know which connectors could be connected together.
          -->
          <connector
            id="Ex1.PositivePin"
            type="f:Modelica.SIunits.Current;p:Modelica.SIunits.Voltage">
            <variable
              id="Ex1.PositivePin.v"
              type="Modelica.SIunits.Voltage"
              connect_type="potential"
              doc="Potential at the pin"/>
            <var
              id="Ex1.PositivePin.i"
              type="Modelica.SIunits.Current"
              connect_type="flow"
              doc="Potential at the pin"/>
          </connector>
          <connector
            id="Ex1.NegativePin"
            type="f:Modelica.SIunits.Current;p:Modelica.SIunits.Voltage">
            <variable
              id="Ex1.NegativePin.v"
              type="Modelica.SIunits.Voltage"
              connect_type="potential"
              doc="Potential at the pin"/>
            <variable
              id="Ex1.NegativePin.i"
              type="Modelica.SIunits.Current"
              connect_type="flow"
              doc="Potential at the pin"/>
          </connector>
        </connectors>
        <models>
          <model
            id="Ex1.TwoPin"
            type="partial"
            doc="Common elements of two pin electrical components">
            <var
              type="Bool"
              id="Ex1.TwoPin.useTheMod"
              variability="parameter">
              false
            </var>
            <var
              type="Ex1.PositivePin"
              id="Ex1.TwoPin.p"
              variability="continuous">
              <!--
                Note: "Placement" annotation downcased
              -->
              <annotation>
                <placement>
                  <transformation>
                    <extent>{{-110,-10},{-90,10}}</extent>
                  </transformation>
                </placement>
              </annotation>
            </var>
            <var
              type="Ex1.NegativePin"
              id="Ex1.TwoPin.n"
              variability="continuous">
              <annotation>
                <placement>
                  <transformation>
                    <extent>{{90,-10},{110,10}}</extent>
                  </transformation>
                </placement>
              </annotation>
            </var>
            <var
              type="Modelica.SIunits.Voltage"
              id="Ex1.TwoPin.v"
              variability="continuous"
              visibility="protected">
              <annotation>
                <placement>
                  <transformation>
                    <extent>{{90,-10},{110,10}}</extent>
                  </transformation>
                </placement>
              </annotation>
            </var>
            <var
              type="Modelica.SIunits.Current"
              id="Ex1.TwoPin.i"
              variability="continuous"
              visibility="protected">
              <annotation>
                <placement>
                  <transformation>
                    <extent>{{90,-10},{110,10}}</extent>
                  </transformation>
                </placement>
              </annotation>
            </var>
            <!-- equation section elided... -->
          </model>
          <!-- OK, and finally the Resistor -->
          <model
            id="Ex1.Resistor"
            doc="A DRY resistor model">
            <extends>Ex1.TwoPin</extends>
            <var
              type="Modelica.SIunits.Resistance"
              id="Ex1.Resistor.R"
              variability="parameter">
            </var>
            <!-- equation section elided... -->
          </model>
        </models>
      </package>
    </lib>

Fortunately, there have been several attempts to represent or use XML in relation
to Modelica in the past:

- `N. Landin. (2014). "XML export and import of Modelica Models"
  <https://gupea.ub.gu.se/bitstream/2077/38718/1/gupea_2077_38718_1.pdf>`_
- `ModelicaXML Schema <https://github.com/modelica-association/ModelicaXML>`_
- `Appendix G of Fritzson (2004) "Principles of ... with Modelica 2.1"
  <http://onlinelibrary.wiley.com/store/10.1002/9780470545669.app7/asset/app7.pdf?v=1&t=iyq3ixri&s=3acd1aef6559f8c230d827878d73980bdd1407f2>`_
- `A. Pop and P. Fritzson. (2003). "ModelicaXML..."
  <https://modelica.org/events/Conference2003/papers/h39_Pop.pdf>`_
- `A. Pop and P. Fritzson. ModelicaXML Presentation
  <http://www.ida.liu.se/~adrpo33/modelica/ModelicaXML-Presentation-2003-11-04.pdf>`_
- `U. Reisenbichler et al. 2006. "If we only had used XML..."
  <https://www.modelica.org/events/modelica2006/Proceedings/sessions/Session6d1.pdf>`_

In particular, the first reference above links to a 2014 Master's Thesis
describing the work of N. Landin with Modelon using JModelica to export XML for
the purpose of model exchange -- this is very similar to our use case.
Unfortunately, this work deals only with "flattened" models -- Modelica models
that have been instantiated with all of the hierarchy removed. For our use
case, the hierarchy must be preserved so that the OpenStudio team can
*construct* a new model from existing library definitions.

The paper by Reisenbichler 2006 motivates the usage of XML in association with
Modelica without getting into specifics. The remaining work by Pop and Fritzson
is thus the only comprehensive proposals for an XML representation of Modelica
*source* AST. The purpose of the XML work by Pop and Fritzson was to create a
complete XML representation of the entire Modelica source. It is generally a good
reference but we note that it is, perhaps unnecessarily, verbose for our
current needs. As such, we plan to study this work but will not tie ourselves
to it.

Summary of Questions and Next Steps
"""""""""""""""""""""""""""""""""""

**Questions**:

- It is our understanding that there is both a paid "proprietary" API as well
  as an "open source" API (which is not guaranteed to be stable) for accessing
  the AST of JModelica. Can we get a better understanding of the differences
  between the two?
- We have confirmed that JModelica 1.17 does support parsing AST of annotations
  and models. We need to confirm that custom directives are supported as well.
- The exact data design for XML output must to be determined. What data will
  the OpenStudio need access to?

**Next Steps**:

- Write a tool using the JModelica Python API to extract AST data from Modelica
  Models in a library and write that data out as XML
- Design the XML end format
- Create diff tool for comparing xml library dumps in a meaningful way

References
""""""""""

JModelica User Guide

    "JModelica.org User Guide: Version 1.17". Available at:
    http://www.jmodelica.org/api-docs/usersguide/JModelicaUsersGuide-1.17.0.pdf

.. rubric:: Footnotes

.. [#fn_mbl] Our main focus is to support the Modelica Buildings Library but
             the tool should also work for other Modelica file import/parsing
             tasks
