Automated Documentation/AST Support Tool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section describes an agreed-upon workflow, toolchain and process to
generate automated SOEP "documentation" and abstract syntax trees.

The goal of this project is to make the abstract syntax tree (AST) of the
Modelica Buildings Library (MBL) [#fn_mbl]_ available to other tools, most notably,
the OpenStudio team. Notably, the AST shall contain both the HTML documentation
for the models, functions, and packages contained within. We shall also further
process the output to HTML format for human inspection (per the wording of our
contract).

The AST output format shall be used to understand what models exist within the
MBL, what their parameters are, what replaceable components exist, as well as
the meta-data related to the given components such as help strings, min/max
limits, units, annotations, etc.

Background
""""""""""

The wording for the contract this work falls under states:

    The Subcontractor shall collaborate with the SOEP development team
    at LBNL, under the NREL Technical Monitor’s oversight, and be
    responsible for the design and creation of an automated SOEP
    documentation generation system from the Modelica Buildings Library
    (MBL) source. This task may leverage and build off of the JModelica
    Abstract Syntax Tree (AST) corresponding to the MBL source files if
    expedient. The Subcontractor shall define, implement and document
    the workflow, toolchain and process to generate automated
    documentation for the SOEP software program. End formats for the
    documents being generated shall be PDF, HTML, or both. The work
    shall build on the knowledge gained under Task 4.1.3.2, and leverage
    access to the embedded HTML documentation capability within the
    Modelica Building Library and SOEP models.

However, from initial discussion with Michael Wetter (LBNL) on this task, we've
identified that our main value-added contribution will be to make the AST of
the modelica source files (specifically, the Modelica Buildings Library)
available to the OpenStudio team. Notably, the AST contains all of the
model-specific documentation but also contains key information such as
parameter names and metadata, model names and location in the package
hierarchy, and annotations.

    The main effort will be in parsing the AST of the Modelica Buildings
    Library source to make available documentation and annotations,
    possibly transforming that information, and making the information
    available to the OpenStudio project in a usable form.


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
