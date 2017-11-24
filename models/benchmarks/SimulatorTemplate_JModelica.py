import pymodelica
from pymodelica import compile_fmu
from pyfmi import load_fmu


# define heap space
pymodelica.environ['JVM_ARGS'] = '{{heap_space}}'

fmu_name = compile_fmu("{{model}}",
                       version={{fmi_version}},
                       compiler_log_level = "{{log_file}}")
test_model = load_fmu(fmu_name)
opts = test_model.simulate_options()
# options specific for CVode: relative tolerance
opts['CVode_options']['rtol'] = 1.0e-6
opts['CVode_options']['rtol'] = 1.0e-6

res = test_model.simulate(final_time={{stop_time}}, options=opts)
