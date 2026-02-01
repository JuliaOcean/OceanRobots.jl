module OceanRobots

using Dates, Statistics
export DateTime, Date

import Base: read

include("types.jl")
include("thredds_servers.jl")
include("files/other.jl")
include("files/XBT.jl")
include("files/gliders.jl")
include("example_GOM.jl")

export GDP, GDP_CloudDrift, NOAA, ArgoFiles
export OceanSites, OceanOPS, CCHDO, XBT
export Glider_Spray_module, Glider_EGO_module, Glider_AOML_module
#export THREDDS
export NOAAbuoy, NOAAbuoy_monthly, ArgoFloat, SurfaceDrifter
export ObservingPlatform, OceanSite, CloudDrift, ShipCruise, XBTtransect
export Glider_EGO, Glider_AOML, Glider_Spray

end # module
