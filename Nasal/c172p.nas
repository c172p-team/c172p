##########################################
# Autostart
##########################################

var autostart = func (msg=1) {
    if (getprop("/engines/active-engine/running")) {
        if (msg)
            gui.popupTip("Engine already running", 5);
        return;
    }

    # Reset battery charge and circuit breakers
    electrical.reset_battery_and_circuit_breakers();

    #Guarantee repairing flag is reset
    setprop("/fdm/jsbsim/damage/repairing", 0);

    # Setting levers and switches for startup
    setprop("/controls/switches/magnetos", 3);
	setprop("/controls/engines/engine[0]/throttle", 0.2);
	setprop("/controls/engines/engine[1]/throttle", 0.2);

    var auto_mixture = getprop("/fdm/jsbsim/engine/auto-mixture");
    setprop("/controls/engines/current-engine/mixture", auto_mixture);

    setprop("/controls/flight/elevator-trim", 0.0);
    setprop("/controls/flight/rudder-trim", 0.02);
    setprop("/controls/switches/master-bat", 1);
    setprop("/controls/switches/master-alt", 1);
    setprop("/controls/switches/master-avionics", 1);
    if (getprop("controls/panel/glass")) {
        setprop("/controls/switches/master-avionics2", 1);
    }

    # Setting lights
    setprop("/controls/lighting/nav-lights", 1);
    setprop("/controls/lighting/strobe", 1);
    setprop("/controls/lighting/beacon", 1);

    # Setting instrument lights if needed
    var light_level = 1-getprop("/rendering/scene/diffuse/red");
    if (light_level > .6) {
        if (!getprop("/controls/panel/glass")){
            if (getprop("/controls/lighting/instruments-norm") == 0) {
                if (light_level > .8) light_level = .8;
                setprop("/controls/lighting/instruments-norm", light_level);
            }
            setprop("/controls/switches/dome-red", 1);
        }
        if (getprop("/controls/panel/glass")) {
            if (getprop("/controls/lighting/swcb-norm") == 0) {
                setprop("/controls/lighting/swcb-norm", .55);
            }
            if (getprop("/controls/lighting/avionics-norm") == 0) {
                setprop("/controls/lighting/avionics-norm", .6);
            }
            if (getprop("/controls/lighting/stby-norm") == 0) {
                setprop("/controls/lighting/stby-norm", .8);
            }
        }
    } else {
        if (getprop("/controls/panel/glass")) {
            if (getprop("/controls/lighting/swcb-norm") == 0) {
                setprop("/controls/lighting/swcb-norm", .35);
            }
            if (getprop("/controls/lighting/avionics-norm") == 0) {
                setprop("/controls/lighting/avionics-norm", .35);
            }
            if (getprop("/controls/lighting/stby-norm") == 0) {
                setprop("/controls/lighting/stby-norm", .75);
            }
        }
    }
    if (getprop("/controls/panel/glass")) {
        setprop("/controls/switches/stby-batt", 2);
    }
    # Setting amphibious landing gear if needed
    if (getprop("/fdm/jsbsim/bushkit")==4){
        if (getprop("/fdm/jsbsim/hydro/active-norm")) {
            setprop("controls/gear/gear-down-command", 0);
            setprop("/fdm/jsbsim/gear/gear-pos-norm", 0);
        } else {
            setprop("controls/gear/gear-down-command", 1);
            setprop("/fdm/jsbsim/gear/gear-pos-norm", 1);
        }
    }

    # Setting flaps to 0
    setprop("/controls/flight/flaps", 0.0);

    # Set the altimeter
    var pressure_sea_level = getprop("/environment/pressure-sea-level-inhg");
    setprop("/instrumentation/altimeter/setting-inhg", pressure_sea_level);

    # Insta-Spin up gyros
    setprop("/instrumentation/heading-indicator/spin", 1.0);
    setprop("/instrumentation/turn-indicator/spin", 1.0);
    setprop("/instrumentation/attitude-indicator/spin", 1.0);

    # Set heading offset
    # Note: this needs a correctly spun up gyro to work.
    var magnetic_variation = getprop("/environment/magnetic-variation-deg");
    magnetic_variation     = sprintf("%.2f", magnetic_variation);
    setprop("/instrumentation/heading-indicator/align-deg", -magnetic_variation);
    setprop("/instrumentation/heading-indicator/error-deg", 0);
    setprop("/instrumentation/heading-indicator/offset-deg", 0);
    print("Heading Indicator calibrated to: " ~ magnetic_variation ~ " magVar");

    # Pre-flight inspection
    setprop("/sim/model/c172p/cockpit/control-lock-placed", 0);
    setprop("/controls/gear/brake-parking", 0);
    setprop("/sim/model/c172p/securing/chock", 0);
    setprop("/sim/model/c172p/securing/cowl-plugs-visible", 0);
    setprop("/sim/model/c172p/securing/pitot-cover-visible", 0);
    setprop("/sim/model/c172p/securing/tiedownL-visible", 0);
    setprop("/sim/model/c172p/securing/tiedownR-visible", 0);
    setprop("/sim/model/c172p/securing/tiedownT-visible", 0);

    # Setting max oil level
    var oil_enabled = getprop("/engines/active-engine/oil_consumption_allowed");
    var oil_level   = getprop("/engines/active-engine/oil-level");

    if (oil_enabled and oil_level < 5.0) {
        if (getprop("/controls/engines/active-engine") == 0) {
            setprop("/engines/active-engine/oil-level", 7.0);
        }
        else {
            setprop("/engines/active-engine/oil-level", 8.0);
        };
    };

    # removing any ice from the carburetor
    setprop("/engines/active-engine/carb_ice", 0.0);
    setprop("/engines/active-engine/carb_icing_rate", 0.0);
    setprop("/engines/active-engine/volumetric-efficiency-factor", 0.85);

    # Removing any contamination from water
    setprop("/consumables/fuel/tank[0]/water-contamination", 0.0);
    setprop("/consumables/fuel/tank[1]/water-contamination", 0.0);
    setprop("/consumables/fuel/tank[0]/sample-water-contamination", 0.0);
    setprop("/consumables/fuel/tank[1]/sample-water-contamination", 0.0);

    # set fuel configuration
    set_fuel();

    setprop("/controls/engines/engine[0]/primer-lever", 0);
    setprop("/controls/engines/engine/primer", 3);

    # All set, starting engine
    setprop("/controls/switches/starter", 1);
    setprop("/engines/active-engine/auto-start", 1);

    var engine_running_check_delay = 5.0;
    settimer(func {
        if (!getprop("/engines/active-engine/running")) {
            gui.popupTip("The autostart failed to start the engine. You must lean the mixture and start the engine manually.", 5);
        }
        setprop("/controls/switches/starter", 0);
        setprop("/engines/active-engine/auto-start", 0);
    }, engine_running_check_delay);

};

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

##########################################
# Set Fuel Configuration
##########################################
var set_fuel = func {
    # Checking for minimal fuel level
    var fuel_level_left_default  = getprop("/consumables/fuel/tank[0]/level-norm");
    var fuel_level_right_default = getprop("/consumables/fuel/tank[1]/level-norm");
    var fuel_level_left_integral  = getprop("/consumables/fuel/tank[2]/level-norm");
    var fuel_level_right_integral = getprop("/consumables/fuel/tank[3]/level-norm");
    # Check which tanks are being used
    var integral_tanks = getprop("/fdm/jsbsim/fuel/tank");
    if (integral_tanks) {
        if (fuel_level_left_integral < 0.25)
            setprop("/consumables/fuel/tank[2]/level-norm", 0.25);
        if (fuel_level_right_integral < 0.25)
            setprop("/consumables/fuel/tank[3]/level-norm", 0.25);
        setprop("/consumables/fuel/tank[2]/selected", 1);
        setprop("/consumables/fuel/tank[3]/selected", 1);
        setprop("/consumables/fuel/tank[0]/selected", 0);
        setprop("/consumables/fuel/tank[1]/selected", 0);
    } else {
        if (fuel_level_left_default < 0.25)
            setprop("/consumables/fuel/tank[0]/level-norm", 0.25);
        if (fuel_level_right_default < 0.25)
            setprop("/consumables/fuel/tank[1]/level-norm", 0.25);
        setprop("/consumables/fuel/tank[0]/selected", 1);
        setprop("/consumables/fuel/tank[1]/selected", 1);
        setprop("/consumables/fuel/tank[2]/selected", 0);
        setprop("/consumables/fuel/tank[3]/selected", 0);
    }
    setprop("sim/model/open-pfuel-cap", 0);
    setprop("sim/model/open-sfuel-cap", 0);
    setprop("sim/model/open-pfuel-sump", 0);
    setprop("sim/model/open-sfuel-sump", 0);
    fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-left-fuel-dialog"}));
    fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-right-fuel-dialog"}));
    fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-fuel-both-tanks-dialog"}));
    fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-left-fuel-sample-dialog"}));
    fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-right-fuel-sample-dialog"}));
};

##########################################
# Fuel Contamination
##########################################
var fuel_contamination = func {
    var chance = rand();

    # Chance of contamination is 1 %
    if (getprop("/consumables/fuel/contamination_allowed") and chance < 0.01) {
        # Quantity of water is much more likely to be small than large, since
        # it's given by x^6 (76 % of the time it will be lower than 0.2)
        var water = math.pow(rand(), 6);

        setprop("/consumables/fuel/tank[0]/water-contamination", water);

        # level of water in the right tank will be the same as in the left tank +- 0.1
        water = water + 0.2 * (rand() - 0.5);
        water = std.max(0.0, std.min(water, 1.0));
        setprop("/consumables/fuel/tank[1]/water-contamination", water);
    }
    else {
        setprop("/consumables/fuel/tank[0]/water-contamination", 0.0);
        setprop("/consumables/fuel/tank[1]/water-contamination", 0.0);
    };
};

##########################################
# Take Fuel Sample
##########################################
var take_fuel_sample = func(index) {
    var fuel = getprop("/consumables/fuel/tank", index, "level-gal_us");
    var water = getprop("/consumables/fuel/tank", index, "water-contamination");

    # Remove 50 ml of fuel
    setprop("/consumables/fuel/tank", index, "level-gal_us", fuel - 0.0132086);

    # Remove a bit of water if contaminated
    if (water > 0.0) {
        var sample_water = std.min(0.2, water);
        water = water - sample_water;
        setprop("/consumables/fuel/tank", index, "water-contamination", water);
        setprop("/consumables/fuel/tank", index, "sample-water-contamination", sample_water);
    };
};

##########################################
# Return Fuel Sample
##########################################
var return_fuel_sample = func(index) {
    var fuel = getprop("/consumables/fuel/tank", index, "level-gal_us");
    var water = getprop("/consumables/fuel/tank", index, "water-contamination");
    var sample_water = getprop("/consumables/fuel/tank", index, "sample-water-contamination");

    # Add back the 50 ml of fuel
    setprop("/consumables/fuel/tank", index, "level-gal_us", fuel + 0.0132086);

    # Add back the (contaminated) water
    if (sample_water > 0.0) {
        water = water + sample_water;
        setprop("/consumables/fuel/tank", index, "water-contamination", water);
        setprop("/consumables/fuel/tank", index, "sample-water-contamination", 0.0);
    };
};

##########################################
# Preflight control surface check: left aileron
##########################################
var control_surface_check_left_aileron = func {
    var auto_coordination = getprop("/controls/flight/auto-coordination");
    setprop("/controls/flight/auto-coordination", 0);
    interpolate("/controls/flight/aileron", 1.0, 0.5, -1.0, 1.0, 0.0, 0.5);
    settimer(func(){
        setprop("/controls/flight/auto-coordination", auto_coordination);
    }, 2.0);
};

##########################################
# Preflight control surface check: right aileron
##########################################
var control_surface_check_right_aileron = func {
    var auto_coordination = getprop("/controls/flight/auto-coordination");
    setprop("/controls/flight/auto-coordination", 0);
    interpolate("/controls/flight/aileron", -1.0, 0.5, 1.0, 1.0, 0.0, 0.5);
    settimer(func(){
        setprop("/controls/flight/auto-coordination", auto_coordination);
    }, 2.0);
};

##########################################
# Preflight control surface check: elevator
##########################################
var control_surface_check_elevator = func {
    interpolate("/controls/flight/elevator", 1.0, 0.8, -1.0, 1.6, 0.0, 0.8);
};

##########################################
# Preflight control surface check: rudder
##########################################
var control_surface_check_rudder = func {
    interpolate("/controls/flight/rudder", -1.0, 0.8, 1.0, 1.6, 0.0, 0.8);
};

##########################################
# Switches Save State
##########################################
var switches_save_state = func {
    if (!getprop("/instrumentation/save-switches-state")) {
        setprop("/controls/engines/engine[0]/primer", 0);
        setprop("/controls/engines/engine[0]/primer-lever", 0);
        setprop("/controls/engines/engine[0]/use-primer", 0);
		setprop("/controls/engines/engine[0]/throttle", 0.0);
		setprop("/controls/engines/engine[1]/throttle", 0.0);
        setprop("/controls/engines/current-engine/mixture", 0.0);
        #setprop("/controls/circuit-breakers/aircond", 1);
        setprop("/controls/circuit-breakers/autopilot", 1);
        setprop("/controls/circuit-breakers/bcnlt", 1);
        setprop("/controls/circuit-breakers/flaps", 1);
        setprop("/controls/circuit-breakers/instr", 1);
        setprop("/controls/circuit-breakers/intlt", 1);
        setprop("/controls/circuit-breakers/landing", 1);
        setprop("/controls/circuit-breakers/master", 1);
        setprop("/controls/circuit-breakers/navlt", 1);
        setprop("/controls/circuit-breakers/pitot-heat", 1);
        setprop("/controls/circuit-breakers/radio1", 1);
        setprop("/controls/circuit-breakers/radio2", 1);
        setprop("/controls/circuit-breakers/radio3", 1);
        setprop("/controls/circuit-breakers/radio4", 1);
        setprop("/controls/circuit-breakers/radio5", 1);
        setprop("/controls/circuit-breakers/strobe", 1);
        if (getprop("sim/model/variant") == 4) {
            setprop("controls/circuit-breakers/gear-advisory", 1);
            setprop("controls/circuit-breakers/hydraulic-pump", 1);
            setprop("controls/circuit-breakers/gear-select", 1);
        }
        setprop("/controls/circuit-breakers/turn-coordinator", 1);
        setprop("/controls/switches/master-avionics", 0);
        setprop("/controls/switches/starter", 0);
        setprop("/controls/switches/master-alt", 0);
        setprop("/controls/switches/master-bat", 0);
        setprop("/controls/switches/magnetos", 0);
        setprop("/controls/switches/dome-white", 0);
        setprop("/controls/switches/dome-red", 0);
        setprop("/controls/lighting/nav-lights", 0);
        setprop("/controls/lighting/beacon", 0);
        setprop("/controls/lighting/strobe", 0);
        setprop("/controls/lighting/taxi-light", 0);
        setprop("/controls/lighting/landing-lights", 0);
        setprop("/controls/lighting/instruments-norm", 0.0);
        setprop("/controls/lighting/radio-norm", 0.0);
        setprop("/controls/lighting/dome-white-norm", 1.0);
        setprop("/controls/lighting/gps-norm", 0.0);
        setprop("/controls/lighting/gearled", 0);
        setprop("/controls/gear/water-rudder", 0);
        setprop("/controls/gear/water-rudder-down", 0);
        setprop("/controls/gear/brake-parking", 1);
        setprop("/controls/flight/flaps", 0.0);
        setprop("/surface-positions/flap-pos-norm", 0.0);
        setprop("/controls/flight/elevator-trim", 0.0);
        setprop("/controls/anti-ice/engine[0]/carb-heat", 0);
        setprop("/controls/anti-ice/engine[1]/carb-heat", 0);
        setprop("/controls/anti-ice/pitot-heat", 0);
        setprop("/environment/aircraft-effects/cabin-heat-set", 0.0);
        setprop("/environment/aircraft-effects/cabin-air-set", 0.0);
        setprop("/consumables/fuel/tank[0]/level-norm", 0.0);
        setprop("/consumables/fuel/tank[1]/level-norm", 0.0);
        setprop("/consumables/fuel/tank[2]/level-norm", 0.0);
        setprop("/consumables/fuel/tank[3]/level-norm", 0.0);

        if (getprop("/sim/model/c172p/ruddertrim-visible"))
          setprop("/controls/flight/rudder-trim", 0);

        if (getprop("controls/panel/glass")) {
            electrical.reset_battery_and_circuit_breakers();
            setprop("/controls/switches/master-avionics", 0);
            setprop("/controls/switches/master-avionics2", 0);
        }

    };
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

var speed_of_sound = func (t, re) {
    # Compute speed of sound in m/s
    #
    # t = temperature in Celsius
    # re = amount of water vapor in the air

    # Compute virtual temperature using mixing ratio (amount of water vapor)
    # Ratio of gas constants of dry air and water vapor: 287.058 / 461.5 = 0.622
    var T = 273.15 + t;
    var v_T = T * (1 + re/0.622)/(1 + re);

    # Compute speed of sound using adiabatic index, gas constant of air,
    # and virtual temperature in Kelvin.
    return math.sqrt(1.4 * 287.058 * v_T);
};

var thunder = func (name) {
    var thunderCalls = 0;

    var lightning_pos_x = getprop("/environment/lightning/lightning-pos-x");
    var lightning_pos_y = getprop("/environment/lightning/lightning-pos-y");
    var lightning_distance = math.sqrt(math.pow(lightning_pos_x, 2) + math.pow(lightning_pos_y, 2));

    # On the ground, thunder can be heard up to 16 km. Increase this value
    # a bit because the aircraft is usually in the air.
    if (lightning_distance > 20000)
        return;

    var t = getprop("/environment/temperature-degc");
    var re = getprop("/environment/relative-humidity") / 100;
    var delay_seconds = lightning_distance / speed_of_sound(t, re);

    # Maximum volume at 5000 meter
    var lightning_distance_norm = std.min(1.0, 1 / math.pow(lightning_distance / 5000.0, 2));

    settimer(func {
        var thunder1 = getprop("/sim/model/c172p/sound/click-thunder1");
        var thunder2 = getprop("/sim/model/c172p/sound/click-thunder2");
        var thunder3 = getprop("/sim/model/c172p/sound/click-thunder3");

        if (!thunder1) {
            thunderCalls = 1;
            setprop("/sim/model/c172p/sound/lightning/dist1", lightning_distance_norm);
        }
        else if (!thunder2) {
            thunderCalls = 2;
            setprop("/sim/model/c172p/sound/lightning/dist2", lightning_distance_norm);
        }
        else if (!thunder3) {
            thunderCalls = 3;
            setprop("/sim/model/c172p/sound/lightning/dist3", lightning_distance_norm);
        }
        else
            return;

        # Play the sound (sound files are about 9 seconds)
        click("thunder" ~ thunderCalls, 9.0, 0);
    }, delay_seconds);
};

var reset_system = func {
    if (getprop("/fdm/jsbsim/running")) {
        c172p.autostart(0);
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

    setprop("/engines/active-engine/kill-engine", 0);

    setprop("/fdm/jsbsim/damage/repairing", 0);

    set_fuel();
}

############################################
# Engine coughing sound
############################################

setlistener("/engines/active-engine/killed", func (node) {
    if (node.getValue() and getprop("/engines/active-engine/running")) {
        click("coughing-engine-sound", 0.7, 0);
    };
});

############################################
# Static objects: right safety cone
############################################

var StaticModel = {
    new: func (name, file) {
        var m = {
            parents: [StaticModel],
            model: nil,
            model_file: file,
            object_name: name
        };

        setlistener("/sim/" ~ name ~ "/enable", func (node) {
            if (node.getBoolValue()) {
                m.add();
            }
            else {
                m.remove();
            }
        });

        return m;
    },

    add: func {
        var manager = props.globals.getNode("/models", 1);
        var i = 0;
        for (; 1; i += 1) {
            if (manager.getChild("model", i, 0) == nil) {
                break;
            }
        }
        var position = geo.aircraft_position().set_alt(getprop("/position/ground-elev-m"));
        if (me.object_name == "anchorbuoy") {
            me.model = geo.put_model(me.model_file, getprop("/fdm/jsbsim/mooring/anchor-lat"), getprop("/fdm/jsbsim/mooring/anchor-lon"), getprop("/position/ground-elev-m"), getprop("/orientation/heading-deg"));
        } else {
            me.model = geo.put_model(me.model_file, position, getprop("/orientation/heading-deg"));
        }
    },

    remove: func {
        if (me.model != nil) {
            me.model.remove();
            me.model = nil;
        }
    }
};

StaticModel.new("coneR", "Aircraft/c172p/Models/Exterior/safety-cone/coneR.ac");
StaticModel.new("coneL", "Aircraft/c172p/Models/Exterior/safety-cone/coneL.ac");
StaticModel.new("gpu", "Aircraft/c172p/Models/Exterior/external-power/external-power.xml");
StaticModel.new("ladderR", "Aircraft/c172p/Models/Exterior/ladder/ladderR.ac");
StaticModel.new("ladderL", "Aircraft/c172p/Models/Exterior/ladder/ladderL.ac");
StaticModel.new("fueltanktrailer", "Aircraft/c172p/Models/Exterior/fueltanktrailer/fueltanktrailer.ac");
StaticModel.new("externalheater", "Aircraft/c172p/Models/Exterior/external-heater/heater.xml");

# Mooring anchor and rope
StaticModel.new("anchorbuoy", "Aircraft/c172p/Models/Effects/pontoon/mooring.xml");


#
# Realism settings
#
var latitude_nut_update = func() {
    var p = "/instrumentation/heading-indicator/latitude-nut-setting";
    var lat = getprop("position/latitude-deg");
    var tgt = sprintf("%2.0f", lat);
    var cur = sprintf("%2.0f", getprop(p));
    if (tgt != cur) {
        setprop(p, tgt);
        print("C172 HI/DG latitude nut adjusted from "~cur~"° to "~tgt~"°");
    }
}
var latitude_nut_setter_timer = maketimer(30.0, latitude_nut_update);

# Define realism adjustments. Default values here are the "unrealistic" settings.
var prev_realism_state = [
    {
        id:"attitude-indicator",
        node: props.globals.getNode("/instrumentation/attitude-indicator"),
        props:[
            {name:"gyro/spin-up-sec",        value:4.0}
        ]
    },
    {
        id:"heading-indicator",
        node: props.globals.getNode("/instrumentation/heading-indicator"),
        props:[
            {name:"gyro/spin-up-sec",        value:4.0},
            {name:"limits/g-error-factor",   value:0.0},
            {name:"limits/yaw-error-factor", value:0.0},
            {name:"limits/g-limit-lower",    value:-99.0},
            {name:"limits/g-limit-upper",    value:99.0}
        ]
    },
    {
        id:"turn-indicator",
        node: props.globals.getNode("/instrumentation/turn-indicator"),
        props:[
            {name:"gyro/spin-up-sec",        value:4.0}
        ]
    },
    {
        id:"magnetic-compass",
        node: props.globals.getNode("/instrumentation/magnetic-compass"),
        props:[
            {name:"roll-limit-left",        value:-999.0},
            {name:"roll-limit-right",       value:999.0},
            {name:"pitch-limit-up",         value:999.0},
            {name:"pitch-limit-down",       value:-999.0}
        ]
    },
];
var setRealismInstruments_setting = 1;
var setRealismInstruments = func() {
    var activate    = getprop("/sim/realism/instruments/realistic-instruments");
    if (activate == setRealismInstruments_setting) return;

    setRealismInstruments_setting = activate;
    var setting_txt = (activate)? "enabled": "disabled";
    print("C172 realistic instruments: "~setting_txt);

    # Swap the current value with the old one for each defined prop
    foreach (item; prev_realism_state) {
        print("  "~item.id);
        foreach (p; item.props) {
            var cur_val = item.node.getValue(p.name);
            #print("    "~p.name~ "\t\t(old="~cur_val~"; new="~p.value~")");
            item.node.setValue(p.name, p.value);
            p.value = cur_val;
        }
    }
    
    # Do some specific actions
    if (activate) {
        # Activate realistic behaviour
        latitude_nut_setter_timer.stop();
        print("  HI/DG latitude nut autoset stopped");

    } else {
        # Make unrealistic
        latitude_nut_update();
        latitude_nut_setter_timer.start();
        print("  HI/DG latitude nut autoset activated");
    }

}

############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
var global_system_loop = func {
    c172p.physics_loop();
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

var update_securing = func {
    var state = 0;
    state = bits.switch(state, 0, getprop("/sim/model/c172p/securing/pitot-cover-visible"));
    state = bits.switch(state, 1, getprop("/sim/model/c172p/securing/chock-visible"));
    state = bits.switch(state, 2, getprop("/sim/model/c172p/securing/tiedownL-visible"));
    state = bits.switch(state, 3, getprop("/sim/model/c172p/securing/tiedownR-visible"));
    state = bits.switch(state, 4, getprop("/sim/model/c172p/securing/tiedownT-visible"));
    setprop("/payload/securing-state", state);
};

setlistener("/sim/model/c172p/securing/pitot-cover-visible", update_securing, 0, 0);
setlistener("/sim/model/c172p/securing/chock-visible", update_securing, 0, 0);
setlistener("/sim/model/c172p/securing/tiedownL-visible", update_securing, 0, 0);
setlistener("/sim/model/c172p/securing/tiedownR-visible", update_securing, 0, 0);
setlistener("/sim/model/c172p/securing/tiedownT-visible", update_securing, 0, 0);
update_securing();

var log_cabin_temp = func {
    if (getprop("/sim/model/c172p/enable-fog-frost")) {
        var temp_degc = getprop("/fdm/jsbsim/heat/cabin-air-temp-degc");
        if (temp_degc >= 32)
            logger.screen.red("Cabin temperature exceeding 90F/32C!");
        elsif (temp_degc <= 0)
            logger.screen.red("Cabin temperature falling below 32F/0C!");
    }
};
var cabin_temp_timer = maketimer(30.0, log_cabin_temp);

var log_fog_frost = func {
    if (getprop("/sim/model/c172p/enable-fog-frost")) {
        logger.screen.white("Wait until fog/frost clears up or decrease cabin air temperature");
    }
};
var fog_frost_timer = maketimer(30.0, log_fog_frost);

var dialog_battery_reload = func {
    electrical.reset_battery_and_circuit_breakers();
    gui.popupTip("The battery is now fully charged!");
}

var c172_timer = maketimer(0.25, func{global_system_loop()});

setlistener("/sim/signals/fdm-initialized", func {
    # Randomize callsign of new users to avoid them blocking
    # other new users on multiplayer
    if (getprop("/sim/multiplay/callsign") == "callsign") {
        var digit = func {
            return math.round(rand()*9);
        };
        var new_callsign = "FG-" ~ digit() ~ digit() ~ digit() ~ digit();
        setprop("/sim/multiplay/callsign", new_callsign);
    };

    # Use Nasal to make some properties persistent. <aircraft-data> does
    # not work reliably.
    aircraft.data.add("/sim/model/c172p/immat-on-panel");
    aircraft.data.load();

    # Initialize mass limits
    set_limits(props.globals.getNode("/controls/engines/active-engine"));

    # Close all caps and doors
    setlistener("/engines/active-engine/cranking", func (node) {
        setprop("sim/model/show-dip-stick", 0);
        setprop("sim/model/open-pfuel-cap", 0);
        setprop("sim/model/open-sfuel-cap", 0);
        setprop("sim/model/open-pfuel-sump", 0);
        setprop("sim/model/open-sfuel-sump", 0);
        setprop("sim/model/door-positions/oilDoor/position-norm", 0);
        setprop("sim/model/c172p/securing/cowl-plugs-visible", 0);
        fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-oil-dialog-160"}));
        fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-oil-dialog-180"}));
        fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-left-fuel-dialog"}));
        fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-right-fuel-dialog"}));
        fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-left-fuel-sample-dialog"}));
        fgcommand("dialog-close", props.Node.new({"dialog-name": "c172p-right-fuel-sample-dialog"}));
    }, 0, 0);

    setlistener("/engines/active-engine/running", func (node) {
        var autostart = getprop("/engines/active-engine/auto-start");
        var cranking  = getprop("/engines/active-engine/cranking");
        if (autostart and cranking and node.getBoolValue()) {
            setprop("/controls/switches/starter", 0);
            setprop("/engines/active-engine/auto-start", 0);
        }
    }, 0, 0);

    setlistener("/engines/active-engine/cranking", func (node) {
        setprop("/engines/active-engine/external-heat/enabled", 0);
        setprop("/sim/externalheater/enable", 0);
        setprop("/fdm/jsbsim/external_reactions/towbar/attached", 0);
    }, 0, 0);

    # Checking if switches should be moved back to default position (in case save state is off)
    switches_save_state();

    # Checking if fuel contamination is allowed, and if so generating a random situation
    fuel_contamination();

    # Listening for lightning strikes
    setlistener("/environment/lightning/lightning-pos-y", thunder);

    reset_system();

    var onground = getprop("/sim/presets/onground") or "";
    if (!onground) {
        state_manager();
    }

    # set user defined pilot view or initialize it
    if (getprop("sim/current-view/view-number") == 0){
        settimer(func {
            if (getprop("sim/current-view/user/x-offset-m") != nil){
                setprop("sim/current-view/x-offset-m", getprop("sim/current-view/user/x-offset-m"));
            } else {
                setprop("sim/current-view/user/x-offset-m", getprop("sim/view/config/x-offset-m"));
            }
            if (getprop("sim/current-view/user/y-offset-m") != nil){
                setprop("sim/current-view/y-offset-m", getprop("sim/current-view/user/y-offset-m"));
            } else {
                setprop("sim/current-view/user/y-offset-m", getprop("sim/view/config/y-offset-m"));
            }
            if (getprop("sim/current-view/user/z-offset-m") != nil){
                setprop("sim/current-view/z-offset-m", getprop("sim/current-view/user/z-offset-m"));
            } else {
                setprop("sim/current-view/user/z-offset-m", getprop("sim/view/config/z-offset-m"));
            }
            if (getprop("sim/current-view/user/default-field-of-view-deg") != nil){
                setprop("sim/current-view/field-of-view", getprop("sim/current-view/user/default-field-of-view-deg"));
            } else {
                setprop("sim/current-view/user/default-field-of-view-deg", getprop("sim/view/config/default-field-of-view-deg"));
            }
            if (getprop("sim/current-view/user/pitch-offset-deg") != nil){
                setprop("sim/current-view/pitch-offset-deg", getprop("sim/current-view/user/pitch-offset-deg"));
            } else {
                setprop("sim/current-view/user/pitch-offset-deg", getprop("sim/view/config/pitch-offset-deg"));
            }
        }, 1);
    }

    if (getprop("sim/model/variant") == 4) {
        settimer(func {
            # check for ground type (land or water, only if not in flight)
            var on_water = getprop("fdm/jsbsim/hydro/active-norm");
            print("ON-WATER ="~ on_water);
            if (on_water) {
                setprop("controls/gear/gear-down-command", 0);
                setprop("controls/gear/gear-down", 0);
                setprop("fdm/jsbsim/gear/gear-pos-norm", 0);
            } else {
                setprop("controls/gear/gear-down-command", 1);
                setprop("controls/gear/gear-down", 1);
                setprop("fdm/jsbsim/gear/gear-pos-norm", 1);
            }
        }, 3);
    }

    settimer(func {
        if (getprop("/sim/model/c172p/securing/tiedownT"))
            setprop("/sim/model/c172p/securing/tiedownT-visible", 1);
        if (getprop("/sim/model/c172p/securing/tiedownR"))
            setprop("/sim/model/c172p/securing/tiedownR-visible", 1);
        if (getprop("/sim/model/c172p/securing/tiedownL"))
            setprop("/sim/model/c172p/securing/tiedownL-visible", 1);
    }, 10);


    # HI/DG: Reset offset to stored values
    # The DG always initializes to indicated_heading=/orientation/heading-deg, so we need to apply the
    # difference of the last known orientation to offset the HI, so it shows the last stored value.
    # The result is, that the HI is only correctly aligned when the planes location and orientation did
    # not change between sessions AND it was calibrated correctly.
    # (This all would be alot easier if the c++ instrument would initialize to saved values)
    var dg_offset_storemode = 0;
    var dg_hdg_cur      = props.globals.getNode("/orientation/heading-deg");
    var dg_hdg_saved    = props.globals.getNode("/orientation/heading-deg-saved", 1);
    var dg_offset_cur   = props.globals.getNode("/instrumentation/heading-indicator/offset-deg");
    var dg_offset_saved = props.globals.getNode("/instrumentation/heading-indicator/offset-deg-saved", 1);
    var dg_error_cur    = props.globals.getNode("/instrumentation/heading-indicator/error-deg");
    var dg_error_saved  = props.globals.getNode("/instrumentation/heading-indicator/error-deg-saved", 1);
    
    # Restore values from last session
    if (dg_hdg_saved.getValue() != nil and dg_offset_saved.getValue() != nil and dg_error_saved.getValue() != nil) {
        print("C172 restore HI/DG settings...");
        print("  HI/DG startup error: "~sprintf("%.2f",dg_error_saved.getValue()));
        dg_error_cur.setDoubleValue(dg_error_saved.getValue());
        
        print("  HI/DG startup offset: "~sprintf("%.2f",dg_offset_saved.getValue()));
        dg_offset_cur.setDoubleValue(dg_offset_saved.getValue());
        
        # Apply orientation difference from last session
        var hdg_diff           = dg_hdg_saved.getValue() - dg_hdg_cur.getValue();
        var dg_offset_startup  = dg_offset_cur.getValue() + hdg_diff;
        print("  HI/DG startup heading: from "~sprintf("%.2f",dg_offset_cur.getValue())~" to "~sprintf("%.2f",dg_offset_startup)~" (stored orientation diff="~sprintf("%.2f", hdg_diff)~")");
        dg_offset_cur.setDoubleValue(dg_offset_startup);
    }
    
    # Store values for next session (as we can't store the instruments values itself, they get overwritten)
    var dg_offset_startup_timer = maketimer(1.0, func(){
            dg_hdg_saved.setDoubleValue(dg_hdg_cur.getValue());
            #print("C172 updating stored HI/DG heading to "~dg_hdg_saved.getValue());
            dg_offset_saved.setDoubleValue(dg_offset_cur.getValue());
            #print("C172 updating stored HI/DG offset to "~dg_offset_saved.getValue());
            dg_error_saved.setDoubleValue(dg_error_cur.getValue());
            #print("C172 updating stored HI/DG error to "~dg_error_saved.getValue());
    });
    dg_offset_startup_timer.start();
    
    # Handle realism settings
    setlistener("/sim/realism/instruments/realistic-instruments", setRealismInstruments, 1, 0);

    c172_timer.start();
});

setlistener("/sim/model/c172p/cabin-air-temp-in-range", func (node) {
    if (node.getValue()) {
        cabin_temp_timer.stop();
        logger.screen.green("Cabin temperature between 32F/0C and 90F/32C");
    }
    else {
        log_cabin_temp();
        cabin_temp_timer.start();
    }
}, 1, 0);

setlistener("/sim/model/c172p/fog-or-frost-increasing", func (node) {
    if (node.getValue()) {
        log_fog_frost();
        fog_frost_timer.start();
    }
    else {
        fog_frost_timer.stop();
    }
}, 1, 0);

# season-winter is a conversion value, see c172p-ground-effects.xml
setprop("/sim/startup/season-winter", getprop("/sim/startup/season") == "winter");
setlistener("/sim/startup/season", func (node) {
    setprop("/sim/startup/season-winter", node.getValue() == "winter");
}, 0, 0);

# rudder trim setting changes, manual or automatic
setlistener("/sim/model/c172p/ruddertrim-visible", func (node) {
    if (node.getValue()) {
        setprop("/controls/flight/rudder-trim", 0);
    } else
        setprop("/controls/flight/rudder-trim", 0.02);
}, 0, 0);

#fuel tank configuration switch
setlistener("/fdm/jsbsim/fuel/tank", func (node) {
    # Set fuel configuration
    set_fuel();
}, 0, 0);

#amphibious gear control
setlistener("sim/model/variant", func (node) {
    if (getprop("sim/model/variant") == 4) {
        setprop("controls/circuit-breakers/gear-advisory", 1);
        setprop("controls/circuit-breakers/hydraulic-pump", 1);
        setprop("controls/circuit-breakers/gear-select", 1);
        # check for ground type
        var on_water = getprop("fdm/jsbsim/hydro/active-norm");
        if (on_water) {
            setprop("controls/gear/gear-down-command", 0);
            setprop("controls/gear/gear-down", 0);
            setprop("fdm/jsbsim/gear/gear-pos-norm", 0);
        } else {
            setprop("controls/gear/gear-down-command", 1);
            setprop("controls/gear/gear-down", 1);
            setprop("fdm/jsbsim/gear/gear-pos-norm", 1);
        }
    }
}, 1, 0);


##########
# Handle Yoke transparency
##########
var updateYokeTransparency = func() {
    var hide = getprop("/sim/model/hide-yoke") or 0;
    if (hide == 1) {
        alpha = getprop("sim/model/hide-yoke-alpha-cmd");
    } else {
        alpha = 1;
    }
    setprop("/sim/model/hide-yoke-alpha", alpha);
}
setlistener("/sim/model/hide-yoke", updateYokeTransparency, 1, 0);
setlistener("/sim/model/hide-yoke-alpha-cmd", updateYokeTransparency, 1, 0);
