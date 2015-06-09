props.Node.new({ "/fdm/jsbsim/bushkit":0 });
props.globals.initNode("/fdm/jsbsim/bushkit", 0, "INT");

# Specifications Vne=158 KIAS,
# Normal category (1500 - 2400 lb): max positive-g=3.8, max negative-g=1.52,
# Utility category (1500 - 2100 lb): max positive-g=4.4, max negative-g=1.76,
# structure holds at least 150% max g's
props.Node.new({ "limits/vne":0 });
props.globals.initNode("limits/vne", 158, "DOUBLE");
props.Node.new({ "limits/max-positive-g":0 });
props.globals.initNode("limits/max-positive-g", 3.8, "DOUBLE");
props.Node.new({ "limits/max-negative-g":0 });
props.globals.initNode("limits/max-negative-g", -1.52, "DOUBLE");

var g = getprop("/fdm/jsbsim/accelerations/Nz");
var max_positive = getprop("limits/max-positive-g");
var max_negative = getprop("limits/max-negative-g");

var aero_coeff = "fdm/jsbsim/aero/coefficient/";
#Roll moment due to (diedra + roll rate + yaw rate + ailerons) ==> asymmetry to break one wing
var roll_moment = getprop(aero_coeff~"Clb")+getprop(aero_coeff~"Clp")+getprop(aero_coeff~"Clr")+getprop(aero_coeff~"ClDa");

var get_gear_force = func (index, spring_coeff, damping_coeff) {
    # Force-on-gear = (compression-ft) x (spring_coeff) + (compression-velocity-fps) x (damping_coeff)

    var compr = getprop("/fdm/jsbsim/gear/unit", index, "compression-ft");
    var compr_vel = getprop("/fdm/jsbsim/gear/unit", index, "compression-velocity-fps");
    return spring_coeff * compr + damping_coeff * compr_vel;
};

var force0 = get_gear_force(0, 1800, 600); # MUST be the same coefficients as spring_coeff and damping_coeff in the FDM for NOSE
var force1 = get_gear_force(1, 5400, 400); # MUST be the same coefficients as spring_coeff and damping_coeff in the FDM for LEFT gear
var force2 = get_gear_force(2, 5400, 400); # MUST be the same coefficients as spring_coeff and damping_coeff in the FDM for RIGHT gear

var gear_side_force = getprop("/fdm/jsbsim/forces/fby-gear-lbs");

var gears = "fdm/jsbsim/gear/";
var contact = "fdm/jsbsim/contact/";
var lastkit=0;
var settledelay=0;

var fairing1 = 0;
var fairing2 = 0;
var fairing3 = 0;

#Uncomment for resetting damage
#props.Node.new({ "/sim/rendering/nosedamage":0 });
#props.globals.initNode("/sim/rendering/nosedamage", 0, "INT");
#props.Node.new({ "/sim/rendering/leftgeardamage":0 });
#props.globals.initNode("/sim/rendering/leftgeardamage", 0, "INT");
#props.Node.new({ "/sim/rendering/rightgeardamage":0 });
#props.globals.initNode("/sim/rendering/rightgeardamage", 0, "INT");
#props.Node.new({ "/sim/rendering/alldamage":0 });
#props.globals.initNode("/sim/rendering/alldamage", 0, "INT");
#props.Node.new({ "/sim/rendering/rightwingdamage":0 });
#props.globals.initNode("/sim/rendering/rightwingdamage", 0, "INT");
#props.Node.new({ "/sim/rendering/leftwingdamage":0 });
#props.globals.initNode("/sim/rendering/leftwingdamage", 0, "INT");
#props.Node.new({ "/sim/rendering/allfix":0 });
#props.globals.initNode("/sim/rendering/allfix", 0, "INT");

var resetalldamage = func
{
    setprop("/fdm/jsbsim/propulsion/tank[2]/priority", 1);
	setprop(gears~"unit[0]/broken", 0);
	setprop(gears~"unit[1]/broken", 0);
	setprop(gears~"unit[2]/broken", 0);
	setprop(contact~"unit[4]/broken", 0);
	setprop(contact~"unit[5]/broken", 0);
	setprop(contact~"unit[4]/z-position", 50);
	setprop(contact~"unit[5]/z-position", 50);
	setprop("/fdm/jsbsim/wing-damage/left-wing", 0);
	setprop("/fdm/jsbsim/wing-damage/right-wing", 0);
	setprop("/fdm/jsbsim/wing-both/broken", 0);
	setprop("/fdm/jsbsim/crash", 0);
	setprop("/fdm/jsbsim/left-pontoon/damaged", 0);
	setprop("/fdm/jsbsim/left-pontoon/broken", 0);
	setprop("/fdm/jsbsim/right-pontoon/damaged", 0);
	setprop("/fdm/jsbsim/right-pontoon/broken", 0);
	#setprop("/sim/rendering/nosedamage", 0);
	#setprop("/sim/rendering/leftgeardamage", 0);
	#setprop("/sim/rendering/rightgeardamage", 0);
	#setprop("/sim/rendering/leftwingdamage", 0);
	#setprop("/sim/rendering/rightwingdamage", 0);
	#setprop("/sim/rendering/bothwingdamage", 0);
	#setprop("/sim/rendering/alldamage", 0);
	#setprop("/sim/rendering/allfix", 0);
	lastkit=5;
}

var nosegearbroke = func
{
	if(getprop("/fdm/jsbsim/bushkit") == 0)
		setprop(contact~"unit[6]/z-position", -10);
	else 
    if(getprop("/fdm/jsbsim/bushkit") == 1)
		setprop(contact~"unit[6]/z-position", -18.5);
	else
	if(getprop("/fdm/jsbsim/bushkit") == 2)
		setprop(contact~"unit[6]/z-position", -17.7);

	setprop(gears~"unit[0]/z-position", 0);
    setprop("/fdm/jsbsim/propulsion/tank[2]/priority", 0);
	setprop(gears~"unit[0]/broken", 1);
}

var leftgearbroke = func
{
	if(getprop("/fdm/jsbsim/bushkit") == 0)
		setprop(contact~"unit[7]/z-position", -9.5);
	else 
    if(getprop("/fdm/jsbsim/bushkit") == 1)
		setprop(contact~"unit[7]/z-position", -14.5);
	else
	if(getprop("/fdm/jsbsim/bushkit") == 2)
		setprop(contact~"unit[7]/z-position", -16);

	setprop(gears~"unit[1]/z-position", 0);
	setprop(gears~"unit[1]/broken", 1);
}

var rightgearbroke = func
{
	if(getprop("/fdm/jsbsim/bushkit") == 0)
		setprop(contact~"unit[8]/z-position", -8);
	else 
    if(getprop("/fdm/jsbsim/bushkit") == 1)
		setprop(contact~"unit[8]/z-position", -15.5);
	else
	if(getprop("/fdm/jsbsim/bushkit") == 2)
		setprop(contact~"unit[8]/z-position", -17.4);

	setprop(gears~"unit[2]/z-position", 0);
	setprop(gears~"unit[2]/broken", 1);
}

var leftpontoondamaged = func
{
	if(getprop("/fdm/jsbsim/bushkit") == 3 or getprop("/fdm/jsbsim/bushkit") == 4)
		if(!getprop("/fdm/jsbsim/left-pontoon/broken"))
			setprop("/fdm/jsbsim/left-pontoon/damaged", 1);

    setprop("/fdm/jsbsim/propulsion/tank[2]/priority", 0);
}

var leftpontoonbroke = func
{
	if(getprop("/fdm/jsbsim/bushkit") == 3 or getprop("/fdm/jsbsim/bushkit") == 4)
	{
		setprop("/fdm/jsbsim/left-pontoon/damaged", 0);
		setprop("/fdm/jsbsim/left-pontoon/broken", 1);
	}
	setprop("/fdm/jsbsim/propulsion/tank[2]/priority", 0);
}

var rightpontoondamaged = func
{
	if(getprop("/fdm/jsbsim/bushkit") == 3 or getprop("/fdm/jsbsim/bushkit") == 4)
		if(!getprop("/fdm/jsbsim/right-pontoon/broken"))
			setprop("/fdm/jsbsim/right-pontoon/damaged", 1);

	setprop("/fdm/jsbsim/propulsion/tank[2]/priority", 0);
}

var rightpontoonbroke = func
{
	if(getprop("/fdm/jsbsim/bushkit") == 3 or getprop("/fdm/jsbsim/bushkit") == 4)
	{
		setprop("/fdm/jsbsim/right-pontoon/damaged", 0);
		setprop("/fdm/jsbsim/right-pontoon/broken", 1);
	}
	setprop("/fdm/jsbsim/propulsion/tank[2]/priority", 0);
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
	setprop(contact~"unit[4]/broken", 1);
	setprop(contact~"unit[5]/broken", 1);
	setprop("/fdm/jsbsim/wing-damage/left-wing", 1);
	setprop("/fdm/jsbsim/wing-damage/right-wing", 1);
	setprop("/fdm/jsbsim/wing-both/broken", 1);
}

var upsidedown = func
{
	if (getprop(contact~"unit[4]/broken"))
		setprop(contact~"unit[4]/z-position", 40);
	else
	if(getprop("/fdm/jsbsim/wing-damage/left-wing") > 1)
		setprop(contact~"unit[4]/z-position", 85);
	else
		setprop(contact~"unit[4]/z-position", 50);

	if (getprop(contact~"unit[5]/broken"))
		setprop(contact~"unit[5]/z-position", 40);
	else
	if(getprop("/fdm/jsbsim/wing-damage/right-wing") > 1)
		setprop(contact~"unit[5]/z-position", 85);
	else
		setprop(contact~"unit[5]/z-position", 50);
}

var killengine = func
{
	setprop("/fdm/jsbsim/propulsion/tank[2]/priority", 0);
}

var resetcontacts = func
{
	setprop(gears~"unit[0]/z-position", 0);
	setprop(gears~"unit[1]/z-position", 0);
	setprop(gears~"unit[2]/z-position", 0);
	setprop(contact~"unit[6]/z-position", 0);
	setprop(contact~"unit[7]/z-position", 0);
	setprop(contact~"unit[8]/z-position", 0);
	setprop(contact~"unit[13]/z-position", 0);
	setprop(contact~"unit[14]/z-position", 0);
	setprop(contact~"unit[15]/z-position", 0);
	setprop(contact~"unit[16]/z-position", 0);
	setprop(contact~"unit[17]/z-position", 0);
	setprop(contact~"unit[18]/z-position", 0);
	setprop(contact~"unit[19]/z-position", 0);
	setprop(contact~"unit[20]/z-position", 0);
	setprop(gears~"unit[21]/z-position", 0);
	setprop(gears~"unit[22]/z-position", 0);
	setprop(gears~"unit[23]/z-position", 0);
	setprop(gears~"unit[24]/z-position", 0);
}

var defaulttires = func
{
	resetalldamage();
	resetcontacts();
	setprop(gears~"unit[0]/z-position", -19.5);
	setprop(gears~"unit[1]/z-position", -15.5);
	setprop(gears~"unit[2]/z-position", -15.5);
}

var medbushtires = func
{
	resetalldamage();
	resetcontacts();
	setprop(gears~"unit[0]/z-position", -22);
	setprop(gears~"unit[1]/z-position", -20);
	setprop(gears~"unit[2]/z-position", -20);
}

var largebushtires = func
{
	resetalldamage();
	resetcontacts();
	setprop(gears~"unit[0]/z-position", -22);
	setprop(gears~"unit[1]/z-position", -22);
	setprop(gears~"unit[2]/z-position", -22);
}

var pontoons = func
{
	resetalldamage();
	resetcontacts();
	setprop(contact~"unit[13]/z-position", -55);
	setprop(contact~"unit[14]/z-position", -55);
	setprop(contact~"unit[15]/z-position", -22);
	setprop(contact~"unit[16]/z-position", -22);
}

var amphibious = func
{
	resetcontacts();
	resetalldamage();
	setprop(contact~"unit[13]/z-position", -55);
	setprop(contact~"unit[14]/z-position", -55);
	setprop(contact~"unit[15]/z-position", -22);
	setprop(contact~"unit[16]/z-position", -22);
	setprop(gears~"unit[21]/z-position", -54);
	setprop(gears~"unit[22]/z-position", -54);
	setprop(gears~"unit[23]/z-position", -48.5);
	setprop(gears~"unit[24]/z-position", -48.5);
}

var poll_damage = func
{

# GROUND DAMAGES

    force0 = get_gear_force(0, 1800, 600); # MUST be the same coefficients as spring_coeff and damping_coeff in the FDM for NOSE
    force1 = get_gear_force(1, 5400, 400); # MUST be the same coefficients as spring_coeff and damping_coeff in the FDM for LEFT gear
    force2 = get_gear_force(2, 5400, 400); # MUST be the same coefficients as spring_coeff and damping_coeff in the FDM for RIGHT gear

    gear_side_force = getprop("/fdm/jsbsim/forces/fby-gear-lbs");
    
#    # For tests: forces (LBS) exerted on gears (along Z and Y)
#    if(force0 > 1000) print("force0 =", force0); #future breaking forces for gears
#    if(force1 > 1500) print("force1 =", force1); #1500 - 2000 lb seems plausible. Mind full load and cross wind landing
#    if(force2 >1500)  print("force2 =", force2);
#    if(abs(gear_side_force) > 500) print ("side-force =", gear_side_force);

	if(force0 > 1400)
		nosegearbroke();

	if(force1 > 2000 or gear_side_force > 1500)
		leftgearbroke();

	if(force2 > 2000 or gear_side_force < -1500)
		rightgearbroke();

	if(getprop(contact~"unit[17]/compression-ft") > 0.75)
		leftpontoondamaged();

	if(getprop(contact~"unit[19]/compression-ft") > 0.49 or getprop(contact~"unit[17]/compression-ft") > 0.95)
		leftpontoonbroke();

	if(getprop(contact~"unit[18]/compression-ft") > 0.75)
		rightpontoondamaged();

	if(getprop(contact~"unit[20]/compression-ft") > 0.49 or getprop(contact~"unit[18]/compression-ft") > 0.95)
		rightpontoonbroke();

	# or getprop("/sim/rendering/leftwingdamage") or getprop("/sim/rendering/bothwingdamage")
	if(getprop(contact~"unit[4]/compression-ft") > 0.005)
		leftwingbroke();

	# or getprop("/sim/rendering/rightwingdamage") or getprop("/sim/rendering/bothwingdamage")
	if(getprop(contact~"unit[5]/compression-ft") > 0.005)
		rightwingbroke();

	if(getprop(gears~"unit[0]/broken")	and getprop(gears~"unit[1]/broken")	and getprop(gears~"unit[2]/broken"))
		if(!getprop("/fdm/jsbsim/wing-both/broken") and getprop("/fdm/jsbsim/wing-damage/left-wing") < 1 and getprop("/fdm/jsbsim/wing-damage/right-wing") < 1)
			bothwingcollapse();

	if (getprop(contact~"unit[12]/WOW"))
		upsidedown();

	if(getprop("position/altitude-agl-m") < 10 and (getprop("/fdm/jsbsim/crash") or getprop("/fdm/jsbsim/wing-damage/left-wing") > 0.5 or getprop("/fdm/jsbsim/wing-damage/right-wing") > 0.5))
		killengine();

	if (getprop("/sim/rendering/allfix"))
		resetalldamage();

#IN-FLIGHT DAMAGES

	roll_moment = getprop(aero_coeff~"Clb")+getprop(aero_coeff~"Clp")+getprop(aero_coeff~"Clr")+getprop(aero_coeff~"ClDa");
	#print ("roll-moment=", roll_moment);

#Over-speed	damages	 
	if (getprop("velocities/airspeed-kt") > getprop("limits/vne"))
	{
		if (roll_moment < -4000 and getprop("/fdm/jsbsim/wing-damage/left-wing") == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/right-wing", 0.12);
            gui.popupTip("Overspeed. Right wing DAMAGED!!", 5);
		}
		
		if (roll_moment > 4000 and getprop("/fdm/jsbsim/wing-damage/right-wing") == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/left-wing", 0.12);
            gui.popupTip("Overspeed. Left wing DAMAGED!!", 5);
		}
	}        

	if (getprop("velocities/airspeed-kt") > (getprop("limits/vne") * 1.14)) # 180 KIAS
	{
        if (roll_moment > -4000 and roll_moment < 4000 and getprop("/fdm/jsbsim/wing-damage/left-wing") == 0 and getprop("/fdm/jsbsim/wing-damage/right-wing") == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/left-wing", 0.3);
            setprop("/fdm/jsbsim/wing-damage/right-wing", 0.3);
            gui.popupTip("Overspeed. Both wing DAMAGED", 5);
		}
        if (roll_moment < -4000 and getprop("/fdm/jsbsim/wing-damage/left-wing") < 0.5)
		{
			rightwingbroke();
            gui.popupTip("Overspeed!! Right wing BROKEN", 5);
		}
		
		if (roll_moment > 4000 and getprop("/fdm/jsbsim/wing-damage/right-wing") < 0.5)
		{
			leftwingbroke();
            gui.popupTip("Overspeed!! Left wing BROKEN", 5);
		}
	}
		
	if (getprop("velocities/airspeed-kt") > (getprop("limits/vne") * 1.225)) # Vne x sqrt(1.5) ~ 200 KIAS
	{    
		if (getprop("/fdm/jsbsim/wing-damage/left-wing") < 1 and getprop("/fdm/jsbsim/wing-damage/right-wing") < 1)
		{
				if (!getprop("/fdm/jsbsim/crash"))
				{
					bothwingsbroke();
					gui.popupTip("Overspeed!! Both wings BROKEN", 5);
				}
		}
	}
	
#Over-g damages
	g = getprop("/fdm/jsbsim/accelerations/Nz");
	if (g > max_positive)
	{
		if (roll_moment < -4000 and getprop("/fdm/jsbsim/wing-damage/left-wing") == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/right-wing", 0.12);
            gui.popupTip("Over-g Right wing DAMAGED!!", 5);
		}
		if (roll_moment > 4000 and getprop("/fdm/jsbsim/wing-damage/right-wing") == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/left-wing", 0.12);
            gui.popupTip("Over-g Left wing DAMAGED!!", 5);
		}
	}
	if (g > (max_positive * 1.25))
	{
		if (roll_moment < -4000 and getprop("/fdm/jsbsim/wing-damage/left-wing") < 1)
		{
			rightwingbroke();
            gui.popupTip("Over-g Right wing BROKEN", 5);
		}
		if (roll_moment > 4000 and getprop("/fdm/jsbsim/wing-damage/right-wing") < 1)
		{
			leftwingbroke();
            gui.popupTip("Over-g Left wing BROKEN", 5);
		}
	}
	if (g > (max_positive * 1.5))
	{
		if (!getprop("/fdm/jsbsim/crash"))
		{
			bothwingsbroke();
			gui.popupTip("Over-g Both wings BROKEN!!", 5);
		}
	}	
}

#check if on water
var poll_surface = func
{
	if (getprop(contact~"unit[13]/solid"))
	{
		setprop(contact~"unit[13]/z-position", 0);
		if (getprop("/fdm/jsbsim/bushkit") == 3)
			setprop(contact~"unit[17]/z-position", -65);
		else
			if (getprop("/fdm/jsbsim/gear/gear-pos-norm") == 1)
				setprop(contact~"unit[17]/z-position", -0);
			else
				setprop(contact~"unit[17]/z-position", -65);
	}
	else
	{
		setprop(contact~"unit[13]/z-position", -55);
		setprop(contact~"unit[17]/z-position", 0);
		if (getprop(contact~"unit[13]/compression-ft"))
		{
			if (.005*(.065*getprop("fdm/jsbsim/propulsion/engine/engine-rpm")) > (.005*getprop("velocities/groundspeed-kt")))
				setprop("/environment/aircraft-effects/ground-splash-norm", (.005*(.065*getprop("fdm/jsbsim/propulsion/engine/engine-rpm"))));
			else
				setprop("/environment/aircraft-effects/ground-splash-norm", (.005*getprop("velocities/groundspeed-kt")));
		}
	}

	if (getprop(contact~"unit[14]/solid"))
	{
		setprop(contact~"unit[14]/z-position", 0);
		if (getprop("/fdm/jsbsim/bushkit") == 3)
			setprop(contact~"unit[18]/z-position", -65);
		else
			if (getprop("/fdm/jsbsim/gear/gear-pos-norm") == 1)
				setprop(contact~"unit[18]/z-position", -0);
			else
				setprop(contact~"unit[18]/z-position", -65);
	}
	else
	{
		setprop(contact~"unit[14]/z-position", -55);
		setprop(contact~"unit[18]/z-position", 0);
		if (getprop(contact~"unit[14]/compression-ft"))
		{
			if (.005*(.065*getprop("fdm/jsbsim/propulsion/engine/engine-rpm")) > (.005*getprop("velocities/groundspeed-kt")))
				setprop("/environment/aircraft-effects/ground-splash-norm", (.005*(.065*getprop("fdm/jsbsim/propulsion/engine/engine-rpm"))));
			else
				setprop("/environment/aircraft-effects/ground-splash-norm", (.005*getprop("velocities/groundspeed-kt")));
		}
	}

	if (getprop(contact~"unit[15]/solid"))
	{
		setprop(contact~"unit[15]/z-position", 0);
		if (getprop("/fdm/jsbsim/bushkit") == 3)
			setprop(contact~"unit[19]/z-position", -40);
		else
			if (getprop("/fdm/jsbsim/gear/gear-pos-norm") == 1)
				setprop(contact~"unit[19]/z-position", -0);
			else
				setprop(contact~"unit[19]/z-position", -40);
	}
	else
	{
		setprop(contact~"unit[15]/z-position", -22);
		setprop(contact~"unit[19]/z-position", 0);
		if (getprop(contact~"unit[15]/compression-ft"))
		{
			if (.005*(.065*getprop("fdm/jsbsim/propulsion/engine/engine-rpm")) > (.005*getprop("velocities/groundspeed-kt")))
				setprop("/environment/aircraft-effects/ground-splash-norm", (.005*(.065*getprop("fdm/jsbsim/propulsion/engine/engine-rpm"))));
			else
				setprop("/environment/aircraft-effects/ground-splash-norm", (.005*getprop("velocities/groundspeed-kt")));
		}
	}

	if (getprop(contact~"unit[16]/solid"))
	{
		setprop(contact~"unit[16]/z-position", 0);
		if (getprop("/fdm/jsbsim/bushkit") == 3)
			setprop(contact~"unit[20]/z-position", -40);
		else
			if (getprop("/fdm/jsbsim/gear/gear-pos-norm") == 1)
				setprop(contact~"unit[20]/z-position", -0);
			else
				setprop(contact~"unit[20]/z-position", -40);
	}
	else
	{
		setprop(contact~"unit[16]/z-position", -22);
		setprop(contact~"unit[20]/z-position", 0);
		if (getprop(contact~"unit[16]/compression-ft"))
		{
			if (.005*(.065*getprop("fdm/jsbsim/propulsion/engine/engine-rpm")) > (.005*getprop("velocities/groundspeed-kt")))
				setprop("/environment/aircraft-effects/ground-splash-norm", (.005*(.065*getprop("fdm/jsbsim/propulsion/engine/engine-rpm"))));
			else
				setprop("/environment/aircraft-effects/ground-splash-norm", (.005*getprop("velocities/groundspeed-kt")));
		}
	}

	if (getprop("position/altitude-agl-m") > 2)
		setprop("/environment/aircraft-effects/ground-splash-norm", 0);
}

#required delay for bush kit change over
var poll_gear_delay = func
{
	if(getprop("/fdm/jsbsim/bushkit") == 0)
		defaulttires();
	else
    if(getprop("/fdm/jsbsim/bushkit") == 1)
		medbushtires();
	else
	if(getprop("/fdm/jsbsim/bushkit") == 2)
		largebushtires();
	else
	if(getprop("/fdm/jsbsim/bushkit") == 3)
		pontoons();
	else
	if(getprop("/fdm/jsbsim/bushkit") == 4)
		amphibious();
}

var physics_loop = func
{
	var nasalInit = setlistener("/sim/freeze/replay-state", func{
	   if(getprop("/sim/freeze/replay-state")) return;
	});
	if (lastkit == getprop("/fdm/jsbsim/bushkit"))
	{
		settledelay = 0;
		if(getprop("/fdm/jsbsim/bushkit") == 3 or getprop("/fdm/jsbsim/bushkit") == 4)
			poll_surface();
		if (getprop("/fdm/jsbsim/damage"))
			poll_damage();
	}
	else
	{
		poll_gear_delay();
		settledelay+=1;
		if (settledelay == 5) {
			lastkit = getprop("/fdm/jsbsim/bushkit");
		}
	}
}
