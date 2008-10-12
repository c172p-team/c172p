####    King KY-196 Comm Transciever   ####
####    Syd Adams    ####
####
####Must be included in the Set file to run the KY-196 radio 
####

KY196 = props.globals.getNode("/instrumentation/ky-196",1);
FDM_ON = 0;

setlistener("/sim/signals/fdm-initialized", func {
    KY196.getNode("comm-num",1).setIntValue(0);
    KY196.getNode("volume-adjust",1).setDoubleValue(0);
    FDM_ON = 1;
    print("KY-196 Comm System ... OK");
    });

setlistener("/instrumentation/ky-196/volume-adjust", func(n) {
    if(FDM_ON == 0){return;}
    var setting = n.getValue();
    n.setDoubleValue(0);
    comm_num = KY196.getNode("comm-num").getValue();
    var commNode = props.globals.getNode("instrumentation/comm[" ~ comm_num ~"]");
    var vol = commNode.getNode("volume").getValue() + setting;
    if(vol > 1.0){vol = 1.0;}
    if(vol < 0.0){vol = 0.0;commNode.getNode("serviceable").setBoolValue(0);}
    if(vol > 0.0){commNode.getNode("serviceable").setBoolValue(1);}
    commNode.getNode("volume").setDoubleValue(vol);
    });
