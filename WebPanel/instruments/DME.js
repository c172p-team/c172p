$('#DME').on('updateValue', function(event, step, clickedArea) {
    // only two clickable area: the switch up and down
    let property = fgPanel.mirror.mirror.dme_switch;
    let newValue = 0;
    let oldValue = 0;
    if(clickedArea === 0) {
      oldValue = property.value;
      newValue = (oldValue || 0) - step;
      newValue = Math.min(Math.max(1, newValue), 3);
      changed = true;
    } else if(clickedArea === 1) {
      oldValue = property.value;
      newValue = (oldValue || 0) + step;
      newValue = Math.min(Math.max(1, newValue), 3);
      changed = true;
    }

    if (oldValue !== newValue) {
        setPropertyRemoteAndLocally(property, newValue);

        // the DME used on the c172p needs changing manually the selected DME frequency.
        switch(newValue){
        case 1:
            fgPanel.mirror.listener.setProperty("/instrumentation/dme/frequencies/source", "/instrumentation/nav[0]/frequencies/selected-mhz");
            break;
        case 2:
            fgPanel.mirror.listener.setProperty("/instrumentation/dme/frequencies/source", "/instrumentation/dme/frequencies/selected-mhz");
            break;
        case 3:
            fgPanel.mirror.listener.setProperty("/instrumentation/dme/frequencies/source", "/instrumentation/nav[1]/frequencies/selected-mhz");
            break;
        }
    }
});
