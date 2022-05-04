
module GliderFiles

using Downloads, Glob, DataFrames, NCDatasets

function check_for_file_Spray(args...)
    if !isempty(args)
        url1="http://spraydata.ucsd.edu/media/data/binnednc/"*basename(args[1])
        pth0=dirname(args[1])
        isempty(pth0) ? pth1=joinpath(tempdir(),"tmp_glider_data") : pth1=pth0
        !isdir(pth1) ? mkdir(pth1) : nothing
        fil1=joinpath(pth1,basename(args[1]))
        !isfile(fil1) ? Downloads.download(url1,fil1) : nothing
    else
        pth0=joinpath(tempdir(),"tmp_glider_data")
        glob("*.nc",pth0)
    end
end

"""
    GliderFiles.read(file::String)

Read a Spray Glider file.    
"""
function read(file::String)
    ds=Dataset(file)
    
	df=DataFrame(:lon => ds[:lon][:], :lat => ds[:lat][:], :ID => ds[:trajectory_index][:])
	df.time=ds[:time][:]

	df.T10=ds[:temperature][:,1]
	df.T100=ds[:temperature][:,10]
	df.T500=ds[:temperature][:,50]

	df.S10=ds[:salinity][:,1]
	df.S100=ds[:salinity][:,10]
	df.S500=ds[:salinity][:,50]

	df.u100=ds[:u][:,10]
	df.v100=ds[:v][:,10]

	df.u=ds[:u_depth_mean][:]
	df.v=ds[:v_depth_mean][:]
	
	df
end

end #module GliderFiles

##

module NOAA

using Downloads, CSV, DataFrames, Dates

"""
    NOAA.download(MC::ModelConfig)

Download files listed in `MC.inputs["stations"]` from `ndbc.noaa.gov` to `pathof(MC)`.
"""
function download(MC)
    url0="https://www.ndbc.noaa.gov/data/realtime2/"
    pth0=pathof(MC)

    for f in MC.inputs["stations"]
        fil="$f.txt"
        url1=url0*fil
        fil1=joinpath(pth0,fil)
        Downloads.download(url1,fil1)
    end
    
    return MC
end

"""
    NOAA.read(MC,sta)

Read station `sta` file from `pathof(MC)`. Meta-data is provided in `NOAA.units` and `NOAA.descriptions`.
"""
function read(MC,sta)
    pth0=pathof(MC)
        
    fil1=joinpath(pth0,"$sta.txt")

    x=DataFrame(CSV.File(fil1,skipto=3,
    missingstring="MM",delim=' ',header=1,ignorerepeated=true))
    rename!(x, Symbol("#YY") => :YY, :Column2 => :MM)

    #time
    nt=size(x,1)	
    x.time=[DateTime(x.YY[t],x.MM[t],x.DD[t],x.hh[t],x.mm[t]) for t in 1:nt]
    dt=x.time.-minimum(x.time)
    x.dt=[dt[i].value for i in 1:nt]/1000/86400;

    #sort by time
    sort!(x,:time)

    return x
end

tmp1=split("YY  MM DD hh mm WDIR WSPD GST  WVHT   DPD   APD MWD   PRES  ATMP  WTMP  DEWP  VIS PTDY  TIDE")
tmp2=split("yr  mo dy hr mn degT m/s  m/s     m   sec   sec degT   hPa  degC  degC  degC  nmi  hPa    ft")
units=Dict(tmp1[i] => tmp2[i] for i = 1:length(tmp1))

descriptions=Dict(
"WDIR"=>"Wind direction (the direction the wind is coming from in degrees clockwise from true N) during the same period used for WSPD. See Wind Averaging Methods",
"WSPD"=>"Wind speed (m/s) averaged over an eight-minute period for buoys and a two-minute period for land stations. Reported Hourly. See Wind Averaging Methods.",
"GST"=>"Peak 5 or 8 second gust speed (m/s) measured during the eight-minute or two-minute period. The 5 or 8 second period can be determined by payload, See the Sensor Reporting, Sampling, and Accuracy section.",
"WVHT"=>"Significant wave height (meters) is calculated as the average of the highest one-third of all of the wave heights during the 20-minute sampling period. See the Wave Measurements section.",
"DPD"=>"Dominant wave period (seconds) is the period with the maximum wave energy. See the Wave Measurements section.",
"APD"=>"Average wave period (seconds) of all waves during the 20-minute period. See the Wave Measurements section.",
"MWD"=>"The direction from which the waves at the dominant period (DPD) are coming. The units are degrees from true North, increasing clockwise, with North as 0 (zero) degrees and East as 90 degrees. See the Wave Measurements section.",
"PRES"=>"Sea level pressure (hPa). For C-MAN sites and Great Lakes buoys, the recorded pressure is reduced to sea level using the method described in NWS Technical Procedures Bulletin 291 (11/14/80). ( labeled BAR in Historical files)",
"ATMP"=>"Air temperature (Celsius). For sensor heights on buoys, see Hull Descriptions. For sensor heights at C-MAN stations, see C-MAN Sensor Locations",
"WTMP"=>"Sea surface temperature (Celsius). For buoys the depth is referenced to the hull's waterline. For fixed platforms it varies with tide, but is referenced to, or near Mean Lower Low Water (MLLW).",
"DEWP"=>"Dewpoint temperature taken at the same height as the air temperature measurement.",
"VIS"=>"Station visibility (nautical miles). Note that buoy stations are limited to reports from 0 to 1.6 nmi.",
"PTDY"=>"Pressure Tendency is the direction (plus or minus) and the amount of pressure change (hPa)for a three hour period ending at the time of observation. (not in Historical files)",
"TIDE"=>"The water level in feet above or below Mean Lower Low Water (MLLW).",
)

end #module NOAA

##

module GDP

using DataFrames, FTPClient, NCDatasets

"""
    list_files()

Get list of drifter files from NOAA ftp server or the corresponding webpage.

- <ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
- <https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/>s
"""
function list_files()
    list_files=DataFrame("folder" => [],"filename" => [])
    ftp=FTP("ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/")
    tmp=readdir(ftp)
    append!(list_files,DataFrame("folder" => "","filename" => tmp))
    list_files
end

# 6-hourly interpolated data product if available via thredds server
# https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:AOML-GDP
# url="https://www.ncei.noaa.gov/thredds-ocean/fileServer/aoml/gdp/1982/drifter_7702192.nc"

"""
    download(list_files,ii=1)

Download one drifter file from NOAA ftp server.

<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>

```
list_files=GDP.list_files()
fil=GDP.download(list_files,1)
```
"""
function download(list_files,ii=1)
    url0="ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/"
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
    read(filename::String)

Open file from NOAA ftp server using `NCDatasets.Dataset`.

<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
or the corresponding webpage 

```
list_files=GDP.list_files()
fil=GDP.download(list_files,1)
ds=GDP.read(fil)
```
"""
read(filename::String) = Dataset(filename)

end #module GDP

##

module ArgoFiles

using NCDatasets, Downloads

"""
    ArgoFiles.download(files_list,wmo)

Download an Argo profiler file.    
"""
function download(files_list,wmo)
    ii=findall(files_list.wmo.==wmo)[1]
    folder=files_list.folder[ii]

    url0="https://data-argo.ifremer.fr/dac/$(folder)/"
    fil=joinpath(tempdir(),"$(wmo)_prof.nc")

    !isfile(fil) ? Downloads.download(url0*"/$(wmo)/$(wmo)_prof.nc",fil) : nothing

    return fil
end

"""
    ArgoFiles.read(fil)

Read an Argo profiler file.    
"""
function read(fil)
    ds=Dataset(fil)

	lon=ds["LONGITUDE"][:]
	lat=ds["LATITUDE"][:]

	lon360=lon; lon[findall(lon.<0)].+=360
	maximum(lon)-minimum(lon)>maximum(lon360)-minimum(lon360) ? lon=lon360 : nothing

	PRES=ds["PRES_ADJUSTED"][:,:]
	TEMP=ds["TEMP_ADJUSTED"][:,:]
	PSAL=ds["PSAL_ADJUSTED"][:,:]
	TIME=10*ones(size(PRES,1)).* (1:length(lon))' .-10.0

    close(ds)

    return (lon=lon,lat=lat,PRES=PRES,TEMP=TEMP,PSAL=PSAL,TIME=TIME)
end

end

##

module OceanSites

using NCDatasets, FTPClient, CSV, DataFrames, Dates

"""
    read_WHOTS(fil)

Read an WHOTS file.    

```
file="DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc"
data,units=OceanSites.read_WHOTS(file)
```
"""
function read_WHOTS(file="DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc")
    url0="http://tds0.ifremer.fr/thredds/dodsC/CORIOLIS-OCEANSITES-GDAC-OBS/"
    fil0=url0*file*"#fillmismatch"

    ds=NCDataset(fil0)
    TIME = ds["TIME"][:,:]; uTIME=ds["TIME"].attrib["units"]
    AIRT = ds["AIRT"][:,:]; uAIRT=ds["AIRT"].attrib["units"]
    TEMP = ds["TEMP"][:,:]; uTEMP=ds["TEMP"].attrib["units"]
    PSAL = ds["PSAL"][:,:]; uPSAL=ds["PSAL"].attrib["units"]
    RAIN = ds["RAIN"][:,:]; uRAIN=ds["RAIN"].attrib["units"]
    RELH = ds["RELH"][:,:]; uRELH=ds["RELH"].attrib["units"]
    wspeed = sqrt.(ds["UWND"][:,:].^2+ds["VWND"][:,:].^2); uwspeed=ds["UWND"].attrib["units"]
    close(ds)

    data=(TIME=TIME,AIRT=AIRT,TEMP=TEMP,PSAL=PSAL,RAIN=RAIN,RELH=RELH,wspeed=wspeed)
    units=(TIME=uTIME,AIRT=uAIRT,TEMP=uTEMP,PSAL=uPSAL,RAIN=uRAIN,RELH=uRELH,wspeed=uwspeed)

    return data,units
end

"""
    index()

Download, read and process the `oceansites_index.txt` file. Return a DataFrame.

```
oceansites_index=OceanSites.index()
```
"""
function index()
    url="ftp://ftp.ifremer.fr/ifremer/oceansites/"
    fil=joinpath(tempdir(),"oceansites_index.txt")
    ftp=FTP(url)
    !isfile(fil) ? FTPClient.download(ftp, "oceansites_index.txt",fil) : nothing

    #main table
    oceansites_index=DataFrame(CSV.File(fil; header=false, skipto=9))

    #treat lines which seem mis-formatted
    aa=findall((ismissing).(oceansites_index.Column17))
    oceansites_index=oceansites_index[aa,:]

    test=sum([sum((!ismissing).(oceansites_index[:,i])) for i in 17:22])
    test>0 ? error("unclear lines remain") : oceansites_index=oceansites_index[!,1:16]

    #column names
    tmp=readlines(fil)[7]
    list=split(tmp,',')
    list=[split(list[i])[1] for i in 1:length(list)]
    list[1]="FILE"

    #rename column
    rename!(oceansites_index,list)

    return oceansites_index
end

function ncread(f::String,v::String)
    Dataset(f,"r") do ds
        ds[v][:]
    end
end

"""
    read(file,args...)

Open file from opendap server.

```
#oceansites_index=OceanSites.index()
#file=oceansites_index[1,:FILE]

file="DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc"
OceanSites.read(file,:lon,:lat,:time,:TEMP)
"""
function read(file,args...)
    url0="http://tds0.ifremer.fr/thredds/dodsC/CORIOLIS-OCEANSITES-GDAC-OBS/"
    fil0=url0*file*"#fillmismatch"
    store=[]
    for a in args
        if a==:lon
            push!(store,Float64.(ncread(fil0,"LONGITUDE")))
        elseif a==:lat
            push!(store,Float64.(ncread(fil0,"LATITUDE")))
        elseif a==:time
            push!(store,DateTime.(ncread(fil0,"TIME")))
        else
            push!(store,ncread(fil0,string(a)))
        end
    end
    
    #Dataset(fil0)
    #store
    (; zip(args, store)...)
end

end