var DCT = dual_control_tools;

# Pilot/copilot aircraft identifiers. Used by dual_control.
var pilot_type = "Aircraft/c172p-detailed/Models/c172p-detailed.xml";
var copilot_type = "Aircraft/c172p-detailed/Models/c172p-detailed-copilot.xml";

props.globals.initNode("/sim/remote/pilot-callsign", "", "STRING");

var pilot_switches1_mpp  = "sim/multiplay/generic/int[0]";
var pilot_TDM1_mpp       = "sim/multiplay/generic/string[1]";
var pilot_TDM2_mpp       = "sim/multiplay/generic/string[2]";
var pilot_TDM3_mpp       = "sim/multiplay/generic/string[3]";
var pilot_TDM4_mpp       = "sim/multiplay/generic/string[4]";

var pilot_rmi_head_mpp   = "sim/multiplay/generic/float[3]";
var pilot_ai_pitch_mpp   = "sim/multiplay/generic/float[4]";
var pilot_ai_roll_mpp    = "sim/multiplay/generic/float[5]";

var copilot_rudder_mpp   = "surface-positions/rudder-pos-norm";
var copilot_elevator_mpp = "surface-positions/elevator-pos-norm";
var copilot_elevator_trim_mpp = "surface-positions/left-aileron-pos-norm";

var copilot_thrust_cmd_mpp  = "sim/multiplay/generic/float[3]";
var copilot_mixture_cmd_mpp = "sim/multiplay/generic/float[4]";
var copilot_switches1_mpp   = "sim/multiplay/generic/int[0]";
var copilot_TDM1_mpp        = "sim/multiplay/generic/string[0]";

# Flight controls
var l_rudder_cmd   = "controls/flight/rudder";
var l_aileron_cmd  = "controls/flight/aileron";
var l_elevator_cmd = "controls/flight/elevator";
var l_elevator_trim_cmd = "controls/flight/elevator-trim";

var l_pilot_thrust_cmd = ["controls/engines/engine[0]/propeller-pitch"];
var l_pilot_mixture_cmd = ["controls/engines/engine[0]/mixture"];

var l_fuel_quantity =
    ["consumables/fuel/tank[0]/level-lbs"];

# Instruments
var l_altimeter_setting = "instrumentation/altimeter[1]/setting-inhg";
var l_rmi_heading = "instrumentation/rmi/indicated-heading-deg";
var l_ai_pitch    = "instrumentation/attitude-indicator/indicated-pitch-deg";
var l_ai_roll     = "instrumentation/attitude-indicator/indicated-roll-deg";

var fcs = "fdm/jsbsim/fcs";

# Pilot MP property mappings and specific copilot connect/disconnect actions.
var l_dual_control = "fdm/jsbsim/fcs/dual-control/enabled";

var l_shared_thrust_cmd = "fdm/jsbsim/fcs/dual-control/thrust-cmd-norm[0]";
var l_final_thrust_cmd = "fdm/jsbsim/fcs/thrust-cmd-norm[0]";

var l_shared_mixture_cmd = "fdm/jsbsim/fcs/dual-control/mixture-cmd-norm[0]";
var l_final_mixture_cmd = "fdm/jsbsim/fcs/mixture-cmd-norm[0]";

# Used by dual_control to set up the mappings for the pilot.
var pilot_connect_copilot = func (copilot) {
    # Make sure dual-control is activated in the FDM FCS.
    settimer(func { setprop(l_dual_control, 1); }, 1);

    # VHF 22 Comm. Comm 1 is owned by pilot, 2 by copilot.
    VHF22.make_master(0);
    VHF22.make_slave_to(1, copilot);

    # VIR 32 Nav. Nav 1 is owned by pilot, 2 by copilot.
    VIR32.make_master(0);
    VIR32.make_slave_to(1, copilot);

    # Process received properties.
    return [
        # Copilot main flight control
        DCT.Translator.new(
            copilot.getNode(copilot_elevator_mpp),
            props.globals.getNode("/fdm/jsbsim/fcs/copilot/pitch-cmd-norm")
        ),
        DCT.Translator.new(
            copilot.getNode(copilot_rudder_mpp),
            props.globals.getNode("/fdm/jsbsim/fcs/copilot/yaw-cmd-norm")
        ),

        # Copilot elevator trim control
        DCT.DeltaAdder.new(
            copilot.getNode(copilot_elevator_trim_mpp),
            props.globals.getNode(l_elevator_trim_cmd)
        ),

        # Copilot engine control inputs
        # Thrust sharing
        DCT.MostRecentSelector.new(
            props.globals.getNode(l_pilot_thrust_cmd),
            copilot.getNode(copilot_thrust_cmd_mpp),
            props.globals.getNode(l_shared_thrust_cmd),
            0.02
        ),

        # Mixture sharing
        DCT.MostRecentSelector.new(
            props.globals.getNode(l_pilot_mixture_cmd),
            copilot.getNode(copilot_mixture_cmd_mpp),
            props.globals.getNode(l_shared_mixture_cmd),
            0.02
        ),

        # Decode copilot cockpit switch states.
        #   NOTE: Actions are only triggered on change.
        DCT.SwitchDecoder.new(
            copilot.getNode(copilot_switches1_mpp),
            #  4 - 8: VHF22 Comm 1
            VHF22.master_receive_slave_buttons(0)
            ~
            #  9 - 13: VIR32 Nav 1
            VIR32.master_receive_slave_buttons(0)
            ~
            #  18 - 22: ADF 462
            ADF462.master_receive_slave_buttons(0)
        ),

        # Set up TDM reception of slow state properties.
        DCT.TDMDecoder.new(
            copilot.getNode(copilot_TDM1_mpp),
            #  0 - 1 Comm 2 frequencies
            VHF22.slave_receive_master_state(1)
            ~
            #  2 - 3 Nav 2 frequencies
            VIR32.slave_receive_master_state(1)
        ),

        # Process properties to send.

        # Encoding of on/off switches.
        DCT.SwitchEncoder.new(
            #  0 - 4: VHF22 Comm 2
            VHF22.slave_send_buttons(1)
            ~
            #  5 - 9: VIR32 Nav 2
            VIR32.slave_send_buttons(1),
            props.globals.getNode(pilot_switches1_mpp)
        ),

        # Set up TDM transmission of slow state properties.
        DCT.TDMEncoder.new(
            [
                props.globals.getNode(l_final_thrust_cmd),
                props.globals.getNode(l_final_mixture_cmd),
                props.globals.getNode(l_altimeter_setting)
            ],
            props.globals.getNode(pilot_TDM1_mpp)
        ),

        # Set up TDM transmission of slow state properties.
        DCT.TDMEncoder.new(
            #  6 - 7 Comm 1 frequencies
            VHF22.master_send_state(0)
            ~
            #  8 - 9 Nav 1 frequencies
            VIR32.master_send_state(0)
            ~
            #  10 - 11 ADF frequencies
            ADF462.master_send_state(0),
            props.globals.getNode(pilot_TDM2_mpp)
        )
    ];
};

var pilot_disconnect_copilot = func {
    # Reset copilot controls. Slightly dangerous.
    setprop("/fdm/jsbsim/fcs/copilot/pitch-cmd-norm", 0.0);
    setprop("/fdm/jsbsim/fcs/copilot/yaw-cmd-norm", 0.0);
    setprop(l_dual_control, 0);

    # VHF 22 Comm. Regain control of Comm 2.
    VHF22.make_master(1);
    # VIR 32 Nav. Regain control of Nav 2.
    VIR32.make_master(1);
};

var copilot_connect_pilot = func (pilot) {
};

var copilot_disconnect_pilot = func {
};
