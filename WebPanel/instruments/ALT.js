$('#ALT').on('updateValue', function(event, step, clickedArea) {
    var property = fgPanel.mirror.mirror.inhg;
    var newValue = 0;
    if(clickedArea === 0) {
        newValue = (property.value || 0) - step / 100;
    } else {
        newValue = (property.value || 0) + step / 100;
    }
    newValue = Math.min(Math.max(newValue, 28.0), 31.1);
    setPropertyRemoteAndLocally(property, newValue);
});
