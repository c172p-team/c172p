
# Manages the engine
#
# Fuel system: based on the Spitfire. Manages primer and negGCutoff
# Hobbs meter


# =============================== DEFINITIONS ===========================================

# set the update period

UPDATE_PERIOD = 0.3;

# set the timer for the selected function

registerTimer = func {

    settimer(arg[0], UPDATE_PERIOD);

} # end function 

var init_double_prop = func(node, prop, val) {
    if (node.getNode(prop) != nil) val = num(node.getNode(prop).getValue());
    if(val == nil) val = 0;
    node.getNode(prop, 1).setDoubleValue(val);
}

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
    # in minutes
    # TODO: change to hours for the final version
    hobbs = hobbs / 60.0;
    # tenths of hour
    setprop("/instrumentation/hobbs-meter/digits0", math.mod(int(hobbs * 10), 10));
    # rest of digits
    setprop("/instrumentation/hobbs-meter/digits1", math.mod(int(hobbs), 10));
    setprop("/instrumentation/hobbs-meter/digits2", math.mod(int(hobbs / 10), 10));
    setprop("/instrumentation/hobbs-meter/digits3", math.mod(int(hobbs / 100), 10));
    setprop("/instrumentation/hobbs-meter/digits4", math.mod(int(hobbs / 1000), 10));
}, 1, 0);

# =============================== -ve g cutoff stuff =========================================

# Manages mixture depending on g force
var negGCutoff = func {

    var g = gcurrent.getValue();
    var grav = gravity.getValue();
    
    if ( g != nil and grav != nil ) {
        g = -g / grav;
    } else {
        # we are not able to compute gravity, just assume 1
        g = 1;
    }
    
    mixture = getprop("/controls/engines/engine/mixture-lever");

    if (g > 0.75) {
        return  mixture;                    # mixture set by lever
    }
    elsif (g <= 0.75 and g >= 0)  {            # mixture set by - ve g
        mixture = g * 4/3;
    }
    else  {                                    # mixture set by - ve g
        mixture = 0;
    }

    return mixture;

} # end function 


# ========== primer stuff ======================

# Toggles the state of the primer
var pumpPrimer = func {
    var push = getprop("/controls/engines/engine/primer-lever") or 0;
    var pump = getprop("/controls/engines/engine/primer") or 0;

    if (push) {
        pump += 1;
        setprop("/controls/engines/engine/primer", pump);
        setprop("/controls/engines/engine/primer-lever", 0);
    } else {
        setprop("/controls/engines/engine/primer-lever", 1);
    }

}

# Returns the mixture (0, 1).
# Warm engine, the mixture is selected using the mixture lever
# Cold engine, if the engine was primed enough times, mixture = 1. If not, mixture = 0
var primerMixture = func {
    var mixture = 0;
    var primer = arg[0];
    var throttle = getprop("/controls/engines/engine/throttle") or 0;
    
    # warm engine: just use mixture
    if (getprop("/engines/engine/oil-temperature-degf") > 75 ) {
        return negGCutoff();
    }
    
    if (primer >2 and primer <7 and throttle > 0.1 and throttle < 0.5) {
        mixture = 1;
        print("Primer: ", primer);
    } elsif ( getprop("/controls/switches/starter", 0) == 1 ) {
        if (primer <3 ) {
            print("Use the primer!");
            gui.popupTip("Use the primer!");
        } elsif ( primer >6 ) {
            print("Flooded engine!");
            gui.popupTip("Flooded engine!");
        } else {
            print("Check the throttle!");
            gui.popupTip("Check the throttle!");
        }
    }
    
    return mixture;
      
} # end function

# Primes the engine automatically. This function takes several seconds
var autoPrime = func {
  var p = getprop("/controls/engines/engine/primer") or 0;
    if ( p < 3 ) {
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
} );


# ========== Main loop ======================

var update = func {
    if (fuel_freeze) {
        return;
    }

    var consumed_fuel = 0;
    foreach (var e; engines) {
        var fuel = e.getNode("fuel-consumed-lbs");
        consumed_fuel += fuel.getValue();
        fuel.setDoubleValue(0);
    }

#    print("running update");

    # Build a list of available tanks. An available tank is both selected and has 
    # fuel remaining.  Note the filtering for "zero-capacity" tanks.  The FlightGear
    # code likes to define zombie tanks that have no meaning to the FDM,
    # so we have to take measures to ignore them here. 
    var availableTanks = [];
    var cap = 0.01; #  division by 0 issue
    var contents = 0;
    var selected = 0;

    foreach(t; alltanks) {

        if(t.getNode("capacity-gal_us") != nil) {
            cap = t.getNode("capacity-gal_us", 1).getValue();
            contents = t.getNode("level-gal_us", 1).getValue();
            selected = t.getNode("selected", 1).getBoolValue();

            if( cap > 0.01 and contents > 0 and selected ) append(availableTanks, t);

        }

    }

    # Subtract fuel from tanks, set auxilliary properties.  Set out-of-fuel
    # when all available tanks are dry.
    var outOfFuel = 0;
    var lbs = 0;
    var ppg = 0;
    var gals = 0;

    if(size(availableTanks) == 0) {
        outOfFuel = 1;
    } else {
        fuelPerTank = consumed_fuel / size(availableTanks);

        foreach(t; availableTanks) {
            ppg = t.getNode("density-ppg").getValue();
            lbs = t.getNode("level-gal_us").getValue() * ppg;
            lbs = lbs - fuelPerTank;

            if(lbs <= 0) 
                {
                lbs = 0; 

                if(t.getNode("kill-when-empty", 1).getBoolValue()) outOfFuel = 1;

                } #endif

            gals = lbs / ppg;
            t.getNode("level-gal_us").setDoubleValue(gals);
            t.getNode("level-lbs").setDoubleValue(lbs);
        }
    }
    
    # Total fuel properties
    foreach(t; alltanks) {
        cap  += t.getNode("capacity-gal_us").getValue();
        gals += t.getNode("level-gal_us").getValue();
        lbs  += t.getNode("level-lbs").getValue();
    }

    setprop("/consumables/fuel/total-fuel-gals", gals);
    setprop("/consumables/fuel/total-fuel-lbs", lbs);
    setprop("/consumables/fuel/total-fuel-norm", gals/cap);

    # we use the mixture to control the engines, so set the mixture
    var usePrimer = getprop("/controls/engines/engine/use-primer") or 0;
    var mixture = 0;

    if ( outOfFuel ) {
        mixture = 0;
        print("Out of fuel!");
        gui.popupTip("Out of fuel!");
     } elsif( usePrimer == 1 ) {
         # mixture is controlled by start conditions
        primer = getprop("/controls/engines/engine/primer") or 0;
        mixture = ( primerMixture(primer) );
#        print("Primer controls fuel");
    } else  {
        # mixture is controlled by G force and mixture lever
        mixture = ( negGCutoff() );
#        print("G-force controls fuel");
    }

# set the mixture on the engines
    foreach(e; enginecontrols) {
        e.getNode("mixture").setDoubleValue(mixture);
    }
#    print("Mixture: ", mixture);

} #end func update

var loop = func {
    update();
    registerTimer(loop);
}


# controls.startEngine = func(v = 1) {
setlistener("/controls/switches/starter", func {
    v = getprop("/controls/switches/starter") or 0;
    if (v == 0) {
    print("Starter off");
    # notice the starter will be reset after 5 seconds
    primerTimer.restart(5);
    } else {
    print("Starter on");
    setprop("/controls/engines/engine/use-primer", 1);
    if ( primerTimer.isRunning ) {
      primerTimer.stop();
    }
    }
}, 1, 1);

# ================================ Initalize ====================================== 
# Make sure all needed properties are present and accounted 
# for, and that they have sane default values.

# =============== Variables ================

var alltanks = [];
var engines = [];
var enginecontrols = [];
var fuel_freeze = nil;
var total_gals = nil;
var total_lbs = nil;
var total_norm = nil;
var gcurrent = nil;
var gravity = nil;

# key 's' calls to this function when it is pressed DOWN even if I overwrite the binding in the -set.xml file!
# fun fact: the key UP event can be overwriten!
controls.startEngine = func(v = 1) {
  setprop("/controls/switches/starter", v);
  # TODO: I still don't know where "/controls/engines/engine/starter" is set to true...
}

var L = setlistener("/sim/signals/fdm-initialized", func {
     gcurrent = props.globals.getNode("accelerations/pilot/z-accel-fps_sec", 1);
     gravity = props.globals.getNode("fdm/jsbsim/accelerations/gravity-ft_sec2", 1);
    
    removelistener(L);
    print( "Initializing Fuel System ..." );
    setlistener("/sim/freeze/fuel", func(n) { fuel_freeze = n.getBoolValue() }, 1);
    
    total_gals = props.globals.getNode("/consumables/fuel/total-fuel-gals", 1);
    total_lbs = props.globals.getNode("/consumables/fuel/total-fuel-lbs", 1);
    total_norm = props.globals.getNode("/consumables/fuel/total-fuel-norm", 1);

    enginecontrols = props.globals.getNode("/controls/engines").getChildren("engine");
    engines = props.globals.getNode("engines", 1).getChildren("engine");
    foreach (var e; engines) {
        e.getNode("fuel-consumed-lbs", 1).setDoubleValue(0);
        e.getNode("out-of-fuel", 1).setBoolValue(0);
        e.getNode("primer", 1).setDoubleValue(0);
    }

    foreach (var t; props.globals.getNode("/consumables/fuel", 1).getChildren("tank")) {

        if (t.getNode("name") == nil) {
#            print("name skipping", t.getNode("name",1).getValue());
            continue;           # skip native_fdm.cxx generated zombie tanks
        }

#        print("name", t.getNode("name",1).getValue());
        append(alltanks, t);
        init_double_prop(t, "level-gal_us", 0.0);
        init_double_prop(t, "level-lbs", 0.0);
        init_double_prop(t, "capacity-gal_us", 0.01); # not zero (div/zero issue)
        init_double_prop(t, "density-ppg", 6.0);      # gasoline

        if (t.getNode("selected") == nil) {
            t.getNode("selected", 1).setBoolValue(1);
        }

    }

    print ("... Fuel system initialized.");

#    print("tank size", size(alltanks));
    loop();
});

