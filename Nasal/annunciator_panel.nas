#
# C182S Annunciator panel
#
# (c) 2018 Benedikt Hallinger, public domain
#
# Described in POH 4-8; the lights will flash for approximately 10 seconds before turning steady on.
# This is also true for the test mode toggled by the switch.


#################################################################
# Infrastructure code to model the components


# Define a basic panel
var annunciator_panel = {
    node:   "/instrumentation/annunciator/",
    volts:  "/systems/electrical/outputs/annunciators",
    svc:    "/instrumentation/annunciator/serviceable",
    test:   "/instrumentation/annunciator/testswitch",
    freq:   0.5,   # the blinking interval of annunciators (also used as loop interval)
    blink:  10,    # blink for this many seconds
    regobj: [],   # registered annunciators for main loop
    
    init: func() {
        me.loop = maketimer(annunciator_panel.freq, func(){
            # Annunciator panel loop: check annunciator states and trigger blinking/steady lights
            foreach(annunc_obj; me.regobj) { annunc_obj.update(); };
        });
        me.loop.simulatedTime = 1;
        me.loop.start();
        
        print("Annunciator panel: initialized");
    },
    
    add: func(annunc_obj) {
        append(me.regobj, annunc_obj);
        
        #print("DBG: Annunciator panel: added new annunciator at: "~annunc_obj.tgt);
        
    },

};


# Basic Abstract Annunciator class
# modelling the state of a single annunciator that can be activated.
# A display blinking value is added to a property appended with "-indicated".
# Expects a sublcass that implements isTriggered()!
var Annunciator = {
    # Returns a new Annunciator object writing to a tgt_prop
    new: func(tgt_prop) {
        return {
            parents:     [Annunciator],
            tgt:         tgt_prop,
            triggered_t: -1,
        };
    },
    
    # Updates the state; called by Panel class main loop
    update: func {
        var l_volts = getprop(annunciator_panel.volts);
        var l_svc   = getprop(annunciator_panel.svc);
        #print("  DBG: check annunciator: "~me.tgt~"    [l_volts="~l_volts~"; l_svc="~l_svc~"; testSw:"~getprop(annunciator_panel.test)~"; ");
        if (l_volts and l_svc and (me.isTriggered() or getprop(annunciator_panel.test) == 2)) {
            # Annunciator test said we are triggeed (or testswitch is engaged)!
            # initiate flashing or steady light
            var now   = getprop("/sim/time/elapsed-sec");
            
            if (me.triggered_t == -1) {
                # triggered the first time
                me.triggered_t = now;
                setprop(me.tgt, 1);
                setprop(me.tgt~"-indicated", 1);
            } else {
                # already triggered: see if we should blink or light steady
                var tgt_v = getprop(me.tgt~"-indicated");
                if ((me.triggered_t + annunciator_panel.blink) > now) {
                    # blink!
                    setprop(me.tgt~"-indicated", !tgt_v);
                    
                } else {
                    # light steady!
                    if (tgt_v != 1) {
                        setprop(me.tgt~"-indicated", 1);
                    }
                }
            }
            
        } else {
            # reset annunciator to off (cause solved or loss of power)
            me.triggered_t = -1;
            setprop(me.tgt, 0);
            setprop(me.tgt~"-indicated", 0);
        }
    },
};

# Annunciator class that triggers if a property value is lower than x
# Extends Annunciator base class
var AnnunciatorMin = {
    new: func(tgt_prop, src_prop, v_min) {
        var m = Annunciator.new(tgt_prop);  # call parent constructor
        append(m.parents, AnnunciatorMin);
        m.src = src_prop;
        m.min = v_min;

        return m;
    },
    
    # Expected from Annunciator base class: tests if this annunciator was triggered
    isTriggered: func() {
        if (getprop(me.src) < me.min ) {
            var r = 1;
        } else {
            var r = 0;
        }
        #print("  DBG: check annunciator: "~me.tgt~"    ["~me.src~"] < ["~me.min~"]? => "~r);
        return r;
    },
    
};

# Annunciator class that triggers if a property value is higher than x
# Extends Annunciator base class
var AnnunciatorMax = {
    new: func(tgt_prop, src_prop, v_max) {
        var m = Annunciator.new(tgt_prop);  # call parent constructor
        append(m.parents, AnnunciatorMax);
        m.src = src_prop;
        m.max = v_max;

        return m;
    },
    
    # Expected from Annunciator base class: tests if this annunciator was triggered
    isTriggered: func() {
        if (getprop(me.src) > me.max ) {
            var r = 1;
        } else {
            var r = 0;
        }
        #print("  DBG: check annunciator: "~me.tgt~"    ["~me.src~"] < ["~me.max~"]? => "~r);
        return r;
    },
    
};

# Annunciator class that triggers if one of the properties is true
# Extends Annunciator base class
var AnnunciatorOR = {
    new: func(tgt_prop, src_prop_list) {
        var m = Annunciator.new(tgt_prop);  # call parent constructor
        append(m.parents, AnnunciatorOR);
        m.src = src_prop_list;

        return m;
    },
    
    # Expected from Annunciator base class: tests if this annunciator was triggered
    isTriggered: func() {
        var r = 0;
        foreach(var p; me.src) {
            if (getprop(p) > 0) {
                r = 1;
                break;
            }
            #print("  DBG: check annunciator: "~me.tgt~"    ["~p~"] > 0? => "~r);
        }
        return r;
    },
    
};




####################################################################
# Ok, lets go and define the annunciators and add them to the panel!
#
annunciator_panel.add( AnnunciatorMin.new(annunciator_panel.node~"volts-low",    "/systems/electrical/volts", 24.5) );
annunciator_panel.add( AnnunciatorMin.new(annunciator_panel.node~"vac-low-l",    "/systems/vacuum[0]/suction-inhg", 3.0) );
annunciator_panel.add( AnnunciatorMin.new(annunciator_panel.node~"vac-low-r",    "/systems/vacuum[1]/suction-inhg", 3.0) );
annunciator_panel.add( AnnunciatorMin.new(annunciator_panel.node~"oilpress-low", "/engines/engine/indicated-oil-pressure-psi", 21.0) );
annunciator_panel.add( AnnunciatorMin.new(annunciator_panel.node~"fuel-low-r",   "/consumables/fuel/tank[1]/indicated-level-gal_us", 8) );
annunciator_panel.add( AnnunciatorMin.new(annunciator_panel.node~"fuel-low-l",   "/consumables/fuel/tank[0]/indicated-level-gal_us", 8) );
annunciator_panel.add( AnnunciatorOR.new(annunciator_panel.node~"fuel-low",      ["/instrumentation/annunciator/fuel-low-l", "/instrumentation/annunciator/fuel-low-r"] ) );
annunciator_panel.add( AnnunciatorMax.new(annunciator_panel.node~"pitch-trim",   "/instrumentation/annunciator/pitch-trim-trigger", 0) );

#TODO: for mor realism... the fuel detection should probably be modelled finer using a custom class: The POH says, that the annunciator nly fires if the low-condition is met for at least 60 seconds





####################################################
# INIT: Start the panel code once FDM is ready

setlistener("/sim/signals/fdm-initialized", func {
    annunciator_panel.init();


    # The PITCH-TRIM annunciator needs the previuos AP state.
    setprop("/autopilot/kap140/panel/state-previous", 0);
    setprop("/autopilot/kap140/panel/state-previous-memory", 0);
    setlistener("/autopilot/kap140/panel/state", func(n) {
        var mem = getprop("/autopilot/kap140/panel/state-previous-memory");
        if (getprop("autopilot/kap140/panel/button-ap") and n.getValue() == 5 and mem == 6) {
            setprop("/autopilot/kap140/panel/state-previous", n.getValue());
        } else {
            setprop("/autopilot/kap140/panel/state-previous", mem);
        }
        setprop("/autopilot/kap140/panel/state-previous-memory", n.getValue());
    }, 1, 0);
});
