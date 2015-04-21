props.Node.new({ "/sim/rendering/bushkit":0 });
props.globals.initNode("/sim/rendering/bushkit", 0, "INT");
props.Node.new({ "/sim/rendering/bushkits":0 });
props.globals.initNode("/sim/rendering/bushkits", 0, "INT");

props.Node.new({ "/sim/rendering/nosedamage":0 });
props.globals.initNode("/sim/rendering/nosedamage", 0, "INT");
props.Node.new({ "/sim/rendering/leftgeardamage":0 });
props.globals.initNode("/sim/rendering/leftgeardamage", 0, "INT");
props.Node.new({ "/sim/rendering/rightgeardamage":0 });
props.globals.initNode("/sim/rendering/rightgeardamage", 0, "INT");
props.Node.new({ "/sim/rendering/alldamage":0 });
props.globals.initNode("/sim/rendering/alldamage", 0, "INT");

var gears = "fdm/jsbsim/gear/";
var contact = "fdm/jsbsim/contact/";
var lastkit=0;
var lastkits=0;
var settledelay=0;

var physics = func
{
	if (lastkit == getprop("/sim/rendering/bushkit") and lastkits == getprop("/sim/rendering/bushkits")) {
		settledelay = 0;
		#if(getprop(gears~"unit[0]/compression-ft") > 0.59)
		if(getprop(gears~"unit[0]/compression-ft") > 0.59 or getprop("/sim/rendering/nosedamage") or getprop("/sim/rendering/alldamage"))
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
	} else {
		if (getprop("/sim/rendering/bushkit") == 0)
		{
			setprop(gears~"unit[0]/z-position", -19.5);
			setprop(gears~"unit[1]/z-position", -15.5);
			setprop(gears~"unit[2]/z-position", -15.5);
			setprop(contact~"unit[6]/z-position", -14.9);
			setprop(contact~"unit[7]/z-position", -7.95);
			setprop(contact~"unit[8]/z-position", -7.8);
		} 
		else if (getprop("/sim/rendering/bushkits") == 1)
		{
			setprop(gears~"unit[0]/z-position", -22);
			setprop(gears~"unit[1]/z-position", -20);
			setprop(gears~"unit[2]/z-position", -20);
			setprop(contact~"unit[6]/z-position", -17);
			setprop(contact~"unit[7]/z-position", -14);
			setprop(contact~"unit[8]/z-position", -15);
		} else {
			setprop(gears~"unit[0]/z-position", -22);
			setprop(gears~"unit[1]/z-position", -22);
			setprop(gears~"unit[2]/z-position", -22);
			setprop(contact~"unit[6]/z-position", -19);
			setprop(contact~"unit[7]/z-position", -16);
			setprop(contact~"unit[8]/z-position", -17);
		}
		settledelay+=1;
		if (settledelay == 5) {
			lastkit = getprop("/sim/rendering/bushkit");
			lastkits = getprop("/sim/rendering/bushkits");
		}
	}
}