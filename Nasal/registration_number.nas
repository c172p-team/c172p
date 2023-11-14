# Initialize Canvas system
# This depends on a special immat.ac model providing 2D-texture-planes to render on:
#   ImmatFuselageLeft, ImmatFuselageRight, ImmatWing, ImmatPanel



var ImmatCanvas = canvas.new({
    "name": "liveryCustomRegistration",   # The name is optional but allow for easier identification
    "size": [2048, 512], # Size of the underlying texture (should be a power of 2, required) [Resolution]
    "view": [2048, 512], # Virtual resolution (Defines the coordinate system of the canvas [Dimensions]
                        #   which will be stretched to the size of the texture, required)
    "mipmapping": 1      # Enable mipmapping (optional)
});
ImmatCanvas.setColorBackground(0, 0, 0, 0.0);

var immatCanvasGroup = ImmatCanvas.createGroup();

# Create text elements
var canvas_immat_text = immatCanvasGroup.createChild("text", "fuselage.immat.left")
                .setTranslation(1024, 256)      # The origin is in the top left corner
                .setAlignment("center-center")  # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                .show();                        # Actual showing/hiding is toggled in the immat.xml 


# Initialize the canvas system for a given module instance (nil=local model)
var initC172ImmatCanvas = func(target_module_id=nil) {
    # Place canvas on model

    if (target_module_id != nil) {
        # Multiplayer instance; var target_module_id is set in <load> of model xml
        print("C172 immat/registration: initialize multiplayer instance for target_module_id="~target_module_id);
        
        ImmatCanvas.addPlacement({"module-id": target_module_id, "type": "scenery-object", "node": "ImmatFuselageLeft"});
        ImmatCanvas.addPlacement({"module-id": target_module_id, "type": "scenery-object", "node": "ImmatFuselageRight"});
        ImmatCanvas.addPlacement({"module-id": target_module_id, "type": "scenery-object", "node": "ImmatWingLeft"});
    } else {
        # Local instance
        print("C172 immat/registration: initialize local instance");
        ImmatCanvas.addPlacement({"node": "ImmatFuselageLeft"});
        ImmatCanvas.addPlacement({"node": "ImmatFuselageRight"});
        ImmatCanvas.addPlacement({"node": "ImmatWingLeft"});
    }

    # Debug window, shows generated registration in dialog window
    #var window = canvas.Window.new([512, 128],"dialog");
    #window.setCanvas(ImmatCanvas);

}


# Function to be called to update the displayed registration texture,
# either for the local instance or a remote one
var set_registration_number = func (namespace, immat) {
    #print("C172 immat/registration: set_registration_number");
    var registrationCanvasUpdater = maketimer(0.5, func(){
        # Should run deferred, so the livery has time to overload the properties
        var livery_font   = namespace.getNode("sim/model/livery/immat/font_name",1).getValue();  # to be defined from livery xml
        var livery_size   = namespace.getNode("sim/model/livery/immat/font_size",1).getValue();
        var livery_font_r = namespace.getNode("sim/model/livery/immat/colour_r",1).getValue();
        var livery_font_g = namespace.getNode("sim/model/livery/immat/colour_g",1).getValue();
        var livery_font_b = namespace.getNode("sim/model/livery/immat/colour_b",1).getValue();
        if (livery_font != nil) {
            # Update the canvas registration elements
            print("C172 immat/registration: update registration: "~immat);
            canvas_immat_text.setText(immat)
                .setFont(livery_font) # Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_ROOT/Fonts
                .setFontSize(livery_size, 1.0)       # Set fontsize and optionally character aspect ratio
                .setColor(livery_font_r, livery_font_g, livery_font_b)           # Text color
                .setText(immat);
        } else {
            print("C172 immat/registration: livery misses canvas immat properties: skipping canvas update.");
        }
    });
    registrationCanvasUpdater.singleShot = 1;
    registrationCanvasUpdater.start();


    # Old code using text-translation (buggy in multiplayer! see https://sourceforge.net/p/flightgear/codetickets/2130/)
    # This is still needed for the immat on panel
    # TODO: we probably should convert that to casnvas too
    if (immat == nil)
        return;

    var glyph = nil;
    var immat_size = size(immat);

    if (immat_size != 0)
        immat = string.uc(immat);

    for (var i = 0; i < 6; i += 1) {
        if (i >= immat_size)
            glyph = -1;
        elsif (string.isupper(immat[i]))
            glyph = immat[i] - `A`;
        elsif (string.isdigit(immat[i]))
            glyph = immat[i] - `0` + 26;
        else
            glyph = 36;
        namespace.getNode("sim/model/c172s/regnum"~(i+1), 1).setValue(glyph+1);
    }
};
