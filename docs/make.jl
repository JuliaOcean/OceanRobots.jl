using Documenter, OceanRobots

makedocs(;
    modules=[OceanRobots],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/gaelforget/OceanRobots.jl/blob/{commit}{path}#L{line}",
    sitename="OceanRobots.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
)

deploydocs(;
    repo="github.com/gaelforget/OceanRobots.jl",
)
