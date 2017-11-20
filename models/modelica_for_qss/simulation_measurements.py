# This script compares simulated values against measured values.
# In the current set-up, the Modelica model represents the real building.
import os

import pandas as pd
import numpy as np

import matplotlib.pyplot as plt
import matplotlib

# Optionally, change fonts to use LaTeX fonts
#from matplotlib import rc
#rc('text', usetex=True)
#rc('font', family='serif')
# Nomenclature
# Define the name of the measured  variable
# measurements.1 : Temperature of air east zone
# measurements.17 : Temperature of air west zone
# measurements.24 : Total HVAC heating power of central HVAC
# measurements.25 : Total HVAC cooling power of central HVAC
# results.32: Optimal set point temperature in east zone
# results.41: Optimal set point temperature in west zone
# results.46: Optimal window control in west zone
# results.37: Optimal window control in east zone
# results.51: Minimal optimal temperature in east zone 
# results.52: Maximum optimal temperature in east zone  
# results.53: Minimal optimal temperature in west zone 
# results.54: Maximal optimal temperature in west zone 
# measurements.3: TSupAir in east zone
# measurements.4: m_flow in the east zone
# measurements.47: pRea in the east zone
# measurements.18: TSupAir in the west zone
# measurements.21: m_flow in the west zone
# measurements.48: pRea in the west zone
# Construct url to request data point value.
# Simulated values
###############################################################
import matplotlib.ticker as plticker

t_ref=19008000

# TRoom air in the east zone
sim_name = 'dymola.csv' 
sim_fil_name = os.path.join(sim_name)
df = pd.read_csv(sim_fil_name)
dym_tim = df['Time']
dym_value=df['vol.T'] 


# TRoom air in the east zone
sim_name = 'TRooK.f.out' 
sim_fil_name = os.path.join(sim_name)
df = pd.read_csv(sim_fil_name, delimiter="\t")
qss_tim = df.iloc[:,0]
qss_value=df.iloc[:,1] 



###############################################################
# Plots
fig = plt.figure()
ax = fig.add_subplot(111)

#loc = plticker.MultipleLocator(base=1.0)
#ax.xaxis.set_major_locator(loc)

ax.plot(dym_tim, dym_value, label='Dymola')
ax.plot(qss_tim, qss_value, label='QSS')
ax.set_xlabel('time [s]')
ax.set_ylabel('Room Air Temperature[C]')
ax.legend(loc='upper left')
ax.grid(True)

# Save figure to file
plt.savefig('plotRooTem.pdf')
plt.savefig('plotRooTem.png')


#plt.show()

