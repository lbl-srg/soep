Automated Documentation/AST Support Tool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section describes how to
generate automated SOEP documentation and abstract syntax trees from
the Modelica Buildings Library (MBL), or from other Modelica libraries that
users may use with SOEP.

The goal is to expose the `abstract
syntax tree (AST) <https://en.wikipedia.org/wiki/Abstract_syntax_tree>`_ of the
Modelica Buildings Library (MBL) [#fn_mbl]_, and make it available
to other tools via one or several json files.
These json files can then be used by OpenStudio to
discover available models and their parameters and other metadata for use
from the OpenStudio interface for SOEP.

Background
""""""""""

Modelica source code contains a lot of meta-data in addition to the
mathematical model itself. An annotation system exists within Modelica and
custom annotations can be written to pass data to tools. Annotations were
designed to be an extensible mechanism for capturing meta-data related to a
model including html-documentation, vendor-specific data, and graphical
annotations. Parameters, variables, equations, and models can contain
documentation strings and annotations. Furthermore, packages can be documented
and the display order of sub-packages, models, classes, functions, connectors
and other objects can be specified. Modelica libraries have a hierarchical
structure consisting mainly of packages which contain models and other objects
as well as sub-packages. Models themselves can be composed of multiple, possibly
replaceable, components. Much of this information will be required by the
OpenStudio tool in order to understand which component models are available,
where they reside in the library's package structure which determines their fully
qualified name, what parameters they have, how they can be configured, how to
display them, and what other meta-data are available, such as documentation
strings and type of connectors that can be connected with each other.

This section is concerned about making the AST of Modelica source files,
including the metadata mentioned above, available to OpenStudio. We
will specifically focus on the Modelica Buildings Library (MBL), but other
Modelica libraries can be used as well.

The intent of the AST representation is *primarily* to be consumed by the
OpenStudio application for identification of models, model documentation, model
connecting points, inputs/outputs, and parameters and related meta-data.

Presumably, an OpenStudio application will consume some or all of the above
information, use it to provide an interface to the user, and ultimately write
out a Modelica file which connects the various library components, configures
various components, and assigns values to parameters.

To create models, information from other libraries, most notably, the Modelica
Standard Library (MSL) itself, may need to be made available. Typical
applications and examples from the MBL use
component models from both the MSL and MBL. There is also interest in being
able to support additional third party libraries.
Therefore, it will be important that this tool is not limited to just
parsing/processing the MBL.

Requirements
""""""""""""

This section will describe the requirements of a batch-process program
that will transform any
Modelica input file or library into a json file. The json file shall contain:

- identification of which models, classes, connectors, functions, etc. exist
- identification of the relative hierarchy of the above components within the
  package structure of the library
- for each package,

  - what models are available
  - what connection "ports" are available
  - for fluid ports, which ports carry the same fluid (so that media assignments can be propagated through a circuit)
  - what control inputs/outputs are available
  - what parameters are available
  - what configuration management options exist (i.e., replaceable components
    and packages and which parameters belong to which component)
  - including meta-data and attributes for all the above such as graphics
    annotations, vendor annotations, html documentation, etc.

For integration with OpenStudio, the tool should reduce dependencies
that complicate the distribution to users.

The tool shall also have options to exclude certain packages. For example,
OpenStudio may give access to `Modelica.Blocks` but not to `Modelica.Magnetic`.

The tool shall also allow to perform a "diff" (i.e., logical
differences) between two generated json files.
The purpose of the diff tool would be to detect non-trivial
differences between two generated json files that hold the AST of a Modelica
library and report those changes. The content of the
"difference" file would explicitly show the differences between the two
input manifests. The options here would allow for tweaking the meaning of what
it means to be "different".

The following two lists attempt to list examples of changes that
cannot be ignored as well as changes that can be ignored.

*Significant Changes (backward-incompatible)*

- changes to names of any public package, model, block, function, record, as well
  as public constants, parameters, variables, connectors, or subcomponents
- addition of any public parameters that has no default value,
  variables that have no equation (in a partial model), connectors (except for output connectors),
  or subcomponents that require changes to models that extend or instantiate these components
- addition/subtraction of packages/models/blocks/functions meant to be consumed
  by OpenStudio
- removing of any public constant, parameter, or class (model, block, function, type etc.)
- moving a class between packages (i.e., changing the path)

*Changes that may be ignored (backward-compatible)*

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
functions must be compared for change detection. Documentation (html)/
documentation strings/graphics annotations will not affect the model interface
or semantics. Changes to protected properties or equations will not affect
the interface (but may affect the actual numeric output quantities).

Annotations could be used to signal status changes such as "deprecation".

The diff tool would be of use in particular when new versions of the
MBL are released and the OpenStudio team would like to check if there are
non-trivial changes they need to integrate.


Literature review
"""""""""""""""""

There have been several attempts to represent or use XML in relation to
Modelica in the past (:cite:`Landin2014`, :cite:`Fritzson2003G`,
:cite:`Pop2003`, :cite:`Pop2005`, and :cite:`Reisenbichler2006`).

In particular, N. Landin did work with Modelon using JModelica to export XML for
the purpose of model exchange :cite:`Landin2014` -- this is very similar to our use case.
Unfortunately, this work deals only with "flattened" models -- Modelica models
that have been instantiated with all of the hierarchy removed. For our use
case, the hierarchy must be preserved so that the OpenStudio team can
build a new model through instantiation of models from the MBL.
For this purpose, JModelica also provides access to the the source AST and instance AST
(see the `JModelica user guide
<http://www.jmodelica.org/api-docs/usersguide/JModelicaUsersGuide-1.17.0.pdf>`_).

The paper by Reisenbichler 2006 motivates the usage of XML in association with
Modelica without getting into specifics :cite:`Reisenbichler2006`.
The remaining work by Pop and Fritzson
is thus the only comprehensive work on an XML representation of Modelica
*source* AST that appears in the literature
(:cite:`Pop2003`, :cite:`Pop2005`, and :cite:`Fritzson2003G`).
The purpose of the XML work by Pop
and Fritzson was to create a complete XML representation of the entire Modelica
source.

ANTLR (ANother Tool for Language Recognition)
is a parser generator for reading, processing, executing, or
translating structured text or binary files.
It is widely used to build languages, tools, and frameworks.
From a grammar, ANTLR generates a parser that can build parse trees and
also generates a listener interface (or visitor) that makes it easy
to respond to the recognition of phrases of interest.
For ANTLR, a Modelica grammar is available at
https://github.com/antlr/grammars-v4/blob/master/modelica/modelica.g4.

Implementation
""""""""""""""

Work started on the implementation of a Modelica-JSON translator.
The development page is https://github.com/lbl-srg/modelica-json

For an example, consider the following model

.. code-block:: modelica

   within FromModelica;
   block BlockWithBlock1 "A block that instantiates another public and protected block"
     Block1 bloPub "A public block";
   protected
     Block1 bloPro "A protected block";
   end BlockWithBlock1;

When parse to a json representation, the output of its public declarations is as follows:

.. code-block:: javascript

    [
      {
        "modelicaFile": "./BlockWithBlock1.mo",
        "within": "FromModelica",
        "topClassName": "FromModelica.BlockWithBlock1",
        "comment": "A block that instantiates another public and protected block",
        "public": {
          "models": [
            {
              "className": "Block1",
              "name": "bloPub",
              "comment": "A public block"
            }
          ]
        },
        "protected": {
          "models": [
            {
              "className": "Block1",
              "name": "bloPro",
              "comment": "A protected block"
            }
          ]
        }
      },
      {
        "modelicaFile": "Block1.mo",
        "within": "FromModelica",
        "topClassName": "FromModelica.Block1",
        "comment": "A block that instantiates nothing"
      }
    ]


.. rubric:: Footnotes

.. [#fn_mbl] Our main focus is to support the Modelica Buildings Library but
             the tool should also work for other Modelica libraries.
