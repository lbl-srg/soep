def get_settings():
    ''' Return the simulation models that are used for benchmark study.
        The cases are stored in this function as they are used for simulation
        case settings and for the post processing.
    '''
    tools = ["dymola", "JModelica"]
    # tools = ["dymola"]
    runSettings = {
        "SOLVER": "radau",
        "END_TIME": 2*24*3600,
        "BRANCH": "master",
        "COMMIT": "HEAD",
        "FROM_GIT_HUB": True,
        "LOCAL_BUILDINGS_LIBRARY": "/home/jianjun/GitFolder/modelica-buildings/Buildings",
        "JMODELICA_INST": "/home/jianjun/proj/JModelica2.0",
        "Heap_Space": "7200m"
        }

    settings = list()
    settings.append(\
        {'model': "Buildings.Examples.HydronicHeating.TwoRoomsWithStorage",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Examples.DualFanDualDuct.ClosedLoop",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Examples.VAVReheat.ClosedLoop",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Examples.ChillerPlant.DataCenterDiscreteTimeControl",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Examples.ChillerPlant.DataCenterContinuousTimeControl",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Examples.VAVReheat.ASHRAE2006",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Examples.VAVReheat.Guideline36",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Experimental.DistrictHeatingCooling.Examples.HeatingCoolingHotWater3Clusters",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.OneFloor_OneZone",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.TwoFloor_TwoZone",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Air.Systems.SingleZone.VAV.Examples.ChillerDXHeatingEconomizer",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})


    settings = list()
    settings.append(\
        {'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.OneFloor_OneZone",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.TwoFloor_TwoZone",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    settings.append(\
        {'model': "Buildings.Experimental.DistrictHeatingCooling.Examples.HeatingCoolingHotWater3Clusters",
         "solver": runSettings['SOLVER'],
         "start_time": 0,
         "stop_time": runSettings['END_TIME']})
    return settings, tools, runSettings
