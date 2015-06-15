var set_registration_number = func (namespace, immat) {
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
        namespace.getNode("sim/model/c172p/regnum"~(i+1), 1).setValue(glyph+1);
    }
};
