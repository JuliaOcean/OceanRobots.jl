using Documenter, OceanRobots, PlutoSliderServer, CairoMakie, ArgoData

ENV["DATADEPS_ALWAYS_ACCEPT"]=true
OceanRobotsMakieExt=Base.get_extension(OceanRobots, :OceanRobotsMakieExt)
OceanRobotsArgoDataExt=Base.get_extension(OceanRobots, :OceanRobotsArgoDataExt)
##

makedocs(;
    modules=[OceanRobots, OceanRobotsMakieExt,OceanRobotsArgoDataExt],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Notebooks" => "examples.md",
        "Reference" => "reference.md",
        "Visuals" => "visuals.md",
        ],
    repo="https://github.com/JuliaOcean/OceanRobots.jl/blob/{commit}{path}#L{line}",
    sitename="OceanRobots.jl",
    authors="JuliaOcean <gforget@mit.edu>",
    warnonly = [:cross_references,:missing_docs],
    )

GliderFiles.check_for_file_Spray("GulfStream.nc")
GliderFiles.check_for_file_Spray("CUGN_along.nc")

lst=("SatelliteAltimetry.jl","Buoy_NWP_NOAA_monthly.jl","Glider_Spray.jl","OceanOPS.jl",
    "Buoy_NWP_NOAA.jl","Mooring_WHOTS.jl","Drifter_GDP.jl","Float_Argo.jl")
for i in lst
    fil_in=joinpath(@__DIR__,"..","examples",i)
    fil_out=joinpath(@__DIR__,"build","examples",i[1:end-2]*"html")
    PlutoSliderServer.export_notebook(fil_in)
    mv(fil_in[1:end-2]*"html",fil_out)
    cp(fil_in,fil_out[1:end-4]*"jl")
end

for fil in ["argo_synthetic-profile_index.txt", "ar_index_global_prof.txt"]
    ArgoFiles.scan_txt(fil,do_write=true)
    fil_in=joinpath(tempdir(),fil[1:end-4]*".csv")
    fil_out=joinpath(@__DIR__,"build", fil[1:end-4]*".csv")
    mv(fil_in,fil_out)
end

deploydocs(;
    repo="github.com/JuliaOcean/OceanRobots.jl",
)
