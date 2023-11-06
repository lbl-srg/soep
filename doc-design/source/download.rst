.. _sec_download:

Download
--------

Software
^^^^^^^^

Official releases
.................

To download SOEP, go to https://simulationresearch.lbl.gov/modelica/download.html.

OpenModelica users can also install the Modelica Buildings Library using the OMEdit
package manager.

Either approach installs all required binaries.

Development version
...................

The development version for Linux 64 bit and Windows 64 can be downloaded from github.

To download all required dependencies, Git Large File Storage is required.
See `git-lfs installation instructions <https://github.com/git-lfs/git-lfs/wiki/Installation>`_.

If Git Large File System is installed, Spawn can be downloaded as

.. code-block:: bash

   git clone git@github.com:lbl-srg/modelica-buildings.git

This will download the development version which has been tested with OpenModelica, OPTIMICA and Dymola.

Either OpenModelica, OPTIMICA or Dymola needs to be installed.

You can then simulate models with OPTIMICA by running

.. code-block:: bash

   cd modelica-buildings
   jm_ipython.sh jmodelica.py Buildings.ThermalZones.EnergyPlus.Examples.SingleFamilyHouse.AirHeating

The output file can be read with https://simulationresearch.lbl.gov/modelica/buildingspy/ or
Dymola.

For more information, see also the user guide in the Modelica Buildings Library at
`Buildings.ThermalZones.EnergyPlus_9_6_0 <https://simulationresearch.lbl.gov/modelica/releases/v10.0.0/help/Buildings_ThermalZones_EnergyPlus_9_6_0_UsersGuide.html>`_.


Publications
^^^^^^^^^^^^

| Michael Wetter, Kyle Benne, Hubertus Tummescheit and Christian Winther.
| `Spawn: coupling Modelica Buildings Library and EnergyPlus to enable new energy system and control applications. <https://doi.org/10.1080/19401493.2023.2266414>`_
| Journal of Building Performance Simulation. Pages 1-19. 2023.

| Michael Wetter, Kyle Benne, Antoine Gautier, Thierry S. Nouidui, Agnes Ramle, Amir Roth, Hubertus Tummescheit, Stuart Mentzer and Christian Winther.
| `Lifting the Garage Door on Spawn, an Open-Source BEM-Controls Engine. <downloads/2020-simBuild-spawn.pdf>`_
| Proc. of Building Performance Modeling Conference and SimBuild, p. 518--525, Chicago, IL, USA, September 2020.
