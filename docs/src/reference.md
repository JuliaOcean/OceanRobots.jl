# User Interface (API)

Each type of ocean data gets :

- a simple `read` function that downloads data if needed.
- a default `plot` function that depicts some of the data.

```@example ex1
using MeshArrays, GeoJSON, DataDeps
pol=MeshArrays.Dataset("countries_geojson1")
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
- Gliders (`Glider_AOML.jl`, `Glider_EGO.jl`,`Glider_Spray.jl`)
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

### Gliders

Three data sets, corresponding to different glider programs (`Spray`, `EGO`, `AOML`).

```@example ex1
using OceanRobots, CairoMakie
glider=read(Glider_Spray(),"GulfStream.nc",1)
plot(glider,pol=pol)
```

```@example ex1
glider=read(Glider_EGO(),2)
plot(glider,pol=pol)
```

```@example ex1
file=Glider_AOML_module.sample_file()
Glider_AOML_module.download_AOML(file)
glider=read(Glider_AOML(),file)
plot(glider,pol=pol,markersize=8)
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
query
```

```@example ex1
list=(  ArgoFloat, SurfaceDrifter, XBTtransect, ShipCruise,
        ObservingPlatform, OceanSite, NOAAbuoy,
        Glider_AOML, Glider_Spray, Glider_EGO )

for T in list
    println("\n"); show(T); println("\n"); show(query(T));
end
```

## Add-Ons

!!! note
    To put data in context, it is useful to download gridded data sets.

```@example ex1
using Climatology, CairoMakie, NCDatasets
SLA=read(SeaLevelAnomaly(name="sla_podaac"))
plot(SLA)
```

