##
# Bendix/King KAP140 Autopilot System
##

Locks = "/autopilot/KAP140/locks";
Settings = "/autopilot/KAP140/settings";
Annunciators = "/autopilot/KAP140/annunciators";
Internal = "/autopilot/internal";

annunciator = "";
annunciator_state = "";
flash_interval = 0.0;
flash_count = 0.0;
flash_timer = -1.0;

# baro setting unit: 0=inHg, 1=hPa
baro_setting_unit = 0;
baro_setting = 29.92;
baro_setting_adjusting = 0;
baro_button_down = 0;
baro_timer_running = 0;

alt_preselect = 0;
alt_button_timer_running = 0;
alt_button_timer_ignore = 0;
alt_alert_on = 0;
alt_captured = 0;

old_alt_number_state = ["off", 0];
old_vs_number_state = ["off", 0];


flasher = func {
  flash_timer = -1.0;
  annunciator = arg[0];
  flash_interval = arg[1];
  flash_count = arg[2] + 1;
  annunciator_state = arg[3];

  flash_timer = 0.0;

  flash_annunciator();
}

flash_annunciator = func {
  ##print(annunciator);
  ##print(flash_interval);
  ##print(flash_count);

  ##
  # If flash_timer is set to -1 then flashing is aborted
  if (flash_timer < -0.5)
  {
    ##print ("flash abort ", annunciator);
    setprop(Annunciators, annunciator, "off");
    return;
  }

  if (flash_timer < flash_count)
  {
    #flash_timer = flash_timer + 1.0;
    if (getprop(Annunciators, annunciator) == "on")
    {
      setprop(Annunciators, annunciator, "off");
      settimer(flash_annunciator, flash_interval / 2.0);
    }
    else
    #elsif (getprop(Annunciators, annunciator) == "off")
    {
      flash_timer = flash_timer + 1.0;
      setprop(Annunciators, annunciator, "on");
      settimer(flash_annunciator, flash_interval);
    }
  }
  else
  {
    flash_timer = -1.0;
    setprop(Annunciators, annunciator, annunciator_state);
  }
}


pt_check = func {
  ##print("pitch trim check");

  if (getprop(Locks, "pitch-mode") == "off")
  {
    setprop(Annunciators, "pt-up", "off");
    setprop(Annunciators, "pt-dn", "off");
    return;
  }

  else
  {
    elevator_control = getprop("/controls/flight/elevator");
    ##print(elevator_control);

    # Flash the pitch trim up annunciator
    if (elevator_control < -0.01)
    {
      if (getprop(Annunciators, "pt-up") == "off")
      {
        setprop(Annunciators, "pt-up", "on");
      }
      elsif (getprop(Annunciators, "pt-up") == "on")
      {
        setprop(Annunciators, "pt-up", "off");
      }
    }
    # Flash the pitch trim down annunciator
    elsif (elevator_control > 0.01)
    {
      if (getprop(Annunciators, "pt-dn") == "off")
      {
        setprop(Annunciators, "pt-dn", "on");
      }
      elsif (getprop(Annunciators, "pt-dn") == "on")
      {
        setprop(Annunciators, "pt-dn", "off");
      }
    }

    else
    {
      setprop(Annunciators, "pt-up", "off");
      setprop(Annunciators, "pt-dn", "off");
    }
  }

  settimer(pt_check, 0.5);
}


ap_init = func {
  ##print("ap init");

  ##
  # Initialises the autopilot.
  ##

  setprop(Locks, "alt-hold", "off");
  setprop(Locks, "apr-hold", "off");
  setprop(Locks, "gs-hold", "off");
  setprop(Locks, "hdg-hold", "off");
  setprop(Locks, "nav-hold", "off");
  setprop(Locks, "rev-hold", "off");
  setprop(Locks, "roll-axis", "off");
  setprop(Locks, "roll-mode", "off");
  setprop(Locks, "pitch-axis", "off");
  setprop(Locks, "pitch-mode", "off");
  setprop(Locks, "arm-mode", "off");
  
  setprop(Settings, "target-alt-pressure", 0.0);
  setprop(Settings, "target-intercept-angle", 0.0);
  setprop(Settings, "target-pressure-rate", 0.0);
  setprop(Settings, "target-turn-rate", 0.0);
  
  setprop(Annunciators, "rol", "off");
  setprop(Annunciators, "hdg", "off");
  setprop(Annunciators, "nav", "off");
  setprop(Annunciators, "nav-arm", "off");
  setprop(Annunciators, "apr", "off");
  setprop(Annunciators, "apr-arm", "off");
  setprop(Annunciators, "rev", "off");
  setprop(Annunciators, "rev-arm", "off");
  setprop(Annunciators, "vs", "off");
  setprop(Annunciators, "vs-number", "off");
  setprop(Annunciators, "fpm", "off");
  setprop(Annunciators, "alt", "off");
  setprop(Annunciators, "alt-number", "off");
  setprop(Annunciators, "apr", "off");
  setprop(Annunciators, "gs", "off");
  setprop(Annunciators, "gs-arm", "off");
  setprop(Annunciators, "pt-up", "off");
  setprop(Annunciators, "pt-dn", "off");
  setprop(Annunciators, "bs-hpa-number", "off");
  setprop(Annunciators, "bs-inhg-number", "off");
  setprop(Annunciators, "ap", "off");

}
  

ap_button = func {
  ##print("ap_button");

  ##
  # Engages the autopilot in Wings level mode (ROL) and Vertical speed hold
  # mode (VS).
  ##
  if (getprop(Locks, "roll-mode") == "off" and
      getprop(Locks, "pitch-mode") == "off")
  {
    flash_timer = -1.0;

    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "rol");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");
    setprop(Locks, "arm-mode", "off");

    setprop(Annunciators, "rol", "on");
    setprop(Annunciators, "vs", "on");
    #setprop(Annunciators, "fpm", "on");
    setprop(Annunciators, "vs-number", "on");

    setprop(Settings, "target-turn-rate", 0.0);
    #setprop(Settings, "target-pressure-rate", getprop(Internal,
    #"pressure-rate"));

    pressure_rate = getprop(Internal, "pressure-rate");
    #print(pressure_rate);
    fpm = -pressure_rate * 58000;
    #print(fpm);
    if (fpm > 0.0)
    {
      fpm = int(fpm/100 + 0.5) * 100;
    }
    else
    {
      fpm = int(fpm/100 - 0.5) * 100;
    }
    #print(fpm);

    setprop(Settings, "target-pressure-rate", -fpm / 58000);

    pt_check();

    if (alt_button_timer_running == 0)
    {
      settimer(alt_button_timer, 3.0);
      alt_button_timer_running = 1;
      alt_button_timer_ignore = 0;
      setprop(Annunciators, "alt-number", "off");
    }
  }
  ##
  # Disengages all modes.
  ##
  elsif (getprop(Locks, "roll-mode") != "off" and
         getprop(Locks, "pitch-mode") != "off")
  {
    flash_timer = -1.0;

    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "roll-axis", "off");
    setprop(Locks, "roll-mode", "off");
    setprop(Locks, "pitch-axis", "off");
    setprop(Locks, "pitch-mode", "off");
    setprop(Locks, "arm-mode", "off");

    setprop(Settings, "target-alt-pressure", 0.0);
    setprop(Settings, "target-intercept-angle", 0.0);
    setprop(Settings, "target-pressure-rate", 0.0);
    setprop(Settings, "target-turn-rate", 0.0);

    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "hdg", "off");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "nav-arm", "off");
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "apr-arm", "off");
    setprop(Annunciators, "rev", "off");
    setprop(Annunciators, "rev-arm", "off");
    setprop(Annunciators, "vs", "off");
    setprop(Annunciators, "vs-number", "off");
    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "alt-number", "off");
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "gs-arm", "off");
    setprop(Annunciators, "pt-up", "off");
    setprop(Annunciators, "pt-dn", "off");

    flasher("ap", 1.0, 5, "off");
  }
}


hdg_button = func {
  ##print("hdg_button");

  ##
  # Engages the heading mode (HDG) and vertical speed hold mode (VS). The
  # commanded vertical speed is set to the vertical speed present at button
  # press.
  ##
  if (getprop(Locks, "roll-mode") == "off" and
      getprop(Locks, "pitch-mode") == "off")
  {
    flash_timer = -1.0;

    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "hdg");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");
    setprop(Locks, "arm-mode", "off");

    setprop(Annunciators, "hdg", "on");
    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "vs", "on");
    setprop(Annunciators, "vs-number", "on");
    #setprop(Annunciators, "fpm", "on");

    setprop(Settings, "target-intercept-angle", 0.0);
    #setprop(Settings, "target-pressure-rate", getprop(Internal,
    #"pressure-rate"));

    pressure_rate = getprop(Internal, "pressure-rate");
    fpm = -pressure_rate * 58000;
    #print(fpm);
    if (fpm > 0.0)
    {
      fpm = int(fpm/100 + 0.5) * 100;
    }
    else
    {
      fpm = int(fpm/100 - 0.5) * 100;
    }
    #print(fpm);

    setprop(Settings, "target-pressure-rate", -fpm / 58000);

    pt_check();

    if (alt_button_timer_running == 0)
    {
      settimer(alt_button_timer, 3.0);
      alt_button_timer_running = 1;
      alt_button_timer_ignore = 0;
      setprop(Annunciators, "alt-number", "off");
    }
  }
  ##
  # Switch from ROL to HDG mode, but don't change pitch mode.
  ##
  elsif (getprop(Locks, "roll-mode") == "rol")
  {
    #flash_timer = -1.0;
    #flasher("hdg", 0.5, 0, "on");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "hdg");
    setprop(Locks, "arm-mode", "off");
    #setprop(Locks, "pitch-axis", "off");
    #setprop(Locks, "pitch-mode", "off");

    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "hdg", "on");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "rev", "off");

    setprop(Settings, "target-intercept-angle", 0.0);
  }
  ##
  # Switch to HDG mode, but don't change pitch mode.
  ##
  elsif ( (getprop(Locks, "roll-mode") == "nav" or
	 getprop(Locks, "arm-mode") == "nav-arm" or
         getprop(Locks, "roll-mode") == "rev" or
         getprop(Locks, "arm-mode") == "rev-arm") and
         flash_timer < -0.5)
  {
    #flash_timer = -1.0;
    #flasher("hdg", 0.5, 0, "on");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "hdg");
    setprop(Locks, "arm-mode", "off");
    #setprop(Locks, "pitch-axis", "off");
    #setprop(Locks, "pitch-mode", "off");

    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "hdg", "on");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "rev", "off");
    setprop(Annunciators, "nav-arm", "off");

    setprop(Settings, "target-intercept-angle", 0.0);
  }
  ##
  # If we already are in HDG mode switch to ROL mode. Again don't touch pitch
  # mode.
  ##
  elsif (getprop(Locks, "roll-mode") == "hdg")
  {
    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "rol");
    #setprop(Locks, "pitch-axis", "off");
    #setprop(Locks, "pitch-mode", "off");

    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "hdg", "off");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "rol", "on");

    setprop(Settings, "target-turn-rate", 0.0);
  }
  ##
  # If we are in APR mode we also have to change pitch mode.
  # TODO: Should we switch to VS or ALT mode? (currently VS)
  ##
  elsif ( (getprop(Locks, "roll-mode") == "apr" or
         getprop(Locks, "arm-mode") == "apr-arm" or
         getprop(Locks, "pitch-mode") == "gs" or
         getprop(Locks, "arm-mode") == "gs-arm") and
         flash_timer < -0.5)
  {
    #flash_timer = -1.0;
    #flasher("hdg", 0.5, 0, "on");

    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "hdg");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");
    setprop(Locks, "arm-mode", "off");

    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "hdg", "on");
    setprop(Annunciators, "nav", "off");
    setprop(Annunciators, "apr", "off");
    setprop(Annunciators, "apr-arm", "off");
    setprop(Annunciators, "gs", "off");
    setprop(Annunciators, "gs-arm", "off");
    setprop(Annunciators, "vs", "on");
    setprop(Annunciators, "vs-number", "on");
    #setprop(Annunciators, "fpm", "on");

    setprop(Settings, "target-intercept-angle", 0.0);
    setprop(Settings, "target-pressure-rate", getprop(Internal,
    "pressure-rate"));
  }
}


nav_button = func {
  ##print("nav_button");

  ##
  # If we are in HDG mode we switch to the 45 degree angle intercept NAV mode
  ##
  if (getprop(Locks, "roll-mode") == "hdg")
  {
    flasher("hdg", 0.5, 8, "off");
      
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "arm-mode", "nav-arm");
    setprop(Locks, "roll-mode", "nav");

    setprop(Annunciators, "nav-arm", "on");

    nav_arm_from_hdg();
  }
  ##
  # If we are in ROL mode we switch to the all angle intercept NAV mode.
  ##
  elsif (getprop(Locks, "roll-mode") == "rol")
  {
    flasher("hdg", 0.5, 8, "off");

    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "arm-mode", "nav-arm");
    setprop(Locks, "roll-mode", "nav");

    setprop(Annunciators, "nav-arm", "on");

    nav_arm_from_rol();
  }
  ##
  # TODO:
  # NAV mode can only be armed if we are in HDG or ROL mode.
  # Can anyone verify that this is correct?
  ##
}

nav_arm_from_hdg = func
{
  ##
  # Abort the NAV-ARM mode if something has changed the arm mode to something
  # else than NAV-ARM.
  ##
  if (getprop(Locks, "arm-mode") != "nav-arm")
  {
    setprop(Annunciators, "nav-arm", "off");
    return;
  }

  #setprop(Annunciators, "nav-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    #print("flashing...");
    settimer(nav_arm_from_hdg, 2.5);
    return;
  }
  ##
  # Activate the nav-hold controller and check the needle deviation.
  ##
  setprop(Locks, "nav-hold", "nav");
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    #print("deviation");
    settimer(nav_arm_from_hdg, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the NAV-ARM annunciator
  # and show the NAV annunciator. End of NAV-ARM sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    #print("capture");
    setprop(Locks, "arm-mode", "off");
    setprop(Annunciators, "nav-arm", "off");
    setprop(Annunciators, "nav", "on");
  }
}

nav_arm_from_rol = func
{
  ##
  # Abort the NAV-ARM mode if something has changed the arm mode to something
  # else than NAV-ARM.
  ##
  if (getprop(Locks, "arm-mode") != "nav-arm")
  {
    setprop(Annunciators, "nav-arm", "off");
    return;
  }
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  #setprop(Annunciators, "nav-arm", "on");
  if (flash_timer > -0.5)
  {
    #print("flashing...");
    setprop(Annunciators, "rol", "off");
    settimer(nav_arm_from_rol, 2.5);
    return;
  }
  ##
  # Turn the ROL annunciator back on and activate the ROL mode.
  ##
  setprop(Annunciators, "rol", "on");
  setprop(Locks, "roll-axis", "trn");
  setprop(Settings, "target-turn-rate", 0.0);
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    #print("deviation");
    settimer(nav_arm_from_rol, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the NAV-ARM annunciator
  # and show the NAV annunciator. End of NAV-ARM sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    #print("capture");
    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "nav-arm", "off");
    setprop(Annunciators, "nav", "on");

    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "nav");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "nav");
    setprop(Locks, "arm-mode", "off");
  }
}

apr_button = func {
  ##print("apr_button");
  ##
  # If we are in HDG mode we switch to the 45 degree intercept angle APR mode
  ##
  if (getprop(Locks, "roll-mode") == "hdg")
  {
    flasher("hdg", 0.5, 8, "off");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "apr");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "arm-mode", "apr-arm");
    #setprop(Locks, "pitch-axis", "vs");
    #setprop(Locks, "pitch-mode", "gs");
    setprop(Locks, "roll-mode", "apr");

    setprop(Annunciators, "apr-arm", "on");

    apr_arm_from_hdg();
  }
  elsif (getprop(Locks, "roll-mode") == "rol")
  {
    flasher("hdg", 0.5, 8, "off");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "arm-mode", "apr-arm");
    #setprop(Locks, "pitch-axis", "vs");
    #setprop(Locks, "pitch-mode", "vs");
    setprop(Locks, "roll-mode", "apr");

    setprop(Annunciators, "apr-arm", "on");

    apr_arm_from_rol();
  }
}

apr_arm_from_hdg = func
{
  ##
  # Abort the APR-ARM mode if something has changed the arm mode to something
  # else than APR-ARM.
  ##
  if (getprop(Locks, "arm-mode") != "apr-arm")
  {
    setprop(Annunciators, "apr-arm", "off");
    return;
  }

  #setprop(Annunciators, "apr-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    #print("flashing...");
    settimer(apr_arm_from_hdg, 2.5);
    return;
  }
  ##
  # Activate the apr-hold controller and check the needle deviation.
  ##
  setprop(Locks, "apr-hold", "apr");
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    #print("deviation");
    settimer(apr_arm_from_hdg, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the APR-ARM annunciator
  # and show the APR annunciator. End of APR-ARM sequence. Start the GS-ARM
  # sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    #print("capture");
    setprop(Annunciators, "apr-arm", "off");
    setprop(Annunciators, "apr", "on");
    setprop(Locks, "arm-mode", "gs-arm");

    gs_arm();
  }
}

apr_arm_from_rol = func
{
  ##
  # Abort the APR-ARM mode if something has changed the roll mode to something
  # else than APR-ARM.
  ##
  if (getprop(Locks, "arm-mode") != "apr-arm")
  {
    setprop(Annunciators, "apr-arm", "off");
    return;
  }

  #setprop(Annunciators, "apr-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    #print("flashing...");
    setprop(Annunciators, "rol", "off");
    settimer(apr_arm_from_rol, 2.5);
    return;
  }
  ##
  # Turn the ROL annunciator back on and activate the ROL mode.
  ##
  setprop(Annunciators, "rol", "on");
  setprop(Locks, "roll-axis", "trn");
  setprop(Settings, "target-turn-rate", 0.0);
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    #print("deviation");
    settimer(apr_arm_from_rol, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the APR-ARM annunciator
  # and show the APR annunciator. End of APR-ARM sequence. Start the GS-ARM
  # sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    #print("capture");
    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "apr-arm", "off");
    setprop(Annunciators, "apr", "on");

    setprop(Locks, "apr-hold", "apr");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "apr");
    setprop(Locks, "arm-mode", "gs-arm");

    gs_arm();
  }
}


gs_arm = func {
  ##
  # Abort the GS-ARM mode if something has changed the arm mode to something
  # else than GS-ARM.
  ##
  if (getprop(Locks, "arm-mode") != "gs-arm")
  {
    setprop(Annunciators, "gs-arm", "off");
    return;
  }

  setprop(Annunciators, "gs-arm", "on");

  deviation = getprop("/radios/nav/gs-needle-deflection");
  ##
  # If the deflection is more than 1 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 1.0)
  {
    #print("deviation");
    settimer(gs_arm, 5);
    return;
  }
  ##
  # If the deviation is less than 1 degrees turn off the GS-ARM annunciator
  # and show the GS annunciator. Activate the GS pitch mode.
  ##
  elsif (abs(deviation) < 3.1)
  {
    #print("capture");
    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "vs", "off");
    setprop(Annunciators, "vs-number", "off");
    #setprop(Annunciators, "fpm", "off");
    setprop(Annunciators, "gs-arm", "off");
    setprop(Annunciators, "gs", "on");

    setprop(Locks, "alt-hold", "off");
    setprop(Locks, "gs-hold", "gs");
    setprop(Locks, "pitch-mode", "gs");
    setprop(Locks, "arm-mode", "off");
    #setprop(Locks, "hdg-hold", "hdg");
    #setprop(Locks, "nav-hold", "off");
    #setprop(Locks, "roll-axis", "trn");
    #setprop(Locks, "roll-mode", "apr");
  }

}


rev_button = func {
  ##print("rev_button");
  ##
  # If we are in HDG mode we switch to the 45 degree intercept angle REV mode
  ##
  if (getprop(Locks, "roll-mode") == "hdg")
  {
    flasher("hdg", 0.5, 8, "off");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "arm-mode", "rev-arm");
    #setprop(Locks, "pitch-axis", "vs");
    #setprop(Locks, "pitch-mode", "gs");

    rev_arm_from_hdg();
  }
  elsif (getprop(Locks, "roll-mode") == "rol")
  {
    flasher("hdg", 0.5, 8, "off");

    #setprop(Locks, "alt-hold", "off");
    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "off");
    setprop(Locks, "hdg-hold", "off");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "arm-mode", "rev-arm");
    #setprop(Locks, "pitch-axis", "vs");
    #setprop(Locks, "pitch-mode", "vs");

    rev_arm_from_rol();
  }
}


rev_arm_from_hdg = func
{
  ##
  # Abort the REV-ARM mode if something has changed the arm mode to something
  # else than REV-ARM.
  ##
  if (getprop(Locks, "arm-mode") != "rev-arm")
  {
    setprop(Annunciators, "rev-arm", "off");
    return;
  }

  #setprop(Annunciators, "rev-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    #print("flashing...");
    settimer(rev_arm_from_hdg, 2.5);
    return;
  }
  ##
  # Activate the rev-hold controller and check the needle deviation.
  ##
  setprop(Locks, "rev-hold", "rev");
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    #print("deviation");
    settimer(rev_arm_from_hdg, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the REV-ARM annunciator
  # and show the REV annunciator. End of REV-ARM sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    #print("capture");
    setprop(Annunciators, "rev-arm", "off");
    setprop(Annunciators, "rev", "on");
    setprop(Locks, "arm-mode", "off");
  }
}


rev_arm_from_rol = func
{
  ##
  # Abort the REV-ARM mode if something has changed the arm mode to something
  # else than REV-ARM.
  ##
  if (getprop(Locks, "arm-mode") != "rev-arm")
  {
    setprop(Annunciators, "rev-arm", "off");
    return;
  }

  #setprop(Annunciators, "rev-arm", "on");
  ##
  # Wait for the HDG annunciator flashing to finish.
  ##
  if (flash_timer > -0.5)
  {
    #print("flashing...");
    setprop(Annunciators, "rol", "off");
    settimer(rev_arm_from_rol, 2.5);
    return;
  }
  ##
  # Turn the ROL annunciator back on and activate the ROL mode.
  ##
  setprop(Annunciators, "rol", "on");
  setprop(Locks, "roll-axis", "trn");
  setprop(Settings, "target-turn-rate", 0.0);
  deviation = getprop("/radios/nav/heading-needle-deflection");
  ##
  # If the deflection is more than 3 degrees wait 5 seconds and check again.
  ##
  if (abs(deviation) > 3.0)
  {
    #print("deviation");
    settimer(rev_arm_from_rol, 5);
    return;
  }
  ##
  # If the deviation is less than 3 degrees turn of the REV-ARM annunciator
  # and show the REV annunciator. End of REV-ARM sequence.
  ##
  elsif (abs(deviation) < 3.1)
  {
    #print("capture");
    setprop(Annunciators, "rol", "off");
    setprop(Annunciators, "rev-arm", "off");
    setprop(Annunciators, "rev", "on");

    setprop(Locks, "apr-hold", "off");
    setprop(Locks, "gs-hold", "off");
    setprop(Locks, "rev-hold", "rev");
    setprop(Locks, "hdg-hold", "hdg");
    setprop(Locks, "nav-hold", "off");
    setprop(Locks, "roll-axis", "trn");
    setprop(Locks, "roll-mode", "rev");
    setprop(Locks, "arm-mode", "off");
  }
}


alt_button_timer = func {
  #print("alt button timer");
  #print(alt_button_timer_ignore);
  
  if (alt_button_timer_ignore == 0)
  {
      setprop(Annunciators, "vs-number", "off");
      setprop(Annunciators, "alt-number", "on");

      alt_button_timer_running = 0;
  }
  elsif (alt_button_timer_ignore > 0)
  {
      alt_button_timer_ignore = alt_button_timer_ignore - 1;
  }
}


alt_button = func {
  ##print("alt_button");

  if (getprop(Locks, "pitch-mode") == "alt")
  {
    if (alt_button_timer_running == 0)
    {
      settimer(alt_button_timer, 3.0);
      alt_button_timer_running = 1;
      alt_button_timer_ignore = 0;
    }
    setprop(Locks, "alt-hold", "off");
    
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "vs");
    
    setprop(Annunciators, "alt", "off");
    setprop(Annunciators, "alt-number", "off");
    setprop(Annunciators, "vs", "on");    
    setprop(Annunciators, "vs-number", "on");

    pressure_rate = getprop(Internal, "pressure-rate");
    fpm = -pressure_rate * 58000;
    #print(fpm);
    if (fpm > 0.0)
    {
      fpm = int(fpm/100 + 0.5) * 100;
    }
    else
    {
      fpm = int(fpm/100 - 0.5) * 100;
    }
    #print(fpm);

    setprop(Settings, "target-pressure-rate", -fpm / 58000);
    
  }
  elsif (getprop(Locks, "pitch-mode") == "vs")
  {
    setprop(Locks, "alt-hold", "alt");
    #setprop(Locks, "apr-hold", "off");
    #setprop(Locks, "gs-hold", "off");
    #setprop(Locks, "hdg-hold", "hdg");
    #setprop(Locks, "nav-hold", "nav");
    #setprop(Locks, "roll-axis", "trn");
    #setprop(Locks, "roll-mode", "nav");
    setprop(Locks, "pitch-axis", "vs");
    setprop(Locks, "pitch-mode", "alt");

    setprop(Annunciators, "alt", "on");
    setprop(Annunciators, "vs", "off");
    setprop(Annunciators, "vs-number", "off");
    #setprop(Annunciators, "fpm", "off");
    setprop(Annunciators, "alt-number", "on");

    #setprop(Settings, "target-alt-pressure",
    #getprop("/systems/static/pressure-inhg"));

    alt_pressure = getprop("/systems/static/pressure-inhg");
    alt_ft = (baro_setting - alt_pressure) / 0.00103;
    if (alt_ft > 0.0)
    {
      alt_ft = int(alt_ft/20 + 0.5) * 20;
    }
    else
    {
      alt_ft = int(alt_ft/20 - 0.5) * 20;
    }
    #print(alt_ft);

    alt_pressure = baro_setting - alt_ft * 0.00103;
    setprop(Settings, "target-alt-ft", alt_ft);
    setprop(Settings, "target-alt-pressure", alt_pressure);

  }
}


dn_button = func {
  ##print("dn_button");

  if (baro_timer_running == 0)
  {
    if (getprop(Locks, "pitch-mode") == "vs")
    {
      if (alt_button_timer_running == 0)
      {
        settimer(alt_button_timer, 3.0);
        alt_button_timer_running = 1;
        alt_button_timer_ignore = 0;
      }
      elsif (alt_button_timer_running == 1)
      {
          settimer(alt_button_timer, 3.0);
          alt_button_timer_ignore = alt_button_timer_ignore + 1;
      }
      Target_VS = getprop(Settings, "target-pressure-rate");
      setprop(Settings, "target-pressure-rate", Target_VS +
              0.0017241379310345);
      setprop(Annunciators, "alt-number", "off");
      setprop(Annunciators, "vs-number", "on");
    }
    elsif (getprop(Locks, "pitch-mode") == "alt")
    {
      Target_Pressure = getprop(Settings, "target-alt-pressure");
      setprop(Settings, "target-alt-pressure", Target_Pressure + 0.0206);
      setprop(Settings, "target-alt-ft",
              getprop(Settings, "target-alt-ft") - 20);
    }
  }
}

up_button = func {
  ##print("up_button");

  if (baro_timer_running == 0)
  {
    if (getprop(Locks, "pitch-mode") == "vs")
    {
      if (alt_button_timer_running == 0)
      {
        settimer(alt_button_timer, 3.0);
        alt_button_timer_running = 1;
        alt_button_timer_ignore = 0;
      }
      elsif (alt_button_timer_running == 1)
      {
          settimer(alt_button_timer, 3.0);
          alt_button_timer_ignore = alt_button_timer_ignore + 1;
      }
      Target_VS = getprop(Settings, "target-pressure-rate");
      setprop(Settings, "target-pressure-rate", Target_VS -
              0.0017241379310345);
      setprop(Annunciators, "alt-number", "off");
      setprop(Annunciators, "vs-number", "on");
    }
    elsif (getprop(Locks, "pitch-mode") == "alt")
    {
      Target_Pressure = getprop(Settings, "target-alt-pressure");
      setprop(Settings, "target-alt-pressure", Target_Pressure - 0.0206);
      setprop(Settings, "target-alt-ft",
              getprop(Settings, "target-alt-ft") + 20);
    }
  }
}

arm_button = func {
  #print("arm button");
}


baro_button_timer = func {
  #print("baro button timer");

  baro_timer_running = 0;
  if (baro_button_down == 1)
  {
    baro_setting_unit = !baro_setting_unit;
    baro_button_down = 0;
    baro_button_press();
  }
  elsif (baro_button_down == 0 and
         baro_setting_adjusting == 0)
  {
    setprop(Annunciators, "bs-hpa-number", "off");
    setprop(Annunciators, "bs-inhg-number", "off");
    setprop(Annunciators, "alt-number", "on");
  }
  elsif (baro_setting_adjusting == 1)
  {
    baro_timer_running = 1;
    baro_setting_adjusting = 0;
    settimer(baro_button_timer, 3.0);
  }
}

baro_button_press = func {
  #print("baro putton press");

  if (baro_button_down == 0 and
      baro_timer_running == 0 and
      alt_button_timer_running == 0)
  {
    baro_button_down = 1;
    baro_timer_running = 1;
    settimer(baro_button_timer, 3.0);
    setprop(Annunciators, "alt-number", "off");
    
    if (baro_setting_unit == 0)
    {
      setprop(Settings, "baro-setting-inhg", baro_setting);
      
      setprop(Annunciators, "bs-inhg-number", "on");
      setprop(Annunciators, "bs-hpa-number", "off");
    }
    elsif (baro_setting_unit == 1)
    {
      setprop(Settings, "baro-setting-hpa",
              baro_setting * 0.03386389);
              
      setprop(Annunciators, "bs-hpa-number", "on");
      setprop(Annunciators, "bs-inhg-number", "off");
    }
  }
}


baro_button_release = func {
  #print("baro button release");

  baro_button_down = 0;
}


alt_alert = func {
  #print("alt alert");
  
  alt_pressure = getprop("/systems/static/pressure-inhg");
  alt_ft = (baro_setting - alt_pressure) / 0.00103;
  alt_difference = abs(alt_preselect - alt_ft);
  #print(alt_difference);

  if (alt_difference > 1000)
  {
    setprop(Annunciators, "alt-alert", "off");
  }
  elsif (alt_difference < 1000 and
         alt_captured == 0)
  {
    if (flash_timer < -0.5) {
      setprop(Annunciators, "alt-alert", "on"); }
    if (alt_difference < 200)
    {
      if (flash_timer < -0.5) {
        setprop(Annunciators, "alt-alert", "off"); }
      if (alt_difference < 20)
      {
        #print("alt_capture()");
        alt_captured = 1;
        flasher("alt-alert", 1.0, 0, "off");
      }
    }
  }
  elsif (alt_difference < 1000 and
         alt_captured == 1)
  {
    if (alt_difference > 200)
    {
      flasher("alt-alert", 1.0, 5, "on");
      alt_captured = 0;
    }
  }
  settimer(alt_alert, 2.0);
}
    

knob_s_up = func {
  #print("knob small up");

  if (baro_timer_running == 1)
  {
    baro_setting_adjusting = 1;
    if (baro_setting_unit == 0)
    {
      baro_setting = baro_setting + 0.01;

      setprop(Settings, "baro-setting-inhg", baro_setting);
    }
    elsif (baro_setting_unit == 1)
    {
      baro_setting_hpa = baro_setting * 0.03386389;
      baro_setting_hpa = baro_setting_hpa + 0.001;
      baro_setting = baro_setting_hpa / 0.03386389;

      setprop(Settings, "baro-setting-hpa", baro_setting_hpa);
    }
  }
  elsif (baro_timer_running == 0 and
         alt_button_timer_running == 0)
  {
    alt_preselect = alt_preselect + 20;
    setprop(Settings, "target-alt-ft", alt_preselect);

    if (getprop(Locks, "roll-mode") == "off" and
        getprop(Locks, "pitch-mode") == "off")
    {
      setprop(Annunciators, "alt-number", "on");
      if (alt_alert_on == 0)
      {
        alt_alert_on = 1;
      }
    }
  }
}


knob_l_up = func {
  #print("knob large up");

  if (baro_timer_running == 1)
  {
    baro_setting_adjusting = 1;
    if (baro_setting_unit == 0)
    {
      baro_setting = baro_setting + 1.0;

      setprop(Settings, "baro-setting-inhg", baro_setting);
    }
    elsif (baro_setting_unit == 1)
    {
      baro_setting_hpa = baro_setting * 0.03386389;
      baro_setting_hpa = baro_setting_hpa + 0.1;
      baro_setting = baro_setting_hpa / 0.03386389;

      setprop(Settings, "baro-setting-hpa", baro_setting_hpa);
    }
  }
  elsif (baro_timer_running == 0 and
         alt_button_timer_running == 0)
  {
    alt_preselect = alt_preselect + 100;
    setprop(Settings, "target-alt-ft", alt_preselect);
  
    if (getprop(Locks, "roll-mode") == "off" and
        getprop(Locks, "pitch-mode") == "off")
    {
      setprop(Annunciators, "alt-number", "on");
      if (alt_alert_on == 0)
      {
        alt_alert_on = 1;
      }
    }
  }
}


knob_s_dn = func {
  #print("knob small down");

  if (baro_timer_running == 1)
  {
    baro_setting_adjusting = 1;
    if (baro_setting_unit == 0)
    {
      baro_setting = baro_setting - 0.01;

      setprop(Settings, "baro-setting-inhg", baro_setting);
    }
    elsif (baro_setting_unit == 1)
    {
      baro_setting_hpa = baro_setting * 0.03386389;
      baro_setting_hpa = baro_setting_hpa - 0.001;
      baro_setting = baro_setting_hpa / 0.03386389;

      setprop(Settings, "baro-setting-hpa", baro_setting_hpa);
    }
  }
  elsif (baro_timer_running == 0 and
         alt_button_timer_running == 0)
  {
    alt_preselect = alt_preselect - 20;
    setprop(Settings, "target-alt-ft", alt_preselect);
 
    if (getprop(Locks, "roll-mode") == "off" and
        getprop(Locks, "pitch-mode") == "off")
    {
      setprop(Annunciators, "alt-number", "on");
      if (alt_alert_on == 0)
      {
        alt_alert_on = 1;
      }
    }
  }
}


knob_l_dn = func {
  #print("knob large down");

  if (baro_timer_running == 1)
  {
    baro_setting_adjusting = 1;
    if (baro_setting_unit == 0)
    {
      baro_setting = baro_setting - 1.0;

      setprop(Settings, "baro-setting-inhg", baro_setting);
    }
    elsif (baro_setting_unit == 1)
    {
      baro_setting_hpa = baro_setting * 0.03386389;
      baro_setting_hpa = baro_setting_hpa - 0.1;
      baro_setting = baro_setting_hpa / 0.03386389;

      setprop(Settings, "baro-setting-hpa", baro_setting_hpa);
    }
  }
  elsif (baro_timer_running == 0 and
         alt_button_timer_running == 0)
  {
    alt_preselect = alt_preselect - 100;
    setprop(Settings, "target-alt-ft", alt_preselect);

    if (getprop(Locks, "roll-mode") == "off" and
        getprop(Locks, "pitch-mode") == "off")
    {
      setprop(Annunciators, "alt-number", "on");
      if (alt_alert_on == 0)
      {
        alt_alert_on = 1;
      }
    }
  }
}


ap_init();

#alt_alert();
