using Documenter, ArgoData

makedocs(;
    modules=[ArgoData],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/gaelforget/ArgoData.jl/blob/{commit}{path}#L{line}",
    sitename="ArgoData.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
)

deploydocs(;
    repo="github.com/gaelforget/ArgoData.jl",
)
