module OceanRobots

using NCDatasets, Dates, CFTime, CSV, DataFrames, MAT
using FTPClient, Downloads, LightXML

include("read_data.jl")
include("thredds_servers.jl")

export drifters_hourly_files, drifters_hourly_download, drifters_hourly_read, drifters_hourly_mat
export Argo_float_files, Argo_float_download
export parse_thredds_catalog

end # module
