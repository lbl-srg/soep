.. _sec_download:

Download
--------

SOEP is still development. The development version for Linux 64 bit is accessible with

.. code-block:: bash

   git clone -b issue1129_energyPlus_zone git@github.com:lbl-srg/modelica-buildings.git

This will download the development version which has been tested with JModelica.

You will also need to install JModelica. A docker image that is used to develop SOEP
is available from https://github.com/lbl-srg/docker-ubuntu-jmodelica

You can then simulate models by running, for example,

.. code-block:: bash

   cd modelica-buildings
   jm_ipython.sh jmodelica.py Buildings.Experimental.EnergyPlus.Validation.OneZoneWithControl

The output file can be read with https://simulationresearch.lbl.gov/modelica/buildingspy/ or
Dymola.

For more information, see also the user guide in the Modelica Buildings Library at
`Buildings.Experimental.EnergyPlus.UsersGuide`.

Currently, only Linux 64 bit is available. Support for other operating systems,
as well as an end-user installer, will be added later.
