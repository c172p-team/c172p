var start = 1;
var moisture = 0;
var foglevel = 0;
var frostlevel = 0;

#debug
#var tempmatch = 0;
#end debug

var dewpointC = getprop("/environment/dewpoint-degc");
var airtempC = getprop("/environment/temperature-degc");

var cabinheatset = 0; #double flow 0 - 1 
var cabinairset = 0;  #double flow 0 - 1 
var cabindewpointset = -7; #19.4 degF

#debug
#props.Node.new({ "/environment/aircraft-effects/debug-tempmatch-airtempC":0 });
#props.globals.initNode("/environment/aircraft-effects/debug-tempmatch-airtempC", tempmatch, "INT");
#end debug

props.Node.new({ "/environment/aircraft-effects/cabin-heat-set":0 });
props.globals.initNode("/environment/aircraft-effects/cabin-heat-set", cabinheatset, "DOUBLE");
props.Node.new({ "/environment/aircraft-effects/cabin-air-set":0 });
props.globals.initNode("/environment/aircraft-effects/cabin-air-set", cabinairset, "DOUBLE");
props.Node.new({ "/environment/aircraft-effects/cabin-dew-setC":0 });
props.globals.initNode("/environment/aircraft-effects/cabin-dew-setC", cabindewpointset, "DOUBLE");

#added for flight recorder
props.Node.new({ "/environment/aircraft-effects/cabinairtempC":0 });
props.globals.initNode("/environment/aircraft-effects/cabinairtempC", airtempC, "DOUBLE");
props.Node.new({ "/environment/aircraft-effects/surfacetempC":0 });
props.globals.initNode("/environment/aircraft-effects/surfacetempC", airtempC, "DOUBLE");
props.Node.new({ "/environment/aircraft-effects/cabinairdewpointC":0 });
props.globals.initNode("/environment/aircraft-effects/cabinairdewpointC", dewpointC, "DOUBLE");

var weather_effects_loop = func {
    var cabinairtempC = getprop("/environment/aircraft-effects/cabinairtempC");
    var surfacetempC = getprop("/environment/aircraft-effects/surfacetempC");
    var cabinairdewpointC = getprop("/environment/aircraft-effects/cabinairdewpointC");

	############################################## rain
	
	var airspeed = getprop("/velocities/airspeed-kt");

	# c172p
	var airspeed_max = 140;

	if (airspeed > airspeed_max) {airspeed = airspeed_max;}

	airspeed = math.sqrt(airspeed/airspeed_max);

	# c172p
	var splash_x = -0.1 - 2.0 * airspeed;
	var splash_y = 0.0;
	var splash_z = 1.0 - 1.35 * airspeed;

	setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
	setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
	setprop("/environment/aircraft-effects/splash-vector-z", splash_z);

	############################################## frost/fog/heat/air
	
	dewpointC = getprop("/environment/dewpoint-degc");
	airtempC = getprop("/environment/temperature-degc");
	cabinairdewpointC = dewpointC;
	cabinairset = getprop("/environment/aircraft-effects/cabin-air-set");
	cabinheatset = getprop("/environment/aircraft-effects/cabin-heat-set");
	
	#debug
	#tempmatch = getprop("/environment/aircraft-effects/debug-tempmatch-airtempC");
	#if (tempmatch) surfacetempC = cabinairtempC = airtempC;
	#end debug

	#cabinheat only pushes heat into cabin if a cabinair is open.
	#cabinair is the flow of air into cabin(it will contian heat if cabinheat is open),
	#otherwise it is just outside airtemp
	if (cabinheatset > 0) 
	{
		cabinairtempC += .04*(cabinheatset*cabinairset);
		if (cabinairtempC > 32)
		{
			if (!getprop("/fdm/jsbsim/weather"))
				gui.popupTip("Cabin temperature exceeding 90F/32C!");
		}
		#surfacetemp is slowely changed by cabinairtemp
		if (surfacetempC < cabinairtempC)
			surfacetempC += .03*(cabinheatset*cabinairset);
		if (surfacetempC > cabinairtempC)
			surfacetempC -= .03*(cabinheatset*cabinairset);
	} 
	else
	if (cabinairset > 0)
	{
		#if no cabinheat then we incrementally adjust cabintemp with outside airtemp
		if (cabinairtempC < airtempC)
			cabinairtempC += .03*cabinairset;
		if (cabinairtempC > airtempC) 
			cabinairtempC -= .03*cabinairset;
		if (surfacetempC < cabinairtempC)
			surfacetempC += .02*cabinairset;
		if (surfacetempC > cabinairtempC)
			surfacetempC -= .02*cabinairset; 
	} 

	#regardless of whether or not vents are open we
	#incremetally adjust cabintemp with outside airtemp
	if (cabinairtempC < airtempC)
		cabinairtempC += .01;
	if (cabinairtempC > airtempC) 
		cabinairtempC -= .01;
	if (cabinairdewpointC < dewpointC)
		cabinairdewpointC += .01;
	if (cabinairdewpointC > dewpointC)
		cabinairdewpointC -= .01;
	if (surfacetempC < cabinairtempC)
		surfacetempC += .01;
	if (surfacetempC > cabinairtempC)
		surfacetempC -= .01;

	#if cabinairtemp is less than dewpointtemp at startup we start out
	#with fog. If it is also freezing we switch to frost.
	#Otherwise we start calculating moisture level in the air
	if (cabinairtempC <= cabinairdewpointC) 
	{
		if (start == 1) {
			foglevel = 1;
			if (cabinairtempC <= 0) 
			{
				frostlevel = 3;
				foglevel = 0;
			}
			start = 0;
		}
		else 
		if (surfacetempC <= cabinairdewpointC)
			if (moisture < 1) moisture += .01;
	}
	else 
	{
		if (surfacetempC > cabinairdewpointC)
			if (moisture > 0) moisture -= .01;
		start = 0;
	}
	
	#we can't get frost unless temp is freezing
	#if it is not freezing then we get fog instead
	if (cabinairtempC <= 0) 
	{
		if (!getprop("/fdm/jsbsim/weather"))
			gui.popupTip("Cabin temperature falling below 32F/0C!");
		frostlevel = moisture * 3;
		if (foglevel > 0) foglevel -= moisture;
		if (foglevel < 0) foglevel = 0;
		if (frostlevel > 3) frostlevel = 3;
	}
	else
	{
		foglevel = moisture;
		if (frostlevel > 0) frostlevel -= moisture;
		if (frostlevel < 0) frostlevel = 0;
		if (foglevel > 1) foglevel = 1;
	}
	
	if (!getprop("/fdm/jsbsim/weather"))
	{
		setprop("/environment/aircraft-effects/frost-level", frostlevel);
		setprop("/environment/aircraft-effects/fog-level", foglevel);
		#added for flight recorder
		if(!getprop("/sim/freeze/replay-state"))
		{
			setprop("/environment/aircraft-effects/cabinairtempC", cabinairtempC);
			setprop("/environment/aircraft-effects/surfacetempC", surfacetempC);
			setprop("/environment/aircraft-effects/cabinairdewpointC", cabinairdewpointC);
		}
	}
	else
	{
		setprop("/environment/aircraft-effects/frost-level", 0);
		setprop("/environment/aircraft-effects/fog-level", 0);
		#added for flight recorder
		if(!getprop("/sim/freeze/replay-state"))
		{
			setprop("/environment/aircraft-effects/cabinairtempC", getprop("/environment/temperature-degc"));
			setprop("/environment/aircraft-effects/surfacetempC", getprop("/environment/temperature-degc"));
			setprop("/environment/aircraft-effects/cabinairdewpointC", getprop("/environment/dewpoint-degc"));
		}
	}

	#debug
	#if (cabinairtempC > 0)
	#{
	#	print("NO ICE, TOO WARM cabinairtempC > 0");
	#} else print("ICE POSSIBLE, CABIN FREEZING cabinairtempC <= 0");
	#if (airtempC > dewpointC) 
	#{
	#	print("NO OUTSIDE DEW airtempC > dewpointC");
	#} else
	#if (airtempC <= dewpointC) 
	#{
	#	print("OUTSIDE DEW ABLE airtempC <= dewpointC");
	#	if (cabinairtempC < 0)
	#	{
	#		print("ICE ABLE, OUTSIDE DEW cabinairtempC < 0");
	#	}
	#} 
	#if (cabinairtempC > cabinairdewpointC)
	#{
	#	print("NO INSIDE DEW cabinairtempC > cabinairdewpointC");
	#} else
	#if (cabinairtempC <= cabinairdewpointC)
	#{
	#	print("INSIDE DEW FORMING cabinairtempC <= cabinairdewpointC");
	#	if (cabinairtempC <= 0)
	#	{
	#		if (surfacetempC <= 0)	
	#			print("ICE BUILDING, CABIN DEW AND SUFACE FREEZING");
	#		else
	#			print("ICE ABLE CABIN DEW, SURFACE NOT FREEZING surfacetempC > 0");
	#	}
	#}
	#print("moisture="~moisture);
	#print("airtempC="~airtempC);
	#print("dewpointC="~dewpointC);
	#print("cabinheatset="~cabinheatset);
	#print("cabinairset="~cabinairset);
	#print("surfacetempC="~surfacetempC);
	#print("cabinairtempC="~cabinairtempC);
	#print("cabinairdewpointC="~cabinairdewpointC);
	#print("foglevel="~foglevel);
	#print("frostlevel="~frostlevel);
	#end debug
	
}
