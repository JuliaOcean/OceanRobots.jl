# User Interface (API)

Each type of ocean data gets :

- a simple `read` function that downloads data if needed.
- a default `plot` function that depicts some of the data.

```@example ex1
using MeshArrays, Shapefile, DataDeps
pol=MeshArrays.Dataset("countries_shp1")
GC.gc() #hide
nothing #hide
```

## Supported Datasets

- OceanOPS data base (`OceanOPS.jl`)
- Surface Drifters (`Drifter_GDP.jl` , `Drifter_CloudDrift.jl`)
- Argo Profilers (`Float_Argo.jl`)
- Ship-Based CTD (`ShipCruise_CCHDO.jl`)
- Ship-Based XBT (`XBT_transect.jl`)
- NOAA Buoys (`Buoy_NWP_NOAA.jl` , `Buoy_NWP_NOAA_monthly.jl`)
- Spray Gliders (`Glider_Spray.jl`)
- WHOTS Mooring (`Mooring_WHOTS.jl`)

### Surface Drifters

```@example ex1
using OceanRobots, CairoMakie
drifter=read(SurfaceDrifter(),1)
plot(drifter,pol=pol)
```

### Argo Profilers

```@example ex1
using OceanRobots, CairoMakie
argo=read(ArgoFloat(),wmo=2900668)
#plot(argo,pol=pol)
plot(argo)
```

### Ship-Based CTD

```@example ex1
using OceanRobots, CairoMakie
cruise=read(ShipCruise(),"33RR20160208")
plot(cruise,variable="salinity",colorrange=(33.5,35.0))
```

### Ship-Based XBT

```@example ex1
using OceanRobots, CairoMakie
#xbt=read(XBTtransect(),source="SIO",transect="PX05",cruise="0910")
xbt=read(XBTtransect(),source="AOML",transect="AX08",cr=1)
fig=plot(xbt,pol=pol)
```

### NOAA Buoys

```@example ex1
using OceanRobots, CairoMakie
buoy=read(NOAAbuoy(),41044)
plot(buoy,["PRES","ATMP","WTMP"],size=(900,600))
```

```@example ex1
using OceanRobots, CairoMakie
buoy=read(NOAAbuoy_monthly(),44013)
plot(buoy)
```

### WHOTS Mooring

```@example ex1
using OceanRobots
whots=read(OceanSite(),:WHOTS)

using CairoMakie, Dates
date1=DateTime(2005,1,1)
date2=DateTime(2005,2,1)
plot(whots,date1,date2)
```

### Spray Gliders

```@example ex1
using OceanRobots, CairoMakie
gliders=read(Gliders(),"GulfStream.nc")
plot(gliders,1,pol=pol)
```

## `read` methods

```@docs
read
```

## `plot` methods

```@docs
plot
```

## `query` method

```@docs
OceanRobots.query
```

```@example ex1
using OceanRobots
OceanRobots.query(XBTtransect,"AOML")
```

## Add-Ons

!!! note
    To put data in context, it is useful to download gridded data sets.

```@example ex1
using Climatology, CairoMakie, NCDatasets
SLA=read(SeaLevelAnomaly(name="sla_podaac"))
plot(SLA)
```

