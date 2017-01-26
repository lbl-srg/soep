
# Import what we can. Primarily envelope and loads.
model = OpenStudio::SOEP::load('small_office.osm');

# The most strict scenario.
# **********  Option A **********

oa_mixer = OpenStudio::SOEP::OutsideAirMixer.new(model);
fan = OpenStudio::SOEP::Fan.new(model);
cooling_coil = OpenStudio::SOEP::DXCoolingCoil.new(model);
heating_coil = OpenStudio::SOEP::HeatingCoil.new(model);
terminal = OpenStudio::SOEP::Diffuser.new(model);
# Should there be duct(s) between components

# Set attributes like this...
fan.setFanEfficiency(0.75);

zone = model.getThermalZones.first

# Fluid Connections
OpenStudio::SOEP::connect(oa_mixer.mixedAirPort(),fan.airInletPort());
OpenStudio::SOEP::connect(fan.airOutletPort(),cooling_coil.airInletPort());
OpenStudio::SOEP::connect(cooling_coil.airOutletPort(),heating_coil.airInletPort());
# Ror simple diffusers you don't even need this component. Just plug the coil outlet into the zone.
OpenStudio::SOEP::connect(heating_coil.airOutletPort(),terminal.airInletPort());
OpenStudio::SOEP::connect(terminal.airOutletPort(),zone.airInletPort());
OpenStudio::SOEP::connect(zone.airOutletPort(),oa_mixer.returnAirPort());

# Control Connections

# Perhaps some pre baked controllers
controller = OpenStudio::SOEP::PackagedSingleZoneController.new();
OpenStudio::SOEP::connect(zone.temperaturePort(),controller.inputTemperaturePort());
OpenStudio::SOEP::connect(controller.fanControlSignalPort(),fan.controlPort());
OpenStudio::SOEP::connect(controller.coolingControlSignalPort(),cooling_coil.controlPort());
OpenStudio::SOEP::connect(controller.heatingControlSignalPort(),heating_coil.controlPort());
OpenStudio::SOEP::connect(controller.oaDamperPositionPort(),oa_mixer.damperPositionPort());

# There should be a mechanism in the API to package a set of components into a new component.
# Here is one way to do it.

# List all of the subcomponents in the new component
std::vector<OpenStudio::SOEP::Component> components;
components.push_back(oa_mixer);
components.push_back(fan);
components.push_back(cooling_coil);
components.push_back(heating_coil);
components.push_back(terminal);
components.push_back(controller);

# Create a map of the internal ports and the name of a newly created "external" port of the new component
std::map<std::string,OpenStudio::SOEP::Port> port_declarations;
port_declarations['airOutletPort'] = terminal.airOutletPort();
port_declarations['returnAirPort'] = oa_mixer.returnAirPort();

# Consider a similar map for attributes....

# Make the new component
rtu = OpenStudio::SOEP::createComponent(components,port_declarations);

# Option A might be too rigid. Consider
#
# **********  Option B **********

# Where "Fan" keys a lookup to a schema or .mo file
# Component being a wrapper around .mo or closely derived schema
fan = OpenStudio::SOEP::Component.new("Fan");
cooling_coil = OpenStudio::SOEP::Component.new("CoolingCoil");
# very similarly
fan = OpenStudio::SOEP::Component.new("/path/to/fan.mo | json | xls | or similar");

fan.setAttribute("FanEfficiency",0.75);
OpenStudio::SOEP::connect(fan.port("AirOutlet"),cooling_coil.port("AirInlet"));
# .... and so on...
 

