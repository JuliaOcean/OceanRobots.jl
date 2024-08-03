# User Interface (API)

Each type of ocean data gets :

- a simple `read` function that downloads data if needed. 
- a default `plot` function that depicts some of the data.

## Surface Drifters

```@example
using OceanRobots, CairoMakie
drifter=read(SurfaceDrifter(),1)
plot(drifter,size=(900,600))
```

## Argo Profilers

```@example
using OceanRobots, ArgoData, CairoMakie
argo=read(ArgoFloat(),wmo=2900668)
plot(argo,size=(900,600))
```

## NOAA Buoys

```@example
using OceanRobots, CairoMakie
buoy=read(NOAAbuoy(),41046)
plot(buoy,"PRES",size=(900,600))
```

```@example
using OceanRobots, CairoMakie
buoy=read(NOAAbuoy_monthly(),44013)
plot(buoy;option=:demo,size=(900,600))
```

## WHOTS Mooring

```@example
using OceanRobots, CairoMakie, Dates
whots=read(OceanSite(),:WHOTS)
plot(whots,DateTime(2005,1,1),DateTime(2005,2,1),size=(900,600))
```

## Spray Gliders

```@example
using OceanRobots, CairoMakie
gliders=read(Gliders(),"GulfStream.nc")
plot(gliders,1,size=(900,600))
```

## Sea Level Anomaly

```@example
using OceanRobots, CairoMakie
sla=read(SeaLevelAnomaly(),:sla_podaac)
plot(sla)
```

## read

```@docs
read
```

## plot

```@docs
plot
```
