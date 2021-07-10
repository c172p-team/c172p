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
# Emesary interface to set fuel information, mainly updating fuel levels.
#

var SelectableFuelInterface = {

new : func ()
{
  var obj = { parents : [ SelectableFuelInterface ] };

  # Emesary
  obj._recipient = nil;
  obj._transmitter = emesary.GlobalTransmitter;
  obj._registered = 0;

  return obj;
},

# Simply update the fuel quantities with the increment.  Note that we assume
# the increment is added to both left and right tanks, rather than being a
# total quanity split between tanks.
updateFuelQuantity : func(incr)
{
  var fuel = getprop("/consumables/fuel/tank[0]/fg1000-indicated-level-gal_us") + incr;
  setprop("/consumables/fuel/tank[0]/fg1000-indicated-level-gal_us", fuel);

  fuel = getprop("/consumables/fuel/tank[1]/fg1000-indicated-level-gal_us") + incr;
  setprop("/consumables/fuel/tank[1]/fg1000-indicated-level-gal_us", fuel);
},

# Set the fuel quantities.  Note that we assume we are setting the value
# to both tanks, rather than splitting between them.
setFuelQuantity : func(val)
{
  setprop("/consumables/fuel/tank[0]/fg1000-indicated-level-gal_us", val);
  setprop("/consumables/fuel/tank[1]/fg1000-indicated-level-gal_us", val);
},

RegisterWithEmesary : func()
{
  if (me._recipient == nil){
    me._recipient = emesary.Recipient.new("FuelInterface");
    var controller = me;

    # Note that unlike the various keys, this data isn't specific to a particular
    # Device - it's shared by all.  Hence we don't check for the notificaiton
    # Device_Id.
    me._recipient.Receive = func(notification)
    {
      if (notification.NotificationType == notifications.PFDEventNotification.DefaultType and
          notification.Event_Id == notifications.PFDEventNotification.FuelData and
          notification.EventParameter != nil)
      {
        var id = notification.EventParameter.Id;

        if (id == "UpdateFuelQuantity") {
          notification.EventParameter.Value = controller.updateFuelQuantity(notification.EventParameter.Value);
          return emesary.Transmitter.ReceiptStatus_Finished;
        }
        if (id == "SetFuelQuantity") {
          notification.EventParameter.Value = controller.setFuelQuantity(notification.EventParameter.Value);
          return emesary.Transmitter.ReceiptStatus_Finished;
        }
      }
      return emesary.Transmitter.ReceiptStatus_NotProcessed;
    };
  }

  me._transmitter.Register(me._recipient);
  me._registered = 1;
},

DeRegisterWithEmesary : func()
{
  # remove registration from transmitter; but keep the recipient once it is created.
  if (me._registered == 1) me._transmitter.DeRegister(me._recipient);
  me._registered = 0;
},


start : func() {
  me.RegisterWithEmesary();
},
stop : func() {
  me.DeRegisterWithEmesary();
},

};
