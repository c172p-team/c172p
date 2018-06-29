var reset_all_damage = func
{
    setprop("/engines/active-engine/crash-engine", 0);
    setprop("/engines/active-engine/kill-engine", 0);

    # Landing gear
    setprop("/fdm/jsbsim/gear/unit[0]/broken", 0);
    setprop("/fdm/jsbsim/gear/unit[1]/broken", 0);
    setprop("/fdm/jsbsim/gear/unit[2]/broken", 0);

    # Wings
    setprop("/fdm/jsbsim/wing-damage/left-wing", 0);
    setprop("/fdm/jsbsim/wing-damage/right-wing", 0);

    # Collapsed wings
    setprop("/fdm/jsbsim/crash", 0);

    # Pontoons
    setprop("/fdm/jsbsim/pontoon-damage/left-pontoon", 0);
    setprop("/fdm/jsbsim/pontoon-damage/right-pontoon", 0);
    
    if (getprop("fdm/jsbsim/orientation/upside-down")) {
        setprop("/orientation/pitch-deg", 0);
        setprop("/orientation/roll-deg", 0);
    }
    
     # Repair engine damage
    setprop("/fdm/jsbsim/engine/damage-level", 0);
}

var repair_damage = func {
    set_bushkit(getprop("/fdm/jsbsim/bushkit"));
};

var killengine = func
{
    if (getprop("/fdm/jsbsim/settings/damage"))
        setprop("/engines/active-engine/crash-engine", 1);
}

# Hydro system loop

var anchor_pos = geo.Coord.new();
var aircraft_pos = geo.Coord.new();
var anchor_dist = 0.0;

var heading_diff = 0.0;
var wind_from_heading  = 0.0;
var aircraft_heading  = 0.0;
var wind_speed = 0.0;
var forward_speed = 0.0;

var poll_hydro = func
{
    var engine_rpm = getprop("fdm/jsbsim/propulsion/engine/engine-rpm");
    var hydro_active_norm = getprop("/fdm/jsbsim/hydro/active-norm");
    var ground_splash_norm = getprop("/environment/aircraft-effects/ground-splash-norm");

    # Use engine RPM and speed to control ground splash if on the water
    # and below 2 meter AGL
    if (getprop("position/altitude-agl-m") < 2 and hydro_active_norm > 0) {
        var groundspeed_half_pc = 0.005 * getprop("/velocities/groundspeed-kt");
        var engine_rpm_almost_nothing = 0.005 * 0.065 * engine_rpm;

        var splash_norm = std.max(engine_rpm_almost_nothing, groundspeed_half_pc);
        setprop("/environment/aircraft-effects/ground-splash-norm", splash_norm);
    }
    elsif (ground_splash_norm > 0)
        setprop("/environment/aircraft-effects/ground-splash-norm", ground_splash_norm - 0.005);

    if (getprop("/controls/mooring/anchor") and !getprop("fdm/jsbsim/mooring/mooring-connected")) {
        if (getprop("/fdm/jsbsim/mooring/anchor-length") == 0) {
            wind_from_heading = getprop("/environment/wind-from-heading-deg");
            aircraft_heading = getprop("/orientation/heading-deg");
            heading_diff = math.min(math.abs(aircraft_heading-wind_from_heading),math.abs(360-aircraft_heading+wind_from_heading),math.abs(360-wind_from_heading+aircraft_heading));
            wind_speed = getprop("/environment/windsock/wind-speed-kt");
            forward_speed = getprop("/fdm/jsbsim/hydro/vbx-fps");
            if (heading_diff > 85) {
                gui.popupTip("Face into the wind to set anchor", 5);
                setprop("/controls/mooring/anchor", 0);
                return;
            } elsif (wind_speed > 40) {
                gui.popupTip("Wind too high to anchor", 5);
                setprop("/controls/mooring/anchor", 0);
                return;
            } elsif (forward_speed > 7) {
                gui.popupTip("Can't anchor while moving forward", 5);
                setprop("/controls/mooring/anchor", 0);
                return;
            } elsif (getprop("/engines/active-engine/running")) {
                gui.popupTip("Can't anchor with engine running", 5);
                setprop("/controls/mooring/anchor", 0);
                return;
            } else {
                anchor_pos.set_latlon(getprop("/fdm/jsbsim/mooring/anchor-lat"), getprop("/fdm/jsbsim/mooring/anchor-lon"));
                setprop("fdm/jsbsim/mooring/latitude-deg", anchor_pos.lat());
                setprop("fdm/jsbsim/mooring/longitude-deg", anchor_pos.lon());
                setprop("fdm/jsbsim/mooring/altitude-ft", getprop("/position/ground-elev-ft"));
                anchor_dist = 0.0;
                setprop("/fdm/jsbsim/mooring/anchor-length", 1);
                setprop("/sim/anchorbuoy/enable", 1);
                setprop("fdm/jsbsim/mooring/mooring-connected", 1);
            }
        }
    }

    if (getprop("fdm/jsbsim/mooring/mooring-connected")) {
        aircraft_pos = geo.aircraft_position();
        anchor_dist = aircraft_pos.distance_to(anchor_pos);
        aircraft_heading = getprop("/orientation/heading-deg");
        var bearing = aircraft_pos.course_to(anchor_pos);
        var rel_bearing = (aircraft_heading - 180.0) - bearing;
        setprop("fdm/jsbsim/mooring/rope-yaw", rel_bearing);

        if (anchor_dist < (getprop("/fdm/jsbsim/mooring/rope-length-ft")*0.3048)-1) {
            setprop("fdm/jsbsim/mooring/rope-visible", 0);
        } else {
            setprop("fdm/jsbsim/mooring/rope-visible", 1);
        }
    }
}

# Duration in which no damage will occur. Assumes the aircraft has
# stabilized within this duration.
var bushkit_change_timeout = 3.0;

var physics_loop = func
{
    if (getprop("/sim/freeze/replay-state")) {
        return;
    }
    if (getprop("/fdm/jsbsim/bushkit") == 3 or getprop("/fdm/jsbsim/bushkit") == 4)
        poll_hydro();
    if (getprop("/fdm/jsbsim/contact/unit[9]/WOW") or getprop("/fdm/jsbsim/contact/unit[10]/WOW"))
        killengine();
    if (getprop("/sim/time/sun-angle-rad") > 1.52)
        setprop("/sim/rendering/shadow-volume-fix", 0);
    else
        setprop("/sim/rendering/shadow-volume-fix", 1);
}

var set_bushkit = func (bushkit) {
    setprop("/fdm/jsbsim/damage/repairing", 1);
    reset_all_damage();
    bushkit_changed_timer.restart(bushkit_change_timeout);
};

# This timer object is used to enable damage again a short time after
# changing to the last bush kit option.
var bushkit_changed_timer = maketimer(bushkit_change_timeout, func {
    setprop("/fdm/jsbsim/damage/repairing", 0);
});
bushkit_changed_timer.singleShot = 1;

setlistener("/sim/signals/fdm-initialized", func {
    # Update the 3D model when changing bush kit
    setlistener("/fdm/jsbsim/bushkit", func (n) {
        set_bushkit(n.getValue());
    }, 1, 0);

    setlistener("/fdm/jsbsim/crash", func (n) {
        if (n.getBoolValue() and getprop("position/altitude-agl-m") < 10) {
            killengine();
        }
    }, 0, 0);

    setlistener("/fdm/jsbsim/wing-damage/left-wing", func (n) {
        var damage = n.getValue();
        var altitude = getprop("position/altitude-agl-m");

        if (damage < 1.0 and damage > 0.0 and altitude < 10.0)
            killengine();
    }, 0, 0);

    setlistener("/fdm/jsbsim/wing-damage/right-wing", func (n) {
        var damage = n.getValue();
        var altitude = getprop("position/altitude-agl-m");

        if (damage < 1.0 and damage > 0.0 and altitude < 10.0)
            killengine();
    }, 0, 0);
});
