module OceanRobots

include("thredds_servers.jl")
include("files.jl")

function check_for_file(set::String,args...)
    if set=="Glider_Spray"
        GliderFiles.check_for_file_Spray(args...)
    else
        println("unknown set")
    end
end

export GDP, NOAA, GliderFiles, ArgoFiles, OceanSites, OceanOPS
export check_for_file, THREDDS

end # module
