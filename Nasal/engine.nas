
# Manages the engine
#
# Fuel system: based on the Spitfire. Manages primer and negGCutoff
# Hobbs meter


# =============================== DEFINITIONS ===========================================

# set the update period

var UPDATE_PERIOD = 0.3;

# =============================== Hobbs meter =======================================

# this property is saved by aircraft.timer
var hobbsmeter_engine_160hp = aircraft.timer.new("/sim/time/hobbs/engine[0]", 60, 1);
var hobbsmeter_engine_180hp = aircraft.timer.new("/sim/time/hobbs/engine[1]", 60, 1);

var init_hobbs_meter = func(index, meter) {
    setlistener("/engines/engine[" ~ index ~ "]/running", func {
        if (getprop("/engines/engine[" ~ index ~ "]/running")) {
            meter.start();
            print("Hobbs system started");
        } else {
            meter.stop();
            print("Hobbs system stopped");
        }
    }, 1, 0);
};

init_hobbs_meter(0, hobbsmeter_engine_160hp);
init_hobbs_meter(1, hobbsmeter_engine_180hp);

var update_hobbs_meter = func {
    # in seconds
    var hobbs_160hp = getprop("/sim/time/hobbs/engine[0]") or 0.0;
    var hobbs_180hp = getprop("/sim/time/hobbs/engine[1]") or 0.0;
    # This uses minutes, for testing
    #hobbs = hobbs / 60.0;
    # in hours
    hobbs = (hobbs_160hp + hobbs_180hp) / 3600.0;
    # tenths of hour
    setprop("/instrumentation/hobbs-meter/digits0", math.mod(int(hobbs * 10), 10));
    # rest of digits
    setprop("/instrumentation/hobbs-meter/digits1", math.mod(int(hobbs), 10));
    setprop("/instrumentation/hobbs-meter/digits2", math.mod(int(hobbs / 10), 10));
    setprop("/instrumentation/hobbs-meter/digits3", math.mod(int(hobbs / 100), 10));
    setprop("/instrumentation/hobbs-meter/digits4", math.mod(int(hobbs / 1000), 10));
};

setlistener("/sim/time/hobbs/engine[0]", update_hobbs_meter, 1, 0);
setlistener("/sim/time/hobbs/engine[1]", update_hobbs_meter, 1, 0);

# ========== primer stuff ======================

# Toggles the state of the primer
var pumpPrimer = func {
    var push = getprop("/controls/engines/engine/primer-lever") or 0;

    if (push) {
        var pump = getprop("/controls/engines/engine/primer") or 0;
        setprop("/controls/engines/engine/primer", pump + 1);
        setprop("/controls/engines/engine/primer-lever", 0);
    }
    else {
        setprop("/controls/engines/engine/primer-lever", 1);
    }
};

# Primes the engine automatically. This function takes several seconds
var autoPrime = func {
    var p = getprop("/controls/engines/engine/primer") or 0;
    if (p < 3) {
        pumpPrimer();
        settimer(autoPrime, 1);
    }
};

# Mixture will be calculated using the primer during 5 seconds AFTER the pilot used the starter
# This prevents the engine to start just after releasing the starter: the propeller will be running
# thanks to the electric starter, but carburator has not yet enough mixture
var primerTimer = maketimer(5, func {
    setprop("/controls/engines/engine/use-primer", 0);
    # Reset the number of times the pilot used the primer only AFTER using the starter
    setprop("/controls/engines/engine/primer", 0);
    print("Primer reset to 0");
    primerTimer.stop();
});

# ========== oil consumption ======================

var oil_consumption = maketimer(1.0, func {
    var oil_level = getprop("/engines/active-engine/oil-level");
    var rpm = getprop("/engines/active-engine/rpm");
    # quadratic formula which outputs 1.0 for input 2300 RPM (cruise value), 0.6 for 700 RPM (idle) and 1.2 for 2700 RPM (max)
    var rpm_factor = 0.00000012 * math.pow(rpm,2) - 0.0001 * rpm + 0.62;
    # consumption rate defined as 1.5 quarter per 10 hours (36000 seconds) at cruise RPM
    var consumption_rate = 1.5 / 36000; 
    var low_oil_pressure_factor = 1.0;
    var low_oil_temperature_factor = 1.0;
    
    if ((getprop("/engines/active-engine/running")) and (getprop("/engines/active-engine/oil_consumption_allowed"))) {
        oil_level = oil_level - consumption_rate * rpm_factor;
        setprop("/engines/active-engine/oil-level", oil_level);        
    }
    
    # If oil gets low, pressure should lower and temperature should rise
    var oil_level_limited = std.min(oil_level, 5.0);

    # Should give 1.0 for oil_level = 5 and 0.1 for oil_level 4.92,
    # which is the min before the engine stops
    low_oil_pressure_factor = 11.25 * oil_level_limited - 55.25;

    # Should give 1.0 for oil_level = 5 and 1.5 for oil_level 4.92
    low_oil_temperature_factor = -6.25 * oil_level_limited + 32.25;

    setprop("/engines/active-engine/low-oil-pressure-factor", low_oil_pressure_factor);
    setprop("/engines/active-engine/low-oil-temperature-factor", low_oil_temperature_factor);

});

# ========== engine coughing ======================

var engine_coughing = maketimer(3.0, func {
    var coughing = getprop("/engines/active-engine/coughing");
    var running = getprop("/engines/active-engine/running");
    if (coughing and running) {
        var delay = 3.0 * rand();
        # engine.xml will force an engine back to killed == 0 if oil level is still all right
        settimer(func {setprop("/engines/active-engine/killed", 1);}, delay);
    };
});

# ========== Main loop ======================

var update = func {
    var leftTankUsable  = getprop("/consumables/fuel/tank[0]/selected") and getprop("/consumables/fuel/tank[0]/level-gal_us") > 0;
    var rightTankUsable = getprop("/consumables/fuel/tank[1]/selected") and getprop("/consumables/fuel/tank[1]/level-gal_us") > 0;
    var outOfFuel = !(leftTankUsable or rightTankUsable);

    # We use the mixture to control the engines, so set the mixture
    var usePrimer = getprop("/controls/engines/engine/use-primer") or 0;

    var engine_running = getprop("/engines/active-engine/running");

    if (outOfFuel and (engine_running or usePrimer)) {
        print("Out of fuel!");
        gui.popupTip("Out of fuel!");
    }
    elsif (usePrimer and !engine_running and getprop("/engines/active-engine/oil-temperature-degf") <= 75) {
        # Mixture is controlled by start conditions
        var primer = getprop("/controls/engines/engine/primer");
        if (!getprop("/fdm/jsbsim/fcs/mixture-primer") and getprop("/controls/switches/starter")) {
            if (primer < 3) {
                print("Use the primer!");
                gui.popupTip("Use the primer!");
            }
            elsif (primer > 6) {
                print("Flooded engine!");
                gui.popupTip("Flooded engine!");
            }
            else {
                print("Check the throttle!");
                gui.popupTip("Check the throttle!");
            }
        }
    }
};

var autostart = func (msg=1) {
    if (getprop("/engines/active-engine/running")) {
		if (msg)
            gui.popupTip("Engine already running", 5);
        return;
    }

    setprop("/controls/switches/magnetos", 3);
    setprop("/controls/engines/current-engine/throttle", 0.2);
    setprop("/controls/engines/current-engine/mixture", 1.0);
    setprop("/controls/flight/elevator-trim", 0.0);
    setprop("/controls/switches/master-bat", 1);
    setprop("/controls/switches/master-alt", 1);
    setprop("/controls/switches/master-avionics", 1);

    setprop("/controls/lighting/nav-lights", 1);
    setprop("/controls/lighting/strobe", 1);
    setprop("/controls/lighting/beacon", 1);

    setprop("/consumables/fuel/tank[0]/selected", 1);
    setprop("/consumables/fuel/tank[1]/selected", 1);

    # Set the altimeter
    setprop("/instrumentation/altimeter/setting-inhg", getprop("/environment/pressure-sea-level-inhg"));

    # Pre-flight inspection
    setprop("/sim/model/c172p/brake-parking", 0);
    setprop("/sim/model/c172p/chock", 0);
    setprop("/sim/model/c172p/pitot-cover", 0);
    setprop("/sim/model/c172p/tiedownL", 0);
    setprop("/sim/model/c172p/tiedownR", 0);
    setprop("/engines/active-engine/oil-level", 7.0);
    setprop("/consumables/fuel/tank[0]/water-contamination", 0.0);
    setprop("/consumables/fuel/tank[1]/water-contamination", 0.0);

    #c172p.autoPrime();
    setprop("/controls/engines/engine[0]/primer-lever", 0);
    setprop("/controls/engines/engine/primer", 3);
	if (msg)
	    gui.popupTip("Hold down \"s\" to start the engine", 5);
};

setlistener("/controls/switches/starter", func {
	if (!getprop("/fdm/jsbsim/complex"))
	    autostart(0);
    var v = getprop("/controls/switches/starter") or 0;
    if (v == 0) {
        print("Starter off");
        # notice the starter will be reset after 5 seconds
        primerTimer.restart(5);
    }
    else {
        print("Starter on");
        setprop("/controls/engines/engine/use-primer", 1);
        if (primerTimer.isRunning) {
            primerTimer.stop();
        }
    }
}, 1, 0);

# ================================ Initalize ====================================== 
# Make sure all needed properties are present and accounted 
# for, and that they have sane default values.

# =============== Variables ================

controls.incThrottle = func {
    var delta = arg[1] * controls.THROTTLE_RATE * getprop("/sim/time/delta-realtime-sec");
    var old_value = getprop("/controls/engines/current-engine/throttle");
    var new_value = std.max(0.0, std.min(old_value + delta, 1.0));
    setprop("/controls/engines/current-engine/throttle", new_value);
};

controls.throttleMouse = func {
    if (!getprop("/devices/status/mice/mouse[0]/button[1]")) {
        return;
    }
    var delta = cmdarg().getNode("offset").getValue() * -4;
    var old_value = getprop("/controls/engines/current-engine/throttle");
    var new_value = std.max(0.0, std.min(old_value + delta, 1.0));
    setprop("/controls/engines/current-engine/throttle", new_value);
};

controls.throttleAxis = func {
    var value = (1 - cmdarg().getNode("setting").getValue()) / 2;
    var new_value = std.max(0.0, std.min(value, 1.0));
    setprop("/controls/engines/current-engine/throttle", new_value);
};

controls.adjMixture = func {
    var delta = arg[0] * controls.THROTTLE_RATE * getprop("/sim/time/delta-realtime-sec");
    var old_value = getprop("/controls/engines/current-engine/mixture");
    var new_value = std.max(0.0, std.min(old_value + delta, 1.0));
    setprop("/controls/engines/current-engine/mixture", new_value);
};

controls.mixtureAxis = func {
    var value = (1 - cmdarg().getNode("setting").getValue()) / 2;
    var new_value = std.max(0.0, std.min(value, 1.0));
    setprop("/controls/engines/current-engine/mixture", new_value);
};

# key 's' calls to this function when it is pressed DOWN even if I overwrite the binding in the -set.xml file!
# fun fact: the key UP event can be overwriten!
controls.startEngine = func(v = 1) {
    if (getprop("/engines/active-engine/running"))
	{
        setprop("/controls/switches/starter", 0);
		return;
	}
	else {
        setprop("/controls/switches/magnetos", 3);
		setprop("/controls/switches/starter", v);
    }
};

setlistener("/sim/signals/fdm-initialized", func {
    var engine_timer = maketimer(UPDATE_PERIOD, func { update(); });
    engine_timer.start();
    oil_consumption.start();
    engine_coughing.start();
});
