# write the c172p state to file and resume
# Addapted from Shuttle, Thorsten Renk 2016 - 2017
# by Wayne Bragg 2018

var save_state = func {

    var running = getprop("/engines/active-engine/running");
    var moving = getprop("/velocities/groundspeed-kt");
    var pitch = getprop("/orientation/pitch-deg");
    var roll = getprop("/orientation/roll-deg");

    if (running) {
        gui.popupTip("Engine must be turned off to save state!", 5.0);
        return;
    }
    if (moving > 7 or moving < -7) {
        gui.popupTip("Aircraft cannot be moving to save state!", 5.0);
        return;
    }
    if (pitch > 7 or roll > 7) {
        gui.popupTip("Slope too steep to save state!", 5.0);
        return;
    }

    var lat = getprop("/position/latitude-deg");
    setprop("/save/latitude-deg", lat);
    var lon = getprop("/position/longitude-deg");
    setprop("/save/longitude-deg", lon);
    var altitude = getprop("/position/altitude-ft");
    setprop("/save/altitude-ft", altitude);
    var heading = getprop("/orientation/heading-deg");
    setprop("/save/heading-deg", heading);
    var pitch = getprop("/orientation/pitch-deg");
    setprop("/save/pitch-deg", pitch);
    var roll = getprop("/orientation/roll-deg");
    setprop("/save/roll-deg", roll);
    var uBody = getprop("/velocities/uBody-fps");
    setprop("/save/uBody-fps", uBody);
    var vBody = getprop("/velocities/vBody-fps");
    setprop("/save/vBody-fps", vBody);
    var wBody = getprop("/velocities/wBody-fps");
    setprop("/save/wBody-fps", wBody);

    var hydro = getprop("/fdm/jsbsim/hydro/active-norm");
    setprop("/save/hydro", hydro);

    var tank1sel = getprop("/consumables/fuel/tank[0]/selected");
    var tank2sel = getprop("/consumables/fuel/tank[1]/selected");
    setprop("/save/tank1-select", tank1sel);
    setprop("/save/tank2-select", tank2sel);
    var tank1 = getprop("/consumables/fuel/tank[0]/level-lbs");
    var tank2 = getprop("/consumables/fuel/tank[1]/level-lbs");
    setprop("/save/tank1-level-lbs", tank1);
    setprop("/save/tank2-level-lbs", tank2);

    var throttle = getprop("/controls/engines/current-engine/throttle");
    setprop("/save/throttle", throttle);
    var mixture = getprop("/controls/engines/current-engine/mixture");
    setprop("/save/mixture", mixture);
    var primlever = getprop("/controls/engines/engine[0]/primer-lever");
    setprop("/save/primlever", primlever);

    var ptmas1 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]");
    var ptmas2 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]");
    var ptmas3 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[2]");
    var ptmas4 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[3]");
    var ptmas5 = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[4]");
    setprop("/save/ptmas1", ptmas1);
    setprop("/save/ptmas2", ptmas2);
    setprop("/save/ptmas3", ptmas3);
    setprop("/save/ptmas4", ptmas4);
    setprop("/save/ptmas5", ptmas5);

    var tiedownL = getprop("/sim/model/c172p/securing/tiedownL-visible");
    var tiedownR = getprop("/sim/model/c172p/securing/tiedownR-visible");
    var tiedownT = getprop("/sim/model/c172p/securing/tiedownT-visible");
    setprop("/save/tiedownL", tiedownL);
    setprop("/save/tiedownR", tiedownR);
    setprop("/save/tiedownT", tiedownT);
    var pitot = getprop("/sim/model/c172p/securing/pitot-cover-visible");
    setprop("/save/pitot", pitot);
    var chock = getprop("/sim/model/c172p/securing/chock");
    setprop("/save/chock", chock);
    var cowlplug = getprop("/sim/model/c172p/securing/cowl-plugs-visible");
    setprop("/save/cowlplug", cowlplug);
    var ctrllock = getprop("/sim/model/c172p/cockpit/control-lock-placed");
    setprop("/save/ctrllock", ctrllock);

    #getprop("/controls/circuit-breakers/aircond");
    #getprop("/controls/circuit-breakers/autopilot");
    #getprop("/controls/circuit-breakers/bcnlt");
    #getprop("/controls/circuit-breakers/flaps");
    #getprop("/controls/circuit-breakers/instr");
    #getprop("/controls/circuit-breakers/intlt");
    #getprop("/controls/circuit-breakers/landing");
    #getprop("/controls/circuit-breakers/master");
    #getprop("/controls/circuit-breakers/navlt");
    #getprop("/controls/circuit-breakers/pitot-heat");
    #getprop("/controls/circuit-breakers/radio1");
    #getprop("/controls/circuit-breakers/radio2");
    #getprop("/controls/circuit-breakers/radio3");
    #getprop("/controls/circuit-breakers/radio4");
    #getprop("/controls/circuit-breakers/radio5");
    #getprop("/controls/circuit-breakers/strobe");
    #getprop("/controls/circuit-breakers/turn-coordinator");

    var avionics = getprop("/controls/switches/master-avionics");
    setprop("/save/avionics", avionics);
    var alt = getprop("/controls/switches/master-alt");
    setprop("/save/alt", alt);
    var bat = getprop("/controls/switches/master-bat");
    setprop("/save/bat", bat);
    var magnetos = getprop("/controls/switches/magnetos");
    setprop("/save/magnetos", magnetos);
    var dome = getprop("/controls/switches/dome-white");
    setprop("/save/dome", dome);
    var flood = getprop("/controls/switches/dome-red");
    setprop("/save/flood", flood);
    var radionorm = getprop("/controls/lighting/radio-norm");
    setprop("/save/radionorm", radionorm);
    var domenorm = getprop("/controls/lighting/dome-white-norm");
    setprop("/save/domenorm", domenorm);
    var floodnorm = getprop("/controls/lighting/dome-norm");
    setprop("/save/floodnorm", floodnorm);
    var gpsnorm = getprop("/controls/lighting/gps-norm");
    setprop("/save/gpsnorm", gpsnorm);
    var gearled = getprop("/controls/lighting/gearled");
    setprop("/save/gearled", gearled);

    var nav = getprop("/controls/lighting/nav-lights");
    setprop("/save/nav", nav);
    var beacon = getprop("/controls/lighting/beacon");
    setprop("/save/beacon", beacon);
    var strobe = getprop("/controls/lighting/strobe");
    setprop("/save/strobe", strobe);
    var taxi = getprop("/controls/lighting/taxi-light");
    setprop("/save/taxi", taxi);
    var landing = getprop("/controls/lighting/landing-lights");
    setprop("/save/landing", landing);
    var instruments = getprop("/controls/lighting/instruments-norm");
    setprop("/save/instruments", instruments);

    var garmin = getprop("/sim/model/c172p/garmin196-visible");
    setprop("/save/garmin", garmin);

    var rdoornorm = getprop("/sim/model/door-positions/rightDoor/position-norm-effective");
    setprop("/save/rdoornorm", rdoornorm);
    var ldoornorm = getprop("/sim/model/door-positions/leftDoor/position-norm-effective");
    setprop("/save/ldoornorm", ldoornorm);
    var bdoornorm = getprop("/sim/model/door-positions/baggageDoor/position-norm-effective");
    setprop("/save/bdoornorm", bdoornorm);
    var lwindnorm = getprop("/sim/model/door-positions/leftWindow/position-norm");
    setprop("/save/lwindnorm", lwindnorm);
    var rwindnorm = getprop("/sim/model/door-positions/rightWindow/position-norm");
    setprop("/save/rwindnorm", rwindnorm);
    var odoornorm = getprop("/sim/model/door-positions/oilDoor/position-norm");
    setprop("/save/odoornorm", odoornorm);
    var gdoornorm = getprop("/sim/model/door-positions/gloveboxDoor/position-norm");
    setprop("/save/gdoornorm", gdoornorm);

    var variant = getprop("/sim/model/variant");
    setprop("/save/variant", variant);
    var bushkit = getprop("/fdm/jsbsim/bushkit");
    setprop("/save/bushkit", bushkit);

    var damage = getprop("/fdm/jsbsim/settings/damage");
    setprop("/save/damage", damage);

    var geardown = getprop("/controls/gear/gear-down");
    setprop("/save/geardown", geardown);
    var gearpos = getprop("/fdm/jsbsim/gear/gear-pos-norm");
    setprop("/save/gearpos", gearpos);
    var wrudder = getprop("/controls/gear/water-rudder");
    setprop("/save/wrudder", wrudder);
    var wrudderdown = getprop("/controls/gear/water-rudder-down");
    setprop("/save/wrudderdown", wrudderdown);
    var parkbrake = getprop("/sim/model/c172p/brake-parking");
    setprop("/save/parkbrake", parkbrake);
    var flaps = getprop("/controls/flight/flaps");
    setprop("/save/flaps", flaps);
    var flapsnorm = getprop("/surface-positions/flap-pos-norm");
    setprop("/save/flapsnorm", flapsnorm);
    var elevtrim = getprop("/controls/flight/elevator-trim");
    setprop("/save/elevtrim", elevtrim);
    var carbheat1 = getprop("/controls/anti-ice/engine[0]/carb-heat");
    setprop("/save/carbheat1", carbheat1);
    var carbheat2 = getprop("/controls/anti-ice/engine[1]/carb-heat");
    setprop("/save/carbheat2", carbheat2);
    var pitotheat = getprop("/controls/anti-ice/pitot-heat");
    setprop("/save/pitotheat", pitotheat);
    var cabheat = getprop("/environment/aircraft-effects/cabin-heat-set");
    setprop("/save/cabheat", cabheat);
    var cabair = getprop("/environment/aircraft-effects/cabin-air-set");
    setprop("/save/cabair", cabair);

    var anchor = getprop("/controls/mooring/anchor");
    setprop("/save/anchor", anchor);
    if (anchor) {
        var anchorlon = getprop("/fdm/jsbsim/mooring/anchor-lon");
        var anchorlat = getprop("/fdm/jsbsim/mooring/anchor-lat");
        setprop("/save/anchorlon", anchorlon);
        setprop("/save/anchorlat", anchorlat);
    }

    setprop("/save/valid", 1);

    # save state to specified file

    var filename = "save1.xml";
    #var filename = getprop("/sim/gui/dialogs/c172pSave/save/filename");
    var path = getprop("/sim/fg-home") ~ "/aircraft-data/c172pSave/"~filename;
    var nodeSave = props.globals.getNode("/save", 0);
    io.write_properties(path, nodeSave);

    print("Current state written to ", filename, " !");
}

#can be converted to multiple saved state files
var read_state_from_file = func (filename) {
    var path = getprop("/sim/fg-home") ~ "/aircraft-data/c172pSave/"~filename;
    var readNode = props.globals.getNode("/save", 0);
    io.read_properties(path, readNode);
}

var resume_state = func {

    # read state from specified file

    var filename = "save1.xml";
    var path = getprop("/sim/fg-home") ~ "/aircraft-data/c172pSave/"~filename;
    var readNode = props.globals.getNode("/save", 0);
    io.read_properties(path, readNode);

    var validfile = getprop("/save/valid");

    if (validfile) {
        setprop("/fdm/jsbsim/settings/damage", 0);
    } else {
        gui.popupTip("Valid saved state file not found, reverting to automatic state!", 5.0);
        return;
    }

    var lat = getprop("/save/latitude-deg");
    setprop("/position/latitude-deg", lat);
    var lon = getprop("/save/longitude-deg");
    setprop("/position/longitude-deg", lon);
    var pitch = getprop("/save/pitch-deg");
    setprop("/orientation/pitch-deg", pitch);
    var roll = getprop("/save/roll-deg");
    setprop("/orientation/roll-deg", roll);
    var uBody = getprop("/save/uBody-fps");
    setprop("/velocities/uBody-fps", uBody);
    var vBody = getprop("/save/vBody-fps");
    setprop("/velocities/vBody-fps", vBody);
    var wBody = getprop("/save/wBody-fps");
    setprop("/velocities/wBody-fps", wBody);

    var tank1sel = getprop("/save/tank1-select");
    var tank2sel = getprop("/save/tank2-select");
    setprop("/consumables/fuel/tank[0]/selected", tank1sel);
    setprop("/consumables/fuel/tank[1]/selected", tank2sel);
    var tank1 = getprop("/save/tank1-level-lbs");
    var tank2 = getprop("/save/tank2-level-lbs");
    setprop("/consumables/fuel/tank[0]/level-lbs", tank1);
    setprop("/consumables/fuel/tank[1]/level-lbs", tank2);

    var throttle = getprop("/save/throttle");
    setprop("/controls/engines/current-engine/throttle", throttle);
    var mixture = getprop("/save/mixture");
    setprop("/controls/engines/current-engine/mixture", mixture);
    var primlever = getprop("/save/primlever");
    setprop("/controls/engines/engine[0]/primer-lever", primlever);

    var ptmas1 = getprop("/save/ptmas1");
    var ptmas2 = getprop("/save/ptmas2");
    var ptmas3 = getprop("/save/ptmas3");
    var ptmas4 = getprop("/save/ptmas4");
    var ptmas5 = getprop("/save/ptmas5");
    setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]", ptmas1);
    setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]", ptmas2);
    setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[2]", ptmas3);
    setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[3]", ptmas4);
    setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[4]", ptmas5);

    var tiedownL = getprop("/save/tiedownL");
    var tiedownR = getprop("/save/tiedownR");
    var tiedownT = getprop("/save/tiedownT");
    setprop("/sim/model/c172p/securing/tiedownL-visible", tiedownL);
    setprop("/sim/model/c172p/securing/tiedownR-visible", tiedownR);
    setprop("/sim/model/c172p/securing/tiedownT-visible", tiedownT);
    var pitot = getprop("/save/pitot");
    setprop("/sim/model/c172p/securing/pitot-cover-visible", pitot);
    var chock = getprop("/save/chock");
    setprop("/sim/model/c172p/securing/chock", chock);
    var cowlplug = getprop("/save/cowlplug");
    setprop("/sim/model/c172p/securing/cowl-plugs-visible", cowlplug);
    var ctrllock = getprop("/save/ctrllock");
    setprop("/sim/model/c172p/cockpit/control-lock-placed", ctrllock);

    #getprop("/controls/circuit-breakers/aircond");
    #getprop("/controls/circuit-breakers/autopilot");
    #getprop("/controls/circuit-breakers/bcnlt");
    #getprop("/controls/circuit-breakers/flaps");
    #getprop("/controls/circuit-breakers/instr");
    #getprop("/controls/circuit-breakers/intlt");
    #getprop("/controls/circuit-breakers/landing");
    #getprop("/controls/circuit-breakers/master");
    #getprop("/controls/circuit-breakers/navlt");
    #getprop("/controls/circuit-breakers/pitot-heat");
    #getprop("/controls/circuit-breakers/radio1");
    #getprop("/controls/circuit-breakers/radio2");
    #getprop("/controls/circuit-breakers/radio3");
    #getprop("/controls/circuit-breakers/radio4");
    #getprop("/controls/circuit-breakers/radio5");
    #getprop("/controls/circuit-breakers/strobe");
    #getprop("/controls/circuit-breakers/turn-coordinator");

    var avionics = getprop("/save/avionics");
    setprop("/controls/switches/master-avionics", avionics);
    var alt = getprop("/save/alt");
    setprop("/controls/switches/master-alt", alt);
    var bat = getprop("/save/bat");
    setprop("/controls/switches/master-bat", bat);
    var magnetos = getprop("/save/magnetos");
    setprop("/controls/switches/magnetos", magnetos);
    var dome = getprop("/save/dome");
    setprop("/controls/switches/dome-white", dome);
    var flood = getprop("/save/flood");
    setprop("/controls/switches/dome-red", flood);
    var radionorm = getprop("/save/radionorm");
    setprop("/controls/lighting/radio-norm", radionorm);
    var domenorm = getprop("/save/domenorm");
    setprop("/controls/lighting/dome-white-norm", domenorm);
    var floodnorm = getprop("/save/floodnorm");
    setprop("/controls/lighting/dome-norm", floodnorm);
    var gpsnorm = getprop("/save/gpsnorm");
    setprop("/controls/lighting/gps-norm", gpsnorm);
    var gearled = getprop("/save/gearled");
    setprop("/controls/lighting/gearled", gearled);

    var nav = getprop("/save/nav");
    setprop("/controls/lighting/nav-lights", nav);
    var beacon = getprop("/save/beacon");
    setprop("/controls/lighting/beacon", beacon);
    var strobe = getprop("/save/strobe");
    setprop("/controls/lighting/strobe", strobe);
    var taxi = getprop("/save/taxi");
    setprop("/controls/lighting/taxi-light", taxi);
    var landing = getprop("/save/landing");
    setprop("/controls/lighting/landing-lights", landing);
    var instruments = getprop("/save/instruments");
    setprop("/controls/lighting/instruments-norm", instruments);

    var garmin = getprop("/save/garmin");
    setprop("/sim/model/c172p/garmin196-visible", garmin);
    var rdoornorm = getprop("/save/rdoornorm");
    setprop("/sim/model/door-positions/rightDoor/position-norm-effective", rdoornorm);
    var ldoornorm = getprop("/save/ldoornorm");
    setprop("/sim/model/door-positions/leftDoor/position-norm-effective", ldoornorm);
    var bdoornorm = getprop("/save/bdoornorm");
    setprop("/sim/model/door-positions/baggageDoor/position-norm-effective", bdoornorm);
    var lwindnorm = getprop("/save/lwindnorm");
    setprop("/sim/model/door-positions/leftWindow/position-norm", lwindnorm);
    var rwindnorm = getprop("/save/rwindnorm");
    setprop("/sim/model/door-positions/rightWindow/position-norm", rwindnorm);
    var odoornorm = getprop("/save/odoornorm");
    setprop("/sim/model/door-positions/oilDoor/position-norm", odoornorm);
    var gdoornorm = getprop("/save/gdoornorm");
    setprop("/sim/model/door-positions/gloveboxDoor/position-norm", gdoornorm);

    var variant = getprop("/save/variant");
    setprop("/sim/model/variant", variant);
    var bushkit = getprop("/save/bushkit");
    setprop("/fdm/jsbsim/bushkit", bushkit);

    var geardown = getprop("/save/geardown");
    setprop("/controls/gear/gear-down", geardown);
    var gearpos = getprop("/save/gearpos");
    setprop("/fdm/jsbsim/gear/gear-pos-norm", gearpos);
    var wrudder = getprop("/save/wrudder");
    setprop("/controls/gear/water-rudder", wrudder);
    var wrudderdown = getprop("/save/wrudderdown");
    setprop("/controls/gear/water-rudder-down", wrudderdown);
    var parkbrake = getprop("/save/parkbrake");
    setprop("/sim/model/c172p/brake-parking", parkbrake);
    var flaps = getprop("/save/flaps");
    setprop("/controls/flight/flaps", flaps);
    var flapsnorm = getprop("/save/flapsnorm");
    setprop("/surface-positions/flap-pos-norm", flapsnorm);
    var elevtrim = getprop("/save/elevtrim");
    setprop("/controls/flight/elevator-trim", elevtrim);
    var carbheat1 = getprop("/save/carbheat1");
    setprop("/controls/anti-ice/engine[0]/carb-heat", carbheat1);
    var carbheat2 = getprop("/save/carbheat2");
    setprop("/controls/anti-ice/engine[1]/carb-heat", carbheat2);
    var pitotheat = getprop("/save/pitotheat");
    setprop("/controls/anti-ice/pitot-heat", pitotheat);
    var cabheat = getprop("/save/cabheat");
    setprop("/environment/aircraft-effects/cabin-heat-set", cabheat);
    var cabair = getprop("/save/cabair");
    setprop("/environment/aircraft-effects/cabin-air-set", cabair);

    var hydro = getprop("/save/hydro");
    var anchor = getprop("/save/anchor");
    var damage = getprop("/save/damage");
    var heading = getprop("/save/heading-deg");
    var altitude = getprop("/save/altitude-ft");

    var heading_delay = 5.0;
    var altitude_delay = 2.0;
    var damage_delay = 5.0;

    if (anchor) {
        var anchorlon = getprop("/save/anchorlon");
        var anchorlat = getprop("/save/anchorlat");
        setprop("/fdm/jsbsim/mooring/anchor-lon", anchorlon);
        setprop("/fdm/jsbsim/mooring/anchor-lat", anchorlat);
        setprop("/sim/anchorbuoy/enable", 0);
        setprop("/fdm/jsbsim/mooring/anchor-dist", 0);
        setprop("/fdm/jsbsim/mooring/anchor-length", 0);
        setprop("/fdm/jsbsim/mooring/mooring-connected", 0);
        settimer(func {
            var headwind = getprop("/environment/wind-from-heading-deg");
            setprop("/orientation/heading-deg", headwind);
            setprop("/controls/mooring/anchor", anchor);
        }, heading_delay);
    } else {
        setprop("/orientation/heading-deg", heading);
    }

    if (!hydro) {
        settimer(func {
            setprop("/position/altitude-ft", altitude);
        }, altitude_delay);
    }

    settimer(func {
        setprop("/fdm/jsbsim/settings/damage", damage);
    }, damage_delay);

    print("State resumed!");
}
