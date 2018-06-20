# Copyright (C) 2015  wlbragg, onox
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

# ALS flashlight
var toggle_flashlight = func {
    if (getprop("/sim/rendering/shaders/skydome")) {
        var old_value = getprop("/sim/rendering/als-secondary-lights/use-flashlight");
        var new_value = math.mod(old_value + 1, 3);
        setprop("/sim/rendering/als-secondary-lights/use-flashlight", new_value);
    }
    else {
        gui.popupTip("Enable ALS for ALS Flashlight", 6);
    }
};

# Dome lights
var toggle_domelight = func {
    var old_value = getprop("/sim/model/c172p/lighting/dome-norm");
    var new_value = math.mod(old_value + 1, 6);
    setprop("/sim/model/c172p/lighting/dome-norm", new_value);
    if (new_value == 1) {
        setprop("/controls/switches/dome-red", 0);
        if (getprop("/controls/lighting/instruments-norm") == 0)
            setprop("/controls/lighting/instruments-norm", 1);
        setprop("/controls/switches/dome-white", 0);
        setprop("/controls/lighting/dome-white-norm", 0);
    }
    if (new_value == 2) {
        setprop("/controls/switches/dome-red", 1);
        if (getprop("/controls/lighting/instruments-norm") == 0)
            setprop("/controls/lighting/instruments-norm", 1);
        setprop("/controls/switches/dome-white", 0);
        setprop("/controls/lighting/dome-white-norm", 0);
    }
    if (new_value == 3) {
        setprop("/controls/switches/dome-red", 2);
        if (getprop("/controls/lighting/instruments-norm") == 0)
            setprop("/controls/lighting/instruments-norm", 1);
        setprop("/controls/switches/dome-white", 0);
        setprop("/controls/lighting/dome-white-norm", 0);
    }
    if (new_value == 4) {
        setprop("/controls/switches/dome-white", 1);
        setprop("/controls/lighting/dome-white-norm", 1);
        setprop("/controls/lighting/instruments-norm", 0);
    }
    if (new_value == 5) {
        setprop("/controls/switches/dome-white", 1);
        setprop("/controls/lighting/dome-white-norm", 1);
        setprop("/controls/switches/dome-red", 1);
        if (getprop("/controls/lighting/instruments-norm") == 0)
            setprop("/controls/lighting/instruments-norm", 1);
    }
    if (new_value == 0)  {
        setprop("/controls/switches/dome-white", 0);
        setprop("/controls/lighting/dome-white-norm", 0);
        setprop("/controls/lighting/instruments-norm", 0);
    }
};
