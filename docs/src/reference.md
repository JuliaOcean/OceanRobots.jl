# User Interface (API)

Each type of ocean data gets :

- a simple `read` function that downloads data if needed.
- a default `plot` function that depicts some of the data.

# Functionalities

## read

```@docs
read
```

## plot

```@docs
plot
```

# Supported Datasets

```@setup ex1
using MeshArrays, Shapefile, DataDeps
pol_file=demo.download_polygons("ne_110m_admin_0_countries.shp")
pol=MeshArrays.read_polygons(pol_file)
nothing #hide
```

## Surface Drifters

```@example ex1
using OceanRobots, CairoMakie
drifter=read(SurfaceDrifter(),1)
plot(drifter,pol=pol)
```

## Argo Profilers

```@example ex1
using OceanRobots, ArgoData, CairoMakie
argo=read(ArgoFloat(),wmo=2900668)
plot(argo,pol=pol)
```

## CTD profiles

```@example ex1
using OceanRobots, CairoMakie
cruise=ShipCruise("33RR20160208")
plot(cruise,variable="salinity",colorrange=(33.5,35.0))
```

## NOAA Buoys

```@example ex1
using OceanRobots, CairoMakie
buoy=read(NOAAbuoy(),41046)
plot(buoy,["PRES","ATMP","WTMP"],size=(900,600))
```

```@example ex1
using OceanRobots, CairoMakie
buoy=read(NOAAbuoy_monthly(),44013)
plot(buoy;option=:demo)
```

## WHOTS Mooring

```@example ex1
using OceanRobots
whots=read(OceanSite(),:WHOTS)

using CairoMakie, Dates
date1=DateTime(2005,1,1)
date2=DateTime(2005,2,1)
plot(whots,date1,date2)
```

## Spray Gliders

```@example ex1
using OceanRobots, CairoMakie
gliders=read(Gliders(),"GulfStream.nc")
plot(gliders,1,pol=pol)
```

!!! note
    To put data in context, it is useful to download country polygons or gridded data sets.

```@example ex1
using MeshArrays, Shapefile, DataDeps
pol_file=demo.download_polygons("ne_110m_admin_0_countries.shp")
pol=MeshArrays.read_polygons(pol_file)
nothing #hide
```

```@example ex1
using Climatology, CairoMakie, NCDatasets
SLA=read(SeaLevelAnomaly(name="sla_podaac"))
plot(sla)
```

