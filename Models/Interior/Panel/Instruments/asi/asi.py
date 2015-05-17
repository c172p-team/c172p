#!/usr/bin/env python

from svginstr import *
import sys

__author__ = "Melchior FRANZ < mfranz # aon : at >"
__url__ = "http://gitorious.org/svginstr/"
__version__ = "0.2"
__license__ = "GPL v2+"
__doc__ = """
"""


try:
	a = Instrument("asi.svg", 512, 512, "test face; " + __version__)
	a.disc(98, color = 'black')
	a.disc(1)

	# define mapping function: map scale value 30 - 160 to angle 0-320 degree.
	# However, the values from 100-160 are compressed slightly, so the lambda function is just 120 values
	a.angle = lambda x: x * 300.0 / 115.0 - 145.0

	# inside line
	l = 50

	# compression
	compress = 0.8

	a.arc(44, 100 + 27 * compress, l+3, width = 8, color = "green")
	a.arc(100 + 27 * compress, 100 + 58 * compress, l+3, width = 8, color = "yellow")
	a.arc(33, 85, l, width = 3, color = "white")

	for i in range(35, 100, 5):
		a.tick(i, l, 58, 2)

	for i in range(100, 152, int(5 * compress + 0.5)):
		a.tick(i, l, 58, 2)

	for i in range(40, 100, 10):
		a.tick(i, l, 65, 2)

	for i in range(100, 155, int(10 * compress + 0.5)):
		a.tick(i, l, 65, 2)

	a.tick(100 + 58 * compress, l, 60, color="red")

	# mph conversion
	mph = 0.8689
	k = 30
	for i in range(40, 100, int(10 * mph)):
		a.tick(i, k, k + 6, 1)
	for i in range(40 + int(65 * mph), 150, int(10 * mph * compress)):
		a.tick(i, k, k + 6, 1)



	# fc-list tells you the names of available fonts on Linux  (fc ... font cache)

	s = 13

	a.at(0,-70).text("AIRSPEED", size = 10, font_family = "Lucida Sans", color = "white")
	a.at(0,-55).text("KNOTS", size = 10, font_family = "Lucida Sans", color = "white")
	a.at(60,-42).text(40, size = s, font_family = "Lucida Sans", color = "white")
	a.at(75,20).text(60, size = s, font_family = "Lucida Sans", color = "white")
	a.at(35,72).text(80, size = s, font_family = "Lucida Sans", color = "white")
	a.at(-40,72).text(100, size = s, font_family = "Lucida Sans", color = "white")
	a.at(-75,30).text(120, size = s, font_family = "Lucida Sans", color = "white")
	a.at(-75,-20).text(140, size = s, font_family = "Lucida Sans", color = "white")
	a.at(-45,-57).text(160, size = s, font_family = "Lucida Sans", color = "white")

	# mph markings
	s = 7
	a.at(16,-18).text(40, size = s, font_family = "Lucida Sans", color = "white")
	a.at(22,2).text(60, size = s, font_family = "Lucida Sans", color = "white")
	a.at(16,20).text(80, size = s, font_family = "Lucida Sans", color = "white")
	a.at(0,27).text(100, size = s, font_family = "Lucida Sans", color = "white")
	a.at(-14,22).text(120, size = s, font_family = "Lucida Sans", color = "white")
	a.at(-19,13).text(140, size = s, font_family = "Lucida Sans", color = "white")
	a.at(-22,0).text(160, size = s, font_family = "Lucida Sans", color = "white")
	a.at(-17,-14).text(180, size = s, font_family = "Lucida Sans", color = "white")
	a.at(0,-20).text("MPH", size = s, font_family = "Lucida Sans", color = "white")
	#a.at(75,20).text(60, size = s, font_family = "Lucida Sans", color = "white")
	#a.at(35,72).text(80, size = s, font_family = "Lucida Sans", color = "white")
	#a.at(-40,72).text(100, size = s, font_family = "Lucida Sans", color = "white")
	#a.at(-75,30).text(120, size = s, font_family = "Lucida Sans", color = "white")
	#a.at(-75,-20).text(140, size = s, font_family = "Lucida Sans", color = "white")
	#a.at(-45,-55).text(160, size = s, font_family = "Lucida Sans", color = "white")

except Error as e:
	print >>sys.stderr, "\033[31;1m%s\033[m\n" % e

