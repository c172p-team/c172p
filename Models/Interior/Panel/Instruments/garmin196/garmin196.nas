## garmin 196 functions
var last_time = 0.0;
var last_bearing = -1;
var tab_chiffres_lettres = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
var old_status = -1;

var init_variables = func{
  ##version
  props.globals.getNode("/instrumentation/garmin196/version",1).setValue("JeeP v. 18/03/2012");

  ##routes
  props.globals.getNode("/instrumentation/garmin196/menu_routes/search/x_char",1).setIntValue(0);
  props.globals.getNode("/instrumentation/garmin196/menu_routes/search/y_char",1).setIntValue(0);
  props.globals.getNode("/instrumentation/garmin196/menu_routes/fpl-loaded",1).setBoolValue(0);
  props.globals.getNode("/instrumentation/garmin196/menu_routes/waypoint-jump",1).setBoolValue(0);

  ##points
  props.globals.getNode("/instrumentation/garmin196/menu_points/x_char",1).setIntValue(0);
  props.globals.getNode("/instrumentation/garmin196/menu_points/y_char",1).setIntValue(0);
  
  ##aircrafts
  props.globals.getNode("/instrumentation/garmin196/menu_aircraft/x_char",1).setIntValue(0);
  props.globals.getNode("/instrumentation/garmin196/menu_aircraft/y_char",1).setIntValue(0);
  
  ##init waypoint system
  props.globals.getNode("/instrumentation/garmin196/panel-wpt-bearing",1).setDoubleValue(0);
  props.globals.getNode("/instrumentation/garmin196/position-wpt-bearing",1).setDoubleValue(0);
  props.globals.getNode("/instrumentation/garmin196/panel-wpt-id",1).setValue("------");
  props.globals.getNode("/instrumentation/gps/config/drive-autopilot",1).setBoolValue(0); ##pour ne pas interferer avec l'autopilot

  ##init map system
  props.globals.getNode("/instrumentation/garmin196/map-range",1).setDoubleValue(0.125);
  
  ##init dto system
  props.globals.getNode("/instrumentation/garmin196/dto_display/x_char",1).setIntValue(0);
  props.globals.getNode("/instrumentation/garmin196/dto_display/y_char",1).setIntValue(0);
  
  ##init saveable variables
  props.globals.getNode("/instrumentation/garmin196/antenne-deg",1).setDoubleValue(30);
  props.globals.getNode("/instrumentation/garmin196/light",1).setDoubleValue(30);
  props.globals.getNode("/instrumentation/garmin196/max-speed",1).setDoubleValue(150);
  props.globals.getNode("/instrumentation/garmin196/cruise-speed",1).setDoubleValue(120);
  props.globals.getNode("/instrumentation/garmin196/fuel-flow",1).setDoubleValue(5);
  props.globals.getNode("/instrumentation/garmin196/no_aircraft",1).setIntValue(0);
  props.globals.getNode("/instrumentation/garmin196/symbols/params/airport",1).setBoolValue(1);
  props.globals.getNode("/instrumentation/garmin196/symbols/params/vor",1).setBoolValue(1);
  props.globals.getNode("/instrumentation/garmin196/symbols/params/ndb",1).setBoolValue(1);
  props.globals.getNode("/instrumentation/garmin196/symbols/params/fix",1).setBoolValue(1);
  props.globals.getNode("/instrumentation/garmin196/symbols/params/twn",1).setBoolValue(1);
  props.globals.getNode("/instrumentation/garmin196/symbols/params/wpt",1).setBoolValue(1);
  
  props.globals.getNode("/instrumentation/garmin196/params/units/distance",1).setIntValue(1);
  props.globals.getNode("/instrumentation/garmin196/params/units/speed",1).setIntValue(1);
  props.globals.getNode("/instrumentation/garmin196/params/units/vert-speed",1).setIntValue(1);
  props.globals.getNode("/instrumentation/garmin196/params/units/altitude",1).setIntValue(1);
  props.globals.getNode("/instrumentation/garmin196/params/units/pressure",1).setIntValue(1);
  props.globals.getNode("/instrumentation/garmin196/params/units/temperature",1).setIntValue(1);
  
  props.globals.getNode("/instrumentation/garmin196/params/filtrage",1).setBoolValue(0);
  props.globals.getNode("/instrumentation/garmin196/params/vnav-indicator",1).setBoolValue(1);
  
  ##status du gps
  #0 eteint
  #1 startup page
  #1x map page
  #2x panel page
  #3x position page
  #50 coffee page 
  #menus
  #100 = menu gps
  #110 = menu flights
  #120 = menu route
  #130 = menu points
  #140 = menu aircraft
  #150 = menu e6b
  #160 = menu map
  #170 = menu setup
  props.globals.getNode("/instrumentation/garmin196/status",1).setIntValue(0);
  
  ##popup windows
  #0 = pas de popup
  #1 = affichage du reglage de la lumiere
  #10,11,12 = dto aviation
  #20 = dto recent
  #30 = dto user
  #40 = nrst airport
  #50 = nrst vor
  #60 = nrst ndb
  #70 = nrst fix
  #80 = nrst cities

  props.globals.getNode("/instrumentation/garmin196/popup_status",1).setIntValue(0);
  
  props.globals.getNode("/instrumentation/garmin196/serviceable",1).setBoolValue(0);
  props.globals.getNode("/instrumentation/garmin196/light",1).setDoubleValue(0);
  props.globals.getNode("/instrumentation/garmin196/coffee",1).setIntValue(0);
  
  load_cities();
  main_loop();
}
#setlistener("/sim/signals/fdm-initialized",,0,0);

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{
  settimer(init_variables, 2);
  removelistener(nasalInit);
});

var load_parameters = func{
  fgcommand("loadxml", props.Node.new({ filename: getprop("/sim/fg-home")~"/aircraft-data/garmin196.xml", targetnode: "/instrumentation/garmin196/save" }));
  
  if(getprop("/instrumentation/garmin196/save/antenne-deg")!=nil){
    setprop("/instrumentation/garmin196/antenne-deg",getprop("/instrumentation/garmin196/save/antenne-deg"));
  }
  if(getprop("/instrumentation/garmin196/save/light")!=nil){
    setprop("/instrumentation/garmin196/light",getprop("/instrumentation/garmin196/save/light"));
  }
  if(getprop("/instrumentation/garmin196/save/max-speed")!=nil){
    setprop("/instrumentation/garmin196/max-speed",getprop("/instrumentation/garmin196/save/max-speed"));
  }
  if(getprop("/instrumentation/garmin196/save/cruise-speed")!=nil){
    setprop("/instrumentation/garmin196/cruise-speed",getprop("/instrumentation/garmin196/save/cruise-speed"));
  }
  if(getprop("/instrumentation/garmin196/save/fuel-flow")!=nil){
    setprop("/instrumentation/garmin196/fuel-flow",getprop("/instrumentation/garmin196/save/fuel-flow"));
  }
  if(getprop("/instrumentation/garmin196/save/no_aircraft")!=nil){
    setprop("/instrumentation/garmin196/no_aircraft",getprop("/instrumentation/garmin196/save/no_aircraft"));
  }
  if(getprop("/instrumentation/garmin196/save/symbols/params/airport")!=nil){
    setprop("/instrumentation/garmin196/symbols/params/airport",getprop("/instrumentation/garmin196/save/symbols/params/airport"));
  }
  if(getprop("/instrumentation/garmin196/save/symbols/params/vor")!=nil){
    setprop("/instrumentation/garmin196/symbols/params/vor",getprop("/instrumentation/garmin196/save/symbols/params/vor"));
  }
  if(getprop("/instrumentation/garmin196/save/symbols/params/ndb")!=nil){
    setprop("/instrumentation/garmin196/symbols/params/ndb",getprop("/instrumentation/garmin196/save/symbols/params/ndb"));
  }
  if(getprop("/instrumentation/garmin196/save/symbols/params/fix")!=nil){
    setprop("/instrumentation/garmin196/symbols/params/fix",getprop("/instrumentation/garmin196/save/symbols/params/fix"));
  }
  if(getprop("/instrumentation/garmin196/save/symbols/params/twn")!=nil){
    setprop("/instrumentation/garmin196/symbols/params/twn",getprop("/instrumentation/garmin196/save/symbols/params/twn"));
  }
  if(getprop("/instrumentation/garmin196/save/symbols/params/wpt")!=nil){
    setprop("/instrumentation/garmin196/symbols/params/wpt",getprop("/instrumentation/garmin196/save/symbols/params/wpt"));
  }
  
  if(getprop("/instrumentation/garmin196/save/params/units/distance")!=nil){
    setprop("/instrumentation/garmin196/params/units/distance",getprop("/instrumentation/garmin196/save/params/units/distance"));
  }
  if(getprop("/instrumentation/garmin196/save/params/units/speed")!=nil){
    setprop("/instrumentation/garmin196/params/units/speed",getprop("/instrumentation/garmin196/save/params/units/speed"));
  }
  if(getprop("/instrumentation/garmin196/save/params/units/vert-speed")!=nil){
    setprop("/instrumentation/garmin196/params/units/vert-speed",getprop("/instrumentation/garmin196/save/params/units/vert-speed"));
  }
  if(getprop("/instrumentation/garmin196/save/params/units/altitude")!=nil){
    setprop("/instrumentation/garmin196/params/units/altitude",getprop("/instrumentation/garmin196/save/params/units/altitude"));
  }
  if(getprop("/instrumentation/garmin196/save/params/units/pressure")!=nil){
    setprop("/instrumentation/garmin196/params/units/pressure",getprop("/instrumentation/garmin196/save/params/units/pressure"));
  }
  if(getprop("/instrumentation/garmin196/save/params/units/temperature")!=nil){
    setprop("/instrumentation/garmin196/params/units/temperature",getprop("/instrumentation/garmin196/save/params/units/temperature"));
  }
  if(getprop("/instrumentation/garmin196/save/params/filtrage")!=nil){
    setprop("/instrumentation/garmin196/params/filtrage",getprop("/instrumentation/garmin196/save/params/filtrage"));
  }
  if(getprop("/instrumentation/garmin196/save/params/vnav-indicator")!=nil){
    setprop("/instrumentation/garmin196/params/vnav-indicator",getprop("/instrumentation/garmin196/save/params/vnav-indicator"));
  }
  
  for(var i=0;i<5;i=i+1){
    if(getprop("/instrumentation/garmin196/save/waypoints/recent/wpt["~i~"]/id")!=nil){
      props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/id",1).setValue(getprop("/instrumentation/garmin196/save/waypoints/recent/wpt["~i~"]/id"));
      props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/type",1).setValue(getprop("/instrumentation/garmin196/save/waypoints/recent/wpt["~i~"]/type"));
    }
  }
  
  for(var i=0;i<5;i=i+1){
    if(getprop("/instrumentation/garmin196/save/waypoints/user/wpt["~i~"]/id")!=nil){
      props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/id",1).setValue(getprop("/instrumentation/garmin196/save/waypoints/user/wpt["~i~"]/id"));
      props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/latitude",1).setDoubleValue(getprop("/instrumentation/garmin196/save/waypoints/user/wpt["~i~"]/latitude"));
      props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/longitude",1).setDoubleValue(getprop("/instrumentation/garmin196/save/waypoints/user/wpt["~i~"]/longitude"));
      props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/longitude"));
      props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/latitude"));
      props.globals.getNode("/instrumentation/gps/scratch/ident",1).setValue(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/id")~"WPTUSR");
      setprop("/instrumentation/gps/command","define-user-wpt");
    }
  }
  
  for(var i=0;i<6;i=i+1){
    if(getprop("/instrumentation/garmin196/save/params/aircrafts/aircraft["~i~"]/name")!=nil){
      props.globals.getNode("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/name",1).setValue(getprop("/instrumentation/garmin196/save/params/aircrafts/aircraft["~i~"]/name"));
      props.globals.getNode("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/max-speed",1).setIntValue(getprop("/instrumentation/garmin196/save/params/aircrafts/aircraft["~i~"]/max-speed"));
      props.globals.getNode("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/cruise-speed",1).setIntValue(getprop("/instrumentation/garmin196/save/params/aircrafts/aircraft["~i~"]/cruise-speed"));
      props.globals.getNode("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/fuel-flow",1).setDoubleValue(getprop("/instrumentation/garmin196/save/params/aircrafts/aircraft["~i~"]/fuel-flow"));
    }
  }
  
  for(var i=0;i<9;i=i+1){
    if(getprop("/instrumentation/garmin196/save/flights/flight["~i~"]/start")!=nil){
      props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/start",1).setValue(getprop("/instrumentation/garmin196/save/flights/flight["~i~"]/start"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/end",1).setValue(getprop("/instrumentation/garmin196/save/flights/flight["~i~"]/end"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/date",1).setValue(getprop("/instrumentation/garmin196/save/flights/flight["~i~"]/date"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/aircraft",1).setValue(getprop("/instrumentation/garmin196/save/flights/flight["~i~"]/aircraft"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/distance",1).setDoubleValue(getprop("/instrumentation/garmin196/save/flights/flight["~i~"]/distance"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/duration",1).setDoubleValue(getprop("/instrumentation/garmin196/save/flights/flight["~i~"]/duration"));
    }
  }
  
  for(var i=0;i<11;i=i+1){
    if(getprop("/instrumentation/garmin196/save/routes/route["~i~"]/name")!=nil){
      props.globals.getNode("/instrumentation/garmin196/routes/route["~i~"]/name",1).setValue(getprop("/instrumentation/garmin196/save/routes/route["~i~"]/name"));
      for(var j=0;j<10;j=j+1){
        if(getprop("/instrumentation/garmin196/save/routes/route["~i~"]/wpts/wpt["~j~"]/id")!=nil){
          props.globals.getNode("/instrumentation/garmin196/routes/route["~i~"]/wpts/wpt["~j~"]/id",1).setValue(getprop("/instrumentation/garmin196/save/routes/route["~i~"]/wpts/wpt["~j~"]/id"));
          props.globals.getNode("/instrumentation/garmin196/routes/route["~i~"]/wpts/wpt["~j~"]/type",1).setValue(getprop("/instrumentation/garmin196/save/routes/route["~i~"]/wpts/wpt["~j~"]/type"));
        }
      }
    }
  }
}
setlistener("/sim/signals/fdm-initialized",load_parameters);

var save_parameters = func{
    props.globals.getNode("/instrumentation/garmin196/save").remove();

    ##preparation
    if(getprop("/instrumentation/garmin196/antenne-deg")!=nil){
      props.globals.getNode("/instrumentation/garmin196/save/antenne-deg",1).setDoubleValue(getprop("/instrumentation/garmin196/antenne-deg"));
    }
    if(getprop("/instrumentation/garmin196/light")!=nil){
      props.globals.getNode("/instrumentation/garmin196/save/light",1).setDoubleValue(getprop("/instrumentation/garmin196/light"));
    }
    if(getprop("/instrumentation/garmin196/max-speed")!=nil){
      props.globals.getNode("/instrumentation/garmin196/save/max-speed",1).setDoubleValue(getprop("/instrumentation/garmin196/max-speed"));
    }
    if(getprop("/instrumentation/garmin196/cruise-speed")!=nil){
      props.globals.getNode("/instrumentation/garmin196/save/cruise-speed",1).setDoubleValue(getprop("/instrumentation/garmin196/cruise-speed"));
    }
    if(getprop("/instrumentation/garmin196/fuel-flow")!=nil){
      props.globals.getNode("/instrumentation/garmin196/save/fuel-flow",1).setDoubleValue(getprop("/instrumentation/garmin196/fuel-flow"));
    }
    if(getprop("/instrumentation/garmin196/no_aircraft")!=nil){
      props.globals.getNode("/instrumentation/garmin196/save/no_aircraft",1).setDoubleValue(getprop("/instrumentation/garmin196/no_aircraft"));
    }
    props.globals.getNode("/instrumentation/garmin196/save/symbols/params/airport",1).setDoubleValue(getprop("/instrumentation/garmin196/symbols/params/airport"));
    props.globals.getNode("/instrumentation/garmin196/save/symbols/params/vor",1).setBoolValue(getprop("/instrumentation/garmin196/symbols/params/vor"));
    props.globals.getNode("/instrumentation/garmin196/save/symbols/params/ndb",1).setBoolValue(getprop("/instrumentation/garmin196/symbols/params/ndb"));
    props.globals.getNode("/instrumentation/garmin196/save/symbols/params/fix",1).setBoolValue(getprop("/instrumentation/garmin196/symbols/params/fix"));
    props.globals.getNode("/instrumentation/garmin196/save/symbols/params/twn",1).setBoolValue(getprop("/instrumentation/garmin196/symbols/params/twn"));
    props.globals.getNode("/instrumentation/garmin196/save/symbols/params/wpt",1).setBoolValue(getprop("/instrumentation/garmin196/symbols/params/wpt"));
    
    props.globals.getNode("/instrumentation/garmin196/save/params/units/distance",1).setIntValue(getprop("/instrumentation/garmin196/params/units/distance"));
    props.globals.getNode("/instrumentation/garmin196/save/params/units/speed",1).setIntValue(getprop("/instrumentation/garmin196/params/units/speed"));
    props.globals.getNode("/instrumentation/garmin196/save/params/units/vert-speed",1).setIntValue(getprop("/instrumentation/garmin196/params/units/vert-speed"));
    props.globals.getNode("/instrumentation/garmin196/save/params/units/altitude",1).setIntValue(getprop("/instrumentation/garmin196/params/units/altitude"));
    props.globals.getNode("/instrumentation/garmin196/save/params/units/pressure",1).setIntValue(getprop("/instrumentation/garmin196/params/units/pressure"));
    props.globals.getNode("/instrumentation/garmin196/save/params/units/temperature",1).setIntValue(getprop("/instrumentation/garmin196/params/units/temperature"));
    props.globals.getNode("/instrumentation/garmin196/save/params/filtrage",1).setBoolValue(getprop("/instrumentation/garmin196/params/filtrage"));
    props.globals.getNode("/instrumentation/garmin196/save/params/vnav-indicator",1).setBoolValue(getprop("/instrumentation/garmin196/params/vnav-indicator"));
    
    for(var i=0;i<5;i=i+1){
      if(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/id")!=nil){
        props.globals.getNode("/instrumentation/garmin196/save/waypoints/recent/wpt["~i~"]/id",1).setValue(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/id"));
        props.globals.getNode("/instrumentation/garmin196/save/waypoints/recent/wpt["~i~"]/type",1).setValue(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/type"));
      }
    }
    
    for(var i=0;i<9;i=i+1){
      if(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/id")!=nil){
        props.globals.getNode("/instrumentation/garmin196/save/waypoints/user/wpt["~i~"]/id",1).setValue(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/id"));
        props.globals.getNode("/instrumentation/garmin196/save/waypoints/user/wpt["~i~"]/latitude",1).setValue(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/latitude"));
        props.globals.getNode("/instrumentation/garmin196/save/waypoints/user/wpt["~i~"]/longitude",1).setValue(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/longitude"));
      }
    }
    
    for(var i=0;i<6;i=i+1){
      if(getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/name")!=nil){
        props.globals.getNode("/instrumentation/garmin196/save/params/aircrafts/aircraft["~i~"]/name",1).setValue(getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/name"));
        props.globals.getNode("/instrumentation/garmin196/save/params/aircrafts/aircraft["~i~"]/max-speed",1).setIntValue(getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/max-speed"));
        props.globals.getNode("/instrumentation/garmin196/save/params/aircrafts/aircraft["~i~"]/cruise-speed",1).setIntValue(getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/cruise-speed"));
        props.globals.getNode("/instrumentation/garmin196/save/params/aircrafts/aircraft["~i~"]/fuel-flow",1).setDoubleValue(getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/fuel-flow"));
      }
    }
    for(var i=0;i<8;i=i+1){
      if(getprop("/instrumentation/garmin196/flights/flight["~i~"]/start")!=nil){
        props.globals.getNode("/instrumentation/garmin196/save/flights/flight["~i~"]/start",1).setValue(getprop("/instrumentation/garmin196/flights/flight["~i~"]/start"));
        props.globals.getNode("/instrumentation/garmin196/save/flights/flight["~i~"]/end",1).setValue(getprop("/instrumentation/garmin196/flights/flight["~i~"]/end"));
        props.globals.getNode("/instrumentation/garmin196/save/flights/flight["~i~"]/date",1).setValue(getprop("/instrumentation/garmin196/flights/flight["~i~"]/date"));
        props.globals.getNode("/instrumentation/garmin196/save/flights/flight["~i~"]/aircraft",1).setValue(getprop("/instrumentation/garmin196/flights/flight["~i~"]/aircraft"));
        props.globals.getNode("/instrumentation/garmin196/save/flights/flight["~i~"]/distance",1).setDoubleValue(getprop("/instrumentation/garmin196/flights/flight["~i~"]/distance"));
        props.globals.getNode("/instrumentation/garmin196/save/flights/flight["~i~"]/duration",1).setDoubleValue(getprop("/instrumentation/garmin196/flights/flight["~i~"]/duration"));
      }
    }
    for(var i=0;i<11;i=i+1){
      if(getprop("/instrumentation/garmin196/routes/route["~i~"]/name")!=nil){
        props.globals.getNode("/instrumentation/garmin196/save/routes/route["~i~"]/name",1).setValue(getprop("/instrumentation/garmin196/routes/route["~i~"]/name"));
        for(var j=0;j<10;j=j+1){
          if(getprop("/instrumentation/garmin196/routes/route["~i~"]/wpts/wpt["~j~"]/id")!=nil){
            props.globals.getNode("/instrumentation/garmin196/save/routes/route["~i~"]/wpts/wpt["~j~"]/id",1).setValue(getprop("/instrumentation/garmin196/routes/route["~i~"]/wpts/wpt["~j~"]/id"));
            props.globals.getNode("/instrumentation/garmin196/save/routes/route["~i~"]/wpts/wpt["~j~"]/type",1).setValue(getprop("/instrumentation/garmin196/routes/route["~i~"]/wpts/wpt["~j~"]/type"));
          }
        }
      }
    }
    ##delete file before saving to delete keys
    var file = io.open(getprop("/sim/fg-home")~"/aircraft-data/garmin196.xml", mode="w");
    io.write(file,"");
    io.close(file);
    fgcommand("savexml", props.Node.new({ filename: getprop("/sim/fg-home")~"/aircraft-data/garmin196.xml", sourcenode: "/instrumentation/garmin196/save" }));
}

var main_loop = func{
  var time = getprop("/sim/time/elapsed-sec");
    var dt = time - last_time;
    last_time = time;
  
  calcul_turn_rate(dt);
  change_speed_display();
  change_position_wpt_bug();
  update_flight();
  update_e6b_menu();

  settimer(main_loop, 0.3);
}

var nyi = func (x) { gui.popupTip(x ~ ": not yet implemented", 3); }

var power = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(x==0){
    if(serviceable==1){
      setprop("/instrumentation/garmin196/serviceable",0);
      setprop("/instrumentation/garmin196/status",0);
      setprop("/instrumentation/garmin196/popup_status",0);
    }else{
      setprop("/instrumentation/garmin196/serviceable",1);
      setprop("/instrumentation/garmin196/status",1);
    }
  }
  
  if(x==1 and serviceable==1){
    setprop("/instrumentation/garmin196/popup_status",1)
  }

}

var in = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(serviceable==1){
    var status = getprop("/instrumentation/garmin196/status");
    if(x==0){
      ##traitement des pages
      if(status==10){
        var range = getprop("/instrumentation/garmin196/map-range");
        range = range / 2;
        if(range<0.125){
          range = 0.125;
        }
        setprop("/instrumentation/garmin196/map-range",range);
        return;
      }
    }elsif(x==1){
      if(getprop("/instrumentation/garmin196/coffee")==2 and status>=10){
        setprop("/instrumentation/garmin196/coffee",0);
        setprop("/instrumentation/garmin196/status",50);
      }
    }
  }
}

var out = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(serviceable==1){
    var status = getprop("/instrumentation/garmin196/status");
    if(x==0){
      ##traitement des pages
      if(status==10){
        var range = getprop("/instrumentation/garmin196/map-range");
        range = range * 2;
        if(range>32){
          range = 32;
        }
        setprop("/instrumentation/garmin196/map-range",range);
        return;
      }
    }elsif(x==1){
      if(getprop("/instrumentation/garmin196/coffee")==1 and status>=10){
        setprop("/instrumentation/garmin196/coffee",2);
      }
    }
  }
}

var page = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(serviceable==1){
    var status = getprop("/instrumentation/garmin196/status");
    if(x==0){
      ##traitement des pages
      if(status==10){
        setprop("/instrumentation/garmin196/status",20);
        return;
      }
      
      if(status==20){
        setprop("/instrumentation/garmin196/status",30);
        return;
      }
      
      if(status==30){
        setprop("/instrumentation/garmin196/status",10);
        update_map();
        return;
      }
      
      if(status==50){
        setprop("/instrumentation/garmin196/status",10);
        update_map();
        return;
      }
    }elsif(x==1){
      if(getprop("/instrumentation/garmin196/coffee")==0 and status>=10){
        setprop("/instrumentation/garmin196/coffee",1);
      }
    }
  }
}

var quit = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(serviceable==1){
    if(x==0){
      #traitement des popup
      var popup_status = getprop("/instrumentation/garmin196/popup_status");
      if(popup_status==1){
        setprop("/instrumentation/garmin196/popup_status",0);
        save_parameters();
        return;
      }
      if(popup_status>=10 and popup_status<=99){
        setprop("/instrumentation/garmin196/popup_status",0);
        return;
      }
      
      ##traitement des pages
      var status = getprop("/instrumentation/garmin196/status");
      if(status==10){
        setprop("/instrumentation/garmin196/status",30);
        return;
      }
      
      if(status==20){
        setprop("/instrumentation/garmin196/status",10);
        update_map();
        return;
      }
      
      if(status==30){
        setprop("/instrumentation/garmin196/status",20);
        return;
      }
      
      if(status==50){
        setprop("/instrumentation/garmin196/status",10);
        update_map();
        return;
      }
      
      if(status==111){
        setprop("/instrumentation/garmin196/status",110);
        setprop("/instrumentation/garmin196/menu_flights/no_ligne_selected",-1);
        return;
      }
      
      if(status==112){
        setprop("/instrumentation/garmin196/status",111);
        return;
      }
      
      ##menu routes
      if(status==121){
        setprop("/instrumentation/garmin196/status",120);
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_selected",-1);
        return;
      }
      
      if(status==122){
        setprop("/instrumentation/garmin196/status",121);
        save_parameters();
        return;
      }
      
      if(status==123){
        setprop("/instrumentation/garmin196/status",122);
        return;
      }
      
      if(status==124){
        setprop("/instrumentation/garmin196/status",123);
        return;
      }
      
      ##menu points
      if(status==131){
        setprop("/instrumentation/garmin196/status",130);
        setprop("/instrumentation/garmin196/menu_points/no_ligne_selected",-1);
        init_list_points();
        return;
      }
      
      if(status==132){
        setprop("/instrumentation/garmin196/status",131);
        return;
      }
      
      if(status==133){
        setprop("/instrumentation/garmin196/status",132);
        return;
      }
      
      if(status==134){
        setprop("/instrumentation/garmin196/status",133);
        return;
      }
      
      if(status==135){
        setprop("/instrumentation/garmin196/status",134);
        return;
      }
      
      if(status==136){
        setprop("/instrumentation/garmin196/status",135);
        return;
      }
      
      ##menu aircraft
      if(status==141){
        setprop("/instrumentation/garmin196/status",140);
        setprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected",-1);
        init_list_aircraft();
        display_list_aircraft();
        return;
      }
      
      if(status==142){
        setprop("/instrumentation/garmin196/status",141);
        display_list_aircraft();
        return;
      }
      
      if(status==143){
        setprop("/instrumentation/garmin196/status",142);
        return;
      }
      
      if(status==144){
        setprop("/instrumentation/garmin196/status",143);
        return;
      }
      
      if(status==145){
        setprop("/instrumentation/garmin196/status",144);
        return;
      }
      
      ##menu map
      if(status==161){
        setprop("/instrumentation/garmin196/status",160);
        setprop("/instrumentation/garmin196/menu_map/no_ligne_selected",-1);
        return;
      }
      
      ##menu setup
      if(status==171){
        setprop("/instrumentation/garmin196/status",170);
        setprop("/instrumentation/garmin196/menu_setup/no_ligne_selected",-1);
        return;
      }
      
      if(status==176){
        setprop("/instrumentation/garmin196/status",175);
        setprop("/instrumentation/garmin196/menu_setup/no_ligne_selected",-1);
        return;
      }
      
      if(status>=100 and status <180){
        if(old_status>=10){
          status = old_status;
        }else{
          status = 10;
        }
        setprop("/instrumentation/garmin196/status",status);
        if(status==10){
          update_map();
        }
        return;
      }
    }
  }
}

var enter = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(serviceable==1){
    if(x==0){
      #traitement des popup
      var popup_status = getprop("/instrumentation/garmin196/popup_status");
      if(popup_status==1){
        setprop("/instrumentation/garmin196/popup_status",0);
        save_parameters();
        return;
      }
      
      if(popup_status==10){
        setprop("/instrumentation/garmin196/popup_status",11);
        display_dto_search();
        return;
      }
      
      if(popup_status==11){
        if(getprop("/instrumentation/garmin196/dto_display/max_ligne_selected")>=0){
          props.globals.getNode("/instrumentation/garmin196/dto_display/ligne[0]/selected",1).setBoolValue(1);
          setprop("/instrumentation/garmin196/popup_status",12);
          return;
        }
      }
      
      if(popup_status==12 or popup_status==30){
        setprop("/instrumentation/garmin196/popup_status",0);
        var id = getprop("/instrumentation/garmin196/dto_display/ligne["~getprop("/instrumentation/garmin196/dto_display/no_ligne_selected")~"]/id");
        var type = getprop("/instrumentation/garmin196/dto_display/ligne["~getprop("/instrumentation/garmin196/dto_display/no_ligne_selected")~"]/type");
        affectation_waypoint(id);
        ##rolling recents waypoints
        var existe_deja = 0;
        for(var i=0;i<5;i=i+1){
          if(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/id")==id){
            existe_deja = 1;
            break;
          }
        }
        if(existe_deja==0){
          for(var i=4;i>0;i=i-1){
            if(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~(i-1)~"]/id")){
              props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/id",1).setValue(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~(i-1)~"]/id"));
              props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/type",1).setValue(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~(i-1)~"]/type"));
            }
          }
          props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt[0]/id",1).setValue(id);
          props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt[0]/type",1).setValue(type);
          save_parameters();
        }
        return;
      }
      
      if(popup_status==20){
        setprop("/instrumentation/garmin196/popup_status",0);
        var id = getprop("/instrumentation/garmin196/dto_display/ligne["~getprop("/instrumentation/garmin196/dto_display/no_ligne_selected")~"]/id");
        var type = getprop("/instrumentation/garmin196/dto_display/ligne["~getprop("/instrumentation/garmin196/dto_display/no_ligne_selected")~"]/type");
        affectation_waypoint(id);
        return;
      }
      
      if(popup_status>30 and popup_status<=89){
        setprop("/instrumentation/garmin196/popup_status",0);
        var id = getprop("/instrumentation/garmin196/nrst_display/ligne["~getprop("/instrumentation/garmin196/nrst_display/no_ligne_selected")~"]/id");
        var type = getprop("/instrumentation/garmin196/nrst_display/ligne["~getprop("/instrumentation/garmin196/nrst_display/no_ligne_selected")~"]/type");
        affectation_waypoint(id);
        ##rolling recents waypoints
        var existe_deja = 0;
        for(var i=0;i<5;i=i+1){
          if(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/id")==id){
            existe_deja = 1;
            break;
          }
        }
        if(existe_deja==0){
          for(var i=4;i>0;i=i-1){
            if(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~(i-1)~"]/id")){
              props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/id",1).setValue(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~(i-1)~"]/id"));
              props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt["~i~"]/type",1).setValue(getprop("/instrumentation/garmin196/waypoints/recent/wpt["~(i-1)~"]/type"));
            }
          }
          props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt[0]/id",1).setValue(id);
          props.globals.getNode("/instrumentation/garmin196/waypoints/recent/wpt[0]/type",1).setValue(type);
          save_parameters();
        }
        return;
      }
      
      ##validation de la startup page
      var status = getprop("/instrumentation/garmin196/status");
      if(status==1){
        setprop("/instrumentation/garmin196/status",10);
        update_map();
        return;
      }
      
      if(status==110){
        if(getprop("/instrumentation/garmin196/menu_flights/max_ligne_selected")>=0){
          setprop("/instrumentation/garmin196/menu_flights/no_ligne_selected",0);
          setprop("/instrumentation/garmin196/status",111);
        }
        return;
      }
      
      if(status==111){
        update_menu_flights_detail();
        setprop("/instrumentation/garmin196/status",112);
        return;
      }
      
      if(status==112){
        setprop("/instrumentation/garmin196/status",111);
        return;
      }
      
      if(status==120){
        setprop("/instrumentation/garmin196/status",121);
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_selected",0);
        return;
      }

      if(status==121){
        setprop("/instrumentation/garmin196/status",122);
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
        if(getprop("/instrumentation/garmin196/routes/route["~no_ligne~"]/name")==nil){
          init_new_route(no_ligne);
        }
        update_menu_routes_detail();
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_detail",0);
        return;
      }

      if(status==122){
        setprop("/instrumentation/garmin196/status",123);
        var no_ligne_liste = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
        var no_ligne_detail = getprop("/instrumentation/garmin196/menu_routes/no_ligne_detail");
        if(getprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~no_ligne_detail~"]/id")==nil){
          init_search_route("0");
        }else{
          init_search_route(getprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~no_ligne_detail~"]/id"));
        }
        setprop("/instrumentation/garmin196/menu_routes/search/no_ligne_selected",-1);
        return;
      }
      
      if(status==123){
        if(getprop("/instrumentation/garmin196/menu_routes/search/max_ligne_selected")>=0){
          setprop("/instrumentation/garmin196/status",124);
          setprop("/instrumentation/garmin196/menu_routes/search/no_ligne_selected",0);
        }
        return;
      }
      
      if(status==124){
        validate_menu_search_routes();
        update_menu_routes_detail();
        init_menu_routes_list();
        setprop("/instrumentation/garmin196/status",122);
        return;
      }
      
      if(status==130){
        setprop("/instrumentation/garmin196/status",131);
        setprop("/instrumentation/garmin196/menu_points/no_ligne_selected",0);
        return;
      }

      if(status==131){
        setprop("/instrumentation/garmin196/status",132);
        var no_ligne = getprop("/instrumentation/garmin196/menu_points/no_ligne_selected");
        if(getprop("/instrumentation/garmin196/waypoints/user/wpt["~no_ligne~"]/id")==nil){
          init_new_point(no_ligne);
        }
        update_menu_points();
        return;
      }
      
      if(status==132){
        setprop("/instrumentation/garmin196/status",133);
        return;
      }
      
      if(status==133){
        setprop("/instrumentation/garmin196/status",134);
        return;
      }
      
      if(status==134){
        setprop("/instrumentation/garmin196/status",135);
        return;
      }
      
      if(status==135){
        setprop("/instrumentation/garmin196/status",136);
        return;
      }
      
      if(status==136){
        setprop("/instrumentation/garmin196/status",131);
        validate_menu_points();
        init_list_points();
        return;
      }
      
      if(status==140){
        setprop("/instrumentation/garmin196/status",141);
        setprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected",getprop("/instrumentation/garmin196/no_aircraft"));
        display_list_aircraft();
        return;
      }
      
      if(status==141){
        setprop("/instrumentation/garmin196/status",142);
        var no_ligne = getprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected");
        if(getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/name")==nil){
          init_new_aircraft(no_ligne);
        }
        init_menu_aircraft();
        return;
      }
      
      if(status==142){
        setprop("/instrumentation/garmin196/status",143);
        return;
      }
      
      if(status==143){
        setprop("/instrumentation/garmin196/status",144);
        return;
      }
      
      if(status==144){
        setprop("/instrumentation/garmin196/status",145);
        return;
      }
      
      if(status==145){
        setprop("/instrumentation/garmin196/status",141);
        validate_menu_aircraft();
        init_list_aircraft();
        display_list_aircraft();
        return;
      }
      
      ##menu map
      if(status==160){
        setprop("/instrumentation/garmin196/status",161);
        setprop("/instrumentation/garmin196/menu_map/no_ligne_selected",0);
        return;
      }
      
      if(status==161){
        var no_ligne = getprop("/instrumentation/garmin196/menu_map/no_ligne_selected");
        if(no_ligne==0){
          setprop("/instrumentation/garmin196/symbols/params/airport",(getprop("/instrumentation/garmin196/symbols/params/airport")==1 ? 0 : 1));
        }
        if(no_ligne==1){
          setprop("/instrumentation/garmin196/symbols/params/vor",(getprop("/instrumentation/garmin196/symbols/params/vor")==1 ? 0 : 1));
        }
        if(no_ligne==2){
          setprop("/instrumentation/garmin196/symbols/params/ndb",(getprop("/instrumentation/garmin196/symbols/params/ndb")==1 ? 0 : 1));
        }
        if(no_ligne==3){
          setprop("/instrumentation/garmin196/symbols/params/fix",(getprop("/instrumentation/garmin196/symbols/params/fix")==1 ? 0 : 1));
        }
        if(no_ligne==4){
          setprop("/instrumentation/garmin196/symbols/params/twn",(getprop("/instrumentation/garmin196/symbols/params/twn")==1 ? 0 : 1));
        }
        if(no_ligne==5){
          setprop("/instrumentation/garmin196/symbols/params/wpt",(getprop("/instrumentation/garmin196/symbols/params/wpt")==1 ? 0 : 1));
        }
        save_parameters();
        return;
      }
      
      ##menu setup
      if(status==170){
        setprop("/instrumentation/garmin196/status",171);
        setprop("/instrumentation/garmin196/menu_setup/no_ligne_selected",0);
        return;
      }
      
      if(status==171){
        var no_ligne = getprop("/instrumentation/garmin196/menu_setup/no_ligne_selected");
        if(no_ligne==0){
          setprop("/instrumentation/garmin196/params/units/distance",(getprop("/instrumentation/garmin196/params/units/distance")==1 ? 2 : 1));
        }
        if(no_ligne==1){
          setprop("/instrumentation/garmin196/params/units/speed",(getprop("/instrumentation/garmin196/params/units/speed")==1 ? 2 : 1));
        }
        if(no_ligne==2){
          setprop("/instrumentation/garmin196/params/units/vert-speed",(getprop("/instrumentation/garmin196/params/units/vert-speed")==1 ? 2 : 1));
        }
        if(no_ligne==3){
          setprop("/instrumentation/garmin196/params/units/altitude",(getprop("/instrumentation/garmin196/params/units/altitude")==1 ? 2 : 1));
        }
        if(no_ligne==4){
          setprop("/instrumentation/garmin196/params/units/pressure",(getprop("/instrumentation/garmin196/params/units/pressure")==1 ? 2 : 1));
        }
        if(no_ligne==5){
          setprop("/instrumentation/garmin196/params/units/temperature",(getprop("/instrumentation/garmin196/params/units/temperature")==1 ? 2 : 1));
        }
        save_parameters();
        return;
      }
      
      if(status==175){
        setprop("/instrumentation/garmin196/status",176);
        setprop("/instrumentation/garmin196/menu_setup/no_ligne_selected",0);
        return;
      }
      if(status==176){
        var no_ligne = getprop("/instrumentation/garmin196/menu_setup/no_ligne_selected");
        if(no_ligne==0){
          setprop("/instrumentation/garmin196/params/filtrage",(getprop("/instrumentation/garmin196/params/filtrage")==0 ? 1 : 0));
        }
        if(no_ligne==1){
          setprop("/instrumentation/garmin196/params/vnav-indicator",(getprop("/instrumentation/garmin196/params/vnav-indicator")==0 ? 1 : 0));
        }
        save_parameters();
        return;
      }
      
    }elsif(x==1){
      #traitement des popup
      var popup_status = getprop("/instrumentation/garmin196/popup_status");
      var status = getprop("/instrumentation/garmin196/status");
      if(popup_status==0){##pas de popup
        if(status>=10 and status<=39){
          old_status = status;
          setprop("/instrumentation/garmin196/status",132);
          setprop("/instrumentation/garmin196/menu_points/no_ligne_selected",0);
          var points = props.globals.getNode("/instrumentation/garmin196/waypoints/user/",1).getChildren("wpt");
          for(var i=size(points)-1;i>=0;i=i-1){
            if(i<8){
              props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~(i+1)~"]/id",1).setValue(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/id"));
              props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~(i+1)~"]/latitude",1).setValue(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/latitude"));
              props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~(i+1)~"]/longitude",1).setValue(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/longitude"));
            }
          }
          init_new_point(0);
          update_menu_points();
          #init_list_points();
        }
      }
    }
  }
}

var menu = func (x){
    var serviceable = getprop("/instrumentation/garmin196/serviceable");
  var status = getprop("/instrumentation/garmin196/status");
  if(serviceable==1){
    if(status>=10 and status<100){
      old_status = status;
      setprop("/instrumentation/garmin196/status",100);
      setprop("/instrumentation/garmin196/popup_status",0);
      
      ##particularite map
      if(status==10){  
        setprop("/instrumentation/garmin196/status",160);
        setprop("/instrumentation/garmin196/menu_map/no_ligne_selected",-1);
      }
    }elsif(status>=100){
      if(old_status>=10){
        status = old_status;
      }else{
        status = 10;
      }
      setprop("/instrumentation/garmin196/status",status);
    }
  }
}

var nrst = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  var status = getprop("/instrumentation/garmin196/status");
  if(serviceable==1 and status>1 and status<100){
    if(x==0){
      setprop("/instrumentation/garmin196/popup_status",40);
      display_nrst("airport");
    }
  }
}

var dto = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  var status = getprop("/instrumentation/garmin196/status");
  if(serviceable==1 and status>1 and status<100){
    if(x==0){
      setprop("/instrumentation/garmin196/popup_status",10);
      setprop("/instrumentation/garmin196/dto_display/ligne_select","Press Enter to search");
      init_dto_display();
      setprop("/instrumentation/garmin196/dto_display/x_char",0);
      setprop("/instrumentation/garmin196/dto_display/y_char",0);
    }
  }
}

var rockerup = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(serviceable==1){
    if(x==0){
      #traitement des popup
      var popup_status = getprop("/instrumentation/garmin196/popup_status");
      
      if(popup_status==1){
        var light_level = getprop("/instrumentation/garmin196/light");
        light_level = light_level + 0.1;
        if(light_level>1){
          light_level = 1;
        }
        setprop("/instrumentation/garmin196/light",light_level);
        return;
      }
      
      if(popup_status==11){
        var y_char = getprop("/instrumentation/garmin196/dto_display/y_char");
        y_char = y_char + 1;
        if(y_char>35){
          y_char = 0;
        }
        setprop("/instrumentation/garmin196/dto_display/y_char",y_char);
        display_dto_search();
        return;
      }
      
      if(popup_status==12){
        var no_ligne = getprop("/instrumentation/garmin196/dto_display/no_ligne_selected");
        var old_no_ligne = no_ligne;
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/dto_display/no_ligne_selected",no_ligne);
        if(old_no_ligne!=no_ligne){
          setprop("/instrumentation/garmin196/dto_display/ligne["~no_ligne~"]/selected",1);
          setprop("/instrumentation/garmin196/dto_display/ligne["~old_no_ligne~"]/selected",0);
        }
        return;
      }
      
      if(popup_status==20 or popup_status==30){
        var no_ligne = getprop("/instrumentation/garmin196/dto_display/no_ligne_selected");
        var old_no_ligne = no_ligne;
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/dto_display/no_ligne_selected",no_ligne);
        setprop("/instrumentation/garmin196/dto_display/ligne_select",getprop("/instrumentation/garmin196/dto_display/ligne["~no_ligne~"]/texte"));
        if(old_no_ligne!=no_ligne){
          setprop("/instrumentation/garmin196/dto_display/ligne["~no_ligne~"]/selected",1);
          setprop("/instrumentation/garmin196/dto_display/ligne["~old_no_ligne~"]/selected",0);
        }
        return;
      }
      
      if(popup_status>=40 and popup_status<=99){
        var no_ligne = getprop("/instrumentation/garmin196/nrst_display/no_ligne_selected");
        var old_no_ligne = no_ligne;
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/nrst_display/no_ligne_selected",no_ligne);
        setprop("/instrumentation/garmin196/nrst_display/ligne_select",getprop("/instrumentation/garmin196/nrst_display/ligne["~no_ligne~"]/texte"));
        if(old_no_ligne!=no_ligne){
          setprop("/instrumentation/garmin196/nrst_display/ligne["~no_ligne~"]/selected",1);
          setprop("/instrumentation/garmin196/nrst_display/ligne["~old_no_ligne~"]/selected",0);
        }
        return;
      }
      
      ##traitement des menus
      var status = getprop("/instrumentation/garmin196/status");
      if(status>=100 and status<110){
        setprop("/instrumentation/garmin196/status",170);
        return;
      }
      
      if(status==110){
        setprop("/instrumentation/garmin196/status",100);
        return;
      }
      
      if(status==111){
        if(getprop("/instrumentation/garmin196/menu_flights/max_ligne_selected")>=0){
          var no_ligne = getprop("/instrumentation/garmin196/menu_flights/no_ligne_selected");
          no_ligne = no_ligne - 1;
          if(no_ligne<0){
            no_ligne = 0;
          }
          setprop("/instrumentation/garmin196/menu_flights/no_ligne_selected",no_ligne);
        }
      }
      
      if(status==120){
        setprop("/instrumentation/garmin196/status",110);
        display_menu_flights();
        return;
      }
      
      if(status==121){
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_selected",no_ligne);
        return;
      }
      
      if(status==122){
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/no_ligne_detail");
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_detail",no_ligne);
        return;
      }
      
      if(status==123){
        var y_char = getprop("/instrumentation/garmin196/menu_routes/search/y_char");
        y_char = y_char + 1;
        if(y_char>35){
          y_char = 0;
        }
        setprop("/instrumentation/garmin196/menu_routes/search/y_char",y_char);
        display_route_waypoint_search();
        return;
      }
      
      if(status==124){
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/search/no_ligne_selected");
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/menu_routes/search/no_ligne_selected",no_ligne);
        return;
      }
      
      if(status==130){
        setprop("/instrumentation/garmin196/status",120);
        init_menu_routes_list();
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_selected",-1);
        return;
      }
      
      if(status==131){
        var no_ligne = getprop("/instrumentation/garmin196/menu_points/no_ligne_selected");
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/menu_points/no_ligne_selected",no_ligne);
        return;
      }
      
      if(status==132){
        var y_char = getprop("/instrumentation/garmin196/menu_points/y_char");
        y_char = y_char + 1;
        if(y_char>35){
          y_char = 0;
        }
        setprop("/instrumentation/garmin196/menu_points/y_char",y_char);
        display_menu_points();
        return;
      }
      
      if(status==133){
        var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
        latitude = latitude + 1;
        if(latitude>180){
          latitude = 180;
        }
        setprop("/instrumentation/garmin196/menu_points/latitude",latitude);
        display_menu_points();
        return;
      }
      
      if(status==134){
        var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
        latitude = latitude + .01;
        if(latitude>180){
          latitude = 180;
        }
        setprop("/instrumentation/garmin196/menu_points/latitude",latitude);
        display_menu_points();
        return;
      }
      
      if(status==135){
        var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
        longitude = longitude + 1;
        if(longitude>180){
          longitude = -180;
        }
        setprop("/instrumentation/garmin196/menu_points/longitude",longitude);
        display_menu_points();
        return;
      }
      
      if(status==136){
        var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
        longitude = longitude + .01;
        if(longitude>180){
          longitude = -180;
        }
        setprop("/instrumentation/garmin196/menu_points/longitude",longitude);
        display_menu_points();
        return;
      }
      
      if(status==140){
        setprop("/instrumentation/garmin196/status",130);
        setprop("/instrumentation/garmin196/menu_points/no_ligne_selected",-1);
        init_list_points();
        return;
      }
      
      if(status==141){
        var no_ligne = getprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected");
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected",no_ligne);
        display_list_aircraft();
        return;
      }
      
      if(status==142){
        var y_char = getprop("/instrumentation/garmin196/menu_aircraft/y_char");
        y_char = y_char + 1;
        if(y_char>35){
          y_char = 0;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/y_char",y_char);
        display_menu_aircraft_name();
        return;
      }
      
      if(status==143){
        var cruise = getprop("/instrumentation/garmin196/menu_aircraft/selected-cruise");
        cruise = cruise + 1;
        if(cruise>500){
          cruise = 500;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-cruise",cruise);
        display_menu_aircraft();
        return;
      }
      
      if(status==144){
        var max = getprop("/instrumentation/garmin196/menu_aircraft/selected-max");
        max = max + 1;
        if(max>500){
          max = 500;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-max",max);
        display_menu_aircraft();
        return;
      }
      
      if(status==145){
        var fuelflow = getprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow");
        fuelflow = fuelflow + 0.1;
        if(fuelflow>100){
          fuelflow = 100;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow",fuelflow);
        return;
      }
  
      if(status==150){
        setprop("/instrumentation/garmin196/status",140);
        setprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected",-1);
        init_list_aircraft();
        display_list_aircraft();
        return;
      }
      
      if(status==160){
        setprop("/instrumentation/garmin196/status",150);
        return;
      }
      
      if(status==161){
        var no_ligne = getprop("/instrumentation/garmin196/menu_map/no_ligne_selected");
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/menu_map/no_ligne_selected",no_ligne);
        return;
      }
      
      if(status==170){
        setprop("/instrumentation/garmin196/status",160);
        setprop("/instrumentation/garmin196/menu_map/no_ligne_selected",-1);
        return;
      }
      
      if(status==171){
        var no_ligne = getprop("/instrumentation/garmin196/menu_setup/no_ligne_selected");
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/menu_setup/no_ligne_selected",no_ligne);
        return;
      }

      if(status==176){
        var no_ligne = getprop("/instrumentation/garmin196/menu_setup/no_ligne_selected");
        no_ligne = no_ligne - 1;
        if(no_ligne<0){
          no_ligne = 0;
        }
        setprop("/instrumentation/garmin196/menu_setup/no_ligne_selected",no_ligne);
        return;
      }
      
    }elsif(x==1){
      #traitement des popup
      var popup_status = getprop("/instrumentation/garmin196/popup_status");
      if(popup_status==11){
        var y_char = getprop("/instrumentation/garmin196/dto_display/y_char");
        y_char = y_char + 10;
        if(y_char>35){
          y_char = y_char-36;
        }
        setprop("/instrumentation/garmin196/dto_display/y_char",y_char);
        display_dto_search();
        return;
      }
      
      ##traitement des menus
      var status = getprop("/instrumentation/garmin196/status");
      
      if(status==123){
        var y_char = getprop("/instrumentation/garmin196/menu_routes/search/y_char");
        y_char = y_char + 10;
        if(y_char>35){
          y_char = y_char-36;
        }
        setprop("/instrumentation/garmin196/menu_routes/search/y_char",y_char);
        display_route_waypoint_search();
        return;
      }
      
      if(status==132){
        var y_char = getprop("/instrumentation/garmin196/menu_points/y_char");
        y_char = y_char + 10;
        if(y_char>35){
          y_char = y_char-36;
        }
        setprop("/instrumentation/garmin196/menu_points/y_char",y_char);
        display_menu_points();
        return;
      }
      
      if(status==133){
        var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
        latitude = latitude + 10;
        if(latitude>180){
          latitude = 180;
        }
        setprop("/instrumentation/garmin196/menu_points/latitude",latitude);
        display_menu_points();
        return;
      }
      
      if(status==134){
        var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
        latitude = latitude + .1;
        if(latitude>180){
          latitude = 180;
        }
        setprop("/instrumentation/garmin196/menu_points/latitude",latitude);
        display_menu_points();
        return;
      }
      
      if(status==135){
        var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
        longitude = longitude + 10;
        if(longitude>180){
          longitude = -180;
        }
        setprop("/instrumentation/garmin196/menu_points/longitude",longitude);
        display_menu_points();
        return;
      }
      
      if(status==136){
        var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
        longitude = longitude + .1;
        if(longitude>180){
          longitude = -180;
        }
        setprop("/instrumentation/garmin196/menu_points/longitude",longitude);
        display_menu_points();
        return;
      }
      
      if(status==142){
        var y_char = getprop("/instrumentation/garmin196/menu_aircraft/y_char");
        y_char = y_char + 10;
        if(y_char>35){
          y_char = y_char-36;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/y_char",y_char);
        display_menu_aircraft_name();
        return;
      }
      
      if(status==143){
        var cruise = getprop("/instrumentation/garmin196/menu_aircraft/selected-cruise");
        cruise = cruise + 10;
        if(cruise>500){
          cruise = 500;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-cruise",cruise);
        display_menu_aircraft();
        return;
      }
      
      if(status==144){
        var max = getprop("/instrumentation/garmin196/menu_aircraft/selected-max");
        max = max + 10;
        if(max>500){
          max = 500;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-max",max);
        display_menu_aircraft();
        return;
      }
      
      if(status==145){
        var fuelflow = getprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow");
        fuelflow = fuelflow + 1;
        if(fuelflow>100){
          fuelflow = 100;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow",fuelflow);
        return;
      }
    }
  }
}

var rockerdown = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(serviceable==1){
    if(x==0){
      #traitement des popup
      var popup_status = getprop("/instrumentation/garmin196/popup_status");
      if(popup_status==1){
        var light_level = getprop("/instrumentation/garmin196/light");
        light_level = light_level - 0.1;
        if(light_level<0){
          light_level = 0;
        }
        setprop("/instrumentation/garmin196/light",light_level);
        return;
      }
      
      if(popup_status==11){
        var y_char = getprop("/instrumentation/garmin196/dto_display/y_char");
        y_char = y_char - 1;
        if(y_char<0){
          y_char = 35;
        }
        setprop("/instrumentation/garmin196/dto_display/y_char",y_char);
        display_dto_search();
        return;
      }
      
      if(popup_status==12){
        var no_ligne = getprop("/instrumentation/garmin196/dto_display/no_ligne_selected");
        var old_no_ligne = no_ligne;
        var max_ligne = getprop("/instrumentation/garmin196/dto_display/max_ligne_selected");
        no_ligne = no_ligne + 1;
        if(no_ligne>max_ligne){
          no_ligne = max_ligne;
        }
        setprop("/instrumentation/garmin196/dto_display/no_ligne_selected",no_ligne);
        if(old_no_ligne!=no_ligne){
          setprop("/instrumentation/garmin196/dto_display/ligne["~no_ligne~"]/selected",1);
          setprop("/instrumentation/garmin196/dto_display/ligne["~old_no_ligne~"]/selected",0);
        }
        return;
      }
      
      if(popup_status==20 or popup_status==30){
        var no_ligne = getprop("/instrumentation/garmin196/dto_display/no_ligne_selected");
        var old_no_ligne = no_ligne;
        var max_ligne = getprop("/instrumentation/garmin196/dto_display/max_ligne_selected");
        no_ligne = no_ligne + 1;
        if(no_ligne>max_ligne){
          no_ligne = max_ligne;
        }
        setprop("/instrumentation/garmin196/dto_display/no_ligne_selected",no_ligne);
        setprop("/instrumentation/garmin196/dto_display/ligne_select",getprop("/instrumentation/garmin196/dto_display/ligne["~no_ligne~"]/texte"));
        if(old_no_ligne!=no_ligne){
          setprop("/instrumentation/garmin196/dto_display/ligne["~no_ligne~"]/selected",1);
          setprop("/instrumentation/garmin196/dto_display/ligne["~old_no_ligne~"]/selected",0);
        }
        return;
      }
      
      if(popup_status>=40 and popup_status<=99){
        var no_ligne = getprop("/instrumentation/garmin196/nrst_display/no_ligne_selected");
        var old_no_ligne = no_ligne;
        var max_ligne = getprop("/instrumentation/garmin196/nrst_display/max_ligne_selected");
        no_ligne = no_ligne + 1;
        if(no_ligne>max_ligne){
          no_ligne = max_ligne;
        }
        setprop("/instrumentation/garmin196/nrst_display/no_ligne_selected",no_ligne);
        setprop("/instrumentation/garmin196/nrst_display/ligne_select",getprop("/instrumentation/garmin196/nrst_display/ligne["~no_ligne~"]/texte"));
        if(old_no_ligne!=no_ligne){
          setprop("/instrumentation/garmin196/nrst_display/ligne["~no_ligne~"]/selected",1);
          setprop("/instrumentation/garmin196/nrst_display/ligne["~old_no_ligne~"]/selected",0);
        }
        return;
      }
      
      ##traitement des menus
      var status = getprop("/instrumentation/garmin196/status");
      if(status>=100 and status<110){
        setprop("/instrumentation/garmin196/status",110);
        display_menu_flights();
        return;
      }
      
      if(status==110){
        setprop("/instrumentation/garmin196/status",120);
        init_menu_routes_list();
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_selected",-1);
        return;
      }
      
      if(status==111){
        if(getprop("/instrumentation/garmin196/menu_flights/max_ligne_selected")>=0){
          var no_ligne = getprop("/instrumentation/garmin196/menu_flights/no_ligne_selected");
          no_ligne = no_ligne + 1;
          if(no_ligne>getprop("/instrumentation/garmin196/menu_flights/max_ligne_selected")){
            no_ligne = getprop("/instrumentation/garmin196/menu_flights/max_ligne_selected");
          }
          setprop("/instrumentation/garmin196/menu_flights/no_ligne_selected",no_ligne);
        }
        return;
      }
      
      if(status==120){
        setprop("/instrumentation/garmin196/status",130);
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_selected",-1);
        init_list_points();
        return;
      }
      
      if(status==121){
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
        var max_no_ligne = getprop("/instrumentation/garmin196/menu_routes/max_no_ligne");
        no_ligne = no_ligne + 1;
        if(no_ligne>max_no_ligne){
          no_ligne = max_no_ligne;
        }
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_selected",no_ligne);
        return;
      }

      if(status==122){
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/no_ligne_detail");
        var max_no_ligne = getprop("/instrumentation/garmin196/menu_routes/max_no_ligne_detail");
        no_ligne = no_ligne + 1;
        if(no_ligne>max_no_ligne){
          no_ligne = max_no_ligne;
        }
        setprop("/instrumentation/garmin196/menu_routes/no_ligne_detail",no_ligne);
        return;
      }
      
      if(status==123){
        var y_char = getprop("/instrumentation/garmin196/menu_routes/search/y_char");
        y_char = y_char - 1;
        if(y_char<0){
          y_char = 35;
        }
        setprop("/instrumentation/garmin196/menu_routes/search/y_char",y_char);
        display_route_waypoint_search();
        return;
      }
      
      if(status==124){
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/search/no_ligne_selected");
        var max_no_ligne = getprop("/instrumentation/garmin196/menu_routes/search/max_ligne_selected");
        no_ligne = no_ligne + 1;
        if(no_ligne>max_no_ligne){
          no_ligne = max_no_ligne;
        }
        setprop("/instrumentation/garmin196/menu_routes/search/no_ligne_selected",no_ligne);
        return;
      }
      
      if(status==130){
        setprop("/instrumentation/garmin196/status",140);
        setprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected",-1);
        init_list_aircraft();
        display_list_aircraft();
        return;
      }

      if(status==131){
        var no_ligne = getprop("/instrumentation/garmin196/menu_points/no_ligne_selected");
        no_ligne = no_ligne + 1;
        if(no_ligne>getprop("/instrumentation/garmin196/menu_points/max_no_ligne")){
          no_ligne = getprop("/instrumentation/garmin196/menu_points/max_no_ligne");
        }
        setprop("/instrumentation/garmin196/menu_points/no_ligne_selected",no_ligne);
        return;
      }
      
      if(status==132){
        var y_char = getprop("/instrumentation/garmin196/menu_points/y_char");
        y_char = y_char - 1;
        if(y_char<0){
          y_char = 35;
        }
        setprop("/instrumentation/garmin196/menu_points/y_char",y_char);
        display_menu_points();
        return;
      }
      
      if(status==133){
        var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
        latitude = latitude - 1;
        if(latitude<-180){
          latitude = -180;
        }
        setprop("/instrumentation/garmin196/menu_points/latitude",latitude);
        display_menu_points();
        return;
      }
      
      if(status==134){
        var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
        latitude = latitude - .01;
        if(latitude<-180){
          latitude = -180;
        }
        setprop("/instrumentation/garmin196/menu_points/latitude",latitude);
        display_menu_points();
        return;
      }
      
      if(status==135){
        var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
        longitude = longitude - 1;
        if(longitude<-180){
          longitude = 180;
        }
        setprop("/instrumentation/garmin196/menu_points/longitude",longitude);
        display_menu_points();
        return;
      }
      
      if(status==136){
        var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
        longitude = longitude - .01;
        if(longitude<-180){
          longitude = 180;
        }
        setprop("/instrumentation/garmin196/menu_points/longitude",longitude);
        display_menu_points();
        return;
      }
      
      if(status==140){
        setprop("/instrumentation/garmin196/status",150);
        return;
      }
      
      if(status==141){
        var no_ligne = getprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected");
        no_ligne = no_ligne + 1;
        if(no_ligne>getprop("/instrumentation/garmin196/menu_aircraft/max_no_ligne")){
          no_ligne = getprop("/instrumentation/garmin196/menu_aircraft/max_no_ligne");
        }
        setprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected",no_ligne);
        display_list_aircraft();
        return;
      }
      
      if(status==142){
        var y_char = getprop("/instrumentation/garmin196/menu_aircraft/y_char");
        y_char = y_char - 1;
        if(y_char<0){
          y_char = 35;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/y_char",y_char);
        display_menu_aircraft_name();
        return;
      }
      
      if(status==143){
        var cruise = getprop("/instrumentation/garmin196/menu_aircraft/selected-cruise");
        cruise = cruise - 1;
        if(cruise<1){
          cruise = 1;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-cruise",cruise);
        display_menu_aircraft();
        return;
      }
      
      if(status==144){
        var max = getprop("/instrumentation/garmin196/menu_aircraft/selected-max");
        max = max - 1;
        if(max<1){
          max = 1;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-max",max);
        display_menu_aircraft();
        return;
      }
      
      if(status==145){
        var fuelflow = getprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow");
        fuelflow = fuelflow - 0.1;
        if(fuelflow<1){
          fuelflow = 1;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow",fuelflow);
        return;
      }
      
      if(status==150){
        setprop("/instrumentation/garmin196/status",160);
        setprop("/instrumentation/garmin196/menu_map/no_ligne_selected",-1);
        return;
      }
      
      if(status==160){
        setprop("/instrumentation/garmin196/status",170);
        return;
      }
      
      if(status==161){
        var no_ligne = getprop("/instrumentation/garmin196/menu_map/no_ligne_selected");
        no_ligne = no_ligne + 1;
        if(no_ligne>5){
          no_ligne = 5;
        }
        setprop("/instrumentation/garmin196/menu_map/no_ligne_selected",no_ligne);
        return;
      }
      
      if(status==170){
        setprop("/instrumentation/garmin196/status",100);
        return;
      }
      
      if(status==171){
        var no_ligne = getprop("/instrumentation/garmin196/menu_setup/no_ligne_selected");
        no_ligne = no_ligne + 1;
        if(no_ligne>5){
          no_ligne = 5;
        }
        setprop("/instrumentation/garmin196/menu_setup/no_ligne_selected",no_ligne);
        return;
      }
      
      if(status==176){
        var no_ligne = getprop("/instrumentation/garmin196/menu_setup/no_ligne_selected");
        no_ligne = no_ligne + 1;
        if(no_ligne>1){
          no_ligne = 1;
        }
        setprop("/instrumentation/garmin196/menu_setup/no_ligne_selected",no_ligne);
        return;
      }
      
    }elsif(x==1){
      #traitement des popup
      var popup_status = getprop("/instrumentation/garmin196/popup_status");
      if(popup_status==11){
        var y_char = getprop("/instrumentation/garmin196/dto_display/y_char");
        y_char = y_char - 10;
        if(y_char<0){
          y_char = y_char + 36;
        }
        setprop("/instrumentation/garmin196/dto_display/y_char",y_char);
        display_dto_search();
        return;
      }
      
      ##traitement des menus
      var status = getprop("/instrumentation/garmin196/status");
      
      if(status==123){
        var y_char = getprop("/instrumentation/garmin196/menu_routes/search/y_char");
        y_char = y_char - 10;
        if(y_char<0){
          y_char = y_char + 36;
        }
        setprop("/instrumentation/garmin196/menu_routes/search/y_char",y_char);
        display_route_waypoint_search();
        return;
      }
      
      if(status==132){
        var y_char = getprop("/instrumentation/garmin196/menu_points/y_char");
        y_char = y_char - 10;
        if(y_char<0){
          y_char = y_char + 36;
        }
        setprop("/instrumentation/garmin196/menu_points/y_char",y_char);
        display_menu_points();
        return;
      }
      
      if(status==132){
        var y_char = getprop("/instrumentation/garmin196/menu_points/y_char");
        y_char = y_char - 1;
        if(y_char<0){
          y_char = 35;
        }
        setprop("/instrumentation/garmin196/menu_points/y_char",y_char);
        display_menu_points();
        return;
      }
      
      if(status==133){
        var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
        latitude = latitude - 10;
        if(latitude<-180){
          latitude = -180;
        }
        setprop("/instrumentation/garmin196/menu_points/latitude",latitude);
        display_menu_points();
        return;
      }
      
      if(status==134){
        var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
        latitude = latitude - .1;
        if(latitude<-180){
          latitude = -180;
        }
        setprop("/instrumentation/garmin196/menu_points/latitude",latitude);
        display_menu_points();
        return;
      }
      
      if(status==135){
        var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
        longitude = longitude - 10;
        if(longitude<-180){
          longitude = 180;
        }
        setprop("/instrumentation/garmin196/menu_points/longitude",longitude);
        display_menu_points();
        return;
      }
      
      if(status==136){
        var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
        longitude = longitude - .1;
        if(longitude<-180){
          longitude = 180;
        }
        setprop("/instrumentation/garmin196/menu_points/longitude",longitude);
        display_menu_points();
        return;
      }
      
      if(status==142){
        var y_char = getprop("/instrumentation/garmin196/menu_aircraft/y_char");
        y_char = y_char - 10;
        if(y_char<0){
          y_char = y_char + 36;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/y_char",y_char);
        display_menu_aircraft_name();
        return;
      }
      
      if(status==143){
        var cruise = getprop("/instrumentation/garmin196/menu_aircraft/selected-cruise");
        cruise = cruise - 10;
        if(cruise<1){
          cruise = 1;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-cruise",cruise);
        display_menu_aircraft();
        return;
      }
      
      if(status==144){
        var max = getprop("/instrumentation/garmin196/menu_aircraft/selected-max");
        max = max - 10;
        if(max<1){
          max = 1;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-max",max);
        display_menu_aircraft();
        return;
      }
      
      if(status==145){
        var fuelflow = getprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow");
        fuelflow = fuelflow - 1;
        if(fuelflow<1){
          fuelflow = 1;
        }
        setprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow",fuelflow);
        return;
      }
    }
  }
}

var rockerleft = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(serviceable==1){
    if(x==0){
      #traitement des popup
      var popup_status = getprop("/instrumentation/garmin196/popup_status");
      if(popup_status==10){
        setprop("/instrumentation/garmin196/popup_status",30);
        setprop("/instrumentation/garmin196/dto_display/ligne_select","");
        init_dto_display();
        display_dto_user();
        return;
      }
      if(popup_status==11){
        var x_char = getprop("/instrumentation/garmin196/dto_display/x_char");
        if(x_char>0){
          setprop("/instrumentation/garmin196/dto_display/x_char",x_char-1);
          setprop("/instrumentation/garmin196/dto_display/y_char",searchLastChar(getprop("/instrumentation/garmin196/dto_display/ligne_select"),getprop("/instrumentation/garmin196/dto_display/x_char")));
          display_dto_search();
        }
        return;
      }
      if(popup_status==20){
        setprop("/instrumentation/garmin196/popup_status",10);
        setprop("/instrumentation/garmin196/dto_display/x_char",0);
        setprop("/instrumentation/garmin196/dto_display/y_char",0);
        setprop("/instrumentation/garmin196/dto_display/ligne_select","Press Enter to search");
        init_dto_display();
        return;
      }
      if(popup_status==30){
        setprop("/instrumentation/garmin196/popup_status",20);
        setprop("/instrumentation/garmin196/dto_display/ligne_select","");
        init_dto_display();
        display_dto_recent();
        return;
      }
      
      if(popup_status==40){
        setprop("/instrumentation/garmin196/popup_status",80);
        display_nrst("wpt");
        return;
      }
      
      if(popup_status==50){
        setprop("/instrumentation/garmin196/popup_status",40);
        display_nrst("airport");
        return;
      }
      
      if(popup_status==60){
        setprop("/instrumentation/garmin196/popup_status",50);
        display_nrst("vor");
        return;
      }
      
      if(popup_status==70){
        setprop("/instrumentation/garmin196/popup_status",60);
        display_nrst("ndb");
        return;
      }
      
      if(popup_status==80){
        setprop("/instrumentation/garmin196/popup_status",70);
        display_nrst("fix");
        return;
      }
      
      var status = getprop("/instrumentation/garmin196/status");
      
      ##menu routes
      #suppression de la ligne
      if(status==121){
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
        delete_route(no_ligne);
        init_menu_routes_list();
      }
      
      if(status==122){
        var no_ligne_liste = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
        var no_ligne_detail = getprop("/instrumentation/garmin196/menu_routes/no_ligne_detail");
        delete_route_detail(no_ligne_liste,no_ligne_detail);
        update_menu_routes_detail();
        return;
      }
      
      if(status==123){
        var x_char = getprop("/instrumentation/garmin196/menu_routes/search/x_char");
        if(x_char>0){
          setprop("/instrumentation/garmin196/menu_routes/search/x_char",x_char-1);
          setprop("/instrumentation/garmin196/menu_routes/search/y_char",searchLastChar(getprop("/instrumentation/garmin196/menu_routes/search/ligne_select"),getprop("/instrumentation/garmin196/menu_routes/search/x_char")));
          display_route_waypoint_search();
        }
        return;
      }
      
      ##menu points
      #suppression de la ligne
      if(status==131){
        var no_ligne = getprop("/instrumentation/garmin196/menu_points/no_ligne_selected");
        delete_point(no_ligne);
        init_list_points();
      }
      
      if(status==132){
        var x_char = getprop("/instrumentation/garmin196/menu_points/x_char");
        if(x_char>0){
          setprop("/instrumentation/garmin196/menu_points/x_char",x_char-1);
          setprop("/instrumentation/garmin196/menu_points/y_char",searchLastChar(getprop("/instrumentation/garmin196/menu_points/name"),getprop("/instrumentation/garmin196/menu_points/x_char")));
          display_menu_points();
        }
        return;
      }
      
      ##menu aircraft
      #suppression de la ligne
      if(status==141){
        var no_ligne = getprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected");
        delete_aircraft(no_ligne);
        init_list_aircraft();
        display_list_aircraft();
      }

      if(status==142){
        var x_char = getprop("/instrumentation/garmin196/menu_aircraft/x_char");
        if(x_char>0){
          setprop("/instrumentation/garmin196/menu_aircraft/x_char",x_char-1);
          setprop("/instrumentation/garmin196/menu_aircraft/y_char",searchLastChar(getprop("/instrumentation/garmin196/menu_aircraft/selected-name"),getprop("/instrumentation/garmin196/menu_aircraft/x_char")));
          display_menu_aircraft_name();
        }
        return;
      }
      
      if(status==175){
        setprop("/instrumentation/garmin196/status",170);
      }

    }
  }
}

var rockerright = func (x){
  var serviceable = getprop("/instrumentation/garmin196/serviceable");
  if(serviceable==1){
    if(x==0){
      #traitement des popup
      var popup_status = getprop("/instrumentation/garmin196/popup_status");
      if(popup_status==10){
        setprop("/instrumentation/garmin196/popup_status",20);
        setprop("/instrumentation/garmin196/dto_display/ligne_select","");
        init_dto_display();
        display_dto_recent();
        return;
      }
      if(popup_status==11){
        var x_char = getprop("/instrumentation/garmin196/dto_display/x_char");
        if(x_char<20){
          setprop("/instrumentation/garmin196/dto_display/x_char",x_char+1);
          display_dto_search();
        }
        return;
      }
      if(popup_status==20){
        setprop("/instrumentation/garmin196/popup_status",30);
        setprop("/instrumentation/garmin196/dto_display/ligne_select","");
        init_dto_display();
        display_dto_user();
        return;
      }
      if(popup_status==30){
        setprop("/instrumentation/garmin196/popup_status",10);
        setprop("/instrumentation/garmin196/dto_display/ligne_select","Press Enter to search");
        init_dto_display();
        setprop("/instrumentation/garmin196/dto_display/x_char",0);
        setprop("/instrumentation/garmin196/dto_display/y_char",0);
        return;
      }
      
      if(popup_status==40){
        setprop("/instrumentation/garmin196/popup_status",50);
        display_nrst("vor");
        return;
      }
      
      if(popup_status==50){
        setprop("/instrumentation/garmin196/popup_status",60);
        display_nrst("ndb");
        return;
      }
      
      if(popup_status==60){
        setprop("/instrumentation/garmin196/popup_status",70);
        display_nrst("fix");
        return;
      }
      
      if(popup_status==70){
        setprop("/instrumentation/garmin196/popup_status",80);
        display_nrst("wpt");
        return;
      }
      
      if(popup_status==80){
        setprop("/instrumentation/garmin196/popup_status",40);
        display_nrst("airport");
        return;
      }
      
      var status = getprop("/instrumentation/garmin196/status");
      
      ##menu routes
      if(status==121){
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
        if(getprop("/instrumentation/garmin196/routes/route["~no_ligne~"]/name")!=nil){
          load_flight_plan(no_ligne);
          affiche_fpl_loaded();
        }
        return;
      }
      
      if(status==122){
        var no_ligne = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
        var no_ligne_detail = getprop("/instrumentation/garmin196/menu_routes/no_ligne_detail");
        if(getprop("/instrumentation/garmin196/routes/route["~no_ligne~"]/wpts/wpt["~no_ligne_detail~"]/id")!=nil){
          jump_to_waypoint(no_ligne_detail);
          affiche_waypoint_jump();
        }
        return;
      }
      
      if(status==123){
        var x_char = getprop("/instrumentation/garmin196/menu_routes/search/x_char");
        if(x_char<20){
          setprop("/instrumentation/garmin196/menu_routes/search/x_char",x_char+1);
          display_route_waypoint_search();
        }
        return;
      }
      
      ##menu points
      if(status==132){
        var x_char = getprop("/instrumentation/garmin196/menu_points/x_char");
        if(x_char<20){
          setprop("/instrumentation/garmin196/menu_points/x_char",x_char+1);
          display_menu_points();
        }
        return;
      }
      
      ##menu aircraft
      if(status==142){
        var x_char = getprop("/instrumentation/garmin196/menu_aircraft/x_char");
        if(x_char<20){
          setprop("/instrumentation/garmin196/menu_aircraft/x_char",x_char+1);
          display_menu_aircraft_name();
        }
        return;
      }
      
      if(status==170){
        setprop("/instrumentation/garmin196/status",175);
      }
    
    }
  }
}

##recalc speed to display
var change_speed_display = func{
  var max_speed = getprop("/instrumentation/garmin196/max-speed");
  var speed = getprop("/instrumentation/gps/indicated-ground-speed-kt");
  setprop("/instrumentation/garmin196/speed-display",315*speed/max_speed);
}

##calcul du turn rate
var calcul_turn_rate = func(dt){
  if(last_bearing==-1){
    last_bearing = getprop("/instrumentation/gps/magnetic-bug-error-deg");
  }
  bearing = getprop("/instrumentation/gps/magnetic-bug-error-deg");
  
  var turn_rate = abs(bearing - last_bearing);
  if(turn_rate>180){
    turn_rate = 360 - turn_rate;
   }
  var sgn = 1;
  if(bearing - last_bearing<0){
    sgn = -1;
  }
  turn_rate = turn_rate/dt;
  if(turn_rate<10){##pour enlever les valeurs aberentes
    props.globals.getNode("/instrumentation/garmin196/turn-rate",1).setDoubleValue(sgn*turn_rate);
  }
  last_bearing = bearing;
}

var change_wpt_id = func{
  if(getprop("/instrumentation/gps/mode")!=nil and getprop("/autopilot/route-manager/wp[0]/id")!=""){
    props.global.getNode("/instrumentation/garmin196/panel-wpt-id").alias("/autopilot/route-manager/wp[0]/id");
  }else{
    setprop("/instrumentation/garmin196/panel-wpt-id",getprop("/instrumentation/garmin196/panel-wpt-dto-id"));
  }
}
setlistener("/instrumentation/gps/mode",change_wpt_id);

var change_position_wpt_bug = func{
  var wpt_bearing = getprop("/instrumentation/gps/wp/wp[1]/bearing-mag-deg");
  var aircraft_bearing = getprop("/instrumentation/gps/indicated-track-magnetic-deg");
  
  var diff = wpt_bearing - aircraft_bearing;
  setprop("/instrumentation/garmin196/position-wpt-bearing",diff);
  setprop("/instrumentation/garmin196/panel-wpt-bearing",diff);
  
  var nb_wpt = getprop("/autopilot/route-manager/route/num");
  var no_wpt = getprop("/autopilot/route-manager/current-wp");
  var panel_course = 0;
  if(no_wpt>0 and no_wpt<(nb_wpt-1)){
    panel_course = getprop("/autopilot/route-manager/route/wp["~(no_wpt-1)~"]/leg-bearing-true-deg");
  }else{
    panel_course = getprop("/instrumentation/gps/wp/wp[1]/bearing-mag-deg");
  }
  panel_course = panel_course - aircraft_bearing;
  var panel_deflexion = diff - panel_course;

  if(math.cos(diff*math.pi/180)>0){
    setprop("/instrumentation/garmin196/panel-neddle-to-flag",1);
  }else{
    setprop("/instrumentation/garmin196/panel-neddle-to-flag",0);
  }
  if(panel_deflexion>10){
    panel_deflexion = 10;
  }
  if(panel_deflexion<-10){
    panel_deflexion = -10;
  }
  
  setprop("/instrumentation/garmin196/panel-neddle-course",panel_course);
  setprop("/instrumentation/garmin196/panel-neddle-deflexion",panel_deflexion);
  
  ##vnav
  var altitude_id = getprop("/instrumentation/garmin196/vnav/altitude-m");
  var latitude_id = getprop("/instrumentation/garmin196/vnav/latitude");
  var longitude_id = getprop("/instrumentation/garmin196/vnav/longitude");
  if(altitude_id!=nil and latitude_id!=nil and longitude_id!=nil and latitude_id!=-9999 and longitude_id!=-9999 and getprop("/instrumentation/garmin196/params/vnav-indicator")==1){
    var altitude_aircraft = getprop("/instrumentation/gps/indicated-altitude-ft") * 0.3048;
    var latitude_aircraft = getprop("/instrumentation/gps/indicated-latitude-deg");
    var longitude_aircraft = getprop("/instrumentation/gps/indicated-longitude-deg");
    
    var coord_id = geo.Coord.new().set_latlon(latitude_id,longitude_id);
    var coord_aircraft = geo.Coord.new().set_latlon(latitude_aircraft,longitude_aircraft);
    var distance = coord_aircraft.distance_to(coord_id);## en metres
    var diff_altitude = altitude_aircraft - altitude_id;
    var angle = math.atan2(diff_altitude,distance)*180/math.pi;
    #setprop("/instrumentation/garmin196/vnav/angle",angle);
    var deviation = angle - 3;#pente ideale = 3 degres
    if(deviation>10){
      deviation = 10;
    }
    if(deviation<-10){
      deviation = -10;
    }
    setprop("/instrumentation/garmin196/vnav/deviation",deviation);
  }else{
    setprop("/instrumentation/garmin196/vnav/deviation",0);
  }
}

var update_map = func{
  ##protection, une seule recherche gps a la fois, la popup devient prioritaire
  var popup_status = getprop("/instrumentation/garmin196/popup_status");
  if(popup_status<10 or popup_status>99){
    var max_plots = 25;
    var offset_mul = 0.034;
    var symbol_map_range = getprop("/instrumentation/garmin196/map-range") * 8;
    var plots = [];
    var type_symbol = [ "airport" , "vor" , "ndb" , "fix" , "twn" , "wpt"];
    
    for(var i=0;i<size(type_symbol);i=i+1){
      if(getprop("/instrumentation/garmin196/symbols/params/"~type_symbol[i])==1){
        if(type_symbol[i]=="twn" or type_symbol[i]=="wpt"){
          props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(max_plots*8 + 1);
        }else{
          props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(max_plots*4 + 1);
        }
        props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
        props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
        var type = type_symbol[i];
        if(type == "twn"){
          type = "wpt";
        }
        setprop("/instrumentation/gps/scratch/type", type);
        setprop("/instrumentation/gps/command", "nearest");
        
        while (getprop('/instrumentation/gps/scratch/has-next')) {
          var id = getprop('/instrumentation/gps/scratch/ident');
          var range = getprop('/instrumentation/gps/scratch/distance-nm') / symbol_map_range; 
          var bearing = 360 - getprop("/instrumentation/gps/indicated-track-magnetic-deg") + getprop('/instrumentation/gps/scratch/mag-bearing-deg');
          if(bearing<0){
            bearing = bearing + 360;
          }
          
          if(bearing>360){
            bearing = bearing - 360;
          }
          
          if(i==1){##vor
            id = id ~ " " ~ sprintf("%2.2f",getprop('/instrumentation/gps/scratch/frequency-mhz'));
          }
          
          if(i==2){##ndb
            id = id ~ " " ~ sprintf("%2.1f",getprop('/instrumentation/gps/scratch/frequency-khz'));
          }
          
          var plot = { id: id,bearing: bearing,type: i,range: range};
          if(range<=1){
            if(i<4){
              append(plots,plot);
            }elsif(i==4 and substr(id,size(id)-6)=="WPTTWN"){
              append(plots,plot);
            }elsif(i==5 and substr(id,size(id)-6)=="WPTUSR"){
              append(plots,plot);
            }
          }else{
            break;
          }
          setprop("/instrumentation/gps/command", "next");
        }
      }
    }

    var plots_sorted = sort (plots, func (a,b) a.range - b.range);
    
    ##suppression des points les plus proches si il y en a de trop
    var filtrage = getprop("/instrumentation/garmin196/params/filtrage");
    if(filtrage==1){
      var nb_points = 0;
      for(var i=0;i<size(plots_sorted);i=i+1){
        if(plots_sorted[i].range<0.25){#un quart d'ecran
          nb_points = nb_points + 1;
        }else{
          break;
        }
      }
      if(nb_points>5){
        plots_sorted = subvec(plots_sorted,nb_points);
      }
    }
    
    var nb_plots = max_plots;
    if(nb_plots>size(plots_sorted)){
      nb_plots = size(plots_sorted);
    }
    for(var i=0;i<nb_plots;i=i+1){
      if(plots_sorted[i].type==4 or plots_sorted[i].type==5){##town or waypoint
        var type_wpt = substr(plots_sorted[i].id,size(plots_sorted[i].id)-6);
        if(type_wpt=="WPTTWN"){#cities
          plots_sorted[i].id = substr(plots_sorted[i].id,0,size(plots_sorted[i].id)-8);
        }elsif(type_wpt=="WPTUSR"){#wpt user
          plots_sorted[i].id = substr(plots_sorted[i].id,0,size(plots_sorted[i].id)-6);
          plots_sorted[i].type = 5;
        }
      }
      
      props.globals.getNode("/instrumentation/garmin196/symbols/symbol["~i~"]/id",1).setValue(plots_sorted[i].id);
      props.globals.getNode("/instrumentation/garmin196/symbols/symbol["~i~"]/type",1).setValue(plots_sorted[i].type);
      
      ##calcul des coordonnees
      var x_wp = math.cos(plots_sorted[i].bearing*math.pi/180) * plots_sorted[i].range * offset_mul;
      var y_wp = math.sin(plots_sorted[i].bearing*math.pi/180) * plots_sorted[i].range * offset_mul;
      props.globals.getNode("/instrumentation/garmin196/symbols/symbol["~i~"]/x",1).setDoubleValue(x_wp);
      props.globals.getNode("/instrumentation/garmin196/symbols/symbol["~i~"]/y",1).setDoubleValue(y_wp);

      if(x_wp<0.026 and x_wp>-0.026 and y_wp<0.0323 and y_wp>-0.0323){##si on est dans l'ecran, on affiche
        props.globals.getNode("/instrumentation/garmin196/symbols/symbol["~i~"]/visible",1).setBoolValue(1);
      }else{
        props.globals.getNode("/instrumentation/garmin196/symbols/symbol["~i~"]/visible",1).setBoolValue(0);
      }
    }

    for(var i=nb_plots;i<max_plots;i=i+1){
      props.globals.getNode("/instrumentation/garmin196/symbols/symbol["~i~"]/visible",1).setIntValue(0);
    }
    
    ##wpt path calculations 
    var offset_range_wp_direct = 0.19;
    var range_wp_direct = offset_range_wp_direct * getprop("/instrumentation/gps/wp/wp[1]/distance-nm") / symbol_map_range;
    
    var bearing_wp_direct = getprop("/instrumentation/garmin196/panel-wpt-bearing");
    var x_range_wp_direct = math.abs(math.cos(bearing_wp_direct*math.pi/180) * range_wp_direct); #max 0.15
    if(x_range_wp_direct>0.15){
      range_wp_direct = math.abs(0.15 / math.cos(bearing_wp_direct*math.pi/180));
    }
    var y_range_wp_direct = math.abs(math.sin(bearing_wp_direct*math.pi/180) * range_wp_direct); #max 0.18
    if(y_range_wp_direct>0.18){
      range_wp_direct = math.abs(0.18 / math.sin(bearing_wp_direct*math.pi/180));
    }    
    setprop("/instrumentation/garmin196/symbols/paths/range_wp_direct/range",range_wp_direct);

    if(getprop("/instrumentation/garmin196/panel-wpt-id")!=nil and getprop("/instrumentation/garmin196/panel-wpt-id")!="------"){
      setprop("/instrumentation/garmin196/symbols/paths/range_wp_direct/visible",1);
    }else{
      setprop("/instrumentation/garmin196/symbols/paths/range_wp_direct/visible",0);
    }
    
    ##flight plan calculation
    var nb_path = getprop("/autopilot/route-manager/route/num");
    if(nb_path>9){
      nb_path = 9;
    }
    
    var aircraft_bearing = getprop("/instrumentation/gps/indicated-track-magnetic-deg");
    for(var i=0;i<(nb_path-1);i=i+1){
      var id = getprop("/autopilot/route-manager/route/wp["~i~"]/id");

      setprop("/instrumentation/gps/scratch/max-results",1);
      setprop("/instrumentation/gps/scratch/longitude-deg",-9999);
      setprop("/instrumentation/gps/scratch/latitude-deg",-9999);
      setprop("/instrumentation/gps/scratch/type", "");
      setprop("/instrumentation/gps/scratch/query", id);
      setprop("/instrumentation/gps/command", "search");
      
      if(getprop("/instrumentation/gps/scratch/valid")==0 or getprop("/instrumentation/gps/scratch/ident")!=id){
        setprop("/instrumentation/gps/scratch/type", "fix");
        setprop("/instrumentation/gps/scratch/query", id);
        setprop("/instrumentation/gps/command", "search");
      }
      
      var distance_to_wp = getprop("/instrumentation/gps/scratch/distance-nm") / symbol_map_range;
      var  bearing_to_wp = 360 - getprop("/instrumentation/gps/indicated-track-magnetic-deg") + getprop("/instrumentation/gps/scratch/mag-bearing-deg");

      var x_wp_fpl = math.cos(bearing_to_wp*math.pi/180) * distance_to_wp * offset_mul;
      var y_wp_fpl = math.sin(bearing_to_wp*math.pi/180) * distance_to_wp * offset_mul;
      
      setprop("/instrumentation/garmin196/symbols/paths/range_wp_"~i~"_"~(i+1)~"/x",x_wp_fpl);
      setprop("/instrumentation/garmin196/symbols/paths/range_wp_"~i~"_"~(i+1)~"/y",y_wp_fpl);

      var wp_bearing = 360 - getprop("/instrumentation/gps/indicated-track-true-deg") + getprop("/autopilot/route-manager/route/wp["~i~"]/leg-bearing-true-deg");
      var wp_distance = offset_range_wp_direct * getprop("/autopilot/route-manager/route/wp["~i~"]/leg-distance-nm") / symbol_map_range;
      
      var x_range_wp =(math.cos(wp_bearing*math.pi/180) * wp_distance) + ((x_wp_fpl/0.026)*0.15); #max 0.15
      if(math.abs(x_range_wp)>0.15){
        wp_distance = math.abs(((0.15*math.sgn(math.cos(wp_bearing*math.pi/180))) - ((x_wp_fpl/0.026)*0.15))/math.cos(wp_bearing*math.pi/180));
      }
      
      var y_range_wp =(math.sin(wp_bearing*math.pi/180) * wp_distance) + ((y_wp_fpl/0.0323)*0.18); #max 0.18
      if(math.abs(y_range_wp)>0.18){
        wp_distance = math.abs(((0.18*math.sgn(math.sin(wp_bearing*math.pi/180))) - ((y_wp_fpl/0.0323)*0.18))/math.sin(wp_bearing*math.pi/180));
      }
      
      setprop("/instrumentation/garmin196/symbols/paths/range_wp_"~i~"_"~(i+1)~"/range",wp_distance);
      setprop("/instrumentation/garmin196/symbols/paths/range_wp_"~i~"_"~(i+1)~"/bearing",wp_bearing);
      
      if(x_wp_fpl<0.026 and x_wp_fpl>-0.026 and y_wp_fpl<0.0323 and y_wp_fpl>-0.0323){##si on est dans l'ecran, on affiche
        setprop("/instrumentation/garmin196/symbols/paths/range_wp_"~i~"_"~(i+1)~"/visible",1);
      }else{
        setprop("/instrumentation/garmin196/symbols/paths/range_wp_"~i~"_"~(i+1)~"/visible",0);
      }
    }
    for(var i=nb_path;i<9;i=i+1){
      setprop("/instrumentation/garmin196/symbols/paths/range_wp_"~i~"_"~(i+1)~"/visible",0);
    }
    
  }
  if(getprop("/instrumentation/garmin196/serviceable")==1 and getprop("/instrumentation/garmin196/status")==10){
    settimer(update_map,1);
  }
}

var display_dto_recent = func{
  var waypoints = props.globals.getNode("/instrumentation/garmin196/waypoints/recent/",1);
  var i = 0;
  foreach (var e; waypoints.getChildren("wpt")) {
    var id = e.getChild("id").getValue();
    var type = e.getChild("type").getValue();
    var ligne = id;
    if(type=="wpt"){
      var type_wpt = substr(id,size(id)-6);
      if(type_wpt=="WPTTWN"){#cities
        ligne = substr(id,0,size(id)-8);
        ligne = substr(ligne,0,15);
      }elsif(type_wpt=="WPTUSR"){#wpt user
        ligne = substr(id,0,size(id)-6);
      }
    }
    
    ligne = ligne ~ " " ~ type;
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,15-size(ligne));
    
    props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(1);
    props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
    props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
    setprop("/instrumentation/gps/scratch/type", type);
    setprop("/instrumentation/gps/scratch/query", id);
    setprop("/instrumentation/gps/command", "search");
    
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var  bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf(" %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf(" %3.1fkm",range*1.852);
    }
    
    if(i==0){
      setprop("/instrumentation/garmin196/dto_display/ligne_select",ligne);
      props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~i~"]/selected",1).setBoolValue(1);
    }else{
      props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~i~"]/selected",1).setBoolValue(0);
    }
    setprop("/instrumentation/garmin196/dto_display/ligne["~i~"]/texte",ligne);
    setprop("/instrumentation/garmin196/dto_display/ligne["~i~"]/id",id);
    setprop("/instrumentation/garmin196/dto_display/ligne["~i~"]/type",type);
    i=i+1;
  }
  for(var j=i;j<5;j=j+1){
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/texte","");
    props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~j~"]/selected",1).setBoolValue(0);
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/id","");
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/type","");
  }
  setprop("/instrumentation/garmin196/dto_display/no_ligne_selected",0);
  setprop("/instrumentation/garmin196/dto_display/max_ligne_selected",i-1);
  if(i==0){
    setprop("/instrumentation/garmin196/dto_display/ligne_select","");
  }
}

var display_dto_user = func{
  var waypoints = props.globals.getNode("/instrumentation/garmin196/waypoints/user/",1);
  var i = 0;
  foreach (var e; waypoints.getChildren("wpt")) {
    var id = e.getChild("id").getValue()~"WPTUSR";
    var type = "wpt";
    var ligne = substr(id,0,size(id)-6);
    ligne = substr(ligne,0,14);  
    
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,14-size(ligne));
    
    props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(1);
    props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
    props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
    setprop("/instrumentation/gps/scratch/type", type);
    setprop("/instrumentation/gps/scratch/query", id);
    setprop("/instrumentation/gps/command", "search");
    
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var  bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf(" %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf(" %3.1fkm",range*1.852);
    }
    
    if(i==0){
      setprop("/instrumentation/garmin196/dto_display/ligne_select",ligne);
      props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~i~"]/selected",1).setBoolValue(1);
    }else{
      props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~i~"]/selected",1).setBoolValue(0);
    }
    setprop("/instrumentation/garmin196/dto_display/ligne["~i~"]/texte",ligne);
    setprop("/instrumentation/garmin196/dto_display/ligne["~i~"]/id",id);
    setprop("/instrumentation/garmin196/dto_display/ligne["~i~"]/type",type);
    i=i+1;
  }
  for(var j=i;j<5;j=j+1){
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/texte","");
    props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~j~"]/selected",1).setBoolValue(0);
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/id","");
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/type","");
  }
  setprop("/instrumentation/garmin196/dto_display/no_ligne_selected",0);
  setprop("/instrumentation/garmin196/dto_display/max_ligne_selected",i-1);
  if(i==0){
    setprop("/instrumentation/garmin196/dto_display/ligne_select","");
  }
}

var affectation_waypoint = func(id){
  setprop("/autopilot/route-manager/input","@CLEAR");
  setprop("/autopilot/route-manager/input","@POP");
  setprop("/autopilot/route-manager/input","@insert0:"~id);
  setprop("/autopilot/route-manager/input","@JUMP0");
  setprop("/autopilot/route-manager/input","@ACTIVATE");
}

var display_dto_search = func{
  var ligne_selected = getprop("/instrumentation/garmin196/dto_display/ligne_select");
  var x_char = props.globals.getNode("/instrumentation/garmin196/dto_display/x_char").getValue();
  ligne_selected = substr(ligne_selected,0,x_char);
  ligne_selected = ligne_selected ~ tab_chiffres_lettres[getprop("/instrumentation/garmin196/dto_display/y_char")];
  setprop("/instrumentation/garmin196/dto_display/ligne_select",ligne_selected);

  var plots = [];
  ##recherche gps globale
  props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(5);
  props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(0);
  props.globals.getNode("/instrumentation/gps/scratch/query",1).setValue(ligne_selected);
  props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("");
  
  setprop("/instrumentation/gps/command", "search");
  var i=0;
  var flag_continue = getprop("/instrumentation/gps/scratch/valid");
  while (flag_continue and i<5) {
    var id = getprop("/instrumentation/gps/scratch/ident");
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    var type = getprop("/instrumentation/gps/scratch/type");
    
    var ligne = id;
    if(type=="waypoint"){
      type = "wpt";
      var type_wpt = substr(id,size(id)-6);
      if(type_wpt=="WPTTWN"){#cities
        ligne = substr(id,0,size(id)-8);
      }elsif(type_wpt=="WPTUSR"){#wpt user
        ligne = substr(id,0,size(id)-6);
      }
    }
    
    ligne = ligne ~ " " ~ type;
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,16-size(ligne));
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf("  %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf("  %3.1fkm",range*1.852);
    }
    var popup_status = getprop("/instrumentation/garmin196/popup_status");
    
    
    var plot = { id: id,texte: ligne,type: type};
    append(plots,plot);
    
    i=i+1;
    setprop("/instrumentation/gps/command", "next");
    flag_continue = getprop("/instrumentation/gps/scratch/has-next");
  }
  
  ##recherche gps fix
  props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(5);
  props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(0);
  props.globals.getNode("/instrumentation/gps/scratch/query",1).setValue(ligne_selected);
  props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("fix");
  
  setprop("/instrumentation/gps/command", "search");
  i=0;
  flag_continue = getprop("/instrumentation/gps/scratch/valid");
  while (flag_continue and i<5) {
    var id = getprop("/instrumentation/gps/scratch/ident");
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    var type = getprop("/instrumentation/gps/scratch/type");
    
    var ligne = id ~ " " ~ type;
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,16-size(ligne));
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf("  %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf("  %3.1fkm",range*1.852);
    }
    var popup_status = getprop("/instrumentation/garmin196/popup_status");
    
    
    var plot = { id: id,texte: ligne,type: type};
    append(plots,plot);
    
    i=i+1;
    setprop("/instrumentation/gps/command", "next");
    flag_continue = getprop("/instrumentation/gps/scratch/has-next");
  }
  
  ##recherche gps vor
  props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(5);
  props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(0);
  props.globals.getNode("/instrumentation/gps/scratch/query",1).setValue(ligne_selected);
  props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("vor");
  
  setprop("/instrumentation/gps/command", "search");
  i=0;
  flag_continue = getprop("/instrumentation/gps/scratch/valid");
  while (flag_continue and i<5) {
    var id = getprop("/instrumentation/gps/scratch/ident");
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    var type = getprop("/instrumentation/gps/scratch/type");
    
    var ligne = id ~ " vor";
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,16-size(ligne));
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf("  %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf("  %3.1fkm",range*1.852);
    }
    var popup_status = getprop("/instrumentation/garmin196/popup_status");
    
    
    var plot = { id: id,texte: ligne,type: type};
    append(plots,plot);
    
    i=i+1;
    setprop("/instrumentation/gps/command", "next");
    flag_continue = getprop("/instrumentation/gps/scratch/has-next");
  }
  
  ##recherche gps ndb
  props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(5);
  props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(0);
  props.globals.getNode("/instrumentation/gps/scratch/query",1).setValue(ligne_selected);
  props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("ndb");
  
  setprop("/instrumentation/gps/command", "search");
  i=0;
  flag_continue = getprop("/instrumentation/gps/scratch/valid");
  while (flag_continue and i<5) {
    var id = getprop("/instrumentation/gps/scratch/ident");
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    var type = getprop("/instrumentation/gps/scratch/type");
    
    var ligne = id ~ " ndb";
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,16-size(ligne));
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf("  %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf("  %3.1fkm",range*1.852);
    }
    var popup_status = getprop("/instrumentation/garmin196/popup_status");
    
    
    var plot = { id: id,texte: ligne,type: type};
    append(plots,plot);
    
    i=i+1;
    setprop("/instrumentation/gps/command", "next");
    flag_continue = getprop("/instrumentation/gps/scratch/has-next");
  }
    
  var plots_sorted = sort (plots, func (a,b) cmp (a.id, b.id));
  var nb_plots = size(plots_sorted);
  if(nb_plots>5){
    nb_plots = 5;
  }
  for(var j=0;j<nb_plots;j=j+1){
    if(i==0 and popup_status!=10 and popup_status!=11){
      props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~i~"]/selected",1).setBoolValue(1);
    }else{
      props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~i~"]/selected",1).setBoolValue(0);
    }
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/texte",plots_sorted[j].texte);
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/id",plots_sorted[j].id);
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/type",plots_sorted[j].type);
  }

  for(var j=nb_plots;j<5;j=j+1){
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/texte","");
    props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~j~"]/selected",1).setBoolValue(0);
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/id","");
    setprop("/instrumentation/garmin196/dto_display/ligne["~j~"]/type","");
  }
  setprop("/instrumentation/garmin196/dto_display/no_ligne_selected",0);
  setprop("/instrumentation/garmin196/dto_display/max_ligne_selected",nb_plots-1);
}

var searchLastChar = func(chaine, char){
  var result = -1;
  var char_a_tester = substr(chaine,char,1);
  for(var i=0;i<size(tab_chiffres_lettres);i=i+1){
    if(tab_chiffres_lettres[i]==char_a_tester){
      result = i;
      break;
    }
  }
  return result;
}

var init_dto_display = func{
  for(var i=0;i<5;i=i+1){
    setprop("/instrumentation/garmin196/dto_display/ligne["~i~"]/texte","");
    props.globals.getNode("/instrumentation/garmin196/dto_display/ligne["~i~"]/selected",1).setBoolValue(0);
    setprop("/instrumentation/garmin196/dto_display/ligne["~i~"]/id","");
    setprop("/instrumentation/garmin196/dto_display/ligne["~i~"]/type","");
  }
}

var init_nrst_display = func{
  for(var i=0;i<5;i=i+1){
    setprop("/instrumentation/garmin196/nrst_display/ligne["~i~"]/texte","");
    props.globals.getNode("/instrumentation/garmin196/nrst_display/ligne["~i~"]/selected",1).setBoolValue(0);
    setprop("/instrumentation/garmin196/nrst_display/ligne["~i~"]/id","");
    setprop("/instrumentation/garmin196/nrst_display/ligne["~i~"]/type","");
  }
}

var display_nrst = func(type){
  if(type=="wpt"){
    props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(25);
    props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
    props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
    #props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(1);
    props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue(type);
    setprop("/instrumentation/gps/command", "nearest");
    var i=0;
    var flag_continue = getprop("/instrumentation/gps/scratch/valid");
    while (flag_continue and i<5) {
      var id = getprop("/instrumentation/gps/scratch/ident");
      var range = getprop("/instrumentation/gps/scratch/distance-nm");
      var  bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");

      var type_wpt = substr(id,size(id)-6);
      if(type_wpt=="WPTTWN"){
        var ligne = substr(id,0,size(id)-8);
      }elsif(type_wpt=="WPTUSR"){
        var ligne = substr(id,0,size(id)-6);
      }
      ligne = substr(ligne,0,18);
      var ligne_spaces = "                              ";
      ligne_spaces = substr(ligne_spaces,0,18-size(ligne));
      ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
      if(getprop("/instrumentation/garmin196/params/units/distance")==1){
        ligne = ligne ~sprintf(" %3.1fnm",range);
      }else{
        ligne = ligne ~sprintf(" %3.1fkm",range*1.852);
      }
      
      if(i==0){
        setprop("/instrumentation/garmin196/nrst_display/ligne_select",ligne);
        props.globals.getNode("/instrumentation/garmin196/nrst_display/ligne["~i~"]/selected",1).setBoolValue(1);
      }else{
        props.globals.getNode("/instrumentation/garmin196/nrst_display/ligne["~i~"]/selected",1).setBoolValue(0);
      }
      setprop("/instrumentation/garmin196/nrst_display/ligne["~i~"]/texte",ligne);
      setprop("/instrumentation/garmin196/nrst_display/ligne["~i~"]/id",id);
      setprop("/instrumentation/garmin196/nrst_display/ligne["~i~"]/type",type);
      i=i+1;

      setprop("/instrumentation/gps/command", "next");
      flag_continue = getprop("/instrumentation/gps/scratch/has-next");
    }
    setprop("/instrumentation/garmin196/nrst_display/no_ligne_selected",0);
    setprop("/instrumentation/garmin196/nrst_display/max_ligne_selected",(i-1));
        
  }else{
    props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(6);
    props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
    props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
    #props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(1);
    props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue(type);
    props.globals.getNode("/instrumentation/gps/scratch").removeChildren("runways");
    setprop("/instrumentation/gps/command", "nearest");
    var i=0;
    var flag_continue = getprop("/instrumentation/gps/scratch/valid");
    while (flag_continue and i<5) {
      var id = getprop("/instrumentation/gps/scratch/ident");
      var ligne = id;
      var range = getprop("/instrumentation/gps/scratch/distance-nm");
      var  bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
      var ligne_spaces = "                              ";
      ligne_spaces = substr(ligne_spaces,0,6-size(ligne));
      ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
      if(getprop("/instrumentation/garmin196/params/units/distance")==1){
        ligne = ligne ~sprintf(" %3.1fnm",range);
      }else{
        ligne = ligne ~sprintf(" %3.1fkm",range*1.852);
      }
      if(type=="airport"){
        var runways = props.globals.getNode("/instrumentation/gps/scratch",1);
        var max_length = 0;
        foreach (var e; runways.getChildren("runways")) {
          var runway_length = e.getChild("length-ft").getValue();
          if(runway_length>max_length){
            max_length = runway_length;
          }
        }
        if(getprop("/instrumentation/garmin196/params/units/distance")==1){
          ligne = ligne ~ " " ~ sprintf("%4.0fft",max_length);
        }else{
          ligne = ligne ~ " " ~ sprintf("%4.0fm",max_length*0.3048);
        }
        
        var radio = airportinfo(id).comms('ATIS');
        if(size(radio) > 0){
          ligne = ligne ~ sprintf(" %3.2f",radio[0]);
        }
      }elsif(type=="vor"){
        ligne = ligne ~ " " ~ sprintf("%2.2f",getprop('/instrumentation/gps/scratch/frequency-mhz'));
      }elsif(type=="ndb"){
        ligne = ligne ~ " " ~ sprintf("%2.1f",getprop('/instrumentation/gps/scratch/frequency-khz'));
      }
      if(i==0){
        setprop("/instrumentation/garmin196/nrst_display/ligne_select",ligne);
        props.globals.getNode("/instrumentation/garmin196/nrst_display/ligne["~i~"]/selected",1).setBoolValue(1);
      }else{
        props.globals.getNode("/instrumentation/garmin196/nrst_display/ligne["~i~"]/selected",1).setBoolValue(0);
      }
      setprop("/instrumentation/garmin196/nrst_display/ligne["~i~"]/texte",ligne);
      setprop("/instrumentation/garmin196/nrst_display/ligne["~i~"]/id",id);
      setprop("/instrumentation/garmin196/nrst_display/ligne["~i~"]/type",type);
      i=i+1;
      
      props.globals.getNode("/instrumentation/gps/scratch").removeChildren("runways");
      setprop("/instrumentation/gps/command", "next");
      flag_continue = getprop("/instrumentation/gps/scratch/has-next");
    }
    setprop("/instrumentation/garmin196/nrst_display/no_ligne_selected",0);
    setprop("/instrumentation/garmin196/nrst_display/max_ligne_selected",(i-1));
  }
}

var load_cities = func{
  print("Garmin 196 loading cities");
  fgcommand("loadxml", props.Node.new({ filename: getprop("/sim/fg-root")~"/Aircraft/Instruments-3d/garmin196/cities.xml", targetnode: "/instrumentation/garmin196/cities" }));
  var waypoints = props.globals.getNode("/instrumentation/garmin196/cities/waypoints",1);
  foreach (var e; waypoints.getChildren("waypoint")) {
    var id = e.getChild("id").getValue();
    var latitude = e.getChild("latitude").getValue();
    var longitude = e.getChild("longitude").getValue();
    
    props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(longitude);
    props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(latitude);
    props.globals.getNode("/instrumentation/gps/scratch/ident",1).setValue(id);
    #setprop("/instrumentation/gps/command","define-user-wpt");
  }
  props.globals.getNode("/instrumentation/garmin196").removeChildren("cities");
  
  
  print("Garmin 196 loading cities done");
}

var update_wp_id_display=func{
  var id=getprop("/autopilot/route-manager/wp[0]/id");
  if(size(id)>6){
    var type_wpt=substr(id,size(id)-6);
    if(type_wpt=="WPTTWN"){#cities
      id=substr(id,0,size(id)-8);
      id=substr(id,0,13);
    }elsif(type_wpt=="WPTUSR"){#wpt user
      id=substr(id,0,size(id)-6);
    }
  }
  setprop("/instrumentation/garmin196/panel-wpt-id",id);
  setprop("/instrumentation/garmin196/position-wpt-id",id);
  
  ##stockage des coordonnees pour la vnav
  setprop("/instrumentation/gps/scratch/max-results",1);
  setprop("/instrumentation/gps/scratch/longitude-deg",-9999);
  setprop("/instrumentation/gps/scratch/latitude-deg",-9999);
  setprop("/instrumentation/gps/scratch/type", "");
  setprop("/instrumentation/gps/scratch/query", id);
  setprop("/instrumentation/gps/command", "search");
      
  if(getprop("/instrumentation/gps/scratch/type")=="airport"){
    ##stockage des coordonnees du waypoint pour vnav
    props.globals.getNode("/instrumentation/garmin196/vnav/longitude",1).setDoubleValue(getprop("/instrumentation/gps/scratch/longitude-deg"));
    props.globals.getNode("/instrumentation/garmin196/vnav/latitude",1).setDoubleValue(getprop("/instrumentation/gps/scratch/latitude-deg"));
    props.globals.getNode("/instrumentation/garmin196/vnav/altitude-m",1).setDoubleValue(getprop("/instrumentation/gps/scratch/altitude-ft") * 0.3048);
    props.globals.getNode("/instrumentation/garmin196/vnav/visible",1).setBoolValue(1);
  }else{
    props.globals.getNode("/instrumentation/garmin196/vnav/visible",1).setBoolValue(0);
  }

}
setlistener("/autopilot/route-manager/wp[0]/id",update_wp_id_display);

var init_list_aircraft = func{
  var aircrafts = props.globals.getNode("/instrumentation/garmin196/params/aircrafts",1);
  var i = 0;
  foreach (var e; aircrafts.getChildren("aircraft")) {
    setprop("/instrumentation/garmin196/menu_aircraft/aircraft["~i~"]/texte",e.getChild("name").getValue());
    i=i+1;
  }
  
  for(var j=i;j<6;j=j+1){
    setprop("/instrumentation/garmin196/menu_aircraft/aircraft["~j~"]/texte","");
  }
  
  if(i<6){
    setprop("/instrumentation/garmin196/menu_aircraft/aircraft["~i~"]/texte","ENTER TO ADD AIRCRAFT");
  }else{
    i=5;
  }
  setprop("/instrumentation/garmin196/menu_aircraft/max_no_ligne",i);
}

var init_new_aircraft = func(no_aircraft){
  props.globals.getNode("/instrumentation/garmin196/params/aircrafts/aircraft["~no_aircraft~"]/name", 1).setValue("AIRCRAFT");
  props.globals.getNode("/instrumentation/garmin196/params/aircrafts/aircraft["~no_aircraft~"]/max-speed", 1).setIntValue(150);
  props.globals.getNode("/instrumentation/garmin196/params/aircrafts/aircraft["~no_aircraft~"]/cruise-speed", 1).setIntValue(120);
  props.globals.getNode("/instrumentation/garmin196/params/aircrafts/aircraft["~no_aircraft~"]/fuel-flow", 1).setIntValue(5);
}

var delete_aircraft = func(no_aircraft){
  for(var i=no_aircraft+1;i<6;i=i+1){
    if(getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/name")!=nil){
      setprop("/instrumentation/garmin196/params/aircrafts/aircraft["~(i-1)~"]/name",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/name"));
      setprop("/instrumentation/garmin196/params/aircrafts/aircraft["~(i-1)~"]/max-speed",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/max-speed"));
      setprop("/instrumentation/garmin196/params/aircrafts/aircraft["~(i-1)~"]/cruise-speed",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/cruise-speed"));
      setprop("/instrumentation/garmin196/params/aircrafts/aircraft["~(i-1)~"]/fuel-flow",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~i~"]/fuel-flow"));
    }
  }
  var nb_aircraft = size(props.globals.getNode("/instrumentation/garmin196/params/aircrafts",1).getChildren("aircraft"));
  if(getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_aircraft~"]/name")!=nil){
    props.globals.getNode("/instrumentation/garmin196/params/aircrafts/aircraft["~(nb_aircraft-1)~"]").remove();
  }
  
  setprop("/instrumentation/garmin196/no_aircraft",no_aircraft-1);
  save_parameters();
}

var display_list_aircraft = func{
  var no_ligne = getprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected");
  if(no_ligne==-1){
    no_ligne = getprop("/instrumentation/garmin196/no_aircraft");
  }
  var aircraft_display = "";
  if(getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/max-speed")!=nil){
    var max_speed = getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/max-speed");
    var name = getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/name");
    setprop("/instrumentation/garmin196/max-speed",max_speed);
    setprop("/instrumentation/garmin196/cruise-speed",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/cruise-speed"));
    setprop("/instrumentation/garmin196/fuel-flow",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/fuel-flow"));
    setprop("/instrumentation/garmin196/no_aircraft",no_ligne);
    
    aircraft_display = name ~ "    vmax=";
    if(getprop("/instrumentation/garmin196/params/units/speed")==1){
      aircraft_display = aircraft_display ~ max_speed ~"kt";
    }else{
      aircraft_display = aircraft_display ~ sprintf("%3.0f",(max_speed*1.852)) ~"km/h";
    }
  }else{
    aircraft_display = "NEW AIRCRAFT";
  }
  setprop("/instrumentation/garmin196/menu_aircraft/text",aircraft_display);
}

var init_menu_aircraft = func{
  var no_ligne = getprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected");
  
  setprop("/instrumentation/garmin196/menu_aircraft/selected-name",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/name"));
  setprop("/instrumentation/garmin196/menu_aircraft/selected-max",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/max-speed"));
  setprop("/instrumentation/garmin196/menu_aircraft/selected-cruise",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/cruise-speed"));
  setprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow",getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/fuel-flow"));
          
  setprop("/instrumentation/garmin196/menu_aircraft/x_char",size(getprop("/instrumentation/garmin196/menu_aircraft/selected-name"))-1);
  setprop("/instrumentation/garmin196/menu_aircraft/y_char",searchLastChar(getprop("/instrumentation/garmin196/menu_aircraft/selected-name"),getprop("/instrumentation/garmin196/menu_aircraft/x_char")));
  display_menu_aircraft();
}

var validate_menu_aircraft=func{
  var no_ligne = getprop("/instrumentation/garmin196/menu_aircraft/no_ligne_selected");
  
  setprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/name",getprop("/instrumentation/garmin196/menu_aircraft/selected-name"));
  setprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/max-speed",getprop("/instrumentation/garmin196/menu_aircraft/selected-max"));
  setprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/cruise-speed",getprop("/instrumentation/garmin196/menu_aircraft/selected-cruise"));
  setprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_ligne~"]/fuel-flow",getprop("/instrumentation/garmin196/menu_aircraft/selected-fuelflow"));
  save_parameters();
}

var display_menu_aircraft=func{
  if(getprop("/instrumentation/garmin196/params/units/speed")==1){
    setprop("/instrumentation/garmin196/menu_aircraft/selected-max-display",getprop("/instrumentation/garmin196/menu_aircraft/selected-max")~"kt");
    setprop("/instrumentation/garmin196/menu_aircraft/selected-cruise-display",getprop("/instrumentation/garmin196/menu_aircraft/selected-cruise")~"kt");
  }else{
    setprop("/instrumentation/garmin196/menu_aircraft/selected-max-display",sprintf("%3.0fkm/h",getprop("/instrumentation/garmin196/menu_aircraft/selected-max")*1.852));
    setprop("/instrumentation/garmin196/menu_aircraft/selected-cruise-display",sprintf("%3.0fkm/h",getprop("/instrumentation/garmin196/menu_aircraft/selected-cruise")*1.852));
  }
}

var display_menu_aircraft_name = func{
  var ligne_selected = getprop("/instrumentation/garmin196/menu_aircraft/selected-name");
  var x_char = props.globals.getNode("/instrumentation/garmin196/menu_aircraft/x_char").getValue();
  ligne_selected = substr(ligne_selected,0,x_char);
  ligne_selected = ligne_selected ~ tab_chiffres_lettres[getprop("/instrumentation/garmin196/menu_aircraft/y_char")];
  setprop("/instrumentation/garmin196/menu_aircraft/selected-name",ligne_selected);
}

var display_menu_flights = func{
  var flights = props.globals.getNode("/instrumentation/garmin196/flights",1);
  var i = 0;
  foreach (var e; flights.getChildren("flight")) {
    var start = e.getChild("start").getValue();
    var end = e.getChild("end").getValue();
    var date = e.getChild("date").getValue();
    var aircraft = e.getChild("aircraft").getValue();
    var distance = e.getChild("distance").getValue();
    var duration = e.getChild("duration").getValue();
    
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      distance = sprintf("%03.1fnm",distance);
    }else{
      distance = sprintf("%03.1fkm",distance*1.852);
    }
    var ligne = sprintf("%s to %s    %s",start,end,date);
    
    setprop("/instrumentation/garmin196/menu_flights/ligne["~i~"]/texte",ligne);
    setprop("/instrumentation/garmin196/menu_flights/ligne["~i~"]/start",start);
    setprop("/instrumentation/garmin196/menu_flights/ligne["~i~"]/end",end);
    setprop("/instrumentation/garmin196/menu_flights/ligne["~i~"]/date",date);
    setprop("/instrumentation/garmin196/menu_flights/ligne["~i~"]/aircraft",aircraft);
    setprop("/instrumentation/garmin196/menu_flights/ligne["~i~"]/distance",distance);
    setprop("/instrumentation/garmin196/menu_flights/ligne["~i~"]/duration",sprintf("%03.1fh",duration));
    
    i=i+1;
  }
  for(var j=i;j<8;j=j+1){
    setprop("/instrumentation/garmin196/menu_flights/ligne["~j~"]/texte","");
  }
  setprop("/instrumentation/garmin196/menu_flights/max_ligne_selected",i-1);
}

var update_menu_flights_detail = func{
  var no_ligne = getprop("/instrumentation/garmin196/menu_flights/no_ligne_selected");
  setprop("/instrumentation/garmin196/menu_flights/ligne_selected/texte",getprop("/instrumentation/garmin196/menu_flights/ligne["~no_ligne~"]/start")~" to "~getprop("/instrumentation/garmin196/menu_flights/ligne["~no_ligne~"]/end"));
  setprop("/instrumentation/garmin196/menu_flights/ligne_selected/date",getprop("/instrumentation/garmin196/menu_flights/ligne["~no_ligne~"]/date"));
  setprop("/instrumentation/garmin196/menu_flights/ligne_selected/aircraft",getprop("/instrumentation/garmin196/menu_flights/ligne["~no_ligne~"]/aircraft"));
  setprop("/instrumentation/garmin196/menu_flights/ligne_selected/distance",getprop("/instrumentation/garmin196/menu_flights/ligne["~no_ligne~"]/distance"));
  setprop("/instrumentation/garmin196/menu_flights/ligne_selected/duration",getprop("/instrumentation/garmin196/menu_flights/ligne["~no_ligne~"]/duration"));
}

var update_flight = func{
  if(getprop("/instrumentation/garmin196/flight/inflight")==nil){
    props.globals.getNode("/instrumentation/garmin196/flight/inflight",1).setBoolValue(0);
    props.globals.getNode("/instrumentation/garmin196/flight/start",1).setValue("");
  }

  var inflight = getprop("/instrumentation/garmin196/flight/inflight");
  var speed = getprop("/instrumentation/gps/indicated-ground-speed-kt");
  if(inflight==1){
    if(speed<30){#speed<30kt, flight saved
      
      props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(1);
      props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
      props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
      props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("airport");
      setprop("/instrumentation/gps/command", "nearest");
      var id = getprop("/instrumentation/gps/scratch/ident");
      props.globals.getNode("/instrumentation/garmin196/flight/end",1).setValue(id);
      props.globals.getNode("/instrumentation/garmin196/flight/distance",1).setDoubleValue(getprop("/instrumentation/gps/trip-odometer"));
      props.globals.getNode("/instrumentation/garmin196/flight/duration",1).setDoubleValue((getprop("/sim/time/elapsed-sec")-getprop("/instrumentation/garmin196/flight/start-time"))/3600);
      setprop("/instrumentation/garmin196/flight/inflight",0);
      
      ##inscription dans le carnet de vol
      for(var i=7;i>0;i=i-1){
        if(getprop("/instrumentation/garmin196/flights/flight["~(i-1)~"]/start")!=nil){
          props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/start",1).setValue(getprop("/instrumentation/garmin196/flights/flight["~(i-1)~"]/start"));
          props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/end",1).setValue(getprop("/instrumentation/garmin196/flights/flight["~(i-1)~"]/end"));
          props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/date",1).setValue(getprop("/instrumentation/garmin196/flights/flight["~(i-1)~"]/date"));
          props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/aircraft",1).setValue(getprop("/instrumentation/garmin196/flights/flight["~(i-1)~"]/aircraft"));
          props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/distance",1).setDoubleValue(getprop("/instrumentation/garmin196/flights/flight["~(i-1)~"]/distance"));
          props.globals.getNode("/instrumentation/garmin196/flights/flight["~i~"]/duration",1).setDoubleValue(getprop("/instrumentation/garmin196/flights/flight["~(i-1)~"]/duration"));
        }
      }
      props.globals.getNode("/instrumentation/garmin196/flights/flight[0]/start",1).setValue(getprop("/instrumentation/garmin196/flight/start"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight[0]/end",1).setValue(getprop("/instrumentation/garmin196/flight/end"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight[0]/date",1).setValue(getprop("/instrumentation/garmin196/flight/date"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight[0]/aircraft",1).setValue(getprop("/instrumentation/garmin196/flight/aircraft"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight[0]/distance",1).setDoubleValue(getprop("/instrumentation/garmin196/flight/distance"));
      props.globals.getNode("/instrumentation/garmin196/flights/flight[0]/duration",1).setDoubleValue(getprop("/instrumentation/garmin196/flight/duration"));
      display_menu_flights();
      save_parameters();
    }
  }else{
    if(speed>30){#speed>30kt, flight started
      props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(1);
      props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
      props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
      props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("airport");
      setprop("/instrumentation/gps/command", "nearest");
      var id = getprop("/instrumentation/gps/scratch/ident");
      props.globals.getNode("/instrumentation/garmin196/flight/start",1).setValue(id);
      var no_aircraft = getprop("/instrumentation/garmin196/no_aircraft");
      var aircraft = getprop("/instrumentation/garmin196/params/aircrafts/aircraft["~no_aircraft~"]/name");
      if(aircraft==nil){
        props.globals.getNode("/instrumentation/garmin196/flight/aircraft",1).setValue("NO AIRCRAFT");
      }else{
        props.globals.getNode("/instrumentation/garmin196/flight/aircraft",1).setValue(aircraft);
      }
      props.globals.getNode("/instrumentation/garmin196/flight/date",1).setValue(substr(getprop("/sim/time/gmt"),0,10));
      props.globals.getNode("/instrumentation/garmin196/flight/start-time",1).setDoubleValue(getprop("/sim/time/elapsed-sec"));
      setprop("/instrumentation/gps/trip-odometer",0);
      setprop("/instrumentation/garmin196/flight/inflight",1);
    }
  }
}

var update_e6b_menu=func{
  var status = getprop("/instrumentation/garmin196/status");
  if(status==150){
    if(getprop("/instrumentation/garmin196/params/units/pressure")==1){
      setprop("/instrumentation/garmin196/menu_e6b/baro-pressure",sprintf("%2.2fInHg",getprop("/environment/pressure-sea-level-inhg")));
    }else{
      setprop("/instrumentation/garmin196/menu_e6b/baro-pressure",sprintf("%4.0fhPa",getprop("/environment/pressure-sea-level-inhg")/0.03));
    }
    
    var diff_speed = getprop("/instrumentation/gps/indicated-ground-speed-kt") - getprop("/velocities/airspeed-kt");
    if(getprop("/instrumentation/garmin196/params/units/speed")==1){
      setprop("/instrumentation/garmin196/menu_e6b/wind-speed",sprintf("%1.0fkt",getprop("/environment/wind-speed-kt")));
      setprop("/instrumentation/garmin196/menu_e6b/calibrated-airspeed",sprintf("%1.0fkt",getprop("/instrumentation/gps/indicated-ground-speed-kt")));
      setprop("/instrumentation/garmin196/menu_e6b/true-airspeed",sprintf("%1.0fkt",getprop("/velocities/airspeed-kt")));
      setprop("/instrumentation/garmin196/menu_e6b/head-wind",sprintf("%1.0fkt",diff_speed));
    }else{
      setprop("/instrumentation/garmin196/menu_e6b/wind-speed",sprintf("%1.0fkm/h",getprop("/environment/wind-speed-kt")*1.852));
      setprop("/instrumentation/garmin196/menu_e6b/calibrated-airspeed",sprintf("%1.0fkm/h",getprop("/instrumentation/gps/indicated-ground-speed-kt")*1.852));
      setprop("/instrumentation/garmin196/menu_e6b/true-airspeed",sprintf("%1.0fkm/h",getprop("/velocities/airspeed-kt")*1.852));
      setprop("/instrumentation/garmin196/menu_e6b/head-wind",sprintf("%1.0fkm/h",diff_speed*1.852));
    }
    
    if(getprop("/instrumentation/garmin196/params/units/altitude")==1){
      setprop("/instrumentation/garmin196/menu_e6b/indicated-altitude",sprintf("%1.0fft",getprop("/instrumentation/gps/indicated-altitude-ft")));
      setprop("/instrumentation/garmin196/menu_e6b/density-altitude",sprintf("%1.0fft",getprop("/position/altitude-ft")));
    }else{
      setprop("/instrumentation/garmin196/menu_e6b/indicated-altitude",sprintf("%1.0fm",getprop("/instrumentation/gps/indicated-altitude-ft")*0.1097));
      setprop("/instrumentation/garmin196/menu_e6b/density-altitude",sprintf("%1.0fm",getprop("/position/altitude-ft")*0.1097));
    }

    if(getprop("/instrumentation/garmin196/params/units/temperature")==1){
      setprop("/instrumentation/garmin196/menu_e6b/air-temp",sprintf("%1.1fC",getprop("/environment/temperature-degc")));
    }else{
      setprop("/instrumentation/garmin196/menu_e6b/air-temp",sprintf("%1.1fF",getprop("/environment/temperature-degf")));
    }
    setprop("/instrumentation/garmin196/menu_e6b/wind-from",sprintf("%1.0f",getprop("/environment/wind-from-heading-deg")));
    setprop("/instrumentation/garmin196/menu_e6b/heading",sprintf("%1.0f",getprop("/orientation/heading-deg")));
  }
}

var init_list_points = func{
  var points = props.globals.getNode("/instrumentation/garmin196/waypoints/user/",1);
  var i = 0;
  foreach (var e; points.getChildren("wpt")) {
    setprop("/instrumentation/garmin196/menu_points/point["~i~"]/texte",e.getChild("id").getValue());
    i=i+1;
  }
  
  for(var j=i;j<9;j=j+1){
    setprop("/instrumentation/garmin196/menu_points/point["~j~"]/texte","");
  }
  
  if(i<9){
    setprop("/instrumentation/garmin196/menu_points/point["~i~"]/texte","ENTER TO ADD WAYPOINT");
  }else{
    i=8;
  }
  setprop("/instrumentation/garmin196/menu_points/max_no_ligne",i);
}

var init_new_point = func(no_point){
  props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~no_point~"]/id", 1).setValue("POINT");
  props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~no_point~"]/latitude", 1).setDoubleValue(getprop("/position/latitude-deg"));
  props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~no_point~"]/longitude", 1).setDoubleValue(getprop("/position/longitude-deg"));
}

var delete_point = func(no_point){
  for(var i=no_point+1;i<9;i=i+1){
    if(getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/id")!=nil){
      setprop("/instrumentation/garmin196/waypoints/user/wpt["~(i-1)~"]/id",getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/id"));
      setprop("/instrumentation/garmin196/waypoints/user/wpt["~(i-1)~"]/latitude",getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/latitude"));
      setprop("/instrumentation/garmin196/waypoints/user/wpt["~(i-1)~"]/longitude",getprop("/instrumentation/garmin196/waypoints/user/wpt["~i~"]/longitude"));
    }
  }
  var nb_points = size(props.globals.getNode("/instrumentation/garmin196/waypoints/user/",1).getChildren("wpt"));
  if(getprop("/instrumentation/garmin196/waypoints/user/wpt["~no_point~"]/id")!=nil){
    props.globals.getNode("/instrumentation/garmin196/waypoints/user/wpt["~(nb_points-1)~"]").remove();
  }
  save_parameters();
}

var update_menu_points = func{
  var no_ligne = getprop("/instrumentation/garmin196/menu_points/no_ligne_selected");
  var name = getprop("/instrumentation/garmin196/waypoints/user/wpt["~no_ligne~"]/id");
  var latitude = getprop("/instrumentation/garmin196/waypoints/user/wpt["~no_ligne~"]/latitude");
  var longitude = getprop("/instrumentation/garmin196/waypoints/user/wpt["~no_ligne~"]/longitude");
  
  setprop("/instrumentation/garmin196/menu_points/name",name);
  props.globals.getNode("/instrumentation/garmin196/menu_points/longitude", 1).setDoubleValue(longitude);
  props.globals.getNode("/instrumentation/garmin196/menu_points/latitude", 1).setDoubleValue(latitude);
  setprop("/instrumentation/garmin196/menu_points/x_char",size(getprop("/instrumentation/garmin196/menu_points/name"))-1);
  setprop("/instrumentation/garmin196/menu_points/y_char",searchLastChar(getprop("/instrumentation/garmin196/menu_points/name"),getprop("/instrumentation/garmin196/menu_points/x_char")));
  display_menu_points();
}

var validate_menu_points = func{
  var no_ligne = getprop("/instrumentation/garmin196/menu_points/no_ligne_selected");
  
  var id = getprop("/instrumentation/garmin196/menu_points/name");
  var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
  var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
  setprop("/instrumentation/garmin196/waypoints/user/wpt["~no_ligne~"]/id",id);
  setprop("/instrumentation/garmin196/waypoints/user/wpt["~no_ligne~"]/latitude",latitude);
  setprop("/instrumentation/garmin196/waypoints/user/wpt["~no_ligne~"]/longitude",longitude);
  props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(longitude);
  props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(latitude);
  props.globals.getNode("/instrumentation/gps/scratch/ident",1).setValue(id~"WPTUSR");
  setprop("/instrumentation/gps/command","define-user-wpt");
  update_menu_points();
  save_parameters();
}

var display_menu_points = func{
  var ligne_selected = getprop("/instrumentation/garmin196/menu_points/name");
  var x_char = props.globals.getNode("/instrumentation/garmin196/menu_points/x_char").getValue();
  ligne_selected = substr(ligne_selected,0,x_char);
  ligne_selected = ligne_selected ~ tab_chiffres_lettres[getprop("/instrumentation/garmin196/menu_points/y_char")];
  setprop("/instrumentation/garmin196/menu_points/name",ligne_selected);

  var latitude = getprop("/instrumentation/garmin196/menu_points/latitude");
  var latitude_tab = split(".",sprintf("%3.2f",math.abs(latitude)));
  var latitude_text10 = latitude_tab[0];
  var latitude_text1 = "00";
  if(size(latitude_tab)>1){
    latitude_text1 = sprintf("%0.2s",latitude_tab[1]);
  }
  if(latitude>=0){
    latitude_text10 = "N" ~ latitude_text10;
  }else{
    latitude_text10 = "S" ~ latitude_text10;
  }
  var longitude = getprop("/instrumentation/garmin196/menu_points/longitude");
  var longitude_tab = split(".",sprintf("%3.2f",math.abs(longitude)));
  var longitude_text10 = longitude_tab[0];
  var longitude_text1 = "00";
  if(size(longitude_tab)>1){
    longitude_text1 = sprintf("%0.2s",longitude_tab[1]);
  }
  if(longitude>=0){
    longitude_text10 = "E" ~ longitude_text10;
  }else{
    longitude_text10 = "W" ~ longitude_text10;
  }

  setprop("/instrumentation/garmin196/menu_points/latitude10_text",latitude_text10);
  setprop("/instrumentation/garmin196/menu_points/latitude1_text",latitude_text1);
  setprop("/instrumentation/garmin196/menu_points/longitude10_text",longitude_text10);
  setprop("/instrumentation/garmin196/menu_points/longitude1_text",longitude_text1);
}

var init_menu_routes_list = func{
  var routes = props.globals.getNode("/instrumentation/garmin196/routes",1);
  var i = 0;
  foreach (var e; routes.getChildren("route")) {
    setprop("/instrumentation/garmin196/menu_routes/route["~i~"]/texte",e.getChild("name").getValue());
    i=i+1;
  }
  
  for(var j=i;j<11;j=j+1){
    setprop("/instrumentation/garmin196/menu_routes/route["~j~"]/texte","");
  }
  
  if(i<11){
    setprop("/instrumentation/garmin196/menu_routes/route["~i~"]/texte","ENTER TO ADD ROUTE");
  }else{
    i=10;
  }
  setprop("/instrumentation/garmin196/menu_routes/max_no_ligne",i);
}

var init_new_route = func(no_ligne){
  setprop("/instrumentation/gps/scratch/max-results", 1);
  setprop("/instrumentation/gps/scratch/longitude-deg",-9999);
  setprop("/instrumentation/gps/scratch/latitude-deg",-9999);
  setprop("/instrumentation/gps/scratch/type", "airport");
  setprop("/instrumentation/gps/command", "nearest");
  var id = getprop("/instrumentation/gps/scratch/ident");
  
  props.globals.getNode("/instrumentation/garmin196/routes/route["~no_ligne~"]/name",1).setValue(id~" to "~id);
  props.globals.getNode("/instrumentation/garmin196/routes/route["~no_ligne~"]/wpts/wpt[0]/id",1).setValue(id);
  props.globals.getNode("/instrumentation/garmin196/routes/route["~no_ligne~"]/wpts/wpt[0]/type",1).setValue("airport");
}

var update_menu_routes_detail = func{
  var no_ligne = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
  
  var points = props.globals.getNode("/instrumentation/garmin196/routes/route["~no_ligne~"]/wpts/",1);
  var i = 0;
  var last_longitude = 0;
  var last_latitude = 0;
  
  var distance_total = 0;
  var cruise_speed = getprop("/instrumentation/garmin196/cruise-speed");
  var conso_horaire = getprop("/instrumentation/garmin196/fuel-flow");
      
  foreach (var e; points.getChildren("wpt")) {
    var id = e.getChild("id").getValue();
    var type = e.getChild("type").getValue();
    var ligne = id;
    if(substr(id,size(id)-6)=="WPTUSR"){
      ligne = substr(id,0,size(id)-6);
    }elsif(substr(id,size(id)-6)=="WPTTWN"){
      ligne = substr(id,0,size(id)-8);
    }
    ligne = substr(ligne,0,8);
    
    if(i==0){
      setprop("/instrumentation/gps/scratch/max-results", 1);
      setprop("/instrumentation/gps/scratch/exact", 0);
      setprop("/instrumentation/gps/scratch/query", id);
      setprop("/instrumentation/gps/scratch/type", type);
      setprop("/instrumentation/gps/command", "search");
      last_longitude = getprop("/instrumentation/gps/scratch/longitude-deg");
      last_latitude = getprop("/instrumentation/gps/scratch/latitude-deg");
    }else{
      var ligne_spaces = "                              ";
      ligne_spaces = substr(ligne_spaces,0,8-size(ligne));
      var coord_last_id = geo.Coord.new().set_latlon(last_latitude,last_longitude);
      setprop("/instrumentation/gps/scratch/max-results", 1);
      setprop("/instrumentation/gps/scratch/exact", 0);
      setprop("/instrumentation/gps/scratch/query", id);
      setprop("/instrumentation/gps/scratch/type", type);
      setprop("/instrumentation/gps/command", "search");
      last_longitude = getprop("/instrumentation/gps/scratch/longitude-deg");
      last_latitude = getprop("/instrumentation/gps/scratch/latitude-deg");
      
      var coord_id = geo.Coord.new().set_latlon(last_latitude,last_longitude);
      var distance = coord_last_id.distance_to(coord_id) * 0.000539;
      var bearing = coord_last_id.course_to(coord_id);
      
      var ete = distance / cruise_speed;
      var ete_hours = int(ete);
      var ete_minutes = int(ete*60-ete_hours*60);
      var conso = ete * conso_horaire;
      distance_total = distance_total + distance;
      if(getprop("/instrumentation/garmin196/params/units/distance")==1){
        ligne = ligne ~ ligne_spaces ~ sprintf(" %03.0f %03.1f %02.0f:%02.0f %02.1f",bearing,distance,ete_hours,ete_minutes,conso);
      }else{
        ligne = ligne ~ ligne_spaces ~ sprintf(" %03.0f %03.1f %02.0f:%02.0f %02.1f",bearing,(distance*1.852),ete_hours,ete_minutes,conso);
      }
    }
    setprop("/instrumentation/garmin196/menu_routes/point["~i~"]/texte",ligne);
    i=i+1;
  }
  
  var ete_total = distance_total / cruise_speed;
  var ete_total_hours = int(ete_total);
  var ete_total_minutes = int(ete_total*60-ete_total_hours*60);
  var conso_total = ete_total * conso_horaire;
  if(getprop("/instrumentation/garmin196/params/units/distance")==1){
    setprop("/instrumentation/garmin196/menu_routes/total/texte",sprintf("%03.1f %02.0f:%02.0f %02.1f",distance_total,ete_total_hours,ete_total_minutes,conso_total));
  }else{
    setprop("/instrumentation/garmin196/menu_routes/total/texte",sprintf("%03.1f %02.0f:%02.0f %02.1f",(distance_total*1.852),ete_total_hours,ete_total_minutes,conso_total));
  }
  
  for(var j=i;j<10;j=j+1){
    setprop("/instrumentation/garmin196/menu_routes/point["~j~"]/texte","");
  }
  if(i<10){
    setprop("/instrumentation/garmin196/menu_routes/point["~i~"]/texte","ENTER TO ADD WAYPOINT");
  }else{
    i=9;
  }
  setprop("/instrumentation/garmin196/menu_routes/max_no_ligne_detail",i);
}

var init_search_route = func(start_string){
  if(substr(start_string,size(start_string)-6)=="WPTUSR"){
    start_string = substr(start_string,0,size(start_string)-6);
  }elsif(substr(start_string,size(start_string)-6)=="WPTTWN"){
    start_string = substr(start_string,0,size(start_string)-8);
  }
  setprop("/instrumentation/garmin196/menu_routes/search/ligne_select",start_string);
  setprop("/instrumentation/garmin196/menu_routes/search/x_char",size(start_string)-1);
  setprop("/instrumentation/garmin196/menu_routes/search/y_char",searchLastChar(getprop("/instrumentation/garmin196/menu_routes/search/ligne_select"),getprop("/instrumentation/garmin196/menu_routes/search/x_char")));
          
  display_route_waypoint_search();
}

var display_route_waypoint_search = func{
  var ligne_selected = getprop("/instrumentation/garmin196/menu_routes/search/ligne_select");
  var x_char = props.globals.getNode("/instrumentation/garmin196/menu_routes/search/x_char").getValue();
  ligne_selected = substr(ligne_selected,0,x_char);
  ligne_selected = ligne_selected ~ tab_chiffres_lettres[getprop("/instrumentation/garmin196/menu_routes/search/y_char")];
  setprop("/instrumentation/garmin196/menu_routes/search/ligne_select",ligne_selected);

  var plots = [];
  ##recherche gps globale
  props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(5);
  props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(0);
  props.globals.getNode("/instrumentation/gps/scratch/query",1).setValue(ligne_selected);
  props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("");
  
  setprop("/instrumentation/gps/command", "search");
  var i=0;
  var flag_continue = getprop("/instrumentation/gps/scratch/valid");
  while (flag_continue and i<5) {
    var id = getprop("/instrumentation/gps/scratch/ident");
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    var type = getprop("/instrumentation/gps/scratch/type");
    
    var ligne = id;
    if(type=="waypoint"){
      type = "wpt";
      var type_wpt = substr(id,size(id)-6);
      if(type_wpt=="WPTTWN"){#cities
        ligne = substr(id,0,size(id)-8);
      }elsif(type_wpt=="WPTUSR"){#wpt user
        ligne = substr(id,0,size(id)-6);
      }
    }
    
    ligne = ligne ~ " " ~ type;
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,16-size(ligne));
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf("  %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf("  %3.1fkm",range*1.852);
    }
    var popup_status = getprop("/instrumentation/garmin196/popup_status");
    
    
    var plot = { id: id,texte: ligne,type: type};
    append(plots,plot);
    
    i=i+1;
    setprop("/instrumentation/gps/command", "next");
    flag_continue = getprop("/instrumentation/gps/scratch/has-next");
  }
  
  ##recherche gps fix
  props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(5);
  props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(0);
  props.globals.getNode("/instrumentation/gps/scratch/query",1).setValue(ligne_selected);
  props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("fix");
  
  setprop("/instrumentation/gps/command", "search");
  i=0;
  flag_continue = getprop("/instrumentation/gps/scratch/valid");
  while (flag_continue and i<5) {
    var id = getprop("/instrumentation/gps/scratch/ident");
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    var type = getprop("/instrumentation/gps/scratch/type");
    
    var ligne = id ~ " " ~ type;
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,16-size(ligne));
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf("  %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf("  %3.1fkm",range*1.852);
    }
    var popup_status = getprop("/instrumentation/garmin196/popup_status");
    
    
    var plot = { id: id,texte: ligne,type: type};
    append(plots,plot);
    
    i=i+1;
    setprop("/instrumentation/gps/command", "next");
    flag_continue = getprop("/instrumentation/gps/scratch/has-next");
  }
  
  ##recherche gps vor
  props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(5);
  props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(0);
  props.globals.getNode("/instrumentation/gps/scratch/query",1).setValue(ligne_selected);
  props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("vor");
  
  setprop("/instrumentation/gps/command", "search");
  i=0;
  flag_continue = getprop("/instrumentation/gps/scratch/valid");
  while (flag_continue and i<5) {
    var id = getprop("/instrumentation/gps/scratch/ident");
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    var type = getprop("/instrumentation/gps/scratch/type");
    
    var ligne = id ~ " vor";
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,16-size(ligne));
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf("  %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf("  %3.1fkm",range*1.852);
    }
    var popup_status = getprop("/instrumentation/garmin196/popup_status");
    
    
    var plot = { id: id,texte: ligne,type: type};
    append(plots,plot);
    
    i=i+1;
    setprop("/instrumentation/gps/command", "next");
    flag_continue = getprop("/instrumentation/gps/scratch/has-next");
  }
  
  ##recherche gps ndb
  props.globals.getNode("/instrumentation/gps/scratch/max-results", 1).setIntValue(5);
  props.globals.getNode("/instrumentation/gps/scratch/longitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/latitude-deg", 1).setDoubleValue(-9999);
  props.globals.getNode("/instrumentation/gps/scratch/exact", 1).setBoolValue(0);
  props.globals.getNode("/instrumentation/gps/scratch/query",1).setValue(ligne_selected);
  props.globals.getNode("/instrumentation/gps/scratch/type",1).setValue("ndb");
  
  setprop("/instrumentation/gps/command", "search");
  i=0;
  flag_continue = getprop("/instrumentation/gps/scratch/valid");
  while (flag_continue and i<5) {
    var id = getprop("/instrumentation/gps/scratch/ident");
    var range = getprop("/instrumentation/gps/scratch/distance-nm");
    var bearing = getprop("/instrumentation/gps/scratch/mag-bearing-deg");
    var type = getprop("/instrumentation/gps/scratch/type");
    
    var ligne = id ~ " ndb";
    var ligne_spaces = "                              ";
    ligne_spaces = substr(ligne_spaces,0,16-size(ligne));
    
    ligne = ligne ~ ligne_spaces ~ sprintf(" %03.f",bearing);
    if(getprop("/instrumentation/garmin196/params/units/distance")==1){
      ligne = ligne ~sprintf("  %3.1fnm",range);
    }else{
      ligne = ligne ~sprintf("  %3.1fkm",range*1.852);
    }
    var popup_status = getprop("/instrumentation/garmin196/popup_status");
    
    
    var plot = { id: id,texte: ligne,type: type};
    append(plots,plot);
    
    i=i+1;
    setprop("/instrumentation/gps/command", "next");
    flag_continue = getprop("/instrumentation/gps/scratch/has-next");
  }
    
  var plots_sorted = sort (plots, func (a,b) cmp (a.id, b.id));
  var nb_plots = size(plots_sorted);
  if(nb_plots>9){
    nb_plots = 9;
  }
  for(var j=0;j<nb_plots;j=j+1){
    setprop("/instrumentation/garmin196/menu_routes/search/ligne["~j~"]/texte",plots_sorted[j].texte);
    setprop("/instrumentation/garmin196/menu_routes/search/ligne["~j~"]/id",plots_sorted[j].id);
    setprop("/instrumentation/garmin196/menu_routes/search/ligne["~j~"]/type",plots_sorted[j].type);
  }

  for(var j=nb_plots;j<9;j=j+1){
    setprop("/instrumentation/garmin196/menu_routes/search/ligne["~j~"]/texte","");
    setprop("/instrumentation/garmin196/menu_routes/search/ligne["~j~"]/id","");
    setprop("/instrumentation/garmin196/menu_routes/search/ligne["~j~"]/type","");
  }
  setprop("/instrumentation/garmin196/menu_routes/search/no_ligne_selected",-1);
  setprop("/instrumentation/garmin196/menu_routes/search/max_ligne_selected",nb_plots-1);
}

var delete_route = func(no_ligne){
  for(var i=no_ligne+1;i<11;i=i+1){
    if(getprop("/instrumentation/garmin196/routes/route["~i~"]/name")!=nil){
      setprop("/instrumentation/garmin196/routes/route["~(i-1)~"]/name",getprop("/instrumentation/garmin196/routes/route["~i~"]/name"));
      for(var j=0;j<10;j=j+1){
        if(getprop("/instrumentation/garmin196/routes/route["~i~"]/wpts/wpt["~j~"]/id")!=nil){
          setprop("/instrumentation/garmin196/routes/route["~(i-1)~"]/wpts/wpt["~j~"]/id",getprop("/instrumentation/garmin196/routes/route["~i~"]/wpts/wpt["~j~"]/id"));
          setprop("/instrumentation/garmin196/routes/route["~(i-1)~"]/wpts/wpt["~j~"]/type",getprop("/instrumentation/garmin196/routes/route["~i~"]/wpts/wpt["~j~"]/type"));
        }
      }
    }
  }
  var nb_routes = size(props.globals.getNode("/instrumentation/garmin196/routes",1).getChildren("route"));
  if(getprop("/instrumentation/garmin196/routes/route["~no_ligne~"]/name")!=nil){
    props.globals.getNode("/instrumentation/garmin196/routes/route["~(nb_routes-1)~"]").remove();
  }
  
  save_parameters();
}

var delete_route_detail = func(no_ligne_liste,no_ligne_detail){
  if(no_ligne_detail>0){
    for(var i=no_ligne_detail+1;i<10;i=i+1){
      if(getprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~i~"]/id")!=nil){
        setprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~(i-1)~"]/id",getprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~i~"]/id"));
        setprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~(i-1)~"]/type",getprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~i~"]/type"));
      }
    }

    var nb_waypoints = size(props.globals.getNode("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts",1).getChildren("wpt"));
    if(getprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~no_ligne_detail~"]/id")!=nil){
      props.globals.getNode("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~(nb_waypoints-1)~"]").remove();
    }
    save_parameters();
  }
}

var validate_menu_search_routes = func{
  var no_ligne = getprop("/instrumentation/garmin196/menu_routes/search/no_ligne_selected");
  var id = getprop("/instrumentation/garmin196/menu_routes/search/ligne["~no_ligne~"]/id");
  var type = getprop("/instrumentation/garmin196/menu_routes/search/ligne["~no_ligne~"]/type");
  var no_ligne_liste = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
  var no_ligne_detail = getprop("/instrumentation/garmin196/menu_routes/no_ligne_detail");
  setprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~no_ligne_detail~"]/id",id);
  setprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~no_ligne_detail~"]/type",type);
  
  var name_wpt0 = getprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt[0]/id");
  if(substr(name_wpt0,size(name_wpt0)-6)=="WPTUSR"){
    name_wpt0 = substr(name_wpt0,0,size(name_wpt0)-6);
  }elsif(substr(name_wpt0,size(name_wpt0)-6)=="WPTTWN"){
    name_wpt0 = substr(name_wpt0,0,size(name_wpt0)-8);
  }
  var name_wpt1 = name_wpt0;
  var nb_points = size(props.globals.getNode("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts").getChildren("wpt"));
  if(nb_points>1){
    name_wpt1 = getprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/wpts/wpt["~(nb_points-1)~"]/id");
    if(substr(name_wpt1,size(name_wpt1)-6)=="WPTUSR"){
      name_wpt1 = substr(name_wpt1,0,size(name_wpt1)-6);
    }elsif(substr(name_wpt1,size(name_wpt1)-6)=="WPTTWN"){
      name_wpt1 = substr(name_wpt1,0,size(name_wpt1)-8);
    }
  }
  
  var name = name_wpt0 ~ " to " ~ name_wpt1;
  setprop("/instrumentation/garmin196/routes/route["~no_ligne_liste~"]/name",name);
}

var load_flight_plan = func(no_ligne){
  setprop("/autopilot/route-manager/input","@CLEAR");
  setprop("/autopilot/route-manager/input","@POP");
  var points = props.globals.getNode("/instrumentation/garmin196/routes/route["~no_ligne~"]/wpts/",1);
  foreach (var e; points.getChildren("wpt")) {
    var id = e.getChild("id").getValue();
    setprop("/autopilot/route-manager/input",id);
  }
  setprop("/autopilot/route-manager/input","@JUMP0");
  setprop("/autopilot/route-manager/input","@ACTIVATE");
}

var close_fpl_loaded = func{
  setprop("/instrumentation/garmin196/menu_routes/fpl-loaded",0);
}
var affiche_fpl_loaded = func{
  setprop("/instrumentation/garmin196/menu_routes/fpl-loaded",1);
  settimer(close_fpl_loaded,3);
}

var close_waypoint_jump = func{
  setprop("/instrumentation/garmin196/menu_routes/waypoint-jump",0);
}
var affiche_waypoint_jump = func{
  setprop("/instrumentation/garmin196/menu_routes/waypoint-jump",1);
  settimer(close_waypoint_jump,3);
}

var jump_to_waypoint = func(no_ligne){
  var no_ligne_liste = getprop("/instrumentation/garmin196/menu_routes/no_ligne_selected");
  load_flight_plan(no_ligne_liste);
  setprop("/autopilot/route-manager/input","@JUMP"~no_ligne);
}
