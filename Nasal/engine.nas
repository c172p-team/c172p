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
# Thanks to HHS81 (Benedikt Hallinger) for more advanced simulation
var service_hours = getprop("/engines/active-engine/oil-service-hours");
var consumption_qph = 0.0;
var rpm_factor = 0.0;
var rpm = 0;
var oil_level = 0;
var oil_full = 0;
var oil_lacking = 0;
var oil_level_limited = 0;
var service_hours_increase = 0;
var service_hours_new = 0;
var low_oil_pressure_factor = 0.0;
var low_oil_temperature_factor = 0.0;

var oil_consumption = maketimer(1.0, func {

    oil_level = getprop("/engines/active-engine/oil-level");
    if (getprop("/controls/engines/active-engine") == 0)
        oil_full = 7;
    if (getprop("/controls/engines/active-engine") == 1)
        oil_full = 8;
    oil_lacking = oil_full - oil_level;
    setprop("/engines/active-engine/oil-lacking", oil_lacking);
    
    if (getprop("/engines/active-engine/oil_consumption_allowed")) {
    
        rpm = getprop("/engines/active-engine/rpm");
    
        # Quadratic formula which outputs 1.0 for input 2300 RPM (cruise value),
        # 0.6 for 700 RPM (idle) and 1.2 for 2700 RPM (max)
        rpm_factor = 0.00000012 * math.pow(rpm, 2) - 0.0001 * rpm + 0.62;
    
        # Consumption rate defined as 0.33 quarts per 1 hour (3600 seconds) (Lycoming Manual 3-6 p27)
        # at 2350 RPM (normal cruise)
        consumption_qph = 0.33 / 3600; 
        
        # Raise consumption when oil level is > 8 quarts (blowout)
        if (oil_level > oil_full) {
            consumption_qph = consumption_qph * 1.3;
        }
        
        # Consumption also raises with oil in service time (lower viscosity => more friction)
        # (Oil should be changed at 50 hrs!)
        # See: http://www.t-craft.org/Reference/Aircraft.Oil.Usage.pdf
        # Hours:        0 |    10 |    25 |  50   |    75
        # Add Qts/hr:   0 |  0.02 | 0.125 | 0.5   | 1.125
        service_hours = getprop("/engines/active-engine/oil-service-hours");
        service_hours_increase = 0.00020 * math.pow(service_hours, 2);
        service_hours_increase = std.min(1.5, service_hours_increase);
        
        consumption_qph = consumption_qph + service_hours_increase;
    
        if (getprop("/engines/active-engine/running")) {
            oil_level = oil_level - consumption_qph * rpm_factor;
            setprop("/engines/active-engine/oil-level", oil_level);
            setprop("/engines/active-engine/oil-consume-qph", consumption_qph);
            
            service_hours_new = (service_hours + 1)/3600; # add one second service time
            setprop("/engines/active-engine/oil-service-hours", service_hours_new);
        } else {
            setprop("/engines/active-engine/oil-consume-qph", 0);
        }

        low_oil_pressure_factor = 1.0;
        low_oil_temperature_factor = 1.0;

        # If oil gets low (< 3.0), pressure should drop and temperature should rise
        oil_level_limited = std.min(oil_level, 3.0);
    
        # Should give 1.0 for oil_level = 3 and 0.1 for oil_level 1.97,
        # which is the min before the engine stops
        low_oil_pressure_factor = 0.873786408 * oil_level_limited - 1.621359224;
        
        # Should give 1.0 for oil_level = 3 and 1.5 for oil_level 1.97
        low_oil_temperature_factor = -0.485436893 * oil_level_limited + 2.456310679;
    
        setprop("/engines/active-engine/low-oil-pressure-factor", low_oil_pressure_factor);
        setprop("/engines/active-engine/low-oil-temperature-factor", low_oil_temperature_factor);
    }

    else {
        # if oil consumption is not allowed, the oil level is set to full and pressure and temp factors are set to 1.0
        if (getprop("/controls/engines/active-engine") == 0)
            setprop("/engines/active-engine/oil-level", 7);
        if (getprop("/controls/engines/active-engine") == 1)
            setprop("/engines/active-engine/oil-level", 8);
        setprop("/engines/active-engine/low-oil-pressure-factor", 1.0);
        setprop("/engines/active-engine/low-oil-temperature-factor", 1.0);
    }
});

# Oil Refilling
var oil_refill = func(){
    var service_hours = getprop("/engines/active-engine/oil-service-hours");
    var oil_level     = getprop("/engines/active-engine/oil-level");
    var refilled      = oil_level - previous_oil_level;
    #print("OIL Refill init: svcHrs=", service_hours, "; oil_level=",oil_level, "; previous_oil_level=",previous_oil_level, "; refilled=",refilled);
    
    if (refilled >= 0) {
        # when refill occured, the new oil "makes the old oil younger"
        var pct = 0;
        if (oil_level > 0) {
            pct = previous_oil_level / oil_level;
        }
        var newService_hours = service_hours * pct;
        setprop("/engines/active-engine/oil-service-hours", newService_hours);
        #print("OIL Refill: pct=", pct, "; service_hours=",service_hours, "; newService_hours=", newService_hours, "; previous_oil_level=", previous_oil_level, "; oil_level=",oil_level);
    }
    
    previous_oil_level = oil_level;
}

# ======= Oil temperature jsbsim compensator =======
# Currently, jsbsim oil temperature always initializes at 60°F.
# We want an temperature that initialize to environment temperature until first start
# and then gradually switch over to the real jsbsim value after some time.
var calculate_real_oiltemp = maketimer(0.5, func {
    if (!getprop("/engines/active-engine/already-started-in-session")) {
        # engine is still cold
        var temp_env        = getprop("/environment/temperature-degf") or 60;
        var temp_jsbsim_oil = getprop("/engines/active-engine/oil-temperature-degf") or 60;
        current_temp_diff   = temp_jsbsim_oil - temp_env;
        setprop("/engines/active-engine/oil-temperature-env-diff", current_temp_diff);
    } else {
        # engine has been started at least one time:
        # gradually remove the difference as jsbsim adapts to real environment temperature
        calculate_real_oiltemp.stop();
        interpolate("/engines/active-engine/oil-temperature-env-diff", 0, 180); # hand over to jsbsim caluclation gradually over 2 minutes
    }
});

# ========== engine damage due to over-RPM =========
# Initialize variables to reduce GC load
var rpm = getprop("/engines/active-engine/rpm");
var damage = 0.0;

var eng_damage_function = maketimer(1.0, func {
    if (getprop("/engines/active-engine/damage_allowed")) {
        rpm = getprop("/engines/active-engine/rpm"); # we need to update the RPM, but we do not set the variable here to avoid GC load
    
        if (rpm > 2700) {
            damage = damage + ((rpm - 2700) / 100); # 1 point of damage per 100RPM over limit added per second, so the damage increases faster the more you go over the limit
        }
    } else { # make sure damage is always 0 if the checkbox is disabled
        damage = 0.0; 
    }
    
    setprop("/engines/active-engine/damage-level", damage);   
});

# ========== carburetor icing ======================

var carb_icing_function = maketimer(1.0, func {
    if (getprop("/engines/active-engine/carb_icing_allowed")) {
        var rpm = getprop("/engines/active-engine/rpm");
        var dewpointC = getprop("/environment/dewpoint-degc");
        var dewpointF = dewpointC * 9.0 / 5.0 + 32;
        var airtempF = getprop("/environment/temperature-degf");
        var oil_temp = getprop("/engines/active-engine/oil-temperature-degf");
        var egt_degf = getprop("/engines/active-engine/egt-degf");
        var engine_running = getprop("/engines/active-engine/running");
        var carb_ice = getprop("/engines/active-engine/carb_ice");
        
        # the formula below attempts to model the graph found in the POH which relates air temperature, dew point and RPM to icing
        # conditions. The outputs of carb_icing_formula ranges from 0.65 to -0.35 (positive means ice is accumulating, negative
        # means that ice is melting)
        var factorX = 13.2 - 3.2 * math.atan2 ( ((rpm - 2000.0) * 0.008), 1);
        var factorY = 7.0 - 2.0 * math.atan2 ( ((rpm - 2000.0) * 0.008), 1);
        var carb_icing_formula = (math.exp( math.pow((0.6 * airtempF + 0.3 * dewpointF - 42.0),2) / (-2 * math.pow(factorX,2))) * math.exp( math.pow((0.3 * airtempF - 0.6 * dewpointF + 14.0),2) / (-2 * math.pow(factorY,2))) - 0.35)  * engine_running;
        
        # the efficacy of carb heat depends on the EGT. With a typical EGT of ~1500, the carb_heat_rate will be around -1.5.
        # This value is an educated guess of the RL effect, and should melt ice regardless of the icing rate
        if (getprop("/controls/engines/current-engine/carb-heat"))
            var carb_heat_rate = -0.001 * egt_degf;
        else
            var carb_heat_rate = 0.0;
        
        # a warm engine will accumulate less ice than a cold one, which is what oil temp factor is used for. oil_temp_factor
        # ranges from 0 to aprox -0.2 (at 250 oF). These values are educated guesses of the RL effect
        var oil_temp_factor = oil_temp / -1250;

        # the final rate of icing or melting is then calculated by all these effects together
        var carb_icing_rate = carb_icing_formula + carb_heat_rate + oil_temp_factor;

        # since the carb_icing_rate gives an arbitrary final value, the rate is then scaled down by 0.00001 to ensure ice 
        # accumulates as slowly as expected
        carb_ice = carb_ice + carb_icing_rate * 0.00001;
        carb_ice = std.max(0.0, std.min(carb_ice, 1.0));

        # this property is used to lower the RPM of the engine as ice accumulates (more ice in the carburator == less power)
        var vol_eff_factor = std.max(0.0, 0.85 - 1.72 * carb_ice);

        setprop("/engines/active-engine/carb_ice", carb_ice);
        setprop("/engines/active-engine/carb_icing_rate", carb_icing_rate);
        setprop("/engines/active-engine/volumetric-efficiency-factor", vol_eff_factor);
        setprop("/engines/active-engine/oil_temp_factor", oil_temp_factor);

    }
    else {
        setprop("/engines/active-engine/carb_ice", 0.0);
        setprop("/engines/active-engine/carb_icing_rate", 0.0);
        setprop("/engines/active-engine/volumetric-efficiency-factor", 0.85);
        setprop("/engines/active-engine/oil_temp_factor", 0.0);
    };
});

# ========== engine coughing ======================

var engine_coughing = func(){

    var coughing = getprop("/engines/active-engine/coughing");
    var running = getprop("/engines/active-engine/running");
    
    if (coughing and running) {
        # the code below kills the engine and then brings it back to life after 0.25 seconds, simulating a cough
        setprop("/engines/active-engine/kill-engine", 1);
        settimer(func {
            setprop("/engines/active-engine/kill-engine", 0);
        }, 0.25);
    };
    
    # basic value for the delay (interval between consecutive coughs), in case no fuel contamination nor carb ice are present
    var delay = 2;
    
    # if coughing due to fuel contamination, then cough interval depends on quantity of water
    var water_contamination0 = getprop("/consumables/fuel/tank[0]/water-contamination");
    var water_contamination1 = getprop("/consumables/fuel/tank[1]/water-contamination");
    var total_water_contamination = std.min((water_contamination0 + water_contamination1), 0.4);
    if (total_water_contamination > 0) {
        # if contamination is near 0, then interval is between 17 and 20 seconds, but if contamination is near the 
        # engine stopping value of 0.4, then interval falls to around 0.5 and 3.5 seconds
        delay = 3.0 * rand() + 17 - 41.25 * total_water_contamination;
    };
    
    # if coughing due to carb ice melting, then cough depends on quantity of ice in the carburettor
    var carb_ice = getprop("/engines/active-engine/carb_ice");
    if (carb_ice > 0) {
        # if carb_ice is near 0, then interval is between 17 and 20 seconds, but if carb_ice is near the 
        # engine stopping value of 0.3, then interval falls to around 0.5 and 3.5 seconds
        delay = 3.0 * rand() + 17 - 41.25 * carb_ice;
    };
    
    coughing_timer.restart(delay);
    
}

var coughing_timer = maketimer(1, engine_coughing);

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
        if (!getprop("/fdm/jsbsim/fcs/mixture-primer-cmd") and getprop("/controls/switches/starter")) {
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
    
    if (getprop("/engines/active-engine/ready-oil-press-checker") == 1 and getprop("/engines/active-engine/rpm") > 900) {
        setprop("/engines/active-engine/ready-oil-press-checker", 2); # engine is ready for use
    }
};

setlistener("/controls/switches/starter", func {
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
    
   
    if (getprop("/controls/engines/active-engine") == 0)
       var rpm = getprop("/engines/engine[0]/rpm");
    if (getprop("/controls/engines/active-engine") == 1)
        var rpm = getprop("/engines/engine[1]/rpm");
    
	# sorry - had to hack this to prevent coughing on startup due to the oil pressure simulation. Maybe this can be used elsewhere
    if (rpm < 900) { # make sure it is not triggered if you accidentally hit s in the air
        setprop("/engines/active-engine/ready-oil-press-checker", 1); # 0 = off, 1 = checker is armed, 2 = engine is running and ready
    }
}, 1, 0);

# ================================ Initalize ====================================== 
# Make sure all needed properties are present and accounted 
# for, and that they have sane default values.

setprop("/engines/active-engine/rpm", 0);
setprop("/engines/active-engine/ready-oil-press-checker", 0);
setprop("/engines/active-engine/damage-level", 0.0);
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

controls.stepMagnetos = func {
    var old_value = getprop("/controls/switches/magnetos");
    var new_value = std.max(0, std.min(old_value + arg[0], 3));
    setprop("/controls/switches/magnetos", new_value);
};

# key 's' calls to this function when it is pressed DOWN even if I overwrite the binding in the -set.xml file!
# fun fact: the key UP event can be overwriten!
controls.startEngine = func(v = 1) {
    # Only operate in non-walker mode ('s' is also bound to walk-backward)
    var view_name = getprop("/sim/current-view/name");
    if (view_name == getprop("/sim/view[110]/name") or view_name == getprop("/sim/view[111]/name")) {
        return;
    }
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
    carb_icing_function.start();
    coughing_timer.singleShot = 1;
    coughing_timer.start();
    eng_damage_function.start();
    
    # ======= OIL SYSTEM INIT =======
    var previous_oil_level = getprop("/engines/engine[0]/oil-level");
    if (!getprop("/engines/active-engine/oil-service-hours")) {
         setprop("/engines/active-engine/oil-service-hours", 0);
    }
    oil_consumption.simulatedTime = 1;
    oil_consumption.start();
    calculate_real_oiltemp.start();
});
