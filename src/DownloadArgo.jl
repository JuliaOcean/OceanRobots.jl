module DownloadArgo

using Printf, Dates, YAML, NetCDF, NCDatasets, CSV, DataFrames

"""
    GDAC_FTP(b::String,y::Int,m::Int)

Download Argo data files for one regional domain (b), year (y), and
month (m) from the `GDAC` FTP server (ftp://ftp.ifremer.fr/ifremer/argo
or, equivalently, ftp://usgodae.org/pub/outgoing/argo).

```
b="atlantic"; yy=2009:2009; mm=8:12;
for y=yy, m=mm;
    println("\$b/\$y/\$m"); DownloadArgo.GDAC_FTP(b,y,m)
end
```
"""
function GDAC_FTP(b::String,y::Int,m::Int)
    yy = @sprintf "%04d" y
    mm = @sprintf "%02d" m
    c=`wget --quiet -r ftp://ftp.ifremer.fr/ifremer/argo/geo/"$b"_ocean/$yy/$mm`
    run(c)
end

"""
    mitprof_interp_setup(fil::String)

Get parameters etc from yaml file (`fil`).
"""
function mitprof_interp_setup(fil::String)

    meta=YAML.load(open(fil))

    #1. file list

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

    #2. coordinate

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

    #3. various other specs

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

    return meta
end

"""
    GetOneProfile(m)

Get one profile from netcdf file.
"""
function GetOneProfile(ds,m)

    #
    t=ds["JULD"][m]
    ymd=Dates.year(t)*1e4+Dates.month(t)*1e2+Dates.day(t)
    hms=Dates.hour(t)*1e4+Dates.minute(t)*1e2+Dates.second(t)

    lat=ds["LATITUDE"][m]
    lon=ds["LONGITUDE"][m]
    lon < 0.0 ? lon=lon+360.0 : nothing

    direction=ds["DIRECTION"][m]
    direc=0
    direction=='A' ? direc=1 : nothing
    direction=='D' ? direc=2 : nothing

    #
    pnum_txt=ds["PLATFORM_NUMBER"][:,m]
    ii=findall(in.(pnum_txt,"0123456789"))
    ~isempty(ii) ? pnum_txt=String(vec(Char.(pnum_txt[ii]))) : pnum_txt="9999"
    pnum=parse(Int,pnum_txt)

    #
    p=ds["PRES_ADJUSTED"][:,m]
    p_QC=ds["PRES_ADJUSTED_QC"][:,m]
    if sum((!ismissing).(p))==0
        p=ds["PRES"][:,m]
        p_QC=ds["PRES_QC"][:,m]
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

    #position and date
    isBAD=0
    ~in(ds["POSITION_QC"][m],"1258") ? isBAD=1 : nothing
    ~in(ds["JULD_QC"][m],"1258") ? isBAD=1 : nothing

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

    #temperature
    t=ds["TEMP_ADJUSTED"][:,m]
    t_QC=ds["TEMP_ADJUSTED_QC"][:,m]
    t_ERR=ds["TEMP_ADJUSTED_ERROR"][:,m]
    t_ERR[findall( (ismissing).(t_ERR) )].=0.0

    if sum((!ismissing).(t))==0
        t=ds["TEMP"][:,m]
        t_QC=ds["TEMP_QC"][:,m]
    end

    #salinity
    if haskey(ds,"PSAL")
        s=ds["PSAL_ADJUSTED"][:,m]
        s_QC=ds["PSAL_ADJUSTED_QC"][:,m]
        s_ERR=ds["PSAL_ADJUSTED_ERROR"][:,m]
        s_ERR[findall( (ismissing).(t_ERR) )].=0.0
        if sum((!ismissing).(t))==0
            s=ds["PSAL"][:,m]
            s_QC=ds["PSAL_QC"][:,m]
        end
    else
        s=fill(missing,size(t))
        s_QC=Char.(32*ones(size(t_QC)))
    end

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
    prof["DATA_MODE"]=ds["DATA_MODE"][m]

    return prof
end

end
