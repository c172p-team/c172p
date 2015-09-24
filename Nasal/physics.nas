var gears = "fdm/jsbsim/gear/";
var contact = "fdm/jsbsim/contact/";

var reset_all_damage = func
{
    setprop("/engines/active-engine/killed", 0);

	setprop(gears~"unit[0]/broken", 0);
	setprop(gears~"unit[1]/broken", 0);
	setprop(gears~"unit[2]/broken", 0);
	setprop(contact~"unit[4]/z-position", 50);
	setprop(contact~"unit[5]/z-position", 50);
	setprop(contact~"unit[9]/z-position", 35);
	setprop(contact~"unit[10]/z-position", 8);
	setprop(contact~"unit[11]/z-position", 60);
	setprop(contact~"unit[12]/z-position", 90);
	setprop("/fdm/jsbsim/wing-damage/left-wing", 0);
	setprop("/fdm/jsbsim/wing-damage/right-wing", 0);
	setprop("/fdm/jsbsim/crash", 0);
	setprop("/fdm/jsbsim/pontoon-damage/left-pontoon", 0);
	setprop("/fdm/jsbsim/pontoon-damage/right-pontoon", 0);

	# Reset contacts
	setprop(gears~"unit[0]/z-position", 0);
	setprop(gears~"unit[1]/z-position", 0);
	setprop(gears~"unit[2]/z-position", 0);
	setprop(contact~"unit[6]/z-position", 0);
	setprop(contact~"unit[7]/z-position", 0);
	setprop(contact~"unit[8]/z-position", 0);
	setprop(gears~"unit[19]/z-position", 0);
	setprop(gears~"unit[20]/z-position", 0);
	setprop(gears~"unit[21]/z-position", 0);
	setprop(gears~"unit[22]/z-position", 0);
}

var repair_damage = func {
    set_bushkit(getprop("/fdm/jsbsim/bushkit"));
};

var nosegearbroke = func (bushkit)
{
	if (bushkit == 0)
		setprop(contact~"unit[6]/z-position", -10);
	elsif (bushkit == 1)
		setprop(contact~"unit[6]/z-position", -18.5);
	elsif (bushkit == 2)
		setprop(contact~"unit[6]/z-position", -17.7);

	setprop(gears~"unit[0]/z-position", 0);
    killengine();
}

var leftgearbroke = func (bushkit)
{
	if (bushkit == 0)
		setprop(contact~"unit[7]/z-position", -9.5);
	elsif (bushkit == 1)
		setprop(contact~"unit[7]/z-position", -14.5);
	elsif (bushkit == 2)
		setprop(contact~"unit[7]/z-position", -16);

	setprop(gears~"unit[1]/z-position", 0);
}

var rightgearbroke = func (bushkit)
{
	if (bushkit == 0)
		setprop(contact~"unit[8]/z-position", -8);
	elsif (bushkit == 1)
		setprop(contact~"unit[8]/z-position", -15.5);
	elsif (bushkit == 2)
		setprop(contact~"unit[8]/z-position", -17.4);

	setprop(gears~"unit[2]/z-position", 0);
}

var bothwingcollapse = func
{
	setprop(contact~"unit[5]/z-position", -8);

    if (getprop("position/altitude-agl-m") < 10)
        killengine();
}

var upsidedown = func
{
	setprop(contact~"unit[12]/z-position", 90);

	if (getprop("/fdm/jsbsim/wing-damage/left-wing") == 1.0)
		setprop(contact~"unit[4]/z-position", 40);
	else
		setprop(contact~"unit[4]/z-position", 50);

	if (getprop("/fdm/jsbsim/wing-damage/right-wing") == 1.0)
		setprop(contact~"unit[5]/z-position", 40);
	else
		setprop(contact~"unit[5]/z-position", 50);
}

var killengine = func
{
	setprop("/engines/active-engine/killed", 1);
}

var defaulttires = func
{
	setprop(gears~"unit[0]/z-position", -19.5);
	setprop(gears~"unit[1]/z-position", -15.5);
	setprop(gears~"unit[2]/z-position", -15.5);
}

var medbushtires = func
{
	setprop(gears~"unit[0]/z-position", -22);
	setprop(gears~"unit[1]/z-position", -20);
	setprop(gears~"unit[2]/z-position", -20);
}

var largebushtires = func
{
	setprop(gears~"unit[0]/z-position", -22);
	setprop(gears~"unit[1]/z-position", -22);
	setprop(gears~"unit[2]/z-position", -22);
}

var pontoons = func
{
    # Empty, no z-position's to reset
}

var amphibious = func
{
	setprop(gears~"unit[19]/z-position", -62);
	setprop(gears~"unit[20]/z-position", -62);
	setprop(gears~"unit[21]/z-position", -50.5);
	setprop(gears~"unit[22]/z-position", -50.5);
}

# Check if on water
var poll_surface = func
{
    var engine_rpm = getprop("fdm/jsbsim/propulsion/engine/engine-rpm");
    var hydro_active_norm = getprop("/fdm/jsbsim/hydro/active-norm");
    var ground_splash_norm = getprop("/environment/aircraft-effects/ground-splash-norm");

    # Use engine RPM and speed to control ground splash if on the water
    # and below 2 meter AGL
	if (getprop("position/altitude-agl-m") < 2 and hydro_active_norm > 0) {
	    var groundspeed_half_pc = 0.005 * getprop("velocities/groundspeed-kt");
        var engine_rpm_almost_nothing = 0.005 * 0.065 * engine_rpm;

	    var splash_norm = std.max(engine_rpm_almost_nothing, groundspeed_half_pc);
	    setprop("/environment/aircraft-effects/ground-splash-norm", splash_norm);
	}
	elsif (ground_splash_norm > 0)
	    setprop("/environment/aircraft-effects/ground-splash-norm", ground_splash_norm - 0.005);

    setprop(contact~"unit[12]/z-position", !getprop(contact~"unit[12]/solid") ? 160 : 90);
    setprop(contact~"unit[4]/z-position", !getprop(contact~"unit[4]/solid") ? -10 : 50);
    setprop(contact~"unit[5]/z-position", !getprop(contact~"unit[5]/solid") ? -10 : 50);
    setprop(contact~"unit[9]/z-position", !getprop(contact~"unit[9]/solid") ? -25 : 35);
    setprop(contact~"unit[10]/z-position", !getprop(contact~"unit[10]/solid") ? -25 : 8);
    setprop(contact~"unit[11]/z-position", !getprop(contact~"unit[11]/solid") ? -25 : 60);
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
		poll_surface();
}

var set_bushkit = func (bushkit) {
    setprop("/fdm/jsbsim/damage/repairing", 1);

    reset_all_damage();

    # Reset z-position's
    if (bushkit == 0)
        defaulttires();
    elsif (bushkit == 1)
        medbushtires();
    elsif (bushkit == 2 or bushkit == 5)
        largebushtires();
    elsif (bushkit == 3)
        pontoons();
    elsif (bushkit == 4)
        amphibious();

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

    setlistener(gears~"unit[0]/broken", func (n) {
        if (n.getBoolValue()) {
            nosegearbroke(getprop("/fdm/jsbsim/bushkit"));
        }
    }, 0, 0);

    setlistener(gears~"unit[1]/broken", func (n) {
        if (n.getBoolValue()) {
            leftgearbroke(getprop("/fdm/jsbsim/bushkit"));
        }
    }, 0, 0);

    setlistener(gears~"unit[2]/broken", func (n) {
        if (n.getBoolValue()) {
            rightgearbroke(getprop("/fdm/jsbsim/bushkit"));
        }
    }, 0, 0);

    setlistener(contact~"unit[12]/WOW", func (n) {
        if (n.getBoolValue()) {
            gui.popupTip("Upside down!", 5);
            upsidedown();
        }
    }, 0, 0);

    setlistener("/fdm/jsbsim/crash", func (n) {
        if (n.getBoolValue()) {
            bothwingcollapse();
        }
    }, 0, 0);

    setlistener("/fdm/jsbsim/wing-damage/left-wing", func (n) {
        var left_wing = n.getValue();
        var right_wing = getprop("/fdm/jsbsim/wing-damage/right-wing");

        if (left_wing == 1.0) {
            if (right_wing == 1.0)
                gui.popupTip("Both wings BROKEN!", 5);
            else
                gui.popupTip("Left wing BROKEN!", 5);
        }
        elsif (left_wing > 0.0) {
            if (0.0 < right_wing and right_wing < 1.0)
                gui.popupTip("Both wings DAMAGED!", 5);
            else
                gui.popupTip("Left wing DAMAGED!", 5);

            if (getprop("position/altitude-agl-m") < 10)
                killengine();
        }

        # upsidedown() uses wing-damage/left-wing
        if (getprop(contact~"unit[12]/WOW"))
            upsidedown();
    }, 0, 0);

    setlistener("/fdm/jsbsim/wing-damage/right-wing", func (n) {
        var left_wing = getprop("/fdm/jsbsim/wing-damage/left-wing");
        var right_wing = n.getValue();

        if (right_wing == 1.0) {
            if (left_wing == 1.0)
                gui.popupTip("Both wings BROKEN!", 5);
            else
                gui.popupTip("Right wing BROKEN!", 5);
        }
        elsif (right_wing > 0.0) {
            if (0.0 < left_wing and left_wing < 1.0)
                gui.popupTip("Both wings DAMAGED!", 5);
            else
                gui.popupTip("Right wing DAMAGED!", 5);

            if (getprop("position/altitude-agl-m") < 10)
                killengine();
        }

        # upsidedown() uses wing-damage/right-wing
        if (getprop(contact~"unit[12]/WOW"))
            upsidedown();
    }, 0, 0);

    setlistener("/fdm/jsbsim/pontoon-damage/left-pontoon", func (n) {
        var left_pontoon = n.getValue();
        var right_pontoon = getprop("/fdm/jsbsim/pontoon-damage/right-pontoon");

        if (left_pontoon == 1) {
            if (right_pontoon == 1)
                gui.popupTip("Both pontoons BROKEN!", 5);
            else
                gui.popupTip("Left pontoon BROKEN!", 5);
        }
        elsif (left_pontoon == 2) {
            if (right_pontoon == 2)
                gui.popupTip("Both pontoons DAMAGED!", 5);
            else
                gui.popupTip("Left pontoon DAMAGED!", 5);
        }

        if (left_pontoon != 0)
            killengine();
    }, 0, 0);

    setlistener("/fdm/jsbsim/pontoon-damage/right-pontoon", func (n) {
        var left_pontoon = getprop("/fdm/jsbsim/pontoon-damage/left-pontoon");
        var right_pontoon = n.getValue();

        if (right_pontoon == 1) {
            if (left_pontoon == 1)
                gui.popupTip("Both pontoons BROKEN!", 5);
            else
                gui.popupTip("Right pontoon BROKEN!", 5);
        }
        elsif (right_pontoon == 2) {
            if (left_pontoon == 2)
                gui.popupTip("Both pontoons DAMAGED!", 5);
            else
                gui.popupTip("Right pontoon DAMAGED!", 5);
        }

        if (right_pontoon != 0)
            killengine();
    }, 0, 0);
});
