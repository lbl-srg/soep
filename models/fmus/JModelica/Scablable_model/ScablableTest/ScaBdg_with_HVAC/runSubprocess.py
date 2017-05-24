import subprocess

simFile = open('simLog.txt','w')
logSim = subprocess.check_output(['sh','./runCases.sh'])
simFile.write(logSim)
simFile.close()
