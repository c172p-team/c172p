# Web panel for Cessna 172p -detailed

This is a separate instrument panel to be run in a web browser, which could
be useful when building a flight training device setup using two monitors,
or for example by using a tablet or second computer as your instrument panel
when flying.

This is still fairly new feature in flightgear and this particular panel is 
still work in progress and thus incomplete, but hopefully useful. Contributions
are also welcome.

You can access the panel from the aircraft menu in FlightGear, and you need
to have the built-in HTTP server running on port 8080.

This panel uses parts from the following:

   * Some instruments derived from the web panel of the excellent [SenecaII](http://sourceforge.net/p/flightgear/fgaddon/HEAD/tree/trunk/Aircraft/SenecaII/) by Torsten Dreyer.
   * The panel uses the [Twitter Bootstrap web framework](http://getbootstrap.com) for layout, it is included locally so that the panel works without an internet connection - although you will need a connection between flightgear and the computer showing the panel in browser.
