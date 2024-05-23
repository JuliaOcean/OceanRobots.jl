
module GliderFiles

using Downloads, Glob, DataFrames, NCDatasets

function check_for_file_Spray(args...)
    if !isempty(args)
        if args[1]=="CUGN_along.nc"
          url0="http://spraydata.ucsd.edu/erddap/files/binnedCUGNalong/"
        elseif args[1]=="GulfStream.nc"
          url0="http://spraydata.ucsd.edu/erddap/files/binnedGS/"
        else
          error("unknown file")
        end
        url1=url0*basename(args[1])
        pth0=dirname(args[1])
        isempty(pth0) ? pth1=joinpath(tempdir(),"tmp_glider_data") : pth1=pth0
        !isdir(pth1) ? mkdir(pth1) : nothing
        fil1=joinpath(pth1,basename(args[1]))
        !isfile(fil1) ? Downloads.download(url1,fil1) : fil1
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

using Downloads, CSV, DataFrames, Dates, NCDatasets, Statistics

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

"""
    NOAA.read_historical_monthly(ID,years)

Read files from https://www.ndbc.noaa.gov to temporary folder for chosen float `ID` and year `y`.
"""
function read_historical_monthly(ID=44013,years=1985:1986)
    mdf=DataFrame(  YY=Int[],MM=Int[],ATMP=Float64[],
                    WTMP=Float64[],WSPD=Float64[],PRES=Float64[])
    for y in years
        y==years[1] ? println(string(y)*" ...") : nothing
        y==years[end] ? println("... "*string(y)) : nothing
		
        df=read_historical_nc(ID,y)

        gdf=groupby(df,"MM")
        df2=combine(gdf) do df
            try
                (ATMP=mean(skipmissing(df.ATMP)) , WTMP=mean(skipmissing(df.WTMP)) , 
                WSPD=mean(skipmissing(df.WSPD)) , PRES=mean(skipmissing(df.PRES)))
            catch
                (ATMP=NaN , WTMP=NaN , WSPD=NaN , PRES=NaN)
            end    
        end
        df2.YY=fill(y,length(df2.MM))

        append!(mdf,df2)
    end

    sort!(mdf, [:YY, :MM])
    return mdf
end

"""
    NOAA.read_historical_nc(ID,year)

Read files from https://www.ndbc.noaa.gov to temporary folder for chosen float `ID` and year `y`.
"""
function read_historical_nc(ID,y)
    url0="https://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/"
    ds=Dataset(url0*"$(ID)/$(ID)h$(y).nc")
    
    df=DataFrame(YY=year.(ds["time"][:]),MM=month.(ds["time"][:]),
    air_temperature=ds["air_temperature"][1,1,:],
    sea_surface_temperature=ds["sea_surface_temperature"][1,1,:],    
    wind_spd=ds["wind_spd"][1,1,:],air_pressure=ds["air_pressure"][1,1,:])

    close(ds)

    rename!( df,Dict("air_temperature" => "ATMP","sea_surface_temperature" => "WTMP",
    "air_pressure" => "PRES", "wind_spd" => "WSPD") )

    df
end

"""
    NOAA.download_historical_txt(ID,years)

Download files from https://www.ndbc.noaa.gov to temporary folder for chosen float `ID` and `years`.
"""
function download_historical_txt(ID,years)
    for y in years
        fil0="$(ID)h$(y).txt"
        url0="https://www.ndbc.noaa.gov/view_text_file.php?filename=$(fil0).gz&dir=data/historical/stdmet/"
        pth0=joinpath(tempdir(),"NDBC"); !isdir(pth0) ? mkdir(pth0) : nothing
        fil1=joinpath(pth0,fil0)
        !isfile(fil1) ? Downloads.download(url0,fil1) : nothing
    end
end

"""
    NOAA.read_historical_txt(ID,y)

Read files from https://www.ndbc.noaa.gov to temporary folder for chosen float `ID` and year `y`.
"""
function read_historical_txt(ID,y)
    fil1=joinpath(tempdir(),"NDBC","$(ID)h$(y).txt")
    if y<2007
        df=CSV.read(fil1,DataFrame,header=1,delim=" ",
            ignorerepeated=true,missingstring=["99.0", "999.0", "9999.0", "99", "999"])
        rename!(df,"BAR" => "PRES")
    else
        df=CSV.read(fil1,DataFrame,header=1,skipto=3,delim=" ",
            ignorerepeated=true,missingstring=["99.0", "999.0", "9999.0", "99", "999"])
    end
    df
end

end #module NOAA

##

module GDP

using DataFrames, FTPClient, NCDatasets

"""
    list_files()

Get list of drifter files from NOAA ftp server or the corresponding webpage.

- <ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
- <https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/>
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

read_v(ds,v) = Float64.(cfvariable(ds,v,missing_value=-1.e+34))

end #module GDP

##

module ArgoFiles

using NCDatasets, Downloads, CSV, DataFrames

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

skmi(x) = ( sum((!ismissing).(x))>0 ? minimum(skipmissing(x)) : missing )
skma(x) = ( sum((!ismissing).(x))>0 ? maximum(skipmissing(x)) : missing )

"""
    ArgoFiles.scan_txt(fil="ar_index_global_prof.txt"; do_write=false)

Scan the Argo file lists and return summary tables in DataFrame format. 
Write to csv file if `istrue(do_write)`.

```
ArgoFiles.scan_txt("ar_index_global_prof.txt",do_write=true)
ArgoFiles.scan_txt("argo_synthetic-profile_index.txt",do_write=true)
```
"""
function scan_txt(fil="ar_index_global_prof.txt"; do_write=false)
    if fil=="ar_index_global_prof.txt"
        filename=joinpath(tempdir(),"ar_index_global_prof.txt")
        url="https://data-argo.ifremer.fr/ar_index_global_prof.txt"
        outputfile=joinpath(tempdir(),"ar_index_global_prof.csv")
    elseif fil=="argo_synthetic-profile_index.txt"
        filename=joinpath(tempdir(),"argo_synthetic-profile_index.txt")
        url="https://data-argo.ifremer.fr/argo_synthetic-profile_index.txt"
        outputfile=joinpath(tempdir(),"argo_synthetic-profile_index.csv")
    else
        error("unknown file")
    end

    !isfile(filename) ? Downloads.download(url,filename) : nothing

    df=DataFrame(CSV.File(filename; header=9))
    n=length(df.file)
    df.wmo=[parse(Int,split(df.file[i],"/")[2]) for i in 1:n]
    sum(occursin.(names(df),"parameters"))==0 ? df.parameters=fill("CTD",n) : nothing

    gdf=groupby(df,:wmo)

    prof=combine(gdf) do df
        (minlon=skmi(df.longitude) , maxlon=skma(df.longitude) ,
        minlat=skmi(df.latitude) , maxlat=skma(df.latitude) ,
        mintim=skmi(df.date) , maxtim=skma(df.date), 
        nprof=length(df.date) , parameters=df.parameters[1])
    end

    do_write ? CSV.write(outputfile, prof) : nothing

    return prof
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
    url0="https://tds0.ifremer.fr/thredds/dodsC/CORIOLIS-OCEANSITES-GDAC-OBS/"
    fil0=url0*file*"#fillmismatch"

    ds=NCDataset(fil0)
    TIME = ds["TIME"][:]; uTIME=ds["TIME"].attrib["units"]
    AIRT = ds["AIRT"][:]; uAIRT=ds["AIRT"].attrib["units"]
    TEMP = ds["TEMP"][:]; uTEMP=ds["TEMP"].attrib["units"]
    PSAL = ds["PSAL"][:]; uPSAL=ds["PSAL"].attrib["units"]
    RAIN = ds["RAIN"][:]; uRAIN=ds["RAIN"].attrib["units"]
    RELH = ds["RELH"][:]; uRELH=ds["RELH"].attrib["units"]
    wspeed = sqrt.(ds["UWND"][:].^2+ds["VWND"][:].^2); uwspeed=ds["UWND"].attrib["units"]
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
file="DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc"
OceanSites.read(file,:lon,:lat,:time,:TEMP)
```
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

module OceanOPS

using Downloads, CSV, DataFrames, JSON3, HTTP

"""
    csv_listings()

List csv files available on the https://www.ocean-ops.org/share/ server.
"""
function csv_listings()
    list_argo=("argo_operational.csv","argo_plans.csv","argo_all.csv","argo_inactive.csv",
    "euro_argo_operational.csv","euro_argo_plans.csv","euro_argo_all.csv")    
    list_dbcp=("dbcp_operational.csv","dbcp_all.csv")    
    list_OceanGliders=("oceangliders_all.csv",)
    list_OceanOPS=("oceanops_eulerian_all.csv",)    
    list_OceanSITES=("oceansites_locations.kmz",)
    list_SOT=("sot_notclosed.csv","sot_all.csv")

    return (Argo=list_argo,DBCP=list_dbcp,OceanGliders=list_OceanGliders,
        OceanOPS=list_OceanOPS,OceanSITES=list_OceanSITES,SOT=list_SOT)
end

status_url(s::Symbol)="https://www.ocean-ops.org/share/"*string(s)*"/Status/"  

"""
    get_table(s::Symbol,i=1)

Read the `csv_listings()[s][i]` table. Download file if needed. 

```
using OceanRobots
tab_Argo=OceanOPS.get_table(:Argo,1)
```    
"""
function get_table(s::Symbol,i=1)
    url0=status_url(s)
    file0=csv_listings()[s][i]
    path0=joinpath(tempdir(),"oceanops-tmp")
    path1=joinpath(path0,file0)
    url1=url0*file0

    !isdir(path0) ? mkdir(path0) : nothing
    !isfile(path1) ? Downloads.download(url1,path1) : nothing

    CSV.read(path1, DataFrame)
end

"""
    get_list(nam=:Argo; status="OPERATIONAL")

Get list of platform IDs from OceanOPS API.

For more information see 

- https://www.ocean-ops.org/api/1/help/
- https://www.ocean-ops.org/api/1/help/?param=platformstatus

```
list_Argo1=OceanOPS.get_list(:Argo,status="OPERATIONAL")
list_Argo2=OceanOPS.get_list(:Argo,status="CONFIRMED")
list_Argo3=OceanOPS.get_list(:Argo,status="REGISTERED")
list_Argo4=OceanOPS.get_list(:Argo,status="INACTIVE")
```
"""
function get_list(nam=:Argo; status="OPERATIONAL")
    url,_=get_url(nam; status=status)
    tmp=JSON3.read(String(HTTP.get(url).body))
    [i.id for i in tmp.data]
end

"""
    get_list_pos(nam=:Argo; status="OPERATIONAL")

Get list of platform positions from OceanOPS API.

For more information see 

- https://www.ocean-ops.org/api/1/help/
- https://www.ocean-ops.org/api/1/help/?param=platformstatus
"""
function get_list_pos(nam=:Argo; status="OPERATIONAL")
    _,url=get_url(nam; status=status)
    tmp=JSON3.read(String(HTTP.get(url).body))
    lon=Float64[]
    lat=Float64[]
    flag=Symbol[]
    for i in tmp.data
        if !isnothing(i.latestObs)
            push!(lon,i.latestObs.lon)
            push!(lat,i.latestObs.lat)
            push!(flag,:latestObs)
        elseif !isnothing(i.ptfDepl.lon) && !isnothing(i.ptfDepl.lat)
            push!(lon,i.ptfDepl.lon)
            push!(lat,i.ptfDepl.lat)
            push!(flag,:ptfDepl)
        else
            push!(lon,NaN)
            push!(lat,NaN)
            push!(flag,:NaN)
        end
    end
    (lon=lon,lat=lat,flag=flag)
end

"""
    get_url(nam=:Argo; status="OPERATIONAL")

API/GET URL to OceanOPS API that will list platforms of chosen type.

Two URLs are reported; the second includes platform positions.

For more information see 

- https://www.ocean-ops.org/api/1/help/
- https://www.ocean-ops.org/api/1/help/?param=platformstatus
- https://www.ocean-ops.org/api/1/help/?param=platformtype
"""
function get_url(nam=:Argo; status="OPERATIONAL")
    if nam==:Argo
        url="https://www.ocean-ops.org/api/1/data/platform/"*
            "?exp=[%22ptfStatus.name=%27$(status)%27%20and%20networkPtfs.network.name=%27Argo%27%22]"
    elseif nam==:Drifter
        url="https://www.ocean-ops.org/api/1/data/platform/"*
            "?exp=[%22ptfStatus.name=%27$(status)%27%20and%20networkPtfs.network.nameShort=%27DBCP%27%20and%20ptfModel.ptfType.ptfFamily.name%20=%20%27Drifting%20Buoy%27%22]"
    else
        url="https://www.ocean-ops.org/api/1/data/platform/"*
#        "?exp=[%22ptfStatus.name=%27$(status)%27%20and%20ptfModel.ptfType.ptfFamily.name%20=%20%27Drifting%20Buoy%27%22]"
#        "?exp=[%22ptfStatus.name=%27$(status)%27%20and%20ptfModel.ptfType.ptfFamily.name%20=%20%27Animal%20Borne%20Sensor%27%22]"
#        "?exp=[%22ptfStatus.name=%27$(status)%27%20and%20ptfModel.ptfType.name%20=%20%27Sailing%20Drone%27%22]"
        "?exp=[%22ptfStatus.name=%27$(status)%27%20and%20ptfModel.ptfType.nameShort%20=%20%27"*string(nam)*"%27%22]"
#        "?exp=[%22ptfModel.ptfType.nameShort%20=%20%27"*string(nam)*"%27%22]"
#        "?exp=[%22%20ptfModel.ptfType.name%20=%20%27SVP%27%22]"
    end

    return url,url*"&include=[%22ptfDepl.lon%22,%22ptfDepl.lat%22,%22ptfDepl.deplDate%22,"*
        "%22latestObs.lon%22,%22latestObs.lat%22,%22latestObs.obsDate%22,"*
        "%22id%22,%22ref%22,%22ptfStatus.name%22]"
end

"""
    get_platform(i)

Get info on platform with `id=i` (e.g., float or drifter) from OceanOPS API.

For more information see https://www.ocean-ops.org/api/1/help/

```
list_Drifter=OceanOPS.get_list(:Drifter)
tmp=OceanOPS.get_platform(list_Drifter[1000])
```
"""
function get_platform(i)
    url="https://www.ocean-ops.org/api/1/data/platform/$(i)"*
        "?include=[%22ptfDepl.ship.name%22,%20%22ref%22,%20%22program.country.name%22,"*
        "%20%22ptfDepl.deplDate%22,%20%22ptfStatus.name%22]"
    tmp=JSON3.read(String(HTTP.get(url).body))
    #
    (id=tmp.data[1].ref,
    country=tmp.data[1].program.country.name,
    status=tmp.data[1].ptfStatus.name,
    deployed=tmp.data[1].ptfDepl.deplDate,
    ship=tmp.data[1].ptfDepl.ship.name,
    )
end

"""
    list_platform_types()

List platform types.
"""
list_platform_types() = begin
    list_platform_types=DataFrame(:nameShort=>String[],:name=>String[],:description=>String[],:wigosCode=>String[],:id=>Int[])
    list_platform_types=DataFrame(:nameShort=>String[],:name=>String[],:description=>Any[],:wigosCode=>Any[],:id=>Int[])
    
    url="https://www.ocean-ops.org/api/1/data/platformtype"
    tmp=JSON3.read(String(HTTP.get(url).body))
    for i in tmp.data
        push!(list_platform_types,(nameShort=i.nameShort,name=i.name,
                    description=i.description,wigosCode=i.wigosCode,id=i.id))
    end
    list_platform_types
end

end
