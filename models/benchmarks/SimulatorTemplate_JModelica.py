import pymodelica
from pymodelica import compile_fmu
from pyfmi import load_fmu

import signal

# Timeout of function adapted from
# https://stackoverflow.com/questions/25027122/break-the-function-after-certain-time
class TimeoutException(Exception):   # Custom exception class
    pass

def timeout_handler(signum, frame):   # Custom signal handler
    raise TimeoutException


# define heap space
pymodelica.environ['JVM_ARGS'] = '{{heap_space}}'

print("*** Compiling {{model}}")
fmu_name = compile_fmu("{{model}}",
                       version="{{fmi_version}}",
                       compiler_log_level = "{{log_file}}")

test_model = load_fmu(fmu_name)


opts = test_model.simulate_options()

if "{{solver}}" == "CVode":
    opts['solver'] = 'CVode' #
    opts['CVode_options']['atol'] = {{tolerance}}
    opts['CVode_options']['rtol'] = {{tolerance}}
elif "{{solver}}" == "Radau":
    opts['solver'] = 'Radau5ODE'
    opts['Radau5ODE_options']['atol'] = {{tolerance}}
    opts['Radau5ODE_options']['rtol'] = {{tolerance}}
else:
    raise ValueError("Unknown solver {} in SimulatorTemplate_JModelica.py".format("{{solver}}"))


# Change the behavior of SIGALRM
signal.signal(signal.SIGALRM, timeout_handler)

# Start the timer. Once time_out seconds are over, a SIGALRM signal is sent.
signal.alarm({{timeout}})

try:
    res = test_model.simulate(\
        start_time={{start_time}},\
        final_time={{stop_time}},\
        options=opts)
except TimeoutException:
    raise RuntimeError("*** Timeout when simulating {{model}} in JModelica.")
else:
    # Reset the alarm
    signal.alarm(0)
