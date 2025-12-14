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
    # Notebook "source" dans le package
    src_dir  = joinpath(pkgdir(@__MODULE__), "src", "notebook")
    src_file = joinpath(src_dir, "book.md")

    @assert isfile(src_file) "book.md introuvable: $src_file"

    # Dossier writable (temp) pour exécuter BonitoBook
    run_dir = mktempdir()
    dst_dir = joinpath(run_dir, "WrappedViz_notebook")
    cp(src_dir, dst_dir; recursive=true, force=true)

    dst_file = joinpath(dst_dir, "book.md")
    println("Launching BonitoBook from: ", dst_file)

    return BonitoBook.book(dst_file)
end

function book_example()
    path = joinpath(pkgdir(@__MODULE__), "src", "notebook", "exemple_book.md") |> normpath
    println("Wrapped Viz loading", path)
    return BonitoBook.book(path)
end

end # module