# Code to handle 8.33 khz for the KX165A radio
var increment = func(index, direction) {
    var selector = getprop("instrumentation/comm[" ~ index ~ "]/channel-mode-selector");
    if (selector == 1) {
        setprop("instrumentation/comm[" ~ index ~ "]/frequencies/standby-channel", getprop("instrumentation/comm[" ~ index ~ "]/frequencies/standby-channel") + direction);
    } elsif (selector == 0) {
        setprop("instrumentation/comm[" ~ index ~ "]/frequencies/standby-channel", getprop("instrumentation/comm[" ~ index ~ "]/frequencies/standby-channel") + (direction * 4));
    }
}

setlistener("/instrumentation/comm[0]/channel-mode-selector", func() {
    if (getprop("/instrumentation/comm[0]/channel-mode-selector") == 0) {
        var result = math.round(getprop("/instrumentation/comm[0]/frequencies/standby-channel") / 4) * 4;
        setprop("/instrumentation/comm[0]/frequencies/standby-channel", result);
        
        var result = math.round(getprop("/instrumentation/comm[0]/frequencies/selected-channel") / 4) * 4;
        setprop("/instrumentation/comm[0]/frequencies/selected-channel", result);
    }
}, 0, 0);

setlistener("/instrumentation/comm[1]/channel-mode-selector", func() {
    if (getprop("/instrumentation/comm[1]/channel-mode-selector") == 0) {
        var result = math.round(getprop("/instrumentation/comm[1]/frequencies/standby-channel") / 4) * 4;
        setprop("/instrumentation/comm[1]/frequencies/standby-channel", result);
        
        var result = math.round(getprop("/instrumentation/comm[1]/frequencies/selected-channel") / 4) * 4;
        setprop("/instrumentation/comm[1]/frequencies/selected-channel", result);
    }
}, 0, 0);

var hackListener = setlistener("/sim/signals/fdm-initialized", func() {
    # a dirty hack but it works. It triggers the above setlisteners on startup (passing the startup argument did not work) 
    # in case a 8.33 frequency has been saved but 25k is selected on startup
    var selector = getprop("instrumentation/comm[0]/channel-mode-selector");
    setprop("/instrumentation/comm[0]/channel-mode-selector", 2);
    setprop("/instrumentation/comm[0]/channel-mode-selector", selector);
    var selector = getprop("instrumentation/comm[1]/channel-mode-selector");
    setprop("/instrumentation/comm[1]/channel-mode-selector", 2);
    setprop("/instrumentation/comm[1]/channel-mode-selector", selector);
    
    # after the first startup we don't need this
    removelistener(hackListener);
});