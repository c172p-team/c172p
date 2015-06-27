var max_lift_force = getprop("limits/max-lift-force");
var limit_vne = getprop("limits/vne");

var aero_coeff = "fdm/jsbsim/aero/coefficient/";

var get_gear_force = func (index, spring_coeff, damping_coeff) {
    # Force-on-gear = (compression-ft) x (spring_coeff) + (compression-velocity-fps) x (damping_coeff)

    var compr = getprop("/fdm/jsbsim/gear/unit", index, "compression-ft");
    var compr_vel = getprop("/fdm/jsbsim/gear/unit", index, "compression-velocity-fps");
    return spring_coeff * compr + damping_coeff * compr_vel;
};

# MUST be the same coefficients as spring_coeff and damping_coeff in the FDM for nose and main gear
var force0 = get_gear_force(0, 1800, 600);
var force1 = get_gear_force(1, 5400, 400);
var force2 = get_gear_force(2, 5400, 400);

var gear_side_force = getprop("/fdm/jsbsim/forces/fby-gear-lbs");

var gears = "fdm/jsbsim/gear/";
var contact = "fdm/jsbsim/contact/";

var fairing1 = 0;
var fairing2 = 0;
var fairing3 = 0;

var resetalldamage = func
{
    setprop("/engines/active-engine/killed", 0);

	setprop(gears~"unit[0]/broken", 0);
	setprop(gears~"unit[1]/broken", 0);
	setprop(gears~"unit[2]/broken", 0);
	setprop(contact~"unit[4]/broken", 0);
	setprop(contact~"unit[5]/broken", 0);
	setprop(contact~"unit[4]/z-position", 50);
	setprop(contact~"unit[5]/z-position", 50);
	setprop(contact~"unit[9]/z-position", 35);
	setprop(contact~"unit[10]/z-position", 8);
	setprop(contact~"unit[11]/z-position", 60);
	setprop(contact~"unit[12]/z-position", 90);
	setprop("/fdm/jsbsim/wing-damage/left-wing", 0);
	setprop("/fdm/jsbsim/wing-damage/right-wing", 0);
	setprop("/fdm/jsbsim/crash", 0);
	setprop("/fdm/jsbsim/left-pontoon/damaged", 0);
	setprop("/fdm/jsbsim/left-pontoon/broken", 0);
	setprop("/fdm/jsbsim/right-pontoon/damaged", 0);
	setprop("/fdm/jsbsim/right-pontoon/broken", 0);
}

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
	setprop(gears~"unit[0]/broken", 1);
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
	setprop(gears~"unit[1]/broken", 1);
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
	setprop(gears~"unit[2]/broken", 1);
}

var leftpontoondamaged = func (bushkit)
{
	if ((bushkit == 3 or bushkit == 4) and !getprop("/fdm/jsbsim/left-pontoon/broken"))
		setprop("/fdm/jsbsim/left-pontoon/damaged", 1);

    killengine();
}

var leftpontoonbroke = func (bushkit)
{
	if (bushkit == 3 or bushkit == 4) {
		setprop("/fdm/jsbsim/left-pontoon/damaged", 0);
		setprop("/fdm/jsbsim/left-pontoon/broken", 1);
	}
    killengine();
}

var rightpontoondamaged = func (bushkit)
{
	if ((bushkit == 3 or bushkit == 4) and !getprop("/fdm/jsbsim/right-pontoon/broken"))
		setprop("/fdm/jsbsim/right-pontoon/damaged", 1);

    killengine();
}

var rightpontoonbroke = func (bushkit)
{
	if (bushkit == 3 or bushkit == 4) {
		setprop("/fdm/jsbsim/right-pontoon/damaged", 0);
		setprop("/fdm/jsbsim/right-pontoon/broken", 1);
	}
    killengine();
}

var leftwingbroke = func
{
	setprop(contact~"unit[4]/broken", 1);
	setprop("/fdm/jsbsim/wing-damage/left-wing", 1);
}

var rightwingbroke = func
{
	setprop(contact~"unit[5]/broken", 1);
	setprop("/fdm/jsbsim/wing-damage/right-wing", 1);
}

var bothwingcollapse = func
{
	setprop(contact~"unit[5]/z-position", -8);
	setprop("/fdm/jsbsim/crash", 1);
}

var bothwingsbroke = func
{
    leftwingbroke();
    rightwingbroke();
}

var upsidedown = func (left_wing_damage, right_wing_damage)
{
	setprop(contact~"unit[12]/z-position", 90);

	if (getprop(contact~"unit[4]/broken"))
		setprop(contact~"unit[4]/z-position", 40);
	elsif (left_wing_damage > 1)
		setprop(contact~"unit[4]/z-position", 85);
	else
		setprop(contact~"unit[4]/z-position", 50);

	if (getprop(contact~"unit[5]/broken"))
		setprop(contact~"unit[5]/z-position", 40);
	elsif (right_wing_damage > 1)
		setprop(contact~"unit[5]/z-position", 85);
	else
		setprop(contact~"unit[5]/z-position", 50);
}

var killengine = func
{
	setprop("/engines/active-engine/killed", 1);
}

var resetcontacts = func
{
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

var poll_damage = func
{
    # GROUND DAMAGES

    # MUST be the same coefficients as spring_coeff and damping_coeff
    # in the FDM for nose and main gear
    force0 = get_gear_force(0, 1800, 600);
    force1 = get_gear_force(1, 5400, 400);
    force2 = get_gear_force(2, 5400, 400);

    gear_side_force = getprop("/fdm/jsbsim/forces/fby-gear-lbs");

#    # For tests: forces (LBS) exerted on gears (along Z and Y), uncomment these lines.
#    # Future breaking forces for gears
#    if (force0 > 1000) print("Nose Z-force =", force0);
#
#    # 1500 - 2000 lb seems plausible. Mind full load and cross wind landing
#    if (force1 > 1200) print("Left Z-force =", force1);
#
#    if (force2 > 1200) print("Right Z-force =", force2);
#    if (gear_side_force > 500) print ("left side-force =", gear_side_force);
#    if (gear_side_force < -500) print ("right side-force =", abs(gear_side_force));

    var bushkit = getprop("/fdm/jsbsim/bushkit");
    var gears_broken = 0;

	if (force0 > 1400) {
		nosegearbroke(bushkit);
		gears_broken += 1;
    }

	if (force1 > 2000 or gear_side_force > 1500) {
		leftgearbroke(bushkit);
		gears_broken += 1;
    }

	if (force2 > 2000 or gear_side_force < -1500) {
		rightgearbroke(bushkit);
		gears_broken += 1;
    }

    var unit_13_comp = getprop(contact~"unit[13]/compression-ft");
    var unit_15_comp = getprop(contact~"unit[15]/compression-ft");
    var unit_17_comp = getprop(contact~"unit[17]/compression-ft");
    var unit_19_comp = getprop(gears~"unit[19]/compression-ft");
    var unit_21_comp = getprop(gears~"unit[21]/compression-ft");

    var max_left_pontoon_gear_comp = std.max(unit_19_comp, unit_21_comp);

    # Left pontoon
    if (unit_13_comp > 0.95 or unit_15_comp > 0.95 or unit_17_comp > 0.95 or
		max_left_pontoon_gear_comp > 0.95)
		leftpontoonbroke(bushkit);
	elsif (unit_13_comp > 0.75 or unit_15_comp > 0.75 or unit_17_comp > 0.75 or
		max_left_pontoon_gear_comp > 0.75)
		leftpontoondamaged(bushkit);

    var unit_14_comp = getprop(contact~"unit[14]/compression-ft");
    var unit_16_comp = getprop(contact~"unit[16]/compression-ft");
    var unit_18_comp = getprop(contact~"unit[18]/compression-ft");
    var unit_20_comp = getprop(gears~"unit[20]/compression-ft");
    var unit_22_comp = getprop(gears~"unit[22]/compression-ft");

    var max_right_pontoon_gear_comp = std.max(unit_20_comp, unit_22_comp);

    # Right pontoon
    if (unit_14_comp > 0.95 or unit_16_comp > 0.95 or unit_18_comp > 0.95 or
		max_right_pontoon_gear_comp > 0.95)
		rightpontoonbroke(bushkit);
	elsif (unit_14_comp > 0.75 or unit_16_comp > 0.75 or unit_18_comp > 0.75 or
		max_right_pontoon_gear_comp > 0.75)
		rightpontoondamaged(bushkit);

	if (getprop(contact~"unit[4]/compression-ft") > 0.005)
		leftwingbroke();

	if (getprop(contact~"unit[5]/compression-ft") > 0.005)
		rightwingbroke();

    var left_wing_damage = getprop("/fdm/jsbsim/wing-damage/left-wing");
    var right_wing_damage = getprop("/fdm/jsbsim/wing-damage/right-wing");

	if (gears_broken == 3 and left_wing_damage < 1 and right_wing_damage < 1)
		bothwingcollapse();

    var crash = getprop("/fdm/jsbsim/crash");

	if (getprop(contact~"unit[12]/WOW"))
		upsidedown(left_wing_damage, right_wing_damage);

	if (getprop("position/altitude-agl-m") < 10 and (crash or left_wing_damage > 0.5 or right_wing_damage > 0.5))
		killengine();

    # IN-FLIGHT DAMAGES

    # Roll moment due to (diedra + roll rate + yaw rate + ailerons)
    # => asymmetry to break one wing
    var roll_moment = getprop(aero_coeff~"Clb")
        + getprop(aero_coeff~"Clp")
        + getprop(aero_coeff~"Clr")
        + getprop(aero_coeff~"ClDa");
#    print("Roll-moment: ", roll_moment);

    # Over-speed damages
    var airspeed = getprop("velocities/airspeed-kt");

    if (airspeed > limit_vne * 1.225) # Vne x sqrt(1.5) ~ 200 KIAS
	{
		if (!crash and left_wing_damage < 1 and right_wing_damage < 1)
		{
			bothwingsbroke();
			gui.popupTip("Overspeed!! Both wings BROKEN", 5);
		}
	}
	elsif (airspeed > limit_vne * 1.14) # 180 KIAS
	{
        if (roll_moment < -4000) {
		    if (left_wing_damage < 0.5) {
			    rightwingbroke();
                gui.popupTip("Overspeed!! Right wing BROKEN", 5);
            }
		}
		elsif (roll_moment > 4000) {
		    if (right_wing_damage < 0.5) {
			    leftwingbroke();
                gui.popupTip("Overspeed!! Left wing BROKEN", 5);
            }
		}
		else {
		    if (left_wing_damage == 0 and right_wing_damage == 0) {
			    setprop("/fdm/jsbsim/wing-damage/left-wing", 0.3);
                setprop("/fdm/jsbsim/wing-damage/right-wing", 0.3);
                gui.popupTip("Overspeed. Both wing DAMAGED", 5);
		    }
		}
	}
	elsif (airspeed > limit_vne)
	{
		if (roll_moment < -4000 and left_wing_damage == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/right-wing", 0.12);
            gui.popupTip("Overspeed. Right wing DAMAGED!!", 5);
		}
		
		if (roll_moment > 4000 and right_wing_damage == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/left-wing", 0.12);
            gui.popupTip("Overspeed. Left wing DAMAGED!!", 5);
		}
	}        

    # Over-g damages, over-forces on wings

    var lift_force = -getprop("/fdm/jsbsim/forces/fbz-aero-lbs");

    if (lift_force > max_lift_force * 1.5)
	{
		if (!crash)
		{
			bothwingsbroke();
			gui.popupTip("Over-load Both wings BROKEN!!", 5);
		}
	}
	elsif (lift_force > max_lift_force * 1.25)
	{
		if (roll_moment < -4000 and left_wing_damage < 1)
		{
			rightwingbroke();
            gui.popupTip("Over-load Right wing BROKEN", 5);
		}
		if (roll_moment > 4000 and right_wing_damage < 1)
		{
			leftwingbroke();
            gui.popupTip("Over-load Left wing BROKEN", 5);
		}
	}
    elsif (lift_force > max_lift_force)
	{
#        print("Lift-Force: ", lift_force);
		if (roll_moment < -4000 and left_wing_damage == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/right-wing", 0.12);
            gui.popupTip("Over-load Right wing DAMAGED!!", 5);
		}
		if (roll_moment > 4000 and right_wing_damage == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/left-wing", 0.12);
            gui.popupTip("Over-load Left wing DAMAGED!!", 5);
		}
	}
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

var changing_bushkit = 0;

# Duration in which no damage will occur. Assumes the aircraft has
# stabilized within this duration.
var bushkit_change_timeout = 3.0;

var physics_loop = func
{
	if (getprop("/sim/freeze/replay-state")) {
        return;
    }

	if(getprop("/fdm/jsbsim/bushkit") == 3 or getprop("/fdm/jsbsim/bushkit") == 4)
		poll_surface();
	if (!changing_bushkit and getprop("/fdm/jsbsim/damage"))
		poll_damage();
}

var set_bushkit = func (bushkit) {
    resetalldamage();
	resetcontacts();

    # Reset z-position's
    if (bushkit == 0)
        defaulttires();
    elsif (bushkit == 1)
        medbushtires();
    elsif (bushkit == 2)
        largebushtires();
    elsif (bushkit == 3)
        pontoons();
    elsif (bushkit == 4)
        amphibious();
};

# This timer object is used to enable damage again a short time after
# changing to the last bush kit option.
var bushkit_changed_timer = maketimer(bushkit_change_timeout, func {
    changing_bushkit = 0;
});
bushkit_changed_timer.singleShot = 1;

setlistener("/sim/signals/fdm-initialized", func {
    setlistener("/fdm/jsbsim/bushkit", func (n) {
        changing_bushkit = 1;
        set_bushkit(n.getValue());
        bushkit_changed_timer.restart(bushkit_change_timeout);
    }, 1, 0);
});
