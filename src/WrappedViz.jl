# In case you want to know, why the last line of the docstring below looks like it is:
# It will show the package (local) path when help on the package is invoked like     help?> WrappedViz
# but it will interpolate to an empty string on CI server, 
# preventing appearing the server local path in the documentation built there

module WrappedViz

export book_final, book_example, txt_temps_ecoute,bp_monthly_tracks, bp_daily_tracks, windrose_hourly_tracks, bbplot_artists, bbplot_tracks, data_cleaning

include("data_cleaning.jl")
include("vizus.jl")

using BonitoBook, Makie, WGLMakie, Gtk, JSON3, DataFrames, Dates, GLMakie, Bonito, Pkg

function book()
    path = joinpath(pkgdir(@__MODULE__), "src", "notebook", "book.md") |> normpath
    println("Wrapped Viz loading", path)
    return BonitoBook.book(path)
end

function book_example()
    path = joinpath(pkgdir(@__MODULE__), "src", "notebook", "exemple_book.md") |> normpath
    println("Wrapped Viz loading", path)
    return BonitoBook.book(path)
end

end # module

