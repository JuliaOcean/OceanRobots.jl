
using DataFrames

abstract type AbstractOceanRobotData <: Any end

struct NOAAbuoy <: AbstractOceanRobotData
ID::Int64
data::DataFrame
units::Dict
descriptions::Dict
end

NOAAbuoy() = NOAAbuoy(0,DataFrame(),Dict(),Dict())

