##
#  action-sim.nas   Updates various simulated features every frame
##

#   Initialize local variables
var H = nil;
var L = nil;
var phi = nil;
var C = nil;

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
var dhN_ft = props.globals.getNode("gear/gear[0]/compression-ft", 1);
var dhR_ft = props.globals.getNode("gear/gear[2]/compression-ft", 1);
var dhL_ft = props.globals.getNode("gear/gear[1]/compression-ft", 1);
var propGear0 = props.globals.getNode("gear/gear[0]", 1);
var propGear1 = props.globals.getNode("gear/gear[1]", 1);
var propGear2 = props.globals.getNode("gear/gear[2]", 1);

# Associate Nodes

var cdiNAV0 = propNav0.getNode("heading-needle-deflection", 1);
var cdiNAV1 = propNav1.getNode("heading-needle-deflection", 1);
var gsNAV0  = propNav0.getNode("gs-needle-deflection-norm", 1);
var gsNAV1  = propNav1.getNode("gs-needle-deflection-norm", 1);
var filteredCDI0 = propNav0.getNode("filtered-cdiNAV0-deflection", 1);
var filteredCDI1 = propNav1.getNode("filtered-cdiNAV1-deflection", 1);
var filteredGS0  = propNav0.getNode("filtered-gsNAV0-deflection", 1);
var filteredGS1  = propNav1.getNode("filtered-gsNAV1-deflection", 1);
var nose_link_rot = propGear0.getNode("compression-rotation-deg", 1);
var left_main_rot = propGear1.getNode("compression-rotation-deg", 1);
var right_main_rot = propGear2.getNode("compression-rotation-deg", 1);

var init_actions = func {
    filteredCDI0.setDoubleValue(0.0);
    filteredCDI1.setDoubleValue(0.0);
    filteredGS0.setDoubleValue(0.0);
    filteredGS1.setDoubleValue(0.0);

    # Make sure that init_actions is called when the sim is reset
    setlistener("sim/signals/reset", init_actions);

    # Request that the update fuction be called next frame
    settimer(update_actions, 0);
}


var update_actions = func {

#  Note:  R2D and FT2M  are unit conversion factors defined in $FG_ROOT/Nasal/globals.nas
#         R2D (radians to degrees) FT2M (feet to meters)

##
#  Compute the scissor link angles due to nose strut compression
##

    var theta = 0.0;

    # Compute the angle the nose gear scissor rotates due to nose gear strut compression

    H = 0.240626;  # Nose gear oleo strut extended length in m
    L = 0.194716;  # Nose gear scissor length in m
    phi = 0.666058;
    C = dhN_ft.getValue()*FT2M;
    if (C > 0.0) {
      theta = scissor_angle(H,C,L,phi)*R2D;
    }

#  Compute compression induced main gear rotations
#
#  constants
   var R_m = 0.919679;
   var h0 = 0.63872;
   var theta0_rad = 0.803068;

#  Right main
   var delta_h = dhR_ft.getValue()*FT2M;
   var right_alpha_deg = ( math.acos( (h0 - delta_h)/R_m ) - theta0_rad )*R2D;


#  Left main
   var delta_h = dhL_ft.getValue()*FT2M;
   var left_alpha_deg = ( math.acos( (h0 - delta_h)/R_m ) - theta0_rad )*R2D;

# Outputs
    instrumentLightFactor.setDoubleValue(instrumentsNorm.getValue());
    panelLights.setDoubleValue(instrumentsNorm.getValue());

    filteredCDI0.setDoubleValue( cdi0_lowpass.filter(cdiNAV0.getValue()));
    filteredCDI1.setDoubleValue(cdi1_lowpass.filter(cdiNAV1.getValue()));
    filteredGS0.setDoubleValue(gs0_lowpass.filter(gsNAV0.getValue()));
    filteredGS1.setDoubleValue(gs1_lowpass.filter(gsNAV1.getValue()));
    nose_link_rot.setDoubleValue(theta);
    right_main_rot.setDoubleValue(right_alpha_deg);
    left_main_rot.setDoubleValue(left_alpha_deg);

    settimer(update_actions, 0);
}


var scissor_angle = func(H,C,L,phi) {
    var a = (H - C)/2/L;
    # Use 2 iterates of Newton's method and 4th order Taylor series to
    # approximate theta where sin(phi - theta) = a
    var theta = phi - 2*a/3 - a/3/(1-a*a/2);
    return theta;
}

# Setup listener call to start update loop once the fdm is initialized
#
setlistener("sim/signals/fdm-initialized", init_actions);

#
# Listeners to tie the /consumables/fuels/tank[]/selected to
# /fdm/jsbsim/propulsion/tank[]/priority

setlistener("consumables/fuel/tank[0]/selected", func(selected) {
  setprop("/fdm/jsbsim/propulsion/tank[0]/priority", selected.getBoolValue() ? 1 : 0);
});

setlistener("consumables/fuel/tank[1]/selected", func(selected) {
  setprop("/fdm/jsbsim/propulsion/tank[1]/priority", selected.getBoolValue() ? 1 : 0);
});

