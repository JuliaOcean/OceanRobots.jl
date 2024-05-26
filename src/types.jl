
using DataFrames, NCDatasets

abstract type AbstractOceanRobotData <: Any end

struct NOAAbuoy <: AbstractOceanRobotData
    ID::Int64
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

ArgoFloat() = ArgoFloat(0,DataFrame())

struct SurfaceDrifter <: AbstractOceanRobotData
    ID::Int64
    data::Union{Array,Dataset}
    wmo::Int64
    list_files::DataFrame
end

SurfaceDrifter() = SurfaceDrifter(0,[],0,DataFrame())
