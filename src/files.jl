
module Spray_Glider

using Downloads, Glob, DataFrames, NCDatasets

function check_for_file_Spray_Glider(args...)
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

function read(fil0)
    ds=Dataset(fil0)
    
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

end #module Spray_Glider

##

module NOAA

using Downloads, CSV, DataFrames, Dates

function get_NWP_NOAA(x)
    url0="https://www.ndbc.noaa.gov/data/realtime2/"
    pth0=pathof(x)

    for f in x.inputs["stations"]
        fil="$f.txt"
        url1=url0*fil
        fil1=joinpath(pth0,fil)
        Downloads.download(url1,fil1)
    end
    
    return x
end

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

Get list of drifter files from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
or the corresponding webpage 
<https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/>.
"""
function list_files()
    list_files=DataFrame("folder" => [],"filename" => [])
    ftp=FTP("ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/")
    tmp=readdir(ftp)
    append!(list_files,DataFrame("folder" => "","filename" => tmp))
    list_files
end

# 6-hourly interpolated data product
# https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:AOML-GDP
# url="https://www.ncei.noaa.gov/thredds-ocean/fileServer/aoml/gdp/1982/drifter_7702192.nc"

"""
    download(list_files,ii=1)

Download one drifter file from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
or the corresponding webpage 
<https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/>.

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

Download one drifter file from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
or the corresponding webpage 
<https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/>.

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

using NCDatasets

function download(files_list,wmo)
    ii=findall(files_list.wmo.==wmo)[1]
    folder=files_list.folder[ii]

    url0="https://data-argo.ifremer.fr/dac/$(folder)/"
    fil=joinpath(tempdir(),"$(wmo)_prof.nc")

    !isfile(fil) ? Downloads.download(url0*"/$(wmo)/$(wmo)_prof.nc",fil) : nothing

    return fil
end

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