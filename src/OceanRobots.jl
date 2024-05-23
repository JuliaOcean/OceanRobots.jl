module OceanRobots

using Dates
export DateTime, Date

include("thredds_servers.jl")
include("files.jl")
include("gridded_data.jl")

function check_for_file(set::String,args...)
    if set=="Glider_Spray"
        GliderFiles.check_for_file_Spray(args...)
    else
        println("unknown set")
    end
end

export GDP, GDP_CloudDrift, NOAA, GliderFiles, ArgoFiles, OceanSites, OceanOPS
export check_for_file, THREDDS, cmems_sla, podaac_sla

end # module
