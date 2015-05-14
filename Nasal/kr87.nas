# 
# This Timer is for stop-watches
#
# ./time       (double)    elapsed time since last start or reset
#
# ./running    (bool)      true if timer is running, false if stopped
# ./start-time (double)    timestamp when the timer was last started or reset

var elapsedTimeSecN = props.globals.getNode( "/sim/time/elapsed-sec" );

var timer = {
  new : func(base) {
    var m = { parents: [timer] };
    m.base = base;
    m.baseN = props.globals.getNode( m.base, 1 );

    m.timeN = m.baseN.initNode( "time", 0.0 );
    m.runningN = m.baseN.initNode( "running", 0, "BOOL" );
    m.startTimeN = m.baseN.initNode( "start-time", -1.0 );

    return m;
  },

  getTime : func {
    return me.timeN.getDoubleValue();
  },

  start : func { 
    me.runningN.setBoolValue( 1 );
  },

  stop : func { 
    me.runningN.setBoolValue( 0 ); 
  },

  reset : func {
    me.startTimeN.setDoubleValue( elapsedTimeSecN.getValue() );
    me.timeN.setDoubleValue( 0 );
  },

  restart : func {
    me.reset();
    me.start();
  },

  # return integer coded time as hmmss
  computeBCDTime : func {
    var t = me.timeN.getValue();
    var h = int(t / 3600);
    var t = t - (h*3600);
    var m = int(t / 60 );
    var t = t - (m*60);
    var s = int(t);
    return h * 10000 + m * 100 + s;
  },

  update : func {
    if( me.runningN.getValue() ) {
      me.timeN.setDoubleValue( elapsedTimeSecN.getValue() - me.startTimeN.getValue() );
    }
  }

};

####################################################################
# KR87

var kr87 = {
  new : func(base) {
    var m = { parents: [kr87] };
    m.base = base;
    m.baseN = props.globals.getNode( m.base, 1 );

    m.flt = timer.new( m.base ~ "/flight-timer" );
    m.flt.restart();
    m.et  = timer.new( m.base ~ "/enroute-timer" );
    m.et.restart();

    m.displayModeN = m.baseN.initNode( "display-mode", 0, "INT" );

    m.rightDisplayN = m.baseN.getNode( "right-display", 1 );
    m.standbyFrequencyN = m.baseN.getNode( "frequencies/standby-khz", 1 );

#   will be set from audiopanel
#    m.baseN.getNode( "ident-audible" ).setBoolValue( 1 );
    m.volumeNormN = m.baseN.initNode( "volume-norm", 0.0 );

    m.power = 0;

    m.powerButtonN = m.baseN.initNode( "power-btn", 0, "BOOL" ); 
    m.powerButtonN.setBoolValue( m.volumeNormN.getValue() != 0 );
    m.setButtonN = m.baseN.initNode( "set-btn", 0, "BOOL" );
    m.powerButtonN.setBoolValue( m.powerButtonN.getValue() );
    m.adfButtonN = m.baseN.initNode( "adf-btn", 0, "BOOL" );
    m.bfoButtonN = m.baseN.initNode( "bfo-btn", 0, "BOOL" );

    m.modeN = m.baseN.getNode( "mode" );
    aircraft.data.add(
      m.adfButtonN,
      m.bfoButtonN,
      m.volumeNormN, 
      m.powerButtonN,
      m.standbyFrequencyN,
      m.baseN.getNode( "frequencies/selected-khz", 1 )
    );
    setlistener( m.base ~ "/adf-btn", func { m.modeButtonListener() } );
    setlistener( m.base ~ "/bfo-btn", func { m.modeButtonListener() } );
    m.modeButtonListener();

    return m;
  },

  modeButtonListener : func {
    if( me.adfButtonN.getBoolValue() ) {
      if( me.bfoButtonN.getBoolValue() ) {
        me.modeN.setValue( "bfo" );
      } else {
        me.modeN.setValue( "adf" );
      }
    } else {
      me.modeN.setValue( "ant" );
    }
  },

  powerButtonListener : func(n) {
    if( n.getBoolValue() and !me.power ) {
      # power on, restart timer and start with FRQ display
      me.et.restart();
      me.flt.restart();
      me.displayModeN.setIntValue( 0 );
    }
    me.power = me.powerButtonN.getValue();
  },

  update : func {
    me.flt.update();
    me.et.update(); 
    var m = me.displayModeN.getValue();

    if( m == 0 ) {
      # FRQ
      me.rightDisplayN.setIntValue( me.standbyFrequencyN.getValue() );
    } 

    # the display works up to 99h, 59m, 59s and then
    # displays 00:00 again. Don't know if this is the like the true kr87
    # handles this - never flewn that long...
    if( m == 1 ) {
      # FLT, show mm:ss up to 59:59, then hh:mm
      var t = me.flt.computeBCDTime();
      if( t >= 10000 ) {
        t = t / 100;
      }
      me.rightDisplayN.setIntValue( t );
    } 
    if( m == 2 ) {
      # ET, show mm:ss up to 59:59, then hh:mm
      t = me.et.computeBCDTime();
      if( t >= 10000 ) {
        t = t / 100;
      }
      me.rightDisplayN.setIntValue( t );
    }

    if( me.setButtonN.getValue() ) {
      me.et.restart();
    }

    if( me.powerButtonN.getBoolValue() and !me.power ) {
      # power on, restart timer and start with FRQ display
      me.et.restart();
      me.flt.restart();
      me.displayModeN.setIntValue( 0 );
    }
    me.power = me.powerButtonN.getValue();

    settimer( func { me.update() }, 0.1 );
  }
};

var kr87_0 = kr87.new( "/instrumentation/adf[0]" ).update();

#setlistener("/sim/signals/fdm-initialized", func { timer_update() } );

