$('#EGT').on('updateValue', function(event, step, area) {
    let property = fgPanel.mirror.mirror.egtBug;
    let newValue = 0;
    if(area == 0 || area == 3) {
        newValue = (property.value || 0) - step / 100;
    } else {
        newValue = (property.value || 0) + step / 100;
    }
    newValue = Math.min(Math.max(newValue, 0.0), 1.0);
    setPropertyRemoteAndLocally(property, newValue);
});