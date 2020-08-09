
const SECONDS_FOR_DIGITS = 3;
const MILLISECONDS_FOR_UPDATES = 200;

$(document).ready(function (){
    // when the document is ready, check the KAP is present and start it
    let kap140 = new KAP140();
    // if this property exists, we assume it is the new KAP140
    $.get('/json/autopilot/kap140/config', (data) => {        
        let baro_tied = kap140.propsToObject(data)['baro-tied'];
        kap140.baro_tied = baro_tied;
        setTimeout(updateKAP140, MILLISECONDS_FOR_UPDATES, new KAP140());
    }).fail(() => {
        alert('KAP140 not present ot not compatible');
        $('#KAP140').css('display', 'none');
    });
})

function updateKAP140(kap140) {
    // data in the KAP140 is updated every MILLISECONS_FOR_UPDATES
    kap140.updateData()
    setTimeout(updateKAP140, MILLISECONDS_FOR_UPDATES, kap140);
}


class KAP140 {
    constructor () {
        let self = this;

        $('#KAP140').on('updateValue',async function(event, step, clickedArea) {
            switch(clickedArea) {
                case 25: case 16: self.knobRotated(-step); break;
                case 26: case 17: self.knobRotated(step); break;
            }
        });
        $('#kap140btnap').click(async function () {
            fgCommand.propertyAssign('/autopilot/kap140/panel/button-ap', 0.01);
            if(self.panel.state > 4) {
                fgCommand.propertyAssignProp('/autopilot/kap140/panel/state-old', '/autopilot/kap140/panel/state');
            }
            // we check state-old because we have not changed the internal state yet
            if(self.panel['state-old'] > 4) {
                fgCommand.propertyAssignProp('/autopilot/internal/target-climb-rate', '/autopilot/internal/vert-speed-fpm');
            } 
        });
        $('#kap140btnhdg').click(async function () {
            // HDG/ROL mode
            // Sequential logic in AP dialog:
            // state === 6 && lateral-mode > 1 -> lateral-mode = -1
            // state === 6 && lateral-mode > 0 -> lateral-mode = 2
            // state === 6 && lateral-mode === -1 -> lateral-mode = 1
            if(self.panel.state === 6) {
                if(self.settings['lateral-mode'] > 1) {
                    fgCommand.propertyAssign('autopilot/kap140/settings/lateral-mode', 1);
                } else {
                    fgCommand.propertyAssign('autopilot/kap140/settings/lateral-mode', 2);
                }
            }
            // these properties are always set
            fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 0);
            fgCommand.propertyAssign('autopilot/internal/target-roll-deg', 0);
            fgCommand.propertyAssign('autopilot/internal/target-intercept-angle', 0);
            fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 0);
            fgCommand.propertyAssign('autopilot/kap140/panel/nav-timer', 0);
        });
        $('#kap140btnnav').click(async function () {
            // NAV mode
            // Sequential logic in AP dialog:
            // state === 6 && lateral-mode != 3 && lateral-arm === 1 -> lateral-arm = -1
            // state === 6 && lateral-mode != 3 && lateral-arm > -1 -> lateral-arm = 1
            // state === 6 && lateral-mode != 3 && lateral-arm === -1 -> lateral-arm = 0
            // state === 6 && lateral-arm === 1 && !hsi-installed -> hdg-timer <=> elapsed-secs
            // state === 6 && lateral-arm === 0 -> hdg-timer = 0
            // nav-timer = 0
            if(self.panel.state === 6) {
                if(self.settings['lateral-mode'] !== 3) {
                    if(self.settings['lateral-arm'] === 1) {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 0);
                        fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 0);
                    } else {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 1);
                        // we asume a HSI is never installed
                        fgCommand.propertyAssignProp('/autopilot/internal/target-climb-rate', '/autopilot/internal/vert-speed-fpm');
                    }
                }
            }
            fgCommand.propertyAssign('autopilot/kap140/panel/nav-timer', 0);
        });
        $('#kap140btnapr').click(async function () {
            // APR mode
            // Sequential logic in AP dialog:
            // state === 6 && lateral-mode != 4 && lateral-arm === 2 -> lateral-arm = -1
            // state === 6 && lateral-mode != 4 && lateral-arm > -1 -> lateral-arm = 2
            // state === 6 && lateral-mode != 4 && lateral-arm === -1 -> lateral-arm = 0
            // state === 6 && lateral-arm === 2 && !hsi-installed -> hdg-timer <=> elapsed-secs
            // state === 6 && lateral-arm === 0 -> hdg-timer = 0
            // nav-timer = 0
            if(self.panel.state === 6) {
                if(self.settings['lateral-mode'] !== 4) {
                    if(self.settings['lateral-arm'] === 2) {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 0);
                        fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 0);
                    } else {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 2);
                        // we asume a HSI is never installed
                        fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 'sim/time/elapsed-sec');
                    }
                }
            }
            fgCommand.propertyAssign('autopilot/kap140/panel/nav-timer', 0);
        });
        $('#kap140btnrev').click(async function () {
            // REV mode
            // Sequential logic in AP dialog:
            // state === 6 && lateral-mode != 5 && lateral-arm === 3 -> lateral-arm = -1
            // state === 6 && lateral-mode != 5 && lateral-arm > -1 -> lateral-arm = 3
            // state === 6 && lateral-mode != 5 && lateral-arm === -1 -> lateral-arm = 0
            // state === 6 && lateral-arm === 3 && !hsi-installed -> hdg-timer <=> elapsed-secs
            // state === 6 && lateral-arm === 0 -> hdg-timer = 0
            // nav-timer = 0
            if(self.panel.state === 6) {
                if(self.settings['lateral-mode'] !== 5) {
                    if(self.settings['lateral-arm'] === 3) {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 0);
                        fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 0);
                    } else {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 3);
                        // we asume a HSI is never installed
                        fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 'sim/time/elapsed-sec');
                    }
                }
            }
            fgCommand.propertyAssign('autopilot/kap140/panel/nav-timer', 0);
        });
        $('#kap140btnalt').click(async function () {
            // ALT mode
            // Sequential logic in AP dialog:
            // vertical-mode > 1 -> vertical-mode = 0
            // vertical-mode === 1 -> vertical-mode = 2
            // state === 6 && vertical-mode === 0 -> vertical-mode = 1
            // vertical-mode === 1 -> target-pressure = 0.0
            // vertical-mode === 2 -> target-pressue = pressure-inhg
            if(self.settings['vertical-mode'] === 2) {
                if(self.panel.state === 6) {
                    fgCommand.propertyAssign('autopilot/kap140/settings/vertical-mode', 1);
                }
                fgCommand.propertyAssign('autopilot/internal/target-pressure', 0);
            } else {
                fgCommand.propertyAssign('autopilot/kap140/settings/vertical-mode', 2);
                fgCommand.propertyAssignProp('autopilot/internal/target-pressure', '/environment/pressure-inhg');
            }
        });
        $('#kap140btndown').click(async function () {
            // DOWN button
            // Sequential logic in AP dialog:
            // state === 6 && vertical-mode === 1 -> target-climb-rate -= 100 (min=-2000)
            // fpm-old = target-climb-rate
            // state === 6 && vertical-mode === 2 -> target-pressure += 0.022 (max=35)            
            if(self.panel.state === 6) {
                if(self.settings['vertical-mode'] === 1) {
                    self.modeButtonClicked(2);
                    let newvalue = Math.max(self.internal['target-climb-rate'] - 100, -2000);
                    fgCommand.propertyAssign('autopilot/internal/target-climb-rate', newvalue);
                } else if(self.settings['vertical-mode'] === 2) {
                    let newvalue = Math.min(self.internal['target-pressure'] + 0.022, 35);
                    self.modeButtonClicked(1);
                    fgCommand.propertyAssign('autopilot/internal/target-pressure', newvalue);
                }
            }
            fgCommand.propertyAssignProp('autopilot/kap140/panel/fpm-old', 'autopilot/internal/target-climb-rate');
        });
        $('#kap140btnup').click(async function () {
            // UP Button
            // Sequential logic in AP dialog:
            // state === 6 && vertical-mode === 1 -> target-climb-rate += 100 (max=2000)
            // fpm-old = target-climb-rate
            // state === 6 && vertical-mode === 2 -> target-pressure -= 0.022 (min=5)
            if(self.panel.state === 6) {
                if(self.settings['vertical-mode'] === 1) {
                    self.modeButtonClicked(2);
                    let newvalue = Math.min(self.internal['target-climb-rate'] + 100, 2000);
                    console.log(newvalue)
                    fgCommand.propertyAssign('autopilot/internal/target-climb-rate', newvalue);
                } else if(self.settings['vertical-mode'] === 2) {
                    self.modeButtonClicked(1);
                    let newvalue = Math.max(self.internal['target-pressure'] - 0.022, 5);
                    console.log(newvalue)
                    fgCommand.propertyAssign('autopilot/internal/target-pressure', newvalue);
                }
            }
            fgCommand.propertyAssignProp('autopilot/kap140/panel/fpm-old', 'autopilot/internal/target-climb-rate');
        });
        $('#kap140btnarm').click(async function () {
            // ALT ARM mode
            // Sequential logic in AP dialog:
            // state === 6 && vertical-mode < 3 && vertical-arm < 2 -> vertical-arm = ! vertical-arm
            if(self.panel.state === 6 && self.settings['vertical-mode'] < 3 && self.settings['vertical-arm'] < 2) {
                if(self.settings['vertical-arm'] === 0) {
                    fgCommand.propertyAssign('autopilot/kap140/settings/vertical-arm', 1);
                } else {
                    fgCommand.propertyAssign('autopilot/kap140/settings/vertical-arm', 0);
                }
            }
        });
        $('#kap140btnbaro').click(async function () {
            // BARO mode
            // Sequential logic in AP dialog:
            // state > 3 -> baro-mode != baro-mode
            // !baro-tied && state === 4 -> state = 5
            // BUT in this panel we must follow the model logic, since
            // we are using a single knob to control both baro and altitude
            // THEN:
            // state === 6 -> imControllingDigit = 3
            if(self.panel.state > 3) {
                if(self.panel['baro-mode'] === 0) {
                    fgCommand.propertyAssign('autopilot/kap140/panel/baro-mode', 1);
                } else {
                    fgCommand.propertyAssign('autopilot/kap140/panel/baro-mode', 0);
                }                
            }
            if(self.panel.state === 6) {
                self.modeButtonClicked(3);
            }
            if(!self.baro_tied && self.panel.state === 4) {
                fgCommand.propertyAssign('autopilot/kap140/panel/state', 5);
            }
        });

        $('#kap140-ptup').addClass('blinking', true);
        $('#kap140-ptdown').addClass('blinking', true);
    }    

    knobRotated(change) {
        // get the event "the knob was rotated". Check the currently selected digit, and
        // change altitude or baro accordingly
        let digitMode = (this.imControllingDigit > 0?this.imControllingDigit:this.panel['digit-mode']);
        switch(digitMode) {
            case 1: this.changeAltitude(change); break;
            case 3: this.changeBaro(change); break;
        }
    }

    changeAltitude(change) {
        // logic in the dialog:
        // state > 4 -> target-altitude += 1000 (min=-1000, max=35000)
        // state > 5 && vertical-arm === 0 -> vertical-arm = 1
        this.modeButtonClicked(1);
        console.log(change);
        if(this.panel.state > 4) {
            let newvalue = Math.max(Math.min(this.internal['target-altitude'] + change * 100, 35000), -1000);
            fgCommand.propertyAssign('autopilot/internal/target-altitude', newvalue);
        }
        if(this.panel.state > 5 && this.settings['vertical-arm'] === 0) {
            fgCommand.propertyAssign('autopilot/kap140/settings/vertical-arm', 1);
        }
    }

    changeBaro(change) {
        // Logic in the dialog
        // !baro-tied && state > 3 && baro-mode === 0 -> baro-inhg += change*0.01 (min=26, max=33)
        // !baro-tied && state > 3 && baro-mode === 1 -> baro-inhg += change (min=880, max=1118)
        // !baro-tied && state === 4 && state = 5
        if(this.baro_tied) return;
        this.modeButtonClicked(3);
        if(this.panel.state > 3) {
            if(this.panel['baro-mode'] === 0) {
                let newvalue = Math.max(Math.min(this.altimeter['setting-inhg'] + change * 0.01, 33), 26);
                fgCommand.propertyAssign('instrumentation/altimeter[1]/setting-inhg', newvalue);
            } else {
                let newvalue = Math.max(Math.min(this.altimeter['setting-hpa'] + change, 1118), 880);
                fgCommand.propertyAssign('instrumentation/altimeter[1]/setting-hpa', newvalue);
            }
        }
        if(this.panel.state === 4) {
            fgCommand.propertyAssign('autopilot/kap140/panel/state', 5);
        }
    }

    modeButtonClicked(mode) {
        // A mode button (BARO, KNOB, UP, DOWN) has been clicked:
        // The digit must change for some seconds.
        // sending this event to FlightGear is not easy, so we control
        // the main digit during SECONS_FOR_DIGITS seconds when
        // one the the mde buttons are clicked

        // if this variable is 0, allow FG to control the main digit
        this.imControllingDigit = mode;
        // if there is not a timer already set, start it
        if(!this.updateButtonClickedEllapsed) {
            setTimeout(this.updateButtonClickedFunction, 1000, this);
        }
        // in any case, register when the button was clicked: FG will
        /// get the control of the digit again in SECONDS_FOR_DIGITS seconds
        this.updateButtonClickedEllapsed = new Date();
    }

    updateButtonClickedFunction(self) {
        // timer to control the digit on the screen: FG will
        // get the control of the digit again after SECONDS_FOR_DIGITS seconds
        // unless a mode button is clicked again 
        let now = new Date();
        if((now - self.updateButtonClickedEllapsed) / 1000 > SECONDS_FOR_DIGITS) {
            self.imControllingDigit = 0;
            self.updateButtonClickedEllapsed = null;
        } else {
            setTimeout(self.updateButtonClickedFunction, 1000, self);
        }
    }

    async updateData() {
        // updates data from FlightGear. Call this function periodically
        this.panel = this.propsToObject(await $.get('/json/autopilot/kap140/panel'));
        this.settings = this.propsToObject(await $.get('/json/autopilot/kap140/settings'));
        this.internal = this.propsToObject(await $.get('/json/autopilot/internal'));
        this.sensors =  this.propsToObject(await $.get('/json/autopilot/kap140/sensors'));
        this.altimeter = this.propsToObject(await $.get('/json/instrumentation/altimeter[1]'));
        // $('#labelkap140-state').html(this.getState());
        $('#kap140-labellateralmode').html(this.getLateralMode());
        $('#kap140-labelverticalmode').html(this.getVerticalMode());
        $('#kap140-labeldigit').html(this.getDigit());
        let lateralarm = this.getLateralArm();
        $('#kap140-labellateralarm').html(lateralarm);  // this is not used in the SVG panel
        $('#kap140-labelnavarm').toggleClass('invisible', lateralarm !== 'NAV ARM');
        $('#kap140-labelaprarm').toggleClass('invisible', lateralarm !== 'APR ARM');
        $('#kap140-labelrevarm').toggleClass('invisible', lateralarm !== 'REV ARM');
        let verticalarm = this.getVerticalArm();
        $('#kap140-labelverticalarm').html(verticalarm);  // this is not used in the SVG panel
        $('#kap140-labelaltarm').toggleClass('invisible', verticalarm !== 'ALT ARM');
        let pitch = this.getPitch();
        $('#kap140-labelpitch').html(pitch);  // this is not used in the SVG panel
        $('#kap140-ptup').toggleClass('invisible', pitch !== 'PT UP');
        $('#kap140-ptdown').toggleClass('invisible', pitch !== 'PT DOWN');
        $('#kap140-labelunit').html(this.getDigitMode());
    }

    getState() {
        let available = ['', 'PFT1', 'PFT2', 'PFT3', 'BARO', 'STBY', 'CWS'];
        let value = available[this.panel.state];
        if(value === 'CWS' && !this.settings.cws) value = '';
        return value;
    }

    getLateralMode() {
        if(this.panel.state < 4 || this.panel.state === 5) {
            // there states are shown on the space reserved to the lateral mode
            return this.getState();
        }
        let available = ['', 'ROL', 'HDG', 'NAV', 'APR', 'REV'];
        let value = available[this.settings['lateral-mode']];
        // TODO: modes 3, 4, 5 with panel/nav-timer > 1 must be shown in red
        if(value === undefined) console.log(this.settings['lateral-mode'])
        return value;
    }

    getVerticalMode() {
        let available = ['', 'VS', 'ALT', 'GS'];
        let value = available[this.settings['vertical-mode']];
        return value;
    }

    getPreselect() {
        if(this.panel.state > 4) {
            return `FT: ${this.internal['target-altitude']}`;
        }
        return '';
    }

    getLateralArm() {
        let available = ['', 'NAV ARM', 'APR ARM', 'REV ARM', 'GS ARM'];
        let value = available[this.settings['lateral-arm']];
        return value;
    }
    
    getVerticalArm() {
        let available = ['', 'ALT ARM'];
        let value = available[this.settings['vertical-arm']];
        return value;
    }

    getPitch() {
        if(this.sensors['pitch-up']) return 'PT UP';
        if(this.sensors['pitch-down']) return 'PT DOWN';
        return '';
    }

    getDigit() {
        // Returns the digit in the main display
        let digitMode = (this.imControllingDigit > 0?this.imControllingDigit:this.panel['digit-mode']);
        switch(digitMode) {
        case 0: return '';
        case 1: return this.internal['target-altitude'];
        case 2: return this.internal['target-climb-rate'];
        case 3: if(this.panel['baro-mode']) return Math.floor(this.altimeter['setting-hpa']); else return this.altimeter['setting-inhg'].toPrecision(4);
        }
    }

    getDigitMode() {
        // Returns the units of the digit in the main display
        let digitMode = (this.imControllingDigit > 0?this.imControllingDigit:this.panel['digit-mode']);
        switch(digitMode) {
        case 0: return '';
        case 1: return 'FT';
        case 2: return 'FPM';
        case 3: if(this.panel['baro-mode']) return 'hPA'; else return 'inHG';
        }
    }
    
    propsToObject(data) {
        // converts a list of properties, as returned by FlightGear, into a dictionary
        let output = {}
        for(var i=0; i<data.nChildren; i++) {
            output[data.children[i].name] = data.children[i].value;
        }
        return output;
    }
}

