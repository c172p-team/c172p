##
#  action-sim.nas   Updates various simulated features every frame
##

# set up filters for these actions

var cdi0_lowpass = aircraft.lowpass.new(0.5);
var cdi1_lowpass = aircraft.lowpass.new(0.5);
var gs0_lowpass = aircraft.lowpass.new(0.5);
var gs1_lowpass = aircraft.lowpass.new(0.5);

# Properties

var propNav0 = props.globals.getNode("instrumentation/nav[0]", 1);
var propNav1 = props.globals.getNode("instrumentation/nav[1]", 1);
var navLights = props.globals.getNode("controls/lighting/nav-lights", 1);
var instrumentsNorm = props.globals.getNode("controls/lighting/instruments-norm", 1);
var instrumentLightFactor = props.globals.getNode("sim/model/material/instruments/factor", 1);
var panelLights = props.globals.getNode("controls/lighting/panel-norm", 1);

# Associate Nodes

var cdiNAV0 = propNav0.getNode("heading-needle-deflection", 1);
var cdiNAV1 = propNav1.getNode("heading-needle-deflection", 1);
var gsNAV0  = propNav0.getNode("gs-needle-deflection-norm", 1);
var gsNAV1  = propNav1.getNode("gs-needle-deflection-norm", 1);
var filteredCDI0 = propNav0.getNode("filtered-cdiNAV0-deflection", 1);
var filteredCDI1 = propNav1.getNode("filtered-cdiNAV1-deflection", 1);
var filteredGS0  = propNav0.getNode("filtered-gsNAV0-deflection", 1);
var filteredGS1  = propNav1.getNode("filtered-gsNAV1-deflection", 1);


var init_actions = func {
    filteredCDI0.setDoubleValue(0.0);
    filteredCDI1.setDoubleValue(0.0);
    filteredGS0.setDoubleValue(0.0);
    filteredGS1.setDoubleValue(0.0);

    # Request that the update fuction be called next frame
    settimer(update_actions, 0);
}


var update_actions = func {

    if ( navLights.getValue() ) {
       instrumentLightFactor.setDoubleValue(1.0);
       #  Used double in case one wants to later add the ability to dim the instrument lights
       instrumentsNorm.setDoubleValue(1.0);
       panelLights.setDoubleValue(1.0);
    } else {
       instrumentLightFactor.setDoubleValue(0.0);
       instrumentsNorm.setDoubleValue(0.0);
       panelLights.setDoubleValue(0.0);       
    }

  # outputs
    filteredCDI0.setDoubleValue( cdi0_lowpass.filter(cdiNAV0.getValue()));
    filteredCDI1.setDoubleValue(cdi1_lowpass.filter(cdiNAV1.getValue()));
    filteredGS0.setDoubleValue(gs0_lowpass.filter(gsNAV0.getValue()));
    filteredGS1.setDoubleValue(gs1_lowpass.filter(gsNAV1.getValue()));

    settimer(update_actions, 0);
}


# Setup listener call to start update loop once the fdm is initialized
# 
setlistener("sim/signals/fdm-initialized", init_actions);  



