#!/bin/sh

# Path to the installation folder of JModelica
JMODELICA_INST="/home/jianjun/proj/JModelica"

# Run the script that compiles and simulate Modelica models
# See run_jmodelica.py
$JMODELICA_INST/JModelica/bin/jm_python.sh ScaleTest.py
