import pymodelica
from pymodelica import compile_fmu
from pyfmi import load_fmu


# define heap space
pymodelica.environ['JVM_ARGS'] = '{{heap_space}}'

fmu_name = compile_fmu("{{model}}", "{{model_name}}.mo",
                       version={{fmi_version}},
                       compiler_options={'extra_lib_dirs':["{{sim_lib_path}}"]},
                       compiler_log_level = "{{log_file}}")
test_model = load_fmu(fmu_name)
endTime = {{end_time}}
res = test_model.simulate(final_time=endTime)