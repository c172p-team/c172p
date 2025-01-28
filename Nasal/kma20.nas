##################################################################
#
# These are the helper functions for the kma20 audio panel
# Maintainer: Thorsten Brehm (brehmt at gmail dot com)
# Enhanced:   1/2025 B. Hallinger
#
# Usage:
# just create one instance of kma20 class for each kma20 panel
# you have in your aircraft:
# kma20.new(0);
#
# KMA20 audio panel properties:
# root: /instrumentation/kma20
#    knob: microphone/radio selector (com1/2)
#    auto: selects COM1/2 based on microphone selector
#    com1: enable/disable COM1 audio (e.g. for ATIS)
#    com2: enable/disable COM2 audio (e.g. for ATIS)
#    nav1: enable/disable NAV1 station identifier
#    nav2: enable/disable NAV2 station identifier
#    adf:  enable/disable ADF station identifier
#    dme:  enable/disable DME station identifier
#    mkr:  enable/disable marker beacon audio
#    sens: beacon receiver sensitivity
#
# KMA20 operational properties:
#    serviceable: (writable) false, when the audio panel failed 
#    operable:    (readonly) true, when power is supplied and serviceable is true

var kma20 = {
    instances: []
};

kma20.new = func(rootPath) {
    var obj = {};
    obj.parents   = [kma20];
    obj.rootPath  = rootPath;

    # Hash containing all listeners / timers / aliases, for the destructor.
    obj.listeners = {};
    obj.timers    = {};
    obj.aliases   = {};

    append(kma20.instances, obj);
    obj.fgcom.instance = obj;
    obj.init();
    return obj;
};

# Destructor
kma20.del = func() {
    foreach (var l; keys(me.listeners)) removelistener(me.listeners[l]);
    foreach (var t; keys(me.timers)) me.timers[t].stop();
    foreach (var a; keys(me.aliases)) me.aliases[a].unalias();
    me.listeners = {};
    me.timers = {};
    me.aliases = {};
    # todo: remove instance
};

kma20.init = func() {
    me.unit   = props.globals.getNode(me.rootPath);
    me.radios = [props.globals.getNode("/instrumentation/comm[0]"), props.globals.getNode("/instrumentation/comm[1]")];

    # Monitor changes to COM related switches and knobs
    me.listeners.opr  = setlistener(me.unit.getChild("operable"), func {me.updateCOMvolumes(); me.updateOtherVolumes();}, 0);
    me.listeners.knob = setlistener(me.unit.getChild("knob"), func {me.updateCOMvolumes();}, 0);
    me.listeners.auto = setlistener(me.unit.getChild("auto"), func {me.updateCOMvolumes();}, 0);
    me.listeners.com1 = setlistener(me.unit.getChild("com1"), func {me.updateCOMvolumes();}, 0);
    me.listeners.com2 = setlistener(me.unit.getChild("com2"), func {me.updateCOMvolumes();}, 0);
    me.listeners.com1vol = setlistener(me.radios[0].getChild("volume-selected"), func {me.updateCOMvolumes();}, 0);
    me.listeners.com2vol = setlistener(me.radios[1].getChild("volume-selected"), func {me.updateCOMvolumes();}, 0);
    me.updateCOMvolumes();

    # FGCom integration: Monitor COMs PTT in order to mute them when sending
    me.listeners.com1ptt = setlistener(me.radios[0].getChild("ptt"), func {me.updateCOMvolumes();}, 0);  # for fgcom integration
    me.listeners.com2ptt = setlistener(me.radios[1].getChild("ptt"), func {me.updateCOMvolumes();}, 0);  # for fgcom integration

    # Monitor changes to NAV, adf, dme and mkr switches
    me.listeners.nav1 = setlistener(me.unit.getChild("nav1"), func {me.updateOtherVolumes();}, 0);
    me.listeners.nav2 = setlistener(me.unit.getChild("nav2"), func {me.updateOtherVolumes();}, 0);
    me.listeners.adf  = setlistener(me.unit.getChild("adf"),  func {me.updateOtherVolumes();}, 0);
    me.listeners.dme  = setlistener(me.unit.getChild("dme"),  func {me.updateOtherVolumes();}, 0);
    me.listeners.mkr  = setlistener(me.unit.getChild("mkr"),  func {me.updateOtherVolumes();}, 0);
    me.updateOtherVolumes();


    # Initialize timer to recalculate operable state of the panel.
    # (We do this timed, because it seems to be enough; and the electrical output property changes way too often)
    me.updateOperable();
    me.timers.operable_loop = maketimer(1.0, me, me.updateOperable);
    me.timers.operable_loop.start();


    print( "KMA20 audio panel initialized" );
};

# Recalculate operable property
kma20.updateOperable = func() {
    var svc   = me.unit.getNode("serviceable",1).getBoolValue();
    var power = getprop("/systems/electrical/outputs/audio-panel");
    var op_p  = me.unit.getNode("operable",1);
    if (svc and power != nil and power > 12.5) {
        op_p.setBoolValue(1);
    } else {
        op_p.setBoolValue(0);
    }
};

kma20.updateCOMvolumes = func() {
    # Idea for the COM is to have volume-selected set to always match the volume knob of the COM radio volume knob.
    # The volume (original property) is set to 0 when disabled by the KMA-20 or the volume-selected when enabled.

    # get KMA20 unit
    var knob_position = me.unit.getValue("knob");   # -1=COM1; 0=COM2; 1=EXT
    var auto_switch   = me.unit.getValue("auto");   # -1=SPKR; 0=OFF; 1=HEADSET
    var com1_switch   = me.unit.getValue("com1");   # -1=SPKR; 0=OFF; 1=HEADSET
    var com2_switch   = me.unit.getValue("com2");   # -1=SPKR; 0=OFF; 1=HEADSET

    # get panel operational state (turned on? power? serviceable?)
    var operable = me.unit.getValue("operable");

    # calculate com tgt volume
    # Auto mode: In case the COM switch is OFF but AUTO mode is on, make the COM audible if the knob has it selected
    # Failsafe mode: When the panel fails, COM1 is wired as fallback.
    tgt = {
        com1: 0,
        com2: 0
    };
    var com1_automode = (com1_switch == 0 and auto_switch != 0 and knob_position == -1);
    var com1_selected = (com1_switch != 0);
    if (operable) {
        if (com1_automode or com1_selected) {
            tgt.com1 = me.radios[0].getValue("volume-selected");
        } else {
            tgt.com1 = 0.0;
        }
    } else {
        # Failsafe mode
        tgt.com1 = me.radios[0].getValue("volume-selected");
    }

    var com2_automode = (com2_switch == 0 and auto_switch != 0 and knob_position == 0);
    var com2_selected = (com2_switch != 0);
    if ( operable and (com2_automode or com2_selected) ) {
        tgt.com2 = me.radios[1].getValue("volume-selected");
    } else {
        tgt.com2 = 0.0;
    }

    # FGCom integration: When sending, mute the radio
    if (me.radios[0].getValue("ptt")) tgt.com1 = 0.0;
    if (me.radios[1].getValue("ptt")) tgt.com2 = 0.0;


    # finally persist
    me.radios[0].setValue("volume", tgt.com1);
    me.radios[1].setValue("volume", tgt.com2);
};

kma20.updateOtherVolumes = func() {
    tgt = {
        nav1: 0,
        nav2: 0,
        adf:  0,
        dme:  0,
        mkr:  0
    };

    # get panel operational state (turned on? power? serviceable?)
    var operable = me.unit.getValue("operable");

    if (operable) {
        # Idea for the NAV is to set audio-btn (original-property) to true when both KMA-20 NAV switch is active & the NAV ident is pulled (ident-audible).
        tgt.nav1 = (me.unit.getValue("nav1") != 0 and getprop("/instrumentation/nav[0]/ident-audible") and getprop("/instrumentation/nav[0]/operable"));
        tgt.nav2 = (me.unit.getValue("nav2") != 0 and getprop("/instrumentation/nav[1]/ident-audible") and getprop("/instrumentation/nav[1]/operable"));

        tgt.adf = (me.unit.getValue("adf") != 0 and getprop("/instrumentation/adf[0]/operable"));
        tgt.dme = (me.unit.getValue("dme") != 0 and getprop("/instrumentation/dme[0]/operable"));

        tgt.mkr = (me.unit.getValue("mkr") != 0 and getprop("/instrumentation/marker-beacon/operable"));
    } else {
        # Failsafe mode
        # ? No failsafe mode, as far as I have seen?
    }

    # set target values effective
    setprop("/instrumentation/nav[0]/audio-btn",        tgt.nav1);
    setprop("/instrumentation/nav[1]/audio-btn",        tgt.nav2);
    setprop("/instrumentation/adf/ident-audible",       tgt.adf);
    setprop("/instrumentation/dme/ident",               tgt.dme);
    setprop("/instrumentation/marker-beacon/audio-btn", tgt.mkr);
};


###########
# FGCom integration
#
kma20.fgcom = {
    instance: {}, # registered by kma20.new() to make it visible in subnamespace here

    # PTT function, gets called when pressing/releasing space
    #   active: 1 if ptt is pressed
    #   mode:   0 normal, 1 shift-space
    ptt: func(active, mode) {
        var modifiers = props.globals.getNode("/devices/status/keyboard");
        var fgcom_integration = getprop("/instrumentation/audio-panel/fgcom-integration");
        if (fgcom_integration == nil) fgcom_integration = 0;
        #print("KMA20: [PTT] integrated=", fgcom_integration, "; active=", active, "; mode=", mode, "; modifiers=",  modifiers.getValue());

        if (fgcom_integration) {
            # FGCom integration activated: detect which radio is activated at the panel and if it is operable
            var selectedRadio = me.instance.fgcom.get_selected_radio();
            if (selectedRadio >= 0) {
                if (active) {
                    print("KMA20: [PTT] activated; panel selected radio COM", selectedRadio + 1);
                    var selectedRadio_isOK = me.instance.fgcom.check_radio(selectedRadio);
                    if (selectedRadio_isOK) {
                        print("KMA20: [PTT] now transmitting on selected radio COM", selectedRadio + 1);
                        me.instance.radios[selectedRadio].getNode("ptt").setValue(1);
                    } else {
                        # Radio was not operable
                        print("KMA20: [PTT] selected radio COM", selectedRadio + 1, " is not operable. Not sending transmission!");
                    }

                } else {
                    print("KMA20: [PTT] released, selected radio=COM", selectedRadio + 1);
                    me.instance.radios[selectedRadio].getNode("ptt").setValue(0);
                }
            }

        } else {
            # FGCom not integrated: tunnel trough to standard behavior;
            # ie: space=COM1, shift+space=COM2 and no operable checks.
            # we use the listeners the default implementation listens to.

            # space pressed
            if (active and mode == 0) {
                me.instance.radios[0].getNode("ptt").setValue(1);
            # space released
            } else if (!active and mode == 0) {
                me.instance.radios[0].getNode("ptt").setValue(0);

            # shift-space pressed
            } else if (active and mode == 1) {
                me.instance.radios[1].getNode("ptt").setValue(1);

            # shift-space released
            } else if (!active and mode == 1) {
                me.instance.radios[1].getNode("ptt").setValue(0);

            # fallback
            } else {
                me.instance.radios[0].getNode("ptt").setValue(0);
                me.instance.radios[0].getNode("ptt").setValue(0);
            }
        }

    },

    # Returns the audio panels selected radio (as index in me.instance.radios)
    # Returns -1 if invalid selection (in this case no PTT is activated when running in "integrated mode")
    get_selected_radio: func() {
        var unit_operable = me.instance.unit.getChild("operable").getBoolValue();
        if (unit_operable) {
            var knob_position = me.instance.unit.getValue("knob");   # -1=COM1; 0=COM2; 1=EXT
            if (knob_position == -1) return  0;  # COM1
            if (knob_position ==  0) return  1;  # COM2
            if (knob_position ==  1) return -1;  # EXT: with FGCom-mumble, this could potentially link the intercom
        } else {
            # Failsafe: COM1 wired
            return 0;
        }
    },

    # Returns if the selected radio (as index in me.instance.radios) is able to transmit
    check_radio: func(selectedRadio) {
        var unit_operable = me.instance.unit.getChild("operable").getBoolValue();
        if (unit_operable) {
            return me.instance.radios[selectedRadio].getChild("operable").getBoolValue();
        } else {
            # Failsafe: get_selected_radio() returns COM1 in case of panel failure
            return me.instance.radios[0].getChild("operable").getBoolValue();
        }
        return 0;
    }
};


# Initialize at startup (delayed, so propertys are properly initialized)
setlistener("/sim/signals/fdm-initialized", func {
    var kma20_0 = kma20.new( "/instrumentation/kma20" );
});
