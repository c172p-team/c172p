# set the timer for the selected function

var UPDATE_PERIOD = 0;

KMA26_timer = func {

	settimer(KMA26Update, UPDATE_PERIOD);

}

# =============================== end timer stuff ===========================================

KMA26Update = func {

	var volts = props.globals.getNode("/systems/electrical/outputs/audio-marker").getValue();
	var dim = 1.0;
	var primaryradio = props.globals.getNode("/instrumentation/kma26/primaryradio").getValue();
	var lampnorm=0.0;


# ======== Radio Selector Buttons ========

	if ( getprop("/instrumentation/kma26/com1sel") or primaryradio==1 )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/com1lampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/com1lampnorm",0.0);
	}

	if ( getprop("/instrumentation/kma26/com2sel") or primaryradio==2 )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/com2lampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/com2lampnorm",0.0);
	}

	if ( getprop("/instrumentation/kma26/com3sel") or primaryradio==3 )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/com3lampnorm",lampnorm);
		setprop("/sim/sound/atc-chatter",1);
	} else {
		setprop("/instrumentation/kma26/com3lampnorm",0.0);
		setprop("/sim/sound/atc-chatter",0);
	}

	if ( getprop("/instrumentation/kma26/nav1sel") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/nav1lampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/nav1lampnorm",0.0);
	}

	if ( getprop("/instrumentation/kma26/nav2sel") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/nav2lampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/nav2lampnorm",0.0);
	}

	if ( getprop("/instrumentation/kma26/mkrsel") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/mkrlampnorm",lampnorm);
		setprop("/instrumentation/marker-beacon/audio-btn",1);
	} else {
		setprop("/instrumentation/kma26/mkrlampnorm",0.0);
		setprop("/instrumentation/marker-beacon/audio-btn",0);
	}

	if ( getprop("/instrumentation/kma26/dmesel") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/dmelampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/dmelampnorm",0.0);
	}

	if ( getprop("/instrumentation/kma26/adfsel") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/adflampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/adflampnorm",0.0);
	}

	if ( getprop("/instrumentation/kma26/auxsel") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/auxlampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/auxlampnorm",0.0);
	}

	if ( getprop("/instrumentation/kma26/monisel") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/monilampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/monilampnorm",0.0);
	}

# ======== Marker Lights ========

	if ( getprop("/instrumentation/marker-beacon/outer") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/omkrlampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/omkrlampnorm",0.0);
	}

	if ( getprop("/instrumentation/marker-beacon/middle") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/mmkrlampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/mmkrlampnorm",0.0);
	}

	if ( getprop("/instrumentation/marker-beacon/inner") )
	{
		lampnorm = volts * dim * 0.041666;
		setprop("/instrumentation/kma26/imkrlampnorm",lampnorm);
	} else {
		setprop("/instrumentation/kma26/imkrlampnorm",0.0);
	}

	KMA26_timer();

}

####################### Initialise ##############################################

initialize = func {

	### Initialise KMA26 ###
	props.globals.getNode("/instrumentation/kma26/com1sel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/com2sel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/com3sel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/nav1sel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/nav2sel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/mkrsel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/adfsel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/dmesel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/auxsel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/monisel", 1).setBoolValue(0);
	props.globals.getNode("/instrumentation/kma26/com1lampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/com2lampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/com3lampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/nav1lampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/nav2lampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/mkrlampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/adflampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/dmelampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/auxlampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/monilampnorm", 1).setDoubleValue(0);
	props.globals.getNode("/instrumentation/kma26/primaryradio", 1).setIntValue(2);

	KMA26Update();
	# Finished Initialising
	print ("KMA26 : initialised");
	var initialized = 1;

} #end func

######################### Fire it up ############################################
setlistener("/sim/signals/electrical-initialized",initialize);
