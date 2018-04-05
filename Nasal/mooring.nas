#init Moorage.
 #Replace  the generic Seaboat fightgear system which is wrong, and not completed with the list of harbours.
#This is a customized developpement done from an original idea =>  the Boeing 314A Project ( the nice and accurate FG Clipper) thanks to his unknown Author.

#We are using the original harbour list which was used by the boeing314 model and using too a specific customized addon list which could be improved .
#both files are: mooring-pos_boeing314-based.xml, mooring-pos.xml

#=========Demarrage==============================================
if (getprop("/sim/mooring")){
catalina = setlistener("/sim/signals/fdm-initialized", func { seaplane = Mooring.new(); removelistener(catalina); }
);
}
# ================================================================

Mooring = {};

Mooring.new = func {
   var obj = { parents : [Mooring],
           presets : nil,
           seaplanes : nil,
         };
   obj.init();
   return obj;
};

Mooring.init = func {
   me.presets = props.globals.getNode("/sim/presets");
   me.seaplanes = props.globals.getNode("/systems/mooring/route").getChildren("seaplane");
   me.presetseaplane();
}

Mooring.setmoorage = func( index, moorage ) {
    var latitudedeg = me.seaplanes[ index ].getChild("latitude-deg").getValue();
    var longitudedeg = me.seaplanes[ index ].getChild("longitude-deg").getValue();
    var headingdeg = me.seaplanes[ index ].getChild("heading-deg").getValue();
    print (" LAT ",latitudedeg," LON ",longitudedeg," HEAD ",headingdeg);

# to cheat fg which overwrite the coordinates from the original airport
    me.presets.getChild("airport-id").setValue("");
    me.presets.getChild("latitude-deg").setValue(latitudedeg);
    me.presets.getChild("longitude-deg").setValue(longitudedeg);
    me.presets.getChild("heading-deg").setValue(headingdeg);

    # forces the computation of ground
    me.presets.getChild("altitude-ft").setValue(-9999);
    me.presets.getChild("airspeed-kt").setValue(0);
}

Mooring.presetseaplane = func {
   # vers la recherche du port
   if( getprop("/sim/sceneryloaded") ) {
       settimer(func{ me.presetharbour(); },0.1);
   }
   # une boucle dans l'attente d'une initialisation
   else {
       settimer(func{ me.presetseaplane(); },0.1);
   }
}

# ======Recherche le port=====================
Mooring.presetharbour = func {
    var aglft = 0.0;
    var airport = "";
    var harbour = "";
    if( getprop("/controls/mooring/automatic") and getprop("/controls/mooring/allowed")==1 ) {
        setprop("/fdm/jsbsim/settings/damage", 0);
        if (!getprop("/controls/switches/master-bat")) {
            setprop("/controls/switches/master-bat", 1);
            setprop("/controls/gear/gear-down", 0);
            settimer(func {
                setprop("/controls/switches/master-bat", 0);
            }, 3);
        } else
            setprop("/controls/gear/gear-down", 0);
        airport = me.presets.getChild("airport-id").getValue();
        if( airport != nil and airport != "" ) {
            for(var i=0; i<size(me.seaplanes); i=i+1) {
                harbour = me.seaplanes[ i ].getChild("airport-id").getValue();
                if( harbour == airport ) {
                    print("PORT ",harbour,"    Index ",i);
                    me.setmoorage( i, airport );
                    fgcommand("presets-commit", props.Node.new());
                    me.prepareseaplane();
                    break;
                }
            }
        }
    }
}

#=====Initialisation specifique de l'avion=============
Mooring.prepareseaplane = func{
    controls.gearDown(-1);
    controls.applyParkingBrake(-1);
    setprop("fdm/jsbsim/fcs/mooring-cmd-norm",1);
    print ("Mooring Position with Gear Retracted");

}