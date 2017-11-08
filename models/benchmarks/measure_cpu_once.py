#!/usr/bin/env python
#############################################################
BRANCH="master"
COMMIT="HEAD"
FROM_GIT_HUB = True
LOCAL_BUILDINGS_LIBRARY = "/home/mwetter/proj/ldrd/bie/modeling/github/lbl-srg/modelica-buildings/Buildings"
CWD = os.getcwd()

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
    worDir = tempfile.mkdtemp( prefix='tmp-simulator-case_study-' + getpass.getuser() )
#    print("Created directory {}".format(worDir))
    return worDir

def checkout_repository(working_directory, from_git_hub):
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


def _profile(model):
    import os
    from buildingspy.simulate.Simulator import Simulator
    from buildingspy.io.outputfile import Reader
    out_dir = os.path.join("out", model)
    s=Simulator(model, "dymola", outputDirectory=out_dir)
    s.setSolver("radau")
    s.setStopTime(365*2*3600)
    s.setTolerance(1E-6)
    s.simulate()

    resultFile = os.path.join(out_dir, model.split(".")[-1] + ".mat")
    r=Reader(resultFile, "dymola")
    print "tCPU = {},  nEve = {},     {}".format(r.max("CPUtime"), r.max('EventCounter'), model)

if __name__=='__main__':

    models = ["Buildings.Examples.HydronicHeating.TwoRoomsWithStorage", \
              "Buildings.Examples.DualFanDualDuct.ClosedLoop", \
              "Buildings.Examples.VAVReheat.ClosedLoop",
              "Buildings.Examples.ChillerPlant.DataCenterDiscreteTimeControl",
              "Buildings.Examples.ChillerPlant.DataCenterContinuousTimeControl",
              "Buildings.Examples.VAVReheat.ASHRAE2006",
              "Buildings.Examples.VAVReheat.Guideline36",
              "Buildings.Experimental.DistrictHeatingCooling.Examples.HeatingCoolingHotWater3Clusters",
              "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.OneFloor_OneZone",
              "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.TwoFloor_TwoZone",
              "Buildings.Air.Systems.SingleZone.VAV.Examples.ChillerDXHeatingEconomizer"]



    for model in models:
        _profile(model)
