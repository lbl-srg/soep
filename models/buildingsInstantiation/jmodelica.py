#!/usr/bin/env python3
##########################################################################
# Script to simulate Modelica models with JModelica.
#
##########################################################################
# Import the function for compilation of models and the load_fmu method

from pymodelica import compile_fmu
import traceback
import logging

from pyfmi import load_fmu
import pymodelica

import os
import shutil
import sys
import matplotlib.pyplot as plt

import pprint

debug_solver = False
model="BuildingRooms.Building"
generate_plot = False

# Overwrite model with command line argument if specified
if len(sys.argv) > 1:
  # If the argument is a file, then parse it to a model name
  if os.path.isfile(sys.argv[1]):
    model = sys.argv[1].replace(os.path.sep, '.')[:-3]
  else:
    model=sys.argv[1]


print("*** Compiling {}".format(model))
# Increase memory
pymodelica.environ['JVM_ARGS'] = '-Xmx4096m'


sys.stdout.flush()

######################################################################
# Compile fmu
fmu_name = compile_fmu(model,
                       version="2.0",
                       compiler_log_level='warning', #'info', 'warning',
                       compiler_options = {"generate_html_diagnostics" : True,
                                           "event_output_vars": True,
                                           "nle_solver_tol_factor": 1e-2}) # 1e-2 is the default

######################################################################
# Copy style sheets.
# This is a hack to get the css and js files to render the html diagnostics.
htm_dir = os.path.splitext(os.path.basename(fmu_name))[0] + "_html_diagnostics"
if os.path.exists(htm_dir):
    for fil in ["scripts.js", "style.css", "zepto.min.js"]:
        src = os.path.join(".jmodelica_html", fil)
        if os.path.exists(src):
            des = os.path.join(htm_dir, fil)
            shutil.copyfile(src, des)

#sys.exit(0)
######################################################################
# Load model
mod = load_fmu(fmu_name, log_level=4) # default setting is 3
mod.set_max_log_size(2073741824) # = 2*1024^3 (about 2GB)
######################################################################
# Print derivatives
import re
print("Derivatives:")
for d in mod.get_derivatives_list().keys():
  print(f"       {d}")
print("")

######################################################################
# Retrieve and set solver options
x_nominal = mod.nominal_continuous_states
opts = mod.simulate_options() #Retrieve the default options

opts['solver'] = 'CVode' #'Radau5ODE' #CVode
opts['ncp'] = 500

# Set user-specified tolerance if it is smaller than the tolerance in the .mo file
rtol = 1.0e-5
x_nominal = mod.nominal_continuous_states

if len(x_nominal) > 0:
  atol = rtol*x_nominal
else:
  atol = rtol
opts[f"{opts['solver']}_options"]['rtol'] = rtol
opts[f"{opts['solver']}_options"]['atol'] = atol


if opts['solver'].lower() == 'cvode':

  opts['CVode_options']['external_event_detection'] = False
  opts['CVode_options']['maxh'] = (mod.get_default_experiment_stop_time()-mod.get_default_experiment_start_time())/float(opts['ncp'])
  opts['CVode_options']['iter'] = 'Newton'
  opts['CVode_options']['discr'] = 'BDF'
  opts['CVode_options']['store_event_points'] = True # True is default, set to false if many events

  if debug_solver:
    opts['CVode_options']['clock_step'] = True


if debug_solver:
  opts["logging"] = True #<- Turn on solver debug logging
  mod.set("_log_level", 4)

######################################################################
# Simulate
if opts['solver'].lower() != 'cvode' or abs(rtol-1E-6) > 1E-12:
  print(f"Solver is {opts['solver']}, {rtol}")

res = mod.simulate(options=opts)
#        logging.error(traceback.format_exc())

stats = res.solver.get_statistics()
print(pprint.pprint(dict(stats))) #Will list all the available statistics output (different for different solvers)


if generate_plot:
  plt.plot(res['time'], res['TDewPoi.T']-273.15)
  plt.xlabel('time in [s]')
  plt.ylabel('Dew point [degC]')
  plt.grid()
  plt.show()
  plt.savefig("plot.pdf")

######################################################################
# Get debugging information
if debug_solver:
  #Load the debug information
  from pyfmi.debug import CVodeDebugInformation
  debug = CVodeDebugInformation(model.replace(".", "_")+"_debug.txt")

  ### Below are options to plot the order, error and step-size evolution.
  ### The error methos also take a threshold and a region if you want to
  ### limit the plot to a certain interval.


  if opts['solver'].lower() == 'cvode':
    #Plot wall-clock time versus model time
    debug.plot_cumulative_time_elapsed()
    #Plot only the region 0.8 - 1.0 seconds and only state variables with an error greater than 0.01 (for any point in that region)
#    debug.plot_error(region=[0.8,1.0], threshold=0.01)


  #Plot order evolution
#  debug.plot_order()

  #Plot error evolution
#  debug.plot_error() #Note see also the arguments to the method

  #Plot the used step-size
  debug.plot_step_size()

  #See also debug?
