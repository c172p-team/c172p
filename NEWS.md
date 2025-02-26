List of features and bug fixes
==============================

Version 2024.1
--------------

**Features:**

* Add winter kit, Cowl grill, expanded icing systems and effects
* Ground services improvements
* Convert Custom Registration to Canvas
* Magnetic Compass enhancements including deviation card
* KX165: Add squelch test to COM radio volume knob
* Add Towbar
* Avionics fan added
* C172sp: Avionic fans added
* Multiplayer engine sound
* Starter overheat simulation
* STICK-FORCE-PER-'g' effect of dynamic pressure on flt controls
* Cockpit flight controls react to trim settings

**Fixes:**

* New fuel gauge texture, thinner oil and fuel gauge needles
* Refactor tiedown logic
* Account for variant properties and others in save/restore logic
* Remove duplicat avionics switch
* GUI refactoring
* Clean up unneeded and unused aliases
* Add alt static port source system
* Slower response for interior static ports
* User volunteer removal of copyright defer to GPA license
* Glass rain effect improvements
* Miscellaneous tutorial fixes
* Miscellaneous glass refactoring
* Ground services bugs
* Wrong property binding for chocks
* Fix NAV needle deflections
* Show rounded headings in tooltips
* VSI damped at sim start and when on the ground
* Fixed conflicts path with MP aircraft system
* Improved Towbar model and fixes
* Magnetic Compass: Clamp roll/pitch animation
* Add transpaent yoke hiding
* Flashlight: synchronize with walker flashlight
* Flashlight: replace ALS by compositor implementation
* Fix autopilot DigitalFilter: unknown config node: value
* Update gyro instruments to current "next" enhancements
* Adjust mixture setting to be able to go over-rich
* Add default props/values for vertical-speed-indicator
* Added ICAO and performance data
* Electrical fix: Turn coordinator flag and power source
* Electrical fix: Ground Power Unit supplies pwr only with master switch
* Turn-coordinator gyro sound depending on spin now
* Avionics switch acts also as circuit breaker (POH 7-26)
* C172sp: Removed turn-coordinator from electrical system
* C172sp: STBY-BAT-LAMP and switch reworked
* C172sp: ESS/AVN Bus wiring corrected
* C172SP: Master-bat switch on for external power to system
* KR87 ADF: Prevent overflow
* KR87 ADF: Implement direct set of active frq in FLT/ELT mode
* KR87 ADF: Added ET count down mode
* KR87: Add ET countdown aural alarm
* Add "X" to aircraft dialog closing buttons (in the window header)
* Add a fallback model index
* Add ALT mode to Throttle/Mixture levers
* Throttle/mixture adjusted to 5% increments for "normal" use
* Added finer ALT mode to elevator and rudder trim
* Fix bug with ADF power switch shutting off also DME
* Fix yoke normals
* Parking brake-lever animation enhanced
* Limit rudder-trim by a filter
* Switched compass pitch/roll to daped c++ values
* KMA20: Made AUTO mode work and make panel failable
* KMA20: Audio panel now has fgcom integration
* KMA20: Listeners only fire when values change
* Refactor throttle controls to work with throttle all

Version 2020.4.1
--------------

**Features:**

* Multi-key suppoet for FG1000 variant

**Fixes:**

* Refactor code for reposition-reinit
* Preset airport tag in tutorials causing problems
* Fuel selector object assigned wrong effect file
* Fix various ac modeling issues
* More robust variant definition code seperation
* Add amphibious gear keyboard bindings
* Removed forced invert mouse wheel
* Invert overhead light controls
* Better and more particle effects
* Fix unusable fuel issue
* Fix material animation and effects def before knob animation bug
* FG1000 audio panel and radio bug fixes
* Hobbs track engine hours per engine
* Add fg1000 glass, glass panel and audio panel to avionics rheostat knob
* Hobbs intreior lighting
* PFD/MFD power consumption less when dimmed
* KAP140 digits color to better match other electronics
* Fix KAP140, dme and kr87 avionics lighting
* Add magnetic compass integral lighting
* Absolute paths to relative for MP compatibility
* Amphibious gear deployment depends on location when equipment change occurs
* Refactor lighting and position of kap140 on fg1000 panel
* Refactor lighting and position of amphib gear ctrl on fg1000 panel
* Refactor lighting and position of elt on fg1000 panel
* Refactor lighting and position of hobbs on fg1000 panel
* Fix amphibious gear spring discrepancy
* Adjust x and Z position on various gear configuration
* Soften the main ski bogey spring coefficient
* FDM - Adverse yaw adjustment
* FDM - Decrease pitch up tendency at full thrust
* FDM - Correct X VRP
* FDM - Combine two Z offsets into a single one, VRP only
* FDM - Fix deg to rad conversion on roll moment to yaw rate

Version 2020.4
--------------

**Features:**

* Completely new 172sp FG1000 variant
* Add 2020.4 clustered shading lighting support
* Compositor compatibility and real time shadows
* Add support for aerotow to allow gliders to be towed by the C172P
* Add revised and improved KAP140

**Fixes:**

* VOR/NAV guages: add missing yellow ticks and OBS label
* VOR/NAV guages: fix localizer needle rotation center
* Correct typos in the 'Flying the Pattern' tutorial
* Fix parking brake binding on joysticks; improve the parking brake control
* Fix issue where the engine wouldn't quit after a plane crash
* Fix issue where external views would break after switching airports
* Re-add the default mouse action when in a viewfrom view mode.
* Fix NAV and COM radio electrical source
* Refactor c172p amp draw calculations
* Correct battery amp hours
* Power of two texture correction
* Improved aircraft variant set file isolation

Version 2020.3
--------------

**Features:**

* Add integral fuel tank option and refactor fuel system to allow for operation
* Fuel selector: improved textures
* Engine startup shaking effect (from c182s)

**Fixes:**

* Turn magnetos on when using ignition key
* FDM: Improve fuel tank locations, COG z location
* Tutorials: Repair aircraft at the start of each tutorial
* Instruments: AI offset knob limited and finer control
* Trim: fix rudder trim sound; adjust animations and sensitivity of trim wheels
* Fix iCCP Color Profile on textures
* Corrected a typo in the engine oil management system
* Add versioning to the propeller configuration files
* Point cones material texture to a valid texture

Version 2020.1
--------------

**Features:**

* New sounds for rolling and tire screeching on both paves and gravel surfaces
* Replaced the KX165 with the KX165A radio which supports 8.33 frequencies
* New mooring locations
* `f` shortcut now toggles flashlight

**Fixes:**

* Fixed xy-plane and missing texture error messages
* Corrected a segfault caused when you lower and then raise the amphibious gear on land
* Turn coordinator gyros breaker was not hooked up
* Fix amphibious gear control breaker logic
* Amphibious gear switch now does not triger repair timer while pontoon damaged
* Initialization of new traversing property which is may prevent issues on some systems
* Fix strong pitch oscillations at rest with brakes on and with pure crosswind
* Fix Nasal error due to a typo in avionics.nas
* Changing xml version to 1.0 in xml file headers as this is the supported version
* Radio tutorial now requires the user to turn on the battery and avionics switches
* Fixed minor spelling mistake in preflight tutorial

Version 2019.1
--------------

**Features:**

* Persistent adjustable pilot seat/view position
* New seat frame modeling
* New fog and frost overlay showing heat and air vent effect
* Wheels sink based on ground cover density
* Tire size influences  tire friction
* Wheels sink based on snow depth
* Snow depth influences tire friction
* Prop spray effect at high rpm in float variant
* New locked brake smoke effect
* Add rudder trim system to interior cabin panel
* Add brake influence to nose wheel steering and disable NWS when airborne
* Animate front caster wheels
* Extend support for CH Throttle Quadrant joystick
* Implement default renderer interior lighting
* Reshape and widen 26" and 36" bush tires to 12" and 15"
* Autostart function includes auto-mixture

**Fixes:**

* Exterior fuselage mesh cleanup
* Fix broken hydrodynamics
* Fix nasal errors and segfaults
* Skis now slide on ice and snow
* Added fallback model support
* Account for the volume of unusable fuel
* Fix cowl plugs issue in tutorials
* Fix invalid version issue
* Adjust damage effect spark size
* Adjust P-factor
* Correct rain animation over windshield
* Correct wheel spin rolling animation ratio
* Set mixture rich to 3000 ft
* Fix visor rotation issue
* Fix ADF to read khz and not mhz
* Fix default values of selected and standby radio frequencies
* Mixture set to 1 at sea level in autostart 
* Fix flap click sound
* Fix animations of COMs, NAVs and ADF knobs
* Correct texture mapping of axles
* Correct texture mapping of interior hydro rudder mechanism

Version 2018.3
--------------

**Features**:

* Improved 3D models and textures of all levers, toggles, seats, magneto keys, EGT gauge and attitude indicator
* New recess casings to all panel instruments
* Improved labels of panel texture 
* Added 3D models to cockpit:
    - Alternate static source knob
    - Glove pocket to panel (holds GPS device when not in use)
    - Lighter hole
    - Overhead panel light switches for red flood, gauge post, and white dome/courtesy lights
    - Low Voltage LED
    - Sunvisors
    - PPT cables connected to the yokes
* New ammeter gauge matching the model used in the 172P
* Light maps for red flood, gauge post and white dome light
* ALS procedural lights (glare) for red flood, gauge post, white dome and wing courtesy light
* Light map illumination and procedural glare responds to available light and dims during daylight
* Re-positioned and improved 3D models and textures of all levers
* Added ambient occlusion map to all interior textures
* Added glass effect for gauges
* New sounds, including when clicking on the checklist, adding/removing control lock, mounting/dismounting GPS, opening/closing glove pocket, opening/closing the window latches, extending/retracting the water rudder cable
* Better sound for flaps lever and motor
* Interlocked master switch (BAT and ALT)
* GPS antenna is now up by default
* GPS night mode
* Amphibious gear advisor activated
* New amphibious gear lever
* Expanded help tool tips
* Add subtle glass reflection to panel instruments and radio stack
* Moved tutorials to Hilo Airport (PHTO)
* Improved tutorials and added two new ones: take off and landing for float variants
* Much improved propeller model
* Improved handle animation of doors and baggage door
* Doors should now be closed from the inside using the door strap
* Air resistance will force an open door or baggage door backwards
* Improved KMA20's marker sensitivity toggle animation
* Much improved vertical stabilizer model, including a retopologized beacon model
* Added external antennas for the ELT, transponder, ADF and marker beacons
* Removed wire connecting the wings to the tail as our ADF receiver uses a different type of antenna
* Animated water rudder cable
* New digital clock added
* New five slot Save and Resume feature
* QT launcher variant selection support
* QT launcher Location support including "On approach"

**Fixes**:

* Most of the cases of multiple objects mapped to a single texture have now been solved by assigning each their own texture
* 3D models of rotary knobs of VOR and NAV radios now turn 360 degrees
* Corrected the label of the OBS knob of the heading indicator
* Implemented a particle effect color and light manager for smoke and spray
* Adjusted P-factor effect
* Strobe lights are stronger now
* Fixed issue which caused the landing light to appear green under certain situations
* Removed shadow effect from radio stack readouts
* Autopilot readouts now match the rest of the radio stack in both colour and intensity
* Added a black panel behind the broken wing structure

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
