
"""
This modification to e.g. "gdp_v2.00.nc" adds the missing `sample_dimension` attribute. 
Doing this is needed to used `NCDataset.loadragged` (or it's modified version below).
"""
function add_attribute_rowsize(file="gdp_v2.00.nc")
    ds = NCDataset(file,"a")
    ds["rowsize"].attrib["sample_dimension"] = "obs"
    close(ds)
end
        
"""
This modified version of loadragged has been submitted as a PR to `NCDatasets.jl`.

```
ds=Dataset("gdp_v2.00.nc");
sst=ds["sst"]
sst=loadragged(ds["sst"],:);
latitude=loadragged(ds["latitude"],:);
```
"""
function loadragged(ncvar,index::Union{Colon,UnitRange})
    ds = NCDataset(ncvar)

    dimensionnames = dimnames(ncvar)
    if length(dimensionnames) !== 1
        throw(NetCDFError(-1, "NetCDF variable $(name(ncvar)) should have only one dimensions"))
    end
    dimname = dimensionnames[1]

    ncvarsizes = varbyattrib(ds,sample_dimension = dimname)
    if length(ncvarsizes) !== 1
        throw(NetCDFError(-1, "There should be exactly one NetCDF variable with the attribute 'sample_dimension' equal to '$(dimname)'"))
    end

    ncvarsize = ncvarsizes[1]

    isa(index,Colon)||(index[1]==1) ? n0=1 : n0=1+sum(ncvarsize[1:index[1]-1])
    isa(index,Colon) ? n1=sum(ncvarsize[:]) : n1=sum(ncvarsize[1:index[end]])
    
    varsize = ncvarsize.var[index]

    istart = 0;
    tmp = ncvar[n0:n1]
    #(n0,n1)

    T = typeof(view(tmp,1:varsize[1]))
    data = Vector{T}(undef,length(varsize))

    for i = 1:length(varsize)
        data[i] = view(tmp,istart+1:istart+varsize[i]);
        istart += varsize[i]
    end
    return data
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
    drifters_hourly_read(filename::String)

Download one drifter file from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v1.04/netcdf/>

```
list_files=drifters_hourly_files()
fil=drifters_hourly_download(list_files,1)
ds=drifters_hourly_read(fil)
```
"""
drifters_hourly_read(filename::String) = Dataset(filename)

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
 