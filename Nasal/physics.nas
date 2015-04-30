props.Node.new({ "/fdm/jsbsim/bushkit":0 });
props.globals.initNode("/fdm/jsbsim/bushkit", 0, "INT");

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
props.Node.new({ "/sim/rendering/allfix":0 });
props.globals.initNode("/sim/rendering/allfix", 0, "INT");

var gears = "fdm/jsbsim/gear/";
var contact = "fdm/jsbsim/contact/";
var lastkit=0;
var settledelay=0;

var fairing1 = 0;
var fairing2 = 0;
var fairing3 = 0;

var poll_damage = func
{
	#if(getprop(gears~"unit[0]/compression-ft") > 0.75)
	if(getprop(gears~"unit[0]/compression-ft") > 0.75 or getprop("/sim/rendering/nosedamage") or getprop("/sim/rendering/alldamage"))

	{
		setprop(gears~"unit[0]/z-position", 0);
		setprop("/controls/engines/engine/magnetos", 0);
		setprop(gears~"unit[0]/broken", 1);
	}
	#if(getprop(gears~"unit[1]/compression-ft") > .49)
	if(getprop(gears~"unit[1]/compression-ft") > .49 or getprop("/sim/rendering/leftgeardamage") or getprop("/sim/rendering/alldamage"))
	{
		setprop(gears~"unit[1]/z-position", 0);
		setprop(gears~"unit[1]/broken", 1);
	}
	#if(getprop(gears~"unit[2]/compression-ft") > 0.49)
	if(getprop(gears~"unit[2]/compression-ft") > 0.49 or getprop("/sim/rendering/rightgeardamage") or getprop("/sim/rendering/alldamage"))
	{
		setprop(gears~"unit[2]/z-position", 0);
		setprop(gears~"unit[2]/broken", 1);
	}

	if(getprop(contact~"unit[4]/compression-ft") > 0.005 or getprop("/sim/rendering/leftwingdamage"))
	{
		setprop(contact~"unit[4]/broken", 1);
		setprop("/fdm/jsbsim/wing/broken-one", -1);
		
	}
	if(getprop(contact~"unit[5]/compression-ft") > 0.005 or getprop("/sim/rendering/rightwingdamage"))
	{
		setprop(contact~"unit[5]/broken", 1);
		setprop("/fdm/jsbsim/wing/broken-one", 1);
	}
	if(getprop(contact~"unit[4]/broken") and getprop(contact~"unit[5]/broken")) {
		setprop("/fdm/jsbsim/wing/broken-both", 1);
	}
	if(getprop(gears~"unit[0]/broken") and getprop(gears~"unit[1]/broken") and getprop(gears~"unit[2]/broken"))
	{
		setprop("/fdm/jsbsim/crash", 1);
		setprop("/fdm/jsbsim/wing/broken-both", 1);
	}
	if(getprop("position/altitude-agl-m") < 10 and (getprop("/fdm/jsbsim/crash") or getprop("/fdm/jsbsim/wing/broken-one") or getprop("/fdm/jsbsim/wing/broken-both"))) {
		setprop("/controls/engines/engine/magnetos", 0);
	}
	if (getprop("/sim/rendering/allfix"))
	{
		setprop("/controls/engines/engine/magnetos", 1);
		setprop(gears~"unit[0]/broken", 0);
		setprop(gears~"unit[1]/broken", 0);
		setprop(gears~"unit[2]/broken", 0);
		setprop(contact~"unit[4]/broken", 0);
		setprop(contact~"unit[5]/broken", 0);
		setprop("/sim/rendering/alldamage", 0);
		setprop("/fdm/jsbsim/wing/broken-one", 0);
		setprop("/fdm/jsbsim/wing/broken-both", 0);
		setprop("/fdm/jsbsim/crash", 0);
		setprop("/sim/rendering/nosedamage", 0);
		setprop("/sim/rendering/leftgeardamage", 0);
		setprop("/sim/rendering/rightgeardamage", 0);
		setprop("/sim/rendering/leftwingdamage", 0);
		setprop("/sim/rendering/rightwingdamage", 0);
		setprop("/sim/rendering/allfix", 0);
		lastkit=3;
	}
}

var poll_gear_delay = func
{
	if (getprop("/fdm/jsbsim/bushkit") == 0)
	{
		setprop(gears~"unit[0]/z-position", -19.5);
		setprop(gears~"unit[1]/z-position", -15.5);
		setprop(gears~"unit[2]/z-position", -15.5);
		setprop(contact~"unit[6]/z-position", -10);
		setprop(contact~"unit[7]/z-position", -9.5);
		setprop(contact~"unit[8]/z-position", -8);
	} 
	else
    if	
	(getprop("/fdm/jsbsim/bushkit") == 1)
	{
		setprop(gears~"unit[0]/z-position", -22);
		setprop(gears~"unit[1]/z-position", -20);
		setprop(gears~"unit[2]/z-position", -20);
		setprop(contact~"unit[6]/z-position", -18.5);
		setprop(contact~"unit[7]/z-position", -14.5);
		setprop(contact~"unit[8]/z-position", -15.5);
	} 
	else 
	{	
		setprop(gears~"unit[0]/z-position", -22);
		setprop(gears~"unit[1]/z-position", -22);
		setprop(gears~"unit[2]/z-position", -22);
		setprop(contact~"unit[6]/z-position", -17.7);
		setprop(contact~"unit[7]/z-position", -16);
		setprop(contact~"unit[8]/z-position", -17.4);
	}
}

var poll_gear = func
{
	if (getprop("/fdm/jsbsim/bushkit") == 1 or getprop("/fdm/jsbsim/bushkit") == 2 or getprop(gears~"unit[0]/broken") or getprop(gears~"unit[1]/broken") or getprop(gears~"unit[2]/broken"))
	{	
		setprop("/sim/model/c172p/fairing1", 0);
		setprop("/sim/model/c172p/fairing2", 0);
		setprop("/sim/model/c172p/fairing3", 0);		
	}
}
var physics_loop = func
{
	if (lastkit == getprop("/fdm/jsbsim/bushkit"))
	{
		settledelay = 0;
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