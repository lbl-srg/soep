END_TIME=2*24*3600

def get_settings():
    ''' Return the simulation models that are used for benchmark study.
        The cases are stored in this function as they are used for simulation
        case settings and for the post processing.
    '''
    SOLVER="radau"
    BRANCH="master"
    COMMIT="HEAD"
    FROM_GIT_HUB = False
    LOCAL_BUILDINGS_LIBRARY = "/home/jianjun/GitFolder/modelica-buildings/Buildings"
    JMODELICA_INST = "/home/jianjun/proj/JModelica"

    settings = list()
    settings.append(\
        {'model': "Buildings.Examples.HydronicHeating.TwoRoomsWithStorage",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Examples.DualFanDualDuct.ClosedLoop",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Examples.VAVReheat.ClosedLoop",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Examples.ChillerPlant.DataCenterDiscreteTimeControl",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Examples.ChillerPlant.DataCenterContinuousTimeControl",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Examples.VAVReheat.ASHRAE2006",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Examples.VAVReheat.Guideline36",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Experimental.DistrictHeatingCooling.Examples.HeatingCoolingHotWater3Clusters",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.OneFloor_OneZone",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.TwoFloor_TwoZone",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})
    settings.append(\
        {'model': "Buildings.Air.Systems.SingleZone.VAV.Examples.ChillerDXHeatingEconomizer",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})


    settings = list()
    settings.append(\
        {'model': "Buildings.Air.Systems.SingleZone.VAV.Examples.ChillerDXHeatingEconomizer",
         "solver": SOLVER,
         "start_time": 0,
         "stop_time": END_TIME})

    return settings, BRANCH, COMMIT, FROM_GIT_HUB, LOCAL_BUILDINGS_LIBRARY, JMODELICA_INST
