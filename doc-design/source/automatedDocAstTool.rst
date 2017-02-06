Automated Documentation/AST Support Tool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section describes an agreed-upon workflow, toolchain and process to
generate automated SOEP "documentation" and abstract syntax trees.

The goal of this project is to make the `abstract syntax tree (AST)
<https://en.wikipedia.org/wiki/Abstract_syntax_tree>`_ of the Modelica
Buildings Library (MBL) [#fn_mbl]_ available to other tools, most notably, the
OpenStudio team. Notably, the AST shall contain both the HTML documentation for
the models, functions, and packages contained within.

The AST output format shall be used to understand what models exist within the
MBL, what their parameters are, what replaceable components exist, as well as
the meta-data related to the given components such as help strings, min/max
limits, units, annotations, etc.

Background
""""""""""

Modelica source code contains quite a lot of meta-data in addition to the
mathematical model itself. For example, parameters, variables, equations, and
models can contain documentation strings and annotations. Furthermore, packages
can be documented and the display order of sub-packages, models, classes,
functions, connectors and other objects can be specified. Modelica Models also
have a hierarchical structure of packages, models, and models can be composed
of multiple (possibly replaceable) components. Much of this information will be
required by the OpenStudio tool in order to understand which components are
available, where they reside in the library structure, what parameters they
have, and what meta-data are available (such as documentation).

From initial discussion with Michael Wetter (LBNL) on this task, we've
identified the main focus of this task will be to make the AST of Modelica
source files including the metadata mentioned above available to the
OpenStudio team. We will specifically focus on the Modelica Buildings Library
(MBL), though as we discuss later, the tool should also be able to work over
other Modelica files and libraries:

    The main effort will be in parsing the AST of the Modelica Buildings
    Library source to make available documentation and annotations,
    possibly transforming that information, and making the information
    available to the OpenStudio project in a usable form.

Notably, the AST contains all of the model-specific documentation but also
contains key information such as parameter names and metadata (including
parameter-specific "doc strings", units, minimums and maximum values, etc.),
model names and location in the package hierarchy, information on replaceable
packages such as used to change the working fluid definition (air, water,
glycol, refrigerant, etc.), and the annotations that go along with a model.
Specifically, annotations were designed to be an extensible mechanism for
capturing all other meta data related to a model including html-documentation,
vendor-specific data, and graphical annotations.

The intent of the AST "documentation" is *primarily* to be consumed by the
OpenStudio application for identification of models, model documentation, model
connecting points, inputs/outputs, and parameters and related meta-data.

Presumably, an OpenStudio application will consume some or all of the above
information, use it to provide an interface to the user, and ultimately write
out a Modelica file which connects the various library components, configures
various components and packages (for example, setting the "media" for the
working fluid in "air", "water", and refrigerant loops), and sets the various
parameter values.

Note: to create models, some or all of the above metadata will need to be made
available for the Modelica Standard Library (MSL) itself as a typical
application using the Modelica Buildings Library (MBL) will use model instances
from both the MSL and MBL. In this same sense, additional third party libraries
could also be added to the mix. Therefore, it will be important that this tool
is not limited to just parsing/processing the MBL.

Also, related to meta-data, it has been proposed that the MBL add any
OpenStudio-specific metadata to the MBL files themselves. However, although
this may be easy and feasible for MBL, it may not be practical to consider
annotating the MSL or other third party libraries as we have no direct control
over that library and any custom annotations would have to be re-applied with
future MSL versions. As such, we may want to consider a mechanism for
externally annotating Modelica models, packages, parameters, and/or
configurable components. Better yet, to the extent possible, it will be better
to not have to rely upon custom vendor-specific annotations where possible.

Proposed Workflow, Process, and Toolchain
"""""""""""""""""""""""""""""""""""""""""

We propose to build a stand-alone batch-process tool that will transform any
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
    - including meta-data for all the above
- consumption of meta-data related to models, packages, parameters

We believe the JModelica tool suite will be able to provide the proper parsing
tools for the AST we need. Specifically, we must ensure that the AST we derive
from JModelica meets all of our needs -- most notably, we must ensure we have
access to all annotations from a model. Thus, there are two key questions we
must answer before deciding whether we can embrace the JModelica toolchain for
the current effort:

1. Does the JModelica toolchain provide sufficient access to the full AST?
2. Is that access available through the Python interface?
3. Are there other means of exporting the AST -- for example an XML dump --
   that may be leveraged?

We have confirmed with a preliminary script that we can walk a source AST using
the Python API of JModelica 1.17. We have also determined that this AST walker
does include annotations. As such, our recommendation would be to build the
tool in python.

The Python interface to JModelica appears the most logical choice as it is the
most developed, documented, and user-facing of the APIs for JModelica -- in
fact, it is the only user-facing interface to the JModelica toolsuite at the
moment. We have used and have demonstrated that the JModelica interface does
indeed expose at least some of the main hooks into the compiler including, most
notably, access to the AST including annotations (using version 1.17). Python
is well known and loved by many developers, most notably those in the
engineering domain and offers quite a few tools and libraries that can be added
if needed.

JRuby is an attractive second choice that leverages internal experience with
Ruby at Big Ladder Software, the Java-based toolchain of JModelica (JRuby runs
on the Java Virtual Machine and has full access to Java classes and objects),
and the knowledge of Ruby available in the OpenStudio development team. That
said, we will attempt to leverage the Python interface first.

The signature of the batch program we will write will be::

    > ast_doc_gen <options> --out <outputfile-path> <path_to_modelica_library>

Or looking at this as a flow diagram::

    modelica-library* ==> xml-file

This will run the tool to generate an XML file at ``outputfile-path`` based on
the library available at ``path_to_modelica_library``. We propose that there
should only be one library documented per XML file. If additional libraries are
added, (for example, the MSL), they should each get their own file.

Options could include various flags to allow turning off/on the reporting of
various features.

An additional feature of the tool will be to perform a "diff" (i.e., logical
differences) between two generated XML files. The signature for this
application would be::

    > ast_doc_diff <options> --out <path_to_diff_report> <path1> <path2>

The purpose of this tool would be to detect any non-trivial differences between
the manifests of both XML files and report those changes out to another XML
file. The content of this XML file would explicitly show the differences
between the two input manifests. The options here would allow for tweaking the
meaning of "non-trivial". Examples of changes that could be considered
*trivial* include:

- changes to text in embedded HTML document
- changes in ordering of classes/models in a package
- addition of new functions (assuming functions would not be directly consumed
  by the OpenStudio tool)

Discussion and Details
""""""""""""""""""""""

A key area of agreement will need to be reached on what data gets put into the
XML data document. Specifically, we need to think through how to represent the
models in the MBL in such a way that they can be consumed by the *OpenStudio*
toolchain. Specifically, one consideration will be: which version of the AST
should be used to represent packages, classes, models, etc. The JModelica
User's Guide 1.17 in Chapter 9 talks about three kinds of AST: source level,
instance level, and flattened. The flattened AST is not relevant for us (it
corresponds to a fully flattened model instance ready to be compiled; our
interest is in browsing all objects for potential configuration).

The source level AST corresponds 1:1 to the original files in both structure
and content. Although the source AST is nominally what we need, it does not
expand out components and extended classes.

An instance level AST, in contrast, represents the fully expanded instance of a
given model or class, including configurations and such. Although this is
tempting to use, we are dealing with a library, not a model *instance*. It will
be *OpenStudio*'s job to build and specify a model class to instantiate.
Especially due to Modelica's configuration mechanism, it would be dangerous to
treat object *classes* as *instances*.

That said, we want to alleviate extensive processing that might be required by
the *OpenStudio* team in terms of chasing down class *extensions*, replaceable
packages, and such.

As this is getting rather abstract, let's switch to a concrete example.
Consider the following model (taken from `Modelica by Example: Electrical
Components <http://book.xogeny.com/components/components/elec_comps/>`_):

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
              <annotation>
                <Placement>
                  <transformation>
                    <extent>{{-110,-10},{-90,10}}</extent>
                  </transformation>
                </Placement>
              </annotation>
            </var>
            <var
              type="Ex1.NegativePin"
              id="Ex1.TwoPin.n"
              variability="continuous">
              <annotation>
                <Placement>
                  <transformation>
                    <extent>{{90,-10},{110,10}}</extent>
                  </transformation>
                </Placement>
              </annotation>
            </var>
            <var
              type="Modelica.SIunits.Voltage"
              id="Ex1.TwoPin.v"
              variability="continuous"
              visibility="protected">
              <annotation>
                <Placement>
                  <transformation>
                    <extent>{{90,-10},{110,10}}</extent>
                  </transformation>
                </Placement>
              </annotation>
            </var>
            <var
              type="Modelica.SIunits.Current"
              id="Ex1.TwoPin.i"
              variability="continuous"
              visibility="protected">
              <annotation>
                <Placement>
                  <transformation>
                    <extent>{{90,-10},{110,10}}</extent>
                  </transformation>
                </Placement>
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
- `Claytex's XML Reader Library
  <http://www.claytex.com/products/dymola/model-libraries/xml-reader/>`_
- `A. Pop and P. Fritzson. (2003). "ModelicaXML..."
  <https://modelica.org/events/Conference2003/papers/h39_Pop.pdf>`_
- `U. Reisenbichler et al. "If we only had used XML..."
  <https://www.modelica.org/events/modelica2006/Proceedings/sessions/Session6d1.pdf>`_
- `A. Pop and P. Fritzson. ModelicaXML Presentation
  <http://www.ida.liu.se/~adrpo33/modelica/ModelicaXML-Presentation-2003-11-04.pdf>`_

In particular, the first reference above links to a 2014 Master's Thesis
describing the work of N Landin with Modelon using JModelica to export XML for
the purpose of model exchange -- this is very similar to our use case. The
ModelicaXML specification mentioned in the thesis is available at the second
link above as a `Github Repo
<https://github.com/modelica-association/ModelicaXML>`_.

Our main concern with using the ModelicaXML approach directly is that it may be
too "detailed" for our use case and may still require a decent amount of
processing on the part of the reader of the code. The advantage, however, is
that it very definitely preserves the full AST of the source files. Also, if
JModelica has a means of generating a "standard" ModelicaXML file, it may be
more robust to write a tool that transforms the ModelicaXML versus the
more-direct "raw" AST from JModelica.

Summary of Questions and Next Steps
"""""""""""""""""""""""""""""""""""

- Does JModelica support MXML (Modelica XML) as mentioned in the theis by
  Landin 2014? If so, it may be easier to depend on JModelica writing out that
  XML and transforming it.
- We have confirmed that JModelica does support parsing AST of annotations and
  models. We need to confirm that custom directives are supported as well.

----------

Some key questions:

-  What is the source of what we will be transforming? Is it *only* the
   Modelica Buildings Library?

-  What, if any, configuration or meta-data will need to be included?

-  What data needs to be made available from the source?

   -  nominally: parameter names, model (fully-qualified) names, model
      documentation / information, replaceable systems?
   -  annotations? All annotations? Graphical representations?

-  What, if any processing/transformation needs to be performed?

   -  for example, do we need to compute the list of models available in
      each package?

-  How to will OpenStudio read what we create? What formats are
   needed/required?

-  What are the use-cases around using ``diffs`` (i.e., differences)
   between outputs created by this tool?

   -  what format should the ``diff`` be in? Either of the two formats
      proposed below could be used XML or SQL (tables) but more work
      will be required to describe the exact data model (i.e., table
      names/columns, or XML attributes/tags)
   -  what constitutes a *trivial* change to MBL from the OS
      perspective?
   -  what constitutes a *non-trivial* change to MBL from the OS
      perspective?

We assume this will be a batch process tool (single transformation of
source to some output format).

In terms of open-source parsers for Modelica source, in addition to what
might be available via the JModelica project, there are numerous (see
`References <#references>`__) open-source code repositories that claim
to parse Modelica syntax. Also, if it is more expedient, we can write
our own language parser but we would prefer to leverage existing tools
if necessary, with JModelica being the first to investigate.

We talk specifically about the capabilities of the JModelica compiler
below.

JModelica AST Parser
""""""""""""""""""""

JModelica is a toolchain and collection of libraries for parsing,
compiling, and simulating Modelica files. JModelica as a whole, is
written in C, Java, and Python.

A key question is whether the JModelica compiler provides sufficient
access to all Modelica annotations required by this effort. We have
demonstrated that JModelica does provide access to the AST of Models via
Python (and Java) -- see the `JModelica User
Guide <#jmodelica-user-guide>`__, chapter 9 for further discussion. A
preliminary experiment to see if JModelica 1.17 could parse annotations
was unsuccessful but more time is required to determine the parsing
capability of JModelica 1.17 as well as the latest code under
development. Method names related to annotations appear on the parsing
class so some functionality is believed to exist.

Proposal
""""""""

Big Ladder proposes to build a batch processing tool that transforms the
Modelica Buildings Library (MBL) and possible additional metadata into a
format more accessible to further processing (i.e., parsing, query,
and/or transformation) and use within OpenStudio. Potential options
include (but are not limited to) one or more of the following:

-  `XML <https://www.w3.org/XML/>`__ format
-  `SQL <https://en.wikipedia.org/wiki/SQL>`__ database file (i.e., a
   plain-text "dump" of SQL commands to populate an SQL database such as
   `SQLite <https://sqlite.org/>`__)

Depending on existing tooling planned or in-use for SOEP/OpenStudio, we
could also consider other formats such as
`JSON <http://www.json.org/>`__.

We will plan to use JModelica's tooling to provide the AST provided it
yields access to all required annotation and documentation information.

A brief discussion of the three formats listed above follows:

.. table:: Data Formats Pros/Cons

   +--------+-------------------------+-----------------------------+
   | Format | Pros                    | Cons                        |
   +========+=========================+=============================+
   | XML    | ubiquitous, extensible, | verbose, requires loading   |
   |        | capable of containing   | into language to "query"    |
   |        | HTML, human             |                             |
   |        | inspectable, schema     |                             |
   |        | validation possible,    |                             |
   |        | straightforward to      |                             |
   |        | put under version       |                             |
   |        | control                 |                             |
   +--------+-------------------------+-----------------------------+
   | SQLite | fast query access to    | must store in version       |
   |        | the data.               | control as a "dump" text    |
   |        |                         | file which can be verbose   |
   +--------+-------------------------+-----------------------------+
   | JSON   | ubiquitous, human       | validation requires         |
   |        | inspectable; can be     | out-of-band tooling; not    |
   |        | validated via JSON      | extensible                  |
   |        | schema                  |                             |
   +--------+-------------------------+-----------------------------+

XML would be the quickest/easiest to implement and the easiest to
extend.

Additionally, we can also create/generate bona fide documentation end
formats such as HTML and PDF. Note that the Modelica Building Library
already has an HTML representation
`here <http://simulationresearch.lbl.gov/modelica/releases/latest/help/Buildings.html>`__

Diffs
"""""

In subsequent discussion with Michael Wetter, we were asked to comment
on the ability of the above formats to handle ``diffs`` against multiple
versions of the MBL. That is, if our tool is used to create a data dump
of one version of MBL, and then is run on a subsequent version, how
would one determine if there were non-trivial changes and get an exact
list of what those changes are.

Creating ``diffs`` between versions of the output formats of our tool is
definitely possible. We have experience writing code to do "intelligent"
diff comparison across two different sets of output file formats for
testing purposes. This involves loading each file into memory (partially
or all at once) and recursively comparing across the relevant parts of
the two data structures and reporting the differences out. Certain
programming languages make such a comparison trivial as they are based
on `immutable/persistent data
structures <https://en.wikipedia.org/wiki/Persistent_data_structure>`__;
others would require us to create our own library to perform the
comparison. In either case, it should be possible to, for example,
compare two different versions of the MBL for non-trivial changes. A
trivial change, would be, for example, updates to MBL's html
documentation whereas a non-trivial change might include the creation of
a new model, the renaming of a parameter, or the addition/deletion of a
parameter.

Use of SQL
""""""""""

The SQL option is included as a possible end-user file format. If the
main objective is to query what we deliver, then having a raw "SQL dump"
that can be loaded into a database may be an elegant solution -- this
could be an external database or the current database OS already uses
(assuming databases are used internally by OS). A database such as
`SQlite <https://www.sqlite.org/>`__ may be a good candidate for use on
a single computer. This option would reduce the problem from the OS
team's side to "talking to a database". It would introduce a need to
come up with a data model (i.e., table definitions), but similar work
would have to be done to determine how the XML would be laid out (i.e.,
valid tags, valid values for tags/attributes, etc.). Depending on the
proposed use cases for the information and the OpenStudio team's
current/proposed workflow/toolchain, this may or may not make sense --
we thought we would bring it up as a point of discussion.

References
""""""""""

Åkesson, Ekman, and Hedin 2008

    J. Åkesson, T. Ekman, and G. Hedin. 2008. "Implementation of a
    Modelica compiler using JastAdd attribute grammars". Science of
    Computer Programming 75 (2010) 21-38. Available at:
    http://www.sciencedirect.com/science/article/pii/S0167642309001087

JModelica User Guide

    "JModelica.org User Guide: Version 1.17". Available at:
    http://www.jmodelica.org/api-docs/usersguide/JModelicaUsersGuide-1.17.0.pdf

Franke 2014

    R. Franke. 2014. "Client-side Modelica powered by Python or
    JavaScript". Available at:
    http://www.ep.liu.se/ecp/096/115/ecp14096115.pdf

Schlegel and Finsterwalder 2011

    C. Schlegel and R. Finsterwalder. 2011. "Automatic Generation of
    Graphical User Interfaces for Simulation of Modelica Models".
    Available at: http://www.ep.liu.se/ecp/063/090/ecp11063090.pdf

Modelica Parser in OCaml

    C. Höger. 2015. "modelica\_ml". License: BSD3. Available at:
    https://opam.ocaml.org/packages/modelica\_ml/modelica\_ml.0.2.0/

Free Modelica Parser in C

    MathCore. "Free Modelica Parser". License: GPL. Available at:
    https://www.modelica.org/tools/parser/Parser.shtml

Modelica Parser in Python

    D. Xie. 2017. "modparc: Modelica Parser Documentation". License:
    GPL. Available at:
    https://modparc.readthedocs.io/en/latest/index.html and
    https://github.com/xie-dongping/modparc

Modelica Parser in Haskell

    H. Hördegen. 2014. "The modelicaparser package". License: BSD3.
    Available at: https://hackage.haskell.org/package/modelicaparser

Modelica Parser in JavaScript/Node.js

    M. Tiller. 2015. "modelica-parser". License: MIT. Available at:
    https://www.npmjs.com/package/modelica-parser

    omuses. 2014. "moijs: Modelica in JavaScript". GitHub Repository.
    License: MIT. Available at: https://github.com/omuses/moijs

JModelica Parser in Java

    JModelica. "ModelicaParser Class". License: GPL. Available at:
    http://www.jmodelica.org/api-docs/modelica\_compiler/classorg\_1\_1jmodelica\_1\_1modelica\_1\_1parser\_1\_1\_modelica\_parser.html


.. rubric:: Footnotes

.. [#fn_mbl] Our main focus is to support the Modelica Buildings Library but
             the tool should also work for other Modelica file import/parsing
             tasks
