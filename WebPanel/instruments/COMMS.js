
$('#COMMS').on('updateValue', function(event, step, clickedArea) {
    let property;
    let newValue;
    switch(clickedArea) {
    case 3: // switch COMM1
        newValue = fgPanel.mirror.mirror.comm1_standby.value
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.comm1_standby, fgPanel.mirror.mirror.comm1_selected.value)
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.comm1_selected, newValue)
        break;
    case 4: // COMM1 down        
        property = fgPanel.mirror.mirror.comm1_standby;
        // we force steps of 0.00833 MHz for now
        newValue = property.value - step * 0.00833;
        newValue = Math.min(Math.max(118, newValue), 137);
        setPropertyRemoteAndLocally(property, newValue)
        break;
    case 5: // COMM1 up
        property = fgPanel.mirror.mirror.comm1_standby;
        newValue = property.value + step * 0.00833;
        newValue = Math.min(Math.max(118, newValue), 137);
        setPropertyRemoteAndLocally(property, newValue)
        break;
    case 9: // switch NAV1
        newValue = fgPanel.mirror.mirror.nav1_standby.value;
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.nav1_standby, fgPanel.mirror.mirror.nav1_selected.value);
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.nav1_selected, newValue);
        break;
    case 10: // NAV1 down
        property = fgPanel.mirror.mirror.nav1_standby;
        // steps of 0.025 Mhz
        newValue = property.value - step * 0.025;
        newValue = Math.min(Math.max(108, newValue), 117.950);
        setPropertyRemoteAndLocally(property, newValue);
        break;
    case 11: // NAV1 up
        property = fgPanel.mirror.mirror.nav1_standby;
        newValue = property.value + step * 0.025;
        newValue = Math.min(Math.max(108, newValue), 117.950);
        setPropertyRemoteAndLocally(property, newValue);
        break;
    case 15: // switch COMM2
        newValue = fgPanel.mirror.mirror.comm2_standby.value;
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.comm2_standby, fgPanel.mirror.mirror.comm2_selected.value);
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.comm2_selected, newValue);
    case 16: // COMM2 down        
        property = fgPanel.mirror.mirror.comm2_standby;
        newValue = property.value - step * 0.00833;
        newValue = Math.min(Math.max(118, newValue), 137);
        setPropertyRemoteAndLocally(property, newValue);
        break;
    case 17: // COMM2 up
        property = fgPanel.mirror.mirror.comm2_standby;
        newValue = property.value + step * 0.00833;
        newValue = Math.min(Math.max(118, newValue), 137);
        setPropertyRemoteAndLocally(property, newValue);
        break;
    case 21: // switch NAV2
        newValue = fgPanel.mirror.mirror.nav2_standby.value;
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.nav2_standby, fgPanel.mirror.mirror.nav2_selected.value);
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.nav2_selected, newValue);
        break;
    case 22: // NAV2 down
        property = fgPanel.mirror.mirror.nav2_standby;
        newValue = property.value - step * 0.025;
        newValue = Math.min(Math.max(108, newValue), 117.950);
        setPropertyRemoteAndLocally(property, newValue);
        break;
    case 23: // NAV2 up
        property = fgPanel.mirror.mirror.nav2_standby;
        newValue = property.value + step * 0.025;
        newValue = Math.min(Math.max(108, newValue), 117.950);
        setPropertyRemoteAndLocally(property, newValue);
        break;
    }
});

