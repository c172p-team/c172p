# Copyright 2018 Stuart Buchanan
# This file is part of FlightGear.
#
# FlightGear is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
# Fuel Publisher, providing information about fuel tank contents
var SelectableFuelPublisher =
{

  new : func (period=1.0) {
    var obj = {
      parents : [
        SelectableFuelPublisher,
        PeriodicPropertyPublisher.new(notifications.PFDEventNotification.FuelData, period)
      ],
    };

    obj.deltaT = period;


    # Hack to handle most aircraft not having proper engine hours
    if (getprop("/engines/engine[0]/hours") == nil) setprop("/engines/engine[0]/hours", 157.0);

    # Assume pilot has correct fuel quantities entered at Start of Day
    var tanks = props.getNode("/consumables/fuel",1).getChildren("tank");

    foreach(var tank; tanks) {
      var actual = tank.getNode("level-gal_us", 1).getValue();
      var indicatedNode = tank.getNode("fg1000-indicated-level-gal_us", 1);
      if (indicatedNode.getValue() == nil) indicatedNode.setValue(actual);
    }

    return obj;
  },

  # Custom publish method as we package the values into an array of fuel tanks,
  # assuming that fuel is drawn evenly from both tanks.
  publish : func() {
    var tank_data = [];
    var tanks = props.getNode("/consumables/fuel",1).getChildren("tank");

    foreach(var tank; tanks) {
      var indicatedNode = tank.getNode("fg1000-indicated-level-gal_us", 1);
      var fuel = indicatedNode.getValue();
      if (fuel == nil) fuel = 0;
      var fuel_flow = getprop("/engines/active-engine/fuel-flow-gph");
      if (fuel_flow == nil)  fuel_flow = 0;
      fuel = fuel - fuel_flow*me.deltaT/3600.0/2;
      indicatedNode.setValue(fuel);
      append(tank_data, {"FuelUSGal": fuel});
    }

    var notification = notifications.PFDEventNotification.new(
      "MFD",
      1,
      notifications.PFDEventNotification.FuelData,
      { Id : "FuelData", Value : tank_data} );

    me._transmitter.NotifyAll(notification);
  },
};
