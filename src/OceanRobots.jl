module OceanRobots

using Dates
export DateTime, Date

import Base: read

include("types.jl")
include("thredds_servers.jl")
include("files.jl")

export GDP, GDP_CloudDrift, NOAA, GliderFiles, ArgoFiles, OceanSites, OceanOPS, SLA, CCHDO
#export THREDDS

include("gridded_data.jl")
export cmems_sla, podaac_sla

export NOAAbuoy, NOAAbuoy_monthly, ArgoFloat, SurfaceDrifter, Gliders
export OceanSite, CloudDrift, SeaLevelAnomaly, ShipCruise

end # module
