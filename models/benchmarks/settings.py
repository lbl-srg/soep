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

def _set_defaults(models, key_word, value):
    for model in models:
        if not model.has_key(key_word):
            model[key_word] = value


def get_models():
    models = list()
    models.append({'model': "Buildings.Examples.HydronicHeating.TwoRoomsWithStorage"})
    models.append({'model': "Buildings.Examples.DualFanDualDuct.ClosedLoop",
                   "solver": "Radau"})
    models.append({'model': "Buildings.Examples.ChillerPlant.DataCenterDiscreteTimeControl"})
    models.append({'model': "Buildings.Examples.ChillerPlant.DataCenterContinuousTimeControl"})
    models.append({'model': "Buildings.Examples.VAVReheat.ASHRAE2006"})
    models.append({'model': "Buildings.Examples.VAVReheat.Guideline36"})
    models.append({'model': "Buildings.Experimental.DistrictHeatingCooling.Examples.HeatingCoolingHotWater3Clusters"})
    models.append({'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.OneFloor_OneZone"})
    models.append({'model': "Buildings.Examples.ScalableBenchmarks.BuildingVAV.Examples.TwoFloor_TwoZone"})
    models.append({'model': "Buildings.Air.Systems.SingleZone.VAV.Examples.ChillerDXHeatingEconomizer"})

##    models = list()
##    models.append({'model': "Buildings.Controls.OBC.CDL.Continuous.Sources.Validation.Ramp"})

##    models = list()
##    models.append({'model': "Buildings.Controls.OBC.CDL.Continuous.Sources.Validation.Ramp"})
##    models.append({'model': "Buildings.Controls.Continuous.Examples.LimPID"})

    # Set defaults
    _set_defaults(models, 'tolerance', 1E-7)
    _set_defaults(models, 'solver', 'CVode')
    _set_defaults(models, 'start_time', 0)
    _set_defaults(models, 'stop_time', 2*24*3600)

    return models
