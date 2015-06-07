# strobes ===========================================================
var strobe_switch = props.globals.getNode("/systems/electrical/outputs/strobe", 1);
aircraft.light.new("sim/model/c172p/lighting/strobes", [0.015, 1.985], strobe_switch);

# beacons ===========================================================
var beacon_switch = props.globals.getNode("/systems/electrical/outputs/beacon", 1);
aircraft.light.new("sim/model/c172p/lighting/beacon-top", [0.10, 0.90], beacon_switch);
