# In case you want to know, why the last line of the docstring below looks like it is:
# It will show the package (local) path when help on the package is invoked like     help?> WrappedViz
# but it will interpolate to an empty string on CI server, 
# preventing appearing the server local path in the documentation built there

module WrappedViz

export hello, init_book

using BonitoBook, Makie, WGLMakie, Gtk, JSON3, DataFrames

function hello()
    println("Hello from WrappedViz!")
end

function init_book()
    println("Initializing WrappedViz book...")
    BonitoBook.book("notebook/book.md")
end

function book_bulleplot()
    println("Book with bulle plot example")
    BonitoBook.book("notebook/code_bulleplot.md")
end

end # module

