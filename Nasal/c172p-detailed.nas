##########################################
# Ground Detection
##########################################

# Do terrain modelling ourselves.
#setprop("sim/fdm/surface/override-level", 1);

var terrain_survol_loop = func {
  var lat = getprop("/position/latitude-deg");
  var lon = getprop("/position/longitude-deg");

  var info = geodinfo(lat, lon);
  if (info != nil) {
    if (info[1] != nil){
      if (info[1].solid !=nil)
        setprop("/environment/terrain-type",info[1].solid);
      if (info[1].load_resistance !=nil)
        setprop("/environment/terrain-load-resistance",info[1].load_resistance);
      if (info[1].friction_factor !=nil)
        setprop("/environment/terrain-friction-factor",info[1].friction_factor);
      if (info[1].bumpiness !=nil)
        setprop("/environment/terrain-bumpiness",info[1].bumpiness);
      if (info[1].rolling_friction !=nil)
        setprop("/environment/terrain-rolling-friction",info[1].rolling_friction);
      if (info[1].names !=nil)
        setprop("/environment/terrain-names",info[1].names[0]);
    }         
  }else{
    setprop("/environment/terrain",1);
    setprop("/environment/terrain-load-resistance",1e+30);
    setprop("/environment/terrain-friction-factor",1.05);
    setprop("/environment/terrain-bumpiness",0);
    setprop("/environment/terrain-rolling-friction",0.02);
  }

  if(!getprop("sim/freeze/replay-state") and !getprop("/environment/terrain-type") and getprop("/position/altitude-agl-ft") < 3.0){
    setprop("sim/messages/copilot", "You are on water !");
    setprop("sim/freeze/clock", 1);
    setprop("sim/freeze/master", 1);
    setprop("sim/crashed", 1);
  }

}

###########################################
# use this loop for any system that requires
# monitoring and possesses no loop of its own
############################################
var check_systems_status = func {
	
	#check for volume shadow version and ALS requirements 
	var p = getprop("/sim/rendering/shadow-volume");
	if (p) {
		if (!c172p.check_eligibility()) {
			setprop("/sim/rendering/shadow-volume", 0);
		} 
	}
	
	#check for internal shadow version and ALS requirements 
	var p = getprop("/sim/rendering/internal-shadow");
	if (p) {
		if (!c172p.check_is_eligibility()) {
			setprop("/sim/rendering/internal-shadow", 0);
		} 
	}
}

############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
global_system_loop = func{

  # terrain_survol_loop was incorporated during damage system creation. 
  # "Unimplemented" crash detection system requires this self terrain modelling (I think)
  # If we end up not using it, then we can remove it.
  #terrain_survol_loop();
  c172p.physics_loop();
  c172p.weather_effects_loop();
  check_systems_status();
}

##########################################
# SetListerner must be at the end of this file
##########################################
#setlistener("/sim/signals/fdm-initialized", func{
#  setprop("/environment/terrain-type",1);
#  setprop("/environment/terrain-load-resistance",1e+30);
#  setprop("/environment/terrain-friction-factor",1.05);
#  setprop("/environment/terrain-bumpiness",0);
#  setprop("/environment/terrain-rolling-friction",0.02);
#});

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{
    # These properties are aliased to MP properties in /sim/multiplay/generic/.
    # This aliasing seems to work in both ways, because the two properties below
    # appear to receive the random values from the MP properties during initialization.
    # Therefore, override these random values with the proper values we want.
    props.globals.getNode("/fdm/jsbsim/crash", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/contact/unit[4]/broken", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/contact/unit[5]/broken", 0).setBoolValue(0);
 
    var c172_timer = maketimer(0.25, func{global_system_loop()});
    c172_timer.start();
});
