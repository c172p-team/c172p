##
# Procedural model of a Cessna 172S electrical system.  Includes a
# preliminary battery charge/discharge model and realistic ammeter
# gauge modeling.
#


##
# Initialize internal values
#

battery = nil;
alternator = nil;

last_time = 0.0;

vbus_volts = 0.0;
ebus1_volts = 0.0;
ebus2_volts = 0.0;

ammeter_ave = 0.0;

##
# Initialize the electrical system
#

init_electrical = func {
    print("Initializing Nasal Electrical System");
    battery = BatteryClass.new();
    alternator = AlternatorClass.new();

    # set initial switch positions
    setprop("/controls/engines/engine[0]/master-bat", 1);
    setprop("/controls/engines/engine[0]/master-alt", 1);
    setprop("/controls/switches/master-avionics", 1);
    setprop("/systems/electrical/outputs/autopilot",0.0);

    # Request that the update fuction be called next frame
    settimer(update_electrical, 0);
}


##
# Battery model class.
#

BatteryClass = {};

BatteryClass.new = func {
    obj = { parents : [BatteryClass],
            ideal_volts : 24.0,
            ideal_amps : 30.0,
            amp_hours : 12.75,
            charge_percent : 1.0,
            charge_amps : 7.0 };
    return obj;
}

##
# Passing in positive amps means the battery will be discharged.
# Negative amps indicates a battery charge.
#

BatteryClass.apply_load = func( amps, dt ) {
    amphrs_used = amps * dt / 3600.0;
    percent_used = amphrs_used / me.amp_hours;
    me.charge_percent -= percent_used;
    if ( me.charge_percent < 0.0 ) {
        me.charge_percent = 0.0;
    } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
    }
    # print( "battery percent = ", me.charge_percent);
    return me.amp_hours * me.charge_percent;
}

##
# Return output volts based on percent charged.  Currently based on a simple
# polynomal percent charge vs. volts function.
#

BatteryClass.get_output_volts = func {
    x = 1.0 - me.charge_percent;
    tmp = -(3.0 * x - 1.0);
    factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
    return me.ideal_volts * factor;
}


##
# Return output amps available.  This function is totally wrong and should be
# fixed at some point with a more sensible function based on charge percent.
# There is probably some physical limits to the number of instantaneous amps
# a battery can produce (cold cranking amps?)
#

BatteryClass.get_output_amps = func {
    x = 1.0 - me.charge_percent;
    tmp = -(3.0 * x - 1.0);
    factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
    return me.ideal_amps * factor;
}


##
# Alternator model class.
#

AlternatorClass = {};

AlternatorClass.new = func {
    obj = { parents : [AlternatorClass],
            rpm_source : "/engines/engine[0]/rpm",
            rpm_threshold : 800.0,
            ideal_volts : 28.0,
            ideal_amps : 60.0 };
    setprop( obj.rpm_source, 0.0 );
    return obj;
}

##
# Computes available amps and returns remaining amps after load is applied
#

AlternatorClass.apply_load = func( amps, dt ) {
    # Scale alternator output for rpms < 800.  For rpms >= 800
    # give full output.  This is just a WAG, and probably not how
    # it really works but I'm keeping things "simple" to start.
    rpm = getprop( me.rpm_source );
    factor = rpm / me.rpm_threshold;
    if ( factor > 1.0 ) {
        factor = 1.0;
    }
    # print( "alternator amps = ", me.ideal_amps * factor );
    available_amps = me.ideal_amps * factor;
    return available_amps - amps;
}

##
# Return output volts based on rpm
#

AlternatorClass.get_output_volts = func {
    # scale alternator output for rpms < 800.  For rpms >= 800
    # give full output.  This is just a WAG, and probably not how
    # it really works but I'm keeping things "simple" to start.
    rpm = getprop( me.rpm_source );
    factor = rpm / me.rpm_threshold;
    if ( factor > 1.0 ) {
        factor = 1.0;
    }
    # print( "alternator volts = ", me.ideal_volts * factor );
    return me.ideal_volts * factor;
}


##
# Return output amps available based on rpm.
#

AlternatorClass.get_output_amps = func {
    # scale alternator output for rpms < 800.  For rpms >= 800
    # give full output.  This is just a WAG, and probably not how
    # it really works but I'm keeping things "simple" to start.
    rpm = getprop( me.rpm_source );
    factor = rpm / me.rpm_threshold;
    if ( factor > 1.0 ) {
        factor = 1.0;
    }
    # print( "alternator amps = ", ideal_amps * factor );
    return me.ideal_amps * factor;
}


##
# This is the main electrical system update function.
#

update_electrical = func {
    time = getprop("/sim/time/elapsed-sec");
    dt = time - last_time;
    last_time = time;

    update_virtual_bus( dt );

    # Request that the update fuction be called again next frame
    settimer(update_electrical, 0);
}


##
# Model the system of relays and connections that join the battery,
# alternator, starter, master/alt switches, external power supply.
#

update_virtual_bus = func( dt ) {
    serviceable = getprop("/systems/electrical/serviceable");
    if ( serviceable ) {
	battery_volts = battery.get_output_volts();
	alternator_volts = alternator.get_output_volts();
    } else {
	battery_volts = 0.0;
	alternator_volts = 0.0;
    }
    external_volts = 0.0;
    load = 0.0;

    # switch state
    master_bat = getprop("/controls/engines/engine[0]/master-bat");
    master_alt = getprop("/controls/engines/engine[0]/master-alt");

    # determine power source
    bus_volts = 0.0;
    power_source = nil;
    if ( master_bat ) {
        bus_volts = battery_volts;
        power_source = "battery";
    }
    if ( master_alt and (alternator_volts > bus_volts) ) {
        bus_volts = alternator_volts;
        power_source = "alternator";
    }
    if ( external_volts > bus_volts ) {
        bus_volts = external_volts;
        power_source = "external";
    }
    # print( "virtual bus volts = ", bus_volts );

    # starter motor
    var starter_switch = getprop("controls/switches/starter");
    var starter_volts = 0.0;
    if ( starter_switch ) {
        starter_volts = bus_volts;
        load += 12;
    }
    setprop("systems/electrical/outputs/starter[0]", starter_volts);
    if (starter_volts > 1) {
    setprop("controls/engines/engine[0]/starter",1);
    setprop("controls/engines/engine[0]/magnetos",3);
    } else {
    setprop("controls/engines/engine[0]/starter",0);
    }

    # bus network (1. these must be called in the right order, 2. the
    # bus routine itself determins where it draws power from.)
    load += electrical_bus_1();
    load += electrical_bus_2();
    load += cross_feed_bus();
    load += avionics_bus_1();
    load += avionics_bus_2();

    # system loads and ammeter gauge
    ammeter = 0.0;
    if ( bus_volts > 1.0 ) {
        # normal load
        load += 15.0;

        # ammeter gauge
        if ( power_source == "battery" ) {
            ammeter = -load;
        } else {
            ammeter = battery.charge_amps;
        }
    }
    # print( "ammeter = ", ammeter );

    # charge/discharge the battery
    if ( power_source == "battery" ) {
        battery.apply_load( load, dt );
    } elsif ( bus_volts > battery_volts ) {
        battery.apply_load( -battery.charge_amps, dt );
    }

    # filter ammeter needle pos
    ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;

    # outputs
    setprop("/systems/electrical/amps", ammeter_ave);
    setprop("/systems/electrical/volts", bus_volts);
    vbus_volts = bus_volts;

    return load;
}


electrical_bus_1 = func() {
    # we are fed from the "virtual" bus
    bus_volts = vbus_volts;
    load = 0.0;
    
    # Cabin Lights Power
    if ( getprop("/controls/circuit-breakers/cabin-lights-pwr") ) {
        setprop("/systems/electrical/outputs/cabin-lights", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/cabin-lights", 0.0);
    }

    # Instrument Power
    setprop("/systems/electrical/outputs/instr-ignition-switch", bus_volts);

    # Fuel Pump Power
    if ( getprop("/controls/engines/engine[0]/fuel-pump") ) {
        setprop("/systems/electrical/outputs/fuel-pump", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/fuel-pump", 0.0);
    }

    # Landing Light Power
    if ( getprop("/controls/switches/landing-light") ) {
        setprop("/systems/electrical/outputs/landing-light", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/landing-light", 0.0 );
    }

    # Beacon Power
    if ( getprop("/controls/switches/flashing-beacon" ) ) {
        setprop("/systems/electrical/outputs/beacon", bus_volts);
        if ( bus_volts > 1.0 ) { load += 7.5; }
    } else {
        setprop("/systems/electrical/outputs/beacon", 0.0);
    }

    # Flaps Power
    setprop("/systems/electrical/outputs/flaps", bus_volts);

    # register bus voltage
    ebus1_volts = bus_volts;

    # return cumulative load
    return load;
}


electrical_bus_2 = func() {
    # we are fed from the "virtual" bus
    bus_volts = vbus_volts;
    load = 0.0;

    # Turn Coordinator Power
    setprop("/systems/electrical/outputs/turn-coordinator", bus_volts);
  
    # Map Lights Power
    if ( getprop("/controls/switches/nav-lights" ) ) {
        setprop("/systems/electrical/outputs/map-lights", bus_volts);
        if ( bus_volts > 1.0 ) { load += 7.0; }
    } else {
        setprop("/systems/electrical/outputs/map-lights", 0.0);
    }
  
    # Instrument Lights Power
    setprop("/systems/electrical/outputs/instrument-lights", bus_volts);
  
    # Strobe Lights Power
    if ( getprop("/controls/switches/strobe-lights" ) ) {
        setprop("/systems/electrical/outputs/strobe-lights", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/strobe-lights", 0.0);
    }
  
    # Taxi Lights Power
    if ( getprop("/controls/switches/taxi-lights" ) ) {
        setprop("/systems/electrical/outputs/taxi-lights", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/taxi-lights", 0.0);
    }
  
    # Pitot Heat Power
    if ( getprop("/controls/switches/pitot-heat" ) ) {
        setprop("/systems/electrical/outputs/pitot-heat", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/pitot-heat", 0.0);
    }
  
    # register bus voltage
    ebus2_volts = bus_volts;

    # return cumulative load
    return load;
}


cross_feed_bus = func() {
    # we are fed from either of the electrical bus 1 or 2
    if ( ebus1_volts > ebus2_volts ) {
        bus_volts = ebus1_volts;
    } else {
        bus_volts = ebus2_volts;
    }

    load = 0.0;

    setprop("/systems/electrical/outputs/annunciators", bus_volts);

    # return cumulative load
    return load;
}


avionics_bus_1 = func() {
    master_av = getprop("/controls/switches/master-avionics");

    # we are fed from the electrical bus 1
    if ( master_av ) {
        bus_volts = ebus1_volts;
    } else {
        bus_volts = 0.0;
    }

    load = 0.0;
    
    # Avionics Fan Power
    setprop("/systems/electrical/outputs/avionics-fan", bus_volts);
    
    # GPS Power
    setprop("/systems/electrical/outputs/gps", bus_volts);
  
    # HSI Power
    setprop("/systems/electrical/outputs/hsi", bus_volts);
  
    # NavCom 1 Power
    setprop("/systems/electrical/outputs/nav[0]", bus_volts);
  
    # DME Power
    setprop("/systems/electrical/outputs/dme", bus_volts);
  
    # Audio Panel 1 Power
    setprop("/systems/electrical/outputs/audio-panel[0]", bus_volts);

    # Com 1 Power
    setprop("systems/electrical/outputs/comm[0]", bus_volts);

    # return cumulative load
    return load;
}


avionics_bus_2 = func() {
    master_av = getprop("/controls/switches/master-avionics");

    # we are fed from the electrical bus 2
    if ( master_av ) {
        bus_volts = ebus2_volts;
    } else {
        bus_volts = 0.0;
    }
    load = 0.0;

    # NavCom 2 Power
    setprop("/systems/electrical/outputs/nav[1]", bus_volts);

    # Audio Panel 2 Power
    setprop("/systems/electrical/outputs/audio-panel[1]", bus_volts);

    # Com 2 Power
    setprop("systems/electrical/outputs/comm[1]", bus_volts);

    # Transponder Power
    setprop("/systems/electrical/outputs/transponder", bus_volts);

    # Autopilot Power
    setprop("/systems/electrical/outputs/autopilot", bus_volts);

    # ADF Power
    setprop("/systems/electrical/outputs/adf", bus_volts);

    # return cumulative load
    return load;
}


# Setup a timer based call to initialized the electrical system as
# soon as possible.
settimer(init_electrical, 0);
