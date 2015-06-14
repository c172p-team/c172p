##
# Procedural model of a Cessna 172S electrical system.  Includes a
# preliminary battery charge/discharge model and realistic ammeter
# gauge modeling.
#


##
# Initialize internal values
#

var battery = nil;
var alternator = nil;

var last_time = 0.0;

var vbus_volts = 0.0;
var ebus1_volts = 0.0;
var ebus2_volts = 0.0;

var ammeter_ave = 0.0;

# number of seconds for a delay of the fuel and oil instruments 
var DELAY_SECS = 3;

##
# Initialize the electrical system
#

var init_electrical = func {
    battery = BatteryClass.new();
    alternator = AlternatorClass.new();
    
    props.globals.getNode("controls/circuit-breakers/aircond", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/master", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/flaps", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/pitot-heat", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/instr", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/intlt", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/navlt", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/bcnlt", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/landing", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/strobe", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/turn-coordinator", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/radio1", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/radio2", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/radio3", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/radio4", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/radio5", 1).setBoolValue(1);
    props.globals.getNode("controls/circuit-breakers/autopilot", 1).setBoolValue(1);

    # These two properties are aliased to MP properties in /sim/multiplay/generic/.
    # This aliasing seems to work in both ways, because the two properties below
    # appear to receive the random values from the MP properties during initialization.
    # Therefore, override these random values with the proper values we want.
    props.globals.getNode("sim/model/c172p/lighting/beacon-top/state", 0).setBoolValue(0);
    props.globals.getNode("sim/model/c172p/lighting/strobes/state", 0).setBoolValue(0);

    # Request that the update function be called next frame
    settimer(update_electrical, 0);
    print("Electrical system initialized");
}

var reset_battery_and_circuit_breakers = func {
    # Charge battery to 100 %
    battery.reset_to_full_charge();

    # Reset circuit breakers
    setprop("/controls/circuit-breakers/master", 1);
    setprop("/controls/circuit-breakers/flaps", 1);
    setprop("/controls/circuit-breakers/pitot-heat", 1);
    setprop("/controls/circuit-breakers/instr", 1);
    setprop("/controls/circuit-breakers/intlt", 1);
    setprop("/controls/circuit-breakers/navlt", 1);
    setprop("/controls/circuit-breakers/landing", 1);
    setprop("/controls/circuit-breakers/bcnlt", 1);
    setprop("/controls/circuit-breakers/strobe", 1);
    setprop("/controls/circuit-breakers/turn-coordinator", 1);
    setprop("/controls/circuit-breakers/radio1", 1);
    setprop("/controls/circuit-breakers/radio2", 1);
    setprop("/controls/circuit-breakers/radio3", 1);
    setprop("/controls/circuit-breakers/radio4", 1);
    setprop("/controls/circuit-breakers/radio5", 1);
    setprop("/controls/circuit-breakers/autopilot", 1);
}

##
# Battery model class.
#

var BatteryClass = {};

BatteryClass.new = func {
    var obj = { parents : [BatteryClass],
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
    var amphrs_used = amps * dt / 3600.0;
    var percent_used = amphrs_used / me.amp_hours;
    var charge_percent = me.charge_percent;
    charge_percent -= percent_used;
    if ( charge_percent < 0.0 ) {
        charge_percent = 0.0;
    } elsif ( charge_percent > 1.0 ) {
        charge_percent = 1.0;
    }
    if ((charge_percent < 0.1)and(me.charge_percent >= 0.1))
    {
        print("Warning: Low battery! Enable alternator or apply external power to recharge battery.");
    }
    me.charge_percent = charge_percent;
    setprop("/systems/electrical/battery-charge-percent", charge_percent);
    # print( "battery percent = ", charge_percent);
    return me.amp_hours * charge_percent;
}

##
# Return output volts based on percent charged.  Currently based on a simple
# polynomial percent charge vs. volts function.
#

BatteryClass.get_output_volts = func {
    var x = 1.0 - me.charge_percent;
    var tmp = -(3.0 * x - 1.0);
    var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
    return me.ideal_volts * factor;
}


##
# Return output amps available.  This function is totally wrong and should be
# fixed at some point with a more sensible function based on charge percent.
# There is probably some physical limits to the number of instantaneous amps
# a battery can produce (cold cranking amps?)
#

BatteryClass.get_output_amps = func {
    var x = 1.0 - me.charge_percent;
    var tmp = -(3.0 * x - 1.0);
    var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
    return me.ideal_amps * factor;
}

##
# Set the current charge instantly to 100 %.
#

BatteryClass.reset_to_full_charge = func {
    me.apply_load(-(1.0 - me.charge_percent) * me.amp_hours, 3600);
}

##
# Alternator model class.
#

var AlternatorClass = {};

AlternatorClass.new = func {
    var obj = { parents : [AlternatorClass],
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
    var rpm = getprop( me.rpm_source );
    var factor = rpm / me.rpm_threshold;
    if ( factor > 1.0 ) {
        factor = 1.0;
    }
    # print( "alternator amps = ", me.ideal_amps * factor );
    var available_amps = me.ideal_amps * factor;
    return available_amps - amps;
}

##
# Return output volts based on rpm
#

AlternatorClass.get_output_volts = func {
    # scale alternator output for rpms < 800.  For rpms >= 800
    # give full output.  This is just a WAG, and probably not how
    # it really works but I'm keeping things "simple" to start.
    var rpm = getprop( me.rpm_source );
    var factor = rpm / me.rpm_threshold;
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
    var rpm = getprop( me.rpm_source );
    var factor = rpm / me.rpm_threshold;
    if ( factor > 1.0 ) {
        factor = 1.0;
    }
    # print( "alternator amps = ", ideal_amps * factor );
    return me.ideal_amps * factor;
}


##
# This is the main electrical system update function.
#

var update_electrical = func {
    var time = getprop("/sim/time/elapsed-sec");
    var dt = time - last_time;
    last_time = time;

    update_virtual_bus( dt );

    # Request that the update function be called again next frame
    settimer(update_electrical, 0);
}


##
# Model the system of relays and connections that join the battery,
# alternator, starter, master/alt switches, external power supply.
#

var update_virtual_bus = func( dt ) {
    var serviceable = getprop("/systems/electrical/serviceable");
    var external_volts = 0.0;
    var load = 0.0;
    var battery_volts = 0.0;
    var alternator_volts = 0.0;
    if ( serviceable ) {
        battery_volts = battery.get_output_volts();
        alternator_volts = alternator.get_output_volts();
    }

    # switch state
    var master_bat = getprop("/controls/engines/engine[0]/master-bat");
    var master_alt = getprop("/controls/engines/engine[0]/master-alt");
    if (getprop("/controls/electric/external-power"))
    {
        external_volts = 28;
    }

    # determine power source
    var bus_volts = 0.0;
    var power_source = nil;
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
    #print( "virtual bus volts = ", bus_volts );

    # bus network (1. these must be called in the right order, 2. the
    # bus routine itself determins where it draws power from.)
    load += electrical_bus_1();
    load += avionics_bus_1();
    
    # swtich the master breaker off if load is out of limits
    if ( load > 55 ) {
      bus_volts = 0;
    }

    # system loads and ammeter gauge
    var ammeter = 0.0;
    if ( bus_volts > 1.0 ) {
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
    if (bus_volts > 12)
        vbus_volts = bus_volts;
    else
        vbus_volts = 0.0;

    return load;
}


var electrical_bus_1 = func() {
    var bus_volts = 0.0;
    var load = 0.0;
    
    # check master breaker
    if ( getprop("/controls/circuit-breakers/master") ) {
        # we are feed from the virtual bus
        bus_volts = vbus_volts;        
    }
    #print("Bus volts: ", bus_volts);
    
    # Air-cond
    if ( getprop("/controls/circuit-breakers/aircond-pwr") ) {
        setprop("/systems/electrical/outputs/aircond", bus_volts);
        load += bus_volts / 57;
    } else {
        setprop("/systems/electrical/outputs/cabin-lights", 0.0);
    }
    
    # Flaps
    if ( getprop("/controls/circuit-breakers/flaps") ) {
        setprop("/systems/electrical/outputs/flaps", bus_volts);
        load += bus_volts / 57;
    } else {
        setprop("/systems/electrical/outputs/flaps", 0.0);
    }
    
    # Pitot Heat Power
    if ( getprop("/controls/anti-ice/pitot-heat" ) ) {
        setprop("/systems/electrical/outputs/pitot-heat", bus_volts);
        load += bus_volts / 28;
    } else {
        setprop("/systems/electrical/outputs/pitot-heat", 0.0);
    }

    # Cabin Lights Power
    if ( getprop("/controls/circuit-breakers/cabin-lights-pwr") ) {
        setprop("/systems/electrical/outputs/cabin-lights", bus_volts);
        load += bus_volts / 57;
    } else {
        setprop("/systems/electrical/outputs/cabin-lights", 0.0);
    }

    # Instrument Power: ignition, fuel, oil temperature
    if ( getprop("/controls/circuit-breakers/instr") ) {
        setprop("/systems/electrical/outputs/instr-ignition-switch", bus_volts);
        if ( bus_volts > 12 ) {
            # starter
            if ( getprop("controls/switches/starter") ) {
                setprop("systems/electrical/outputs/starter[0]", bus_volts);
                setprop("controls/engines/engine[0]/starter", 1);
                load += 12;
            } else {
                setprop("controls/engines/engine[0]/starter", 0);
            }
            # fuel
            interpolate("consumables/fuel/tank[0]/indicated-level-gal_us", getprop("consumables/fuel/tank[0]/level-gal_us"), DELAY_SECS);
            interpolate("consumables/fuel/tank[1]/indicated-level-gal_us", getprop("consumables/fuel/tank[1]/level-gal_us"), DELAY_SECS);
            # oil
            interpolate("engines/engine[0]/indicated-oil-temperature-degf", getprop("engines/engine[0]/oil-temperature-degf"), DELAY_SECS);
            interpolate("engines/engine[0]/indicated-oil-pressure-psi", getprop("engines/engine[0]/oil-pressure-psi"), DELAY_SECS);
            load += bus_volts / 57;
        } else {
            setprop("systems/electrical/outputs/starter[0]", 0.0);
            setprop("controls/engines/engine[0]/starter", 0);
            interpolate("consumables/fuel/tank[0]/indicated-level-gal_us", 0, DELAY_SECS);
            interpolate("consumables/fuel/tank[1]/indicated-level-gal_us", 0, DELAY_SECS);
            interpolate("engines/engine[0]/indicated-oil-temperature-degf", 0, DELAY_SECS);
            interpolate("engines/engine[0]/indicated-oil-pressure-psi", 0, DELAY_SECS);
        }
    } else {
        setprop("/systems/electrical/outputs/instr-ignition-switch", 0.0);
        setprop("/systems/electrical/outputs/starter[0]", 0.0);
        setprop("controls/engines/engine[0]/starter", 0);
        interpolate("consumables/fuel/tank[0]/indicated-level-gal_us", 0, DELAY_SECS);
        interpolate("consumables/fuel/tank[1]/indicated-level-gal_us", 0, DELAY_SECS);
        interpolate("engines/engine[0]/indicated-oil-temperature-degf", 0, DELAY_SECS);
        interpolate("engines/engine[0]/indicated-oil-pressure-psi", 0, DELAY_SECS);
    }
    
    # Interior lights
    if ( getprop("/controls/circuit-breakers/intlt") ) {
        setprop("/systems/electrical/outputs/instrument-lights", bus_volts);
        load += bus_volts / 57;
    } else {
        setprop("/systems/electrical/outputs/instrument-lights", 0.0);
    }    

    # Landing Light Power
    if ( getprop("/controls/circuit-breakers/landing") and getprop("/controls/lighting/landing-lights") ) {
        setprop("/systems/electrical/outputs/landing-lights", bus_volts);
        load += bus_volts / 5;
    } else {
        setprop("/systems/electrical/outputs/landing-lights", 0.0 );
    }    
        
    # Taxi Lights Power
    # Notice taxi lights also use landing lights breaker. It is not a bug.
    if ( getprop("/controls/circuit-breakers/landing") and getprop("/controls/lighting/taxi-light" ) ) {
        setprop("/systems/electrical/outputs/taxi-light", bus_volts);
        load += bus_volts / 10;
    } else {
        setprop("/systems/electrical/outputs/taxi-light", 0.0);
    }

    # Beacon Power
    if ( getprop("/controls/circuit-breakers/bcnlt") and getprop("/controls/lighting/beacon" ) ) {
        setprop("/systems/electrical/outputs/beacon", bus_volts);
        load += bus_volts / 28;
    } else {
        setprop("/systems/electrical/outputs/beacon", 0.0);
    }
    
    # Nav Lights Power
    if ( getprop("/controls/circuit-breakers/navlt") and getprop("/controls/lighting/nav-lights" ) ) {
        setprop("/systems/electrical/outputs/nav-lights", bus_volts);
        load += bus_volts / 14;
    } else {
        setprop("/systems/electrical/outputs/nav-lights", 0.0);
    }

          
    # Strobe Lights Power
    if ( getprop("/controls/circuit-breakers/strobe") and getprop("/controls/lighting/strobe" ) ) {
        setprop("/systems/electrical/outputs/strobe", bus_volts);
        load += bus_volts / 14;
    } else {
        setprop("/systems/electrical/outputs/strobe", 0.0);
    }
    
    # Turn Coordinator and directional gyro Power
    if ( getprop("/controls/circuit-breakers/turn-coordinator") ) {
        setprop("/systems/electrical/outputs/turn-coordinator", bus_volts);
        setprop("/systems/electrical/outputs/DG", bus_volts);
        load += bus_volts / 14;
    } else {
        setprop("/systems/electrical/outputs/turn-coordinator", 0.0);
        setprop("/systems/electrical/outputs/DG", 0.0);
    }

    # register bus voltage
    ebus1_volts = bus_volts;

    # return cumulative load
    return load;
}

var avionics_bus_1 = func() {
    var bus_volts = 0.0;
    var load = 0.0;

    # we are fed from the electrical bus 1
    var master_av = getprop("/controls/switches/master-avionics");
    if ( master_av ) {
        bus_volts = ebus1_volts;
    }

    load += bus_volts / 20.0;

    # Avionics Fan Power
    #setprop("/systems/electrical/outputs/avionics-fan", bus_volts);

    # Audio Panel 1 Power
    if ( getprop("/controls/circuit-breakers/radio1") ) {
      setprop("/systems/electrical/outputs/audio-panel[0]", bus_volts);
    } else {
      setprop("/systems/electrical/outputs/audio-panel[0]", 0.0);
    }

    # Com and Nav 1 Power
    if ( getprop("/controls/circuit-breakers/radio2") ) {
      setprop("/systems/electrical/outputs/nav[0]", bus_volts);
      setprop("systems/electrical/outputs/comm[0]", bus_volts);
    } else {
      setprop("/systems/electrical/outputs/nav[0]", 0.0);
      setprop("systems/electrical/outputs/comm[0]", 0.0);
    }
    
    # Com and Nav 2 Power
    if ( getprop("/controls/circuit-breakers/radio3") ) {
      setprop("/systems/electrical/outputs/nav[1]", bus_volts);
      setprop("systems/electrical/outputs/comm[1]", bus_volts);
    } else {
      setprop("/systems/electrical/outputs/nav[1]", 0.0);
      setprop("systems/electrical/outputs/comm[1]", 0.0);
    }

    # Transponder Power
    if ( getprop("/controls/circuit-breakers/radio4") ) {
      setprop("/systems/electrical/outputs/transponder", bus_volts);
    } else {
      setprop("/systems/electrical/outputs/transponder", 0.0);
    }
    
    # DME and ADF Power
    if ( getprop("/controls/circuit-breakers/radio5") ) {
      setprop("/systems/electrical/outputs/dme", bus_volts);
      setprop("/systems/electrical/outputs/adf", bus_volts);
    } else {
      setprop("/systems/electrical/outputs/dme", 0.0);
      setprop("/systems/electrical/outputs/adf", 0.0);
    }

    # Autopilot Power
    if ( getprop("/controls/circuit-breakers/autopilot") ) {
      setprop("/systems/electrical/outputs/autopilot", bus_volts);
    } else {
      setprop("/systems/electrical/outputs/autopilot", 0.0);
    }
    

    # return cumulative load
    return load;
}


# Setup a timer based call to initialized the electrical system as
# soon as possible.
settimer(init_electrical, 0);

############################ Utility function

# (from the g115) Only move flaps if voltage is sufficient
var flapsDown = controls.flapsDown;
controls.flapsDown = func(v){
  var volts = getprop("systems/electrical/outputs/flaps");
  print("Flap Volts: ",volts);
  flapsDown(volts > 16 ? v : 0);
}
