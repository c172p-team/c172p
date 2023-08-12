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

    var tank1sel = getprop("/consumables/fuel/tank[0]/selected");
    var tank2sel = getprop("/consumables/fuel/tank[1]/selected");
    var tank3sel = getprop("/consumables/fuel/tank[2]/selected");
    var tank4sel = getprop("/consumables/fuel/tank[3]/selected");
    setprop("/save/tank1-select", tank1sel);
    setprop("/save/tank2-select", tank2sel);
    setprop("/save/tank3-select", tank3sel);
    setprop("/save/tank4-select", tank4sel);
    var tank1 = getprop("/consumables/fuel/tank[0]/level-lbs");
    var tank2 = getprop("/consumables/fuel/tank[1]/level-lbs");
    var tank3 = getprop("/consumables/fuel/tank[2]/level-lbs");
    var tank4 = getprop("/consumables/fuel/tank[3]/level-lbs");
    setprop("/save/tank1-level-lbs", tank1);
    setprop("/save/tank2-level-lbs", tank2);
    setprop("/save/tank3-level-lbs", tank3);
    setprop("/save/tank4-level-lbs", tank4);
    var ftank = getprop("/fdm/jsbsim/fuel/tank");
    setprop("/save/ftank", ftank);

    var savebat = getprop("/systems/electrical/save-battery-charge");
    setprop("/save/savebat", savebat);

    if (!getprop("/controls/panel/glass")) {
        var savebatp = getprop("/systems/electrical/battery-charge-percent");
        setprop("/save/savebatp", savebatp);
    } else {
        var savebatpa = getprop("/systems/electrical/battery-charge-percent/a");
        setprop("/save/savebatpa", savebatpa);
        var savebatpb = getprop("/systems/electrical/battery-charge-percent/b");
        setprop("/save/savebatpb", savebatpb);
    }

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

    if (!getprop("/controls/panel/glass")) {
        var garmin = getprop("/sim/model/c172p/garmin196-visible");
        setprop("/save/garmin", garmin);
    }

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
    var parkbrake = getprop("/controls/gear/brake-parking");
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
    var ruddertrim = getprop("/sim/model/c172p/ruddertrim-visible");
    setprop("/save/ruddertrim", ruddertrim);
    var oventleft = getprop("/controls/climate-control/overhead-vent-front-left");
    setprop("/save/oventleft", oventleft);
    var oventright = getprop("/controls/climate-control/overhead-vent-front-right");
    setprop("/save/oventright", oventright);

    var immat = getprop("/sim/model/c172p/immat-on-panel");
    setprop("/save/immat", immat);
    var livery = getprop("/sim/model/livery/name");
    setprop("/save/livery", livery);
    var occupants = getprop("/sim/model/occupants");
    setprop("/save/occupants", occupants);
    var frstfog = getprop("/sim/model/c172p/enable-fog-frost");
    setprop("/save/frstfog", frstfog);
    var digitalclock = getprop("/sim/model/c172p/digitalclock-visible");
    setprop("/save/digitalclock", digitalclock);

    #var userviewx = getprop("/sim/current-view/user/x-offset-m");
    #setprop("/save/userviewx", userviewx);
    #var userviewy = getprop("/sim/current-view/user/y-offset-m");
    #setprop("/save/userviewy", userviewy);
    #var userviewz = getprop("/sim/current-view/user/z-offset-m");
    #setprop("/save/userviewz", userviewz);
    #var userviewp = getprop("/sim/current-view/user/pitch-offset-deg");
    #setprop("/save/userviewp", userviewp);
    #var userviewf = getprop("/sim/current-view/user/default-field-of-view-deg");
    #setprop("/save/userviewf", userviewf);

    #fg1000
    var glasspnl = getprop("/controls/panel/glass");
    setprop("/save/glasspnl", glasspnl);
    var autopilot = getprop("/controls/panel/kap140");
    setprop("/save/autopilot", autopilot);
    var stbybatt = getprop("/controls/switches/stby-batt");
    setprop("/save/stbybatt", stbybatt);
    var batttest = getprop("/controls/lighting/batt-test-lamp-norm");
    setprop("/save/batttest", batttest);
    var avionicsn = getprop("/controls/lighting/avionics-norm");
    setprop("/save/avionicsn", avionicsn);
    var pedestaln = getprop("/controls/lighting/pedestal-norm");
    setprop("/save/pedestaln", pedestaln);
    var swcbn = getprop("/controls/lighting/swcb-norm");
    setprop("/save/swcbn", swcbn);
    var stbyn = getprop("/controls/lighting/stby-norm");
    setprop("/save/stbyn", stbyn);
    var domeLn = getprop("/controls/lighting/domeL-norm");
    setprop("/save/domeLn", domeLn);
    var domeRn = getprop("/controls/lighting/domeR-norm");
    setprop("/save/domeRn", domeRn);
    var mfdlight = getprop("/instrumentation/FG1000/Lightmap");
    setprop("/save/mfdlight", mfdlight);
    var com1micbtn = getprop("/instrumentation/audio-panel/com1-mic-btn");
    setprop("/save/com1-mic-btn", com1micbtn);
    var com2micbtn = getprop("/instrumentation/audio-panel/com2-mic-btn");
    setprop("/save/com2-mic-btn", com2micbtn);
    var com3micbtn = getprop("/instrumentation/audio-panel/com3-mic-btn");
    setprop("/save/com3-mic-btn", com3micbtn);
    var com12btn = getprop("/instrumentation/audio-panel/com12-btn");
    setprop("/save/com12-btn", com12btn);
    var pabtn = getprop("/instrumentation/audio-panel/pa-btn");
    setprop("/save/pa-btn", pabtn);
    var mkrmutebtn = getprop("/instrumentation/audio-panel/mkr-mute-btn");
    setprop("/save/mkr-mute-btn", mkrmutebtn);
    var dmebtn = getprop("/instrumentation/audio-panel/dme-btn");
    setprop("/save/dme-btn", dmebtn);
    var adfbtn = getprop("/instrumentation/audio-panel/adf-btn");
    setprop("/save/adf-btn", adfbtn);
    var auxbtn = getprop("/instrumentation/audio-panel/aux-btn");
    setprop("/save/aux-btn", auxbtn);
    var mansqbtn = getprop("/instrumentation/audio-panel/man-sq-btn");
    setprop("/save/man-sq-btn", mansqbtn);
    var pilotbtn = getprop("/instrumentation/audio-panel/pilot-btn");
    setprop("/save/pilot-btn", pilotbtn);
    var com1btn = getprop("/instrumentation/audio-panel/com1-btn");
    setprop("/save/com1-btn", com1btn);
    var com2btn = getprop("/instrumentation/audio-panel/com2-btn");
    setprop("/save/com2-btn", com2btn);
    var com3btn = getprop("/instrumentation/audio-panel/com3-btn");
    setprop("/save/com3-btn", com3btn);
    var telbtn = getprop("/instrumentation/audio-panel/tel-btn");
    setprop("/save/tel-btn", telbtn);
    var spkrbtn = getprop("/instrumentation/audio-panel/spkr-btn");
    setprop("/save/spkr-btn", spkrbtn);
    var hisensbtn = getprop("/instrumentation/audio-panel/hi-sens-btn");
    setprop("/save/hi-sens-btn", hisensbtn);
    var nav1btn = getprop("/instrumentation/audio-panel/nav1-btn");
    setprop("/save/nav1-btn", nav1btn);
    var nav2btn = getprop("/instrumentation/audio-panel/nav2-btn");
    setprop("/save/nav2-btn", nav2btn);
    var playbtn = getprop("/instrumentation/audio-panel/play-btn");
    setprop("/save/play-btn", playbtn);
    var copltbtn = getprop("/instrumentation/audio-panel/coplt-btn");
    setprop("/save/coplt-btn", copltbtn);
    var powerbtn = getprop("/instrumentation/comm/power-btn");
    setprop("/save/power-btn", powerbtn);
    var cvolume = getprop("/instrumentation/comm/volume");
    setprop("/save/cvolume", cvolume);
    var audiobtn = getprop("/instrumentation/marker-beacon/audio-btn");
    setprop("/save/audio-btn", audiobtn);
    var ident = getprop("/instrumentation/dme/ident");
    setprop("/save/ident", ident);
    var identaudible = getprop("/instrumentation/adf/ident-audible");
    setprop("/save/ident-audible", identaudible);

    var anchorconnect = getprop("/fdm/jsbsim/mooring/mooring-connected");
    setprop("/save/anchorconnect", anchorconnect);
    var anchor = getprop("/controls/mooring/anchor");
    setprop("/save/anchor", anchor);
    if (anchor) {
        var anchorlon = getprop("/fdm/jsbsim/mooring/anchor-lon");
        var anchorlat = getprop("/fdm/jsbsim/mooring/anchor-lat");
        setprop("/save/anchorlon", anchorlon);
        setprop("/save/anchorlat", anchorlat);
    }

    # the scenario description
    var timestring = getprop("/sim/time/real/year");
    timestring = timestring~ "-"~getprop("/sim/time/real/month");
    timestring = timestring~ "-"~getprop("/sim/time/real/day");
    timestring = timestring~ "-"~getprop("/sim/time/real/hour");

    var minute = getprop("/sim/time/real/minute");
    if (minute < 10) {minute = "0"~minute;}
    timestring = timestring~ ":"~minute;

    var description = getprop("/sim/gui/dialogs/c172p/save/description");

    setprop("/save/description", description);
    setprop("/save/timestring", timestring);

    # save state to specified file

    var filename = getprop("/sim/gui/dialogs/c172p/save/filename");
    var path = getprop("/sim/fg-home") ~ "/aircraft-data/c172pSave/"~filename;
    var nodeSave = props.globals.getNode("/save", 0);
    io.write_properties(path, nodeSave);

    print("Current state written to ", filename, " !");
}

var read_state_from_file = func (filename) {

    # read state from specified file

    var path = getprop("/sim/fg-home") ~ "/aircraft-data/c172pSave/"~filename;
    var readNode = props.globals.getNode("/save", 0);

    io.read_properties(path, readNode);

}

var resume_state = func {

    setprop("/fdm/jsbsim/settings/damage", 0);

    c172p.oil_consumption.stop();

    setprop("/sim/presets/airport-id", "");
    var lat = getprop("/save/latitude-deg");
    setprop("/sim/presets/latitude-deg", lat);
    var lon = getprop("/save/longitude-deg");
    setprop("/sim/presets/longitude-deg", lon);
    var pitch = getprop("/save/pitch-deg");
    setprop("/sim/presets/pitch-deg", pitch);
    var roll = getprop("/save/roll-deg");
    setprop("/sim/presets/roll-deg", roll);
    var uBody = getprop("/save/uBody-fps");
    setprop("/sim/presets/uBody-fps", uBody);
    var vBody = getprop("/save/vBody-fps");
    setprop("/sim/presets/vBody-fps", vBody);
    var wBody = getprop("/save/wBody-fps");
    setprop("/sim/presets/wBody-fps", wBody);
    setprop("/sim/presets/altitude-ft", -9999);
    setprop("/sim/presets/airspeed-kt", 0);
    setprop("/sim/presets/offset-distance-nm", 0);
    setprop("/sim/presets/glideslope-deg", 0);
    setprop("/sim/presets/runway", "");
    setprop("/sim/presets/parkpos", "");
    setprop("/sim/presets/runway-requested", 0);

    var heading = getprop("/save/heading-deg");
    var anchorconnect = getprop("/save/anchorconnect");
    setprop("/fdm/jsbsim/mooring/mooring-connected", anchorconnect);
    if (!anchorconnect) {
        setprop("/sim/presets/heading-deg", heading);
    }

    fgcommand("reposition");

    var load_delay = 2.0;
    settimer(func {

        var tank1sel = getprop("/save/tank1-select");
        var tank2sel = getprop("/save/tank2-select");
        var tank3sel = getprop("/save/tank3-select");
        var tank4sel = getprop("/save/tank4-select");
        setprop("/consumables/fuel/tank[0]/selected", tank1sel);
        setprop("/consumables/fuel/tank[1]/selected", tank2sel);
        setprop("/consumables/fuel/tank[2]/selected", tank3sel);
        setprop("/consumables/fuel/tank[3]/selected", tank4sel);
        var tank1 = getprop("/save/tank1-level-lbs");
        var tank2 = getprop("/save/tank2-level-lbs");
        var tank3 = getprop("/save/tank3-level-lbs");
        var tank4 = getprop("/save/tank4-level-lbs");
        setprop("/consumables/fuel/tank[0]/level-lbs", tank1);
        setprop("/consumables/fuel/tank[1]/level-lbs", tank2);
        setprop("/consumables/fuel/tank[2]/level-lbs", tank3);
        setprop("/consumables/fuel/tank[3]/level-lbs", tank4);
        var ftank = getprop("/save/ftank");
        setprop("/fdm/jsbsim/fuel/tank", ftank);

        var savebat = getprop("/save/savebat");
        setprop("/systems/electrical/save-battery-charge", savebat);
        
        if (!getprop("/controls/panel/glass")) {
            var savebatp = getprop("/save/savebatp");   
            setprop("/systems/electrical/battery-charge-percent", savebatp);
        } else {
            var savebatpa = getprop("/save/savebatpa"); 
            setprop("/systems/electrical/battery-charge-percent/a", savebatpa);
            var savebatpb = getprop("/save/savebatpb");
            setprop("/systems/electrical/battery-charge-percent/b", savebatpb);
        }

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

        if (!getprop("/controls/panel/glass")) {
            var garmin = getprop("/save/garmin");
            setprop("/sim/model/c172p/garmin196-visible", garmin);
        }

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
        setprop("/controls/gear/brake-parking", parkbrake);
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
        var ruddertrim = getprop("/save/ruddertrim");
        setprop("/sim/model/c172p/ruddertrim-visible", ruddertrim);
        var oventleft = getprop("/save/oventleft");
        setprop("/controls/climate-control/overhead-vent-front-left", oventleft);
        var oventright = getprop("/save/oventright");
        setprop("/controls/climate-control/overhead-vent-front-right", oventright);

        var immat = getprop("/save/immat");
        setprop("/sim/model/c172p/immat-on-panel", immat);
        var livery = getprop("/save/livery");
        setprop("/sim/model/livery/name", livery);
        var occupants = getprop("/save/occupants");
        setprop("/sim/model/occupants", occupants);
        var frstfog = getprop("/save/frstfog");
        setprop("/sim/model/c172p/enable-fog-frost", frstfog);
        var digitalclock = getprop("/save/digitalclock");
        setprop("/sim/model/c172p/digitalclock-visible", digitalclock);

        #var userviewx = getprop("/save/userviewx");
        #setprop("/sim/current-view/user/x-offset-m", userviewx);
        #var userviewy = getprop("/save/userviewy");
        #setprop("/sim/current-view/user/y-offset-m", userviewy);
        #var userviewz = getprop("/save/userviewz");
        #setprop("/sim/current-view/user/z-offset-m", userviewz);
        #var userviewp = getprop("/save/userviewp");
        #setprop("/sim/current-view/user/pitch-offset-deg", userviewp);
        #var userviewf = getprop("/save/userviewf");
        #setprop("/sim/current-view/user/default-field-of-view-deg", userviewf);

        #fg1000
        var glasspnl = getprop("/save/glasspnl");
        setprop("/controls/panel/glass", glasspnl);
        var autopilot = getprop("/save/autopilot");
        setprop("/controls/panel/kap140", autopilot);
        var stbybatt = getprop("/save/stbybatt");
        setprop("/controls/switches/stby-batt", stbybatt);
        var batttest = getprop("/save/batttest");
        setprop("/controls/lighting/batt-test-lamp-norm", batttest);
        var avionicsn = getprop("/save/avionicsn");
        setprop("/controls/lighting/avionics-norm", avionicsn);
        var pedestaln = getprop("/save/pedestaln");
        setprop("/controls/lighting/pedestal-norm", pedestaln);
        var swcbn = getprop("/save/swcbn");
        setprop("/controls/lighting/swcb-norm", swcbn);
        var stbyn = getprop("/save/stbyn");
        setprop("/controls/lighting/stby-norm", stbyn);
        var domeLn = getprop("/save/domeLn");
        setprop("/controls/lighting/domeL-norm", domeLn);
        var domeRn = getprop("/save/domeRn");
        setprop("/controls/lighting/domeR-norm", domeRn);
        var mfdlight = getprop("/save/mfdlight");
        setprop("/instrumentation/FG1000/Lightmap", mfdlight);
        var com1micbtn = getprop("/save/com1-mic-btn");
        setprop("/instrumentation/audio-panel/com1-mic-btn", com1micbtn);
        var com2micbtn = getprop("/save/com2-mic-btn");
        setprop("/instrumentation/audio-panel/com2-mic-btn", com2micbtn);
        var com3micbtn = getprop("/save/com3-mic-btn");
        setprop("/instrumentation/audio-panel/com3-mic-btn", com3micbtn);
        var com12btn = getprop("/save/com12-btn");
        setprop("/instrumentation/audio-panel/com12-btn", com12btn);
        var pabtn = getprop("/save/pa-btn");
        setprop("/instrumentation/audio-panel/pa-btn", pabtn);
        var mkrmutebtn = getprop("/save/mkr-mute-btn");
        setprop("/instrumentation/audio-panel/mkr-mute-btn", mkrmutebtn);
        var dmebtn = getprop("/save/dme-btn");
        setprop("/instrumentation/audio-panel/dme-btn", dmebtn);
        var adfbtn = getprop("/save/adf-btn");
        setprop("/instrumentation/audio-panel/adf-btn", adfbtn);
        var auxbtn = getprop("/save/aux-btn");
        setprop("/instrumentation/audio-panel/aux-btn", auxbtn);
        var mansqbtn = getprop("/save/man-sq-btn");
        setprop("/instrumentation/audio-panel/man-sq-btn", mansqbtn);
        var pilotbtn = getprop("/save/pilot-btn");
        setprop("/instrumentation/audio-panel/pilot-btn", pilotbtn);
        var com1btn = getprop("/save/com1-btn");
        setprop("/instrumentation/audio-panel/com1-btn", com1btn);
        var com2btn = getprop("/save/com2-btn");
        setprop("/instrumentation/audio-panel/com2-btn", com2btn);
        var com3btn = getprop("/save/com3-btn");
        setprop("/instrumentation/audio-panel/com3-btn", com3btn);
        var telbtn = getprop("/save/tel-btn");
        setprop("/instrumentation/audio-panel/tel-btn", telbtn);
        var spkrbtn = getprop("/save/spkr-btn");
        setprop("/instrumentation/audio-panel/spkr-btn", spkrbtn);
        var hisensbtn = getprop("/save/hi-sens-btn");
        setprop("/instrumentation/audio-panel/hi-sens-btn", hisensbtn);
        var nav1btn = getprop("/save/nav1-btn");
        setprop("/instrumentation/audio-panel/nav1-btn", nav1btn);
        var nav2btn = getprop("/save/nav2-btn");
        setprop("/instrumentation/audio-panel/nav2-btn", nav2btn);
        var playbtn = getprop("/save/play-btn");
        setprop("/instrumentation/audio-panel/play-btn", playbtn);
        var copltbtn = getprop("/save/coplt-btn");
        setprop("/instrumentation/audio-panel/coplt-btn", copltbtn);
        var powerbtn = getprop("/save/power-btn");
        setprop("/instrumentation/comm/power-btn", powerbtn);
        var cvolume = getprop("/save/cvolume");
        setprop("/instrumentation/comm/volume", cvolume);
        var audiobtn = getprop("/save/audio-btn");
        setprop("/instrumentation/marker-beacon/audio-btn", audiobtn);
        var ident = getprop("/save/ident");
        setprop("/instrumentation/dme/ident", ident);
        var identaudible = getprop("/save/ident-audible");
        setprop("/instrumentation/adf/ident-audible", identaudible);

        var anchor = getprop("/save/anchor");
        setprop("/controls/mooring/anchor", anchor);

        var damage = getprop("/save/damage");
        #var altitude = getprop("/save/altitude-ft");

        var heading_delay = 3.0;
        var mooring_delay = 4.0;
        var damage_delay = 5.0;

        if (anchorconnect) {
            settimer(func {
                var headwind = getprop("/environment/wind-from-heading-deg");
                setprop("/orientation/heading-deg", headwind);
            }, heading_delay);
            settimer(func {
                var anchorlon = getprop("/save/anchorlon");
                var anchorlat = getprop("/save/anchorlat");
                setprop("/fdm/jsbsim/mooring/anchor-lon", anchorlon);
                setprop("/fdm/jsbsim/mooring/anchor-lat", anchorlat);
                setprop("/sim/anchorbuoy/enable", 0);
                setprop("/fdm/jsbsim/mooring/anchor-dist", 0);
                setprop("/fdm/jsbsim/mooring/anchor-length", 0);
                setprop("/fdm/jsbsim/mooring/mooring-connected", 0);
                setprop("/controls/mooring/anchor", anchor);
            }, mooring_delay);
        }

        settimer(func {
            setprop("/fdm/jsbsim/settings/damage", damage);
        }, damage_delay);

        print("State resumed!");

    }, load_delay);
}
