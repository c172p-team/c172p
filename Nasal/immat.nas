io.include("Aircraft/c172p/Nasal/registration_number.nas");

var refresh_immat = func {
    var immat = props.globals.getNode("/sim/model/immat",1).getValue();
    set_registration_number(props.globals, immat);
};

var immat_dialog = gui.Dialog.new("/sim/gui/dialogs/c172p/status/dialog",
                  "Aircraft/c172p/gui/dialogs/immat.xml");

setlistener("/sim/signals/fdm-initialized", func {
    if (props.globals.getNode("/sim/model/immat") == nil) {
        var immat = props.globals.getNode("/sim/model/immat", 1);
        var callsign = props.globals.getNode("/sim/multiplay/callsign").getValue();

        if (callsign != "callsign")
            immat.setValue(callsign);
        else
            immat.setValue("");
    }
    setlistener("sim/model/immat", refresh_immat, 1, 0);
});
