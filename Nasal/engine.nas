
# Manages the engine
#
# Fuel system: based on the Spitfire. Manages primer and negGCutoff
# Hobbs meter


# =============================== DEFINITIONS ===========================================

# set the update period

UPDATE_PERIOD = 0.3;

# =============================== Hobbs meter =======================================

# this property is saved by aircraft.timer
var hobbsmeter_engine = aircraft.timer.new("/sim/time/hobbs/engine[0]", 60, 1);

setlistener("/engines/engine[0]/running", func {
    if ( getprop("/engines/engine[0]/running") or 0 ) {
        hobbsmeter_engine.start();
        print("Hobbs system started");
    } else {
        hobbsmeter_engine.stop();
        print("Hobbs system stopped");
    }
}, 1, 0);

setlistener("/sim/time/hobbs/engine[0]", func {
    # in seconds
    hobbs = getprop("/sim/time/hobbs/engine[0]") or 0.0;
    # This uses minutes, for testing
    #hobbs = hobbs / 60.0;
    # in hours
    hobbs = hobbs / 3600.0;
    # tenths of hour
    setprop("/instrumentation/hobbs-meter/digits0", math.mod(int(hobbs * 10), 10));
    # rest of digits
    setprop("/instrumentation/hobbs-meter/digits1", math.mod(int(hobbs), 10));
    setprop("/instrumentation/hobbs-meter/digits2", math.mod(int(hobbs / 10), 10));
    setprop("/instrumentation/hobbs-meter/digits3", math.mod(int(hobbs / 100), 10));
    setprop("/instrumentation/hobbs-meter/digits4", math.mod(int(hobbs / 1000), 10));
}, 1, 0);

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


# ========== Main loop ======================

var update = func {
    var leftTankUsable  = getprop("/consumables/fuel/tank[0]/selected") and getprop("/consumables/fuel/tank[0]/level-gal_us") > 0;
    var rightTankUsable = getprop("/consumables/fuel/tank[1]/selected") and getprop("/consumables/fuel/tank[1]/level-gal_us") > 0;
    var outOfFuel = !(leftTankUsable or rightTankUsable);

    # We use the mixture to control the engines, so set the mixture
    var usePrimer = getprop("/controls/engines/engine/use-primer") or 0;

    if (outOfFuel) {
        print("Out of fuel!");
        gui.popupTip("Out of fuel!");
    }
    elsif (usePrimer and getprop("/engines/engine/oil-temperature-degf") <= 75) {
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

# controls.startEngine = func(v = 1) {
setlistener("/controls/switches/starter", func {
	if (!getprop("/fdm/jsbsim/complex"))
	    autostart();
    v = getprop("/controls/switches/starter") or 0;
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
}, 1, 1);

var autostart = func {
    if (getprop("/engines/engine/running")) {
		gui.popupTip("Engine already running.", 5);
        return;
    }

    setprop("/controls/engines/engine/magnetos", 3);
    setprop("/controls/engines/engine/throttle", 0.2);
    setprop("/controls/engines/engine/mixture", 1.0);
    setprop("/controls/engines/engine/master-bat", 1.0);
    setprop("/controls/engines/engine/master-alt", 1.0);
    setprop("/controls/switches/master-avionics", 1.0);

    setprop("/controls/lighting/nav-lights", 1);
    setprop("/controls/lighting/strobe", 1);
    setprop("/controls/lighting/beacon", 1);

    setprop("/consumables/fuel/tank[0]/selected", 1);
    setprop("/consumables/fuel/tank[1]/selected", 1);

    # Set the altimeter
    setprop("/instrumentation/altimeter/setting-inhg", getprop("/environment/pressure-sea-level-inhg"));

    #c172p.autoPrime();
    setprop("/controls/engines/engine/primer", 3);
	gui.popupTip("Hold down \"s\" to start the engine. After that, release brakes (press \"B\")", 5);
};

# ================================ Initalize ====================================== 
# Make sure all needed properties are present and accounted 
# for, and that they have sane default values.

# =============== Variables ================

# key 's' calls to this function when it is pressed DOWN even if I overwrite the binding in the -set.xml file!
# fun fact: the key UP event can be overwriten!
controls.startEngine = func(v = 1) {
    setprop("/controls/switches/starter", v);
    # TODO: I still don't know where "/controls/engines/engine/starter" is set to true...
};

setlistener("/sim/signals/fdm-initialized", func {
    var engine_timer = maketimer(UPDATE_PERIOD, func { update(); });
    engine_timer.start();
});

