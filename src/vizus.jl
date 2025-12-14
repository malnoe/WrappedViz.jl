import DataFrames, Dates, Makie, WGLMakie, GLMakie
using DataFrames, Dates, Makie, WGLMakie, GLMakie


# Barplot des temps d'écoute mensuelles
function bp_monthly_tracks(df::DataFrame)
    # Récupération du mois correspondant
    df.month = month.(df.date)
    # Fréquence d'écoute par mois
    df_freq = combine(
        groupby(df, :month),
        nrow => :nb_titles,  # Nombre de titres écoutés
        :ms_played => (x -> sum(x) ./ 60000) => :freq  # Durée totale en minutes
    )
    # Ajoute des mois vides
    months = DataFrame(month = 1:12)
    df_freq = leftjoin(months, df_freq, on = :month)
    df_freq.freq .= coalesce.(df_freq.freq, 0)
    df_freq.nb_titles .= coalesce.(df_freq.nb_titles, 0)
    # Correspondance mois
    month_labels = [
        "Janvier", "Février", "Mars", "Avril", "Mai", "Juin", 
        "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ]
    # Tri des donées
    df_data = sort(df_freq, :month)
    months_str = month_labels[df_data.month]
    freq = df_data.freq
    # Meilleur mois
    best_month_idx = findmax(freq)[2]
    printstyled(
        "Tu as fait fort en $(months_str[best_month_idx]) avec $(round(freq[best_month_idx], digits=2)) minutes d'écoute ! 🤯",
        bold = true, color = :magenta
    )
    # Figure
    fig = Figure(size=(1000, 450))
    ax = Axis(
        fig[1, 1],
        xticks = (1:12, months_str),
        xlabel = "Mois",
        ylabel = "Durée d'écoute (minutes)"
    )
    barplot!(ax, 1:12, freq, color = "#2a2781")
    fig
end


# Barplot des temps d'écoute journaliers (jours de la semaine)
function bp_daily_tracks(df::DataFrame)
    # Récupération du jour correspondant
    df.dayofweek = dayofweek.(df.date)
    # Fréquence d'écoute par mois
    df_freq = combine(
        groupby(df, :dayofweek),
        nrow => :nb_titles,  # Nombre de titres écoutés
        :ms_played => (x -> sum(x) ./ (60000 .* 52)) => :freq  # Durée totale moyenne en minutes
    )
    # Conversion en nombre de titre moyens
    df_freq.nb_titles = round.(df_freq.nb_titles ./ 52)
    # Ajoute des jours vides
    days = DataFrame(dayofweek = 1:7)
    df_freq = leftjoin(days, df_freq, on = :dayofweek)
    df_freq.freq .= coalesce.(df_freq.freq, 0)
    df_freq.nb_titles .= coalesce.(df_freq.nb_titles, 0)
    # correspondance jour de la semaine
    day_labels = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
    # Tri des données
    df_data = sort(df_freq, :dayofweek)
    days_str = day_labels[df_data.dayofweek]
    freq = df_data.freq
    # Meilleur jour
    best_day_idx = findmax(freq)[2]
    printstyled(
        "$(days_str[best_day_idx]) est ton jour musical de la semaine : tu écoutes en moyenne $(round(freq[best_day_idx], digits=2)) \nminutes de musique ! 🤯",
        bold = true, color = :magenta
    )
    # Figure
    fig = Figure(size=(800, 450))
    ax = Axis(
        fig[1, 1],
        xticks = (1:7, days_str),
        xlabel = "Jour de la semaine",
        ylabel = "Durée d'écoute moyenne (minutes)"
    )
    barplot!(ax, 1:7, freq, color = "#2a2781")
    fig
end


# Rose des vents des écoutes (heures de la journée)
function windrose_hourly_tracks(df::DataFrame; close_polygon::Bool=true, rmax=nothing)
    # Tranche horaire de chaque écoute
    df.hour = hour.(df.time)
    # Fréquence d'écoute par heure
    df_freq = combine(
        groupby(df, :hour),
        nrow => :nb_titles,  # Nombre de titres écoutés
        :ms_played => (x -> round.(sum(x) ./ (60000 .* 52), digits = 2)) => :freq  # Durée totale moyenne en minutes
    )
    # Conversion en nombre de titre moyens par heures
    df_freq.nb_titles = round.(df_freq.nb_titles ./ 52)
    # Ajout des heurs creuses
    hours = DataFrame(hour = 0:23)
    df_freq = leftjoin(hours, df_freq, on = :hour)
    df_freq.nb_titles .= coalesce.(df_freq.nb_titles, 0)
    df_freq.freq .= coalesce.(df_freq.freq, 0)
    # Tri des données
    df_data = sort(df_freq, :hour, rev=true)
    labels = string.(df_data[!, :hour])
    # Meilleur heure
    best_hour_idx = findmax(df_data.freq)[2]
    printstyled(
        "Waouh ! $(df_data[best_hour_idx, :hour])h est vraiment ton heure d'écoute ! 🔥",
        bold = true, color = :magenta
    )
    # Réglages de la figure
    r = Float64.(df_data[!, :freq])
    n = length(r)
    # Angles (n points) + rotation pour avoir 0 en haut
    rotation = π/2 + π/12
    θ = collect(range(0, 2π; length=n+1))[1:end-1] .+ rotation
    # Fermer le polygone
    if close_polygon
        θ = vcat(θ, θ[1])
        r = vcat(r, r[1])
    end
    rmax_val = isnothing(rmax) ? maximum(r) : rmax
    # Figure
    fig = Figure(size=(700, 600))
    ax = Axis(fig[1, 1], aspect=DataAspect())
    hidedecorations!(ax); hidespines!(ax)
    ### grille radiale (5 cercles) avec dégradé de couleurs
    rrs = range(0, rmax_val; length=6)[2:end]
    for rr in rrs
        tt = range(0, 2π; length=400)
        lines!(
            ax, rr .* cos.(tt), rr .* sin.(tt),
            color = rr,  colormap = :YlOrRd, colorrange = (0, rmax_val),
            linewidth = 1.5
        )
    end
    ### Rayons
    for t in (collect(range(0, 2π; length=n+1))[1:end-1] .+ rotation)
        lines!(ax, [0, rmax_val*cos(t)], [0, rmax_val*sin(t)],
        color=:black, linestyle=:dot
        )
    end
    ### Polygone
    x = r .* cos.(θ)
    y = r .* sin.(θ)
    poly!(ax, Point2f.(x, y), strokewidth=2, color=("#2a2781", 0.8), strokecolor="#2a2781")
    # scatter!(ax, x, y, marker=:star4, color="#2a2781")
    ### labels
    θlab = (collect(range(0, 2π; length=n+1))[1:end-1] .+ rotation)
    for (i, t) in enumerate(θlab)
        tx = 1.08 * rmax_val * cos(t)
        ty = 1.08 * rmax_val * sin(t)
        text!(ax, labels[i], position=Point2f(tx, ty), align=(:center, :center))
    end
    fig
end


# Bubbleplot top 10 artistes
function bbplot_artists(df::DataFrame)
    # Phrases d'intro
    printstyled(
        "Tu as écouté $(length(df.artist)) artistes, dont $(length(unique(df.artist))) différents. Impréssionnant ! \nMais certains t'ont marqué plus que d'autres, regarde 👇", 
        bold=true, color=:magenta
    )
    # Nombre d'écoutes par artistes
    df_counts = combine(groupby(df, :artist), nrow => :listening_counts)
    # Trier par ordre décroissant
    sort!(df_counts, :listening_counts, rev=true)
    # Top 10 artistes les plus écoutés
    top10 = df_counts[1:10, :]
    # Données graphiques
    ### Positions des bulles (fixes dans [0;4]x[0;4])
    top10.x = [0.5, 1.5, 2.5, 3.5, 1.0, 2.0, 3.0, 0.5, 2.5, 3.5]
    top10.y = [3.5, 3.0, 3.5, 3.0, 1.5, 1.0, 1.5, 0.5, 0.5, 1.0]
    positions = Point2f.(top10.x, top10.y)
    ### Taille des bulles
    bb_sizes = top10.listening_counts / findmax(top10.listening_counts)[1]
    ### Couleur et noms des bulles
    bb_colors = rand(10)
    bb_labels = top10.artist  # Textes à afficher
    bb_labels = coalesce.(top10.artist, "")
    # Bubble plot
    fig = Figure(size = (800, 600))
    ax = Axis(
        fig[1, 1],
        title = "Top 10 artistes", xlabel = "", ylabel = ""
    )
    xlims!(ax, 0, 4)
    ylims!(ax, 0, 4)
    scatter!(
        ax, positions;
        markersize = bb_sizes, markerspace = :data,
        color = bb_colors, colormap = :viridis,
        strokewidth = 0.8, strokecolor = :black
    )
    text!(
        ax, positions;
        text = bb_labels,
        font = "bold", fontsize = 12, color = :black,
        align = (:center, :center)
    )
    fig
end


# Bubbleplot top 10 musiques
function bbplot_tracks(df::DataFrame)
    # Phrases d'intro
    printstyled(
        "Tu as écouté $(length(df.track_name)) titres, dont $(length(unique(df.track_name))) différents. Impréssionnant ! \nMais certains t'ont marqué plus que d'autres, regarde 👇", 
        bold=true, color=:magenta
    )
    # Nombre d'écoutes par titres
    df_counts = combine(groupby(df, :track_name), nrow => :listening_counts)
    # Trier par ordre décroissant
    sort!(df_counts, :listening_counts, rev=true)
    # Top 10 titres les plus écoutés
    top10 = df_counts[1:10, :]
    # Données graphiques
    ### Positions des bulles (fixes dans [0;4]x[0;4])
    top10.x = [0.5, 1.5, 2.5, 3.5, 1.0, 2.0, 3.0, 0.5, 2.5, 3.5]
    top10.y = [3.5, 3.0, 3.5, 3.0, 1.5, 1.0, 1.5, 0.5, 0.5, 1.0]
    positions = Point2f.(top10.x, top10.y)
    ### Taille des bulles
    bb_sizes = top10.listening_counts / findmax(top10.listening_counts)[1]
    ### Couleur et noms des bulles
    bb_colors = rand(10)
    bb_labels = top10.track_name  # Textes à afficher
    bb_labels = coalesce.(top10.track_name, "")
    # Figure
    fig = Figure(size = (700, 700))
    ax = Axis(
        fig[1, 1],
        title = "Top 10 titres", xlabel = "", ylabel = ""
    )
    xlims!(ax, 0, 4)
    ylims!(ax, 0, 4)
    scatter!(
        ax, positions;
        markersize = bb_sizes, markerspace = :data,
        color = bb_colors, colormap = :viridis,
        strokewidth = 0.8, strokecolor = :black
    )
    text!(
        ax, positions;
        text = bb_labels,
        font = "bold", fontsize = 12, color = :black,
        align = (:center, :center)
    )
    fig
end