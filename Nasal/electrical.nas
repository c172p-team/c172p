##
# Procedural model of a Cessna 172S electrical system.  Includes a
# preliminary battery charge/discharge model and realistic ammeter
# gauge modeling.
#
# Modelled after the POH and a maintenance manual.
# Sources/discussion: https://github.com/c172p-team/c172p/pull/1496
#

##
# Initialize internal values
#

var vbus_volts = 0.0;
var ebus1_volts = 0.0;
var ebus2_volts = 0.0;

var ammeter_ave = 0.0;

##
# Beacon and Strobe intermittent instantiation
#

aircraft.light.new("/sim/model/c172p/lighting/strobes", [0.1, 1.3]);
aircraft.light.new("/sim/model/c172p/lighting/beacon", [0.3, 1.3]);

var old_flap_position = 0;
var current_flap_position = getprop("/surface-positions/flap-pos-norm");
var old_gear_position = 0;
var current_gear_position = getprop("/controls/gear/gear-down-command");
var radio_lighting_load = 0;

# Init avionics breaker (POH 7-26); the breaker is integrated into the switch.
var brk_avionics_master = props.globals.getNode("/controls/circuit-breakers/avionics-master", 1);
brk_avionics_master.setBoolValue(getprop("/controls/switches/master-avionics"));
setlistener(brk_avionics_master, func (node) {
    # when breaker trips, set switch to OFF
    if (!node.getBoolValue())
        setprop("/controls/switches/master-avionics", 0);
}, 0, 0);
setlistener("/controls/switches/master-avionics", func (node) {
    # when switch is set to ON, reset the breaker
    if (node.getBoolValue())
        brk_avionics_master.setBoolValue(1);
}, 1, 0);



##
# Battery model class.
#

var BatteryClass = {};

BatteryClass.new = func {
    var obj = { parents : [BatteryClass],
                ideal_volts : 24.0,
                ideal_amps : 30.0,
                amp_hours : 13.36,
                charge_percent : getprop("/systems/electrical/battery-charge-percent") or 1.0,
                charge_amps : 7.0 };
    setprop("/systems/electrical/battery-charge-percent", obj.charge_percent);
    return obj;
}

##
# Passing in positive amps means the battery will be discharged.
# Negative amps indicates a battery charge.
#

BatteryClass.apply_load = func (amps, dt) {
    var old_charge_percent = getprop("/systems/electrical/battery-charge-percent") or 0;

    if (getprop("/sim/freeze/replay-state"))
        return me.amp_hours * old_charge_percent;

    var amphrs_used = amps * dt / 3600.0;
    var percent_used = amphrs_used / me.amp_hours;

    var new_charge_percent = std.max(0.0, std.min(old_charge_percent - percent_used, 1.0)) or 0;

    if (new_charge_percent < 0.1 and old_charge_percent >= 0.1)
        gui.popupTip("Warning: Low battery! Enable alternator or apply external power to recharge battery!", 10);
    me.charge_percent = new_charge_percent;
    setprop("/systems/electrical/battery-charge-percent", new_charge_percent);
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

BatteryClass.reset_to_full_charge = func {
    me.apply_load(-(1.0 - me.charge_percent) * me.amp_hours, 3600);
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

var battery = BatteryClass.new();
var alternator = AlternatorClass.new();

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
    var draw = 0.0;
    var battery_volts = 0.0;
    var alternator_volts = 0.0;
    if ( serviceable ) {
        battery_volts = battery.get_output_volts();
        alternator_volts = alternator.get_output_volts();
    }

    # switch state
    var master_bat = getprop("/controls/switches/master-bat");
    var master_alt = getprop("/controls/switches/master-alt");
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
    if ( external_volts > bus_volts) {
        # Ground-power-unit is connected to the plus-side of the battery. If
        # the reverse-polarity-contactor is closed (which it is if the GPU
        # has power and was plugged in correctly), the GPU powers the starter,
        # and also the electrical system.
        bus_volts = external_volts;
        power_source = "external";
    }
    #print( "virtual bus volts = ", bus_volts );

    # bus network (1. these must be called in the right order, 2. the
    # bus routine itself determins where it draws power from.)
    draw += electrical_bus_1();
    draw += avionics_bus_1();

	if (bus_volts) load = draw / bus_volts;

    # swtich the master breaker off if load is out of limits
    if ( load > 330 ) {
        setprop("/controls/circuit-breakers/master", 0)
    }


    # charge/discharge the battery
    # show battery charge/discharge on the ammeter
    var ammeter = 0.0;
    var bat_charge_pct = getprop("/systems/electrical/battery-charge-percent") or 0;
    if ( power_source == "battery" ) {
        battery.apply_load( load, dt );
        ammeter = -load;
    } elsif ( master_bat and bat_charge_pct >= 1.0) {
        # show small charge with fully loaded battery and only small load
        # (ie. show the conservatory charge rate)
        if (load < 20.0 and ammeter < 3.0) ammeter = 3.0;
    } elsif ( bus_volts > battery_volts and master_bat and bat_charge_pct < 1.0) {
        # Charge, but only if master_bat switch is ON.
        # If it's off, power is coming either from the alternator, or GPU.
        # If the battery contactor is open (which it is always with master_bat=OFF),
        # the battery is removed from the system.
        # The charge rate depends on the power source and the battery condition.
        # Normal charge rates are not more than two needle widths (~7 amps).
        battery.apply_load( -battery.charge_amps, dt );
        ammeter = battery.charge_amps;
    }

    # print( "ammeter = ", ammeter );

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
            load += 4.5 * bus_volts; # 3.5-4.5
        }
    }

    # Pitot Heat Power
    if (getprop("/controls/anti-ice/pitot-heat" ) and getprop("controls/anti-ice/pitot-heat")) {
        setprop("/systems/electrical/outputs/pitot-heat", bus_volts);
        load += 5 * bus_volts;
    } else {
        setprop("/systems/electrical/outputs/pitot-heat", 0.0);
    }

    # Instrument Power: ignition, fuel, oil temperature
    if ( getprop("/controls/circuit-breakers/instr") ) {
        setprop("/systems/electrical/outputs/instr-ignition-switch", bus_volts);
        if ( bus_volts > 12 ) {
            # starter
            var starter_svc    = getprop("/engines/active-engine/starter/serviceable");
            var starter_molten = getprop("/engines/active-engine/starter/overheated");
            if ( getprop("controls/switches/starter") and starter_svc and !starter_molten ) {
                setprop("systems/electrical/outputs/starter", bus_volts);
            } else {
                setprop("systems/electrical/outputs/starter", 0.0);
            }
        } else {
            setprop("systems/electrical/outputs/starter", 0.0);
        }
    } else {
        setprop("/systems/electrical/outputs/instr-ignition-switch", 0.0);
        setprop("/systems/electrical/outputs/starter", 0.0);
    }

    # Interior lights (cabin red and post)
    if (getprop("/controls/circuit-breakers/intlt")) {
        setprop("/systems/electrical/outputs/cabin-lights", bus_volts);
        var instruments_norm = getprop("/controls/lighting/instruments-norm");
		load += (5 * instruments_norm) * bus_volts; # 3.5-5 amp
    } else {
        setprop("/systems/electrical/outputs/cabin-lights", 0.0);
    }
    # Interior lights (dome white)
    if (getprop("/systems/electrical/outputs/cabin-lights")and getprop("/controls/switches/dome-white")) {
        var dome_white_norm = getprop("/controls/lighting/dome-white-norm");
		load += (5 * dome_white_norm) * bus_volts; # 3.5-5 amp
    }

    # Avionics (radio lighting)
    if (getprop("/controls/circuit-breakers/intlt")) {
        setprop("/systems/electrical/outputs/instrument-lights", bus_volts);
        var radio_norm = getprop("/controls/lighting/radio-norm");
		load += (radio_lighting_load * radio_norm) * bus_volts; # 3.5-5 amp
    } else {
        setprop("/systems/electrical/outputs/instrument-lights", 0.0);
    }

    # Landing Light Power
    if ( getprop("/controls/circuit-breakers/landing") and getprop("/controls/lighting/landing-lights") ) {
        setprop("/systems/electrical/outputs/landing-lights", bus_volts);
        load += 14.5 * bus_volts; # 14-18 amps
    } else {
        setprop("/systems/electrical/outputs/landing-lights", 0.0 );
    }

    # Taxi Lights Power
    # Notice taxi lights also use landing lights breaker. It is not a bug.
    if ( getprop("/controls/circuit-breakers/landing") and getprop("/controls/lighting/taxi-light" ) ) {
        setprop("/systems/electrical/outputs/taxi-light", bus_volts);
        load += 14.5 * bus_volts; # 14-18 amps
    } else {
        setprop("/systems/electrical/outputs/taxi-light", 0.0);
    }

    # Beacon Power
    if ( getprop("/controls/circuit-breakers/bcnlt") and getprop("/controls/lighting/beacon" ) ) {
        setprop("/systems/electrical/outputs/beacon", bus_volts);
        load += 4.5 * bus_volts; # 4.5-5 amps
    } else {
        setprop("/systems/electrical/outputs/beacon", 0.0);
    }

    # Nav Lights Power
    if ( getprop("/controls/circuit-breakers/navlt") and getprop("/controls/lighting/nav-lights" ) ) {
        setprop("/systems/electrical/outputs/nav-lights", bus_volts);
        load += 5 * bus_volts; # 4.5-5 amps
    } else {
        setprop("/systems/electrical/outputs/nav-lights", 0.0);
    }

    # Strobe Lights Power
    if ( getprop("/controls/circuit-breakers/strobe") and getprop("/controls/lighting/strobe" ) ) {
        setprop("/systems/electrical/outputs/strobe", bus_volts);
        setprop("/systems/electrical/outputs/strobe-norm", (bus_volts/24));
        load += 5 * bus_volts; # 4.5-5 amps
    } else {
        setprop("/systems/electrical/outputs/strobe", 0.0);
        setprop("/systems/electrical/outputs/strobe-norm", 0.0);
    }

    # Directional gyro Power
    # DG/HI is vacuum powered. This looks obsolete here and could probably be removed.
    #if (getprop("/controls/circuit-breakers/turn-coordinator") and getprop("/controls/switches/master-avionics")) {
    #    setprop("/systems/electrical/outputs/DG", bus_volts);
    #    load += 14 * bus_volts;
    #} else {
    #    setprop("/systems/electrical/outputs/DG", 0.0);
    #}

    # Turn Coordinator Power
    if (getprop("/controls/circuit-breakers/turn-coordinator") ) {
        setprop("/systems/electrical/outputs/turn-coordinator", bus_volts);
        load += 14 * bus_volts;
    } else {
        setprop("/systems/electrical/outputs/turn-coordinator", 0.0);
    }

    # Gear Select Power
    if ( getprop("/controls/circuit-breakers/gear-select") ) {
        setprop("/systems/electrical/outputs/gear-select", bus_volts);
        load += 5 * bus_volts;
    } else {
        setprop("/systems/electrical/outputs/gear-select", 0.0);
    }

    # Gear Advisory Power
    if ( getprop("/controls/circuit-breakers/gear-advisory") ) {
        setprop("/systems/electrical/outputs/gear-advisory", bus_volts);
        if (getprop("/velocities/groundspeed-kt") > 10 and getprop("/velocities/groundspeed-kt") < 70) {
            load += 2 * bus_volts;
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
            load += 40 * bus_volts;
        }
    }

    # Avionics Fan Power
    # Power comes trough the strobe breaker
    if ( bus_volts > 12 and getprop("/controls/circuit-breakers/strobe")) {
        setprop("/systems/electrical/outputs/avionics-fan[0]", bus_volts);
        load += bus_volts / 28;
    } else {
        setprop("/systems/electrical/outputs/avionics-fan[0]", 0);
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

    # Avionics Fan Power
    #setprop("/systems/electrical/outputs/avionics-fan", bus_volts);

    # Audio Panel 1 Power
    if ( getprop("/controls/circuit-breakers/radio1") ) {
      setprop("/systems/electrical/outputs/audio-panel[0]", bus_volts);
      setprop("/instrumentation/audio-panel[0]/operable", 1);
      load += 5 * bus_volts;
    } else {
      setprop("/systems/electrical/outputs/audio-panel[0]", 0.0);
      setprop("/instrumentation/audio-panel[0]/operable", 0);
    }

    # Com and Nav 1 Power
    if (getprop("/controls/circuit-breakers/radio2") and getprop("/instrumentation/nav[0]/power-btn")) {
      setprop("/systems/electrical/outputs/nav[0]", bus_volts);
      setprop("systems/electrical/outputs/comm[0]", bus_volts);
      load += 5 * bus_volts;
      radio_lighting_load = 1.0;
    } else {
      setprop("/systems/electrical/outputs/nav[0]", 0.0);
      setprop("systems/electrical/outputs/comm[0]", 0.0);
    }

    # Com and Nav 2 Power
    if (getprop("/controls/circuit-breakers/radio3") and getprop("/instrumentation/nav[1]/power-btn")) {
      setprop("/systems/electrical/outputs/nav[1]", bus_volts);
      setprop("systems/electrical/outputs/comm[1]", bus_volts);
      load += 5 * bus_volts;
      radio_lighting_load += 1.0;
    } else {
      setprop("/systems/electrical/outputs/nav[1]", 0.0);
      setprop("systems/electrical/outputs/comm[1]", 0.0);
    }

    # Transponder Power
    if (getprop("/controls/circuit-breakers/radio4") and getprop("/instrumentation/transponder/inputs/knob-mode")) {
      setprop("/systems/electrical/outputs/transponder", bus_volts);
     load += 5 * bus_volts;
      radio_lighting_load += 1.0;
    } else {
      setprop("/systems/electrical/outputs/transponder", 0.0);
    }

    # ADF Power
    # Note, ADF and DME are secured by the same breaker
    if (getprop("/controls/circuit-breakers/radio5") and getprop("/instrumentation/adf[0]/power-btn")) {
      setprop("/systems/electrical/outputs/adf", bus_volts);
      load += 5 * bus_volts;
      radio_lighting_load += 1.0;
    } else {
      setprop("/systems/electrical/outputs/adf", 0.0);
    }
    # DME ADF Power
    # Note, ADF and DME are secured by the same breaker
    if (getprop("/controls/circuit-breakers/radio5") and getprop("/instrumentation/dme[0]/power-btn")) {
      setprop("/systems/electrical/outputs/dme", bus_volts);
      load += 5 * bus_volts;
      radio_lighting_load += 1.0;
    } else {
      setprop("/systems/electrical/outputs/dme", 0.0);
    }

    # Autopilot Power
    if ( getprop("/controls/circuit-breakers/autopilot") and getprop("/autopilot/kap140/serviceable") ) {
      setprop("/systems/electrical/outputs/autopilot", bus_volts);
      load += 5 * bus_volts;
      radio_lighting_load += 1.0;
    } else {
      setprop("/systems/electrical/outputs/autopilot", 0.0);
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
    battery.reset_to_full_charge();
};

system_updater.enable();

print("Electrical system initialized");

