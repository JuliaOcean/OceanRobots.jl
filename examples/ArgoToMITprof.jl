# -*- coding: utf-8 -*-
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

fil="ArgoToMITprof.yml"
meta=DownloadArgo.mitprof_interp_setup(fil)
greylist=DataFrame(CSV.File(meta["dirIn"]*"../ar_greylist.txt"));
# -

f=1
println(meta["dirIn"]*meta["fileInList"][f])
argo_data=Dataset(meta["dirIn"]*meta["fileInList"][f])
haskey(argo_data.dim,"N_PROF") ? np=argo_data.dim["N_PROF"] : np=NaN

m=1
prof=DownloadArgo.GetOneProfile(argo_data,m)

k=findall((!ismissing).(prof["T"]))[200]
prof["p"][k]-401.799987792968724

# +
#using Plots
#scatter(prof["S"],prof["T"])

# + {"cell_style": "split"}
#scatter(prof["T"],-prof["p"])

# + {"cell_style": "split"}
#scatter(prof["S"],-prof["p"])
# + {}
lonlatISbad=false
(prof["lat"]<-90.0)|(prof["lat"]>90.0) ? lonlatISbad=true : nothing
(prof["lon"]<-180.0)|(prof["lon"]>360.0) ? lonlatISbad=true : nothing

#if needed then reset lon,lat after issuing a warning
lonlatISbad==true ? println("warning: out of range lon/lat was reset to 0.0,-89.99") : nothing 
lonlatISbad ? (prof["lon"],prof["lat"])=(0.0,-89.99) : nothing

#if needed then fix longitude range to 0-360
(~lonlatISbad)&(prof["lon"]>180.0) ? prof["lon"]-=360.0 : nothing


# +
function prof_PtoZ!(prof,meta)
    l=prof["lat"]
    v=meta["var_out"][1]
    prof[v]=similar(prof["p"],Union{Missing,Float64})
    prof[v].=missing
    k=findall((!ismissing).(prof["p"]))
    prof[v][k]=[DownloadArgo.sw_dpth(Float64(prof["p"][kk]),Float64(l)) for kk in k]
end

#if needed then convert pressure to depth
(~meta["inclZ"])&(~lonlatISbad) ? prof_PtoZ!(prof,meta) : nothing

#println(prof["T"][200]-13.85900020599365177)
prof[meta["var_out"][1]][200]-398.625084513574966

# +
function prof_TtoΘ!(prof,meta)
    T=prof[meta["var_out"][2]]
    P=0.981*1.027*prof[meta["var_out"][1]]
    S=35.0*ones(size(T))
    k=findall( (!ismissing).(T) )
    T[k]=[DownloadArgo.sw_ptmp(Float64(S[kk]),Float64(T[kk]),Float64(P[kk])) for kk in k]
end
    
meta["TPOTfromTINSITU"] ? prof_TtoΘ!(prof,meta) : nothing
        
println(prof["T"][200]-13.80094224720384374)
# -


