module OceanRobots

using NCDatasets, Dates, CFTime, CSV, DataFrames, MAT, FTPClient

include("read_data.jl")
export drifters_hourly_mat
export drifters_hourly_files, drifters_hourly_download, drifters_hourly_read

end # module
