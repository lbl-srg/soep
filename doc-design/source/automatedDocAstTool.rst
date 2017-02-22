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
it means to be "different". For example, depending on the context, the
following types of changes may be ignored:

- changes to text in embedded HTML document
- changes in ordering of classes/models in a package
- addition of new functions (assuming functions would not be directly consumed
  by the OpenStudio tool)

The `ast_doc_diff` tool would be of use in particular when new versions of the
MBL are released and the OpenStudio team would like to check if there are
non-trivial changes they need to integrate.

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

Therefore, we will aim at delivering something closer to the source AST but
with a mind to construct the data model such that it is easy to trace
dependencies such as class extensions (i.e., inheritance) and replaceable
components.

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

            todo: what does type add? This information is already in the children.

                  mok: That is true that the information is in the children.
                  The 'type' information was proposed as a pre-processing step
                  that could assist OpenStudio in determining which connectors
                  (or other models) can be connected together. However, it may
                  be better to move this logic elsewhere.

            type="f:Modelica.SIunits.Current;p:Modelica.SIunits.Voltage">
            <variable

              todo: is it required that id below repeats the id of the parent?
                     It seems to give a conflict if a model from a different
                     package is extended, as then, the first part of the name
                     may change (say A extends B, B contains parameter p.
                     Then this is called A.p, and not A.B.p)

                    mok: We don't need to use the 'id' attribute but if we
                    do, each 'id' in a well-formed XML document must be unique:

                    https://www.w3.org/TR/2006/REC-xml11-20060816/#id

                    Regarding your example, one way this could be handled is
                    as follows:

                        <model id="A"><extends>B</extends></model>
                        <model id="B">
                          <variable id="B.p" ...></variable>
                        </model>
                    
                    In the above, one would have to "walk" the datastructure
                    to know of A.p's existance. We're definitely open to
                    handling this differently. We could perhaps go with
                    using a "name" attribute which does not echo the
                    entire path -- this would save space but would require
                    those consuming the data to recreate the paths.

              id="Ex1.PositivePin.v"
              type="Modelica.SIunits.Voltage"
              connect_type="potential"
              doc="Potential at the pin"/>
            <variable
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

            todo: above we used variable, but here we use var. Is this a typo?

                  mok: Yes, fixed below. Note that I don't want this example
                  to reflect the exact tag names and data model -- we still
                  need to discuss first; this is only a suggestion. Note: we
                  may want to investigate using more "terse" names as a means
                  of reducing file size (e.g., "v" instead of "variable" as an
                  extreme case); compression technology may make long variable
                  names a non-issue but we need to measure. There is also the
                  question of what data should appear as nested tags and what
                  should appear as attributes.

            <variable
              type="Bool"
              id="Ex1.TwoPin.useTheMod"
              variability="parameter">
              false
            </variable>
            <variable
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
            </variable>
            <variable
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
            </variable>
            <variable
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
            </variable>
            <variable
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
            </variable>
            <!-- equation section elided... -->
          </model>
          <!-- OK, and finally the Resistor -->
          <model
            id="Ex1.Resistor"
            doc="A DRY resistor model">
            <extends>Ex1.TwoPin</extends>
            <variable
              type="Modelica.SIunits.Resistance"
              id="Ex1.Resistor.R"
              variability="parameter">
            </variable>
            <!-- equation section elided... -->
          </model>
        </models>
      </package>
    </lib>

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
