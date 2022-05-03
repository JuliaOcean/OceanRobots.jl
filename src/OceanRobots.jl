module OceanRobots

include("thredds_servers.jl")
include("files.jl")

function check_for_file(set::String,args...)
    if set=="Spray_Glider"
        Spray_Glider.check_for_file_Spray_Glider(args...)
    else
        println("unknown set")
    end
end

export GDP, NOAA, Spray_Glider, ArgoFiles, WHOTS
export check_for_file, THREDDS

end # module
