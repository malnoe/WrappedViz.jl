# In case you want to know, why the last line of the docstring below looks like it is:
# It will show the package (local) path when help on the package is invoked like     help?> WrappedViz
# but it will interpolate to an empty string on CI server, 
# preventing appearing the server local path in the documentation built there.

"""
    Package WrappedViz v$(pkgversion(WrappedViz))

What did you listen to ?

$(isnothing(get(ENV, "CI", nothing)) ? ("\n" * "Package local path: " * pathof(WrappedViz)) : "") 
"""

module WrappedViz

# Write your package code here.

end
