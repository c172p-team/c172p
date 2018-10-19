#############################################################################
# This file is part of FlightGear, the free flight simulator
# http://www.flightgear.org/
#
# Copyright (C) 2009 Torsten Dreyer, Torsten (at) t3r _dot_ de
# modified and used for C182S by Heiko H. Schulz 2018
# Implemented on C172P by J Redpath 2018
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#############################################################################

#########################################################################################
# this are the helper functions to model structural icing on airplanes
# Maintainer: Torsten Dreyer (Torsten at t3r dot de)
#
# Simple model: we listen to temperature and dewpoint. If the difference (spread) 
# is near zero and temperature is below zero, icing may occour.
# 
# inputs
# /environment/dewpoint-degc
# /environment/temperature-degc
# /environment/effective-visibility-m
# /velocities/airspeed-kt
# /environment/icing/max-spread-degc       default: 0.1
# /environment/rain-norm
# /environment/snow-norm
#
##Clouds detection see c182s.nas
#inputs
#/environment/icing/InCloudIcing
#
# outputs
# /environment/icing/icing-severity        numeric value of icing severity
# /environment/icing/icing-severity-name   textual representation of icing severity one of
#                                          none,trace,light,moderate,severe
# /environment/icing/icing-factor          ammound of ice accumulation per NAM



#########################################################################
# implementation of the global icemachine
#########################################################################

var ICING_NONE     = 0;
var ICING_TRACE    = 1;
var ICING_LIGHT    = 2;
var ICING_MODERATE = 3;
var ICING_SEVERE   = 4;

# these are the names for the icing severities
var ICING_CATEGORY = [ "none", "trace", "light", "moderate", "severe" ];

# the ice accumulating factors. Inches per nautical air mile flown
var ICING_FACTOR = [
  # none: sublimating 0.3" / 80NM
  -0.3/80,

  # traces: 0.5" / 80NM
  0.5/80.0,

  # light: 0.5" / 40NM
  0.5/40.0,

  # moderate: 0.5" / 20NM
  0.5/20.0,

  #severe: 0.5" / 10NM
  0.5/10
];

# since we don't know the LWC of our clouds, just define some severities
# depending on temperature and a random offset
# format: upper temperatur, lower temperatur, minimum severity, maximum severity
var ICING_TEMPERATURE = [
  [ 999,   0, ICING_NONE,     ICING_NONE ],
  [   0,  -2, ICING_NONE,     ICING_MODERATE ],
  [  -2, -12, ICING_LIGHT,    ICING_SEVERE ],
  [ -12, -20, ICING_LIGHT,    ICING_MODERATE ],
  [ -20, -30, ICING_TRACE,    ICING_LIGHT ],
  [ -30, -99, ICING_TRACE,    ICING_NONE ]
];

var dewpointN     = props.globals.getNode( "/environment/dewpoint-degc" );
var temperatureN  = props.globals.getNode( "/environment/temperature-degc" );
var speedN        = props.globals.getNode( "/velocities/airspeed-kt" );
var icingRootN    = props.globals.getNode( "/environment/icing", 1 );
var visibilityN   = props.globals.getNode( "/environment/effective-visibility-m" );
var rain =  props.globals.getNode( "/environment/rain-norm" );
var snow = props.globals.getNode( "/environment/snow-norm" );
#var visibility_factor = 0;
#var InCloudIcing = props.globals.getNode( "/environment/icing/InCloudIcing" );

#var ici = func{

#if (InCloudIcing ==1){
#visibility_factor.setValue(0.01)
#}else{
#visibility_factor.setValue(1)
#}
#}

var severityN     = icingRootN.initNode( "icing-severity", ICING_NONE, "INT" );
var severityNameN = icingRootN.initNode( "icing-severity-name", ICING_CATEGORY[severityN.getValue()] );
var icingFactorN  = icingRootN.initNode( "icing-factor", 0.0 );
var maxSpreadN    = icingRootN.initNode( "max-spread-degc", 0.1 );

var setSeverity = func {
  var value = arg[0];
  if( severityN.getValue() != value ) {
    severityN.setValue( value );
    severityNameN.setValue( ICING_CATEGORY[value] );
  }
}

#########################################################################################
# These are objects that are subject to icing
# inputs under /sim/model/icing/iceable (multiple instances allowed)
# ./name               # name of this object, more or less useless
# ./salvage-control    # name of a boolean property that salvages from ice
# ./output-property    # the name of the property where the ice amount is written to
# ./sensitivity        # a multiplier for the ice accumulation
#
# outputs
# ./ice-inches         # the amount of ice in inches OR
# [property named by output-property] # the amount of ice in inches
#########################################################################################
var IceSensitiveElement = {};

IceSensitiveElement.new = func {
  var obj = {};
  obj.parents = [IceSensitiveElement];
  obj.node = arg[0];

  obj.nameN = obj.node.initNode( "name", "noname" );
  var n = obj.node.getNode( "salvage-control", 0 );
  obj.controlN = nil;
  if( n != nil ) {
    n = n.getValue();
    if( n != nil ) {
      obj.controlN = props.globals.initNode( n, 0, "BOOL" );
    }
  }
  obj.sensitivityN = obj.node.initNode( "sensitivity", 1.0 );

  obj.iceAmountN = nil;
  n = obj.node.getNode( "output-property", 0 );
  if( n != nil ) {
    n = n.getValue();
    if( n != nil ) {
      obj.iceAmountN = props.globals.initNode( n, 0.0 );
    }
  }
  if( obj.iceAmountN == nil ) {
    obj.iceAmountN = obj.node.initNode( "ice-inches", 0.0 );
  }

  return obj;
};

#####################################################################
# this gets called from the icemachine on each update cycle
# arg[0] is the time in seconds since last update
# arg[1] is the number of NAM traveled since last update
# arg[2] is the ice-accumulation-factor for the current severity
#####################################################################
IceSensitiveElement.update = func {
  if( me.controlN != nil and me.controlN.getBoolValue() ) {
    if( me.iceAmountN.getValue() != 0.0 ) {
      me.iceAmountN.setDoubleValue( 0.0 );
    }
    return;
  }

  var deltat  = arg[0];
  var dist_nm = arg[1];
  var factor  = arg[2];

  var v = me.iceAmountN.getValue() + dist_nm * factor * me.sensitivityN.getValue();
  if( v < 0.0 ) {
    v = 0.0;
  }
  if( me.iceAmountN.getValue() != v ) {
    me.iceAmountN.setValue( v );
  }
};

#####################################################################
# read the ice sensitive elements from the config file
#####################################################################
var iceSensitiveElements = nil;

var icingConfigN = props.globals.getNode( "/sim/model/icing", 0 );
if( icingConfigN != nil ) {
  iceSensitiveElements = [];
  var iceableNodes = icingConfigN.getChildren( "iceable" );
  foreach( var iceable; iceableNodes ) {
    append( iceSensitiveElements, IceSensitiveElement.new( iceable ) );
  }
};

#########################################################################
# implementation of the clouds altitude detection (HHS)
#########################################################################

var Cloudaltitude = func {

var mdewpointN     = props.globals.getValue( "/environment/metar/dewpoint-degc" ) or 0;
var mtemperatureN  = getprop( "/environment/metar/temperature-degc");
var statE = props.globals.getValue( "/environment/metar/station-elevation-ft" ) or 0;
var cle0 = props.globals.getValue( "/environment/metar/clouds/layer[0]/elevation-ft" )or 0 ;
var cle1 = props.globals.getValue( "/environment/metar/clouds/layer[1]/elevation-ft" )or 0 ;
var cle2 = props.globals.getValue( "/environment/metar/clouds/layer[2]/elevation-ft" )or 0 ;
var cle3 = props.globals.getValue( "/environment/metar/clouds/layer[3]/elevation-ft" )or 0 ;
var cle4 = props.globals.getValue( "/environment/metar/clouds/layer[4]/elevation-ft" )or 0 ;


#cloffset = getprop("/local-weather/tmp/tile-alt-offset-ft") or 0;
#var cloffset = 0;

if (getprop("/local-weather/tmp/tile-alt-offset-ft") =="METAR") {
cloffset = getprop("/local-weather/tmp/tile-alt-offset-ft") or 0
}else{
cloffset = 0;
}

cloud0 = props.globals.getNode("/environment/icing/clouds/cloud0", 1);
cloud1 = props.globals.getNode("/environment/icing/clouds/cloud1", 1);
cloud2 = props.globals.getNode("/environment/icing/clouds/cloud2", 1);
cloud3 = props.globals.getNode("/environment/icing/clouds/cloud3", 1);
cloud4 = props.globals.getNode("/environment/icing/clouds/cloud4", 1);


setprop("/environment/icing/clouds/cloud0", (((mtemperatureN - mdewpointN)*30) + statE + cle0 ));
setprop("/environment/icing/clouds/cloud1", (((mtemperatureN - mdewpointN)*30) + statE + cle1 ));
setprop("/environment/icing/clouds/cloud2", (((mtemperatureN - mdewpointN)*30) + statE + cle2 ));
setprop("/environment/icing/clouds/cloud3", (((mtemperatureN - mdewpointN)*30) + statE + cle3 ));
setprop("/environment/icing/clouds/cloud4", (((mtemperatureN - mdewpointN)*30) + statE + cle4 ));

 
settimer(Cloudaltitude, 0.0);
}
Cloudaltitude();


###################
#
###################

var d = func {
cloud0 = getprop("/environment/icing/clouds/cloud0") or 0;
cloud1 =  getprop("/environment/icing/clouds/cloud1") or 0;
cloud2 =  getprop("/environment/icing/clouds/cloud2") or 0;
cloud3 =  getprop("/environment/icing/clouds/cloud3") or 0;
cloud4 =  getprop("/environment/icing/clouds/cloud4")or 0;

coverage0 = getprop("/environment/metar/clouds/layer/coverage") or 0;
coverage1 = getprop("/environment/metar/clouds/layer[1]/coverage") or 0;
coverage2 = getprop("/environment/metar/clouds/layer[2]/coverage") or 0;
coverage3 = getprop("/environment/metar/clouds/layer[3]/coverage") or 0;
coverage4 = getprop("/environment/metar/clouds/layer[4]/coverage") or 0;

var position = getprop("/position/altitude-ft") or 0;


if (((coverage0 == "overcast") and (position > cloud0) and (position < (cloud0 + 2500)) or ((coverage0 == "broken") and (position > cloud0) and (position < (cloud0 + 2000)))  or ((coverage0 == "scattered") and (position > cloud0) and (position < (cloud0 + 1500))))
or
((coverage1 == "overcast") and (position > cloud1) and (position < (cloud1 + 2500)) or ((coverage0 == "broken") and (position > cloud1) and (position < (cloud1 + 2000))) or ((coverage0 == "scattered") and (position > cloud0) and (position < (cloud0 + 1500))))
or
((coverage2 == "overcast") and (position > cloud2) and (position < (cloud2 + 2500)) or ((coverage2 == "broken") and (position > cloud2) and (position < (cloud2 + 2000))) or ((coverage0 == "scattered") and (position > cloud0) and (position < (cloud0 + 1500))))
or
((coverage3 == "overcast") and (position > cloud30) and (position < (cloud3 + 2500)) or ((coverage3 == "broken") and (position > cloud3) and (position < (cloud3 + 2000))) or ((coverage0 == "scattered") and (position > cloud0) and (position < (cloud0 + 1500))))
or
((coverage4 == "overcast") and (position > cloud4) and (position < (cloud4 + 2500)) or ((coverage4 == "broken") and (position > cloud4) and (position < (cloud4 + 2000))) or((coverage0 == "scattered") and (position > cloud0) and (position < (cloud0 + 1500)))) )

{
        setprop("/environment/icing/InCloudIcing/detected", 1);
    } else{
        setprop("/environment/icing/InCloudIcing/detected", 0);
}
    

    settimer(d, 0.0);
}

d();

#####################################################################
# the time triggered loop
#####################################################################
var elapsedTimeNode = props.globals.getNode( "/sim/time/elapsed-sec" );
var lastUpdate = 0.0;
var icing = func {

	var temperature = temperatureN.getValue();
	  
	# var rain = rainN.getValue();
	#var snow = snowN.getValue();
	var severity = ICING_NONE;
	icingFactorN.setDoubleValue( ICING_FACTOR[severity] );

	var visibility = 0;
	if( visibilityN != nil ) {
	  
		#var visibility_factor = 0;

		var InCloudIcing = getprop("/environment/icing/InCloudIcing/detected" ) or 0;
		if (InCloudIcing ==1){
			setprop("/environment/icing/InCloudIcing/visibilityfactor", 0.01);
		} else {
			setprop("/environment/icing/InCloudIcing/visibilityfactor", 1);
		}

		visibilityE = visibilityN.getValue();
		visibility = visibilityE * (getprop ("/environment/icing/InCloudIcing/visibilityfactor") or 0);
	}

	# check if we should create some ice
	var spread = temperature - dewpointN.getValue();
	if( spread < maxSpreadN.getValue() and visibility < 5000 ) {
		for( var i = 0; i < size(ICING_TEMPERATURE); i = i + 1 ) {
			if( ICING_TEMPERATURE[i][0] > temperature and 
			  ICING_TEMPERATURE[i][1] <= temperature ) {
				var s1 = ICING_TEMPERATURE[i][2];
				var s2 = ICING_TEMPERATURE[i][3];
				var ds = s2 - s1 + 1;
				severity = s1 + int(rand()*ds);
				icingFactorN.setDoubleValue(ICING_FACTOR[severity]);
				break;
			}
		}
	} else {
		# clear air
		# melt ice if above freezing temperature
		# the warmer, the faster. Lets guess that at 10degc
		# 0.5 inch goes in 10miles
		if(temperature > 0.0) {
		  icingFactorN.setDoubleValue(factor = -0.05 * temperature / 10.0);
		}
		# if temperature below zero, sublimating factor is initialized
	}

	setSeverity( severity );

	# update all sensitive areas
	var now = elapsedTimeNode.getValue();
	var dt = now - lastUpdate;
	foreach( var iceable; iceSensitiveElements ) {
		iceable.update(dt, dt * speedN.getValue()/3600.0, icingFactorN.getValue());
	}

	lastUpdate = now;
	settimer(icing, 0.1);
}

#####################################################################
# start our icemachine
# don't care if there is nothing to put ice on
#####################################################################
if( iceSensitiveElements != nil ) {
  lastUpdate = elapsedTimeNode.getValue();
  icing();
}
#####################################################################
