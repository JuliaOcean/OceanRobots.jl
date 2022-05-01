using Documenter, OceanRobots, PlutoSliderServer

makedocs(;
    modules=[OceanRobots],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Examples" => "examples.md",
        ],
    repo="https://github.com/gaelforget/OceanRobots.jl/blob/{commit}{path}#L{line}",
    sitename="OceanRobots.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
    )

OceanRobots.check_for_file("Spray_Glider","GulfStream.nc")
OceanRobots.check_for_file("Spray_Glider","CUGN_along.nc")

lst=("Spray_Glider.jl","Buoy_NWP_NOAA.jl","Mooring_WHOTS.jl","Drifter_GDP.jl","Float_Argo.jl")
for i in lst
    fil_in=joinpath(@__DIR__,"..", "examples",i)
    fil_out=joinpath(@__DIR__,"build", "examples",i[1:end-2]*"html")
    PlutoSliderServer.export_notebook(fil_in)
    mv(fil_in[1:end-2]*"html",fil_out)
    cp(fil_in,fil_out[1:end-4]*"jl")
end

deploydocs(;
    repo="github.com/gaelforget/OceanRobots.jl",
)
