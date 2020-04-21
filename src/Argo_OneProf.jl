# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.2.4
#   kernelspec:
#     display_name: Julia 1.3.1
#     language: julia
#     name: julia-1.3
# ---

# +
using ArgoData, DataFrames, CSV, NCDatasets
include("DownloadArgo.jl")

fil="task_argo.yml"
meta=DownloadArgo.mitprof_interp_setup(fil)
greylist=DataFrame(CSV.File(meta["dirIn"]*"../ar_greylist.txt"));
# -

f=1
println(meta["dirIn"]*meta["fileInList"][f])
argo_data=Dataset(meta["dirIn"]*meta["fileInList"][f])
haskey(argo_data.dim,"N_PROF") ? np=argo_data.dim["N_PROF"] : np=NaN

m=1
prof=DownloadArgo.GetOneProfile(argo_data,m)

using Plots
scatter(prof["S"],prof["T"])

# + {"cell_style": "split"}
scatter(prof["T"],-prof["p"])

# + {"cell_style": "split"}
scatter(prof["S"],-prof["p"])
# -


