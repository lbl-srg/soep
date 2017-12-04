#!/usr/bin/env python
#
# Todo: - Make sure process are terminated if run in a docker.
#       - Use the same solver for JModelica as is used for Dymola.
#
#############################################################
import matplotlib
matplotlib.use('Agg') # Enables plotting without an window manager

import os
import shutil
import subprocess
import numpy as N
import multiprocessing
from multiprocessing import Pool


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
    import os
    import tempfile
    import getpass
    import platform

#    suf = os.path.join(os.getcwd(), "tmp_benchmarks")
#    if not os.path.exists(suf):
#        os.makedirs(suf)

    # Make temp directory in /private/var/tmp for docker on mac
    if platform.system() == "Darwin":
        worDir = tempfile.mkdtemp(dir = "/private/var/tmp", prefix='tmp-benchmark-' + getpass.getuser() + '-')
        print("Created {}".format(worDir))
    else:
        worDir = tempfile.mkdtemp(prefix='tmp-benchmark-' + getpass.getuser() + '-')
    return worDir

def checkout_repository(from_git_hub, branch, commit, working_directory):
    from git import Repo
    import git

    if from_git_hub:
        print("Checking out repository branch {}, commit {}".format(branch, commit))
        git_url = "https://github.com/lbl-srg/modelica-buildings"
        Repo.clone_from(git_url, working_directory)
        g = git.Git(working_directory)
        g.checkout(branch)
        g.checkout(commit)
    else:
        bui_lib_pat = None
        # Search on the MODELICAPATH, or the current directory
        if os.environ.has_key("MODELICAPATH"):
            roo = os.environ['MODELICAPATH']
        else:
            roo = os.getcwd()
        for d in roo.split(":"):
            if os.path.exists(os.path.join(d, "Buildings", "package.mo")):
                bui_lib_pat = d
        if bui_lib_pat is None:
            raise ValueError("Did not find Buildings library. Make sure it is on MODELICAPATH.")
        else:
            des = os.path.join(working_directory, "Buildings")
            print("*** Copying Buildings library to {}".format(des))
            shutil.copytree(os.path.join(bui_lib_pat, "Buildings"), des)

def _profile_dymola(result):
    ''' Run simulation with dymola. The function returns
        CPU time used for compile and simulation.
    '''
    import datetime
    import time

    from buildingspy.simulate.Simulator import Simulator
    from buildingspy.io.outputfile import Reader

    model=result['model']
    modelName = model.split(".")[-1]

    worDir = create_working_directory()
    # Update MODELICAPATH to get the right library version
    s=Simulator(model, "dymola", outputDirectory=worDir)
    s.setSolver(result['solver'])
    s.setStartTime(result['start_time'])
    s.setStopTime(result['stop_time'])
    s.setTolerance(result['tolerance'])
    timeout = result['timeout']
    if float(timeout) > 0.01:
        s.setTimeOut(timeout)
    tstart_tr = datetime.datetime.now()
    s.simulate()
    tend_tr = datetime.datetime.now()
    # total time
    tTotTim = (tend_tr-tstart_tr).total_seconds()
    resultFile = os.path.join(worDir, "{}.mat".format(modelName))

    # In case of timeout or error, the output file may not exist
    if not os.path.exists(resultFile):
        shutil.rmtree(worDir)
        return {'tTra': 0,
            'tCPU': 0,
            'nTimeEvent': 0,
            'nStateEvent': 0,
            'nStepEvent': 0}

    r=Reader(resultFile, "dymola")
    tCPU=r.max("CPUtime")
    tTra = tTotTim-tCPU
    nEve=r.max('EventCounter')

    eveLog = N.zeros(3)
    searchEve = list()
    searchEve.append("Number of (model) time events             :")
    searchEve.append("Number of time    events                 :")
    searchEve.append("Number of step     events                 :")
    # ------ search and retrieve times from compile log file ------
    with open(os.path.join(worDir,'dslog.txt'), "r") as f:
        for line in f:
            for index, strLin in enumerate(searchEve):
                if strLin in line:
                    sect1 = line.split(": ")
                    sect2 = sect1[1].split("\n")
                    eveLog[index] = sect2[0]
    f.close()

    shutil.rmtree(worDir)
    return {'tTra': float(tTra),
            'tCPU': float(tCPU),
            'nTimeEvent': float(eveLog[0]),
            'nStateEvent': float(eveLog[1]),
            'nStepEvent': float(eveLog[2])}


def _write_jmodelica_input(result, file_name, timeout):
    import jinja2 as jja2
    import string

    model  = result['model']

    # truncate model path to the package containing it
    truPath = model.rsplit('.',1)[0]

    modelPath = string.replace(truPath,'.','/')


    loader = jja2.FileSystemLoader('SimulatorTemplate_JModelica.py')
    env = jja2.Environment(loader=loader)
    template = env.get_template('')
    # render the JModelica simulator file
    runJMOut = template.render(heap_space='-Xmx{}'.format(result['heap_space']),
                               model=model,
                               solver=result['solver'],
                               tolerance=result['tolerance'],
                               fmi_version=2.0,
                               log_file='d:{}'.format("compilation.txt"),
                               start_time=result['start_time'],
                               stop_time=result['stop_time'],
                               timeout=timeout)

    with open(file_name, 'w') as rf:
        rf.write(runJMOut)


def _run_jmodelica(worDir, input_file, log_file, timeout):
    import signal
    import datetime
    import time
    import os

    try:
        #os.chdir(worDir)
        staTim = datetime.datetime.now()
        pro = subprocess.Popen(args=['jm_ipython.sh', input_file],\
                               cwd=worDir,\
                               stdout=subprocess.PIPE,\
                               stderr=subprocess.PIPE,\
                               shell=False)
        killedProcess = False
        if timeout > 0:
            while pro.poll() is None:
                time.sleep(0.01)
                elapsedTime = (datetime.datetime.now() - staTim).seconds
                #print ('current elapsed time: {}'.format(elapsedTime))
                if elapsedTime > timeout:
                    killedProcess = True
                    pro.send_signal(signal.SIGKILL)
                    #os.kill(pro.pid, signal.SIGTERM)
                    #pro.terminate()
                    raise RuntimeError('*** Terminated JModelica simulation due to timeout.')
        else:
            pro.wait()

        with open(log_file, 'w') as f:
            f.write(pro.stdout.read())
    except OSError as e:
        raise e

    retFla = pro.returncode

    if retFla is None:
        raise ValueError("Process returned no return code.")
    if retFla != 0:
        raise OSError("Running JModelica failed with return code {}.".format(retFla))
    return

def _profile_jmodelica(result):
    ''' Run simulation with dymola. The function returns
        CPU time used for compile and simulation.
    '''
    import string

    worDir = create_working_directory()
    runJM_file = os.path.join(worDir, 'runJM.py')
    _write_jmodelica_input(result, runJM_file, result['timeout'])

    # ------ implement JModelica simulation ------
    log_file = os.path.join(worDir, 'simLog.txt')

    try:
        _run_jmodelica(worDir, runJM_file, log_file, result['timeout'])
    except (RuntimeError, OSError, ValueError) as e:
        print(e)
        shutil.rmtree(worDir)
        return {'tSim': 0,
            'tTra': 0,
            'tIns': 0,
            'tFla': 0,
            'tPrePriRawFla':  0,
            'tTraCan_Sca': 0,
            'tTraCan_IndRed': 0,
            'tTraCan_ComMatBLT': 0,
            'tTraCan_Others': 0,
            'tPrePriFla': 0,
            'tGenC': 0,
            'tComC': 0,
            'tOthTra': 0,
            'nStateEvent': 0,
            'nTimeEvent': 0}



#    os.remove(runJM_file)
    # --------------------------------------------
    # retrieve the compile and simulation time
    translateTime, totSimTim, numStaEve, numTimEve  = read_jmodelica_output( \
       os.path.join(worDir, 'compilation.txt'), \
       log_file)

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
    shutil.rmtree(worDir)
    return {'tSim': float(totSimTim),
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
            'nTimeEvent': float(numTimEve)}

def _profile(result):

    # iCas is a unique number, starting with zero
    if result['tool'] == "dymola":
        p = _profile_dymola(result)
    elif result['tool'] == "jmodelica":
        p = _profile_jmodelica(result)
    else:
        raise ValueError("Wrong or missing tool in {}".format(result))
    ret = result
    ret['profiling'] = p

    return ret

# Retrieve compile and simulation time from log files when running JModelica
def read_jmodelica_output(compile_log, sim_log):
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

    # ------ search and retrieve times from compile log file ------
    if not os.path.exists(compile_log):
        print("Warning: JModelica log file {} does not exist.".format(compile_log))
        return translateTime, 0, 0, 0

    with open(compile_log, "r") as f:
        for line in f:
            for index, strLin in enumerate(searchComp):
                if strLin in line:
                    sect1 = line.split(":")
                    sect2 = sect1[1].split("s,")
                    translateTime[index] = sect2[0]

    # ------ search and retrieve times from simulation log file ------
    simTime = 0
    numStaEve = 0
    numTimEve = 0
    if not os.path.exists(sim_log):
        print("Warning: JModelica simulation file {} does not exist.".format(sim_log))
        return translateTime, simTime, numStaEve, numTimEve

    with open(sim_log, "r") as sf:
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

    return translateTime, simTime, numStaEve, numTimEve

def plot_results(resultsFile, genPlot):
    import json
    import matplotlib.pyplot as plt

    if genPlot:
        with open(resultsFile) as json_file:
            results = json.load(json_file)
        if 'dymola' in results['case_list']:
            length = len(results['case_list']['dymola'])
        else:
            length = len(results['case_list']['jmodelica'])
        dy_tCPU = N.empty(length)
        dy_tTra = N.empty(length)
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

        dy_model = list()
        dy_solver = list()
        jm_model = list()
        jm_solver = list()
        # ------ extract data from Json file ------
        if 'dymola' in results['case_list']:
            for index, ele in enumerate(results['case_list']['dymola']):
                short_model_name = "{}.\n{}".format(ele['model'].split(".")[-2], ele['model'].split(".")[-1])
                dy_model.append(short_model_name)
                dy_tTra[index] = ele['profiling']['tTra']
                dy_tCPU[index] = ele['profiling']['tCPU']
                dy_nTimEve[index] = ele['profiling']['nTimeEvent']
                dy_nStaEve[index] = ele['profiling']['nStateEvent']
                dy_nSteEve[index] = ele['profiling']['nStepEvent']
                dy_solver.append(ele['solver'])
        if 'jmodelica' in results['case_list']:
            for index, ele in enumerate(results['case_list']['jmodelica']):
                jm_model.append(ele['model'])
                jm_tSim[index] = ele['profiling']['tSim']

                jm_tTra[index] = ele['profiling']['tTra']

                jm_tIns[index] = ele['profiling']['tIns']
                jm_tFla[index] = ele['profiling']['tFla']
                jm_base1[index] = jm_tIns[index] + jm_tFla[index]
                jm_tPrePriRawFla[index] = ele['profiling']['tPrePriRawFla']
                jm_base2[index] = jm_base1[index] + jm_tPrePriRawFla[index]
                jm_tTraCan_Sca[index] = ele['profiling']['tTraCan_Sca']
                jm_base3[index] = jm_base2[index] + jm_tTraCan_Sca[index]
                jm_tTraCan_IndRed[index] = ele['profiling']['tTraCan_IndRed']
                jm_base4[index] = jm_base3[index] + jm_tTraCan_IndRed[index]
                jm_tTraCan_ComMatBLT[index] = ele['profiling']['tTraCan_ComMatBLT']
                jm_base5[index] = jm_base4[index] + jm_tTraCan_ComMatBLT[index]
                jm_tTraCan_Others[index] = ele['profiling']['tTraCan_Others']
                jm_base6[index] = jm_base5[index] + jm_tTraCan_Others[index]
                jm_tPrePriFla[index] = ele['profiling']['tPrePriFla']
                jm_base7[index] = jm_base6[index] + jm_tPrePriFla[index]
                jm_tGenC[index] = ele['profiling']['tGenC']
                jm_base8[index] = jm_base7[index] + jm_tGenC[index]
                jm_tComC[index] = ele['profiling']['tComC']
                jm_base9[index] = jm_base8[index] + jm_tComC[index]
                jm_tOthTra[index] = ele['profiling']['tOthTra']
                jm_tTotFla[index] = jm_tTra[index]-\
                    (jm_tOthTra[index]+jm_tIns[index]+jm_tGenC[index]+jm_tComC[index])
                jm_nStaEve[index] = ele['profiling']['nStateEvent']
                jm_nTimEve[index] = ele['profiling']['nTimeEvent']
                jm_solver.append(ele['solver'])
        pos = list(range(length))
        width = 0.2
        # ------ generate plot for simulation time ------
        fig, ax = plt.subplots(figsize=(10,10))
        if ('dymola' in results['case_list']) and (not 'jmodelica' in results['case_list']):
            plt.barh(pos, dy_tCPU, width, color='grey', label='dymola')
            plt.yticks(pos, dy_model)
        elif (not 'dymola' in results['case_list']) and ('jmodelica' in results['case_list']):
            plt.barh(pos, jm_tSim, width, color='k', label='jmodelica')
            plt.yticks(pos, jm_model)
        else:
            plt.barh([p+width for p in pos], jm_tSim, width, color='k', label='jmodelica')
            plt.barh(pos, dy_tCPU, width, color='grey', label='dymola')
            plt.yticks([p+width/2 for p in pos], dy_model)
        plt.xlabel('simulation time [s]')

        lgd = plt.legend(loc = 'upper right')
        #plt.grid(linestyle='--', axis='y')
        plt.savefig(os.path.join("results","simulation.pdf"), bbox_extra_artists=(lgd,), bbox_inches='tight')

        # ------ generate plot for compile time ------
        fig, ax = plt.subplots(figsize=(10,10))
        if ('dymola' in results['case_list']) and (not 'jmodelica' in results['case_list']):
            plt.barh(pos, dy_tTra, width, color='k', label='Dymola')
            plt.xticks(pos, dy_model)
            plt.legend(loc = 'upper right')
        elif (not 'dymola' in results['case_list']) and ('jmodelica' in results['case_list']):
            p1 = plt.barh(pos, jm_tIns, width, color = 'blue', edgecolor='black')
            p2 = plt.barh(pos, jm_tFla, width, left=jm_tIns, color = 'royalblue')
            p3 = plt.barh(pos, jm_tPrePriRawFla, width, left=jm_base1, color = 'lightcyan')
            p4 = plt.barh(pos, jm_tTraCan_Sca, width, left=jm_base2, color = 'green')
            p5 = plt.barh(pos, jm_tTraCan_IndRed, width, left=jm_base3, color = 'mediumpurple')
            p6 = plt.barh(pos, jm_tTraCan_ComMatBLT, width, left=jm_base4, color = 'midnightblue')
            p7 = plt.barh(pos, jm_tTraCan_Others, width, left=jm_base5, color = 'cornsilk')
            p8 = plt.barh(pos, jm_tPrePriFla, width, left=jm_base6, color = 'paleturquoise')
            p9 = plt.barh(pos, jm_tGenC, width, left=jm_base7, color = 'bisque', edgecolor='black')
            p10 = plt.barh(pos, jm_tComC, width, left=jm_base8, color = 'slategray', edgecolor='black')
            p11 = plt.barh(pos, jm_tOthTra, width, left=jm_base9, color = 'darkcyan', edgecolor='black')
            #p12 = plt.barh(pos, jm_tTotFla, width, left=jm_tIns, fill=False, edgecolor='black')
            plt.xticks(pos, jm_model)
            plt.legend((p11[0],p10[0],p9[0],p8[0],p7[0],p6[0],p5[0],p4[0],p3[0],p2[0],p1[0]),\
                ('jmodelica: others', 'jmodelica: compile C', \
                'jmodelica: generate C', 'jmodelica: prettyPrintFlat', \
                'jmodelica: traCan.others', 'jmodelica: traCan.compMat&BLT',\
                'jmodelica: traCan.indexRed', 'jmodelica: traCan.scalarize',\
                'jmodelica: prettyPrintRawFlat', 'jmodelica: flatten',\
                'jmodelica: instantiate'), loc = 'upper right')
        else:
            dyP = plt.barh(pos, dy_tTra, width, color='grey')
            p1 = plt.barh([p+width for p in pos], jm_tIns, width, color = 'blue')
            p2 = plt.barh([p+width for p in pos], jm_tFla, width, left=jm_tIns, color = 'royalblue')
            p3 = plt.barh([p+width for p in pos], jm_tPrePriRawFla, width, left=jm_base1, color = 'lightcyan')
            p4 = plt.barh([p+width for p in pos], jm_tTraCan_Sca, width, left=jm_base2, color = 'green')
            p5 = plt.barh([p+width for p in pos], jm_tTraCan_IndRed, width, left=jm_base3, color = 'mediumpurple')
            p6 = plt.barh([p+width for p in pos], jm_tTraCan_ComMatBLT, width, left=jm_base4, color = 'midnightblue')
            p7 = plt.barh([p+width for p in pos], jm_tTraCan_Others, width, left=jm_base5, color = 'cornsilk')
            p8 = plt.barh([p+width for p in pos], jm_tPrePriFla, width, left=jm_base6, color = 'paleturquoise')
            p9 = plt.barh([p+width for p in pos], jm_tGenC, width, left=jm_base7, color = 'bisque')
            p10 = plt.barh([p+width for p in pos], jm_tComC, width, left=jm_base8, color = 'slategray')
            p11 = plt.barh([p+width for p in pos], jm_tOthTra, width, left=jm_base9, color = 'red')
#            p12 = plt.barh([p+width for p in pos], jm_tTotFla, width, left=jm_tIns, fill=False, edgecolor='black', linewidth=0.5)
            plt.yticks([p+width/2 for p in pos], dy_model)

            lgd = plt.legend((p11[0],p10[0],p9[0],p8[0],p7[0],p6[0],p5[0],p4[0],p3[0],p2[0],p1[0],dyP[0]),\
                ('jmodelica: others', 'jmodelica: compile C', \
                'jmodelica: generate C', 'jmodelica: prettyPrintFlat', \
                'jmodelica: traCan.others', 'jmodelica: traCan.compMat&BLT',\
                'jmodelica: traCan.indexRed', 'jmodelica: traCan.scalarize',\
                'jmodelica: prettyPrintRawFlat', 'jmodelica: flatten',\
                'jmodelica: instantiate', 'dymola'), bbox_to_anchor=(1, 1.02))

        plt.xlabel('translation time [s]')
        #plt.grid(linestyle='--', axis='y')
        plt.savefig(os.path.join("results", "translation.pdf"), bbox_extra_artists=(lgd,), bbox_inches='tight')


if __name__=='__main__':
    import json
    import settings as s
    import argparse

    # ------ retrieve default settings ------
    tools = s.get_tools()
    cases = s.get_models()
    version = s.get_model_version()

    # ------ user input from console ------
    parser = argparse.ArgumentParser(
        description = 'Benchmark study of computing time.')
    parser.add_argument(\
                        '--from-git-hub',
                        action="store_true",
                        help='If specified, checkout the repository from Github',
                        dest='from_git_hub')
    parser.add_argument(\
                        '--branch',
                        help="Branch name, default is from settings.py",
                        default=version['branch'],
                        dest='branch')
    parser.add_argument(\
                        '--commit',
                        help='Commit, such as HEAD, default is from settings.py',
                        default=version['commit'],
                        dest='commit')
    parser.add_argument(\
                        '--timeout',
                        help='Timeout for each test case in seconds',
                        default=-1,
                        dest='timeout')
    parser.add_argument(\
                        '--tool',
                        help='Tools to run simulation, dymola or jmodelica',
                        choices=['dymola', 'jmodelica'],
                        type=str,
                        default=tools,
                        dest='tool')
    parser.add_argument(\
                        '--heap',
                        help='Heap space for running JModelica, such as 7200m',
                        default='2048m',
                        dest='heap_space')


#    plot_results(os.path.join(os.getcwd(), "results", "results.json"), True)
#    exit(1)

    args = parser.parse_args()
    arg_dic = vars(args)

    timeout = int(arg_dic['timeout'])
    heap_space = arg_dic['heap_space']
    res_dir = os.path.join(os.getcwd(), "results")

#    resultsFile = os.path.join(res_dir, "results.json")
#    plot_results(resultsFile, True)
#    exit(1)

    # ------ create folder to save results ------
    if os.path.exists("results"):
        shutil.rmtree("results")
    os.makedirs(res_dir)

    results = {}
    results['case_list'] = {}
    results['case_list']['dymola'] = []
    results['case_list']['jmodelica'] = []
    #nCas is a unique case number, that is used to parallelize the simulations
    nCas = 0
    for case in cases:
        # It is more convenient to also add a field for the tool
        if "dymola" in args.tool:
            results['case_list']['dymola'].append({
            'case_number': nCas,
            'model': case['model'],
            'solver': case['solver'],
            'start_time': case['start_time'],
            'stop_time': case['stop_time'],
            'tolerance': case['tolerance'],
            'timeout' : timeout,
            'tool': "dymola"})
            nCas = nCas + 1
        if "jmodelica" in args.tool:
            results['case_list']['jmodelica'].append({
            'case_number': nCas,
            'model': case['model'],
            'solver': 'CVode',
            'start_time': case['start_time'],
            'stop_time': case['stop_time'],
            'tolerance': case['tolerance'],
            'timeout' : timeout,
            'heap_space': heap_space,
            'tool': "jmodelica"})
            nCas = nCas + 1

    #print(json.dumps(results, indent=1))

    #Build a list with all cases
    lisRes = list()
    for iCas in range(nCas):
        # Add the dictionary with the right number.
        for tool in args.tool:
            for res in results['case_list'][tool]:
                if res['case_number'] == iCas:
                    lisRes.append(res)
                    break

    tmp_rep_dir = create_working_directory()
    # Put the Buildings library directory on the MODELICAPATH
    if os.environ.has_key("MODELICAPATH"):
        os.environ["MODELICAPATH"] = "{}:{}".format(tmp_rep_dir, os.environ["MODELICAPATH"])
    else:
        os.environ["MODELICAPATH"] = tmp_rep_dir

    # ------ clone and checkout repository to working folder ------
    checkout_repository(arg_dic['from_git_hub'], arg_dic['branch'], arg_dic['commit'], tmp_rep_dir)

    nPro = min(multiprocessing.cpu_count(), nCas)
    nPro = 1 # Multi-processing does not work. Results are not written back to dictionary

    p = Pool(nPro)

    if nPro == 1:
        for res in lisRes:
            res = _profile(res)
    else:
        mapLis = p.map(_profile, lisRes)
        for iCas in range(nCas):
            # Add results back into results data structure
            for tool in args.tool:
                for res in results['case_list'][tool]:
                    if res["case_number"] == mapLis[iCas]:
                        res = mapLis[iCas]

    # Delete directory that contains the Buildings library
    shutil.rmtree(tmp_rep_dir)
    # Write results to a json file for post-processing
    resultsFile = os.path.join(res_dir, "results.json")
    with open(resultsFile, 'w') as outfile:
        json.dump(results, outfile, sort_keys=True, indent=4)
    plot_results(resultsFile, True)
