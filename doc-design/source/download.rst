.. _sec_download:

Download
--------

Software
^^^^^^^^

.. note:: Git Large File Storage is required for loading all the required dependencies of Spawn.
  See `git-lfs installation instructions <https://github.com/git-lfs/git-lfs/wiki/Installation>`.

SOEP is still in development. The development version for Linux 64 bit and Windows 64 bit is accessible with

.. code-block:: bash

   git clone git@github.com:lbl-srg/modelica-buildings.git

This will download the development version which has been tested with OPTIMICA, JModelica and Dymola.

Either OPTIMICA, JModelica and Dymola needs to be installed.
A JModelica docker image that is used to test Spawn
is available from https://github.com/lbl-srg/docker-ubuntu-jmodelica

You can then simulate models with OPTIMICA or JModelica by running

.. code-block:: bash

   cd modelica-buildings
   jm_ipython.sh jmodelica.py Buildings.Experimental.EnergyPlus.Validation.OneZoneWithControl

The output file can be read with https://simulationresearch.lbl.gov/modelica/buildingspy/ or
Dymola.

For more information, see also the user guide in the Modelica Buildings Library at
`Buildings.Experimental.EnergyPlus.UsersGuide`.

Support for an end-user installer and for OS X, will be added later.


Publications
^^^^^^^^^^^^

| Michael Wetter, Kyle Benne, Antoine Gautier, Thierry S. Nouidui, Agnes Ramle, Amir Roth, Hubertus Tummescheit, Stuart Mentzer and Christian Winther.
| `Lifting the Garage Door on Spawn, an Open-Source BEM-Controls Engine. <downloads/2020-simBuild-spawn.pdf>`_
| Proc. of Building Performance Modeling Conference and SimBuild, p. 518--525, Chicago, IL, USA, September 2020.
