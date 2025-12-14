# WrappedViz : Analyse de vos données Spotify
```julia (editor=true, logging=false, output=false)
print("Hello World from WrappedViz!")
```

```julia (editor=true, logging=false, output=false)
using WrappedViz,Makie, WGLMakie, Gtk, JSON3, DataFrames, Dates, VegaLite, GLMakie, Bonito
df = data_cleaning()
```
# Temps d'écoute

## 0. Temps total d'écoute

```julia (editor=true, logging=false, output=true)
txt_temps_ecoute(df)
```
## 1. Répartition sur les mois

```julia (editor=true, logging=false, output=true)
bp_monthly_tracks(df)
```
## 2. Répartition sur les jours de la semaine

```julia (editor=true, logging=false, output=true)
bp_daily_tracks(df)
```
## 3. Répartition sur les heures de la journée

```julia (editor=true, logging=false, output=true)
windrose_hourly_tracks(df)
```
# Statistiques sur les titres

```julia (editor=true, logging=false, output=true)
bbplot_tracks(df)
```
# Statistiques sur les artistes

```julia (editor=true, logging=false, output=true)
bbplot_artists(df)
```
