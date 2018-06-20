 # copied from Instruments-3D
 var lc2 = {
    new : func(prop1){
        var m = { parents : [lc2]};
        m.MODE =0;
        m.flip =0;
        m.digit_to_set=0;
        m.digit=[];
        m.set_mode=0;
        m.ctl_timer=0;
        m.et_start_time=0;
        m.et_countdown=0;
        m.et_running=0;
        m.et_elapsed=0;
        m.ft_start_time=0;
    m.ft_running=0;
        m.modetext =["GMT","LT","FT","ET"];
        m.lc2 = props.globals.initNode(prop1);
        m.fmeter_sec=m.lc2.initNode("flight-meter-sec",0,"DOUBLE");
        m.fmeter=aircraft.timer.new(m.fmeter_sec,1,1);
        m.tenths=m.lc2.initNode("tenths",0,"BOOL");
        m.ET_alarm=m.lc2.initNode("et-alarm",0,"BOOL");
        m.FT_alarm=m.lc2.initNode("ft-alert",0,"BOOL");
        m.FT_alarm_time=m.lc2.initNode("ft-alarm-time",0,"BOOL");
        append(m.digit,m.lc2.initNode("digit[0]",1,"BOOL"));
        append(m.digit,m.lc2.initNode("digit[1]",1,"BOOL"));
        append(m.digit,m.lc2.initNode("digit[2]",1,"BOOL"));
        append(m.digit,m.lc2.initNode("digit[3]",1,"BOOL"));
        m.modestring=m.lc2.initNode("mode-string",m.modetext[m.MODE],"STRING");
        m.power=m.lc2.initNode("power",1,"BOOL");
        m.HR=m.lc2.initNode("indicated-hour",0,"INT");
        m.MN=m.lc2.initNode("indicated-min",0,"INT");
        m.ET_HR=m.lc2.initNode("ET-hr",0,"INT");
        m.ET_MN=m.lc2.initNode("ET-min",0,"INT");
        m.FT_HR=m.lc2.initNode("FT-hr",0,"INT");
        m.FT_MN=m.lc2.initNode("FT-min",0,"INT");
        return m;
    },
#### flightmeter ####
    fmeter_control : func(){
    var ias =getprop("velocities/airspeed-kt");
        if(ias>30){
        if(me.ft_running==0){
            me.ft_running=1;
            me.fmeter.start();
        }
    }elsif(ias<30){
        if(me.ft_running==1){
            me.ft_running=0;
            me.fmeter.stop();
        }
        }
    },
#### displayed mode  ####
    select_display : func(){
        if(me.set_mode==0){
            me.MODE +=1;
            if(me.MODE>3)me.MODE -=4;
            me.modestring.setValue(me.modetext[me.MODE]);
        }else{
            me.digit[me.digit_to_set].setValue(1);
            me.digit_to_set+=1;
            if(me.digit_to_set>3){
                me.digit_to_set=0;
                me.set_mode=0;
            }
        }
    },
#### set displayed mode  ####
    set_time : func(){
        me.set_mode=1-me.set_mode;
    },
#### CTL button action ####
    control_action : func(tmr){
        if(me.set_mode==0){
            if(me.MODE==2){
                me.ctl_timer+=getprop("/sim/time/delta-realtime-sec");
                me.ctl_timer *=tmr;
                if(me.ctl_timer>1.5)me.fmeter.reset();
            }elsif(me.MODE==3){
                if(me.et_running==0){
                me.et_start_time=getprop("/sim/time/elapsed-sec");
                    me.et_running=1;
                }else{
                    me.et_start_time=getprop("/sim/time/elapsed-sec");
                    me.et_elapsed=0;
                    me.et_running=0;
                }
            }
        }else{
            if(me.MODE==0){
                me.set_gmt();
            }elsif(meMODE==1){
                me.set_lt();
            }elsif(meMODE==2){
                me.set_ft();
            }elsif(meMODE==3){
                me.set_et();
            }
        }
    },

#### set GMT  ####
    set_gmt : func(){
    
    },

#### set LT  ####
    set_lt : func(){
    
    },

#### set FT  ####
    set_ft : func(){
    
    },

#### set ET  ####
    set_et : func(){
    
    },

#### elapsed time  ####
    update_ET : func(){
        if(me.et_running!=0){
        me.et_elapsed=getprop("/sim/time/elapsed-sec") - me.et_start_time;
        }
        var ethour = me.et_elapsed/3600;
        var hr= int(ethour);
        var etmin=(ethour-hr) * 60;
        var min = int(etmin);
        var etsec= (etmin- min) *60;
        if(ethour <1){
            me.ET_HR.setValue(min);
            me.ET_MN.setValue(etsec);
        }else{
            me.ET_HR.setValue(hr);
            me.ET_MN.setValue(min);
        }
    },
#### flight time  ####
    update_FT : func(){
        var fthour = me.fmeter_sec.getValue()/3600;
        var hr= int(fthour);
        var ftmin=(fthour-hr) * 60;
        var min = int(ftmin);
        var ftsec= (ftmin- min) *60;
        if(fthour <1){
        me.FT_HR.setValue(min);
        me.FT_MN.setValue(ftsec);
        }else{
        me.FT_HR.setValue(hr);
        me.FT_MN.setValue(min);
        }
    },

#### update clock  ####
    update_clock : func{
        var pwr=me.power.getValue();
    me.fmeter_control();
        if(me.set_mode==0){
            pwr=1-pwr;
        }else{
            pwr=1;
        }
        me.power.setValue(pwr);
    
        if(me.flip==0){
            me.update_ET();
        }else{
            me.update_FT();
        }
        if(me.MODE ==0){
            me.HR.setValue(getprop("/instrumentation/clock/indicated-hour"));
            me.MN.setValue(getprop("/instrumentation/clock/indicated-min"));
        }elsif(me.MODE == 1) {
            me.HR.setValue(getprop("/instrumentation/clock/local-hour"));
            me.MN.setValue(getprop("/instrumentation/clock/indicated-min"));
        }elsif(me.MODE == 2) {
            me.HR.setValue(me.FT_HR.getValue());
            me.MN.setValue(me.FT_MN.getValue());
        }elsif(me.MODE == 3) {
            me.HR.setValue(me.ET_HR.getValue());
            me.MN.setValue(me.ET_MN.getValue());
        }
        if(me.set_mode==1){
            var flsh=me.digit[me.digit_to_set].getValue();
            flsh=1-flsh;
            me.digit[me.digit_to_set].setValue(flsh);
        }else{
            me.digit[me.digit_to_set].setValue(1);
        }
        me.flip=1-me.flip;
    },
};
#####################################

var astrotech=lc2.new("instrumentation/clock/lc2");


setlistener("/sim/signals/fdm-initialized", func {
    settimer(update,2);
    print("Astro Tech LC-2 Chronometer ... Check");
});

var update = func{
astrotech.update_clock();
settimer(update,0.5);
}
