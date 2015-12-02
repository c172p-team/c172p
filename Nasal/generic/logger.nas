# Copyright (C) 2014  onox
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

var error = func (message) {
    var string = sprintf("Error: %s", message);
    print(globals.string.color("31;40;1", string));
};

var warn = func (message) {
    var string = sprintf("Warning: %s", message);
    print(globals.string.color("33;40;1", string));
};

var info = func (message) {
    var string = sprintf("Info: %s", message);
    print(globals.string.color("37;40;1", string));
};

var screen = {

    # Print colored text on the screen

    red: func (message) {
        globals.screen.log.write(message, 1, 0, 0);
    },

    green: func (message) {
        globals.screen.log.write(message, 0, 1.0, 0);
    },

    blue: func (message) {
        globals.screen.log.write(message, 0, 0.584, 1);
    },

    white: func (message) {
        globals.screen.log.write(message, 1, 1, 1);
    }

};
