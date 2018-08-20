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
        m.et_frozen=0;
        m.et_offset=0;
        m.et_elapsed=0;
        m.et_pause_time=0;
        m.ft_running=0;
        m.modetext =["LT","ET"];
        m.lc2 = props.globals.initNode(prop1);
        m.fmeter_sec=m.lc2.initNode("flight-meter-sec",0,"DOUBLE");
        m.fmeter=aircraft.timer.new(m.fmeter_sec,1,1);
        m.tenths=m.lc2.initNode("tenths",0,"BOOL");
        m.ET_alarm=m.lc2.initNode("et-alarm",0,"BOOL");
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
        return m;
    },
    
#### displayed mode  ####
    select_mode : func(){
        if(me.set_mode==0){
            me.MODE +=1;
            if(me.MODE>1)me.MODE -=2;
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
    left_knob : func(){
        if(me.MODE==1){
            if(me.et_running==0 and me.et_frozen==1){ # reset
                    me.et_start_time = getprop("/sim/time/elapsed-sec");
                    me.et_frozen=0;
                    me.et_offset=0;
                    me.et_elapsed=0;
                    me.et_running=0;
            }
        } else {
            me.set_mode=1-me.set_mode;
        }
    },
#### CTL button action ####
    right_knob : func(){
        if(me.set_mode==0){
            if(me.MODE==0){
                me.MODE=2;
                settimer(func(){
                    me.MODE=0;
                },1.5);
            }elsif(me.MODE==1){
                if(me.et_running==0 and me.et_frozen==0){ # start
                    me.et_start_time=getprop("/sim/time/elapsed-sec");
                    me.et_running=1;
                }elsif(me.et_frozen==0 and me.et_running==1){ # pause
                    me.et_running=0;
                    me.et_frozen=1;
                    me.et_pause_time=getprop("/sim/time/elapsed-sec");
                }elsif(me.et_frozen==1 and me.et_running==0){ # unpause
                    me.et_start_time=me.et_start_time + me.et_offset;
                    me.et_pause_time=0;
                    me.et_running=1;
                    me.et_frozen=0;
                }
            }
        }else{
            if(me.MODE==0){
                me.set_lt();
            }
        }
    },

#### set LT  ####
    set_lt : func(){
    # TODO
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

#### update clock  ####
    update_clock : func{
        var pwr=me.power.getValue();
        if(me.set_mode==0 and me.et_frozen==0){
            pwr=1-pwr;
        }else{
            pwr=1;
        }
        me.power.setValue(pwr);
        
        if (me.et_frozen==1) {
            me.et_offset=getprop("/sim/time/elapsed-sec") - me.et_pause_time;
        }
        if(me.flip==0){
            me.update_ET();
        }
        
        if(me.MODE == 0){
            me.HR.setValue(getprop("/instrumentation/clock/local-hour"));
            me.MN.setValue(getprop("/instrumentation/clock/indicated-min"));
        }elsif(me.MODE==1){
            me.HR.setValue(me.ET_HR.getValue());
            me.MN.setValue(me.ET_MN.getValue());
        }elsif(me.MODE==2){
            me.HR.setValue(getprop("/sim/time/real/month"));
            me.MN.setValue(getprop("/sim/time/real/day"));
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
    print("Astro Tech LC-2 Chronometer Loaded");
});

var update = func{
astrotech.update_clock();
settimer(update,0.5);
}


