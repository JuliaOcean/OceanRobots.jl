module OceanRobots

using Dates, Statistics
export DateTime, Date

import Base: read

include("types.jl")
include("thredds_servers.jl")
include("files.jl")
include("files_XBT.jl")
include("example_GOM.jl")

export GDP, GDP_CloudDrift, NOAA, ArgoFiles
export OceanSites, OceanOPS, CCHDO, XBT
export Glider_Spray_module, Glider_EGO_module
#export THREDDS
export NOAAbuoy, NOAAbuoy_monthly, ArgoFloat, SurfaceDrifter, Glider_Spray
export OceanSite, CloudDrift, ShipCruise, XBTtransect, Glider_EGO

end # module
