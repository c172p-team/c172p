#
# Listeners to tie the /consumables/fuels/tank[]/selected to
# /fdm/jsbsim/propulsion/tank[]/priority

setlistener("consumables/fuel/tank[0]/selected", func(selected) {
  setprop("/fdm/jsbsim/propulsion/tank[0]/priority", selected.getBoolValue() ? 1 : 0);
});

setlistener("consumables/fuel/tank[1]/selected", func(selected) {
  setprop("/fdm/jsbsim/propulsion/tank[1]/priority", selected.getBoolValue() ? 1 : 0);
});

