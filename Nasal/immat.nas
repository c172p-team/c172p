# Immatriculation via Canvas
#
# This file is included from the local model and initializes everything for the local instance

io.include("Aircraft/c172p/Nasal/registration_number.nas");
initC172ImmatCanvas();

var refresh_immat = func {
    var immat = props.globals.getNode("sim/model/immat",1).getValue();
    set_registration_number(props.globals, immat);
};

var immat_dialog = gui.Dialog.new("/sim/gui/dialogs/c172p/status/dialog",
                  "Aircraft/c172p/gui/dialogs/immat.xml");

setlistener("/sim/signals/fdm-initialized", func {
    #print("[IMMAT-DBG] fdm-initialized");
    var immat    = props.globals.getNode("sim/model/immat", 1);
    var callsign = props.globals.getNode("sim/multiplay/callsign").getValue();

    if (callsign != "callsign")
        immat.setValue(callsign);
    else
        immat.setValue("");

    setlistener("sim/model/immat", refresh_immat, 1, 0);
    setlistener("sim/model/livery/name", refresh_immat, 0, 0);
});
