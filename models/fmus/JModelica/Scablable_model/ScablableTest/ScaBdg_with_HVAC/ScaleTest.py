import os

import numpy as N
import pylab as p
import pymodelica

# Import the function for compilation of models and the load_fmu method
from pymodelica import compile_fmu
from pyfmi import load_fmu
from datetime import datetime

#========================================================
#==== Clone Building Library (scalable model branch) ====
def setup_lib():
    from git import Repo
    import os
    import shutil
    if not os.path.exists(os.path.join(os.getcwd(),"tmp")):
        clo_dir = os.path.join(os.getcwd(), "tmp")
        Repo.clone_from("https://github.com/lbl-srg/modelica-buildings.git", \
                            clo_dir, branch = "issue637_scalable_models", depth=1)

#========================================================
def translate_simulate(BUILDINGS_LIB,Base_class,ClassName,curZonNum):

    timeLog=[]
    # Compile model
    tstart_tr = datetime.now()
    logFile = 'd:CompileLog/Compilelog_' + str(curZonNum) + '.txt'
    fmu_name = compile_fmu(ClassName,"MultizoneWithVAV.mo", version=2.0, compiler_options={'extra_lib_dirs':[BUILDINGS_LIB, Base_class]},compiler_log_level = logFile)
    tend_tr = datetime.now()
    timeLog.append((tend_tr-tstart_tr).total_seconds())

    # Load model
    Scale_test = load_fmu(fmu_name)

    # Simulate model
    tstart = datetime.now()
    res = Scale_test.simulate(final_time=604800.0)
    tend = datetime.now()
    timeLog.append((tend-tstart).total_seconds())

    return timeLog[0],timeLog[1]

#========================================================
def genPlot(with_plots,TimeLog):
    if with_plots:
	MaxZon = len(TimeLog)
	fig, ax1 = p.subplots()
	ax1.plot(TimeLog[:,0],TimeLog[:,1],'b-',label='Translation time')
	ax1.set_xlabel('Number of zones')
	ax1.set_ylabel('Translation time (S)',color='b')
	ax1.set_ylim(0,5000)
	ax1.set_xlim(1,MaxZon)
	ax1.grid(True)
	ax1.tick_params('y',colors='b')

	ax2 = ax1.twinx()
	ax2.plot(TimeLog[:,0],TimeLog[:,2],'r-',label='Simulation time')
	ax2.set_ylabel('Simulation time (S)',color='r')
	ax2.set_ylim(0,500)
	ax2.set_xlim(1,MaxZon)
	ax2.tick_params('y',colors='r')

	ax1.legend(loc=2)
	ax2.legend(loc=1)

	fig.tight_layout()
	p.savefig("TimeTest_Max"+str(MaxZon)+"Zone.png")
	# p.show()

#========================================================
if __name__=="__main__":
    import pymodelica
    import shutil
    import gc

    # Control JVM heap memory size
    # pymodelica.environ['JVM_ARGS'] = '-Xmx7168m'
    pymodelica.environ['JVM_ARGS'] = '-Xmx7200m'

    # Clone Building Library (scalable model branch)
    setup_lib()

    # Prepare building library and base class
    BUILDINGS_LIB = os.getcwd() + "/tmp"
    Base_class = os.path.join(os.getcwd(), "tmp/Buildings/Experimental/ScalableModels/") + "ScalableDemo"

    # Copy .mo file from Building library to current working folder
    shutil.copy2(os.path.join(os.getcwd(), "tmp/Buildings/Experimental/ScalableModels/") + "ScalableDemo/MultizoneWithVAV.mo","MultizoneWithVAV.mo")

    # Specify maximum number of zones
    ZonNum = 2

    # Open files for logging implementation times
    if os.path.exists('TimeLog.txt'):
	os.remove('TimeLog.txt')
    else:
	print("%s is not exist. A new file will be created.\r\n" % 'TimeLog.txt')
    file_Time = open('TimeLog.txt','a')
    file_Time.write("Number_of_zones  Translation_time  Simulation_time \r\n")
    file_Time.close()

    TimeLog=N.empty([ZonNum,3])
    for i in range(ZonNum):
    # for i in [ZonNum]:
	print "====== Compiling/Simulating model: "+str((i+1)*1) + "-zones ======"
	curZonNum = i+1

	# Prepare class name with the update of total number of zones
	ClassName = "Buildings.Experimental.ScalableModels.ScalableDemo.MultizoneWithVAV(nZon="+str((i+1)*1)+")"

	# ******* Compilation/Simulation, record the time *******
	TrTime, SimTime = translate_simulate(BUILDINGS_LIB,Base_class,ClassName,curZonNum)
	# ******* ******* ******* ******* ******* ******* *******

	# Log translation and simulation time
	file_Time = open('TimeLog.txt','a')
	file_Time.write(str((i+1)*1)+ "  "+str(TrTime)+"  " +str(SimTime)+"\r\n")
	file_Time.close()

        TimeLog[i,0] = i+1
	TimeLog[i,1] = TrTime
	TimeLog[i,2] = SimTime
	print "==================================================================== \r\n"
    # Delete the "tmp" repository file
    shutil.rmtree("tmp")

    with_plots = True
    genPlot(with_plots,TimeLog)
#========================================================
