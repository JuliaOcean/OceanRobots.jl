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
using ArgoData, Printf
include("DownloadArgo.jl")

fil="task_argo.yml"
meta=DownloadArgo.mitprof_interp_setup(fil)

# +
d=meta["dirIn"]
b=meta["subset"]["basin"]
y=meta["subset"]["year"]

list0=Array{Array,1}(undef,12)
for m=1:12
    sd="$b"*"_ocean/$y/"*Printf.@sprintf("%02d/",m)
    tmp=readdir(d*sd)
    list0[m]=[sd*tmp[i] for i=1:length(tmp)]
end

nf=sum(length.(list0))
list1=Array{String,1}(undef,nf)
f=0
for m=1:12
    for ff=1:length(list0[m])
        f+=1
        list1[f]=list0[m][ff]
    end
end

meta["fileInList"]=list1;

# +
z_std=meta["z"]
if length(z_std)>1
    tmp1=(z_std[2:end]+z_std[1:end-1])/2
    z_top=[z_std[1]-(z_std[2]-z_std[1])/2;tmp1]
    z_bot=[tmp1;z_std[end]+(z_std[end]-z_std[end-1])/2]
else
    z_top=0.9*z_std
    z_bot=1.1*z_std
end

meta["z_std"]=z_std
meta["z_top"]=z_top
meta["z_bot"]=z_bot

# +
meta["inclZ"] = false
meta["inclT"] = true
meta["inclS"] = true
meta["inclU"] = false
meta["inclV"] = false
meta["inclPTR"] = false
meta["inclSSH"] = false
meta["TPOTfromTINSITU"] = 1

meta["doInterp"] = 1
meta["addGrid"] = 1
meta["outputMore"] = 0
meta["method"] = "interp"
meta["fillval"] = -9999.0
meta["buffer_size"] = 10000
# -


