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

lst=("example_NWP_NOAA.jl","example_WHOTS.jl","example_GDP.jl")
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
