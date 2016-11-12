List of features and bug fixes
==============================

Version 2016.4
--------------

* Improvements to the oil management (better function, oil now changes
  CG and weight of the plane, etc.)
* New ALS external view navigation, taxi and landing lights
* Added fire extinguisher and ELT models
* Bug fix for flashlight effect not illuminating the baggages
* Bug fix for interaction with external items in one of the tutorials
* Improvements to the autostart function

Version 2016.3
--------------

* Radio stack has been reworked (textures, 3D model)
* Radio stack illumination has been vastly improved and includes a
  daylight mode now (via RADIO LT at 0%)
* Fix bug with airspeed indicator
* Fix bug with the 3D model of the key in the ignition
* Fix bug which allowed to click on external hotspots while inside the cockpit
* Better autostart function, should work under more situations and warns
  the user if the engine fails to start
* The tooltip of the primer lever now shows the number of strokes
* Clock now displays local time
* Fix bug with battery: voltage now drains normally
* Add battery options and recharge button to aircraft menu
* Improved yoke model
* New splash screen no. 1
* Add ground equipment like safety pylons, ladder, fuel tank trailer, and
  ground power unit

Version 2016.2
--------------

* Decreased rudder authority
* Added propwash effect for 180 HP version
* Improvements to the irradiance effect
* Better oil dialog
* Flap lever is now dragable and scrollable
* Added normal map to wheels and other objects
* Improvements to the heading indicator
* Correct rudder pedal animation
* Updated tutorial to Barcelona
* Changed "Autostart" menu item to actually start the engine as well
* Split instrument light knob into a knob that two knobs: one that
  controls the instruments, and one that controls the radio's

Version 2016.1
--------------

* Ski's
* Amphibious plane improvements:
    - Added two metal reinforcement bars in the cockpit
    - Added panel for gear deploy and retract
    - Added water rudders retraction mechanism
* Saving state of switches is now optional
* Zooming with mouse scroll wheel in Helicopter View, Model View, and
  Walker Orbit View
* Additional views for co-pilot and passengers
* New sounds:
    - Rain (ambient and windshield) and thunderstorms
    - Wing damage
    - Wheel damage
* Windshield rain overhaul
* Opening the baggage door displays a window which allows weight to be
  added. Baggage will be displayed if the weight is high enough
* ASI now shows the IAS instead of the CAS
* Adjusted stall horn volume to sound to about 5-10 knots above stall speed
* Carburetor heat toggle now drops RPM as expected
* Oil consumption and management have been implemented
* Refactored fog/frost system: air flow now depends on airspeed and
  engine RPM. Supports overhead air vents, windows, and doors. Humans
  add extra heat and humidity.
* Preflight inspection improvements:
    - Added "Preflight Inspection" checklists and tutorial
    - Pitot tube can be clicked to add/remove a red "remove before flight" label
    - Nose wheel can be clicked to add/remove chocks
    - You can tie down the wings and tail to the ground. It will hold
      the aircraft even with full engine power.
    - Each fuel tank can randomly get contaminated with water. Samples
      from the fuel can be taken to test for contamination.
* Added GPS 196 device
* Fixed glass reflection in external views
* Improved lighting, including better looking navigation lights (and
  depending on viewing angle) in ALS
* Improved textures of instruments, primer, cabin air/heat levers in cockpit,
  and flap lever
* Smooth instead of instant animation of yoke, pedals, and parking brake
* Added menu item to open a web panel in your browser, showing most instruments
* Improved interior shadow and reflection cubes

Version 3.6
-----------

* Various ALS effects: flash light, 3D shadow, interior shadow, fog and
  frost, rain splashes, landing light
* Damage system:
    - Gear can be damaged upon rough landings
    - Wings can be damaged or break if g load limits or airspeed are exceeded
    - Smoke and sparks
* New HD liveries, panels and interior textures
* Improvements to the exterior 3D model: ADF antenna, back of the
  fuselage and rudder
* Cockpit panel improved:
    - Added primer, master switches, avionics switch, circuit breakers,
      cabin heat sliders
    - Better magneto's/starter switch
    - Improved textures of several instruments (AI, altimeter, CDI, HI,
      Hobbs meter, TC, VAC gauge, fuel selector)
* New sound effects (doors, parking brakes, knobs, trim wheel)
* Added (positioned) sounds to all buttons and switches
* Added flight recorder to record state of aircraft, including switches,
  damage, and effects
* Bush kits: 26" and 36" tires
* Sea plane variants: pontoons and amphibious. Amphibious variant has
  retractable gear. Both sea plane variants have water rudders
* Effects, lighting, damage, and human models visible over multiplayer
* 160 HP and 180 HP engine choice
* FDM improvements:
    - Better stall and spin behaviour
    - Float chamber
    - Hydrodynamics for the sea plane variants
* Improved sound and behaviour of stall horn
* Improved and new checklists
* Small improvements to instruments in radio stack
* Random splash screen while loading FlightGear
* Human models visible
