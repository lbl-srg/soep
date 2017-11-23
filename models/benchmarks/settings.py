def get_tools():
    ''' Return the tools used in the benchmark.
    '''
    tools = ["dymola", "jmodelica"]
    return tools


def get_model_version():
    versions = { \
    "branch": "master",
    "commit": "HEAD"}
    return versions


def get_models():
    models = list()
    models.append(\
        {'model': "Buildings.Examples.HydronicHeating.TwoRoomsWithStorage",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Examples.DualFanDualDuct.ClosedLoop",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Examples.VAVReheat.ClosedLoop",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Examples.ChillerPlant.DataCenterDiscreteTimeControl",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Examples.ChillerPlant.DataCenterContinuousTimeControl",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Examples.VAVReheat.ASHRAE2006",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Examples.VAVReheat.Guideline36",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Experimental.DistrictHeatingCooling.Examples.HeatingCoolingHotWater3Clusters",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.OneFloor_OneZone",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.TwoFloor_TwoZone",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Air.Systems.SingleZone.VAV.Examples.ChillerDXHeatingEconomizer",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})

    models = list()
    models.append(\
        {'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.OneFloor_OneZone",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
    models.append(\
        {'model': "Buildings.Air.Systems.SingleZone.VAV.Examples.ChillerDXHeatingEconomizer",
         "solver": "Cvode",
         "start_time": 0,
         "stop_time": 2*24*3600})
##    models = list()
##    models.append(\
##            {'model': "Buildings.Controls.OBC.CDL.Continuous.Sources.Validation.Constant",
##             "solver": "Cvode",
##             "start_time": 0,
##             "stop_time": 2*24*3600})
    return models
