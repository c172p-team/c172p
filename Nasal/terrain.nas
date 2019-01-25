var terrain_loop = func {
  var lat = getprop("/position/latitude-deg");
  var lon = getprop("/position/longitude-deg");

  var info = geodinfo(lat, lon);
  if (info != nil) {
    if (info[1] != nil){
      #load-resistance : a pressure value how much force per surface area this
      #surface can carry without deformation. The value should be in N/m^2
      #(default: 1e30).
      if (info[1].load_resistance !=nil)
        setprop("/fdm/jsbsim/ground/terrain-load-resistance",info[1].load_resistance);
      if (info[1].names !=nil)
        setprop("/fdm/jsbsim/ground/terrain-names",info[1].names[0]);
    }
  }

  #if (groundtype == whatever){
  #  setprop("/environment/terrain-load-resistance",1e+30);
  #}

}
var terrain_timer = maketimer(0.5, func{terrain_loop()});
terrain_timer.start();
