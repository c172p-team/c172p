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
        m.stepFactor = m.baseN.initNode( "step-factor", 1 ); # count up by default
        
        m.clock = maketimer(1, func(){
            m.timeN.setValue(m.timeN.getValue() + m.stepFactor.getValue());
        });
        m.clock.simulatedTime = 1;
        setlistener( m.runningN, func(n) {
            if (n.getValue()) {
                m.clock.start();
            } else {
                m.clock.stop();
            }
        } );

        return m;
    },

    getTime : func {
       return me.timeN.getDoubleValue();
    },

    start : func { 
       me.runningN.setBoolValue( 1 );
       me.clock.start();
    },

    stop : func { 
       me.runningN.setBoolValue( 0 ); 
       me.clock.stop();
    },

    reset : func {
        me.timeN.setDoubleValue( 0 );
        me.stepFactor.setValue(1);
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
        m.et_alarmFlash = m.baseN.initNode( "enroute-timer/alarm-flash", 0, "BOOL" );
        m.et_alarmSound = m.baseN.initNode( "enroute-timer/alarm-sound", 0, "BOOL" );

        m.displayModeN = m.baseN.initNode( "display-mode", 0, "INT" );

        m.rightDisplayN = m.baseN.getNode( "right-display", 1 );
        m.standbyFrequencyN = m.baseN.getNode( "frequencies/standby-khz", 1 );

        # will be set from audiopanel
        # m.baseN.getNode( "ident-audible" ).setBoolValue( 1 );
        m.volumeNormN = m.baseN.initNode( "volume-norm", 0.0 );

        m.power = 0;

        m.powerButtonN = m.baseN.initNode( "power-btn", 0, "BOOL" ); 
        m.powerButtonN.setBoolValue( m.volumeNormN.getValue() != 0 );
        m.setButtonN = m.baseN.initNode( "set-btn", 0, "BOOL" );
        m.setButtonPTN = m.baseN.initNode( "set-btn-presstime", 0, "DOUBLE" );
        m.powerButtonN.setBoolValue( m.powerButtonN.getValue() );
        m.adfButtonN = m.baseN.initNode( "adf-btn", 0, "BOOL" );
        m.bfoButtonN = m.baseN.initNode( "bfo-btn", 0, "BOOL" );
        m.operable = m.baseN.initNode( "operable", 0, "BOOL" );
        m.isOperable = 0;

        m.setModeN = m.baseN.initNode( "set-mode", 0, "BOOL" );

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
            me.setModeN.setBoolValue(0);
          }
        me.power = me.powerButtonN.getValue();
    },

    update : func {
        var m = me.displayModeN.getValue();

        if( m == 0 ) {
            # FRQ
            me.rightDisplayN.setIntValue( me.standbyFrequencyN.getValue() );
        } 

        # Handle count-down wrapping;
        # this happens when the countdown reaches zero.
        # We flash the alarm and switch to the ET mode; clock starts to count upwards.
        if (me.et.clock.isRunning and me.et.stepFactor.getValue() < 0 and me.et.getTime() <= 0) {
            me.et.restart();
            me.et_alarmFlash.setBoolValue(1);
            me.et_alarmSound.setBoolValue(1);
            me.displayModeN.setIntValue(2);
            settimer( func { me.et_alarmFlash.setBoolValue(0); }, 15 );
            settimer( func { me.et_alarmSound.setBoolValue(0); }, 1 );
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

        var setButtonPTN_td = 0;
        if (me.setButtonPTN.getValue() > 0.0)  setButtonPTN_td = elapsedTimeSecN.getValue() - me.setButtonPTN.getValue();
        if( !me.setButtonN.getValue() and setButtonPTN_td >= 0.1 and setButtonPTN_td < 2.0) {
           # set-button was released before 2 secs
           me.setButtonPTN.setValue(0);
           if (me.et.clock.isRunning) {
               # counter is running; restart
               me.et.restart();
           }
           if (me.setModeN.getValue() and !me.et.clock.isRunning) {
               # set mode was active, start count down as timer was not running
               me.setModeN.setBoolValue(0);
               me.et.start();
           }
        }
        if( me.setButtonN.getValue() and setButtonPTN_td >= 2.0) {
            # set-button is still hold after 2 secs in ET mode: enter set-mode
            me.displayModeN.setIntValue(2);
            me.setModeN.setBoolValue(1);
            me.et.stop();
            # me.et.reset();   <-unsure, if the set mode starts at the current setting or at 00:00
            me.et.stepFactor.setValue(-1); # arm count-down mode
        }
        if( me.setButtonN.getValue() )  me.et_alarmFlash.setBoolValue(0); # in case we had an alarm active
        if( me.setButtonN.getValue() )  me.et_alarmSound.setBoolValue(0); # in case we had an alarm active

        if( me.powerButtonN.getBoolValue() and !me.power ) {
            # power on, restart timer and start with FRQ display
            me.et.restart();
            me.flt.restart();
            me.displayModeN.setIntValue( 0 );
            me.setModeN.setBoolValue(0);
        }

        me.power = me.powerButtonN.getValue();

        if (!me.operable.getBoolValue() ) {
            # powerloss or failure: reset and stop timers
            me.et.stop();
            me.et.reset();
            me.et.reset();
            me.flt.stop();
            me.flt.reset();
            me.displayModeN.setIntValue( 0 );
            me.setModeN.setBoolValue(0);
        } else {
            # power recovery
            if (!me.isOperable) {
                if (!me.flt.clock.isRunning)
                    me.flt.start();
                if (!me.et.clock.isRunning) {
                    me.et.start();
                }
            }
        }
        me.isOperable = me.operable.getBoolValue();

        settimer( func { me.update() }, 0.1 );
    }
};


setlistener("/sim/signals/fdm-initialized", func {
    kr87.new( "/instrumentation/adf[0]" ).update();
} );
