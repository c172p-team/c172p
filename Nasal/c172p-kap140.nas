# Copyright (C) 2015  Juan Vera
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

headingNeedleDeflection = "/instrumentation/nav/heading-needle-deflection";
gsNeedleDeflection = "/instrumentation/nav/gs-needle-deflection-norm";
staticPressure = "systems/static/pressure-inhg";

# electrical.nas switches on MASTER and ALT always!
# I prefer not changing electrical.nas because other versions of the c172p in FG may prefer that
var init_electrical_detailed = func {
    # Set initial positions for main switches
    setprop("/controls/engines/engine[0]/master-bat", 0);
    setprop("/controls/engines/engine[0]/master-alt", 0);
    setprop("/controls/switches/master-avionics", 0);
}

settimer(init_electrical_detailed, 1.0);
