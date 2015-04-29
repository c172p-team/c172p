props.Node.new({ "/sim/rendering/bushkit":0 });
props.globals.initNode("/sim/rendering/bushkit", 0, "INT");

var gears = "fdm/jsbsim/gear/";
var contact = "fdm/jsbsim/contact/";
var lastkit=0;
var settledelay=0;

var fairing1 = 0;
var fairing2 = 0;
var fairing3 = 0;

var poll_damage = func
{
	if(getprop(gears~"unit[0]/compression-ft") > 0.75)
	{
		setprop(gears~"unit[0]/z-position", 0);
		setprop("/controls/engines/engine/magnetos", 0);
		setprop(gears~"unit[0]/broken", 1);
	}
	if(getprop(gears~"unit[1]/compression-ft") > .49)
	{
		setprop(gears~"unit[1]/z-position", 0);
		setprop(gears~"unit[1]/broken", 1);
	}
	if(getprop(gears~"unit[2]/compression-ft") > 0.49)
	{
		setprop(gears~"unit[2]/z-position", 0);
		setprop(gears~"unit[2]/broken", 1);
	}
	
	if(getprop(contact~"unit[4]/compression-ft") > 0.005)
	{
		setprop(contact~"unit[4]/broken", 1);
		setprop("/fdm/jsbsim/wing/broken-one", -1);
	}
	if(getprop(contact~"unit[5]/compression-ft") > 0.005)
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
}

var poll_gear_delay = func
{
	if (getprop("/sim/rendering/bushkit") == 0)
	{
		setprop(gears~"unit[0]/z-position", -19.5);
		setprop(gears~"unit[1]/z-position", -15.5);
		setprop(gears~"unit[2]/z-position", -15.5);
		setprop(contact~"unit[6]/z-position", -10.95);
		setprop(contact~"unit[7]/z-position", -7.95);
		setprop(contact~"unit[8]/z-position", -7.8);
	} 
	else
	if (getprop("/sim/rendering/bushkit") == 1)
	{
		setprop(gears~"unit[0]/z-position", -22);
		setprop(gears~"unit[1]/z-position", -20);
		setprop(gears~"unit[2]/z-position", -20);
		setprop(contact~"unit[6]/z-position", -13.9);
		setprop(contact~"unit[7]/z-position", -14);
		setprop(contact~"unit[8]/z-position", -15);
	} 
	else 
	{	
		setprop(gears~"unit[0]/z-position", -22);
		setprop(gears~"unit[1]/z-position", -22);
		setprop(gears~"unit[2]/z-position", -22);
		setprop(contact~"unit[6]/z-position", -13.9);
		setprop(contact~"unit[7]/z-position", -16);
		setprop(contact~"unit[8]/z-position", -17);
	}
}

var poll_gear = func
{
	if (getprop("/sim/rendering/bushkit") == 1 or getprop("/sim/rendering/bushkit") == 2 or getprop(gears~"unit[0]/broken") or getprop(gears~"unit[1]/broken") or getprop(gears~"unit[2]/broken"))
	{	
		setprop("/sim/model/c172p/fairing1", 0);
		setprop("/sim/model/c172p/fairing2", 0);
		setprop("/sim/model/c172p/fairing3", 0);		
	}
}
var physics_loop = func
{
	if (lastkit == getprop("/sim/rendering/bushkit"))
	{
		settledelay = 0;
		poll_damage();
	}
	else
	{
		poll_gear_delay();
		settledelay+=1;
		if (settledelay == 5) {
			lastkit = getprop("/sim/rendering/bushkit");
		}
	}
	poll_gear();
}