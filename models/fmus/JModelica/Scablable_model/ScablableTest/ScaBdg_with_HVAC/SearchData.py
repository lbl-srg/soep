import os
import numpy as N
import re
import matplotlib.pyplot as plt

def search_Time(Compilelog_file, Simlog_file):

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
	sf.close()
    return compileTime, simTime

#========================================================
def genPlot(with_plots,compTimLog,simTimLog):
    if with_plots:
	MaxZon = len(simTimLog)
    fig = plt.figure(figsize=(15, 15))

    sub1 = fig.add_subplot(331, axisbg="lightgreen")
    sub1.set_title('Total CompileTime', fontweight='bold')
    sub1.plot(compTimLog[:,0],compTimLog[:,1],'r',lw=2)
    sub1.set_xlabel('Number of Zones')
    sub1.set_ylabel('Time, second')
    sub1.set_xlim([1,MaxZon])
    sub1.set_ylim([0,600])
    sub1.grid()

    sub2 = fig.add_subplot(332)
    sub2.set_title('parseModel')
    sub2.plot(compTimLog[:,0],compTimLog[:,2],'r',lw=2)
    sub2.set_xlabel('Number of Zones')
    sub2.set_ylabel('Time, second')
    sub2.set_xlim([1,MaxZon])
    sub2.grid()

    sub3 = fig.add_subplot(333)
    sub3.set_title('instantiateModel')
    sub3.plot(compTimLog[:,0],compTimLog[:,3],'r',lw=2)
    sub3.set_xlabel('Number of Zones')
    sub3.set_ylabel('Time, second')
    sub3.set_xlim([1,MaxZon])
    sub3.grid()

    sub4 = fig.add_subplot(334)
    sub4.set_title('flattenModel')
    sub4.plot(compTimLog[:,0],compTimLog[:,4],'r', label='Total flatten time',lw=2)
    sub4.plot(compTimLog[:,0],compTimLog[:,5],'b', label='flatten',lw=1)
    sub4.plot(compTimLog[:,0],compTimLog[:,11],'g', label='prettyPrintRawFlat',lw=1)
    sub4.plot(compTimLog[:,0],compTimLog[:,12],'c', label='transformCanonical',lw=1)
    sub4.plot(compTimLog[:,0],compTimLog[:,51],'m', label='prettyPrintFlat',lw=1)
    sub4.legend(loc='best',fontsize='small')
    sub4.set_xlabel('Number of Zones')
    sub4.set_ylabel('Time, second')
    sub4.set_xlim([1,MaxZon])
    sub4.grid()

    sub5 = fig.add_subplot(335)
    sub5.set_title('generateCode')
    sub5.plot(compTimLog[:,0],compTimLog[:,52],'r',lw=2)
    sub5.set_xlabel('Number of Zones')
    sub5.set_ylabel('Time, second')
    sub5.set_xlim([1,MaxZon])
    sub5.grid()

    sub6 = fig.add_subplot(336)
    sub6.set_title('compileCCode')
    sub6.plot(compTimLog[:,0],compTimLog[:,53],'r',lw=2)
    sub6.set_xlabel('Number of Zones')
    sub6.set_ylabel('Time, second')
    sub6.set_xlim([1,MaxZon])
    sub6.grid()

    sub7 = fig.add_subplot(337)
    sub7.set_title('packUnit')
    sub7.plot(compTimLog[:,0],compTimLog[:,54],'r',lw=2)
    sub7.set_xlabel('Number of Zones')
    sub7.set_ylabel('Time, second')
    sub7.set_xlim([1,MaxZon])
    sub7.grid()

    sub8 = fig.add_subplot(338, axisbg="lightgrey")
    sub8.set_title('Compile time split',fontweight='bold')
    sub8.plot(compTimLog[:,0],compTimLog[:,1],'r', label='Total compile time',lw=2)
    sub8.plot(compTimLog[:,0],compTimLog[:,4],'b', label='Total flatten time',lw=1)
    sub8.plot(compTimLog[:,0],compTimLog[:,3],'g', label='instantiateModel',lw=1)
    sub8.plot(compTimLog[:,0],compTimLog[:,53],'c', label='compileCCode',lw=1)
    sub8.plot(compTimLog[:,0],compTimLog[:,52],'m', label='generateCode',lw=1)
    sub8.legend(loc='best',fontsize='small')
    sub8.set_xlabel('Number of Zones')
    sub8.set_ylabel('Time, second')
    sub8.set_xlim([1,MaxZon])
    sub8.grid()

    sub9 = fig.add_subplot(339, axisbg="lightgreen")
    sub9.set_title('Total SimTime',fontweight='bold')
    sub9.plot(simTimLog[:,0],simTimLog[:,1],'r',lw=2)
    sub9.set_xlabel('Number of Zones')
    sub9.set_ylabel('Time, second')
    sub9.set_xlim([1,MaxZon])
    sub9.set_ylim([0,600])
    sub9.grid()

    plt.tight_layout()
    plt.show()

    fig.savefig("TimeTest_Max"+str(MaxZon)+"Zone.png")


if __name__=="__main__":
    maxZonNum = 21
    compTimLog=N.empty([maxZonNum,55])
    simTimLog=N.empty([maxZonNum,2])
    for i in range(maxZonNum):
        Compilelog_file = os.getcwd() + "/CompileLog/Compilelog_" + str(i+1) + ".txt"
        Simlog_file = os.getcwd() + "/SimLog/simLog_" + str(i+1) + ".txt"
        compileTime, simTime = search_Time(Compilelog_file, Simlog_file)
	simTimLog[i,0] = i+1
	simTimLog[i,1] = simTime
	compTimLog[i,0]= i+1
	for j in range(54):
	    compTimLog[i,j+1] = compileTime[j]
    with_plots = True
    genPlot(with_plots,compTimLog,simTimLog)
