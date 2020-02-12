The Bendix/King KAP 140 (version 1.0)
-------------------------------------

This implementation is build according to the user manual.
You can set the desired model in the kap140-config.xml (comments are there).
If your aircraft has a encoding altimeter, point the config to the right properties and
set 'baro-tied' to true.
If not, set up a extra altimeter in your /sim/instrumentation/, config the properties
to the extra altimeter and set 'baro-tied' to false.
Configure the nav-selector in nav-selector-config.xml.
This enables you to use up to three navigation sources (nav radios, rnav devices, GPS, etc...).
You can bind buttons or a switch to change '/instrumentation/nav-source/selector' to 0, 1 or 2.
If you only have one source, configure only the first and avoid a switch or button in the cockpit.

If the KAP140 isn't tied with a altimeter, the standard pressure will flash after Pre Flight Test (PFT) is finished.
As long as the standard pressure is flashing, the autopilot can't be activated!
The pilot must set the desired pressure (with the knobs) or confirm the standard pressure (press BARO button).

If your aircraft has a HSI installed, set 'hsi-installed' to true.
If not, there is no radial pointer, therefor the KAP140 uses the heading bug for the radial.
In this situation, if you switch from ROL or HDG to NAV, APR or REV, you will see HDG blink
in the display for 5 seconds as a reminder for the pilot to set the heading bug to the desired radial.
After 5 seconds (blinking HDG stops), the KAP140 take the heading bug as radial.

To activate the KAP140, press and hold the AP button for at least 0.25 seconds.

Engaging the NAV, APR or REV mode happens if the aircraft is close enough.
This means, the deviation needle is only 3 points left or right of the center (or closer).
The actual scaling of the points doesn't matter. Normally, on VOR one point represent 2 degrees and
on LOCalizer (ILS) one point represent 0.8 degrees. Often on RNAV one point represent 1nm.
But the KAP140 doesn't know the scaling. It catch inside 3 point left or right.

If the KAP140 is in NAV, APR or REV mode and the deviation needle move more then 3 points away,
the mode starts flashing. The autopilot will try to come back on the right track.
If the autopilot isn't back in the next 30 seconds, it automatically disengage.

If the autopilot is in VS mode, one press on UP or DOWN button switch the display to show the actual FPM without altering.
Every press on the UP or DOWN button while the FPM is shown in the display, will alter the rate by 100fpm.
If you press and hold the UP or DOWN button, the rate will be changed by around 300fpm per second.

If the autopilot is in ALT mode, the UP and DOWN button set the holding altitude up or down by around 20ft.
If you press and hold the UP or DOWN button, the autopilot command a climb/descend with 500fpm.
Immediately as you release the button, the autopilot catch the new pressure altitude.

!!! Caution !!!
The 'kap140-autopilot.xml' is only a example to show what settings must be checked for every mode.
It is important to replace the filter and controller with your own.
Make sure your filter and controller check the right properties.


Include the KAP 140 in your aircraft:
-------------------------------------

- copy the 'kap140' directory inside your aircraft tree
    (as example to 'Models/Interior/Panel/Instruments/')

- add the 'kap140.xml' to your panel (like every other model)

- if your aircraft hasn't a encoding altimeter, add a 'altimeter' in your instrumentation
    (under <sim> … <instrumentation>)

- open the file 'kap140-config.xml' and configure your setup

- open the file 'nav-selector-config.xml' and configure your setup

- add the file 'kap140-proprules.xml' as property rule under '<sim> … <systems>' in your set-file

- add the file 'nav-selector.xml' as property rule under '<sim> … <systems>' in your set-file

- add the file 'kap140-autopilot.xml' as autopilot under '<sim> … <systems>' in your set-file

- add the following lines under '<sim>' in your set-file:

<!-- kap140 begin -->
  <autopilot>
    <internal>
      <target-climb-rate type="int">0</target-climb-rate>
      <target-altitude type="int">0</target-altitude>
      <target-pressure type="double">0.0</target-pressure>
      <target-roll-deg type="double">0.0</target-roll-deg>
    </internal>
    <kap140>
      <serviceable type="bool">true</serviceable>
      <powered type="bool">false</powered>
      <programmed type="bool">true</programmed>
      <roll-axis-fail type="bool">false</roll-axis-fail>
      <pitch-axis-fail type="bool">false</pitch-axis-fail>
      <bad-condition type="bool">false</bad-condition>
      <config>
        <model type="int">3</model>
        <power type="double">24.0</power>
        <hsi-installed type="bool">true</hsi-installed>
        <default-altitude type="int">4500</default-altitude>
        <baro-tied type="bool">true</baro-tied>
      </config>
      <panel>
        <state type="int">0</state>
        <state-old type="int">0</state-old>
        <alt-alert type="double">0.0</alt-alert>
        <alt-alert-arm type="double">0.0</alt-alert-arm>
        <alt-alert-sound type="bool">false</alt-alert-sound>
        <ap-timer type="double">0.0</ap-timer>
        <button-ap type="double">0.0</button-ap>
        <button-up type="double">0.0</button-up>
        <button-down type="double">0.0</button-down>
        <baro-button type="double">0.0</baro-button>
        <baro-timer type="double">0.0</baro-timer>
        <baro-mode type="int">0</baro-mode>
        <baro-mode-old type="int">0</baro-mode-old>
        <digit type="int">0</digit>
        <digit-mode type="int">0</digit-mode>
        <digit-timer type="double">0.0</digit-timer>
        <fpm-timer type="double">0.0</fpm-timer>
        <hdg-timer type="double">0.0</hdg-timer>
        <pft-1 type="double">0.0</pft-1>
        <pft-2 type="double">0.0</pft-2>
        <pft-3 type="double">0.0</pft-3>
        <pt-up type="bool">false</pt-up>
        <pt-down type="bool">false</pt-down>
      </panel>
      <sensors>
        <elevator-trim type="double">0.0</elevator-trim>
        <pitch-up type="double">0.0</pitch-up>
        <pitch-down type="double">0.0</pitch-down>
        <pitch-trim type="double">0.0</pitch-trim>
        <!--pitch-force type="double">0.0</pitch-force-->
        <!--roll-force type="double">0.0</roll-force-->
      </sensors>
      <servo>
        <aileron type="double">0.0</aileron>
        <aileron-rate type="double">0.0</aileron-rate>
        <elevator type="double">0.0</elevator>
        <elevator-rate type="double">0.0</elevator-rate>
      </servo>
      <settings>
        <cws type="bool">false</cws>
        <lateral-mode type="int">0</lateral-mode>
        <lateral-arm type="int">0</lateral-arm>
        <vertical-mode type="int">0</vertical-mode>
        <vertical-arm type="int">0</vertical-arm>
      </settings>
    </kap140>
  </autopilot>
<!-- kap140 end -->

- move the sound files (kap140-alert.wav and kap140-disengage.wav) in your sound directory

- add the following lines in your sound.xml (don't forget to set the position correctly):

<!-- kap140-sound end -->
    <kap140-disengage>
      <name>KAP140 disengage</name>
      <path>kap140-disengage.wav</path>
      <condition>
        <or>
          <equals>
            <property>autopilot/kap140/panel/state</property>
            <value>3</value>
          </equals>
          <property>autopilot/kap140/panel/ap-timer</property>
        </or>
      </condition>
      <volume><factor>0.2</factor></volume>
      <position>
        <x>-0.444</x>
        <y> 0.229</y>
        <z> 0.312</z>
      </position>
    </kap140-disengage>

    <kap140-alert>
      <name>KAP140 altitude alerter</name>
      <path>kap140-alert.wav</path>
      <condition>
        <property>autopilot/kap140/panel/alt-alert-sound</property>
      </condition>
      <volume><factor>0.2</factor></volume>
      <position>
        <x>-0.444</x>
        <y> 0.229</y>
        <z> 0.312</z>
      </position>
    </kap140-alert>
<!-- kap140-sound end -->

- add the following lines under '<sim> … <instrumentation>' in your set-file:

<!-- nav-selector begin -->
    <nav-source>
      <selector type="int">0</selector>
      <in-range type="bool">false</in-range>
      <from-flag type="bool">false</from-flag>
      <to-flag type="bool">false</to-flag>
      <nav-loc type="bool">false</nav-loc>
      <has-gs type="bool">false</has-gs>
      <gs-in-range type="bool">false</gs-in-range>
      <gs-rate-of-climb type="double">0.0</gs-rate-of-climb>
      <gs-rate-of-climb-fpm type="double">0.0</gs-rate-of-climb-fpm>
      <heading-needle-deflection type="double">0.0</heading-needle-deflection>
      <heading-needle-deflection-norm type="double">0.0</heading-needle-deflection-norm>
      <gs-needle-deflection type="double">0.0</gs-needle-deflection>
      <selected-radial-deg type="double">0.0</selected-radial-deg>
      <target-radial-deg type="double">0.0</target-radial-deg>
      <course-error type="double">0.0</course-error>
    </nav-source>
<!-- nav-selector end -->

The KAP140 support CWS (Control Wheel Steering).
To use this feature, add the following lines to your keyboard.xml:

<!-- CWS begin -->
  <key n="99">
    <desc>Control Wheel Steering (CWS)</desc>
    <binding>
      <command>property-assign</command>
      <property>autopilot/kap140/settings/cws</property>
      <value>1</value>
    </binding>
    <mod-up>
      <binding>
        <command>property-assign</command>
        <property>autopilot/kap140/settings/cws</property>
        <value>0</value>
      </binding>
    </mod-up>
  </key>
<!-- CWS end -->





Finish!
Happy flying :)
Sascha Reißner
2019
