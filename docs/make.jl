using Documenter, OceanRobots, PlutoSliderServer, CairoMakie

println("downloading files ...")

ENV["DATADEPS_ALWAYS_ACCEPT"]=true
OceanRobotsMakieExt=Base.get_extension(OceanRobots, :OceanRobotsMakieExt)

using MeshArrays, GeoJSON, DataDeps
pol=MeshArrays.Dataset("countries_geojson1")

Glider_Spray_module.check_for_file_Spray("GulfStream.nc")
Glider_Spray_module.check_for_file_Spray("CUGN_along.nc")

GDP_CloudDrift.CloudDrift_subset_download()

##

println("calling makedocs ...")

makedocs(;
    modules=[OceanRobots, OceanRobotsMakieExt],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "User Interface" => "reference.md",
        "Notebooks" => "examples.md",
        "User Directions" => "contributing.md",
        ],
    repo="https://github.com/JuliaOcean/OceanRobots.jl/blob/{commit}{path}#L{line}",
    sitename="OceanRobots.jl",
    authors="JuliaOcean <gforget@mit.edu>",
    warnonly = [:cross_references,:missing_docs],
    )

##

println("running notebooks ...")

lst=("OceanOPS.jl","ShipCruise_CCHDO.jl",
    "CPR_notebook.jl","Roce_interop.jl","XBT_transect.jl",
    "Buoy_NWP_NOAA.jl","Buoy_NWP_NOAA_monthly.jl","Mooring_WHOTS.jl",
    "Glider_Spray.jl","Glider_EGO.jl","Glider_AOML.jl",
    "Drifter_GDP.jl","Drifter_CloudDrift.jl","Float_Argo.jl")

for i in lst
    fil_in=joinpath(@__DIR__,"..","examples",i)
    fil_out=joinpath(@__DIR__,"build","examples",i[1:end-2]*"html")
    PlutoSliderServer.export_notebook(fil_in)
    mv(fil_in[1:end-2]*"html",fil_out)
    cp(fil_in,fil_out[1:end-4]*"jl")
end

deploydocs(;
    repo="github.com/JuliaOcean/OceanRobots.jl",
)
