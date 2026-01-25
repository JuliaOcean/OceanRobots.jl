
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
    read(x::Glider_Spray, file::String, cruise=1, format=0)

Read a Spray Glider file into a `Glider_Spray`.

```
using OceanRobots, CairoMakie
glider=read(Glider_Spray(),"GulfStream.nc",1)
plot(glider)
```

- `format==0` (default) : format data via `to_DataFrame`
- `format==0` : format data via `to_DataFrame_v1` (to plot via `plot_glider_Spray_v1`)
"""
function read(x::Glider_Spray, file="GulfStream.nc", cruise=1, format=0)
    f=check_for_file_Spray(file)
    data=if format==0
		to_DataFrame(Dataset(f),cruise)
	elseif format==-1
		to_DataFrame_v1(Dataset(f))
	else
		error("unknown format")
	end
    Glider_Spray(f,data)
end

function to_DataFrame(ds,cruise=0)
#	id=unique(ds["trajectory_index"])
	nz=ds.dim["depth"]
	np=ds.dim["profile"]
	ii=findall(ds["trajectory_index"].==cruise-1)
	npi=length(ii)

	lon=ds[:lon][ii]*ones(1,nz)
	lat=ds[:lat][ii]*ones(1,nz)
	dep=ones(npi,1)*ds["depth"][:]'
	temp=ds[:temperature][ii,:]
	sal=ds[:salinity][ii,:]
	tim=repeat(ds[:time][ii],1,nz)

	df=DataFrames.DataFrame()
	df.time=tim[:]
	df.longitude=lon[:]
	df.latitude=lat[:]
	df.depth=dep[:]
	df.temperature=temp[:]
	df.salinity=sal[:]

	df
end

function to_DataFrame_v1(ds)
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

import FTPClient, NCDatasets, DataFrames, JSON3
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
    ds=NCDatasets.Dataset(file_nc)
    js=JSON3.read(file_json)
    (missions=missions,file_nc=file_nc,file_json=file_json,ds=ds,js=js)
end

"""
    read(x::Glider_EGO, ID=1)

Read a EGO Glider files.    
"""
read(x::Glider_EGO, ID=1) = begin
    tmp=read_Glider_EGO(ID)
	data=to_DataFrame(tmp.ds)
    Glider_EGO(ID,data)
end

function to_DataFrame(ds)
	df=DataFrames.DataFrame()
	df.time=ds[:TIME][:]
	df.longitude=ds[:LONGITUDE][:]
	df.latitude=ds[:LATITUDE][:]
	df.depth=ds[:GLIDER_DEPTH][:]
	df.temperature=ds[:TEMP][:]
	df.salinity=ds[:PSAL][:]
	df
end

end

##

module Glider_AOML_module

import OceanRobots: Glider_AOML
import FTPClient, NCDatasets, DataFrames, Glob
import Base: read

url0="ftp://ftp.aoml.noaa.gov/phod/pub/bringas/Glider/Operation/Data/"

"""
    query(; option=:gliders, glider=missing, mission=missing)

```
OceanRobots.query(Glider_AOML,glider="SG610",mission="M03JUL2015",option=:profiles)

list1=Glider_AOML_module.query(option=:gliders)
g=list1[5]
list2=Glider_AOML_module.query(glider=g,option=:missions)
m=list1[2]
list3=Glider_AOML_module.query(glider=g,mission=m,option=:profiles)
p=list3[1]
```
"""
function query(; option=:gliders,  
	glider=missing, mission=missing, verbose=false)
	if option==:gliders
		ftp=FTPClient.FTP(url0)
		Symbol.(readdir(ftp))
	elseif option==:missions
		url=url0*string(glider)*"/"
		verbose ? println(url) : nothing
		Symbol.(readdir(FTPClient.FTP(url)))
	elseif option==:profiles
		url1=url0*string(glider)*"/"*string(mission)*"/"
		url_to_file.(url1.*readdir(FTPClient.FTP(url1)))
	else
		"unknown option"
	end
end

##

"""
    download_AOML(ID::Symbol)

```
using OceanRobots
gliders=Glider_AOML_module.query();
ID=Symbol(gliders[5]);

missions=Glider_AOML_module.query(glider=string(ID),option=:missions)
#Glider_AOML_module.download_AOML(ID);

m=missions[1]
profiles=Glider_AOML_module.query(glider=string(ID),mission=m,option=:profiles)

p=profiles[1]
isfile(p) ? nothing : Glider_AOML_module.download_AOML(p)
glider=read(Glider_AOML(),p);
```
"""
function download_AOML(ID::Symbol; verbose=false)
	missions=query(glider=string(ID),option=:missions)
	for m in missions
		verbose ? println(m) : nothing
		profiles=query(glider=string(ID),mission=m,option=:profiles)
		url1=dirname(file_to_url(profiles[1]))
		ftp=FTPClient.FTP(url1)
		for p in profiles
			download_AOML(ftp,p,verbose=verbose)
		end
		close(ftp)
	end
end

"""
    download_AOML(fil::String)

```
using OceanRobots
sample_file=Glider_AOML_module.sample_file()
sample_file=Glider_AOML_module.download_AOML(sample_file)
```	
"""
function download_AOML(fil::String; verbose=false)
	verbose ? println(fil) : nothing
	url1=dirname(file_to_url(fil))
	ftp=FTPClient.FTP(url1)
	download_AOML(ftp,fil; verbose=verbose)
	close(ftp)
	fil
end

function download_AOML(ftp::FTPClient.FTP,fil::String; verbose=false)
	verbose ? println(fil) : nothing

	path0,fil0=(dirname(fil),basename(fil))
	paths=[dirname(dirname(dirname(fil))), dirname(dirname(fil)), dirname(fil)]
	for p in paths
	    !isdir(p) ? mkdir(p) : nothing
	end

    !isfile(fil) ? FTPClient.download(ftp, fil0, fil) : nothing
    fil
end

##

"""
    read(x::Glider_AOML, file::String)

Read a AOML Glider file. 

```
using OceanRobots
sample_file=Glider_AOML_module.sample_file()
glider=read(Glider_AOML(),sample_file)
```
"""
function read(x::Glider_AOML, file::String=sample_file())
	Glider_AOML(file,read_profile(file))
end

"""
    read(x::Glider_AOML, ID::Symbol, mission::Symbol)

Read a AOML glider mission. 

```
using OceanRobots
(ID,MS)=Glider_AOML_module.ID_MS(5,1)
glider=read(Glider_AOML(),ID,MS)

using CairoMakie
scatter(glider.data.longitude,glider.data.latitude)
```
"""
function read(x::Glider_AOML, ID::Symbol, mission::Symbol)
	profiles=query(glider=string(ID),mission=string(mission),option=:profiles)
	p=joinpath(tempdir(),"glider_AOML",string(ID),string(mission))
	profiles=Glob.glob("*.nc",p)

	tmp=DataFrames.DataFrame()
	for p in profiles
		ds=NCDatasets.Dataset(p)
		append!(tmp,to_DataFrame(ds))
	end
	
	Glider_AOML(p,tmp)
end

"""
    read_profile(file)

```
using OceanRobots
sample_file=Glider_AOML_module.sample_file(3,1,1)
df=Glider_AOML_module.read_profile(sample_file)
```
"""
function read_profile(file; verbose=false)
	isfile(file) ? nothing : download_AOML(file)
	ds=NCDatasets.Dataset(file)
	to_DataFrame(ds)
end 

##

function to_DataFrame(ds)
	df=DataFrames.DataFrame()
	df.time=ds[:ctd_time][:]
	df.longitude=ds[:longitude][:]
	df.latitude=ds[:latitude][:]
	df.depth=ds[:ctd_depth][:]
	df.temperature=ds[:temperature][:]
	df.salinity=ds[:salinity][:]
	df
end

##

function ID_MS(i,j)
	ID=query(option=:gliders)[i]
	MS=query(glider=ID,option=:missions)[j]
	(ID,MS)
end

##

function sample_file(i=5,j=1,k=1)
	(ID,MS)=ID_MS(i,j)
	profile=query(glider=string(ID),mission=MS,option=:profiles)[k]
end

##

function url_to_file(url; folder=joinpath(tempdir(),"glider_AOML"))
	tmp0=split(url,"/")
	tmp1=tmp0[end-2]
	tmp2=tmp0[end-1]
	fil0=tmp0[end]
	joinpath(folder,tmp1,tmp2,fil0)
end

function file_to_url(fil)
	tmp0=split(fil,"/")
	tmp1=tmp0[end-2]
	tmp2=tmp0[end-1]
	fil0=tmp0[end]
	joinpath(url0,tmp1,tmp2,fil0)
end

##

end