$('#VOR1').on('updateValue', function(event, step, clickedArea) {
    let property = fgPanel.mirror.mirror.CourseVOR1;
    let newValue = 0;
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
    setPropertyRemoteAndLocally(property, newValue)
    fgPanel.mirror.listener.setProperty(property.path, newValue);
});

$('#VOR2').on('updateValue', function(event, step, clickedArea) {
    let property = fgPanel.mirror.mirror.CourseVOR2;
    let newValue = 0;
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
    setPropertyRemoteAndLocally(property, newValue)
    fgPanel.mirror.listener.setProperty(property.path, newValue);
});
