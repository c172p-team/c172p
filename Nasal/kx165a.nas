# Code to handle 8.33 khz for the KX165A radio

var increment = func(index, direction) {
    if (direction != -1 and direction != 1) {
        print("Invalid direction call on line 13, kx165a.nas");
        return;
    }
    
    var standbyFreq = getprop("instrumentation/comm[" ~ index ~ "]/frequencies/standby-mhz");
    var selector = getprop("instrumentation/comm[" ~ index ~ "]/channel-mode-selector");
    
    if (standbyFreq == nil or selector == nil) {
        print("Non-existent properties on line 13, kx165a.nas");
        return;
    }
    
    if (standbyFreq < 118.0) {
        setprop("instrumentation/comm[" ~ index ~ "]/frequencies/standby-mhz", 118.0);
        return;
    } elsif (standbyFreq > 136.990 and selector) {
        setprop("instrumentation/comm[" ~ index ~ "]/frequencies/standby-mhz", 136.990);
        return;
    } elsif (standbyFreq > 136.975 and !selector) {
        setprop("instrumentation/comm[" ~ index ~ "]/frequencies/standby-mhz", 136.975);
        return;
    }
    
    var end = substr(sprintf("%s", standbyFreq), 5, 2);
    
    var incrementBy = 0.005;
    if (selector) {
        if (end == "14" or end == "15" or end == "39" or end =="40" or end == "64" or end == "65" or end == "89" or end == "90") { # take into account floating point precision loss
            incrementBy = direction * incrementBy * 2;
        } else {
            incrementBy = direction * incrementBy;
        }
    } else {
        incrementBy = direction * incrementBy * 5;
    }
    
    setprop("instrumentation/comm[" ~ index ~ "]/frequencies/standby-mhz", standbyFreq + incrementBy);
}

setlistener("instrumentation/comm[0]/channel-mode-selector", func() {
    var standbyFreq = getprop("instrumentation/comm[0]/frequencies/standby-mhz");
    var selector = getprop("instrumentation/comm[0]/channel-mode-selector");
    
    if (!selector) {
        if (standbyFreq > 136.975) {
            setprop("instrumentation/comm[0]/frequencies/standby-mhz", 136.975);
        }
    }
}, 0, 0);

setlistener("instrumentation/comm[1]/channel-mode-selector", func() {
    var standbyFreq = getprop("instrumentation/comm[1]/frequencies/standby-mhz");
    var selector = getprop("instrumentation/comm[1]/channel-mode-selector");
    
    if (!selector) {
        if (standbyFreq > 136.975) {
            setprop("instrumentation/comm[1]/frequencies/standby-mhz", 136.975);
        }
    }
}, 0, 0);

print("KX165A radio initialized");