# On-screen displays
var enableOSD = func {
    var left  = screen.display.new(20, 10);
    var right = screen.display.new(-300, 10);

    left.add("/fdm/jsbsim/hydro/displacement-drag-lbs");
	left.add("/fdm/jsbsim/hydro/rudder-drag-lbs");
    left.add("/fdm/jsbsim/hydro/planing-drag-lbs");
    left.add("/fdm/jsbsim/hydro/fdrag-lbs");

    left.add("/fdm/jsbsim/aero/function/kCDge");
    left.add("/fdm/jsbsim/aero/function/vel-propwash-fps");
    left.add("/fdm/jsbsim/aero/function/qbar-propwash-psf");
    left.add("/fdm/jsbsim/aero/function/velocity-induced-fps");

    left.add("velocities/u-aero-fps");

    left.add("propulsion/engine/prop-induced-velocity_fps");
    left.add("propulsion/engine[1]/prop-induced-velocity_fps");

    left.add("/fdm/jsbsim/aero/function/qbar-induced-psf");
    left.add("/fdm/jsbsim/aero/coefficient/CDo");
    left.add("/fdm/jsbsim/aero/coefficient/CDDf");
    left.add("/fdm/jsbsim/aero/coefficient/CDwbh");
    left.add("/fdm/jsbsim/aero/coefficient/CDDe");
    left.add("/fdm/jsbsim/aero/coefficient/CDbeta");
    left.add("/fdm/jsbsim/hydro/vbx-fps");
    left.add("/velocities/uBody-fps");
    left.add("/fdm/jsbsim/hydro-Z");
    left.add("/fdm/jsbsim/mooring/rope-yaw");

	right.add("/controls/engines/engine[0]/throttle");
	right.add("/controls/engines/engine[1]/throttle");
	right.add("/controls/engines/current-engine/throttle");
	right.add("/controls/engines/throttle-all");
}
enableOSD();
