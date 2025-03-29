
readme_Roce=
"""
This example calls 
the [R oce](https://dankelley.github.io/oce/) package 
via [RCall.jl](https://juliainterop.github.io/RCall.jl/dev/)

```
include("OceanRobots/examples/Roce_interop.jl")
```
"""

using Pkg
Pkg.activate(temp=true)
Pkg.add("RCall")
using RCall

url1="https://dankelley.r-universe.dev"
url2="https://cloud.r-project.org"
R"install.packages('oce', repos = c($url1, $url2))"

#R"install.packages('oce', repos = c('https://dankelley.r-universe.dev', 'https://cloud.r-project.org'))"

R"remotes::install_github('dankelley/ocedata', ref='main', force=TRUE)"

R"library(oce)"

ctd1=R"ctd=read.oce(system.file('extdata', 'ctd.cnv.gz', package = 'oce'))"

x = randn(10)
R"t.test($x)"


