#!/usr/bin/env python
#############################################################
import os
import shutil

def sh(cmd, path):
    ''' Run the command ```cmd``` command in the directory ```path```
    '''
    import subprocess
    import sys
#    if args.verbose:
#        print("*** " + path + "> " + '%s' % ' '.join(map(str, cmd)))
    p = subprocess.Popen(cmd, cwd = path)
    p.communicate()
    if p.returncode != 0:
        print("Error: %s." % p.returncode)
        sys.exit(p.returncode)

def create_working_directory():
    ''' Create working directory
    '''
    import os
    import tempfile
    import getpass
    worDir = tempfile.mkdtemp( prefix='tmp_timeBench_' + getpass.getuser() )
#    print("Created directory {}".format(worDir))
    return worDir

def checkout_repository(BRANCH, LOCAL_BUILDINGS_LIBRARY, working_directory, from_git_hub):
    import os
    from git import Repo
    import git
    if from_git_hub:
        print("Checking out repository branch {}".format(BRANCH))
        git_url = "https://github.com/lbl-srg/modelica-buildings"
        Repo.clone_from(git_url, working_directory)
        g = git.Git(working_directory)
        g.checkout(BRANCH)
    else:
        # This is a hack to get the local copy of the repository
        des = os.path.join(working_directory, "Buildings")
        print("*** Copying Buildings library to {}".format(des))
        shutil.copytree(LOCAL_BUILDINGS_LIBRARY, des)

def _profile(setting,tool,JMODELICA_INST):
    import os
    import string
    import jinja2 as jja2
    import subprocess

    from buildingspy.simulate.Simulator import Simulator
    from buildingspy.io.outputfile import Reader

    model=setting['model']
    modelName = model.split(".")[-1]
    # ------------------- Run dymola -------------------
    if tool == "dymola":
        out_dir = os.path.join("out", modelName)
        # Update MODELICAPATH to get the right library version
        os.environ["MODELICAPATH"] = ":".join([setting['lib_dir'], out_dir])
        s=Simulator(model, "dymola", outputDirectory=out_dir)
        s.setSolver(setting['solver'])
        s.setStopTime(setting['stop_time'])
        s.setTolerance(1E-6)
        s.simulate()
        resultFile = os.path.join(out_dir, model.split(".")[-1] + ".mat")
        r=Reader(resultFile, "dymola")
        tCPU=r.max("CPUtime")
        nEve=r.max('EventCounter')
        solver=setting['solver']
        print "tCPU = {},  nEve = {},   solver = {},     {}".format(tCPU, nEve, solver, model)
        return tCPU, nEve, solver
    # ------------------- Run JModelica -------------------
    else:
        worDir = setting['lib_dir']
        # Update MODELICAPATH to get the right library version
        os.environ["MODELICAPATH"] = "/".join([JMODELICA_INST, 'JModelica/ThirdParty/MSL'])
        # truncate model path to the package containing it
        truPath = model.rsplit('.',1)[0]
        # create base class path
        modelPath = string.replace(truPath,'.','/')
        # print(worDir)
        # print(modelPath)
        Base_class = os.path.join(worDir,modelPath)
        # print(Base_class)
        # Copy .mo file from Building library to current working folder
        shutil.copy2(Base_class +'/'+ modelName + '.mo', worDir+'/'+modelName + '.mo')
        # create file to log output during compile process
        logFile = 'd:' + worDir + '/comLog.txt'

        loader = jja2.FileSystemLoader('SimulatorTemplate_JModelica.py')
        env = jja2.Environment(loader=loader)
        template = env.get_template('')
        # render the JModelica simulator file
        runJMOut = template.render(model_name=modelName,
                                   fmi_version=2.0,
                                   sim_lib_path=worDir,
                                   base_class=worDir+'/Buildings',
                                   log_file=logFile,
                                   end_time=setting['stop_time'])
        runJM_file = "runJM.py"
        with open(runJM_file,'w') as rf:
            rf.write(str(runJMOut))
        shutil.copy2(runJM_file, worDir+'/'+'runJM.py')
        curWorDir=os.getcwd()
        # change working directory
        os.chdir(worDir)
        # create command line to implement the runJM.py
        command = JMODELICA_INST + '/JModelica/bin/jm_python.sh'
        simFile = open('simLog.txt','w')
        # implement JModelica simulation
        logSim = subprocess.check_output([command, runJM_file])
        # write out simulation information typically showing on console to simFile
        simFile.write(logSim)
        simFile.close()
        # retrieve the compile and simulation time
        compileTime, totSimTim, numStaEve, numTimEve, solTyp  = search_Time('comLog.txt', 'simLog.txt')
        # change back to current work directory
        os.chdir(curWorDir)
        # total compile time
        totComTim = compileTime[0]
        # compile time break:
        # flatten model time
        flaModTim = compileTime[3]
        # instantiate model time
        insModTim = compileTime[2]
        # compilte C code time
        comCTim = compileTime[52]
        # generate code time
        genCodTim = compileTime[51]
        print "comTim={}, simTim={}, flaTim={}, insTim={}, comCTim={}, genCodTim={}". \
              format(totComTim, totSimTim, flaModTim, insModTim, comCTim, genCodTim)
        return totComTim, totSimTim, \
               flaModTim, insModTim, comCTim, genCodTim, \
               numStaEve, numTimEve, solTyp

# Retrieve compile and simulation time from log files when running JModelica
def search_Time(Compilelog_file, Simlog_file):
    import numpy as N

    compileTime = N.zeros(54)
    search_str1 = "Total                                    :"
    search_str2 = "parseModel()                            :"
    search_str3 = "instantiateModel()                      :"
    search_str4 = "flattenModel()                          :"
    search_str5 = "flatten()                              :"
    search_str6 = "flattenInstClassDecl()                :"
    search_str7 = "buildConnectionSets()                :"
    search_str8 = "flattenComponents()                  :"
    search_str9 = "updateVariabilityForVariablesInWhen():"
    search_str10 = "genConnectionEquations()             :"
    search_str11 = "prettyPrintRawFlat()                   :"
    search_str12 = "transformCanonical()                   :"
    search_str13 = "enableIfEquationElimination           :"
    search_str14 = "genInitArrayStatements                :"
    search_str15 = "scalarize                             :"
    search_str16 = "MakeReinitedVarsStates                :"
    search_str17 = "enableIfEquationElimination           :"
    search_str18 = "enableStreamsRewrite                  :"
    search_str19 = "extractEventGeneratingExps            :"
    search_str20 = "transformAlgorithms                   :"
    search_str21 = "convertWhenToIf                       :"
    search_str22 = "FunctionInliningIfSet                 :"
    search_str23 = "setFDerivativeVariables               :"
    search_str24 = "addFPreVariables                      :"
    search_str25 = "enableIfEquationRewrite               :"
    search_str26 = "aliasEliminationIfSet                 :"
    search_str27 = "variabilityPropagationIfSet           :"
    search_str28 = "aliasEliminationIfSet                 :"
    search_str29 = "eliminateLinearEquations              :"
    search_str30 = "aliasEliminationIfSet                 :"
    search_str31 = "enableExpandedInStreamRewrite         :"
    search_str32 = "evaluateAsserts                       :"
    search_str33 = "enableSemiLinearRewrite               :"
    search_str34 = "eliminateEqualSwitches                :"
    search_str35 = "genInitialEquations                   :"
    search_str36 = "setFDerivativeVariablesPreBLT         :"
    search_str37 = "indexReduction                        :"
    search_str38 = "Munkres                              :"
    search_str39 = "aliasEliminationIfSet                :"
    search_str40 = "setFDerivativeVariables              :"
    search_str41 = "LateFunctionInliningIfSet             :"
    search_str42 = "commonSubexpressionEliminationIfSet   :"
    search_str43 = "addFPreVariables                      :"
    search_str44 = "aliasEliminationIfSet                 :"
    search_str45 = "sortDependentParameters               :"
    search_str46 = "addRuntimeOptionParameters            :"
    search_str47 = "computeMatchingsAndBLT                :"
    search_str48 = "computeBLT()                         :"
    search_str49 = "computeBLT()                         :"
    search_str50 = "removeUnusedFunctionsAndRecords()     :"
    search_str51 = "prettyPrintFlat()                      :"
    search_str52 = "generateCode()                          :"
    search_str53 = "compileCCode()                          :"
    search_str54 = "packUnit()                              :"

    simSearch_str = "Elapsed simulation time:"
    numStaEve_str = "Number of state events                          :"
    numTimEve_str = "Number of time events                           :"
    solTyp_str = "Solver                   :"

    with open(Compilelog_file, "r") as f:
        for line in f:
            if search_str1 in line:
		# Major time-cost that should be investigated
                Total = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[0] = value2[0]
            if search_str2 in line:
		# Major time-cost that should be investigated
                parseModel = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[1] = value2[0]
            if search_str3 in line:
		# Major time-cost that should be investigated
                instantiateModel = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[2] = value2[0]
            if search_str4 in line:
		# Major time-cost that should be investigated
                flattenModel = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[3] = value2[0]
            if search_str5 in line:
		# Major time-cost that should be investigated
                flatten = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[4] = value2[0]
            if search_str6 in line:
                flattenInstClassDecl = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[5] = value2[0]
            if search_str7 in line:
                buildConnectionSets = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[6] = value2[0]
            if search_str8 in line:
                flattenComponents = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[7] = value2[0]
            if search_str9 in line:
                updateVariabilityForVariablesInWhen = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[8] = value2[0]
            if search_str10 in line:
                genConnectionEquations = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[9] = value2[0]
            if search_str11 in line:
		# Major time-cost that should be investigated
                prettyPrintRawFlat = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[10] = value2[0]
            if search_str12 in line:
		# Major time-cost that should be investigated
                transformCanonical = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[11] = value2[0]
            if search_str13 in line:
                enableIfEquationElimination = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[12] = value2[0]
            if search_str14 in line:
                genInitArrayStatements = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[13] = value2[0]
            if search_str15 in line:
                scalarize = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[14] = value2[0]
            if search_str16 in line:
                MakeReinitedVarsStates = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[15] = value2[0]
            if search_str17 in line:
                enableIfEquationElimination = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[16] = value2[0]
            if search_str18 in line:
                enableStreamsRewrite = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[17] = value2[0]
            if search_str19 in line:
                extractEventGeneratingExps = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[18] = value2[0]
            if search_str20 in line:
                transformAlgorithms = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[19] = value2[0]
            if search_str21 in line:
                convertWhenToIf = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[20] = value2[0]
            if search_str22 in line:
                FunctionInliningIfSet = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[21] = value2[0]
            if search_str23 in line:
                setFDerivativeVariables = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[22] = value2[0]
            if search_str24 in line:
                addFPreVariables = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[23] = value2[0]
            if search_str25 in line:
                enableIfEquationRewrite = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[24] = value2[0]
            if search_str26 in line:
                aliasEliminationIfSet = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[25] = value2[0]
            if search_str27 in line:
                variabilityPropagationIfSet = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[26] = value2[0]
            if search_str28 in line:
                aliasEliminationIfSet = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[27] = value2[0]
            if search_str29 in line:
                eliminateLinearEquations = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[28] = value2[0]
            if search_str30 in line:
                aliasEliminationIfSet = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[29] = value2[0]
            if search_str31 in line:
                enableExpandedInStreamRewrite = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[30] = value2[0]
            if search_str32 in line:
                evaluateAsserts = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[31] = value2[0]
            if search_str33 in line:
                enableSemiLinearRewrite = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[32] = value2[0]
            if search_str34 in line:
                eliminateEqualSwitches = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[33] = value2[0]
            if search_str35 in line:
                genInitialEquations = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[34] = value2[0]
            if search_str36 in line:
                setFDerivativeVariablesPreBLT = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[35] = value2[0]
            if search_str37 in line:
                indexReduction = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[36] = value2[0]
            if search_str38 in line:
                Munkres = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[37] = value2[0]
            if search_str39 in line:
                aliasEliminationIfSet = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[38] = value2[0]
            if search_str40 in line:
                setFDerivativeVariables = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[39] = value2[0]
            if search_str41 in line:
                LateFunctionInliningIfSet = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[40] = value2[0]
            if search_str42 in line:
                commonSubexpressionEliminationIfSet = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[41] = value2[0]
            if search_str43 in line:
                addFPreVariables = line
                value1 = line.split(":")
		value2 = value1[1].split("s,")
		compileTime[42] = value2[0]
            if search_str44 in line:
                aliasEliminationIfSet = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[43] = value2[0]
            if search_str45 in line:
                sortDependentParameters = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[44] = value2[0]
            if search_str46 in line:
                addRuntimeOptionParameters = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[45] = value2[0]
            if search_str47 in line:
                computeMatchingsAndBLT = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[46] = value2[0]
            if search_str48 in line:
                computeBLT = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[47] = value2[0]
            if search_str49 in line:
                computeBLT = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[48] = value2[0]
            if search_str50 in line:
                removeUnusedFunctionsAndRecords = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[49] = value2[0]
            if search_str51 in line:
		# Major time-cost that should be investigated
                prettyPrintFlat = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[50] = value2[0]
            if search_str52 in line:
                # Major time-cost that should be investigated
                generateCode = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[51] = value2[0]
            if search_str53 in line:
                # Major time-cost that should be investigated
                compileCCode = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[52] = value2[0]
            if search_str54 in line:
                # Major time-cost that should be investigated
                packUnit = line
                value1 = line.split(":")
        	value2 = value1[1].split("s,")
        	compileTime[53] = value2[0]
	f.close()
    with open(Simlog_file, "r") as sf:
        for line in sf:
            if simSearch_str in line:
		value1 = line.split(":")
		value2 = value1[1].split("seconds")
		simTime = value2[0]
            if numStaEve_str in line:
                value = line.split(":")
		numStaEve = value[1]
            if numTimEve_str in line:
                value = line.split(":")
		numTimEve = value[1]
            if solTyp_str in line:
                value = line.split(":")
		solTyp = value[1]
	sf.close()
    return compileTime, simTime, numStaEve, numTimEve, solTyp


if __name__=='__main__':
    import caseSettings

    settings, BRANCH, COMMIT, FROM_GIT_HUB, LOCAL_BUILDINGS_LIBRARY, JMODELICA_INST = caseSettings.get_settings()
    lib_dir = create_working_directory()
    checkout_repository(BRANCH, LOCAL_BUILDINGS_LIBRARY, lib_dir, FROM_GIT_HUB)

    print(lib_dir)
    # Open files for logging implementation times
    if os.path.exists('TimeLog.json'):
	    os.remove('TimeLog.json')
    else:
	    print("%s is not exist. A new file will be created.\r\n" % 'TimeLog.json')

    # create and open an empty JSON file
    logFile = open('TimeLog.json', 'a')
    logFile.write("{ \r\n")
    logFile.write('     "title": "TimeLog", \r\n')
    logFile.write('     "case list": { \r\n')
    logFile.close()
    # get list size
    listLen = len(settings)

    tools = ["dymola", "JModelica"]
    for tool in tools:
        if tool == "dymola":
            logFile = open('TimeLog.json', 'a')
            logFile.write('         "dymola": { \r\n')

            for index, setting in enumerate(settings):
                setting['lib_dir'] = lib_dir
                model=setting['model']
                modelName=model.split(".")[-1]
                tCPU, nEve, solver \
                    =_profile(setting,tool,JMODELICA_INST)
                # write outputs to JSON file
                logFile.write('                     "'+ modelName + '": { \r\n')
                logFile.write('                             "tCPU":' + str(tCPU) + ', \r\n')
                logFile.write('                             "nEve":' + str(nEve) + ', \r\n')
                logFile.write('                             "solver":"' + solver + '"\r\n')
                if index < (listLen-1):
                    logFile.write('                                             }, \r\n')
                else:
                    logFile.write('                                             } \r\n')
            if len(tools) > 1:
                logFile.write('                    }, \r\n')
            else:
                logFile.write('                    } \r\n')
            logFile.close()
        else:
            logFile = open('TimeLog.json', 'a')
            logFile.write('         "JModelica": { \r\n')
            for index, setting in enumerate(settings):
                setting['lib_dir'] = lib_dir
                model=setting['model']
                modelName=model.split(".")[-1]
                totComTim, totSimTim, flaModTim, insModTim, comCTim, \
                genCodTim, numStaEve, numTimEve, solTyp \
                    = _profile(setting,tool,JMODELICA_INST)
                # write outputs to JSON file
                logFile.write('         "'+ modelName + '" : { \r\n')
                logFile.write('                 "tComTim":' + str(totComTim) + ', \r\n')
                logFile.write('                 "tSimTim":' + str(totSimTim) + ', \r\n')
                logFile.write('                 "tFlaTim":' + str(flaModTim) + ', \r\n')
                logFile.write('                 "tInsTim":' + str(insModTim) + ', \r\n')
                logFile.write('                 "tComCTim":' + str(comCTim) + ', \r\n')
                logFile.write('                 "tGenCodTim":' + str(genCodTim) + ', \r\n')
                logFile.write('                 "nStaEve":' + str(numStaEve) + ', \r\n')
                logFile.write('                 "nTimEve":' + str(numTimEve) + ', \r\n')
                logFile.write('                 "solver":"' + solTyp + '"\r\n')
                if index < (listLen-1):
                    logFile.write('                                     }, \r\n')
                else:
                    logFile.write('                                     } \r\n')
            logFile.write('                    } \r\n')
            logFile.close()

    logFile = open('TimeLog.json', 'a')
    logFile.write("     } \r\n")
    logFile.write("} \r\n")
    logFile.close()
