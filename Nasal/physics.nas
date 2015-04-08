var gears = "fdm/jsbsim/gear/";


var physics = func{
if(getprop(gears~"unit[0]/compression-ft") > 0.79){
  #if(getprop(gears~"unit[0]/compression-ft") > 0.29){
    setprop(gears~"unit[0]/z-position", -4.75);
    setprop(gears~"unit[0]/broken", 1);
  }
if(getprop(gears~"unit[1]/compression-ft") > 0.59){
  #if(getprop(gears~"unit[1]/compression-ft") > 0.29){
    setprop(gears~"unit[1]/z-position", -4.2);
    setprop(gears~"unit[1]/broken", 1);
  }
if(getprop(gears~"unit[2]/compression-ft") > 0.59){
  #if(getprop(gears~"unit[2]/compression-ft") > 0.29){
    setprop(gears~"unit[2]/z-position", -4.2);
    setprop(gears~"unit[2]/broken", 1);
  }

}
