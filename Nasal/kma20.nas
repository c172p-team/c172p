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

  setlistener(rootPath ~ "/com1", func(v) {setprop("/instrumentation/comm/volume",        0.7*(v.getValue() != 0));}, 1);
  setlistener(rootPath ~ "/com2", func(v) {setprop("/instrumentation/comm[1]/volume",     0.7*(v.getValue() != 0));}, 1);
  setlistener(rootPath ~ "/nav1", func(v) {setprop("/instrumentation/nav/audio-btn",          (v.getValue() != 0));}, 1);
  setlistener(rootPath ~ "/nav2", func(v) {setprop("/instrumentation/nav[1]/audio-btn",       (v.getValue() != 0));}, 1);
  setlistener(rootPath ~ "/adf",  func(v) {setprop("/instrumentation/adf/ident-audible",      (v.getValue() != 0));}, 1);
  setlistener(rootPath ~ "/dme",  func(v) {setprop("/instrumentation/dme/ident",              (v.getValue() != 0));}, 1);
  setlistener(rootPath ~ "/mkr",  func(v) {setprop("/instrumentation/marker-beacon/audio-btn",(v.getValue() != 0));}, 1);
  print( "KMA20 audio panel initialized" );
  return obj;
};

var kma20_0 = kma20.new( "/instrumentation/kma20" );
