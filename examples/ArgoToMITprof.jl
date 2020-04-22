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
# + {}
using Dierckx

T_step1=prof["T"]; D_step1=prof["depth"];

function prof_interp!(prof,meta)
    for ii=2:length(meta["var_out"])
        v=meta["var_out"][ii]
        v_e=v*"_ERR"
        
        z_std=meta["z_std"]
        t_std=similar(z_std,Union{Missing,Float64})
        e_std=similar(z_std,Union{Missing,Float64})
        
        z=prof["depth"]
        t=prof[v]
        do_e=haskey(prof,v_e)
        do_e ? e=prof[v_e] : e=[]
    
        kk=findall((!ismissing).(z.*t))
        if (meta["doInterp"])&&(length(kk)>1)
            z_in=z[kk]; t_in=t[kk]
            do_e ? e_in=e[kk] : nothing
            k=sort(1:length(kk),by= i -> z_in[i])
            z_in=z_in[k]; t_in=t_in[k]
            do_e ? e_in=e_in[k] : nothing
            #omit values outside observed range:
            D0=minimum(skipmissing(z_in))
            D1=maximum(skipmissing(z_in))
            msk1=findall( (z_std.<D0).|(z_std.>D1) )            
            #avoid duplicates:
            msk2=findall( ([false;(z_in[1:end-1]-z_in[2:end]).==0.0]).==true )
            if length(kk)>5
                spl = Spline1D(z_in, t_in)
                t_std[:] = spl(z_std)
                t_std[msk1].=missing
                t_std[msk2].=missing
                if do_e
                    spl = Spline1D(z_in, e_in)
                    e_std[:] = spl(z_std)
                    e_std[msk1].=missing
                    e_std[msk2].=missing
                end
            else
                t_std = []
                e_std = []
            end
            prof[v]=t_std
        end
    end
    return "ok"
end

prof_interp!(prof,meta)
# -


using Plots
scatter(T_step1,-D_step1)
scatter!(prof["T"],-meta["z_std"])


