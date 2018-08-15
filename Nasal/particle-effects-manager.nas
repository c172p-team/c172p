var particle_effects_loop = func {

    #particle effect colors
	var alt = getprop("/position/altitude-agl-ft");
    var land = getprop("/fdm/jsbsim/ground/solid");
    var red_diffuse = getprop("/rendering/scene/diffuse/red");
    var snowlevel = getprop("/environment/snow-level-m");

    if (land) {
        if (alt > snowlevel) {
            setprop("/sim/model/c172p/lighting/particles/redcombinedstart",   red_diffuse*.8);
            setprop("/sim/model/c172p/lighting/particles/greencombinedstart", red_diffuse*.8);
            setprop("/sim/model/c172p/lighting/particles/bluecombinedstart",  red_diffuse*.8);
            setprop("/sim/model/c172p/lighting/particles/redcombinedend",     red_diffuse*.9);
            setprop("/sim/model/c172p/lighting/particles/greencombinedend",   red_diffuse*.9);
            setprop("/sim/model/c172p/lighting/particles/bluecombinedend",    red_diffuse*.9);
        } else {
            setprop("/sim/model/c172p/lighting/particles/redcombinedstart",   red_diffuse*.89);
            setprop("/sim/model/c172p/lighting/particles/greencombinedstart", red_diffuse*.76);
            setprop("/sim/model/c172p/lighting/particles/bluecombinedstart",  red_diffuse*.57);
            setprop("/sim/model/c172p/lighting/particles/redcombinedend",     red_diffuse*.99);
            setprop("/sim/model/c172p/lighting/particles/greencombinedend",   red_diffuse*.86);
            setprop("/sim/model/c172p/lighting/particles/bluecombinedend",    red_diffuse*.67);
        }
    } else {
        setprop("/sim/model/c172p/lighting/particles/redcombinedstart",   red_diffuse*.90);
        setprop("/sim/model/c172p/lighting/particles/greencombinedstart", red_diffuse*.95);
        setprop("/sim/model/c172p/lighting/particles/bluecombinedstart",  red_diffuse*.93);
        setprop("/sim/model/c172p/lighting/particles/redcombinedend",     red_diffuse*.92);
        setprop("/sim/model/c172p/lighting/particles/greencombinedend",   red_diffuse*.98);
        setprop("/sim/model/c172p/lighting/particles/bluecombinedend",    red_diffuse*.95);
    }

    #smoke and damage smoke
    setprop("/sim/model/c172p/lighting/particles/redsmokestart",   red_diffuse*.10);
    setprop("/sim/model/c172p/lighting/particles/greensmokestart", red_diffuse*.10);
    setprop("/sim/model/c172p/lighting/particles/bluesmokestart",  red_diffuse*.10);
    setprop("/sim/model/c172p/lighting/particles/redsmokeend",     red_diffuse*.7);
    setprop("/sim/model/c172p/lighting/particles/greensmokeend",   red_diffuse*.7);
    setprop("/sim/model/c172p/lighting/particles/bluesmokeend",    red_diffuse*.85);
}

