
module Glider_Spray_module

import OceanRobots: Glider_Spray
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
    read(x::Glider_Spray, file::String)

Read a Spray Glider file.    
"""
read(x::Glider_Spray, file="GulfStream.nc") = begin
    f=check_for_file_Spray(file)
    df=to_DataFrame(Dataset(f))
    Glider_Spray(f,df)
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

end

## 

module Glider_EGO_module

using FTPClient, NCDatasets
using JSON3, FTPClient
import OceanRobots: Glider_EGO
import Base: read

"""
    file_lists(k=1:2)

Get list of EGO glider files from ftp server `ftp://ftp.ifremer.fr/ifremer/glider/v2/`

```
missions,folders,files=Glider_EGO_module.file_lists(1:10)
Glider_EGO_module.glider_download(files[1][1])

data=read(Glider_EGO(),2)


fig_glider=plot(data)

ds=data.ds,variable="CHLA")
```
"""
function file_lists(k=1:2)
	ftp=FTPClient.FTP("ftp://ftp.ifremer.fr/ifremer/glider/v2/")
	missions=readdir(ftp)
	folders=[]
	files=[]
	for m in missions[k]
		ftp=FTPClient.FTP("ftp://ftp.ifremer.fr/ifremer/glider/v2/"*m*"/")
		push!(folders,readdir(ftp))
		for n in folders[end]
			ftp=FTPClient.FTP("ftp://ftp.ifremer.fr/ifremer/glider/v2/"*m*"/"*n*"/")
			url0="ftp://ftp.ifremer.fr/ifremer/glider/v2/"*m*"/"*n*"/"			
			push!(files,url0.*readdir(ftp))
		end
	end
	missions,folders,files
end

function glider_download(fil)
	url0=dirname(fil)
	fil0=basename(fil)

	n0=length("ftp://ftp.ifremer.fr/ifremer/glider/v2/")
	tmp1=url0[n0+1:end]
	tmp2=dirname(tmp1)

	pth=joinpath(tempdir(),"glider")
    !isdir(pth) ? mkdir(pth) : nothing

	pth=joinpath(tempdir(),"glider",tmp2)
    !isdir(pth) ? mkdir(pth) : nothing

	pth=joinpath(tempdir(),"glider",tmp1)
    !isdir(pth) ? mkdir(pth) : nothing

    fil_out=joinpath(pth,fil0)
	ftp=FTPClient.FTP(url0)
    !isfile(fil_out) ? FTPClient.download(ftp, fil0, fil_out) : nothing
    fil_out
end

function file_indices(files)
	if split(files[1],".")[end]=="json"
		i_nc=2
		i_json=1
	else
		i_nc=1
		i_json=2
	end
	i_nc,i_json
end


function read_Glider_EGO(ID::Int)
    missions,folders,files=file_lists(ID:ID)
    i_nc,i_json=file_indices(files[1])
    file_nc=glider_download(files[1][i_nc])
    file_json=glider_download(files[1][i_json])
    ds=Dataset(file_nc)
    js=JSON3.read(file_json)
    (missions=missions,file_nc=file_nc,file_json=file_json,ds=ds,js=js)
end

"""
    read(x::Glider_EGO, ID=1)

Read a EGO Glider files.    
"""
read(x::Glider_EGO, ID=1) = begin
    data=read_Glider_EGO(ID)
    Glider_EGO(ID,data)
end

end

##

module Glider_AOML_module

import OceanRobots: Glider_AOML
import FTPClient, NCDatasets
import Base: read

url0="ftp://ftp.aoml.noaa.gov/phod/pub/bringas/Glider/Operation/Data/"

"""
    query(; option=:gliders, glider=missing, mission=missing)

```
OceanRobots.query(Glider_AOML,glider="SG610",mission="M03JUL2015",option=:profiles)

list1=Glider_AOML_module.query(option=:gliders);
list2=Glider_AOML_module.query(glider=list1[1],option=:missions)
list3=Glider_AOML_module.query(glider="SG610",mission="M03JUL2015",option=:profiles)
```
"""
function query(; option=:gliders, glider=missing, mission=missing)
	if option==:gliders
		ftp=FTPClient.FTP(url0)
		readdir(ftp)
	elseif option==:missions
		url=url0*glider*"/"; println(url)
		readdir(FTPClient.FTP(url0*glider*"/"))
	elseif option==:profiles
		readdir(FTPClient.FTP(url0*glider*"/"*mission*"/"))
	else
		"unknown option"
	end
end

function scan(i=5,j=1,k=3)
	top=Glider_AOML_module.query(option=:gliders);
	name_glider=top[i]
	ls_glider=query(glider=name_glider,option=:missions)
	name_mission=ls_glider[j]
	ls_mission=query(glider=name_glider,mission=name_mission,option=:profiles)
	name_file=ls_mission[k]

	sample_file=url0*name_glider*"/"*name_mission*"/"*name_file
	(top_level=top,name_glider=name_glider,name_mission=name_mission,
	name_file=name_file,ls_glider=ls_glider,ls_mission=ls_mission,
	sample_file=sample_file)
end

function download_AOML(ID::Symbol)
	#download whole set of profiles
end

"""
    download_AOML(fil)

```
using OceanRobots
scan=OceanRobots.Glider_AOML_module.scan();
sample_file=OceanRobots.Glider_AOML_module.download_AOML(scan.sample_file)
```	
"""
function download_AOML(fil)
	url0=dirname(fil)
	fil0=basename(fil)

	n0=length(url0)
	tmp1=url0[n0+1:end]
	tmp2=dirname(tmp1)

	pth=joinpath(tempdir(),"glider_AOML")
    !isdir(pth) ? mkdir(pth) : nothing

	pth=joinpath(tempdir(),"glider_AOML",tmp2)
    !isdir(pth) ? mkdir(pth) : nothing

	pth=joinpath(tempdir(),"glider_AOML",tmp1)
    !isdir(pth) ? mkdir(pth) : nothing

    fil_out=joinpath(pth,fil0)
	ftp=FTPClient.FTP(url0)

    !isfile(fil_out) ? FTPClient.download(ftp, fil0, fil_out) : nothing
    fil_out
end

"""
    read(x::Glider_AOML, file::String)

Read a AOML Glider file. 

```
using OceanRobots
sample_file=OceanRobots.Glider_AOML_module.sample_file()
glider=read(Glider_AOML(),sample_file);
```
"""
read(x::Glider_AOML, file::String=sample_file()) = begin
	ds,data=read_glider(file)
    Glider_AOML(file,data)
end

function sample_file()
	sc=scan();
	sample_file=download_AOML(sc.sample_file)
end

"""
    read_glider(file)

```
using OceanRobots
scan=OceanRobots.Glider_AOML.scan();
sample_file=OceanRobots.Glider_AOML.download_AOML(scan.sample_file)
ds,data=OceanRobots.Glider_AOML.read(sample_file)
```
"""
function read_glider(file)
	println(file)
	ds=NCDatasets.Dataset(file)

	tmp=Dict()
	merge!(tmp,Dict("trajectory" => string(ds["trajectory"][:]...)))
	lst=["ctd_time","longitude","latitude","ctd_depth","temperature","salinity"]
	append!(lst,["profile_id","profile_time","profile_lon","profile_lat","du","dv"])
	for i in lst
		merge!(tmp,Dict(i=>ds[i][:]))
	end

	data=NamedTuple((Symbol(key),value) for (key,value) in tmp)
	
	ds,data
end

end