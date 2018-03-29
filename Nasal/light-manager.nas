# provides relative vectors from eye-point to aircraft lights
# in east/north/up coordinates the renderer uses

var light_manager = {

    lat_to_m: 110952.0,
    lon_to_m: 0.0,

    light1_xpos: 0.0,
    light1_ypos: 0.0,
    light1_zpos: 0.0,
    light1_r: 0.0,
    light1_g: 0.0,
    light1_b: 0.0,
    light1_size: 0.0,
    light1_stretch: 0.0,

    light2_xpos: 0.0,
    light2_ypos: 0.0,
    light2_zpos: 0.0,
    light2_r: 0.0,
    light2_g: 0.0,
    light2_b: 0.0,
    light2_size: 0.0,
    light2_stretch: 0.0,

    light3_xpos: 0.0,
    light3_ypos: 0.0,
    light3_zpos: 0.0,
    light3_r: 0.0,
    light3_g: 0.0,
    light3_b: 0.0,
    light3_size: 0.0,

    light4_xpos: 0.0,
    light4_ypos: 0.0,
    light4_zpos: 0.0,
    light4_r: 0.0,
    light4_g: 0.0,
    light4_b: 0.0,
    light4_size: 0.0,

    init: func {
        # define your lights here

        # light 1 ########
        # offsets to aircraft center
        me.light1_xpos = 30.0;
        me.light1_ypos =  1.0;
        me.light1_zpos =  2.0;

        # color values
        me.light1_r = 0.5;
        me.light1_g = 0.5;
        me.light1_b = 0.5;

        # spot size
        me.light1_size = 15.0;
        me.light1_stretch = 1.25;

        # light 2 ########
        # offsets to aircraft center
        me.light2_xpos = 15.0;
        me.light2_ypos = -1.0;
        me.light2_zpos =  2.0;

        # color values
        me.light2_r = 0.4;
        me.light2_g = 0.4;
        me.light2_b = 0.4;

        # spot size
         me.light2_size = 16.0;
         me.light2_stretch = 1.5;

        # light 3 ########
        # offsets to aircraft center
        me.light3_ypos = -6.0;
        me.light3_zpos = 2.0;

        # color values
        me.light3_r = 0.0;
        me.light3_g = 0.05;
        me.light3_b = 0.0;

        # spot size
         me.light3_size = 5.0;

        # light 4 ########
        # offsets to aircraft center
        me.light4_ypos = 6.0;
        me.light4_zpos = 2.0;

        # color values
        me.light4_r = 0.05;
        me.light4_g = 0.0;
        me.light4_b = 0.0;

        # spot size
        me.light4_size = 5.0;
        
        me.light_manager_timer = maketimer(0.0, func{me.update()});
        
        me.start();
    },

    start: func {
        setprop("/sim/rendering/als-secondary-lights/num-lightspots", 4);

        setprop("/sim/rendering/als-secondary-lights/lightspot/size", me.light1_size);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size[1]", me.light2_size);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size[2]", me.light3_size);
        setprop("/sim/rendering/als-secondary-lights/lightspot/size[3]", me.light4_size);

        setprop("/sim/rendering/als-secondary-lights/lightspot/stretch", me.light1_stretch);
        setprop("/sim/rendering/als-secondary-lights/lightspot/stretch[1]", me.light2_stretch);

        me.light_manager_timer.start();
    },

    stop: func {
        me.light_manager_timer.stop();
    },

    update: func {

        var apos = geo.aircraft_position();
        var vpos = geo.viewer_position();

        me.lon_to_m = math.cos(apos.lat()*math.pi/180.0) * me.lat_to_m;

        var heading = getprop("/orientation/heading-deg") * math.pi/180.0;

        var lat = apos.lat();
        var lon = apos.lon();
        var alt = apos.alt();

        var sh = math.sin(heading);
        var ch = math.cos(heading);

        # light 1 position
        var alt_agl = getprop("/position/altitude-agl-ft");

        var proj_x = alt_agl;
        var proj_z = alt_agl/10.0;

        apos.set_lat(lat + ((me.light1_xpos + proj_x) * ch + me.light1_ypos * sh) / me.lat_to_m);
        apos.set_lon(lon + ((me.light1_xpos + proj_x)* sh - me.light1_ypos * ch) / me.lon_to_m);

        var delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
        var delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
        var delta_z = apos.alt()- proj_z - vpos.alt();

        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m", delta_x);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m", delta_y);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m", delta_z);
        setprop("/sim/rendering/als-secondary-lights/lightspot/dir", heading);

        # light 2 position
        var alt_agl = getprop("/position/altitude-agl-ft");

        var proj_x = alt_agl;
        var proj_z = alt_agl/10.0;

        apos.set_lat(lat + ((me.light2_xpos + proj_x) * ch + me.light2_ypos * sh) / me.lat_to_m);
        apos.set_lon(lon + ((me.light2_xpos + proj_x)* sh - me.light2_ypos * ch) / me.lon_to_m);

        var delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
        var delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
        var delta_z = apos.alt()- proj_z - vpos.alt();

        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m[1]", delta_x);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m[1]", delta_y);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m[1]", delta_z);
        setprop("/sim/rendering/als-secondary-lights/lightspot/dir", heading);

        # light 3 position
        apos.set_lat(lat + (me.light3_xpos * ch + me.light3_ypos * sh) / me.lat_to_m);
        apos.set_lon(lon + (me.light3_xpos * sh - me.light3_ypos * ch) / me.lon_to_m);

        delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
        delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
        delta_z = apos.alt() - vpos.alt();

        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m[2]", delta_x);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m[2]", delta_y);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m[2]", delta_z);

        # light 4 position
        apos.set_lat(lat + (me.light4_xpos * ch + me.light4_ypos * sh) / me.lat_to_m);
        apos.set_lon(lon + (me.light4_xpos * sh - me.light4_ypos * ch) / me.lon_to_m);

        delta_x = (apos.lat() - vpos.lat()) * me.lat_to_m;
        delta_y = -(apos.lon() - vpos.lon()) * me.lon_to_m;
        delta_z = apos.alt() - vpos.alt();

        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-x-m[3]", delta_x);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-y-m[3]", delta_y);
        setprop("/sim/rendering/als-secondary-lights/lightspot/eyerel-z-m[3]", delta_z);

    },   

    switch_position: func(light, lightr, lightg, lightb) {
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-r["~light~"]", lightr);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-g["~light~"]", lightg);
        setprop("/sim/rendering/als-secondary-lights/lightspot/lightspot-b["~light~"]", lightb);
    },

    enable_or_disable: func (enable, light_num) {
        if (enable) {
            if (light_num == 0)
                me.switch_position(light_num, me.light1_r, me.light1_g, me.light1_b);
            if (light_num == 1)
                me.switch_position(light_num, me.light2_r, me.light2_g, me.light2_b);
            if (light_num == 2)
                me.switch_position(light_num, me.light3_r, me.light3_g, me.light3_b);
            if (light_num == 3)
                me.switch_position(light_num, me.light4_r, me.light4_g, me.light4_b);
        } else {
            me.switch_position(light_num, 0.0, 0.0, 0.0);
        }
    },

};

setlistener("/sim/signals/fdm-initialized", func {

    light_manager.init();

    setlistener("/sim/rendering/als-secondary-lights/use-landing-light-ext", func (node) {
        light_manager.enable_or_disable(node.getValue(), 0);
    }, 1, 0);

    setlistener("/sim/rendering/als-secondary-lights/use-taxi-light-ext", func (node) {
        light_manager.enable_or_disable(node.getValue(), 1);
    }, 1, 0);

    setlistener("/sim/model/c172p/lighting/nav-lights/left-on", func (node) {
        light_manager.enable_or_disable(node.getValue(), 3);
    }, 1, 0);
     setlistener("/sim/model/c172p/lighting/nav-lights/right-on", func (node) {
        light_manager.enable_or_disable(node.getValue(), 2);
    }, 1, 0);
});