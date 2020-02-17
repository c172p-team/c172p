$('#START').on('updateValue', function(event, step, clickedArea, action) {
    if (action === "maintained") {
        if(clickedArea === 2 || clickedArea === 8) {
            if(fgPanel.mirror.mirror.magnetos.value === 3) {
                // starter ON
                // Warning: 4 works for animations both in FG and the panel, but it does have any real meaning
                setPropertyRemoteAndLocally(fgPanel.mirror.mirror.magnetos, 4)
                setPropertyRemoteAndLocally(fgPanel.mirror.mirror.starter, true)
            }
        }
        return
    }
    let property;
    let newValue;
    switch(clickedArea) {
    case 3: // master bat ON
        property = fgPanel.mirror.mirror.master_bat
        setPropertyRemoteAndLocally(property, true)
        break;
    case 9: // master bat OFF
        property = fgPanel.mirror.mirror.master_bat
        setPropertyRemoteAndLocally(property, false)
        break;
    case 4: // master alt ON
        property = fgPanel.mirror.mirror.master_alt
        setPropertyRemoteAndLocally(property, true)
        break;
    case 10: // master alt OFF
        property = fgPanel.mirror.mirror.master_alt
        setPropertyRemoteAndLocally(property, false)
        break;
    case 5: // master avionics ON
        property = fgPanel.mirror.mirror.master_avionics
        setPropertyRemoteAndLocally(property, true)
        break;
    case 11: // master avionics OFF
        property = fgPanel.mirror.mirror.master_avionics
        setPropertyRemoteAndLocally(property, false)
        break;
    case 2: case 8: // magnetos +1
        property = fgPanel.mirror.mirror.magnetos
        newValue = Math.min(property.value + 1, 3)
        // starter OFF no matter what
        setPropertyRemoteAndLocally(fgPanel.mirror.mirror.starter, false)
        setPropertyRemoteAndLocally(property, newValue)
        break;
    case 1: case 7: // magnetos -1
        property = fgPanel.mirror.mirror.magnetos        
        newValue = Math.max(property.value - 1, 0)
        if(newValue == 3) {
            setPropertyRemoteAndLocally(fgPanel.mirror.mirror.starter, false)
        }
        setPropertyRemoteAndLocally(property, newValue)
        break;
    case 0: case 6: // primer
        property = fgPanel.mirror.mirror.primer_lever
        newValue = !property.value
        if(!newValue) {
            // In FG, Nasal does this. We must prime manually
            setPropertyRemoteAndLocally(fgPanel.mirror.mirror.primer, fgPanel.mirror.mirror.primer.value + 1)    
        }
        setPropertyRemoteAndLocally(property, newValue)
        break;
    }
});

