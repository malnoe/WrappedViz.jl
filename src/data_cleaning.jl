import Gtk, JSON3, DataFrames, Dates

using Gtk, JSON3, DataFrames, Dates

function data_cleaning()
    # Dialogue sélection du fichier    
    printstyled("Hey 👋 Quelle données Spotify veux-tu regarder aujourd'hui ?", bold=true, color=:magenta)
    file_path = open_dialog("Sélectionnez un fichier Spotify (JSON)")
    file_path === nothing && error("Aucun fichier sélectionné.")
    printstyled("Fichier sélectionné : $file_path", color=:blue)

    # Lecture fichier
    txt = read(file_path, String)
    txt = strip(txt)

    # Parse JSON
    data = JSON3.read(txt)
    # Conversion en dataframe
    rows = [Dict{Symbol,Any}(Symbol(k) => v for (k, v) in pairs(obj)) for obj in data]
    df = DataFrame(rows)

    # Séparation de la date et de l'heure
    df.date_time_parsed = DateTime.(df.ts, dateformat"yyyy-mm-ddTHH:MM:SSZ")
    df.date = Date.(df.date_time_parsed)
    df.time = Time.(df.date_time_parsed)

    # Sélection des colonnes d'intérêt et renommage
    df = select(df,
        :master_metadata_track_name => :track_name,
        :master_metadata_album_album_name => :album,
        :master_metadata_album_artist_name => :artist,
        :date, :time,
        :ms_played => :duration_ms,
        :skipped, :reason_end, :shuffle
    )

    # Retour du dataframe nettoyé (utilisabe pour analyse ultérieure)
    return df
end