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
using ArgoData
include("DownloadArgo.jl")

fil="task_argo.yml"
meta=DownloadArgo.mitprof_interp_setup(fil);

# +
using NCDatasets

f=1
println(meta["dirIn"]*meta["fileInList"][1])
argo_data=Dataset(meta["dirIn"]*meta["fileInList"][f])
haskey(argo_data.dim,"N_PROF") ? np=argo_data.dim["N_PROF"] : np=NaN

# +
using DataFrames, CSV

greylist=DataFrame(CSV.File(meta["dirIn"]*"../ar_greylist.txt"))
greylist[1:5,:]

# +
m=1

using Dates

t=argo_data["JULD"][m]
ymd=Dates.year(t)*1e4+Dates.month(t)*1e2+Dates.day(t)
hms=Dates.hour(t)*1e4+Dates.minute(t)*1e2+Dates.second(t)

lat=argo_data["LATITUDE"][m]
lon=argo_data["LONGITUDE"][m]
lon < 0.0 ? lon=lon+360.0 : nothing

direction=argo_data["DIRECTION"][m]
direc=0
direction=='A' ? direc=1 : nothing
direction=='D' ? direc=2 : nothing
# -

pnum_txt=argo_data["PLATFORM_NUMBER"][:,m]
ii=findall(in.(pnum_txt,"0123456789"))
~isempty(ii) ? pnum_txt=String(vec(Char.(pnum_txt[ii]))) : pnum_txt="9999"
pnum=parse(Int,pnum_txt)

# +
p=argo_data["PRES_ADJUSTED"][m,:]
p_QC=argo_data["PRES_ADJUSTED_QC"][m,:]
if sum((!ismissing).(p))==0
    p=argo_data["PRES"][m,:]
    p_QC=argo_data["PRES_QC"][m,:]
end

#set qc to 5 if missing
p_QC[findall(ismissing.(p))].='5'
#avoid potential duplicates
for n=1:length(p)-1
    if ~ismissing(p[n])
        tmp1=( (!ismissing).(p[n+1:end]) ).&( p[n+1:end].==p[n] )
        tmp1=findall(tmp1)
        p[n.+tmp1].=missing
        p_QC[n.+tmp1].='5'
    end
end

#p[8]
#tmp1=findall(( (!ismissing).(p) ).&( p.==p[8] ))
#p[tmp1]

# +
#position and date
isBAD=0
~in(argo_data["POSITION_QC"][m],"1258") ? isBAD=1 : nothing
~in(argo_data["JULD_QC"][m],"1258") ? isBAD=1 : nothing

#pressure
tmp1=findall( (!in).(p_QC,"1258") )
if (length(tmp1)<=5)&&(length(tmp1)>0)
    #omit these few bad points but keep the profile
    p[tmp1].=missing
elseif length(tmp1)>5
    #flag the profile (will be omitted later)
    #but keep the bad points (for potential inspection)
    isBAD=1
end

# +
#temperature
t=argo_data["TEMP_ADJUSTED"][m,:]
t_QC=argo_data["TEMP_ADJUSTED_QC"][m,:]
t_ERR=argo_data["TEMP_ADJUSTED_ERROR"][m,:]
t_ERR[findall( (ismissing).(t_ERR) )].=0.0

if sum((!ismissing).(t))==0
    t=argo_data["TEMP"][m,:]
    t_QC=argo_data["TEMP_QC"][m,:]
end
# -

#salinity
if haskey(argo_data,"PSAL")
    s=argo_data["PSAL_ADJUSTED"][m,:]
    s_QC=argo_data["PSAL_ADJUSTED_QC"][m,:]
    s_ERR=argo_data["PSAL_ADJUSTED_ERROR"][m,:]
    s_ERR[findall( (ismissing).(t_ERR) )].=0.0
    if sum((!ismissing).(t))==0
        s=argo_data["PSAL"][m,:]
        s_QC=argo_data["PSAL_QC"][m,:]
    end
else
    s=fill(missing,size(t))
    s_QC=Char.(32*ones(size(t_QC)))
end

# +
if ismissing(t[1]) #this file does not contain temperature data...
    t=fill(missing,size(t))
    t_ERR=fill(0.0,size(t))
else #apply QC
    tmp1=findall( (!in).(t_QC,"1258") )
    t[tmp1].=missing
end

if ismissing(s[1]) #this file does not contain salinity data...
    s=fill(missing,size(s))
    s_ERR=fill(0.0,size(s))
else #apply QC
    tmp1=findall( (!in).(s_QC,"1258") )
    s[tmp1].=missing
end
# -

prof=Dict()
prof["pnum_txt"]=pnum_txt
prof["ymd"]=ymd
prof["hms"]=hms
prof["lat"]=lat
prof["lon"]=lon
prof["direc"]=direc
prof["T"]=t
prof["S"]=s
prof["p"]=p
prof["T_ERR"]=t_ERR
prof["S_ERR"]=s_ERR
prof["isBAD"]=isBAD
prof["DATA_MODE"]=argo_data["DATA_MODE"][m]

# ```    
#     profileCur.pnum_txt=pnum_txt;
#     profileCur.ymd=ymd; profileCur.hms=hms;
#     profileCur.lat=lat; profileCur.lon=lon;
#     profileCur.direc=direc;
#     profileCur.T=t;
#     profileCur.S=s;
#     profileCur.p=p;
#     profileCur.T_ERR=t_ERR;
#     profileCur.S_ERR=s_ERR;
#     profileCur.isBAD=isBAD;
#     profileCur.DATA_MODE=argo_data.DATA_MODE(m);
# ```

using Plots
scatter(prof["S"],prof["T"])


