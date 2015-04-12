var templo = 0;
var temphi = 32;
var frostlo = .1;
var frosthi = 3;


var weather_effects_loop = func {

	############################################## rain
	var airspeed = getprop("/velocities/airspeed-kt");

	# c172p
	var airspeed_max = 120;

	if (airspeed > airspeed_max) {airspeed = airspeed_max;}

	airspeed = math.sqrt(airspeed/airspeed_max);

	# c172p
	var splash_x = -0.1 - 2.0 * airspeed;
	var splash_y = 0.0;
	var splash_z = 1.0 - 1.35 * airspeed;

	setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
	setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
	setprop("/environment/aircraft-effects/splash-vector-z", splash_z);

	############################################## frost
	var dewpoint = getprop("/environment/dewpoint-degc");
	var temp = getprop("/environment/temperature-degf");

	var tempComp = temp;

	if (temp > 32) temp = 32;
	if (temp < 0) temp = 0;

	var tempScale = (temphi-temp)/(temphi-templo);
	var frostLevel = (frostlo+(frosthi-frostlo))*tempScale;
	   
	if (tempComp > ((dewpoint*1.8)+32)) frostLevel = 0;

	setprop("/environment/aircraft-effects/frost-level", frostLevel);

	#print("FrostLevel="~frostLevel);

	settimer( func {weather_effects_loop() },1.0);
	
}
weather_effects_loop();