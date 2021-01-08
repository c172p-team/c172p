var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
io.load_nasal(nasal_dir ~ 'FG1000.nas', "fg1000");
var aircraft_dir = getprop("/sim/aircraft-dir");
io.load_nasal(aircraft_dir ~ '/Nasal/Interfaces/SelectableInterfaceController.nas', "fg1000");

var interfaceController = fg1000.SelectableInterfaceController.getOrCreateInstance();
interfaceController.start();

# Create the FG1000
var fg1000system = fg1000.FG1000.getOrCreateInstance();

# Create a PFD as device 1, MFD as device 2
fg1000system.addPFD(1);
fg1000system.addMFD(2);

# Display the devices
fg1000system.display(1);
fg1000system.display(2);

#  Display a GUI version of device 1 at 50% scale.
#fg1000system.displayGUI(1, 0.5);

##
# Procedural model of a Cessna 172S electrical system.  Includes a
# preliminary battery charge/discharge model and realistic ammeter
# gauge modeling.
#

##
# Beacon and Strobe intermittent instantiation
#

aircraft.light.new("/sim/model/c172p/lighting/strobes", [0.1, 1.3], "controls/lighting/strobe");
aircraft.light.new("/sim/model/c172p/lighting/beacon", [0.3, 1.3], "controls/lighting/beacon");

##
# Initialize internal values
#

var vbus_volts = 0.0;
var vbus_stby_volts = 0.0;

var ebus1_volts = 0.0;
var ebus2_volts = 0.0;
var avn1_volts = 0.0;
var avn2_volts = 0.0;

var ammeter_ave = 0.0;

var feeder_a = 0.0;
var feeder_b = 0.0;

var master_bat = 0.0;
var master_alt = 0.0;
var master_bat_stby = 0.0;

var master_av1 = 0.0;
var master_av2 = 0.0;

var pfd_display = 0.0;

var stby_batt_breaker = 0.0;

var old_flap_position = 0;
var current_flap_position = getprop("/surface-positions/flap-pos-norm");
var old_gear_position = 0;
var current_gear_position = getprop("/controls/gear/gear-down-command");

var current_load = 0.0;

##
# Battery model class.
#

var BatteryClass = {};

BatteryClass.new = func (x) {
    var obj = { parents : [BatteryClass],
      ideal_volts : 24.0,
      ideal_amps : 30.0,
      amp_hours : 3.1875,
      charge_percent : getprop("/systems/electrical/battery-charge-percent/"~x) or 1.0,
      charge_amps : 7.0 };
    setprop("/systems/electrical/battery-charge-percent/"~x, obj.charge_percent);
    return obj;
}

##
# Passing in positive amps means the battery will be discharged.
# Negative amps indicates a battery charge.
#

BatteryClass.apply_load = func (amps, dt, x) {
    var old_charge_percent = getprop("/systems/electrical/battery-charge-percent/"~x);

    if (getprop("/sim/freeze/replay-state"))
        return me.amp_hours * old_charge_percent;

    var amphrs_used = amps * dt / 3600.0;
    var percent_used = amphrs_used / me.amp_hours;

    var new_charge_percent = std.max(0.0, std.min(old_charge_percent - percent_used, 1.0));

    if (new_charge_percent < 0.1 and old_charge_percent >= 0.1)
        gui.popupTip("Warning: Low battery! Enable alternator or apply external power to recharge battery!", 10);
    me.charge_percent = new_charge_percent;
    setprop("/systems/electrical/battery-charge-percent/"~x, new_charge_percent);
    return me.amp_hours * new_charge_percent;
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

BatteryClass.reset_to_full_charge = func (x) {
    me.apply_load(-(1.0 - me.charge_percent) * me.amp_hours, 3600, x);
}

##
# Alternator model class.
#

var AlternatorClass = {};

AlternatorClass.new = func {
    var obj = { parents : [AlternatorClass],
                rpm_source : "/engines/active-engine/rpm",
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

var battery = BatteryClass.new("a");
var battery_stby = BatteryClass.new("b");
var alternator = AlternatorClass.new();

var reset_battery_and_circuit_breakers = func {

    # Charge battery to 100 %
    battery.reset_to_full_charge("a");
    # Charge battery to 100 %
    battery_stby.reset_to_full_charge("b");

    # feeder breakers in cowling
    setprop("/controls/circuit-breakers/feeder-b", 1);
    setprop("/controls/circuit-breakers/feeder-a", 1);

    setprop("/controls/circuit-breakers/autopilot", 1);
    setprop("/controls/circuit-breakers/adc-ahrs-avn", 1);
    setprop("/controls/circuit-breakers/adc-ahrs-ess", 1);
    setprop("/controls/circuit-breakers/alt-field", 1);
    setprop("/controls/circuit-breakers/audio", 1);
    setprop("/controls/circuit-breakers/autopilot", 1);
    setprop("/controls/circuit-breakers/avn1", 1);
    setprop("/controls/circuit-breakers/strobe", 1);
    setprop("/controls/circuit-breakers/bcnlt", 1);
    setprop("/controls/circuit-breakers/landing", 1);
    setprop("/controls/circuit-breakers/navlt", 1);
    setprop("/controls/circuit-breakers/intlt", 1);
    setprop("/controls/circuit-breakers/instr", 1);
    setprop("/controls/circuit-breakers/pitot-heat", 1);
    setprop("/controls/circuit-breakers/flaps", 1);
    setprop("/controls/circuit-breakers/avn2", 1);
    setprop("/controls/circuit-breakers/comm1", 1);
    setprop("/controls/circuit-breakers/comm2", 1);
    setprop("/controls/circuit-breakers/dme-adf", 1);
    setprop("/controls/circuit-breakers/fis", 1);
    setprop("/controls/circuit-breakers/fuel-pump", 1);
    setprop("/controls/circuit-breakers/mfd", 1);
    setprop("/controls/circuit-breakers/nav1-eng-avn", 1);
    setprop("/controls/circuit-breakers/nav1-eng-ess", 1);
    setprop("/controls/circuit-breakers/nav2", 1);
    setprop("/controls/circuit-breakers/pfd-avn", 1);
    setprop("/controls/circuit-breakers/pfd-ess", 1);
    setprop("/controls/circuit-breakers/stdby-batt", 1);
    setprop("/controls/circuit-breakers/stdby-ndlts", 1);
    setprop("/controls/circuit-breakers/taxi", 1);
    setprop("/controls/circuit-breakers/warn", 1);
    setprop("/controls/circuit-breakers/xpndr", 1);

    if (getprop("/fdm/jsbsim/bushkit") == 4) {
        setprop("/controls/circuit-breakers/gear-select", 1);
        setprop("/controls/circuit-breakers/gear-advisory", 1);
        setprop("/controls/circuit-breakers/hydraulic-pump", 1);
    }
}

##
# This is the main electrical system update function.
#

var ElectricalSystemUpdater = {
    new : func {
        var m = {
            parents: [ElectricalSystemUpdater]
        };
        # Request that the update function be called each frame
        m.loop = updateloop.UpdateLoop.new(components: [m], update_period: 0.0, enable: 0);
        return m;
    },

    enable: func {
        me.loop.reset();
        me.loop.enable();
    },

    disable: func {
        me.loop.disable();
    },

    reset: func {
        # Do nothing
    },

    update: func (dt) {
        update_virtual_bus(dt);
    }
};

##
# Model the system of relays and connections that join the battery,
# alternator, starter, master/alt switches, external power supply.
#

var update_virtual_bus = func (dt) {
    var serviceable = getprop("/systems/electrical/serviceable");
    var external_volts = 0.0;
    var load = 0.0;
    var battery_volts = 0.0;
    var battery_stby_volts = 0.0;
    var alternator_volts = 0.0;
    if ( serviceable ) {
        battery_volts = battery.get_output_volts();
        battery_stby_volts = battery_stby.get_output_volts();
        alternator_volts = alternator.get_output_volts();
    }

    # switch state
    master_bat = getprop("/controls/switches/master-bat");
    master_alt = getprop("/controls/switches/master-alt");
    master_bat_stby = getprop("/controls/switches/stby-batt");
    if (getprop("/controls/electric/external-power"))
    {
        external_volts = 28;
    }

    # determine power source
    var bus_volts = 0.0;
    var stby_bus_volts = 0.0;
    var power_source = "None";
    var switch_pos = getprop("controls/switches/stby-batt");

    if ( master_bat ) {
        bus_volts = battery_volts;
        power_source = "battery";
        if (switch_pos == 2 ) {
            setprop("controls/lighting/batt-test-lamp-norm", 0);
        }
    } 

    if (master_bat_stby == 2 and !master_bat) {
        stby_bus_volts = battery_stby_volts;
        power_source = "battery_stby";
        if (current_load > 5) {
            setprop("controls/lighting/batt-test-lamp-norm", 1);
        }
    }

    if ( master_alt and (alternator_volts > bus_volts) ) {
        bus_volts = alternator_volts;
        power_source = "alternator";
        if (switch_pos == 2 ) {
            setprop("controls/lighting/batt-test-lamp-norm", 0);
        }
    }
    
    if ( external_volts > bus_volts ) {
        bus_volts = external_volts;
        power_source = "external";
        if (switch_pos == 2 ) {
            setprop("controls/lighting/batt-test-lamp-norm", 0);
        }
    }

    setprop("/systems/electrical/powersource", power_source);
    setprop("/systems/electrical/load", load);

    # bus network (
    # 1. these must be called in the right order, 
    # 2. the bus routine itself determins where it draws power from.
    # )
    load += electrical_bus_1();
    load += electrical_bus_2();
    load += avionics_bus_1();
    load += avionics_bus_2();
    load += essential_bus();

    # swtich the master breaker off if load is out of limits (247 max load)
    if ( load > 250 ) {
      #bus_volts = 0;
      setprop("/controls/circuit-breakers/feeder-b", 0);
      setprop("/controls/circuit-breakers/feeder-a", 0);
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
    if (power_source == "battery") {
        battery.apply_load( load, dt, "a");
    } 
    if (power_source == "battery_stby") {
        battery_stby.apply_load( load, dt, "b");
    } 
    if (bus_volts > battery_volts) {
        battery.apply_load(-battery.charge_amps, dt, "a");
    }
    if (master_bat_stby == 2) {
        if (bus_volts > battery_stby_volts)
            battery_stby.apply_load(-battery_stby.charge_amps, dt, "b");
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

    if (stby_bus_volts > 12)
        vbus_stby_volts = stby_bus_volts;
    else
        vbus_stby_volts = 0.0;

    # Feeder A
    if (getprop("/controls/circuit-breakers/feeder-a")) {
        setprop("/systems/electrical/outputs/feeder-a", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/feeder-a", 0.0);
    }
    # Feeder B
    if (getprop("/controls/circuit-breakers/feeder-b")) {
        setprop("/systems/electrical/outputs/feeder-b", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/feeder-b", 0.0);
    }
    feeder_a = getprop("/systems/electrical/outputs/feeder-a");
    feeder_b = getprop("/systems/electrical/outputs/feeder-b");

    master_av1 = getprop("/controls/switches/master-avionics");
    master_av2 = getprop("/controls/switches/master-avionics2");

    # starter fed from the virtual bus or stby batt
    if ((master_bat or master_alt) and (feeder_a or feeder_b)) {
        setprop("/systems/electrical/outputs/instr-ignition-switch", bus_volts);
        if ( bus_volts > 12 ) {
            if (getprop("controls/switches/starter")) {
                setprop("systems/electrical/outputs/starter", bus_volts);
            } else {
                setprop("systems/electrical/outputs/starter", 0.0);
            }
        } else {
            setprop("systems/electrical/outputs/starter", 0.0);
        }
    }

    current_load = load;
setprop("/systems/electrical/current-load", current_load);

    return load;
}

var electrical_bus_1 = func() {
    var bus_volts = 0.0;
    var load = 0.0;

    # feed through feeder-b breaker and master_bat or master_alt
    if (feeder_b and (master_bat or master_alt)) {
         bus_volts = vbus_volts;
    }

    # Fuel Pump
    if (getprop("/controls/circuit-breakers/fuel-pump") and getprop("controls/fuel/fuel-pump")) {
        setprop("/systems/electrical/outputs/fuel-pump", bus_volts);
        load += bus_volts / 5;
    } else {
        setprop("/systems/electrical/outputs/fuel-pump", 0.0);
    }

    # Beacon Power 5 amp breaker
    if ( getprop("/controls/circuit-breakers/bcnlt") and getprop("/controls/lighting/beacon" ) ) {
        setprop("/systems/electrical/outputs/beacon", bus_volts);
        load += bus_volts / 28;
    } else {
        setprop("/systems/electrical/outputs/beacon", 0.0);
    }

    # Landing Light Power
    if ( getprop("/controls/circuit-breakers/landing") and getprop("/controls/lighting/landing-lights") ) {
        setprop("/systems/electrical/outputs/landing-lights", bus_volts);
        load += bus_volts / 10;
    } else {
        setprop("/systems/electrical/outputs/landing-lights", 0.0 );
    }

    # Interior lights 5 amp breaker
    if ( getprop("/controls/circuit-breakers/intlt") and getprop("/controls/switches/toggle-cabin-pwr")) {
        setprop("/systems/electrical/outputs/cabin-lights", bus_volts);
        if (getprop("/controls/switches/dome-white")) {
            load += bus_volts / 14.25 * getprop("/controls/lighting/dome-white-norm");
        }
        if (getprop("/controls/switches/dome-red")) {
            load += bus_volts / 14.25 * getprop("/controls/lighting/instruments-norm");
        }
    } else {
        setprop("/systems/electrical/outputs/cabin-lights", 0.0);
    }

    # Flaps 10 amp breaker
    if (getprop("/controls/circuit-breakers/flaps")) {
        setprop("/systems/electrical/outputs/flaps", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/flaps", 0.0);
    }
    current_flap_position = getprop("/surface-positions/flap-pos-norm");
    if (current_flap_position != old_flap_position) {
        old_flap_position = current_flap_position;
        if (getprop("/systems/electrical/outputs/flaps") > 12) {
            load += bus_volts / 57;
            settimer(func(){
                load += bus_volts;
            }, 3);
        }
    }

    # AVN1
    if ( getprop("/controls/circuit-breakers/avn1") ) {
        setprop("/systems/electrical/outputs/avn1", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/avn1", 0.0);
    }

    # register bus voltage
    ebus1_volts = bus_volts;

    # return cumulative load
    return load;
}

var electrical_bus_2 = func() {
    var bus_volts = 0.0;
    var load = 0.0;

    # feed through feeder-a breaker and master_bat or master_alt
    if (feeder_a and (master_bat or master_alt)) {
         bus_volts = vbus_volts;
    }

    # Pitot Heat Power 5 amp breaker
    if ( getprop("/controls/circuit-breakers/pitot-heat") and  getprop("/controls/anti-ice/pitot-heat" ) ) {
        setprop("/systems/electrical/outputs/pitot-heat", bus_volts);
        load += bus_volts / 28;
    } else {
        setprop("/systems/electrical/outputs/pitot-heat", 0.0);
    }

    # Nav Lights Power 5 amp breaker
    if ( getprop("/controls/circuit-breakers/navlt") and getprop("/controls/lighting/nav-lights" ) ) {
        setprop("/systems/electrical/outputs/nav-lights", bus_volts);
        load += bus_volts / 14;
    } else {
        setprop("/systems/electrical/outputs/nav-lights", 0.0);
    }

    # Taxi Lights Power
    if ( getprop("/controls/circuit-breakers/taxi") and getprop("/controls/lighting/taxi-light" ) ) {
        setprop("/systems/electrical/outputs/taxi-light", bus_volts);
        load += bus_volts / 10;
    } else {
        setprop("/systems/electrical/outputs/taxi-light", 0.0);
    }

    # Strobe Lights Power 5 amp breaker
    if ( getprop("/controls/circuit-breakers/strobe") and getprop("/controls/lighting/strobe" ) ) {
        setprop("/systems/electrical/outputs/strobe", bus_volts);
        setprop("/systems/electrical/outputs/strobe-norm", (bus_volts/24));
        load += bus_volts / 14;
    } else {
        setprop("/systems/electrical/outputs/strobe", 0.0);
        setprop("/systems/electrical/outputs/strobe-norm", 0.0);
    }

    # Panel Power 5 amp breaker
    if ( getprop("/controls/circuit-breakers/instr") ) {
        setprop("/systems/electrical/outputs/instrument-lights", bus_volts);
        #load += bus_volts / 28.5;
    } else {
        setprop("/systems/electrical/outputs/instrument-lights", 0.0);
    }

    # AVN2
    if ( getprop("/controls/circuit-breakers/avn2") ) {
        setprop("/systems/electrical/outputs/avn2", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/avn2", 0.0);
    }

    # register bus voltage
    ebus2_volts = bus_volts;

    # return cumulative load
    return load;
}

var avionics_bus_1 = func() {
    var bus_volts = 0.0;
    var load = 0.0;

    # feed through ebus1 avn1 breaker and avn1 switch
    if (getprop("/controls/switches/master-avionics"))
        bus_volts = getprop("/systems/electrical/outputs/avn1");

    # FG1000 PFD
    if ( getprop("/controls/circuit-breakers/pfd-avn") ) {
      setprop("/systems/electrical/outputs/pfd-avn", bus_volts);
    } else {
      setprop("/systems/electrical/outputs/pfd-avn", 0.0);
    }
    pfd_display = getprop("/systems/electrical/outputs/pfd-avn");
 
    # Air Data Computer
    if ( getprop("/controls/circuit-breakers/adc-ahrs-avn") ) {
      setprop("/systems/electrical/outputs/adc-ahrs", bus_volts);
      #load += bus_volts / 10;
    } else {
      setprop("/systems/electrical/outputs/adc-ahrs", 0.0);
    }

    # Nav 1 Power
    if ( getprop("/controls/circuit-breakers/nav1-eng-ess") ) {
      setprop("/systems/electrical/outputs/nav[0]", bus_volts);
      #load += bus_volts / 15;
    } else {
      setprop("/systems/electrical/outputs/nav[0]", 0.0);
    }

    # FIS
    if ( getprop("/controls/circuit-breakers/fis") ) {
      setprop("/systems/electrical/outputs/is", bus_volts);
      #load += bus_volts / 5;
    } else {
      setprop("/systems/electrical/outputs/is", 0.0);
    }

    # DME and ADF Power
    if ( getprop("/controls/circuit-breakers/dme-adf") ) {
      setprop("/systems/electrical/outputs/dme", bus_volts);
      setprop("/systems/electrical/outputs/adf", bus_volts);
      #load += bus_volts / 5;
    } else {
      setprop("/systems/electrical/outputs/dme", 0.0);
      setprop("/systems/electrical/outputs/adf", 0.0);
    }

     ##############????????#############
    # Turn Coordinator and directional gyro Power
    if ( getprop("/controls/circuit-breakers/turn-coordinator") ) {
        setprop("/systems/electrical/outputs/turn-coordinator", bus_volts);
        setprop("/systems/electrical/outputs/DG", bus_volts);
        #load += bus_volts / 14;
    } else {
        setprop("/systems/electrical/outputs/turn-coordinator", 0.0);
        setprop("/systems/electrical/outputs/DG", 0.0);
    }

    # register avn1 voltage
    avn1_volts = bus_volts;

    # return cumulative load
    return load;
}

var avionics_bus_2 = func() {
    var bus_volts = 0.0;
    var load = 0.0;

    if (getprop("/controls/switches/master-avionics2"))
        bus_volts = getprop("/systems/electrical/outputs/avn2");

    # FG1000 MFD
    if ( getprop("/controls/circuit-breakers/mfd") ) {
      setprop("/systems/electrical/outputs/mfd", bus_volts);
      if (bus_volts > 0) {
          fg1000system.show(2);
		  setprop("/instrumentation/FG1000/Lightmap", 5);
      } else {
          fg1000system.hide(2);
		  setprop("/instrumentation/FG1000/Lightmap", 0);
      }
      load += bus_volts / 5;
    } else {
      setprop("/systems/electrical/outputs/mfd", 0.0);
      fg1000system.hide(2);
    }

    # Transponder Power
    if ( getprop("/controls/circuit-breakers/xpndr") ) {
      setprop("/systems/electrical/outputs/transponder", bus_volts);
      load += bus_volts / 5;
    } else {
      setprop("/systems/electrical/outputs/transponder", 0.0);
    }

    # Nav 2 Power and Avionics Fan Power
    if ( getprop("/controls/circuit-breakers/nav2") ) {
      setprop("/systems/electrical/outputs/nav[1]", bus_volts);
      setprop("/systems/electrical/outputs/avionics-fan", bus_volts);
      load += bus_volts / 5;
    } else {
      setprop("/systems/electrical/outputs/nav[1]", 0.0);
      setprop("/systems/electrical/outputs/avionics-fan", 0.0);
    }

    # Com 2 Power
    if ( getprop("/controls/circuit-breakers/comm2") ) {
      setprop("systems/electrical/outputs/comm[1]", bus_volts);
      load += bus_volts / 5;
    } else {
      setprop("systems/electrical/outputs/comm[1]", 0.0);
    }

    # Audio Panel 1 Power
    if ( getprop("/controls/circuit-breakers/audio") ) {
      setprop("/systems/electrical/outputs/audio-panel[0]", bus_volts);
      load += bus_volts / 5;
    } else {
      setprop("/systems/electrical/outputs/audio-panel[0]", 0.0);
    }

    # Autopilot Power
    if ( getprop("/controls/circuit-breakers/autopilot") ) {
      setprop("/systems/electrical/outputs/autopilot", bus_volts);
      load += bus_volts / 5;
    } else {
      setprop("/systems/electrical/outputs/autopilot", 0.0);
    }

    # register avn2 voltage
    avn2_volts = bus_volts;

    # return cumulative load
    return load;
}

var essential_bus = func() {
    var bus_volts = 0.0;
    var load = 0.0; 

    # feed through bus1 and bus2 or stby-batt-breaker
    var total_bus_volts = (ebus1_volts + ebus2_volts) * .5;
    if (total_bus_volts) {
        bus_volts = total_bus_volts;
    } else {
        if (master_bat_stby == 2) {
            if (getprop("/controls/circuit-breakers/stdby-batt") ) {
              bus_volts = vbus_stby_volts;
            } else {
              bus_volts = 0.0;
            } 
        } else
            bus_volts = 0.0;
    }
    #print("Bus volts: ", bus_volts);

    # FG1000 PFD
    if (getprop("/controls/circuit-breakers/pfd-ess") ) {
        setprop("/systems/electrical/outputs/pfd-ess", bus_volts);
        load += bus_volts / 5;
    } else {
        setprop("/systems/electrical/outputs/pfd-ess", 0.0);
    }
    if (pfd_display or getprop("/systems/electrical/outputs/pfd-ess") > 12) {
        fg1000system.show(1);
		setprop("/instrumentation/FG1000/Lightmap", 5);
    } else {
        fg1000system.hide(1);
		setprop("/instrumentation/FG1000/Lightmap", 0);
    }

    # Air Data Computer
    if (getprop("/controls/circuit-breakers/adc-ahrs-ess")) {
        setprop("/systems/electrical/outputs/adc-ahrs", bus_volts);
        load += bus_volts / 10;
    } else {
        setprop("/systems/electrical/outputs/adc-ahrs", 0.0);
    }

    # Nav 1 Power
    if (getprop("/controls/circuit-breakers/nav1-eng-ess")) {
        setprop("/systems/electrical/outputs/nav[0]", bus_volts);
        load += bus_volts / 15;
    } else {
        setprop("/systems/electrical/outputs/nav[0]", 0.0);
    }

    # Com 1 Power
    if (getprop("/controls/circuit-breakers/comm1")) {
        setprop("systems/electrical/outputs/comm[0]", bus_volts);
        load += bus_volts / 5;
    } else {
        setprop("systems/electrical/outputs/comm[0]", 0.0);
    }

    # Gear Select Power
    if ( getprop("/controls/circuit-breakers/gear-select") ) {
        setprop("/systems/electrical/outputs/gear-select", bus_volts);
        load += bus_volts / 5;
    } else {
        setprop("/systems/electrical/outputs/gear-select", 0.0);
    }

    # Gear Advisory Power
    if ( getprop("/controls/circuit-breakers/gear-advisory") ) {
        setprop("/systems/electrical/outputs/gear-advisory", bus_volts);
        if (getprop("/velocities/groundspeed-kt") > 10 and getprop("/velocities/groundspeed-kt") < 70) {
            load += bus_volts / 2;
        }
    } else {
        setprop("/systems/electrical/outputs/gear-advisory", 0.0);
    }

    # Hydraulic Pump Power
    if ( getprop("/controls/circuit-breakers/hydraulic-pump") ) {
        setprop("/systems/electrical/outputs/hydraulic-pump", bus_volts);
    } else {
        setprop("/systems/electrical/outputs/hydraulic-pump", 0.0);
    }
    current_gear_position = getprop("controls/gear/gear-down-command");
    if (current_gear_position != old_gear_position) {
        old_gear_position = current_gear_position;
        if (getprop("/systems/electrical/outputs/hydraulic-pump") > 12) {
            load += bus_volts / 40;
            settimer(func(){
                load += bus_volts;
            }, 4);
        }
    }

    # return cumulative load
    return load;
}

##
# Initialize the electrical system
#

var system_updater = ElectricalSystemUpdater.new();

# checking if battery should be automatically recharged
if (!getprop("/systems/electrical/save-battery-charge")) {
    battery.reset_to_full_charge("a");
    battery_stby.reset_to_full_charge("b");
};

system_updater.enable();

print("Electrical system initialized");


