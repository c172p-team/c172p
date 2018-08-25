# c172p state manager system
# by Wayne Bragg 2018


var state_manager = func (state) {

    var onground = getprop("/sim/presets/onground") or "";
    var newstate = "";

    if (!onground) {
        newstate = "approach";
    }

    if (state == "Parked, secured") {
        newstate = "secured";
    }

    if (state == "Ready for Take-off, lights on") {
        newstate = "night";
    }

    if (state == "Alaska Mountain Top, bush tires") {
        newstate = "mountain";
    }

    if (state == "Columbia Glacier, skis") {
        newstate = "glacier";
    }

    if (state == "Lake Tahoe, floats") {
        newstate = "tahoe";
    }

    if (state == "Kachemak Bay, amphibious") {
        newstate = "kachemak";
    }

    if (state == "cruise") {
        setprop("/controls/flight/flaps", 0.0);
        setprop("/controls/gear/gear-down", 0);
    }

    if (newstate == "approach") {
        setprop("/controls/flight/flaps", 1.0);
        setprop("/controls/gear/gear-down", 1);
    }

    if (newstate == "secured") {
        setprop("/sim/model/c172p/securing/tiedownL-visible", 1);
        setprop("/sim/model/c172p/securing/tiedownR-visible", 1);
        setprop("/sim/model/c172p/securing/tiedownT-visible", 1);
        setprop("/consumables/fuel/tank[0]/selected", 0);
        setprop("/consumables/fuel/tank[1]/selected", 0);
        setprop("/sim/model/c172p/securing/pitot-cover-visible", 1);
        setprop("/sim/model/c172p/securing/chock", 1);
        setprop("/sim/model/c172p/securing/cowl-plugs-visible", 1);
        setprop("/sim/model/c172p/cockpit/control-lock-placed", 1);
    }

    if (state == "parking") {
        setprop("/sim/model/c172p/securing/tiedownL-visible", 0);
        setprop("/sim/model/c172p/securing/tiedownR-visible", 0);
        setprop("/sim/model/c172p/securing/tiedownT-visible", 0);
        setprop("/sim/model/c172p/securing/pitot-cover-visible", 0);
        setprop("/sim/model/c172p/securing/chock", 0);
        setprop("/sim/model/c172p/securing/cowl-plugs-visible", 0);
        setprop("/sim/model/c172p/cockpit/control-lock-placed", 0);
        setprop("/consumables/fuel/tank[0]/selected", 1);
        setprop("/consumables/fuel/tank[1]/selected", 1);
    }

    if (newstate == "secured" or state == "parking") {
        setprop("/sim/model/c172p/brake-parking", 1);
        setprop("/fdm/jsbsim/running", 0);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", 0);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", 0);
        setprop("/engines/active-engine/running", 0);
        setprop("/engines/active-engine/auto-start", 0);
        setprop("/engines/active-engine/cranking", 0);
        setprop("/controls/flight/flaps", 0.0);
        setprop("/controls/gear/gear-down", 1);
        setprop("/controls/switches/magnetos", 0);
        setprop("/controls/switches/master-bat", 0);
        setprop("/controls/switches/master-alt", 0);
        setprop("/controls/switches/master-avionics", 0);
        setprop("/controls/switches/starter", 0);
        setprop("/controls/engines/engine[0]/primer", 0);
        setprop("/controls/engines/engine[0]/primer-lever", 0);
        setprop("/controls/engines/engine[1]/primer", 0);
        setprop("/controls/engines/engine[1]/primer-lever", 0);
        setprop("/controls/engines/current-engine/throttle", 0.0);
        setprop("/controls/engines/current-engine/mixture", 0.0);
    }

    if (newstate == "mountain") {
        setprop("/controls/engines/active-engine", 1);
        setprop("/sim/model/c172p/brake-parking", 1);
        setprop("/controls/flight/flaps", 0.0);
        setprop("/sim/model/variant", 1);
        setprop("/fdm/jsbsim/bushkit", 1);
    }

    if (newstate == "glacier") {
        setprop("/controls/engines/active-engine", 1);
        setprop("/sim/model/c172p/brake-parking", 0);
        setprop("/controls/flight/flaps", 0.0);
        setprop("/sim/model/variant", 5);
        setprop("/fdm/jsbsim/bushkit", 5);
    }

    if (state == "take-off" or newstate == "night") {
        setprop("/sim/model/c172p/brake-parking", 1);
        setprop("/controls/flight/flaps", 0.0);
        setprop("/controls/gear/gear-down", 1);
    }

    if (newstate == "night") {
        setprop("/controls/switches/master-avionics", 1);
        setprop("/controls/lighting/taxi-light", 1);
        #setprop("/controls/lighting/landing-lights", 1);
        setprop("/controls/lighting/nav-lights", 1);
        setprop("/controls/lighting/beacon", 1);
        setprop("/controls/lighting/strobe", 1);
        setprop("/controls/lighting/instruments-norm", .5);
        setprop("/controls/lighting/radio-norm", .4);
    }

    if (newstate == "kachemak") {
        setprop("/controls/engines/active-engine", 1);
        setprop("/sim/model/variant", 4);
        setprop("/fdm/jsbsim/bushkit", 4);
    }

    if (newstate == "tahoe") {
        setprop("/controls/engines/active-engine", 0);
        setprop("/sim/model/variant", 3);
        setprop("/fdm/jsbsim/bushkit", 3);
    }

    if (newstate == "tahoe" or newstate == "kachemak") {
        setprop("/controls/flight/flaps", 1.0);
        setprop("/controls/gear/gear-down", 0);
    }

    if (newstate == "approach" or newstate == "tahoe" or newstate == "kachemak" or state == "cruise") {
        setprop("/sim/model/c172p/brake-parking", 0);
    }

    if (newstate == "approach" or state == "cruise" or state == "take-off" or newstate == "night" or newstate == "tahoe" or newstate == "kachemak" or newstate == "glacier" or newstate == "mountain") {
        setprop("/sim/model/c172p/securing/tiedownL-visible", 0);
        setprop("/sim/model/c172p/securing/tiedownR-visible", 0);
        setprop("/sim/model/c172p/securing/tiedownT-visible", 0);
        setprop("/sim/model/c172p/securing/pitot-cover-visible", 0);
        setprop("/sim/model/c172p/securing/chock", 0);
        setprop("/sim/model/c172p/securing/cowl-plugs-visible", 0);
        setprop("/sim/model/c172p/cockpit/control-lock-placed", 0);
        setprop("/fdm/jsbsim/running", 0);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", 170);
        setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", 0);
        setprop("/consumables/fuel/tank[0]/selected", 1);
        setprop("/consumables/fuel/tank[1]/selected", 1);
        setprop("/engines/active-engine/running", 1);
        setprop("/engines/active-engine/auto-start", 1);
        setprop("/engines/active-engine/cranking", 1);
        setprop("/controls/switches/magnetos", 3);
        setprop("/controls/switches/master-bat", 1);
        setprop("/controls/switches/master-alt", 1);
        setprop("/controls/switches/master-avionics", 1);
        setprop("/controls/switches/starter", 1);
        setprop("/controls/engines/engine[0]/primer", 3);
        setprop("/controls/engines/engine[0]/primer-lever", 0);
        setprop("/controls/engines/engine[1]/primer", 3);
        setprop("/controls/engines/engine[1]/primer-lever", 0);
        setprop("/controls/engines/current-engine/throttle", 0.2);
        setprop("/controls/engines/current-engine/mixture", 0.95);

        var engine_running_check_delay = 5.0;
        settimer(func {
            if (!getprop("/engines/active-engine/running")) {
                gui.popupTip("The autostart failed to start the engine. You may have to adjust the mixture and start the engine manually.", 5);
            }
            setprop("/controls/switches/starter", 0);
            setprop("/engines/active-engine/auto-start", 0);

            if (newstate == "approach" or newstate == "tahoe" or newstate == "kachemak") {
                setprop("/controls/engines/current-engine/throttle", 0.65);
            }
            if (state == "cruise") {
                setprop("/controls/engines/current-engine/throttle", 0.80);
            }
        }, engine_running_check_delay);
    }

};
