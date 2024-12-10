
module CCHDO

import Downloads, Dataverse, NCDatasets, Glob
import NCDatasets: Dataset
import DataFrames: DataFrame
import JSON3, HTTP

import Base: read
import OceanRobots: ShipCruise
import Dates: DateTime

"""
    read(x::ShipCruise, ID="unknown")

Read ShipCruise data.    
"""
read(x::ShipCruise,ID="unknown") = begin
    if ID!=="unknown"
        path=CCHDO.download(ID)
        x=ShipCruise(ID,[],path)
        list1=CCHDO.list_CTD_files(x)	
		df1=CCHDO.DataFrame("depth"=>Float64[],"time"=>DateTime[],"temperature"=>Float64[],"salinity"=>Float64[])
		for f in list1
			ds=CCHDO.NCDatasets.Dataset(f)
			tim=fill(ds["time"][1],ds.dim["pressure"])
			append!(df1,CCHDO.DataFrame("depth"=>-ds["pressure"][:],"time"=>tim,
            "temperature"=>ds["temperature"][:],"salinity"=>ds["salinity"][:]))
		end
        push!(x.data,df1)
        x
    else
        @warn "unknown cruise"
        ShipCruise()
    end
end

"""
    extract_json_table(url)

```
using JSON3, HTTP

url="https://cchdo.ucsd.edu/search?q=GO-SHIP"
url="https://cchdo.ucsd.edu/search?bbox=-75,-60,20,65" #Atlantic
url="https://cchdo.ucsd.edu/search?dtstart=1999-12-31&dtend=2000-01-31" #one month
url="https://cchdo.ucsd.edu/search?q=ARS01" # BATS
url="https://cchdo.ucsd.edu/search?q=PRS02" #HOT

table=extract_json_table(url)

ta=table[1]
xy1=ta.track.coordinates
x1=[i[1] for i in xy1]
y1=[i[2] for i in xy1]  

using GLMakie
scatter(x1,y1)
```
"""
function extract_json_table(url="https://cchdo.ucsd.edu/search?q=GO-SHIP")
  tmp=String(HTTP.get(url).body)

  x1=findall("var results =",tmp)[1]
  x2=findall("]]}}]",tmp)[1]
  y=maximum(x1)+1:maximum(x2)

  JSON3.read(tmp[y])
end


"""
    CCHDO.download(cruise::Union(Symbol,Symbol[]),path=tempdir())

Download files listed in `stations` from `cchdo.ucsd.edu/cruise/` to `path`.

```
using OceanRobots
ID="33RR20160208"
path=OceanRobots.CCHDO.download(ID)
```
"""
function download(cruise::Union{Symbol,String,Vector},path=tempdir())
    url0="https://cchdo.ucsd.edu/cruise/"
    files=String[]
    cruises=(isa(cruise,Vector) ? cruise : [cruise])
    for f in cruises
        url1=url0*string(f)*"?download=dataset"
        fil1=joinpath(path,string(f)*".zip")
        path1=joinpath(path,string(f))
        fil2=joinpath(path1,string(f)*".zip")
        list=ancillary_files(f)
        if !isdir(path1)
            println("downloading CCHDO files for cruise $(f)")
            Downloads.download(url1,fil1)
            mkdir(path1)
            mv(fil1,fil2)
            Dataverse.unzip(fil2)
            #unzip ctd files
            tmp1=readdir(path1)
            tmp2=findall(occursin.(Ref("_nc_ctd.zip"),tmp1))
            if length(tmp2)>0
                fil3=joinpath(path1,tmp1[tmp2[1]])
                Dataverse.unzip(fil3)
            end
            #download ancillary files
            for i in list
                isempty(i) ? nothing : Downloads.download(i,joinpath(path1,basename(i)))
            end
        end
        push!(files,path1)
    end
    length(files)==1 ? files[1] : files
end

#other relevant URLs:
#
#https://cchdo.ucsd.edu/search?q=chipod
#https://microstructure.ucsd.edu
#
#https://cchdo.ucsd.edu/products/
#https://doi.org/10.7942/GOSHIP-EasyOcean
#https://argovis.colorado.edu/ships


"""
    ancillary_files(cruise::Union{Symbol,String})

```
using OceanRobots
ID="33RR20230722"
list=OceanRobots.CCHDO.ancillary_files(ID)
```
"""
function ancillary_files(cruise::Union{Symbol,String})
    f=string(cruise)    
    if f=="33RR20160208"
        list=(  txt="https://cchdo.ucsd.edu/data/12413/33RR20160208_do.txt",
                sum="https://cchdo.ucsd.edu/data/34887/33RR20160208su.txt",
                chipod="https://cchdo.ucsd.edu/data/41776/I08S_nc_final.nc",
                chipod_raw="" )#https://cchdo.ucsd.edu/data/41775/I08S_chipod_raw.zip")
    elseif f=="320620170703"
        list=(  txt="https://cchdo.ucsd.edu/data/34919/320620170703su.txt",
                sum="https://cchdo.ucsd.edu/data/14267/320620170703_do.txt",
                chipod="https://cchdo.ucsd.edu/data/41749/P06_CTDchipod_final.nc",
                chipod_raw="")#https://cchdo.ucsd.edu/data/41748/P06_chipod_raw.zip")
    elseif f=="74EQ20151206"
        list=(  txt="",
                sum="https://cchdo.ucsd.edu/data/23056/74EQ20151206su.txt",
                chipod="https://cchdo.ucsd.edu/data/41792/A05_nc_final.nc",
                chipod_raw="") #https://cchdo.ucsd.edu/data/41791/A05_chipod_raw.zip")
    elseif f=="33RO20131223"
        list=(  txt="https://cchdo.ucsd.edu/data/14685/33RO20131223_do.txt",
                sum="https://cchdo.ucsd.edu/data/1844/33RO20131223su.txt",
                chipod="https://cchdo.ucsd.edu/data/41774/A16S_nc_final.nc",
                chipod_raw="") #https://cchdo.ucsd.edu/data/41773/A16S_chipod_raw.zip")
    elseif f=="33RO20150410"
        list=(  txt="https://cchdo.ucsd.edu/data/11984/33RO20150410_do.txt",
                sum="https://cchdo.ucsd.edu/data/34881/33RO20150410su.txt",
                chipod="https://cchdo.ucsd.edu/data/41784/P16N1_CTDchipod_final.nc",
                chipod_raw="") #https://cchdo.ucsd.edu/data/41783/P16N1_chipod_raw.zip")
    #others that dont have the finalize nc file yet:
    elseif f=="33RR20230722"
        list=(  txt="",
                sum="https://cchdo.ucsd.edu/data/41041/33RR20230722su.txt",
                chipod="",
                chipod_raw="https://cchdo.ucsd.edu/data/41794/I05_chipod_raw.zip")
    else
        list=(txt="",sum="",chipod="",chipod_raw="")
    end
end

open_chipod_file(x) = begin
	fil0=basename(CCHDO.ancillary_files(x.ID).chipod)
	fil1=joinpath(x.path,fil0)
	Dataset(fil1)
end

list_CTD_files(x) = Glob.glob(x.ID*"*_ctd.nc",x.path)

end

##

import ArgoData
import Base: read

"""
    read(x::ArgoFloat;wmo=2900668)

Note: the first time this method is used, it calls `ArgoData.GDAC.files_list()` 
to get the list of Argo floats from server, and save it to a temporary file.

```
using OceanRobots
read(ArgoFloat(),wmo=2900668)
```
"""
function read(x::ArgoFloat;wmo=2900668,files_list="")
    y=read(ArgoData.OneArgoFloat(),wmo=wmo,files_list=files_list)
    ArgoFloat(y.ID,y.data)
end

##

module GliderFiles

import OceanRobots: Gliders
using Downloads, Glob, DataFrames, NCDatasets
import Base: read

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
    read(x::Gliders, file::String)

Read a Spray Glider file.    
"""
read(x::Gliders, file="GulfStream.nc") = begin
    f=check_for_file_Spray(file)
    df=to_DataFrame(Dataset(f))
    Gliders(f,df)
end

function to_DataFrame(ds)
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

using Downloads, CSV, DataFrames, Dates, NCDatasets, Statistics, HTTP
import OceanRobots: NOAAbuoy, NOAAbuoy_monthly, THREDDS
import Base: read

"""
    NOAA.list_stations()

Get stations list from https://www.ndbc.noaa.gov/to_station.shtml
"""
function list_stations()
    myurl0="https://www.ndbc.noaa.gov/to_station.shtml"
    txt0=String(HTTP.get(myurl0).body)
    txt1=split(txt0,"station_page.php?station=")[2:end]
    String.([split(t,"\"")[1] for t in txt1])
end

"""
    NOAA.list_realtime(;ext=:all)

Get either files list from https://www.ndbc.noaa.gov/data/realtime2/
or list of buoy codes that provide some file type 
(e.g. "txt" for "Standard Meteorological Data")

```
lst0=NOAA.list_realtime()
lst1=NOAA.list_realtime(ext=:txt)
```
"""
function list_realtime(;ext=:all)
    myurl0="https://www.ndbc.noaa.gov/data/realtime2/"
    txt0=String(HTTP.get(myurl0).body)
    txt1=split(txt0,"<tr><td valign=\"top\"><img src=\"/icons/text.gif\"")[3:end]
    lst1=[split(split(t,"href=\"")[2],"\">")[1]  for t in txt1]
    lst2=(if ext!==:all
        extxt=String(ext)
        lst2=lst1[[split(t,".")[2]==string(ext) for t in lst1]]
        [split(t,".")[1] for t in  lst2]
    else
        lst1
    end)
    string.(lst2)
end

"""
    NOAA.download(stations::Union(Array,Int),path=tempdir())

Download files listed in `stations` from `ndbc.noaa.gov` to `path`.
"""
function download(stations::Union{Array,Int},path=tempdir())
    url0="https://www.ndbc.noaa.gov/data/realtime2/"
    files=String[]
    for f in stations
        fil="$f.txt"
        url1=url0*fil
        fil1=joinpath(path,fil)
        Downloads.download(url1,fil1)
        push!(files,fil1)
    end
    files
end

"""
    NOAA.download(sta::String,path=tempdir())

Download files for stations `sta` from `ndbc.noaa.gov` to `path`.
"""
function download(sta::Union{String,SubString},path=tempdir())
    url0="https://www.ndbc.noaa.gov/data/realtime2/"
    fil="$sta.txt"
    url1=url0*fil
    fil1=joinpath(path,fil)
    Downloads.download(url1,fil1)
    fil1
end

"""
    NOAA.download(MC::ModelConfig)

Download files listed in `MC.inputs["stations"]` from `ndbc.noaa.gov` to `pathof(MC)`.
"""
function download(MC)
    download(MC.inputs["stations"],pathof(MC))
    return MC
end

"""
    read(x::NOAAbuoy,args...)

Read a NOAA buoy file (past month).    
"""
read(x::NOAAbuoy,args...) = read_station(args...)

"""
    read(x::NOAAbuoy_monthly,args...)

Read a NOAA buoy file (historical).    
"""
read(x::NOAAbuoy_monthly,args...) = read_monthly(args...)

"""
    NOAA.read_station(station,path=tempdir())

Read station file from specified path, and add meta-data (`units` and `descriptions`).
"""
function read_station(station::Union{Int,String},path=tempdir())        
    fil1=joinpath(path,"$station.txt")
    !isfile(fil1) ? download(station,path)  : nothing

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

    return NOAAbuoy(station,x,units,descriptions)
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
    #url0="https://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/"
    url0="https://dods.ndbc.noaa.gov/thredds/fileServer/data/stdmet/"
    
    fil=joinpath(tempdir(),"$(ID)h$(y).nc")
    url=url0*"$(ID)/$(ID)h$(y).nc"
    !isfile(fil) ? Downloads.download(url,fil) : nothing

    ds=Dataset(fil)    
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

function summary_table(z,ny=25;var="T(°F)")
    if var=="T(°F)"
        T=round.(z.WTMP * 1.8 .+32,digits=1)
    else
        T=buoy.data[:,var]
    end
    p=[(T[z.YY.==y],T[z.YY.==y+ny]) for y in 1984:2001]
    i=findall([length(pp[1])*length(pp[2])==1 for pp in p])
    T0=[p[ii][1][1] for ii in i]
    T1=[p[ii][2][1] for ii in i]
    i=findall((!isnan).(T0.*T1))
    DataFrame(T0 = T0[i], T1 = T1[i])
end

read_monthly(ID=44013,years=[])=begin
    Y = (isempty(years) ? THREDDS.parse_catalog_NOAA_buoy(ID)[1] : years)
    isa(Y,UnitRange) ? Y=collect(Y) : nothing
    isa(Y,Int) ? Y=[Y] : nothing
    isa(Y[1],UnitRange) ? Y=collect(Y[1]) : nothing
    mdf=read_historical_monthly(ID,Y)
    NOAAbuoy_monthly(ID,mdf,NOAA.units,NOAA.descriptions)
end

end #module NOAA

##

module GDP

using DataFrames, NCDatasets, Dates, CSV
import OceanRobots: SurfaceDrifter
import Base: read
import Downloads, FTPClient

"""
    list_files()

Get list of drifter files from NOAA ftp server or the corresponding webpage.

- <ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
- <https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/>
"""
function list_files()
    td=string(Dates.today())
    fil=joinpath(tempdir(),"GDP_list_$(td).csv")
    if isfile(fil)
        list_files=CSV.read(fil,DataFrame)
    else
        list_files=DataFrame("folder" => [],"filename" => [])
        ftp=FTPClient.FTP("ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/")
        tmp=readdir(ftp)
        append!(list_files,DataFrame("folder" => "","filename" => tmp))
        list_files.ID=[parse(Int,split(f,"_")[2][1:end-3]) for f in list_files.filename]
        CSV.write(fil,list_files)
        list_files
    end
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
    pth0=list_files[ii,"folder"]
    url1=(ismissing(pth0) ? url0 : joinpath(url0,pth0))
    ftp=FTPClient.FTP(url1)

    fil=list_files[ii,"filename"]
    
    pth=joinpath(tempdir(),"drifters_hourly_noaa")
    !isdir(pth) ? mkdir(pth) : nothing
    fil_out=joinpath(pth,fil)

    !isfile(fil_out) ? FTPClient.download(ftp, fil, fil_out) : nothing
    fil_out
end

"""
    read(x::SurfaceDrifter,ii::Int)

Open file number `ii` from NOAA ftp server using `NCDatasets.jl`.

Server : ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/

Note: the first time this method is used, it calls `GDP.list_files()` 
to get the list of drifters from server, and save it to a temporary file.

```
using OceanRobots
sd=read(SurfaceDrifter(),1)
```
"""
read(x::SurfaceDrifter,ii::Int; list_files=[]) = begin
    lst=(isempty(list_files) ? GDP.list_files() : list_files)
	fil=GDP.download(lst,ii)
	ds=Dataset(fil)
    wmo=ds[:WMO][1]
    SurfaceDrifter(lst.ID[ii],ds,wmo,lst)
end

"""
    read(x::SurfaceDrifter; ID=300234065515480, version="v2.01")

Download file from NOAA http server read it using `NCDatasets.jl`.

Server : https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/

```
using OceanRobots
sd=read(SurfaceDrifter(),ID=300234065515480)
```
"""
read(x::SurfaceDrifter; ID=300234065515480, version="v2.01") = begin
    prefix = (version=="v2.01" ? "drifter_hourly_" : "drifter_")
    fil=prefix*"$(ID).nc"
    url0="https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/$(version)/netcdf/"
    path0=joinpath(tempdir(),"drifters_hourly_noaa")
    !isdir(path0) ? mkdir(path0) : nothing
    Downloads.download(url0*fil,path0*fil)
	ds=Dataset(path0*fil)
    wmo=ds[:WMO][1]
    SurfaceDrifter(ID,ds,wmo,DataFrame())
end

missing_to_NaN(x) = [(ismissing(y) ? NaN : y) for y in x]
read_v(ds,v) = missing_to_NaN(cfvariable(ds,v,missing_value=-1.e+34))

end #module GDP

##

module GDP_CloudDrift

using DataFrames, Statistics, NCDatasets, Downloads, Dates
import Base: read
import OceanRobots: CloudDrift
#

#https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/drifter_101783.nc
#https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:AOML-GDP-1hr
#https://www.aoml.noaa.gov/phod/gdp/hourly_data.php
#https://clouddrift.org/index.html

"""
    read(x::CloudDrift, file)

Read a GDP/CloudDrift file.    
"""
read(x::CloudDrift,file) = CloudDrift_demo(file)

function CloudDrift_demo(file="")
    isempty(file) ? fi=CloudDrift_subset_download() : fi=file
    #file="Drifter_hourly_v2p0/gdp_v2.00.nc"

    ds=GDP_CloudDrift.Dataset(fi)
    df=GDP_CloudDrift.to_DataFrame(ds)
    GDP_CloudDrift.add_ID!(df,ds)
    GDP_CloudDrift.add_index!(df)
    df.cv=df.ve+1im*df.vn

	lon = (-98, -78); lat = (18, 31)
	#lon = (-150, -140); lat = (25, 35)
	d0=DateTime("2000-01-1T00:00:00")
	d1=DateTime("2020-12-31T00:00:00")
	tim=(d0,d1)
	df_subset=GDP_CloudDrift.region_subset(df,lon,lat,tim)

    gdf2=GDP_CloudDrift.groupby(df,:ID)
	df_stats=GDP_CloudDrift.trajectory_stats(gdf2)

    gdf=GDP_CloudDrift.groupby(df,:index)
    grid=(lon=-180.0+0.25:0.5:180.0,lat=-90.0+0.25:0.5:90.0)
    (ve,vn)=GDP_CloudDrift.to_Grid(gdf,grid)
    
    CloudDrift(fi,(main=df,subset=df_subset,grid=grid,ve=ve,vn=vn,df_stats=df_stats))
end

CloudDrift_subset_download() = begin
    url="https://zenodo.org/records/11325477/files/gdp_subset.nc?download=1"
    fil=joinpath(tempdir(),"gdp_subset.nc")
    !isfile(fil) ? Downloads.download(url,fil) : nothing
    fil
end

"""
    to_DataFrame(ds)
"""
function to_DataFrame(ds)
	df=DataFrame(:sst => ds[:sst][:], :ve => ds[:ve][:], :vn => ds[:vn][:])
	in("drogue_status",names(df)) ? df.drogue_status=ds[:drogue_status][:] : nothing
	df.sst1=ds[:sst1][:]
	df.sst2=ds[:sst2][:]
    if haskey(ds,"longitude")
        df.longitude=ds[:longitude][:]
        df.latitude=ds[:latitude][:]
    else
        df.longitude=ds[:lon][:]
        df.latitude=ds[:lat][:]
    end    
	df.time=ds[:time][:]
	df
end

"""
    add_index!(df)
"""
function add_index!(df)
	ii=(df.longitude[:] .+180 .+0.25)/0.5;
	ilon=Int.(round.(ii))
	#extrema(ilon)

	ii=(df.latitude[:] .+90 .+0.25)/0.5;
	ilat=Int.(round.(ii))
	#extrema(ilat)

	df.index=CartesianIndex.(ilon,ilat)
end	

"""
    add_ID!(df,ds)
"""
function add_ID!(df,ds)
	tmp=ds[:ID][:]
	rowsize=ds[:rowsize][:]
    nn=[0 ; cumsum(ds["rowsize"])]
	df.ID=fill(0,nn[end])
	[df.ID[nn[i]+1:nn[i+1]].=tmp[i] for i in 1:length(nn)-1];
end

"""
    to_Grid(gdf,grid)
"""
function to_Grid(gdf,grid)
	df2=combine(gdf) do df
#		(ve=median(df.ve) , vn=median(df.vn) )
		(ve=mean(df.ve) , vn=mean(df.vn) )
	end
		
	ve=fill(NaN,(length(grid.lon),length(grid.lat)))
	[ve[df2.index[i]]=df2.ve[i] for i in 1:size(df2,1)];
	vn=fill(NaN,(length(grid.lon),length(grid.lat)))
	[vn[df2.index[i]]=df2.vn[i] for i in 1:size(df2,1)];

	ve,vn
end

"""
    region_subset(df,lons,lats,dates)

Subset of df that's within specified date and position ranges.    
"""
region_subset(df,lons,lats,dates) = 
    df[ (df.longitude .> lons[1]) .& (df.longitude .<= lons[2]) .&
    (df.latitude .> lats[1]) .& (df.latitude .<= lats[2]) .&
    (df.time .> dates[1]) .& (df.time .<= dates[2]) ,:]

"""
    trajectory_stats(gdf)
"""
function trajectory_stats(gdf)
	df2=combine(gdf) do df
		(ve=mean(df.ve) , vn=mean(df.vn) , 
		t0=minimum(skipmissing(df.time)) , t1=maximum(skipmissing(df.time)) ,
		longitude=mean(skipmissing(df.longitude)) , latitude=mean(skipmissing(df.latitude)) ,
		sst=mean(skipmissing(df.sst)) , sst1=mean(skipmissing(df.sst1)), sst2=mean(skipmissing(df.sst2)))
	end
	df2
end

end

##

module OceanSites

using NCDatasets, CSV, DataFrames, Dates
import FTPClient
import OceanRobots: OceanSite
import Base: read

"""
    read(x::OceanSite, ID=:WHOTS)

Read OceanSite data.    
"""
read(x::OceanSite,ID=:WHOTS) = begin
    if ID==:WHOTS
        (arr,units)=read_WHOTS()
        OceanSite(ID,arr,units)
    else
        @warn "site not yet supported"
        OceanSite()
    end
end


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
    ftp=FTPClient.FTP(url)
    !isfile(fil) ? FTPClient.download(ftp, "oceansites_index.txt",fil) : nothing

    #main table
    oceansites_index=DataFrame(CSV.File(fil; header=false, skipto=9, silencewarnings=true))

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
    read_variables(file,args...)

Open file from opendap server.

```
file="DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc"
OceanSites.read_variables(file,:lon,:lat,:time,:TEMP)
```
"""
function read_variables(file,args...)
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

status_url(s::Symbol)="https://www.ocean-ops.org/share/"*string(s)*"/Status/"  

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

##

module XBT

using TableScraper, HTTP, Downloads, CodecZlib, Dates, Glob, DataFrames, CSV, Dataverse
import OceanRobots: XBTtransect
import Base: read

"""# XBT transect

For more information, [see this page](https://www-hrx.ucsd.edu/index.html).

_Data were made available by the Scripps High Resolution XBT program (www-hrx.ucsd.edu)_
"""

"""
    list_transects(; group="AOML")

known groups : AOML, SIO    

```
using OceanRobots
OceanRobots.list_transects(:SIO)
```
read_NOAA_csv(path)
"""
function list_transects(group="SIO")
    if group=="AOML"
        list_of_transects_AOML
    elseif group=="SIO"
        list_of_transects_SIO
    else
        @warn "unknown group"
        []
    end
end

list_of_transects_SIO=[
	"PX05", "PX06", "PX30", "PX34", "PX37", "PX37-South", "PX38", "PX40", 
	"PX06-Loop", "PX08", "PX10", "PX25", "PX44", "PX50", "PX81", 
	"AX22", "IX15", "IX28"]

list_of_transects=list_of_transects_SIO #alias, deprecated

list_of_transects_AOML=[
    "AX01","AX02","AX04","AX07","AX08","AX10","AX18","AX20","AX25","AX32","AX90","AX97",
    "AXCOAST","AXWBTS","MX01","MX02","MX04"]
    
### SIO transects

dep = -(5:10:895) # Depth (m), same for all profiles

function get_url_to_download(url1)
    r = HTTP.get(url1)
    h = String(r.body)
    tmp=split(split(h,"../www-hrx/")[2],".gz")[1]
    "https://www-hrx.ucsd.edu/www-hrx/"*tmp*".gz"
end

function download_file_if_needed(url2)
	path1=joinpath(tempdir(),basename(url2))
	isfile(path1) ? nothing : Downloads.download(url2,path1)

	path2=path1[1:end-3]*".txt"
	open(GzipDecompressorStream, path1) do stream
       write(path2,stream)
    end
	
	path2
end

function read_SIO_XBT(path2)
	txt=readlines(path2)
	
	nlines=parse(Int,txt[1])
	T_all=zeros(nlines,length(dep))
	meta_all=Array{Any}(undef,nlines,4)

	for li in 1:nlines
		i=2+(li-1)*9
	
		lat=parse(Float64,txt[i][1:11])
		lon=parse(Float64,txt[i][12:19])
		lon+=(lon>180 ? -360 : 0)
		day=parse(Float64,txt[i][19:21])
		mon=parse(Float64,txt[i][23:24])
		year=parse(Float64,txt[i][26:27])
		hour=parse(Float64,txt[i][29:30])
		min=parse(Float64,txt[i][32:33])
		sec=parse(Float64,txt[i][35:36])
		profile_number=parse(Float64,txt[i][38:40])
		year=year+(year > 50 ? 1900 : 2000)
		date=DateTime(year,mon,day,hour,min,sec)

		meta_all[li,:]=[lon lat date profile_number]

		T=[]
		for ii in 1:8	
		push!(T,1/1000*parse.(Int,split(txt[i+ii]))...)
		end
		T[T.<0.0].=NaN
		T_all[li,:].=T
	end

	T_all,meta_all
#	lines(T,dep)
end

"""
    list_of_cruises(transect)

```
include("parse_xbt_html.jl")

transect="PX05"
cruises,years,months,url_base=list_of_cruises(transect)

CR=cruises[1]
url1=url_base*CR*".html"
url2=get_url_to_download(url1)

path2=download_file(url2)
```
"""
function list_of_cruises(transect="PX05")
	PX=transect[3:end]
	PX=( transect=="PX06-South" ? "37s" : PX )
	PX=( transect=="PX06-Loop" ? "06" : PX )

	pp="p"
	pp=( transect[1]=='I' ? "i" : pp )
	pp=( transect[1]=='A' ? "a" : pp )
	
    url0="https://www-hrx.ucsd.edu/$(pp)x$(PX).html"
    url_base=url0[1:end-5]*"/$(pp)$(PX)"
    x=scrape_tables(url0)
    y=x[4].rows

    months=Int[]; years=Int[]; cruises=String[]
    for row in 3:length(y)
    z=y[row]
    a=findall( (z.!==" \n           ").&&(z.!==" ") )
    if length(a)>1
        push!(months,Int.(a[2:end].-1)...)
        push!(years,parse(Int,z[1])*ones(length(a)-1)...)
        push!(cruises,z[a[2:end]]...)
    end
    end

    DataFrame("cruise" => cruises, "year" => years, "month" => months, "url" => .*(.*(url_base,cruises),".html"))
end

"""
    read(x::XBTtransect;transect="PX05",cr=1,cruise="")

```
using OceanRobots
read(XBTtransect(),source="SIO",transect="PX05",cruise="0910")
```
"""
function read(x::XBTtransect;source="SIO",transect="PX05",cr=1,cruise="")
    if source=="SIO"
        cruises=list_of_cruises(transect)
        CR=(isempty(cruise) ? cr : findall(cruises.cruise.=="0910")[1])
        url1=cruises.url[CR]
        url2=get_url_to_download(url1)
        path2=download_file_if_needed(url2)
        T_all,meta_all=read_SIO_XBT(path2)
        XBTtransect(source,transect,[T_all,meta_all,cruises.cruise[CR]],path2)
    elseif source=="AOML"
        list1=XBT.list_files_on_server(transect)
#       list2=XBT.get_url_to_transect(ax)
        CR=(isempty(cruise) ? cr : findall(list1.==cruise)[1])
        files=XBT.download_file_if_needed_AOML(transect,list1[CR])
        path=dirname(files[1])
        (data,meta)=read_NOAA_XBT(path)
        XBTtransect(source,string(transect),[data,meta,list1[CR]],path)
    else
        @warn "unknown source"
    end
end

### AOML transects

"""
    read_NOAA_XBT(path)

```
using OceanRobots
files=XBT.download_file_if_needed_AOML(8,"ax80102_qc.tgz")
(data,meta)=XBT.read_NOAA_XBT(dirname(files[1]))
```

List of variables:

- "te" is for in situ temperature
- "th" is for potential temperature
- “sa” for salinity (climatology from WOA)
- “ht” for dynamic height reference to sea surface
- “de” for depth
- “ox” for oxygen
- “Cast” for oxygen
"""
function read_NOAA_XBT(path; silencewarnings=true)
  list=glob("*.???",path)
  data=DataFrame()
  meta=DataFrame()
  for ii in 1:length(list)
    fil=list[ii]
    #println(fil)
    tmp1=CSV.read(fil,DataFrame,header=1,limit=1,delim=' ',ignorerepeated=true, silencewarnings=silencewarnings)
    #
    tmp2=tmp1[1,5]
    t=(size(tmp1,2)==7 ? tmp2*"200"*string(tmp1[1,6]) : tmp2[1:end-3]*"19"*tmp2[end-1:end] )
    d=Date(t,"mm/dd/yyyy")
    h=div(tmp1[1,end],100)
    m=rem(tmp1[1,end],100)
    t=DateTime(d,Time(h,m,0))
    #
    append!(meta,DataFrame("lon"=>tmp1.long,"lat"=>tmp1.lat,"time"=>t,"cast"=>tmp1.Cast))
    d=CSV.read(fil,DataFrame,header=11,skipto=13,delim=' ',ignorerepeated=true, silencewarnings=silencewarnings)
    d.lon.=meta.lon[end]
    d.lat.=meta.lat[end]
    d.time.=meta.time[end]
    d.cast.=meta.cast[end]
    append!(data,d)
  end
  (data,meta)
end

function get_url_to_transect(transect="AX08")
    ax=parse(Int,transect[3:end])
    url1="https://www.aoml.noaa.gov/phod/hdenxbt/ax_home.php?ax="*string(ax)
    r = HTTP.get(url1)
    h = String(r.body)
    txt0="<select name=\"cnum\">"
    txt1="</select></p><br><p>"
    h1=split(split(h,txt0)[2],txt1)[1]
    h2=split(h1,"value=")[2:end]
    [split(split(i,">")[2]," \n")[1] for i in h2]
#    tmp=split(split(h,"../www-hrx/")[2],".gz")[1]
end 

function list_files_on_server(transect="AX08")
    ax=parse(Int,transect[3:end])
    url1="https://www.aoml.noaa.gov/phod/hdenxbt/ax"*string(ax)*"/"
    r = HTTP.get(url1)
    h = String(r.body)
    #in the html look for "ax*_qc.tgz" etc:
    txt0="Parent Directory</a></li>\n"
    txt1="</ul>"
    h1=split(split(h,txt0)[2],txt1)[1]
    txt2="<li><a href=\""
    h2=split(h1,txt2)
    h2=h2[findall( (!isempty).(h2)  )]
    h3=[split(i,"\">")[1] for i in h2]
    h3[findall(occursin.("_qc.tgz",h3).||occursin.("_qc_2.tgz",h3).||occursin.("_qc_3.tgz",h3))]
end 


"""
    XBT.download_file_if_needed_AOML(transect="AX08",file="ax80102_qc.tgz")

```
using OceanRobots

list=XBT.list_transects("AOML")

transect="AX08"
list1=XBT.list_files_on_server(transect)
list2=XBT.get_url_to_transect(transect)

files=XBT.download_file_if_needed_AOML(transect,"ax80102_qc.tgz")
path=dirname(files[1])
(data,meta)=XBT.read_NOAA_XBT(path)
```
"""
function download_file_if_needed_AOML(transect="AX08",file="ax80102_qc.tgz")
    ax=parse(Int,transect[3:end])
    url1="https://www.aoml.noaa.gov/phod/hdenxbt/ax"*string(ax)*"/"*file
	path1=joinpath(tempdir(),file)
	isfile(path1) ? nothing : Downloads.download(url1,path1)
    tmp_path=Dataverse.untargz(path1)
    p=joinpath(tmp_path,"m1","data","xbt","aoml","nodc","ax"*string(ax))
	p=joinpath(p,readdir(p)[1])
    glob("*.???",p)
end

end

##
