##########################################
# Brakes
##########################################

controls.applyBrakes = func (v, which = 0) {
    if (which <= 0 and !getprop("/fdm/jsbsim/gear/unit[1]/broken")) {
        interpolate("/controls/gear/brake-left", v, controls.fullBrakeTime);
    }
    if (which >= 0 and !getprop("/fdm/jsbsim/gear/unit[2]/broken")) {
        interpolate("/controls/gear/brake-right", v, controls.fullBrakeTime);
    }
};

controls.applyParkingBrake = func (v) {
    if (!v) {
        return;
    }

    var left_broken = getprop("/fdm/jsbsim/gear/unit[1]/broken");
    var right_broken =getprop("/fdm/jsbsim/gear/unit[2]/broken");
    var p = "/controls/gear/brake-parking";
    var orig_p = getprop(p);

    # We assume one non-broken gear is enough to apply the parking brake
    if (orig_p or !left_broken or !right_broken) {
        setprop(p, var i = !orig_p);
        return i;
    }
    return orig_p;
};

##########################################
# Click Sounds
##########################################

var click = func (name, timeout=0.1, delay=0) {
    var sound_prop = "/sim/model/c172p/sound/click-" ~ name;

    settimer(func {
        # Play the sound
        setprop(sound_prop, 1);

        # Reset the property after 0.2 seconds so that the sound can be
        # played again.
        settimer(func {
            setprop(sound_prop, 0);
        }, timeout);
    }, delay);
};

##########################################
# Thunder Sound
##########################################

var thunder = func (name) {
    var thunderCalls=0;
    var lightning_pos_x = getprop("/environment/lightning/lightning-pos-x");
    var lightning_pos_y = getprop("/environment/lightning/lightning-pos-y");
    var lightning_distance = math.sqrt(math.pow(lightning_pos_x,2) + math.pow(lightning_pos_y,2));
    var delay_seconds = lightning_distance / 340.29;
    var thunder1 = getprop("/sim/model/c172p/sound/click-thunder1");
    var thunder2 = getprop("/sim/model/c172p/sound/click-thunder2");
    var thunder3 = getprop("/sim/model/c172p/sound/click-thunder3");

    if (delay_seconds < 0) delay_seconds = 0;
    if (delay_seconds > 50) delay_seconds = 50;
    var lightning_distance_norm = 1+(1-(delay_seconds/50));

    if (!thunder1)
    {
	    thunderCalls=1;
		setprop("/sim/model/c172p/sound/lightning/dist1", lightning_distance_norm);
    }
    else if (!thunder2)
    {
        thunderCalls=2;
        setprop("/sim/model/c172p/sound/lightning/dist2", lightning_distance_norm);
    }
    else if (!thunder3)
    {
        thunderCalls=3;
		setprop("/sim/model/c172p/sound/lightning/dist3", lightning_distance_norm);
    } else return;

    # Play the sound
    click("thunder"~thunderCalls, 9.0, delay_seconds);
};

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

var reset_system = func {

	if (getprop("/fdm/jsbsim/running"))
	{
		c172p.autostart(0);
	    setprop("/controls/switches/starter", 1);
		var engineRunning = setlistener("/engines/active-engine/running", func{
			if (getprop("/engines/active-engine/running"))
			{
				setprop("/controls/switches/starter", 0);
				removelistener(engineRunning);
			}
		});
	}

    # These properties are aliased to MP properties in /sim/multiplay/generic/.
    # This aliasing seems to work in both ways, because the two properties below
    # appear to receive the random values from the MP properties during initialization.
    # Therefore, override these random values with the proper values we want.
    props.globals.getNode("/fdm/jsbsim/crash", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/gear/unit[0]/broken", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/gear/unit[1]/broken", 0).setBoolValue(0);
    props.globals.getNode("/fdm/jsbsim/gear/unit[2]/broken", 0).setBoolValue(0);
	props.globals.getNode("/fdm/jsbsim/pontoon-damage/left-pontoon", 0).setIntValue(0);
	props.globals.getNode("/fdm/jsbsim/pontoon-damage/right-pontoon", 0).setIntValue(0);

	setprop("/engines/active-engine/killed", 0);
	setprop("/fdm/jsbsim/contact/unit[4]/z-position", 50);
	setprop("/fdm/jsbsim/contact/unit[5]/z-position", 50);

    # Note: these separate flags exist because PUI's <radio> element
    #       only accepts booleans.
	var p = getprop("fdm/jsbsim/bushkit");
	setprop("/sim/model/c172p/bushkit_flag_0",0);
	setprop("/sim/model/c172p/bushkit_flag_1",0);
	setprop("/sim/model/c172p/bushkit_flag_2",0);
	setprop("/sim/model/c172p/bushkit_flag_3",0);
	setprop("/sim/model/c172p/bushkit_flag_4",0);
	if (p == 0) { setprop("/sim/model/c172p/bushkit_flag_0",1); }
	if (p == 1) { setprop("/sim/model/c172p/bushkit_flag_1",1); }
	if (p == 2) { setprop("/sim/model/c172p/bushkit_flag_2",1); }
	if (p == 3) { setprop("/sim/model/c172p/bushkit_flag_3",1); }
	if (p == 4) { setprop("/sim/model/c172p/bushkit_flag_4",1); }
}

############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
var global_system_loop = func{
  c172p.physics_loop();
  c172p.weather_effects_loop();
}

##########################################
# SetListerner must be at the end of this file
##########################################
var set_limits = func (node) {
    if (node.getValue() == 1) {
        var limits = props.globals.getNode("/limits/mass-and-balance-180hp");
    }
    else {
        var limits = props.globals.getNode("/limits/mass-and-balance-160hp");
    }
    var ac_limits = props.globals.getNode("/limits/mass-and-balance");

    # Get the mass limits of the current engine
    var ramp_mass = limits.getNode("maximum-ramp-mass-lbs");
    var takeoff_mass = limits.getNode("maximum-takeoff-mass-lbs");
    var landing_mass = limits.getNode("maximum-landing-mass-lbs");

    # Get the actual mass limit nodes of the aircraft
    var ac_ramp_mass = ac_limits.getNode("maximum-ramp-mass-lbs");
    var ac_takeoff_mass = ac_limits.getNode("maximum-takeoff-mass-lbs");
    var ac_landing_mass = ac_limits.getNode("maximum-landing-mass-lbs");

    # Set the mass limits of the aircraft
    ac_ramp_mass.unalias();
    ac_takeoff_mass.unalias();
    ac_landing_mass.unalias();

    ac_ramp_mass.alias(ramp_mass);
    ac_takeoff_mass.alias(takeoff_mass);
    ac_landing_mass.alias(landing_mass);
};

setlistener("/controls/engines/active-engine", func (node) {
    # Set new mass limits for Fuel and Payload Settings dialog
    set_limits(node);

    # Emit a sound because the engine has been replaced
    click("engine-repair", 6.0);
}, 0, 0);

var update_pax = func {
    var state = 0;
    state = bits.switch(state, 0, getprop("pax/co-pilot/present"));
    state = bits.switch(state, 1, getprop("pax/left-passenger/present"));
    state = bits.switch(state, 2, getprop("pax/right-passenger/present"));
    state = bits.switch(state, 3, getprop("pax/pilot/present"));
    setprop("/payload/pax-state", state);
};

setlistener("/pax/co-pilot/present", update_pax, 0, 0);
setlistener("/pax/left-passenger/present", update_pax, 0, 0);
setlistener("/pax/right-passenger/present", update_pax, 0, 0);
setlistener("/pax/pilot/present", update_pax, 0, 0);
update_pax();

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{
    # Use Nasal to make some properties persistent. <aircraft-data> does
    # not work reliably.
    aircraft.data.add("/sim/model/c172p/immat-on-panel");
    aircraft.data.load();

    # Initialize mass limits
    set_limits(props.globals.getNode("/controls/engines/active-engine"));

    # Set alt alert of KAP 140 autopilot to 20_000 ft to get rid of annoying beep
    setlistener("/autopilot/KAP140/settings/target-alt-ft", func (n) {
        if (n.getValue() == 0) {
            kap140.altPreselect = 20000;
            setprop("/autopilot/KAP140/settings/target-alt-ft", kap140.altPreselect);
        }
    });
    
    # Listening for lightning strikes
    setlistener("/environment/lightning/lightning-pos-x", thunder);

    reset_system();
    var c172_timer = maketimer(0.25, func{global_system_loop()});
    c172_timer.start();
});
