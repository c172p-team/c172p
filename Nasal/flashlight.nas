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

#ALS flashlight

var toggle_flashlight = func {
    if (check_required_version([3, 5])) {
	    if (getprop("/sim/rendering/shaders/skydome")) {
			if (!getprop("/sim/rendering/als-secondary-lights/use-flashlight"))
				setprop("/sim/rendering/als-secondary-lights/use-flashlight", 1);
			else
			if (getprop("/sim/rendering/als-secondary-lights/use-flashlight") == 1)
				setprop("/sim/rendering/als-secondary-lights/use-flashlight", 2);
			else
			if (getprop("/sim/rendering/als-secondary-lights/use-flashlight") == 2)
				setprop("/sim/rendering/als-secondary-lights/use-flashlight", 0);
	    }
	    else {
		    gui.popupTip("Enable ALS for ALS Flashlight", 5);
	    }
    }
    else {
	    gui.popupTip("ALS Flashlight require version 3.5 or greater", 5);
    }
};
