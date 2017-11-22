#!/usr/bin/env python
#############################################################
import os
import shutil
import subprocess
import numpy as N

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

def checkout_repository(setArgs, local_lib, working_directory):
    from git import Repo
    import git

    BRANCH = setArgs.b
    LOCAL_BUILDINGS_LIBRARY = local_lib
    from_git_hub = setArgs.git
    commit = setArgs.c

    print ("Is from Git hub? {}".format(from_git_hub))
    if from_git_hub:
        print("Checking out repository branch {}, commit {}".format(BRANCH, commit))
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

def _profile(setting,tool,JMODELICA_INST,args):
    ''' Run simulation with both dymola and JModelica. The function returns
        CPU time used for compile and simulation.
    '''
    import string
    import jinja2 as jja2
    import datetime
    import time

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
        s.setSolver(args.s)
        s.setStopTime(args.runtime)
        s.setTolerance(1E-6)
        tstart_tr = datetime.datetime.now()
        s.simulate()
        tend_tr = datetime.datetime.now()
        # total time
        tTotTim = (tend_tr-tstart_tr).total_seconds()
        resultFile = os.path.join(out_dir, model.split(".")[-1] + ".mat")
        r=Reader(resultFile, "dymola")
        tCPU=r.max("CPUtime")
        tTraTim = tTotTim-tCPU
        nEve=r.max('EventCounter')
        solver=args.s

        eveLog = N.zeros(3)
        searchEve = list()
        searchEve.append("Number of (model) time events             :")
        searchEve.append("Number of time    events                 :")
        searchEve.append("Number of step     events                 :")
        # ------ search and retrieve times from compile log file ------
        with open(os.path.join(out_dir,'dslog.txt'), "r") as f:
            for line in f:
                for index, strLin in enumerate(searchEve):
                    if strLin in line:
                        sect1 = line.split(": ")
                        sect2 = sect1[1].split("\n")
                        eveLog[index] = sect2[0]
        f.close()
        print "tTraTim = {}, tCPU = {}, nEve = {}, timeEvent = {}, stateEvent = {}, stepEvent = {}, solver = {},  {}"\
            .format(tTraTim, tCPU, nEve, eveLog[0], eveLog[1], eveLog[2],  solver, model)
        shutil.rmtree("out")
        return tTraTim, tCPU, nEve, eveLog, solver
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
        logFile = 'd:{}'.format("comLog.txt")
        # create heap space input
        heapSpace = '-Xmx' + args.heapSpace

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
                                   end_time=args.runtime)
        runJM_file = "runJM.py"
        with open(runJM_file,'w') as rf:
            rf.write(str(runJMOut))
        # move rendered simulator script to working directory
        shutil.copy(runJM_file, os.path.join(worDir,'runJM.py'))
        os.remove(runJM_file)
        curWorDir=os.getcwd()
        # change working directory
        os.chdir(worDir)
        # ------ implement JModelica simulation ------
        simFile = open('simLog.txt','w')
        timeout = 10
        try:
            staTim = datetime.datetime.now()
            pro = subprocess.Popen(args=['jm_ipython.sh', runJM_file],\
                                   stdout=subprocess.PIPE,\
                                   stderr=subprocess.PIPE,\
                                   shell=False)
            killedProcess = False
            if timeout > 0:
                while pro.poll() is None:
                    time.sleep(0.01)
                    elapsedTime = (datetime.datetime.now() - staTim).seconds
                    print ('current elapsed time: {}'.format(elapsedTime))
                    if elapsedTime > timeout:
                        if not killedProcess:
                            killedProcess = True
                            print('Terminating JModelica simulation.')
                            pro.terminate()
                        else:
                            print("Killing JModelica simulation due to timeout.")
                            pro.kill()
            else:
                pro.wait()
            simFile.write(pro.stdout.read())
        except OSError as e:
            print("Execution of JModelica failed:", e)

        os.remove(runJM_file)
        # write out simulation information typically showing on console to "simFile"
        simFile.close()
        # --------------------------------------------
        # retrieve the compile and simulation time
        translateTime, totSimTim, numStaEve, numTimEve, solTyp  = search_Time('comLog.txt', 'simLog.txt')
        # change back to current work directory containing this .py file
        os.chdir(curWorDir)
        # total compile time
        totTraTim = translateTime[0]
        # ------ compile time break ------
        jmTraTimBre = N.zeros(12)
        # level 1: instantiate model time
        jmTraTimBre[0] = translateTime[2]
        # level 1: flatten model time
        flaModTim = translateTime[3]
        # ::::level 2: flattenBreak.flatten
        jmTraTimBre[1] = translateTime[4]
        # ::::level 2: flattenBreak.prettyPrintRawFlat
        jmTraTimBre[2] = translateTime[10]
        # ::::level 2: flattenBreak.transformCanonical
        transformCanonical = translateTime[11]
        # ::::::::level 3: flattenBreak.transformCanonical.scalarize
        jmTraTimBre[3] = translateTime[14]
        # ::::::::level 3: flattenBreak.transformCanonical.indexReduction
        jmTraTimBre[4] = translateTime[36]
        # ::::::::level 3: flattenBreak.transformCanonical.computeMatchingsAndBLT
        jmTraTimBre[5] = translateTime[46]
        # ::::::::level 3: flattenBreak.transformCanonical.others
        jmTraTimBre[6] = transformCanonical - (jmTraTimBre[3]+jmTraTimBre[4]+jmTraTimBre[5])
        # ::::level 2: flattenBreak.prettyPrintFlat
        jmTraTimBre[7] = translateTime[50]
        # level 1: generate code time
        jmTraTimBre[8] = translateTime[51]
        # level 1: compilte C code time
        jmTraTimBre[9] = translateTime[52]
        # level 1: other compile time
        jmTraTimBre[10] = totTraTim - (flaModTim + jmTraTimBre[0] + jmTraTimBre[8] + jmTraTimBre[9])
        print "simTim={}, traTim={} which includes insTim={}, flaTim={}, genCodTim={}, comCTim={} and others={}.". \
              format(totSimTim, totTraTim, jmTraTimBre[0], flaModTim, jmTraTimBre[8], jmTraTimBre[9],jmTraTimBre[10])
        return totTraTim, totSimTim, jmTraTimBre,\
               numStaEve, numTimEve, solTyp

# Retrieve compile and simulation time from log files when running JModelica
def search_Time(Compilelog_file, Simlog_file):
    ''' This function searchs and returns compile times from the log files.
    '''
    translateTime = N.zeros(54)
    searchComp = list()
    searchComp.append("Total                                    :")
    searchComp.append("parseModel()                            :")
    searchComp.append("instantiateModel()                      :")
    searchComp.append("flattenModel()                          :")
    # searchComp[4]
    searchComp.append("flatten()                              :")
    searchComp.append("flattenInstClassDecl()                :")
    searchComp.append("buildConnectionSets()                :")
    searchComp.append("flattenComponents()                  :")
    searchComp.append("updateVariabilityForVariablesInWhen():")
    searchComp.append("genConnectionEquations()             :")
    # searchComp[10]
    searchComp.append("prettyPrintRawFlat()                   :")
    # searchComp[11]
    searchComp.append("transformCanonical()                   :")
    searchComp.append("enableIfEquationElimination           :")
    searchComp.append("genInitArrayStatements                :")
    # searchComp[14]
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
    # searchComp[36]
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
    # searchComp[46]
    searchComp.append("computeMatchingsAndBLT                :")
    searchComp.append("computeBLT()                         :")
    searchComp.append("computeBLT()                         :")
    searchComp.append("removeUnusedFunctionsAndRecords()     :")
    # searchComp[50]
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
                    translateTime[index] = sect2[0]
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
    return translateTime, simTime, numStaEve, numTimEve, solTyp

def genPlots(resultsFile, genPlot):
    import json
    import matplotlib.pyplot as plt

    if genPlot:
        with open(resultsFile) as json_file:
            results = json.load(json_file)
        if 'dymola' in results['case_list']:
            length = len(results['case_list']['dymola'])
        else:
            length = len(results['case_list']['JModelica'])
        dy_tCPU = N.empty(length)
        dy_tTraTim = N.empty(length)
        dy_nTimEve = N.empty(length)
        dy_nStaEve = N.empty(length)
        dy_nSteEve = N.empty(length)

        jm_tSim = N.empty(length)
        jm_tTra = N.empty(length)
        jm_tIns = N.empty(length)
        jm_tTotFla = N.empty(length)
        jm_tFla = N.empty(length)
        jm_tPrePriRawFla = N.empty(length)
        jm_tTraCan_Sca = N.empty(length)
        jm_tTraCan_IndRed = N.empty(length)
        jm_tTraCan_ComMatBLT = N.empty(length)
        jm_tTraCan_Others = N.empty(length)
        jm_tPrePriFla = N.empty(length)
        jm_tGenC = N.empty(length)
        jm_tComC = N.empty(length)
        jm_tOthTra = N.empty(length)
        jm_nStaEve = N.empty(length)
        jm_nTimEve = N.empty(length)

        jm_base1 = N.empty(length)
        jm_base2 = N.empty(length)
        jm_base3 = N.empty(length)
        jm_base4 = N.empty(length)
        jm_base5 = N.empty(length)
        jm_base6 = N.empty(length)
        jm_base7 = N.empty(length)
        jm_base8 = N.empty(length)
        jm_base9 = N.empty(length)

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
                dy_nTimEve[index] = ele['nTimeEvent']
                dy_nStaEve[index] = ele['nStateEvent']
                dy_nSteEve[index] = ele['nStepEvent']
                dy_solver.append(ele['solver'])
        if 'JModelica' in results['case_list']:
            for index, ele in enumerate(results['case_list']['JModelica']):
                jm_modelName.append(ele['modelName'])
                jm_tSim[index] = ele['tSim']

                jm_tTra[index] = ele['tTra']

                jm_tIns[index] = ele['tIns']
                jm_tFla[index] = ele['tFla']
                jm_base1[index] = jm_tIns[index] + jm_tFla[index]
                jm_tPrePriRawFla[index] = ele['tPrePriRawFla']
                jm_base2[index] = jm_base1[index] + jm_tPrePriRawFla[index]
                jm_tTraCan_Sca[index] = ele['tTraCan_Sca']
                jm_base3[index] = jm_base2[index] + jm_tTraCan_Sca[index]
                jm_tTraCan_IndRed[index] = ele['tTraCan_IndRed']
                jm_base4[index] = jm_base3[index] + jm_tTraCan_IndRed[index]
                jm_tTraCan_ComMatBLT[index] = ele['tTraCan_ComMatBLT']
                jm_base5[index] = jm_base4[index] + jm_tTraCan_ComMatBLT[index]
                jm_tTraCan_Others[index] = ele['tTraCan_Others']
                jm_base6[index] = jm_base5[index] + jm_tTraCan_Others[index]
                jm_tPrePriFla[index] = ele['tPrePriFla']
                jm_base7[index] = jm_base6[index] + jm_tPrePriFla[index]
                jm_tGenC[index] = ele['tGenC']
                jm_base8[index] = jm_base7[index] + jm_tGenC[index]
                jm_tComC[index] = ele['tComC']
                jm_base9[index] = jm_base8[index] + jm_tComC[index]
                jm_tOthTra[index] = ele['tOthTra']
                jm_tTotFla[index] = jm_tTra[index]-\
                    (jm_tOthTra[index]+jm_tIns[index]+jm_tGenC[index]+jm_tComC[index])
                jm_nStaEve[index] = ele['nStateEvent']
                jm_nTimEve[index] = ele['nTimeEvent']
                jm_solver.append(ele['solver'])
        pos = list(range(length))
        width = 0.1
        # ------ generate plot for simulation time ------
        fig, ax = plt.subplots(figsize=(10,5))
        if ('dymola' in results['case_list']) and (not 'JModelica' in results['case_list']):
            plt.bar(pos, dy_tCPU, width, color='k', label='Dymola')
            plt.xticks(pos, dy_modelName)
        elif (not 'dymola' in results['case_list']) and ('JModelica' in results['case_list']):
            plt.bar(pos, jm_tSim, width, color='b', label='JModelica')
            plt.xticks(pos, jm_modelName)
        else:
            plt.bar(pos, dy_tCPU, width, color='k', label='Dymola')
            plt.bar([p+width for p in pos], jm_tSim, width, color='b', label='JModelica')
            plt.xticks([p+width/2 for p in pos], dy_modelName)
        plt.xlabel('Model')
        plt.ylabel('Simulation time, seconds')
        plt.title('Simulation time')
        plt.legend(loc = 'upper right')
        #plt.grid(linestyle='--', axis='y')
        plt.savefig(os.path.join("results","SimulationTime.pdf"))
        # ------ generate plot for compile time ------
        fig, ax = plt.subplots(figsize=(10,5))
        if ('dymola' in results['case_list']) and (not 'JModelica' in results['case_list']):
            plt.bar(pos, dy_tTraTim, width, color='k', label='Dymola')
            plt.xticks(pos, dy_modelName)
            plt.legend(loc = 'upper right')
        elif (not 'dymola' in results['case_list']) and ('JModelica' in results['case_list']):
            p1 = plt.bar(pos, jm_tIns, width, color = 'blue', edgecolor='black')
            p2 = plt.bar(pos, jm_tFla, width, bottom=jm_tIns, color = 'royalblue')
            p3 = plt.bar(pos, jm_tPrePriRawFla, width, bottom=jm_base1, color = 'lightcyan')
            p4 = plt.bar(pos, jm_tTraCan_Sca, width, bottom=jm_base2, color = 'green')
            p5 = plt.bar(pos, jm_tTraCan_IndRed, width, bottom=jm_base3, color = 'mediumpurple')
            p6 = plt.bar(pos, jm_tTraCan_ComMatBLT, width, bottom=jm_base4, color = 'midnightblue')
            p7 = plt.bar(pos, jm_tTraCan_Others, width, bottom=jm_base5, color = 'cornsilk')
            p8 = plt.bar(pos, jm_tPrePriFla, width, bottom=jm_base6, color = 'paleturquoise')
            p9 = plt.bar(pos, jm_tGenC, width, bottom=jm_base7, color = 'bisque', edgecolor='black')
            p10 = plt.bar(pos, jm_tComC, width, bottom=jm_base8, color = 'slategray', edgecolor='black')
            p11 = plt.bar(pos, jm_tOthTra, width, bottom=jm_base9, color = 'darkcyan', edgecolor='black')
            p12 = plt.bar(pos, jm_tTotFla, width, bottom=jm_tIns, fill=False, edgecolor='black')
            plt.xticks(pos, jm_modelName)
            plt.legend((p11[0],p10[0],p9[0],p8[0],p7[0],p6[0],p5[0],p4[0],p3[0],p2[0],p1[0]),\
                ('JModelica: others', 'JModelica: compile C', \
                'JModelica: generate C', 'JModelica: prettyPrintFlat', \
                'JModelica: traCan.Others', 'JModelica: traCan.CompMat&BLT',\
                'JModelica: traCan.IndexRed', 'JModelica: traCan.Scalarize',\
                'JModelica: prettyPrintRawFlat', 'JModelica: flatten',\
                'JModelica: instantiate'), loc = 'upper right')
        else:
            dyP = plt.bar(pos, dy_tTraTim, width, color='k')
            p1 = plt.bar([p+width for p in pos], jm_tIns, width, color = 'blue', edgecolor='black')
            p2 = plt.bar([p+width for p in pos], jm_tFla, width, bottom=jm_tIns, color = 'royalblue')
            p3 = plt.bar([p+width for p in pos], jm_tPrePriRawFla, width, bottom=jm_base1, color = 'lightcyan')
            p4 = plt.bar([p+width for p in pos], jm_tTraCan_Sca, width, bottom=jm_base2, color = 'green')
            p5 = plt.bar([p+width for p in pos], jm_tTraCan_IndRed, width, bottom=jm_base3, color = 'mediumpurple')
            p6 = plt.bar([p+width for p in pos], jm_tTraCan_ComMatBLT, width, bottom=jm_base4, color = 'midnightblue')
            p7 = plt.bar([p+width for p in pos], jm_tTraCan_Others, width, bottom=jm_base5, color = 'cornsilk')
            p8 = plt.bar([p+width for p in pos], jm_tPrePriFla, width, bottom=jm_base6, color = 'paleturquoise')
            p9 = plt.bar([p+width for p in pos], jm_tGenC, width, bottom=jm_base7, color = 'bisque', edgecolor='black')
            p10 = plt.bar([p+width for p in pos], jm_tComC, width, bottom=jm_base8, color = 'slategray', edgecolor='black')
            p11 = plt.bar([p+width for p in pos], jm_tOthTra, width, bottom=jm_base9, color = 'darkcyan', edgecolor='black')
            p12 = plt.bar([p+width for p in pos], jm_tTotFla, width, bottom=jm_tIns, fill=False, edgecolor='black')
            plt.xticks([p+width/2 for p in pos], dy_modelName)
            legend1 = plt.legend([dyP[0]],['Dymola'], loc = 'upper left')
            plt.legend((p11[0],p10[0],p9[0],p8[0],p7[0],p6[0],p5[0],p4[0],p3[0],p2[0],p1[0]),\
                ('JModelica: others', 'JModelica: compile C', \
                'JModelica: generate C', 'JModelica: prettyPrintFlat', \
                'JModelica: traCan.Others', 'JModelica: traCan.CompMat&BLT',\
                'JModelica: traCan.IndexRed', 'JModelica: traCan.Scalarize',\
                'JModelica: prettyPrintRawFlat', 'JModelica: flatten',\
                'JModelica: instantiate'), loc = 'upper right')
            plt.gca().add_artist(legend1)
        plt.xlabel('Model')
        plt.ylabel('Translate time, seconds')
        plt.title('Translate time')
        #plt.grid(linestyle='--', axis='y')
        plt.savefig(os.path.join("results", "TranslateTime.pdf"))


if __name__=='__main__':
    import json
    import caseSettings
    import argparse

    # ------ retrieve settings ------
    settings, tools, runSettings = caseSettings.get_settings()
    lib_dir = create_working_directory()
    # ------ user input from console ------
    parser = argparse.ArgumentParser(
        description = 'Benchmark study of computing time.',
        epilog = "Use as benchmarkStudy.py --tool dymola JModelica --from_git_hub True --branch master --commit HEAD --solver radau --runtime 7200 --heapSpace 7200m")
    parser.add_argument(\
                        '--from_git_hub',
                        help='Check if clone the repository from Github',
                        default=runSettings['FROM_GIT_HUB'],
                        dest='git')
    parser.add_argument(\
                        '--branch',
                        help='Branch name, such as master',
                        default=runSettings['BRANCH'],
                        dest='b')
    parser.add_argument(\
                        '--commit',
                        help='Commit number, such as HEAD',
                        default=runSettings['COMMIT'],
                        dest='c')
    parser.add_argument(\
                        '--solver',
                        help='Set solver for Dymola simulation. JModelica uses its default solver Cvode',
                        default=runSettings['SOLVER'],
                        dest='s')
    parser.add_argument(\
                        '--runtime',
                        help='Total simulation time in seconds, such as 2*24*3600',
                        default=runSettings['END_TIME'],
                        dest='runtime')
    parser.add_argument(\
                        '--tool',
                        help='Tools to run simulation, Dymola or JModelica',
                        nargs="*",
                        default=tools,
                        dest='tool')
    parser.add_argument(\
                        '--heapSpace',
                        help='Heap space for running JModelica, such as 7200m',
                        default=runSettings['Heap_Space'],
                        dest='heapSpace')

    args = parser.parse_args()

    print("from GitHub: {}".format(args.git))
    # ------ clone and checkout repository to working folder ------
    local_lib = runSettings['LOCAL_BUILDINGS_LIBRARY']
    checkout_repository(args, local_lib, lib_dir)
    # ------ create folder to save results ------
    if os.path.exists("results"):
        shutil.rmtree("results")
    newDir = os.path.join(os.getcwd(),"results")
    os.makedirs(newDir)
    resultsFile = os.path.join("results", "results.json")

    results = {}
    results['title'] = 'timeLog'
    results['case_list'] = {}

    for tool in args.tool:
        print ("========== current tool is: {} ==========".format(tool))
        if tool == "dymola":
            results['case_list']['dymola'] = []
            for index, setting in enumerate(settings):
                setting['lib_dir'] = lib_dir
                model=setting['model']
                modelName=model.split(".")[-1]
                tTraTim, tCPU, nEve, eveLog, solver \
                    =_profile(setting,tool,runSettings['JMODELICA_INST'],args)
                results['case_list']['dymola'].append({
                    'modelName': modelName,
                    'tTraTim': float(tTraTim),
                    'tCPU': float(tCPU),
                    'nTimeEvent': float(eveLog[0]),
                    'nStateEvent': float(eveLog[1]),
                    'nStepEvent': float(eveLog[2]),
                    'solver': solver})
        else:
            results['case_list']['JModelica'] = []
            for index, setting in enumerate(settings):
                setting['lib_dir'] = lib_dir
                model=setting['model']
                modelName=model.split(".")[-1]
                totTraTim, totSimTim, jmTraTimBre, \
                numStaEve, numTimEve, solTyp \
                    = _profile(setting,tool,runSettings['JMODELICA_INST'],args)
                results['case_list']['JModelica'].append({
                    'modelName': modelName,
                    'tSim': float(totSimTim),
                    'tTra': float(totTraTim),
                    'tIns': float(jmTraTimBre[0]),
                    'tFla': float(jmTraTimBre[1]),
                    'tPrePriRawFla': float(jmTraTimBre[2]),
                    'tTraCan_Sca': float(jmTraTimBre[3]),
                    'tTraCan_IndRed': float(jmTraTimBre[4]),
                    'tTraCan_ComMatBLT': float(jmTraTimBre[5]),
                    'tTraCan_Others': float(jmTraTimBre[6]),
                    'tPrePriFla': float(jmTraTimBre[7]),
                    'tGenC': float(jmTraTimBre[8]),
                    'tComC': float(jmTraTimBre[9]),
                    'tOthTra': float(jmTraTimBre[10]),
                    'nStateEvent': float(numStaEve),
                    'nTimeEvent': float(numTimEve),
                    'solver': solTyp})
    # ------ open an empty JSON file logging times ------
    if os.path.exists(resultsFile):
	    os.remove(resultsFile)
    else:
	    print("{} does not exist. A new file will be created.\r\n".format(resultsFile))
    with open(resultsFile, 'w') as outfile:
        json.dump(results, outfile, sort_keys=True, indent=4)
    genPlots(resultsFile, True)
