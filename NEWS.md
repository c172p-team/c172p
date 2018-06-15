List of features and bug fixes
==============================

Version 2018.2
--------------

**Features**:

* Major overhaul of the 3D model, including:
    * Thicker wings with a more rounded leading edge
    * Improved taxi and landing lights, VHF antennas and recessed fuel caps
    * Model ribs to show through broken wing
    * Improvements to tail and rudder, including animated rudder cables
    * Cowling now protrudes around the nose
    * Front windshield redesign to allow for proper vent fittings
    * Tie-down connections on the wing look a little more realistic
    * Added a vent line pipe to the left wing
    * New landing gear strut steps and improved strut to fuselage connection
    * Improved textures of air intake, cockpit bars, trim wheel, propeller, glare shield, tires
    * Add two sided prop blur to livery system
    * Moved panel upwards
    * Improved flap model and animation
    * New exterior door handles and relocated bottom door hinges
    * Added GPS device with a new texture and added mount
    * Added rudder pedal push rod model, sump port models, animated cabin air vent, engine compartment vent, wing vent holes, elevator trim tab
    * New disc brakes, cowling handhold, animated oil door and cap, animated fuel caps
* Improved ground equipment
* The f key can be used to toggle the flash light
* Changes to the FDM:
     * Allow aerodynamic interaction between the aircraft and AI traffic models
     * Make the pitch axis less sensitive to control. Increase the adverse yaw, also results in a better slip-skid-ball behaviour
* Added a new HD livery: N73429
* Improved sounds:
    * Better engine sound based on a real recording 
    * New idle engine sound which is cross-faded with the regular engine sound so that it is only perceived at low RPMs. It has that characteristic "rumbling" of low RPM
    * New crank and engine start sounds, much improved from the default ones. In particular, the engine now starts with a large "thump" just like a real engine does
    * New sound for when the engine is cut, also based on a real 172 recording
    * New sounds for the primer lever, a low volume squeak sound based on reference videos of startup procedures
* Added registrations to the bottom wing of all liveries
* Implemented engine damage when flying at a RPM higher than the red mark
* More advanced oil management and consumption calculation
* Improved hydrodynamic modeling
* Support mooring (including rope and buoy animation) and spawning at a seaport

**Fixes**:

* Animation of primer and carburettor heat levers so that they don't just flip between their binary positions
* Autopilot buttons are now animated
* Applied shadow effect to more objects in the cabin
* Fixed a bug with the control lock being added to a hidden yoke
* Fix some switches in the KMA 20 instrument changing the dials in the two radio's below it
* Improved DME clickspots
* Nose wheel is no longer buried in the ground
* Fix collision of beacon lights with beacon lamp model

Version 2018.1
--------------

* New images for the new splash screen and thumbnails system
* FDM improvements:
    - Fixed deflection angles of ailerons and roll moment due to ailerons
    - Added spiraling propwash effect (requiring right rudder at full
      throttle, low airspeed)
    - Made the elevator action at high AoA asymmetric in order to take
      into account the screening effect of the horizontal stabilizer in
      such stall conditions
    - Increasing the side force due to rudder, to make it consistent with
      the exerted moment
    - Decreasing the adverse yaw (the aileron trim gave too much
      slip-skid-ball deviation at cruise)
* Increased maximum rotation of yoke from 70 to 90 degrees
* Use shift + q to reset view
* Added avionics sound
* Fixed bug with oil temperature and pressure gauges (they were not working
  when complex engine procedures was toggled off)
* Fixed bug with lighting of pontoon wake effect
* Eliminated wingtip and tail sparks when over water
* Eliminated sparks of broken gear while aircrafts sits on the flight deck
  of a moving carrier
* Fixed some bugs with the walker

Version 2017.1
--------------

* Control surfaces can be checked for free movement during preflight inspection
* The opening of the baggage dialog was delayed as to wait for the
  animation of the baggage door
* Cleaning up the Aircraft Options dialog
* Improvements to the Ground Equipment dialog
* Callsigns of new users are automatically randomized to avoid them blocking
  other new users on multiplayer
* New About This Aircraft dialog, with information about the project as
  well as relevant links
* The pilot's yoke can now be locked with a control lock (lock can be found
  in the bag on the left of the pilot's seat)
* Fix bug with ADF timer in the radio stack
* Added view for IFR training
* Improvements to the carburetor system (icing, carb heat)
* Improvements to the engine coughs (due to fuel contamination or carb ice)
* Lowered limit of critical oil level according to Lycoming's manual
* Critical oil will not cause the engine to cough, it will simply quit when
  oil reaches the critical value of 2 quarts
* Improved fuel contamination system (fixed some bugs)
* More realistic bush wheels and tires
* Fuselage shows fresnel effect

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
