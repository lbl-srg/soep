#!/usr/bin/env python
#############################################################
import os
import shutil
import subprocess

def sh(cmd, path):
    ''' Run the command ```cmd``` command in the directory ```path```
    '''
    import sys
    p = subprocess.Popen(cmd, cwd = path)
    p.communicate()
    if p.returncode != 0:
        print("Error: {}.".format(p.returncode))
        sys.exit(p.returncode)

def create_working_directory():
    ''' Create working directory
    '''
    import tempfile
    import getpass
    worDir = tempfile.mkdtemp( prefix='tmp_timeBench_' + getpass.getuser() )
    return worDir

def checkout_repository(runSettings, working_directory):
    from git import Repo
    import git

    BRANCH = runSettings['BRANCH']
    LOCAL_BUILDINGS_LIBRARY = runSettings['LOCAL_BUILDINGS_LIBRARY']
    from_git_hub = runSettings['FROM_GIT_HUB']
    commit = runSettings['COMMIT']

    if from_git_hub:
        print("Checking out repository branch {}".format(BRANCH))
        git_url = "https://github.com/lbl-srg/modelica-buildings"
        Repo.clone_from(git_url, working_directory)
        g = git.Git(working_directory)
        g.checkout(BRANCH)
        g.checkout(commit)
    else:
        # This is a hack to get the local copy of the repository
        des = os.path.join(working_directory, "Buildings")
        print("*** Copying Buildings library to {}".format(des))
        shutil.copytree(LOCAL_BUILDINGS_LIBRARY, des)

def _profile(setting,tool,JMODELICA_INST,runSpace):
    ''' Run simulation with both dymola and JModelica. The function returns
        CPU time used for compile and simulation.
    '''
    import string
    import jinja2 as jja2
    from datetime import datetime

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
        tstart_tr = datetime.now()
        s.translate()
        tend_tr = datetime.now()
        # tranlation time
        tTraTim = (tend_tr-tstart_tr).total_seconds()
        s.simulate_translated()
        s.deleteTranslateDirectory()
        resultFile = os.path.join(out_dir, model.split(".")[-1] + ".mat")
        r=Reader(resultFile, "dymola")
        tCPU=r.max("CPUtime")
        nEve=r.max('EventCounter')
        solver=setting['solver']
        print "tTraTim = {}, tCPU = {}, nEve = {}, solver = {},  {}"\
            .format(tTraTim, tCPU, nEve, solver, model)
        shutil.rmtree("out")
        return tTraTim, tCPU, nEve, solver
    # ------------------- Run JModelica -------------------
    else:
        worDir = setting['lib_dir']
        # Update MODELICAPATH to get the right library version
        os.environ["MODELICAPATH"] = os.path.join(JMODELICA_INST, 'JModelica/ThirdParty/MSL')
        # truncate model path to the package containing it
        truPath = model.rsplit('.',1)[0]
        # create base class path
        modelPath = string.replace(truPath,'.','/')
        Base_class = os.path.join(worDir,modelPath)
        # Copy .mo file from Building library to current working folder
        shutil.copy2(os.path.join(Base_class, modelName + '.mo'), os.path.join(worDir, modelName + '.mo'))
        # create file to log output during compile process
        logFile = 'd:' + worDir + '/comLog.txt'
        # create heap space input
        heapSpace = '-Xmx' + runSpace

        loader = jja2.FileSystemLoader('SimulatorTemplate_JModelica.py')
        env = jja2.Environment(loader=loader)
        template = env.get_template('')
        # render the JModelica simulator file
        runJMOut = template.render(heap_space=heapSpace,
                                   model=model,
                                   model_name=modelName,
                                   fmi_version=2.0,
                                   sim_lib_path=worDir,
                                   log_file=logFile,
                                   end_time=setting['stop_time'])
        runJM_file = "runJM.py"
        with open(runJM_file,'w') as rf:
            rf.write(str(runJMOut))
        # move rendered simulator script to working directory
        shutil.move(runJM_file, os.path.join(worDir,'runJM.py'))
        curWorDir=os.getcwd()
        # change working directory
        os.chdir(worDir)
        # create command line to implement the rendered runJM.py
        command = JMODELICA_INST + '/JModelica/bin/jm_python.sh'

        # ------ implement JModelica simulation ------
        simFile = open('simLog.txt','w')
        logSim = subprocess.check_output([command, runJM_file])
        os.remove(runJM_file)
        # write out simulation information typically showing on console to "simFile"
        simFile.write(logSim)
        simFile.close()
        # --------------------------------------------

        # retrieve the compile and simulation time
        compileTime, totSimTim, numStaEve, numTimEve, solTyp  = search_Time('comLog.txt', 'simLog.txt')
        # change back to current work directory containing this .py file
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
        # other compile time
        otherComTim = totComTim - (flaModTim + insModTim + comCTim + genCodTim)
        print "comTim={}, simTim={}, flaTim={}, insTim={}, comCTim={}, genCodTim={}". \
              format(totComTim, totSimTim, flaModTim, insModTim, comCTim, genCodTim)
        return totComTim, totSimTim, \
               flaModTim, insModTim, comCTim, genCodTim, otherComTim,\
               numStaEve, numTimEve, solTyp

# Retrieve compile and simulation time from log files when running JModelica
def search_Time(Compilelog_file, Simlog_file):
    ''' This function searchs and returns compile times from the log files.
    '''
    import numpy as N

    compileTime = N.zeros(54)
    searchComp = list()
    searchComp.append("Total                                    :")
    searchComp.append("parseModel()                            :")
    searchComp.append("instantiateModel()                      :")
    searchComp.append("flattenModel()                          :")
    searchComp.append("flatten()                              :")
    searchComp.append("flattenInstClassDecl()                :")
    searchComp.append("buildConnectionSets()                :")
    searchComp.append("flattenComponents()                  :")
    searchComp.append("updateVariabilityForVariablesInWhen():")
    searchComp.append("genConnectionEquations()             :")
    searchComp.append("prettyPrintRawFlat()                   :")
    searchComp.append("transformCanonical()                   :")
    searchComp.append("enableIfEquationElimination           :")
    searchComp.append("genInitArrayStatements                :")
    searchComp.append("scalarize                             :")
    searchComp.append("MakeReinitedVarsStates                :")
    searchComp.append("enableIfEquationElimination           :")
    searchComp.append("enableStreamsRewrite                  :")
    searchComp.append("extractEventGeneratingExps            :")
    searchComp.append("transformAlgorithms                   :")
    searchComp.append("convertWhenToIf                       :")
    searchComp.append("FunctionInliningIfSet                 :")
    searchComp.append("setFDerivativeVariables               :")
    searchComp.append("addFPreVariables                      :")
    searchComp.append("enableIfEquationRewrite               :")
    searchComp.append("aliasEliminationIfSet                 :")
    searchComp.append("variabilityPropagationIfSet           :")
    searchComp.append("aliasEliminationIfSet                 :")
    searchComp.append("eliminateLinearEquations              :")
    searchComp.append("aliasEliminationIfSet                 :")
    searchComp.append("enableExpandedInStreamRewrite         :")
    searchComp.append("evaluateAsserts                       :")
    searchComp.append("enableSemiLinearRewrite               :")
    searchComp.append("eliminateEqualSwitches                :")
    searchComp.append("genInitialEquations                   :")
    searchComp.append("setFDerivativeVariablesPreBLT         :")
    searchComp.append("indexReduction                        :")
    searchComp.append("Munkres                              :")
    searchComp.append("aliasEliminationIfSet                :")
    searchComp.append("setFDerivativeVariables              :")
    searchComp.append("LateFunctionInliningIfSet             :")
    searchComp.append("commonSubexpressionEliminationIfSet   :")
    searchComp.append("addFPreVariables                      :")
    searchComp.append("aliasEliminationIfSet                 :")
    searchComp.append("sortDependentParameters               :")
    searchComp.append("addRuntimeOptionParameters            :")
    searchComp.append("computeMatchingsAndBLT                :")
    searchComp.append("computeBLT()                         :")
    searchComp.append("computeBLT()                         :")
    searchComp.append("removeUnusedFunctionsAndRecords()     :")
    searchComp.append("prettyPrintFlat()                      :")
    searchComp.append("generateCode()                          :")
    searchComp.append("compileCCode()                          :")
    # searchComp[53]
    searchComp.append("packUnit()                              :")

    simSearch_str = "Elapsed simulation time: "
    numStaEve_str = "Number of state events"
    numTimEve_str = "Number of time events"
    solTyp_str = "Solver                   : "

    # ------ search and retrieve times from compile log file ------
    with open(Compilelog_file, "r") as f:
        for line in f:
            for index, strLin in enumerate(searchComp):
                if strLin in line:
                    sect1 = line.split(":")
                    sect2 = sect1[1].split("s,")
                    compileTime[index] = sect2[0]
	f.close()
    # ------ search and retrieve times from simulation log file ------
    numStaEve = 0
    numTimEve = 0
    with open(Simlog_file, "r") as sf:
        for line in sf:
            if simSearch_str in line:
                sect1 = line.split(": ")
                sect2 = sect1[1].split(" seconds")
                simTime = sect2[0]
            if numStaEve_str in line:
                sect1 = line.split(": ")
                sect2 = sect1[1].split("\n")
                numStaEve = sect2[0]
            if numTimEve_str in line:
                sect1 = line.split(": ")
                sect2 = sect1[1].split("\n")
                numTimEve = sect2[0]
            if solTyp_str in line:
                sect1 = line.split(": ")
                sect2 = sect1[1].split("\n")
                solTyp = sect2[0]
	sf.close()
    return compileTime, simTime, numStaEve, numTimEve, solTyp

def genPlots(resultsFile, genPlot):
    import json
    import matplotlib.pyplot as plt
    import numpy as np

    if genPlot:
        with open(resultsFile) as json_file:
            results = json.load(json_file)
        if 'dymola' in results['case_list']:
            length = len(results['case_list']['dymola'])
        else:
            length = len(results['case_list']['JModelica'])
        dy_tCPU = np.empty(length)
        dy_tTraTim = np.empty(length)
        dy_nEve = np.empty(length)
        jm_tComTim = np.empty(length)
        jm_tSimTim = np.empty(length)
        jm_tFlaTim = np.empty(length)
        jm_tInsTim = np.empty(length)
        jm_tComCTim = np.empty(length)
        jm_tGenCodTim = np.empty(length)
        jm_tOtherTim = np.empty(length)
        jm_nStaEve = np.empty(length)
        jm_nTimEve = np.empty(length)
        tInsTimeBas = np.empty(length)
        tComCBas = np.empty(length)
        tGenCBas = np.empty(length)
        dy_modelName = list()
        dy_solver = list()
        jm_modelName = list()
        jm_solver = list()
        # ------ extract data from Json file ------
        if 'dymola' in results['case_list']:
            for index, ele in enumerate(results['case_list']['dymola']):
                dy_modelName.append(ele['modelName'])
                dy_tTraTim[index] = ele['tTraTim']
                dy_tCPU[index] = ele['tCPU']
                dy_nEve[index] = ele['nEve']
                dy_solver.append(ele['solver'])
        if 'JModelica' in results['case_list']:
            for index, ele in enumerate(results['case_list']['JModelica']):
                jm_modelName.append(ele['modelName'])
                jm_tComTim[index] = ele['tComTim']
                jm_tSimTim[index] = ele['tSimTim']
                jm_tFlaTim[index] = ele['tFlaTim']
                jm_tInsTim[index] = ele['tInsTim']
                tInsTimeBas[index] = jm_tFlaTim[index] + jm_tInsTim[index]
                jm_tComCTim[index] = ele['tComCTim']
                tComCBas[index] = tInsTimeBas[index] + jm_tComCTim[index]
                jm_tGenCodTim[index] = ele['tGenCodTim']
                tGenCBas[index] = tComCBas[index] + jm_tGenCodTim[index]
                jm_tOtherTim[index] = ele['tOtherTim']
                jm_nStaEve[index] = ele['nStaEve']
                jm_nTimEve[index] = ele['nTimEve']
                jm_solver.append(ele['solver'])

        pos = list(range(length))
        width = 0.1
        # ------ generate plot for simulation time ------
        fig, ax = plt.subplots(figsize=(10,5))
        if ('dymola' in results['case_list']) and (not 'JModelica' in results['case_list']):
            plt.bar(pos, dy_tCPU, width, color='b', label='Dymola')
            plt.xticks(pos, dy_modelName)
        elif (not 'dymola' in results['case_list']) and ('JModelica' in results['case_list']):
            plt.bar(pos, jm_tSimTim, width, color='b', label='JModelica')
            plt.xticks(pos, jm_modelName)
        else:
            plt.bar(pos, dy_tCPU, width, color='k', label='Dymola')
            plt.bar([p+width for p in pos], jm_tSimTim, width, color='b', label='JModelica')
            plt.xticks([p+width/2 for p in pos], dy_modelName)
        plt.xlabel('Model')
        plt.ylabel('Simulation time')
        plt.title('Simulation time')
        plt.legend(loc = 'upper right')
        plt.grid(linestyle='--', axis='y')
        plt.savefig(os.path.join("results","SimulationTime.png"))
        # ------ generate plot for compile time ------
        fig, ax = plt.subplots(figsize=(10,5))
        if ('dymola' in results['case_list']) and (not 'JModelica' in results['case_list']):
            plt.bar(pos, dy_tTraTim, width, color='m', label='Dymola')
            plt.xticks(pos, dy_modelName)
            plt.legend(loc = 'upper right')
        elif (not 'dymola' in results['case_list']) and ('JModelica' in results['case_list']):
            p1 = plt.bar(pos, jm_tFlaTim, width, color='k')
            p2 = plt.bar(pos, jm_tInsTim, width, bottom=jm_tFlaTim, color='b')
            p3 = plt.bar(pos, jm_tComCTim, width, bottom=tInsTimeBas, color='r')
            p4 = plt.bar(pos, jm_tGenCodTim, width, bottom=tComCBas, color='g')
            p5 = plt.bar(pos, jm_tOtherTim, width, bottom=tGenCBas, color='c')
            plt.xticks(pos, jm_modelName)
            plt.legend((p5[0],p4[0],p3[0],p2[0],p1[0]),\
                ('JModelica: Others', 'JModelica: Generate C', \
                'JModelica: Compile C', 'JModelica: Instantiate', \
                'JModelica: Flatten'), loc = 'upper right')
        else:
            dyP = plt.bar(pos, dy_tTraTim, width, color='m')
            p1 = plt.bar([p+width for p in pos], jm_tFlaTim, width, color='k')
            p2 = plt.bar([p+width for p in pos], jm_tInsTim, width, bottom=jm_tFlaTim, color='b')
            p3 = plt.bar([p+width for p in pos], jm_tComCTim, width, bottom=tInsTimeBas, color='r')
            p4 = plt.bar([p+width for p in pos], jm_tGenCodTim, width, bottom=tComCBas, color='g')
            p5 = plt.bar([p+width for p in pos], jm_tOtherTim, width, bottom=tGenCBas, color='c')
            plt.xticks([p+width/2 for p in pos], dy_modelName)
            plt.legend(dyP[0],'Dymola', loc = 'upper left')
            plt.legend((p5[0],p4[0],p3[0],p2[0],p1[0],dyP[0]),\
                ('JModelica: Others', 'JModelica: Generate C', \
                'JModelica: Compile C', 'JModelica: Instantiate', \
                'JModelica: Flatten', 'Dymola'), loc = 'upper right')
        plt.xlabel('Model')
        plt.ylabel('Compile time')
        plt.title('Compile time')
        plt.grid(linestyle='--', axis='y')
        plt.savefig(os.path.join("results", "CompileTime.png"))


if __name__=='__main__':
    import json
    import caseSettings
    # ------ retrieve settings ------
    settings, tools, runSettings = caseSettings.get_settings()
    lib_dir = create_working_directory()
    # ------ clone and checkout repository to working folder ------
    checkout_repository(runSettings, lib_dir)
    # ------ create folder to save results ------
    if os.path.exists("results"):
        shutil.rmtree("results")
    newDir = os.path.join(os.getcwd(),"results")
    os.makedirs(newDir)
    resultsFile = os.path.join("results", "results.json")

    results = {}
    results['title'] = 'timeLog'
    results['case_list'] = {}
    for tool in tools:
        if tool == "dymola":
            results['case_list']['dymola'] = []
            for index, setting in enumerate(settings):
                setting['lib_dir'] = lib_dir
                model=setting['model']
                modelName=model.split(".")[-1]
                tTraTim, tCPU, nEve, solver \
                    =_profile(setting,tool,runSettings['JMODELICA_INST'], runSettings['Heap_Space'])
                results['case_list']['dymola'].append({
                    'modelName': modelName,
                    'tTraTim': float(tTraTim),
                    'tCPU': float(tCPU),
                    'nEve': float(nEve),
                    'solver': solver})
        else:
            results['case_list']['JModelica'] = []
            for index, setting in enumerate(settings):
                setting['lib_dir'] = lib_dir
                model=setting['model']
                modelName=model.split(".")[-1]
                totComTim, totSimTim, flaModTim, insModTim, comCTim, \
                genCodTim, otherComTim, numStaEve, numTimEve, solTyp \
                    = _profile(setting,tool,runSettings['JMODELICA_INST'],runSettings['Heap_Space'])
                results['case_list']['JModelica'].append({
                    'modelName': modelName,
                    'tComTim': float(totComTim),
                    'tSimTim': float(totSimTim),
                    'tFlaTim': float(flaModTim),
                    'tInsTim': float(insModTim),
                    'tComCTim': float(comCTim),
                    'tGenCodTim': float(genCodTim),
                    'tOtherTim': float(otherComTim),
                    'nStaEve': float(numStaEve),
                    'nTimEve': float(numTimEve),
                    'solver': solTyp})
    # ------ open an empty JSON file logging times ------
    if os.path.exists(resultsFile):
	    os.remove(resultsFile)
    else:
	    print("{} is not exist. A new file will be created.\r\n".format(resultsFile))
    with open(resultsFile, 'w') as outfile:
        json.dump(results, outfile)
    genPlots(resultsFile, True)
