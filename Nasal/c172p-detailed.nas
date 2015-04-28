##########################################
# Ground Detection
##########################################

# Do terrain modelling ourselves.
#setprop("sim/fdm/surface/override-level", 1);

var terrain_survol_loop = func {
  var lat = getprop("/position/latitude-deg");
  var lon = getprop("/position/longitude-deg");

  var info = geodinfo(lat, lon);
  if (info != nil) {
    if (info[1] != nil){
      if (info[1].solid !=nil)
        setprop("/environment/terrain-type",info[1].solid);
      if (info[1].load_resistance !=nil)
        setprop("/environment/terrain-load-resistance",info[1].load_resistance);
      if (info[1].friction_factor !=nil)
        setprop("/environment/terrain-friction-factor",info[1].friction_factor);
      if (info[1].bumpiness !=nil)
        setprop("/environment/terrain-bumpiness",info[1].bumpiness);
      if (info[1].rolling_friction !=nil)
        setprop("/environment/terrain-rolling-friction",info[1].rolling_friction);
      if (info[1].names !=nil)
        setprop("/environment/terrain-names",info[1].names[0]);
    }         
  }else{
    setprop("/environment/terrain",1);
    setprop("/environment/terrain-load-resistance",1e+30);
    setprop("/environment/terrain-friction-factor",1.05);
    setprop("/environment/terrain-bumpiness",0);
    setprop("/environment/terrain-rolling-friction",0.02);
  }

  if(!getprop("sim/freeze/replay-state") and !getprop("/environment/terrain-type") and getprop("/position/altitude-agl-ft") < 3.0){
    setprop("sim/messages/copilot", "You are on water !");
    setprop("sim/freeze/clock", 1);
    setprop("sim/freeze/master", 1);
    setprop("sim/crashed", 1);
  }

}

############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
global_system_loop = func{

  terrain_survol_loop();
  c172p.physics_loop();
  c172p.weather_effects_loop();

}

##########################################
# SetListerner must be at the end of this file
##########################################
setlistener("/sim/signals/fdm-initialized", func{
  setprop("/environment/terrain-type",1);
  setprop("/environment/terrain-load-resistance",1e+30);
  setprop("/environment/terrain-friction-factor",1.05);
  setprop("/environment/terrain-bumpiness",0);
  setprop("/environment/terrain-rolling-friction",0.02);
});

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{ 
  var c172_timer = maketimer(0.25, func{global_system_loop()});
  c172_timer.start();
  removelistener(nasalInit);
});