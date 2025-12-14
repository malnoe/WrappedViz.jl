# include("data_cleaning.jl") : pas utile ?

import Makie, WGLMakie, DataFrames, Dates, VegaLite, GLMakie
using Makie, WGLMakie, DataFrames, Dates, VegaLite, GLMakie


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
    # Barplot
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
    # plot
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
function windrose_hourly_tracks(df::DataFrame)
    # Tranche horaire de chaque écoute
    df.hour = hour.(df.time)
    # Fréquence d'écoute par heure
    df_freq = combine(
        groupby(df, :hour),
        nrow => :freq
    )
    # Dataframe heures + nombre de chansons jouées
    hours = DataFrame(hour = 0:23)
    df_freq = leftjoin(hours, df_freq, on = :hour)
    df_freq.freq .= coalesce.(df_freq.freq, 0)


function spiderplot(df_freq::DataFrame; labelcol::Symbol=:hour, valcol::Symbol=:freq,
                    close_polygon::Bool=true, rmax=nothing)

    # ordonne les valeurs
    df = sort(df_freq, labelcol, rev=true)
    labels = string.(df[!, labelcol])
    r = Float64.(df[!, valcol])

    n = length(r)

    # angles (n points) + rotation pour avoir 0 en haut
    rotation = π/2 + π/12
    θ = collect(range(0, 2π; length=n+1))[1:end-1] .+ rotation

    # fermer le polygone
    if close_polygon
        θ = vcat(θ, θ[1])
        r = vcat(r, r[1])
    end

    rmax_val = isnothing(rmax) ? maximum(r) : rmax

    fig = Figure(size=(700, 600))
    ax = Axis(fig[1, 1], aspect=DataAspect())
    hidedecorations!(ax); hidespines!(ax)

    # grille radiale (5 cercles)
    for rr in range(0, rmax_val; length=6)[2:end]
        tt = range(0, 2π; length=400)
        lines!(ax, rr .* cos.(tt), rr .* sin.(tt))
    end

    # rayons
    for t in (collect(range(0, 2π; length=n+1))[1:end-1] .+ rotation)
        lines!(ax, [0, rmax_val*cos(t)], [0, rmax_val*sin(t)])
    end

    # polygone
    x = r .* cos.(θ)
    y = r .* sin.(θ)
    poly!(ax, Point2f.(x, y), strokewidth=3)
    scatter!(ax, x, y)

    # labels
    θlab = (collect(range(0, 2π; length=n+1))[1:end-1] .+ rotation)
    for (i, t) in enumerate(θlab)
        tx = 1.08 * rmax_val * cos(t)
        ty = 1.08 * rmax_val * sin(t)
        text!(ax, labels[i], position=Point2f(tx, ty), align=(:center, :center))
    end

    fig
end


fig = spiderplot(df_freq; labelcol=:hour, valcol=:freq)
fig

end