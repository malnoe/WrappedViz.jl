module WrappedViz

export book, book_example, bp_monthly_tracks, bp_daily_tracks, windrose_hourly_tracks, bbplot_artists, bbplot_tracks,txt_temps_ecoute, bonito_text, data_cleaning

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

function _assert_can_write(p::AbstractString)
    open(p, "a") do io
        write(io, "\n")  # append pour tester l'écriture
    end
end

function book()
    src_dir  = joinpath(pkgdir(@__MODULE__), "src", "notebook")
    src_file = joinpath(src_dir, "book.md")
    @assert isfile(src_file) "book.md introuvable: $src_file"

    workroot = joinpath(homedir(), ".wrappedviz", "runs")
    mkpath(workroot)

    run_dir = mktempdir(workroot)
    dst_dir = joinpath(run_dir, "notebook")
    _copytree_rewrite(src_dir, dst_dir)

    dst_file = joinpath(dst_dir, "book.md")
    _assert_can_write(dst_file)

    println("Launching BonitoBook from: ", dst_file)
    Bonito.use_compression!(false)
    Bonito.force_connection!(Bonito.DualWebsocket)
    return BonitoBook.book(dst_file)
end

# Fonction pour lancer un exemple de notebook
function book_example()
    path = joinpath(pkgdir(@__MODULE__), "src", "notebook", "exemple_book.md") |> normpath
    println("Wrapped Viz loading", path)
    return BonitoBook.book(path)
end

end # module