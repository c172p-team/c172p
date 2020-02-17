// the ADF freqs go from 200 to 1799 KHz. AFAIK, freqs higher than 800 are rare, and using only three digits simplifies rendering

$('#ADFCOMMS').on('updateValue', function(event, step, clickedArea) {
    let property;
    let newValue;
    switch(clickedArea) {
    case 3: // switch ADF
        newValue = fgPanel.mirror.mirror.adf_standby.value;
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.adf_standby, fgPanel.mirror.mirror.adf_selected.value);
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.adf_selected, newValue);
        break;
    case 4: // ADF down        
        property = fgPanel.mirror.mirror.adf_standby;
        newValue = property.value - step;
        newValue = Math.min(Math.max(200, newValue), 999);
        setPropertyRemoteAndLocally(property, newValue);
        break;
    case 5: // ADF up
        property = fgPanel.mirror.mirror.adf_standby;
        newValue = property.value + step;
        newValue = Math.min(Math.max(200, newValue), 999);
        setPropertyRemoteAndLocally(property, newValue);
        break;
    }
});

