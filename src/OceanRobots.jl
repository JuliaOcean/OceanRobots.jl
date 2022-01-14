module OceanRobots

using NetCDF, Dates, CFTime, DataFrames, MAT

include("read_data.jl")
export drifters_hourly_mat

end # module
