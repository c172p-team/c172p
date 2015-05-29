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

#ALS shadow
props.Node.new({ "/sim/rendering/shadow":0 });
props.globals.initNode("/sim/rendering/shadow", 0, "INT");

#ALS Volume shadow
props.Node.new({ "/sim/rendering/shadow-volume":0 });
props.globals.initNode("/sim/rendering/shadow-volume", 0, "INT");

var check_required_version = func (required_version) {
    var version = split(".", getprop("/sim/version/flightgear"));
    forindex (var i; required_version) {
        if (version[i] > required_version[i]) {
            return 1;
        }
        elsif (version[i] < required_version[i]) {
            return 0;
        }
    }
    return 1;
};

var check_eligibility = func {
	if (check_required_version([3, 5])) {
	    if (getprop("/sim/rendering/shaders/skydome")) {
		    return 1;
	    }
	    else {
		    gui.popupTip("Enable ALS for Shadow Volume", 5);
			return 0;
	    }
    }
    else {
	    gui.popupTip("ALS Shadow Volumes require version 3.5 or greater", 5);
		return 0;
    }
	
}

var toggle_shadow_volume = func {
    if (check_required_version([3, 5])) {
	    if (getprop("/sim/rendering/shaders/skydome")) {
			if (getprop("/sim/rendering/shadow"))
				setprop("/sim/rendering/shadow", !getprop("/sim/rendering/shadow"));
		    setprop("/sim/rendering/shadow-volume", !getprop("/sim/rendering/shadow-volume"));
	    }
	    else {
		    gui.popupTip("Enable ALS for Shadow Volume", 5);
	    }
    }
    else {
	    gui.popupTip("ALS Shadow Volumes require version 3.5 or greater", 5);
    }
};

var toggle_shadow = func {
    if (check_required_version([3, 2])) {
	    if (getprop("/sim/rendering/shaders/skydome")) {
			if (getprop("/sim/rendering/shadow-volume"))
				setprop("/sim/rendering/shadow-volume", !getprop("/sim/rendering/shadow-volume"));
		    setprop("/sim/rendering/shadow", !getprop("/sim/rendering/shadow"));
	    }
	    else {
		    gui.popupTip("Enable ALS for ALS Shadow", 5);
	    }
    }
    else {
	    gui.popupTip("ALS Shadow require version 3.2 or greater", 5);
    }
};
