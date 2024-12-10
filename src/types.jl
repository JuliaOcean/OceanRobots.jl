
using DataFrames, NCDatasets

abstract type AbstractOceanRobotData <: Any end

struct NOAAbuoy <: AbstractOceanRobotData
    ID::Union{Int64,String}
    data::DataFrame
    units::Dict
    descriptions::Dict
end

NOAAbuoy() = NOAAbuoy(0,DataFrame(),NOAA.units,NOAA.descriptions)
NOAAbuoy(ID,df) = NOAAbuoy(ID,df,NOAA.units,NOAA.descriptions)

struct NOAAbuoy_monthly <: AbstractOceanRobotData
    ID::Int64
    data::DataFrame
    units::Dict
    descriptions::Dict
end

NOAAbuoy_monthly() = NOAAbuoy_monthly(0,DataFrame(),NOAA.units,NOAA.descriptions)
NOAAbuoy_monthly(ID,gdf) = NOAAbuoy_monthly(ID,gdf,NOAA.units,NOAA.descriptions)

##

struct ArgoFloat <: AbstractOceanRobotData
    ID::Int64
    data::NamedTuple
end

ArgoFloat() = ArgoFloat(0,NamedTuple())

struct SurfaceDrifter <: AbstractOceanRobotData
    ID::Int64
    data::Union{Array,Dataset}
    wmo::Int64
    list_files::DataFrame
end

SurfaceDrifter() = SurfaceDrifter(0,[],0,DataFrame())

struct CloudDrift <: AbstractOceanRobotData
    file::String
    data::NamedTuple
end

CloudDrift() = CloudDrift("",NamedTuple())

struct Gliders <: AbstractOceanRobotData
    file::String
    data::DataFrame
end

Gliders() = Gliders("",DataFrame())

struct OceanSite <: AbstractOceanRobotData
    ID::Symbol
    data::NamedTuple
    units::NamedTuple
end

OceanSite() = OceanSite(:unknown,NamedTuple(),NamedTuple())

struct ShipCruise <: AbstractOceanRobotData
    ID::String
    data::Union{Array,Dataset}
    path::String
end

ShipCruise()=ShipCruise("unknown",[],tempdir())

struct XBTtransect <: AbstractOceanRobotData
    source::String
    ID::String
    data::Union{Array,Dataset}
    path::String
end

XBTtransect()=XBTtransect("unknown","unknown",[],tempdir())


"""
    query(x::DataType)

Get list of observing platforms.

```
using OceanRobots
OceanRobots.query(ShipCruise)
```

#not treated yet : Gliders, CloudDrift
"""
function query(x::DataType,args...;kwargs...)
    if x==ShipCruise
        table=CCHDO.extract_json_table()
        [t.expocode for t in table]
    elseif x==NOAAbuoy
        NOAA.list_stations()
    elseif x==SurfaceDrifter
        list=GDP.list_files()
        list.ID
    elseif x==XBTtransect
        XBT.list_transects(args...;kwargs...)
    elseif x==ArgoFloat
        list=ArgoData.GDAC.files_list()
        list.wmo
    elseif x==OceanSite
        OceanSites.index()
    else
        warning("unknown data type")
    end
end
