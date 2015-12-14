# Copyright (C) 2015  onox
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Position and offset of the start point of a tiedown. The position is on
# the surface of the fuselage or wing.
var point_coords = {
    left: {
        x:  0.1188,
        y: -2.2998,
        z:  0.4008,
        offset: 90.0
    },

    right: {
        x:  0.1188,
        y:  2.2998,
        z:  0.4008,
        offset: -90.0
    },

    tail: {
        x:  4.7116,
        y:  0.0000,
        z: -0.6663,
        offset: 180.0
    },
};

# Values must be the same as in Models/c172p.xml
var model_offsets_pitch_deg = -3.0;
var model_offsets_z_m = -0.065;

var TiedownPositionUpdater = {

    new: func (name) {
        var m = {
            parents: [TiedownPositionUpdater]
        };
        m.loop = updateloop.UpdateLoop.new(components: [m], update_period: 0.0, enable: 0);
        m.name = name;
        return m;
    },

    enable: func {
        me.loop.reset();
        me.loop.enable();
    },

    disable: func {
        me.loop.disable();
    },

    enable_or_disable: func (enable) {
        if (enable)
            me.enable();
        else
            me.disable();
    },

    reset: func {
        me.end_point = geo.aircraft_position();
        var heading = getprop("/orientation/heading-deg");

        var x = getprop("/sim/model/c172p/tiedowns", me.name, "x");
        var y = getprop("/sim/model/c172p/tiedowns", me.name, "y");

        # Set position of end point
        var course = heading + geo.normdeg(math_ext.atan(y, x));
        var distance = math.sqrt(math.pow(x, 2) + math.pow(y, 2));
        me.end_point.apply_course_distance(course, distance);

        # Set altitude of end point
        var elev_m = geo.elevation(me.end_point.lat(), me.end_point.lon());
        me.end_point.set_alt(elev_m or getprop("/position/ground-elev-m"));

        # Call update() immediately to compute initial length
        me.update(0);
        var length = getprop("/sim/model/c172p/tiedowns", me.name, "length");
        setprop("/sim/model/c172p/tiedowns", me.name, "ref-length", length);
    },

    update: func (dt) {
        var point = point_coords[me.name];

        var start_x = point.x;
        var start_y = point.y;
        var start_z = point.z + model_offsets_z_m;

        var roll_deg  = getprop("/orientation/roll-deg");
        var pitch_deg = getprop("/orientation/pitch-deg") + model_offsets_pitch_deg;
        var heading   = getprop("/orientation/heading-deg");

        # Compute the actual position of the start of the tiedown
        var (start_point_2d, start_point) = math_ext.get_point(start_x, start_y, start_z, roll_deg, pitch_deg, heading);

        var (yaw, pitch, distance) = math_ext.get_yaw_pitch_distance_inert(start_point_2d, start_point, me.end_point, heading);
        (yaw, pitch) = math_ext.get_yaw_pitch_body(roll_deg, pitch_deg, yaw, pitch, point.offset);

        setprop("/sim/model/c172p/tiedowns", me.name, "heading-deg", yaw);
        setprop("/sim/model/c172p/tiedowns", me.name, "pitch-deg", pitch);
        setprop("/sim/model/c172p/tiedowns", me.name, "length", distance);
    },

};

var tiedown_left_updater  = TiedownPositionUpdater.new("left");
var tiedown_right_updater = TiedownPositionUpdater.new("right");
var tiedown_tail_updater  = TiedownPositionUpdater.new("tail");

setlistener("/sim/signals/fdm-initialized", func {
    setlistener("/sim/model/c172p/securing/tiedownL-visible", func (node) {
        tiedown_left_updater.enable_or_disable(node.getValue());
    }, 1, 0);

    setlistener("/sim/model/c172p/securing/tiedownR-visible", func (node) {
        tiedown_right_updater.enable_or_disable(node.getValue());
    }, 1, 0);

    setlistener("/sim/model/c172p/securing/tiedownT-visible", func (node) {
        tiedown_tail_updater.enable_or_disable(node.getValue());
    }, 1, 0);
});
