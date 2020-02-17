$('#ADF').on('updateValue', function(event, step, clickedArea) {
    let property = fgPanel.mirror.mirror['adf-rotation-deg'];
    var newValue = 0;
    if(clickedArea === 0) {
        newValue = (property.value || 0) - step;
    } else {
        newValue = (property.value || 0) + step;
    }
    setPropertyRemoteAndLocally(property, newValue);
});