
$(document).ready(function (){
    setTimeout(updateKAP140, 500, new KAP140());
})

function updateKAP140(kap140) {
    kap140.updateData()
    setTimeout(updateKAP140, 200, kap140);
}


class KAP140 {
    constructor () {
        let self = this;
        $('#kap140btnap').click(function () {
            fgCommand.propertyAssign('/autopilot/kap140/panel/button-ap', 0.01);
            if(self.panel.state > 4) {
                fgCommand.propertySwap('/autopilot/kap140/panel/state-old', '/autopilot/kap140/panel/state');
            }    
        });
        $('#kap140btnhdg').click(function () {
            if(self.panel.state === 6) {
                if(self.settings['lateral-mode'] > 1) {
                    fgCommand.propertyAssign('autopilot/kap140/settings/lateral-mode', 1);
                } else if(self.settings['lateral-mode'] === 0) {
                    fgCommand.propertyAssign('autopilot/kap140/settings/lateral-mode', 2);
                }
            }
            fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 0);
            fgCommand.propertyAssign('autopilot/internal/target-roll-deg', 0);
            fgCommand.propertyAssign('autopilot/internal/target-intercept-angle', 0);
            fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 0);
            fgCommand.propertyAssign('autopilot/kap140/panel/nav-timer', 0);
        });
        $('#kap140btnnav').click(function () {
            if(self.panel.state === 6) {
                if(self.settings['lateral-mode'] !== 3) {
                    if(self.settings['lateral-arm'] === 1) {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 0);
                        fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 0);
                    } else {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 1);
                    }
                }
            }
            fgCommand.propertyAssign('autopilot/kap140/panel/nav-timer', 0);
        });
        $('#kap140btnapr').click(function () {
            if(self.panel.state === 6) {
                if(self.settings['lateral-mode'] !== 4) {
                    if(self.settings['lateral-arm'] === 2) {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 0);
                        fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 0);
                    } else {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 2);
                    }
                }
            }
            fgCommand.propertyAssign('autopilot/kap140/panel/nav-timer', 0);
        });
        $('#kap140btnrev').click(function () {
            if(self.panel.state === 6) {
                if(self.settings['lateral-mode'] !== 5) {
                    if(self.settings['lateral-arm'] === 3) {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 0);
                        fgCommand.propertyAssign('autopilot/kap140/panel/hdg-timer', 0);
                    } else {
                        fgCommand.propertyAssign('autopilot/kap140/settings/lateral-arm', 3);
                    }
                }
            }
            fgCommand.propertyAssign('autopilot/kap140/panel/nav-timer', 0);
        });
    }

    async updateData() {
        this.panel = this.propsToObject(await $.get('/json/autopilot/kap140/panel'));
        this.settings = this.propsToObject(await $.get('/json/autopilot/kap140/settings'));
        this.internal = this.propsToObject(await $.get('/json/autopilot/internal'));
        this.sensors =  this.propsToObject(await $.get('/json/autopilot/kap140/sensors'));
        this.altimeter = this.propsToObject(await $.get('/json/instrumentation/altimeter[1]'));
        $('#log').html(
            `${this.getState()}|${this.getLateralMode()}|${this.getVerticalMode()}|${this.getRefRate()}|${this.getPreselect()}<br />` + 
            `NAV1|${this.getLateralArm()}|${this.getVerticalArm()}|${this.getPitch()}|${this.getBaro()}`
            )
    }

    getState() {
        let available = ['', 'PPT1', 'PPT2', 'PPT3', 'BARO', 'STBY', 'CWS'];
        let value = available[this.panel.state];
        if(value === 'CWS' && !this.settings.cws) value = '';
        return value;
    }

    getLateralMode() {
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

    getRefRate() {
        if(this.settings['vertical-mode'] === 1) {
            return `FPM: ${this.internal['target-climb-rate']}`;
        }else if(this.settings['vertical-mode'] === 2) {
            return `Press: ${this.internal['target-pressure']}`;
        }
        return '';
    }

    getPreselect() {
        if(this.panel.state > 4) {
            return `Preselect: ${this.internal['target-altitude']}`;
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

    getBaro() {
        if(this.panel.state < 4) return '';
        if(this.panel['baro-mode']) {
            return `hPa: ${this.altimeter['setting-hpa']}`;
        } else {        
            return `InHg: ${this.altimeter['setting-inhg']}`;
        }
    }

    propsToObject(data) {
        let output = {}
        for(var i=0; i<data.nChildren; i++) {
            output[data.children[i].name] = data.children[i].value;
        }
        return output;
    }
}