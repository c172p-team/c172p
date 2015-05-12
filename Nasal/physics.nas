props.Node.new({ "/fdm/jsbsim/bushkit":0 });
props.globals.initNode("/fdm/jsbsim/bushkit", 0, "INT");

#reference Vne=158, max positive-g=5.8, max negative-g=5.8 
props.Node.new({ "limits/vne":0 });
props.globals.initNode("limits/vne", 158, "DOUBLE");
props.Node.new({ "limits/vne2":0 });
props.globals.initNode("limits/vne2", 200, "DOUBLE");
props.Node.new({ "limits/max-positive-g":0 });
props.globals.initNode("limits/max-positive-g", 4.4, "DOUBLE");
props.Node.new({ "limits/max-negative-g":0 });
props.globals.initNode("limits/max-negative-g", -1.76, "DOUBLE");

var g = getprop("/fdm/jsbsim/accelerations/Nz");
var max_positive = getprop("limits/max-positive-g");
var max_negative = getprop("limits/max-negative-g");

var aero_coeff = "fdm/jsbsim/aero/coefficient/";
#roll moment due to (diedra + roll rate + yaw rate + ailerons) ==> asymmetry to break one wing
var roll_moment = getprop(aero_coeff~"Clb")+getprop(aero_coeff~"Clp")+getprop(aero_coeff~"Clr")+getprop(aero_coeff~"ClDa");

var gears = "fdm/jsbsim/gear/";
var contact = "fdm/jsbsim/contact/";
var lastkit=0;
var settledelay=0;

var fairing1 = 0;
var fairing2 = 0;
var fairing3 = 0;

props.Node.new({ "/sim/rendering/nosedamage":0 });
props.globals.initNode("/sim/rendering/nosedamage", 0, "INT");
props.Node.new({ "/sim/rendering/leftgeardamage":0 });
props.globals.initNode("/sim/rendering/leftgeardamage", 0, "INT");
props.Node.new({ "/sim/rendering/rightgeardamage":0 });
props.globals.initNode("/sim/rendering/rightgeardamage", 0, "INT");
props.Node.new({ "/sim/rendering/alldamage":0 });
props.globals.initNode("/sim/rendering/alldamage", 0, "INT");
props.Node.new({ "/sim/rendering/rightwingdamage":0 });
props.globals.initNode("/sim/rendering/rightwingdamage", 0, "INT");
props.Node.new({ "/sim/rendering/leftwingdamage":0 });
props.globals.initNode("/sim/rendering/leftwingdamage", 0, "INT");
props.Node.new({ "/sim/rendering/bothwingdamage":0 });
props.globals.initNode("/sim/rendering/bothwingdamage", 0, "INT");
props.Node.new({ "/sim/rendering/allfix":0 });
props.globals.initNode("/sim/rendering/allfix", 0, "INT");
var resetalldamage = func
{
	setprop("/controls/engines/engine/magnetos", 1);
	setprop(gears~"unit[0]/broken", 0);
	setprop(gears~"unit[1]/broken", 0);
	setprop(gears~"unit[2]/broken", 0);
	setprop(contact~"unit[4]/broken", 0);
	setprop(contact~"unit[5]/broken", 0);
	setprop(contact~"unit[4]/z-position", 50);
	setprop(contact~"unit[5]/z-position", 50);
	setprop("/sim/rendering/alldamage", 0);
	setprop("/fdm/jsbsim/wing-damage/left-wing", 0);
	setprop("/fdm/jsbsim/wing-damage/right-wing", 0);
	setprop("/fdm/jsbsim/crash", 0);
	setprop("/sim/rendering/nosedamage", 0);
	setprop("/sim/rendering/leftgeardamage", 0);
	setprop("/sim/rendering/rightgeardamage", 0);
	setprop("/sim/rendering/leftwingdamage", 0);
	setprop("/sim/rendering/rightwingdamage", 0);
	setprop("/sim/rendering/bothwingdamage", 0);
	setprop("/sim/rendering/allfix", 0);
	lastkit=3;
}

var nosegearbroke = func
{
	setprop(contact~"unit[6]/z-position", -10);
	setprop(contact~"unit[7]/z-position", -9.5);
	setprop(contact~"unit[8]/z-position", -8);
	setprop(gears~"unit[0]/z-position", 0);
	setprop("/controls/engines/engine/magnetos", 0);
	setprop(gears~"unit[0]/broken", 1);
}

var leftgearbroke = func
{
	setprop(contact~"unit[6]/z-position", -18.5);
	setprop(contact~"unit[7]/z-position", -14.5);
	setprop(contact~"unit[8]/z-position", -15.5);
	setprop(gears~"unit[1]/z-position", 0);
	setprop(gears~"unit[1]/broken", 1);
}

var rightgearbroke = func
{
	setprop(contact~"unit[6]/z-position", -17.7);
	setprop(contact~"unit[7]/z-position", -16);
	setprop(contact~"unit[8]/z-position", -17.4);
	setprop(gears~"unit[2]/z-position", 0);
	setprop(gears~"unit[2]/broken", 1);
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

var bothwingbroke = func
{
	setprop(contact~"unit[4]/broken", 1);
	setprop(contact~"unit[5]/broken", 1);
	setprop("/fdm/jsbsim/wing/broken-both", 1);
}

var bothwingcollapse = func
{
	setprop("/fdm/jsbsim/crash", 1);
}

var upsidedown = func
{
	if (getprop(contact~"unit[4]/broken") 
		setprop(contact~"unit[4]/z-position", 85);
	else
		setprop(contact~"unit[4]/z-position", 50);
	
	if (getprop(contact~"unit[5]/broken") 
		setprop(contact~"unit[5]/z-position", 85);
	else
		setprop(contact~"unit[5]/z-position", 50);
}

var killengine = func
{
	setprop("/controls/engines/engine/magnetos", 0);
}

var defaulttires = func
{
	setprop(gears~"unit[0]/z-position", -19.5);
	setprop(gears~"unit[1]/z-position", -15.5);
	setprop(gears~"unit[2]/z-position", -15.5);
	setprop(contact~"unit[6]/z-position", 0);
	setprop(contact~"unit[7]/z-position", 0);
	setprop(contact~"unit[8]/z-position", 0);
}

var medbushtires = func
{
	setprop(gears~"unit[0]/z-position", -22);
	setprop(gears~"unit[1]/z-position", -20);
	setprop(gears~"unit[2]/z-position", -20);
	setprop(contact~"unit[6]/z-position", 0);
	setprop(contact~"unit[7]/z-position", 0);
	setprop(contact~"unit[8]/z-position", 0);
}

var largebushtires = func
{
	setprop(gears~"unit[0]/z-position", -22);
	setprop(gears~"unit[1]/z-position", -22);
	setprop(gears~"unit[2]/z-position", -22);
	setprop(contact~"unit[6]/z-position", 0);
	setprop(contact~"unit[7]/z-position", 0);
	setprop(contact~"unit[8]/z-position", 0);
}

var removefairings = func
{
	setprop("/sim/model/c172p/fairing1", 0);
	setprop("/sim/model/c172p/fairing2", 0);
	setprop("/sim/model/c172p/fairing3", 0);
}

var poll_damage = func
{
	if (getprop(gears~"unit[0]/compression-ft") > 0.75 or getprop("/sim/rendering/nosedamage") or getprop("/sim/rendering/alldamage"))
		nosegearbroke();

	if (getprop(gears~"unit[1]/compression-ft") > .49 or getprop("/sim/rendering/leftgeardamage") or getprop("/sim/rendering/alldamage"))
		leftgearbroke();
		
	if (getprop(gears~"unit[2]/compression-ft") > 0.49 or getprop("/sim/rendering/rightgeardamage") or getprop("/sim/rendering/alldamage"))
		rightgearbroke();
	
	if (getprop(contact~"unit[4]/compression-ft") > 0.005 or getprop("/sim/rendering/leftwingdamage") or getprop("/sim/rendering/bothwingdamage"))
		leftwingbroke();
		
	if (getprop(contact~"unit[5]/compression-ft") > 0.005 or getprop("/sim/rendering/rightwingdamage") or getprop("/sim/rendering/bothwingdamage"))
		rightwingbroke();
	
	if(getprop(contact~"unit[4]/broken") and getprop(contact~"unit[5]/broken"))
		bothwingbroke();
	
	if (getprop(gears~"unit[0]/broken")	and getprop(gears~"unit[1]/broken")	and getprop(gears~"unit[2]/broken"))
		bothwingcollapse();
	
	if (getprop(contact~"unit[12]/WOW"))
		upsidedown();
	
	if (getprop("position/altitude-agl-m") < 10 and (getprop("/fdm/jsbsim/crash") or getprop("/fdm/jsbsim/wing-damage/left-wing") or getprop("/fdm/jsbsim/wing-damage/right-wing")))
		killengine();
	
	if (getprop("/sim/rendering/allfix"))
		resetalldamage();
	
	roll_moment = getprop(aero_coeff~"Clb")+getprop(aero_coeff~"Clp")+getprop(aero_coeff~"Clr")+getprop(aero_coeff~"ClDa");
	#print ("roll-moment=", roll_moment);
		 
	if (getprop("velocities/airspeed-kt") > getprop("limits/vne"))
	{
		if (roll_moment < -4000 and getprop("/fdm/jsbsim/wing-damage/left-wing") == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/right-wing", 0.12);
			screen.log.write("Overspeed. Right wing DAMAGED!!");
		}
		
		if (roll_moment > 4000 and getprop("/fdm/jsbsim/wing-damage/right-wing") == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/left-wing", 0.12);
			screen.log.write("Overspeed. Left wing DAMAGED!!");
		}
	}        

	if (getprop("velocities/airspeed-kt") > 180)
	{
		if (roll_moment < -4000 and getprop("/fdm/jsbsim/wing-damage/left-wing") == 0)
		{
			rightwingbroke();
			screen.log.write("Overspeed!! Right wing BROKEN ");
		}
		
		if (roll_moment > 4000 and getprop("/fdm/jsbsim/wing-damage/right-wing") == 0)
		{
			leftwingbroke();
			screen.log.write("Overspeed!! Left wing BROKEN");
		}
	}
		
	if (getprop("velocities/airspeed-kt") > getprop("limits/vne2"))
	{    
		if (getprop("/fdm/jsbsim/wing-damage/left-wing") == 0 and getprop("/fdm/jsbsim/wing-damage/right-wing") == 0)
		{
			   rightwingbroke();
			   leftwingbroke();
			   screen.log.write("Overspeed!! Both wings BROKEN!!");
		}
	}
	
	g = getprop("/fdm/jsbsim/accelerations/Nz");
	if (g > max_positive)
	{
		if (roll_moment < -4000 and getprop("/fdm/jsbsim/wing-damage/left-wing") == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/right-wing", 0.12);
			screen.log.write("Over-g Right wing DAMAGED!!");
		}
		if (roll_moment > 4000 and getprop("/fdm/jsbsim/wing-damage/right-wing") == 0)
		{
			setprop("/fdm/jsbsim/wing-damage/left-wing", 0.12);
			screen.log.write("Over-g Left wing DAMAGED!!");
		}
	}
	if (g > 5.5)
	{
		if (roll_moment < -4000 and getprop("/fdm/jsbsim/wing-damage/left-wing") != 1)
		{
			rightwingbroke();
			screen.log.write("Over-g Right wing BROKEN!!");
		}
		if (roll_moment > 4000 and getprop("/fdm/jsbsim/wing-damage/right-wing") != 1)
		{
			leftwingbroke();
			screen.log.write("Over-g Left wing BROKEN!!");
		}
	}
	if (g > 6.6)
	{
		rightwingbroke();
		leftwingbroke();
		screen.log.write("Over-g Both wings BROKEN!!");
	}	
}

#required delay for bush kit change over
var poll_gear_delay = func
{
	if (getprop("/fdm/jsbsim/bushkit") == 0)
		defaulttires();
	else
    if (getprop("/fdm/jsbsim/bushkit") == 1)
		medbushtires();
	else
		largebushtires();
}

var poll_gear = func
{
	if (getprop("/fdm/jsbsim/bushkit") == 1 or getprop("/fdm/jsbsim/bushkit") == 2 or getprop(gears~"unit[0]/broken") or getprop(gears~"unit[1]/broken") or getprop(gears~"unit[2]/broken"))
		removefairings();
}

var physics_loop = func
{
	if (lastkit == getprop("/fdm/jsbsim/bushkit"))
	{
		settledelay = 0;
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
	poll_gear();
}
