import os
from jinja2 import Template
import subprocess as sp
from io import open
script_path = os.path.dirname(os.path.realpath(__file__))
MOS_TEMPLATE = """translateModelFMU("{{model_name}}", false, "", "2", "me", false);
exit();
"""

def compileFMUDymola():

    print "-------------- starting Dymola"

    #class_names = [  "Annex60.Utilities.Math.SmoothMaxInline"   ]
    class_names = [  "Specific.Events.BouncingBall", "Specific.Events.OnOffController", "Specific.Events.OnOffController1",\
                     "Specific.Events.StateEvent1", "Specific.Events.StateEvent2", \
                     "Specific.Events.StateEvent3", "Specific.Events.StateEvent4",  \
                     "Specific.Events.StateEvent5", "Specific.Events.StateEvent6", \
                     "Specific.Events.StateEventWithIf1", "Specific.Events.StateEventWithIf2", \
                     "Specific.Events.StateTimeEventWithIf", "Specific.Events.ZCBoolean1", \
                     "Specific.Events.ZCBoolean2", "Generic.Achilles", \
                     "Generic.CoupledSystem", "Generic.ExponentialDecay", \
                     "Generic.Identity", "Generic.InputFunction", "Generic.Quadratic"]

    # Set the Modelica path to point to the Simulator Library
    current_library_path = os.environ.get('MODELICAPATH')
    if (current_library_path is None):
        os.environ['MODELICAPATH'] = script_path
    else:
        os.environ['MODELICAPATH'] = script_path\
        + os.pathsep + current_library_path

    print ("Modelicapath is " + str(os.environ['MODELICAPATH']))
    
    for class_name in class_names:

        print "=================================================================="
        class_name='QSS.'+class_name
        print "=== Compiling {}".format(class_name)
        template = Template(MOS_TEMPLATE)
        output_res = template.render(model_name=class_name)

        path_mos = os.path.join(class_name + '.mos')

        with open(path_mos, mode="w", encoding="utf-8") as mos_fil:
            mos_fil.write(output_res)
        mos_fil.close()
        retStr=sp.check_output(["dymola", path_mos])
        os.remove(path_mos)
        print "========= Finished compilation of {}".format(class_name)


if __name__=="__main__":
    compileFMUDymola()
