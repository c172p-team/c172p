# Strobe lights at the wing tips
var strobe_switch = props.globals.getNode("/systems/electrical/outputs/strobe", 1);
aircraft.light.new("/sim/model/c172p/lighting/strobes", [0.015, 1.985], strobe_switch);

# Beacon light on top of tail
var beacon_switch = props.globals.getNode("/systems/electrical/outputs/beacon", 1);
aircraft.light.new("/sim/model/c172p/lighting/beacon-top", [0.10, 0.90], beacon_switch);

# Navigation lights
var nav_switch = props.globals.getNode("/systems/electrical/outputs/nav-lights", 1);
aircraft.light.new("/sim/model/c172p/lighting/navigation", [1.0], nav_switch);

# Control both panel and instrument light intensity with one property
var instrumentsNorm = props.globals.getNode("controls/lighting/instruments-norm", 1);
var instrumentLightFactor = props.globals.getNode("sim/model/material/instruments/factor", 1);
var panelLights = props.globals.getNode("controls/lighting/panel-norm", 1);

var update_intensity = func {
    instrumentLightFactor.setDoubleValue(instrumentsNorm.getValue());
    panelLights.setDoubleValue(instrumentsNorm.getValue());
};
var intensity_updater = maketimer(0.1, update_intensity);

setlistener("/sim/signals/fdm-initialized", func {
    intensity_updater.start();
});
