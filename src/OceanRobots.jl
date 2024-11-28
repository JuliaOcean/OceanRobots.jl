module OceanRobots

using Dates
export DateTime, Date

import Base: read

include("types.jl")
include("thredds_servers.jl")
include("files.jl")
include("example_GOM.jl")

export GDP, GDP_CloudDrift, NOAA, GliderFiles, ArgoFiles, OceanSites, OceanOPS, CCHDO
#export THREDDS
export NOAAbuoy, NOAAbuoy_monthly, ArgoFloat, SurfaceDrifter, Gliders
export OceanSite, CloudDrift, ShipCruise

end # module
