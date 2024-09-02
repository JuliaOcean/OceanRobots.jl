
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

struct SeaLevelAnomaly <: AbstractOceanRobotData
    ID::Symbol
    data::Union{Array,Dataset}
    file::String
end

SeaLevelAnomaly() = SeaLevelAnomaly(:unknown,[],"")

Base.@kwdef struct OceanExpedition <: AbstractOceanRobotData
    ID::String
    data::Union{Array,Dataset}
    list_files::DataFrame
end

OceanExpedition(ID::String)=begin
    path=CCHDO.download(ID)
    filenames=joinpath.(Ref(path),readdir(path))
    list1=DataFrames.DataFrame(:filename=>filenames)
    OceanExpedition(ID,[],list1)
end
