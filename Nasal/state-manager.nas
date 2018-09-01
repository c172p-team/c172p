# c172p state manager
# by Wayne Bragg 2018

var state_manager = func {

    if (!getprop("/sim/presets/airspeed-kt")) {
        setprop("/velocities/airspeed-kt", 100);
        setprop("/velocities/uBody-fps", 163);
        setprop("/orientation/pitch-deg", 0);
    }

    var auto_mixture = getprop("/fdm/jsbsim/engine/auto-mixture");
    setprop("/controls/engines/current-engine/mixture", auto_mixture);

    setprop("/engines/active-engine/running", 1);
    setprop("/engines/active-engine/auto-start", 1);
    setprop("/engines/active-engine/cranking", 1);
    setprop("/controls/switches/starter", 1);
    setprop("/controls/engines/engine[0]/primer", 3);
    setprop("/controls/engines/engine[0]/primer-lever", 0);
    setprop("/controls/engines/current-engine/throttle", 0.2);
    setprop("/controls/flight/elevator-trim", -0.03);
    setprop("/consumables/fuel/tank[0]/selected", 1);
    setprop("/consumables/fuel/tank[1]/selected", 1);
    setprop("/controls/circuit-breakers/aircond", 1);
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
    setprop("/controls/circuit-breakers/turn-coordinator", 1);
    setprop("/controls/circuit-breakers/cabin", 1);
    setprop("/controls/switches/dome-red", 0);
    setprop("/controls/switches/dome-white", 0);
    setprop("/controls/switches/magnetos", 3);
    setprop("/controls/switches/master-bat", 1);
    setprop("/controls/switches/master-alt", 1);
    setprop("/controls/switches/master-avionics", 1);
    setprop("/controls/gear/gear-down", 1);
    setprop("/controls/engines/current-engine/carb-heat", 1);
    setprop("/controls/lighting/beacon", 1);
    setprop("/controls/lighting/taxi-light", 0);
    setprop("/sim/model/c172p/brake-parking", 0);
    setprop("/fdm/jsbsim/running", 0);
    setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", 170);
    setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", 0);
    setprop("/sim/model/c172p/securing/tiedownL-visible", 0);
    setprop("/sim/model/c172p/securing/tiedownR-visible", 0);
    setprop("/sim/model/c172p/securing/tiedownT-visible", 0);
    setprop("/sim/model/c172p/securing/pitot-cover-visible", 0);
    setprop("/sim/model/c172p/securing/chock", 0);
    setprop("/sim/model/c172p/securing/cowl-plugs-visible", 0);
    setprop("/sim/model/c172p/cockpit/control-lock-placed", 0);

    var distance_nm = getprop("/sim/presets/offset-distance-nm") or "";

    var engine_running_check_delay = 5.0;
    settimer(func {
        if (!getprop("/engines/active-engine/running")) {
            gui.popupTip("The autostart failed to start the engine. You may have to adjust the mixture and start the engine manually.", 5);
        }
        setprop("/controls/switches/starter", 0);
        setprop("/engines/active-engine/auto-start", 0);

        if (distance_nm > 5) {
            setprop("/controls/engines/current-engine/throttle", 0.85);
            setprop("/controls/flight/flaps", .33);
        } else if (distance_nm > 1) {
            setprop("/controls/engines/current-engine/throttle", 0.80);
            setprop("/controls/flight/flaps", .66);
        } else {
            setprop("/controls/engines/current-engine/throttle", 0.75);
            setprop("/controls/flight/flaps", 1);
        }

        # Set the altimeter
        var pressure_sea_level = getprop("/environment/pressure-sea-level-inhg");
        setprop("/instrumentation/altimeter/setting-inhg", pressure_sea_level);

        # Set heading offset
        var magnetic_variation = getprop("/environment/magnetic-variation-deg");
        setprop("/instrumentation/heading-indicator/offset-deg", -magnetic_variation);

        # Setting instrument lights if needed
        var light_level = 1.0-getprop("/rendering/scene/diffuse/red");

        if (light_level > .6) {
            if (getprop("/controls/lighting/instruments-norm") == 0) {
                if (light_level > .6) light_level = .6;
                setprop("/controls/lighting/instruments-norm", light_level);
            }
            if (getprop("/controls/lighting/nav-lights") == 0) {
                setprop("/controls/lighting/nav-lights", 1);
            }
            if (getprop("/controls/lighting/strobe") == 0) {
                setprop("/controls/lighting/strobe", 1);
            }
            if (getprop("/controls/lighting/landing-lights") == 0) {
                setprop("/controls/lighting/landing-lights", 1);
            }
        }

    }, engine_running_check_delay);

};
