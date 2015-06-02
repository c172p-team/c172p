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

ki266.new(0);
aircraft.data.add("engines/engine[0]/egt-bug-norm");

var headingNeedleDeflection = "/instrumentation/nav/heading-needle-deflection";
var gsNeedleDeflection = "/instrumentation/nav/gs-needle-deflection-norm";
var staticPressure = "systems/static/pressure-inhg";

# Save the state of the avionics Radio control panel (according to its
# documentation)
aircraft.data.add(
    "instrumentation/kma20/test",
    "instrumentation/kma20/auto",
    "instrumentation/kma20/com1",
    "instrumentation/kma20/com2",
    "instrumentation/kma20/nav1",
    "instrumentation/kma20/nav2",
    "instrumentation/kma20/adf",
    "instrumentation/kma20/dme",
    "instrumentation/kma20/mkr",
    "instrumentation/kma20/sens",
    "instrumentation/kma20/knob"
);

# COMM1 (according to its documentation)
aircraft.data.add(
    "instrumentation/comm[0]/power-btn",
    "instrumentation/comm[0]/volume",
    "instrumentation/comm[0]/frequencies/selected-mhz",
    "instrumentation/comm[0]/frequencies/standby-mhz",
    "instrumentation/comm[0]/test-btn",
    "instrumentation/nav[0]/audio-btn",
    "instrumentation/nav[0]/power-btn",
    "instrumentation/nav[0]/frequencies/selected-mhz",
    "instrumentation/nav[0]/frequencies/standby-mhz",
);

# COMM2 (according to its documentation)
aircraft.data.add(
    "instrumentation/comm[1]/power-btn",
    "instrumentation/comm[1]/volume",
    "instrumentation/comm[1]/frequencies/selected-mhz",
    "instrumentation/comm[1]/frequencies/standby-mhz",
    "instrumentation/comm[1]/test-btn",
    "instrumentation/nav[1]/audio-btn",
    "instrumentation/nav[1]/power-btn",
    "instrumentation/nav[1]/frequencies/selected-mhz",
    "instrumentation/nav[1]/frequencies/standby-mhz",
);

# DME saves power-btn in ki266.nas
# ADF saves its properties in ki87.nas
# TRANSPONDER (KT76A)
aircraft.data.add(
    "instrumentation/transponder/inputs/knob-mode",
    "instrumentation/transponder/inputs/ident-btn",
    "instrumentation/transponder/inputs/digit[0]",
    "instrumentation/transponder/inputs/digit[1]",
    "instrumentation/transponder/inputs/digit[2]",
    "instrumentation/transponder/inputs/digit[3]",
    "instrumentation/transponder/inputs/dimming-norm",
);

# Hobbs meter is saved in Nasal/engine.nas
# Save switches
aircraft.data.add(
    "/controls/lighting/beacon",
    "/controls/lighting/instruments-norm",
    "/controls/lighting/landing-lights",
    "/controls/lighting/nav-lights",
    "/controls/lighting/panel-norm",
    "/controls/lighting/strobe",
    "/controls/lighting/taxi-light"
);

# Other controls
aircraft.data.add(
    "/controls/anti-ice/engine/carb-heat",
    "/controls/anti-ice/pitot-heat",
    "/consumables/fuel/tank/selected",
    "/consumables/fuel/tank[1]/selected"
);
