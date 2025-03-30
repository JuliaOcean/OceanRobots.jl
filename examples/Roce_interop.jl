
readme_Roce=
"""
This example calls 
the [R oce](https://dankelley.github.io/oce/) package 
via [RCall.jl](https://juliainterop.github.io/RCall.jl/dev/)

```
include("OceanRobots/examples/Roce_interop.jl")
```
"""

if !isdefined(Main,:RCall)
    using Pkg
    Pkg.activate(temp=true)
    Pkg.add("RCall")
    using RCall
end

## basic RCall examples

let
    x = randn(10)
    R"t.test($x)"
end

## 

if !isdefined(Main,:url1)
    url1="https://dankelley.r-universe.dev"
    url2="https://cloud.r-project.org"
    R"install.packages('oce', repos = c($url1, $url2))"
    #R"install.packages('oce', repos = c('https://dankelley.r-universe.dev', 'https://cloud.r-project.org'))"
    R"remotes::install_github('dankelley/ocedata', ref='main', force=TRUE)"
    R"library(oce)"
end

ctd1=R"ctd=read.oce(system.file('extdata', 'ctd.cnv.gz', package = 'oce'))"
dep_R=R"ctd[['depth']][1:181]"

dep=rcopy(R"ctd[['depth']]")
temp=rcopy(R"ctd[['temperature']]")

## plot data

using CairoMakie

plot_temp(temp,dep) = begin
    fi=Figure(); ax=Axis(fi[1,1],yreversed=true,ylabel="depth",xlabel="degree C")
    lines!(temp,dep)
    fi
end

plot_temp(temp,dep)
