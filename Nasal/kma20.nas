##################################################################
#
# These are the helper functions for the kma20 audio panel
# Maintainer: Thorsten Brehm (brehmt at gmail dot com)
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

var kma20 = {};

kma20.new = func(rootPath) {
    var obj = {};
    obj.parents = [kma20];

    # Idea for the COM is to have volume-selected set to always match the volume knob of the COM radio volume knob. The volume (original property) is set to 0 when disabled by the KMA-20 or the volume-selected when enabled.

    # Monitor changes to COM1 switch
    setlistener(rootPath ~ "/com1", func(v) {setprop("/instrumentation/comm/volume",            (v.getValue() != 0) * getprop("/instrumentation/comm/volume-selected"));}, 1);
    # Monitor changes to volume selection knob of COM1
    setlistener("/instrumentation/comm/volume-selected", func(v) {setprop("/instrumentation/comm/volume", (getprop(rootPath ~ "/com1") != 0) * getprop("/instrumentation/comm/volume-selected"));}, 1);

    # Monitor changes to COM2 switch
    setlistener(rootPath ~ "/com2", func(v) {setprop("/instrumentation/comm[1]/volume",         (v.getValue() != 0) * getprop("/instrumentation/comm[1]/volume-selected"));}, 1);
    # Monitor changes to volume selection knob of COM2
    setlistener("/instrumentation/comm[1]/volume-selected", func(v) {setprop("/instrumentation/comm[1]/volume", (getprop(rootPath ~ "/com2") != 0) * getprop("/instrumentation/comm[1]/volume-selected"));}, 1);

    # Idea for the NAV is to set audio-btn (original-property) to true when both KMA-20 NAV switch is active & the NAV ident is pulled (ident-audible).
    # Monitor changes to NAV1 switch
    setlistener(rootPath ~ "/nav1",                   func(v) {setprop("/instrumentation/nav/audio-btn", (v.getValue() != 0) and getprop("/instrumentation/nav/ident-audible"));}, 1);
    # Monitor changes to NAV1 pull ident
    setlistener("/instrumentation/nav/ident-audible", func(v) {setprop("/instrumentation/nav/audio-btn", (getprop(rootPath ~ "/nav1") != 0) and v.getValue());}, 1);

    # Monitor changes to NAV2 switch
    setlistener(rootPath ~ "/nav2",                      func(v) {setprop("/instrumentation/nav[1]/audio-btn", (v.getValue() != 0) and getprop("/instrumentation/nav[1]/ident-audible"));}, 1);
    # Monitor changes to NAV2 pull ident
    setlistener("/instrumentation/nav[1]/ident-audible", func(v) {setprop("/instrumentation/nav[1]/audio-btn", (getprop(rootPath ~ "/nav2") != 0) and v.getValue());}, 1);

    setlistener(rootPath ~ "/adf",  func(v) {setprop("/instrumentation/adf/ident-audible",      (v.getValue() != 0));}, 1);
    setlistener(rootPath ~ "/dme",  func(v) {setprop("/instrumentation/dme/ident",              (v.getValue() != 0));}, 1);
    setlistener(rootPath ~ "/mkr",  func(v) {setprop("/instrumentation/marker-beacon/audio-btn",(v.getValue() != 0));}, 1);
    print( "KMA20 audio panel initialized" );
    return obj;
};

var kma20_0 = kma20.new( "/instrumentation/kma20" );
