module OceanRobots

using Dates, Statistics
export DateTime, Date

import Base: read

include("types.jl")
include("thredds_servers.jl")
include("files.jl")
include("files_XBT.jl")
include("example_GOM.jl")

export GDP, GDP_CloudDrift, NOAA, GliderFiles, ArgoFiles
export OceanSites, OceanOPS, CCHDO, XBT, Glider_EGO_module
#export THREDDS
export NOAAbuoy, NOAAbuoy_monthly, ArgoFloat, SurfaceDrifter, Gliders
export OceanSite, CloudDrift, ShipCruise, XBTtransect, Glider_EGO

end # module
