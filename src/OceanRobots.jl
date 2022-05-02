module OceanRobots

using NCDatasets, Dates, CFTime, CSV, DataFrames, MAT
using FTPClient, Downloads, LightXML, Glob

include("thredds_servers.jl")
include("files.jl")

function check_for_file(set::String,args...)
    if set=="Spray_Glider"
        Spray_Glider.check_for_file_Spray_Glider(args...)
    else
        println("unknown set")
    end
end

export GDP, NOAA, Spray_Glider
export check_for_file, parse_thredds_catalog

end # module
