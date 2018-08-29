# c172p state manager
# by Wayne Bragg 2018

var onapproach_manager = func {

    setprop("/controls/flight/flaps", 1.0);
    setprop("/controls/gear/gear-down", 1);
    setprop("/sim/model/c172p/brake-parking", 0);
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
        setprop("/controls/engines/current-engine/throttle", 0.65);
       
    }, engine_running_check_delay);

};
