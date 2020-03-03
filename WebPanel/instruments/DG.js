$('#DG').on('updateValue', function(event, step, clickedArea) {
    var property = fgPanel.mirror.mirror.headingBug;
    var newValue = 0;
    if(clickedArea === 0) {
      newValue = (property.value || 0) - step;
    } else {
      newValue = (property.value || 0) + step;
    }
    if(newValue > 360) {
      newValue -= 360;
    } else if (newValue < 0) {
        newValue += 360;
    }
    setPropertyRemoteAndLocally(property, newValue);
});