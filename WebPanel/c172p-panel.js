
// Fixes the original FGFS.TextAnimation:
//
// 1. Allow declaring precison in the configuration file. The default precision is 4, but most our text
// animations are frequencies and they MUST have precision 6 (COMM, NAV) or 3 (ADF)
// Fix fgfs.js by allowing .json  files to define precision for their values
// For backwards compatibility, if a precision is not defined, the default value in FGFS.InputValue is used.
//
// 2. The standard JavaScript Number.toPrecission, used by InputValue, may return numbers in exponential
// notation. User a custom format function to prevent this.
FGFS.TextAnimation = function(arg) {
  this.__proto__ = new FGFS.Animation(arg);
  this.text = new FGFS.InputValue({property: arg.text, precision: (arg.precision || null)});
  
  this.text.getFormatted = function( value ) {
    let formatted = value.toPrecision(this.precision);
    // manage exponential notation. This assumes JavaScript returns an exponential representation
    // if the value is too big or too small
    if(formatted.includes('e+')) {
      // if formatted includes the string 'e+', return '-' times precission
      if(this.precision) {
        return '-'.repeat(this.precision)
      } else {
        return '-'
      }
    } else if(formatted.includes('e-')) {
      return 0
    }
    return formatted
  }

  this.makeAnimation = function() {
    var reply = {
      type: 'text',
      text: this.text.getValue(),
    };
    return reply;
  }
}

// PropertyListener only updates values in the PropertyMirror if the value is changed between the updating period
// A value updated (sent) at the same time than the property is read never changes locally. This happens often.
// To cope with this, set the new value both in FlightGear and in our local copy of the property
function setPropertyRemoteAndLocally(property, newValue) {
    fgPanel.mirror.listener.setProperty(property.path, newValue);
    property.value = newValue;
}

$(document).ready(function(){
  let clickedArea = 0;
  let updateInstrumentTimer = null;
  let selectedInstrument = null;

  // trigger periodically update events if an instrument is selected (mousedown) 
  function updateInstrumentInterval() {
    if(selectedInstrument !== null) {
      selectedInstrument.trigger("updateValue", [2, clickedArea, "maintained"]);
      updateInstrumentTimer = setTimeout(updateInstrumentInterval, 25);
    }
  }

  // get clicked area based on defined cols and rows: top-left=0
  function calculateClickedArea(x, y, instrument) {
    let instrumentOffset = instrument.offset();
    let cols = parseInt(instrument.data('fgpanel-cols') || 1);
    let rows = parseInt(instrument.data('fgpanel-rows') || 1);
    let clickedCol = Math.floor(cols * (x - instrumentOffset.left) / instrument.outerWidth());
    let clickedRow = Math.floor(rows * (y - instrumentOffset.top) / instrument.outerHeight());
    return clickedRow * cols + clickedCol;
  }

  $('.instrument').on("mousedown", function (event) {
    event.stopImmediatePropagation();
    if(selectedInstrument !== null) {
        console.log('Warning! An instrument was clicked while another is selected.');
        return;
    }
    selectedInstrument = $(event.currentTarget);
    clickedArea = calculateClickedArea(event.pageX, event.pageY, selectedInstrument);
    // first timer is 500 milliseconds to prevent triggering bulk updates on short clicks
    updateInstrumentTimer = setTimeout(updateInstrumentInterval, 500);
  });
  // touchable screens have a touchstart event: long clicks trigger touchstart but NOT mousedown
  $('.instrument').on("touchstart", function (event){
    if(updateInstrumentTimer === null) {
      selectedInstrument = $(event.currentTarget);
      clickedArea = calculateClickedArea(event.pageX, event.pageY, selectedInstrument);
      updateInstrumentTimer = setTimeout(updateInstrumentInterval, 500);
    }
  });

  $('.instrument').on("mouseup", function (event){
    event.stopImmediatePropagation();
    if(selectedInstrument !== null) {
      selectedInstrument.trigger('updateValue', [1, clickedArea, "released"]);
      selectedInstrument = null;
      if(updateInstrumentTimer !== null) {
        clearTimeout(updateInstrumentTimer);
        updateInstrumentTimer = null;
      }
    }
  });
  // touchable screens have a touchend event: long clicks trigger touchend but NOT mouseup
  $('.instrument').on("touchend", function (event){
    if(updateInstrumentTimer !== null) {
      clearTimeout(updateInstrumentTimer);
      updateInstrumentTimer = null;
    }
  });
});

window.onerror = function(message, source, lineno, colno, error) {
  $('#log').append(message + '-' + source + '-' + lineno + '-' + colno + '-' + error);
}
