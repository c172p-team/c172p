###############################################################################
##
## JSBSim hydrodynamics system. FlightGear side.
##
##  Copyright (C) 2015  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license v2 or later.
##
###############################################################################

var ground = func {
    # Send the current ground level to the JSBSim hydrodynamics model.
    setprop("/fdm/jsbsim/hydro/environment/water-level-ft",
            getprop("/position/ground-elev-ft") +
            getprop("/fdm/jsbsim/hydro/environment/wave-amplitude-ft"));

    # Connect the JSBSim hydrodynamics wave model with the custom water shader.
    setprop("environment/waves/time-sec",
            getprop("/fdm/jsbsim/simulation/sim-time-sec"));
    setprop("environment/waves/from-deg",
            getprop("/fdm/jsbsim/hydro/environment/waves-from-deg"));
    setprop("environment/waves/length-ft",
            getprop("/fdm/jsbsim/hydro/environment/wave-length-ft"));
    setprop("environment/waves/amplitude-ft",
            getprop("/fdm/jsbsim/hydro/environment/wave-amplitude-ft"));
    setprop("environment/waves/angular-frequency-rad_sec",
            getprop("/fdm/jsbsim/hydro/environment/wave/angular-frequency-rad_sec"));
    setprop("environment/waves/wave-number-rad_ft",
            getprop("/fdm/jsbsim/hydro/environment/wave/wave-number-rad_ft"));


    settimer(ground, 0.0);
}

settimer(ground, 0.0);
