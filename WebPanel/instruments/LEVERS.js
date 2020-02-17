$('#LEVERS').on('updateValue', function(event, step, clickedArea, action) {
    let property;
    let newValue;
    switch(clickedArea) {
    case 0: case 3: // toggle carb heat
        property = fgPanel.mirror.mirror.carb_heat_lever
        newValue = !property.value
        setPropertyRemoteAndLocally(property, newValue)
        break;
    case 1: // open throttle
        property = fgPanel.mirror.mirror.throttle_lever
        newValue = Math.min(1, property.value + 0.05)
        setPropertyRemoteAndLocally(property, newValue)
        break;
    case 4: // close throttle
        property = fgPanel.mirror.mirror.throttle_lever
        newValue = Math.max(0, property.value - 0.05)
        setPropertyRemoteAndLocally(property, newValue)
        break;
    case 2: // rich mixture
        property = fgPanel.mirror.mirror.mixture_lever
        newValue = Math.min(1, property.value + 0.05)
        setPropertyRemoteAndLocally(property, newValue)
        break;
    case 5: // lean mixture
        property = fgPanel.mirror.mirror.mixture_lever
        newValue = Math.max(0, property.value - 0.05)
        setPropertyRemoteAndLocally(property, newValue)
        break;
    }
});

