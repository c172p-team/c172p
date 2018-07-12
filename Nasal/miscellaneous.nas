# Copyright (C) 2018  onox
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

# It would be much easier for everyone if the fgms servers just enforced
# everyone to use the same protocol. Then FG would simply show only
# servers that require the 2017.2 protocol.
setlistener("/sim/multiplay/online", func (n) {
    if (n.getBoolValue() and getprop("/sim/multiplay/protocol-version") != 2) {
        canvas.MessageBox.warning(
            "2017.2 multiplayer protocol required",
            "Using this model over multiplayer requires using the 2017.2 protocol. Do you want to switch the compatibility to 'Visible to only 2017+'?",
            func (sel) {
                if (sel != canvas.MessageBox.Ok) {
                    return;
                }
                setprop("/sim/multiplay/protocol-version", 2);
            },
            canvas.MessageBox.Ok
            | canvas.MessageBox.Cancel
            | canvas.MessageBox.DontShowAgain
        );
    }
}, 0, 0);

setlistener("/sim/signals/fdm-initialized", func {
    var min_fg_version = getprop("/sim/minimum-fg-version");
    var fg_version = getprop("/sim/version/flightgear");

    var short_fg_version = string.replace(fg_version, '.', '');
    var short_min_fg_version = string.replace(min_fg_version, '.', '');

    # Transmit the FlightGear version in an MP packet
    setprop("/sim/multiplay/generic/short[78]", num(substr(short_fg_version, 2)));

    if (num(short_fg_version) < num(short_min_fg_version)) {
        var title = sprintf("FlightGear %s required", min_fg_version);
        var message = sprintf("This model requires FlightGear %s or higher to work correctly. You are using version %s, which may not fully support this model.", min_fg_version, fg_version);
        canvas.MessageBox.warning(title, message, nil, canvas.MessageBox.Ok | canvas.MessageBox.DontShowAgain);
    }
});
