
"""
Argo_float_files()

Get list of Argo float files from Ifremer GDAC server     
<ftp://ftp.ifremer.fr/ifremer/argo/dac/>
"""
function Argo_float_files()
    ftp=FTP("ftp://ftp.ifremer.fr/ifremer/argo/dac/")

    list_files=DataFrame("folder" => [],"wmo" => [])
    list_folders=readdir(ftp)

    for pth in list_folders
        cd(ftp,pth)
        tmp=readdir(ftp)
        [append!(list_files,DataFrame("folder" => pth,"wmo" => parse(Int,x))) for x in tmp]
        cd(ftp,"..")
    end
    list_files
end

"""
    Argo_float_download(list_files,ii=1,suff="prof",ftp=missing)

Download one Argo file for float ranked `ii` in `list_files` 
from GDAC server (`ftp://ftp.ifremer.fr/ifremer/argo/dac/` by default)
to a temporary folder (`joinpath(tempdir(),"Argo_DAC_files")`).

By default `suff="prof"` means we'll download the file that contains 
the profile data (e.g. `13857_prof.nc` for `ii=1` with `wmo=13857`). 
Other possible choices for `suff`: "meta", "Rtraj", "tech".

If the `ftp` argument is omitted or `isa(ftp,String)` then `Downloads.download` is used. 
If, alternatively, `isa(ftp,FTP)` then `FTPClient.download` is used.

Example :

```
using OceanRobots
list_files=Argo_float_files()
Argo_float_download(list_files,10000)
ftp="ftp://usgodae.org/pub/outgoing/argo/dac/"
Argo_float_download(list_files,10000,"meta",ftp)
```
"""
function Argo_float_download(list_files,ii,suff="prof",ftp=missing)
    path=joinpath(tempdir(),"Argo_DAC_files")
    !isdir(path) ? mkdir(path) : nothing
    folder=list_files[ii,:folder]
    wmo=list_files[ii,:wmo]
    path=joinpath(path,folder)
    !isdir(path) ? mkdir(path) : nothing
    path=joinpath(path,string(wmo))
    !isdir(path) ? mkdir(path) : nothing

    if ismissing(ftp)||isa(ftp,String)
        fil_out=joinpath(path,string(wmo)*"_"*suff*".nc")
        path_ftp="ftp://ftp.ifremer.fr/ifremer/argo/dac/"
        fil_in=path_ftp*folder*"/"*string(wmo)*"/"*string(wmo)*"_"*suff*".nc"
        Downloads.download(fil_in, fil_out)
    else
        fil_out=path*"/"*string(wmo)*"_"*suff*".nc"
        fil_in=folder*"/"*string(wmo)*"/"*string(wmo)*"_"*suff*".nc"
        FTPClient.download(ftp,fil_in, fil_out)
    end
    
    return "done"
end

"""
    drifters_hourly_files()

Get list of drifter files from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v1.04/netcdf/>
"""
function drifters_hourly_files()
    list_files=DataFrame("folder" => [],"filename" => [])
    list_folders=["gps",["argos_block$i" for i in 1:8]...]
    for pth in list_folders
        ftp=FTP("ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v1.04/netcdf/")
        cd(ftp,pth)
        tmp=readdir(ftp)
        append!(list_files,DataFrame("folder" => pth,"filename" => tmp))
        cd(ftp,"..")
    end
    list_files
end

# 6-hourly interpolated data product
# https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:AOML-GDP
# url="https://www.ncei.noaa.gov/thredds-ocean/fileServer/aoml/gdp/1982/drifter_7702192.nc"

"""
    drifters_hourly_download(list_files,ii=1)

Download one drifter file from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v1.04/netcdf/>

```
list_files=drifters_hourly_files()
fil=drifters_hourly_download(list_files,1)
```
"""
function drifters_hourly_download(list_files,ii=1)
    url0="ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v1.04/netcdf/"
    url1=joinpath(url0,list_files[ii,"folder"])
    ftp=FTP(url1)

    fil=list_files[ii,"filename"]
    
    pth=joinpath(tempdir(),"drifters_hourly_noaa")
    !isdir(pth) ? mkdir(pth) : nothing
    fil_out=joinpath(pth,fil)

    !isfile(fil_out) ? FTPClient.download(ftp, fil, fil_out) : nothing
    fil_out
end

"""
    drifters_hourly_download(list_files,ii=1)

Download one drifter file from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v1.04/netcdf/>

```
list_files=drifters_hourly_files()
fil=drifters_hourly_download(list_files,1)
ds=drifters_hourly_read(fil)
```
"""
drifters_hourly_read(filename::String)= Dataset(filename)

"""
    drifters_hourly_mat(pth,lst;chnk=Inf,rng=(-Inf,Inf))

Read near-surface [drifter data](https://doi.org/10.1002/2016JC011716) from the
[Global Drifter Program](https://doi.org/10.25921/7ntx-z961) into a DataFrame.

```
pth,lst=drifters_hourly_mat()
df=drifters_hourly_mat( pth*lst[end], rng=(2014.1,2014.2) )
```
"""
function drifters_hourly_mat(fil::String;chnk=1000,rng=(-Inf,Inf))
    fid=matopen(fil)

    t=read(fid,"TIME")
    t_u="hours since 1979-01-01 00:00:00"
    lo=read(fid,"LON")
    la=read(fid,"LAT")
 
    ##
 
    ii=findall(isfinite.(lo.*la.*t))
 
    t=t[ii]
    lo=lo[ii]
    la=la[ii]
    haskey(fid, "ID") ? ID=read(fid,"ID")[ii] : ID=read(fid,"id")[ii]
    DROGUE=read(fid,"DROGUE")[ii]
    U=read(fid,"U")[ii]
    V=read(fid,"V")[ii]
 
    ##
 
    t=timedecode(t, t_u)
    tmp=dayofyear.(t)+(hour.(t) + minute.(t)/60 ) /24
    t=year.(t)+tmp./daysinyear.(t)
    ii=findall( (t.>rng[1]).&(t.<=rng[2]).*(DROGUE.==1) )
 
    t=t[ii]
    lo=lo[ii]
    la=la[ii]
    ID=ID[ii]
    DROGUE=DROGUE[ii]
    U=U[ii]
    V=V[ii]
 
    close(fid)

    ##
 
    df = DataFrame(ID=Int[], lon=Float64[], lat=Float64[], 
                u=Float64[], v=Float64[], t=Float64[])
    !isinf(chnk) ? nn=Int(ceil(length(ii)/chnk)) : nn=1
    for jj=1:nn
       #println([jj nn])
       !isinf(chnk) ? i=(jj-1)*chnk.+(1:chnk) : i=(1:length(ii))
       i=i[findall(i.<length(ii))]
       append!(df,DataFrame(lon=lo[i], lat=la[i], t=t[i], u=U[i], v=V[i], ID=Int.(ID[i])))
    end
 
    return df
end
 
"""
    drifters_hourly_mat()

Path name and file list for near-surface [drifter data](https://doi.org/10.1002/2016JC011716)
from the [Global Drifter Program](https://doi.org/10.25921/7ntx-z961)

```
pth,lst=drifters_hourly_mat()
```
"""
function drifters_hourly_mat()
    pth=joinpath(tempdir(),"Drifter_hourly_v014")
    lst=["hourly_WMLE_1.02_block1.mat","hourly_WMLE_1.02_block2.mat",
        "hourly_WMLE_1.02_block3.mat","hourly_WMLE_1.02_block4.mat",
        "hourly_WMLE_1.02_block5.mat","hourly_WMLE_1.02_block6.mat",
        "hourly_WMLE_1.04_block7.mat","hourly_WMLE_1.04_block8.mat",
        "hourly_GPS_1.04.mat"]
    return pth,lst
 end   
 
"""
    drifters_hourly_mat(t0::Number,t1::Number)

Loop over all files and call drifters_hourly_mat with rng=(t0,t1)

```
@everywhere using OceanRobots
@distributed for y in 2005:2020
    df=drifters_hourly_mat(y+0.0,y+1.0)
    pth=joinpath(tempdir(),"Drifter_hourly_v014","csv")
    fil=joinpath("drifters_"*string(y)*".csv")
    OceanRobots.CSV.write(fil, df)
end
```
"""
function drifters_hourly_mat( t0::Number,t1::Number )
    pth,lst=drifters_hourly_mat()
    df = DataFrame(ID=Int[],lon=Float64[],lat=Float64[],
            u=Float64[],v=Float64[],t=Float64[])
    for fil in lst
       println(fil)
       append!(df,drifters_hourly_mat( pth*fil,chnk=10000,rng=(t0,t1) ))
    end
    return df
 end
 