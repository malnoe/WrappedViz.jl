# In case you want to know, why the last line of the docstring below looks like it is:
# It will show the package (local) path when help on the package is invoked like     help?> WrappedViz
# but it will interpolate to an empty string on CI server, 
# preventing appearing the server local path in the documentation built there

module WrappedViz

export book_final, book_example, txt_temps_ecoute,bp_monthly_tracks, bp_daily_tracks, windrose_hourly_tracks, bbplot_artists, bbplot_tracks, data_cleaning

include("data_cleaning.jl")
include("vizus.jl")

using BonitoBook, Makie, WGLMakie, Gtk, JSON3, DataFrames, Dates, GLMakie, Bonito, Pkg


function _copytree_rewrite(src::AbstractString, dst::AbstractString)
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
            open(srcf, "r") do io_in
                open(dstf, "w") do io_out
                    write(io_out, read(io_in))
                end
            end
        end
    end
end

# test d'écriture "réel"
function _assert_can_write(p::AbstractString)
    try
        open(p, "a") do io
            write(io, "\n")  # append
        end
    catch err
        error("Cannot write to $p\nUnderlying error: $(err)")
    end
end

# optionnel: enlever read-only via attrib (Windows)
function _windows_clear_readonly(dir::AbstractString)
    Sys.iswindows() || return
    try
        run(`cmd /c attrib -R "${dir}\*" /S /D`)
    catch
        # si attrib échoue, on continue quand même
    end
end

function book()
    src_dir  = joinpath(pkgdir(@__MODULE__), "src", "notebook")
    src_file = joinpath(src_dir, "book.md")
    @assert isfile(src_file) "book.md introuvable: $src_file"

    # ✅ Dossier de travail stable et writable
    workroot = joinpath(homedir(), ".wrappedviz", "runs")
    mkpath(workroot)

    run_dir = mktempdir(workroot)  # crée un sous-dossier unique dans workroot
    dst_dir = joinpath(run_dir, "notebook")
    _copytree_rewrite(src_dir, dst_dir)

    _windows_clear_readonly(dst_dir)

    dst_file = joinpath(dst_dir, "book.md")
    _assert_can_write(dst_file)

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