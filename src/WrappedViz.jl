# In case you want to know, why the last line of the docstring below looks like it is:
# It will show the package (local) path when help on the package is invoked like     help?> WrappedViz
# but it will interpolate to an empty string on CI server, 
# preventing appearing the server local path in the documentation built there

module WrappedViz

export book_final, book_example, txt_temps_ecoute,bp_monthly_tracks, bp_daily_tracks, windrose_hourly_tracks, bbplot_artists, bbplot_tracks, data_cleaning

include("data_cleaning.jl")
include("vizus.jl")

using BonitoBook, Makie, WGLMakie, Gtk, JSON3, DataFrames, Dates, GLMakie, Bonito, Pkg

function _copytree(src::AbstractString, dst::AbstractString)
    mkpath(dst)
    for (root, dirs, files) in walkdir(src)
        rel = relpath(root, src)
        out_root = rel == "." ? dst : joinpath(dst, rel)
        mkpath(out_root)
        for d in dirs
            mkpath(joinpath(out_root, d))
        end
        for f in files
            srcf = joinpath(root, f)
            dstf = joinpath(out_root, f)
            Base.Filesystem.cp(srcf, dstf; force=true)
        end
    end
    return dst
end

function _make_writable(dir::AbstractString)
    for (root, _, files) in walkdir(dir)
        for f in files
            p = joinpath(root, f)
            try
                chmod(p, 0o666)  # enlève read-only sur Windows
            catch err
                @warn "Could not chmod $p" err
            end
        end
    end
end

function book()
    src_dir  = joinpath(pkgdir(@__MODULE__), "src", "notebook")
    src_file = joinpath(src_dir, "book.md")
    @assert isfile(src_file) "book.md introuvable: $src_file"

    run_dir = mktempdir()
    dst_dir = joinpath(run_dir, "WrappedViz_notebook")
    _copytree(src_dir, dst_dir)
    _make_writable(dst_dir)

    dst_file = joinpath(dst_dir, "book.md")
    @assert iswritable(dst_file) "book.md non-writable après copie: $dst_file"

    println("Launching BonitoBook from: ", dst_file)
    return BonitoBook.book(dst_file)
end

# Fonction pour lancer un exemple de notebook
function book_example()
    path = joinpath(pkgdir(@__MODULE__), "src", "notebook", "exemple_book.md") |> normpath
    println("Wrapped Viz loading", path)
    return BonitoBook.book(path)
end

end # module