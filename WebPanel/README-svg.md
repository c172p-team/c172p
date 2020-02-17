
Some tips for working with SVG files in Inkscape.

# Size

The height and width attributes of the SVG MUST be set to "100%" to allow rescaling the instrument.
Inkscape doesn't seem to have a dialog to set this kind of size, and you must either edit the header
of the SVG file in your favourite browser, or use the internal XML editor in Inkscape.

# Dimensions

Identifying the center point for translation/rotation animations is tricky, because this point is
set BEFORE applying the matrix transformation on you object. Check the dimensions of the object in the
object attributes to calculate correctly the rotation center of the amount or the right translation.
You can check these dimensions and matrix transformation in Inkscape's internal XML editor.

# Gradients

Gradients in all SVG files MUST have a unique identifier. If two SVG files have gradientes with the same
gradient identifier the object will be rendered using the first loaded gradient and the second will be ignored.
This depends on the browser AND the OS: the second gradient is ignored in Firefox for Windows, but not in
Firefox for iOS.

As a result, you MUST change all gradient identifiers. I couldn't find any way to do this in Inkscape, so
load the SVG file in you preferred editor and run a regular expression like this:

(Visual Code Studio regex)

```
Search: (["#])(linear|radial)Gradient
Replace: $1lv$2Gradient
```

Change the preffix "lv" for something unique to the SVG file.

# Caching SVG

Phi has configured a long time for files to be cached. As a result, many browsers will cache the SVG files
for a long time and your changes won't be visible even for days. Deactivate the cache during development
(desktop browsers) or clean regularly the browser cache (mobile browsers)