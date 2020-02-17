$('#SWITCHES').on('updateValue', function(event, step, clickedArea, action) {
    if (action === "maintained") return;
    let property;
    switch(clickedArea) {
    case 0: case 1: // FLAPS up
        property = fgPanel.mirror.mirror.flaps
        setPropertyRemoteAndLocally(property, Math.min(property.value - 0.3334, 1))
        break;
    case 7: case 8: // FLAPS down
        property = fgPanel.mirror.mirror.flaps
        setPropertyRemoteAndLocally(property, Math.min(property.value + 0.3334, 1))
        break;
    case 2: // taxi on
        property = fgPanel.mirror.mirror.taxi_light
        setPropertyRemoteAndLocally(property, true)
        break;
    case 9: // taxi off
        property = fgPanel.mirror.mirror.taxi_light
        setPropertyRemoteAndLocally(property, false)
        break;
    case 3: // landing on
        property = fgPanel.mirror.mirror.landing_light
        setPropertyRemoteAndLocally(property, true)
        break;
    case 10: // landing off
        property = fgPanel.mirror.mirror.landing_light
        setPropertyRemoteAndLocally(property, false)
        break;
    case 4: // nav on
        property = fgPanel.mirror.mirror.nav_light
        setPropertyRemoteAndLocally(property, true)
        break;
    case 11: // nav off
        property = fgPanel.mirror.mirror.nav_light
        setPropertyRemoteAndLocally(property, false)
        break;
    case 5: // beacon on
        property = fgPanel.mirror.mirror.beacon_light
        setPropertyRemoteAndLocally(property, true)
        break;
    case 12: // beacon off
        property = fgPanel.mirror.mirror.beacon_light
        setPropertyRemoteAndLocally(property, false)
        break;
    case 6: // strobe on
        property = fgPanel.mirror.mirror.strobe_light
        setPropertyRemoteAndLocally(property, true)
        break;
    case 13: // strobe off
        property = fgPanel.mirror.mirror.strobe_light
        setPropertyRemoteAndLocally(property, false)
        break;
    }
});

