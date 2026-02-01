
using DataFrames, NCDatasets, JSON3

abstract type AbstractOceanRobotData <: Any end

function Base.show(io::IO, z::AbstractOceanRobotData)
    zn=fieldnames(typeof(z))
    printstyled(io, " $(typeof(z)) \n",color=:normal)
    in(:ID,zn) ? printstyled(io, "  ID        = ",color=:normal) : nothing
    in(:ID,zn) ? printstyled(io, "$(z.ID)\n",color=:magenta) : nothing
    if in(:data,zn)
        printstyled(io, "  data      = ",color=:normal)
        tmp=(if isa(z.data,NamedTuple)
            keys(z.data)
        elseif isa(z.data,DataFrames.DataFrame)
            names(z.data)
            #show(z.data)
        else
            typeof.(z.data)
        end)
        printstyled(io, "$(tmp)\n",color=:magenta)
    end
    in(:file,zn) ? printstyled(io, "  file      = ",color=:normal) : nothing
    in(:file,zn) ? printstyled(io, "$(z.file)\n",color=:magenta) : nothing
    in(:source,zn) ? printstyled(io, "  source      = ",color=:normal) : nothing
    in(:source,zn) ? printstyled(io, "$(z.source)\n",color=:magenta) : nothing
    in(:format,zn) ? printstyled(io, "  format      = ",color=:normal) : nothing
    in(:format,zn) ? printstyled(io, "$(z.format)\n",color=:magenta) : nothing
    in(:units,zn) ? printstyled(io, "  units      = ",color=:normal) : nothing
    in(:units,zn) ? printstyled(io, "$(z.units)\n",color=:magenta) : nothing
    in(:path,zn) ? printstyled(io, "  path      = ",color=:normal) : nothing
    in(:path,zn) ? printstyled(io, "$(z.path)\n",color=:magenta) : nothing
    return
end  

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

##

struct Glider_Spray <: AbstractOceanRobotData
    file::String
    data::DataFrame
end

Glider_Spray() = Glider_Spray("",DataFrame())

##

struct Glider_EGO <: AbstractOceanRobotData
    ID::Union{Missing,Int64}
    data::Any #Union{NamedTuple,DataFrame}
end

Glider_EGO() = Glider_EGO(missing,NamedTuple())

##

struct Glider_AOML <: AbstractOceanRobotData
    path::String
    data::DataFrame
end

Glider_AOML() = Glider_AOML("",DataFrame())

##

struct OceanSite <: AbstractOceanRobotData
    ID::Union{Symbol,Int}
    data::Union{NamedTuple,DataFrame}
    meta::Union{NamedTuple,DataFrame}
    other::Any
end

OceanSite() = OceanSite(:unknown,NamedTuple(),NamedTuple(),missing)

##

struct ShipCruise <: AbstractOceanRobotData
    ID::String
    data::Union{Array,Dataset}
    path::String
end

ShipCruise()=ShipCruise("unknown",[],tempdir())

##

struct ObservingPlatform <: AbstractOceanRobotData
    ID::Union{Symbol,Int}
    data::Union{NamedTuple,DataFrame}
    meta::Union{NamedTuple,DataFrame}
    other::Any
end

ObservingPlatform() = ObservingPlatform(:unknown,NamedTuple(),NamedTuple(),missing)

##

struct XBTtransect <: AbstractOceanRobotData
    source::String
    format::String ##default will be ~ IMOS case (i.e. simple DataFrame )
    mission::String
    transect::String
    folder::String
    data::Union{Array,Dataset,DataFrame}
    stations::DataFrame
end

XBTtransect()=XBTtransect("unknown","unknown","unknown","unknown",
                tempdir(),DataFrame(),DataFrame())

"""
    query(x::DataType)

Get list of observing platforms.

```
using OceanRobots
OceanRobots.query(ShipCruise)
OceanRobots.query(XBTtransect,"AOML")
```

#not treated yet : Glider_Spray, CloudDrift
"""
function query(x::DataType,args...;kwargs...)
    if x==ShipCruise
        table=CCHDO.extract_json_table(format="DataFrame")
    elseif x==NOAAbuoy
        #option to get location, activity status, and a bit more metadata?
        tab_code=NOAA.list_stations()
        DataFrame("transect"=>tab_code)
    elseif x==SurfaceDrifter
        #option to query the hourly data set?
        list=GDP.list_files()
        DataFrame("ID"=>list.ID)
    elseif x==XBTtransect
        if haskey(kwargs,:transect)
            XBT.list_of_cruises(args...;kwargs...)
        else
            tmp=XBT.list_transects(args...;kwargs...)
            DataFrame("transect"=>tmp)
        end
    elseif x==ArgoFloat
        list=ArgoData.GDAC.files_list()
        #rename [folder  wmo] as [source  wmo]?
    elseif x==OceanSite
        OceanSites.index()
    elseif x==ObservingPlatform
        OceanOPS.query(;kwargs...)
    elseif x==Glider_AOML
        tab_code=Glider_AOML_module.query(;kwargs...)
        DataFrame("ID"=>tab_code)
    elseif x==Glider_Spray
        tab_code=Glider_Spray_module.query(;kwargs...)
    elseif x==Glider_EGO
        tab_code=Glider_EGO_module.query(;kwargs...)
    else
        warning("unknown data type")
    end
end
