
module XBT

using TableScraper, HTTP, Downloads, CodecZlib, Dates, Glob, DataFrames, CSV, Dataverse
import OceanRobots: XBTtransect, query
import Base: read

"""# XBT transect

For more information, [see this page](https://www-hrx.ucsd.edu/index.html).

_Data were made available by the Scripps High Resolution XBT program (www-hrx.ucsd.edu)_
"""

"""
    list_transects(; group="SIO")

known groups : AOML, SIO    

```
using OceanRobots
OceanRobots.list_transects("SIO")
```
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
#       list2=XBT.get_url_to_transect(transect)
        CR=(isempty(cruise) ? cr : findall(list1.==cruise)[1])
        files=XBT.download_file_if_needed_AOML(transect,list1[CR])
        if !isempty(files)
            path=dirname(files[1])
            (data,meta)=read_NOAA_XBT(path)
            XBTtransect(source,string(transect),[data,meta,list1[CR]],path)
        else
            XBTtransect()
        end
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
    tmp1=CSV.read(fil,DataFrame,header=1,limit=1,delim=' ',ignorerepeated=true, silencewarnings=silencewarnings)
    #
    tmp2=tmp1[1,5]
    t=(if size(tmp1,2)==7
        tmp2*"200"*string(tmp1[1,6])
    else
        tmp2a=tmp2[end-1:end]
        tmp2b=parse(Int,tmp2a)
        tmp2[1:end-2]*(tmp2b<50 ? "19"*tmp2a : "20"*tmp2a)
    end)
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
    ax=name_on_API(transect)
    url1="https://www.aoml.noaa.gov/phod/hdenxbt/ax_home.php?ax="*string(ax)
    r = HTTP.get(url1)
    h = String(r.body)
    txt0="<select name=\"cnum\">"
    txt1="</select></p><br><p>"
    h1=split(split(h,txt0)[2],txt1)[1]
    h2=split(h1,"value=")[2:end]
    [split(split(i,">")[2]," \n")[1] for i in h2]
end 

function list_files_on_server(transect="AX08")
    ax=name_on_server(transect)
    url1="https://www.aoml.noaa.gov/phod/hdenxbt/"*ax*"/"
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

function name_on_server(transect)
    ax=if transect=="AXCOAST"
        "axcs"
    elseif transect=="AXWBTS"
        "axwbts"
    elseif transect[1:2]=="MX"
        "mx"*string(parse(Int,transect[3:end]))
    else
        "ax"*string(parse(Int,transect[3:end]))
    end
end

function name_on_API(transect)
    ax=if transect=="AXCOAST"
        "cs"
    elseif transect=="AXWBTS"
        "wbts"
    elseif transect[1:2]=="MX"
        "1"*transect[3:end]
    else
        transect[3:end]
    end
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
    ax=name_on_server(transect)
    url1="https://www.aoml.noaa.gov/phod/hdenxbt/"*ax*"/"*file
	path1=joinpath(tempdir(),file)
	isfile(path1) ? nothing : Downloads.download(url1,path1)
    tmp_path=Dataverse.untargz(path1)

    p=[tmp_path]
    if !isempty(readdir(p[1]))
        f=glob("*.???",p[1])
        while(isempty(f))
            p.=joinpath(p[1],readdir(p[1])[1])
            f=glob("*.???",p[1])
        end
    end

    glob("*.???",p[1])
end

###

function download_all_AOML(path="XBT_AOML")
    !ispath(path) ? mkdir(path) : nothing
    lst_AOML=query(XBTtransect,"AOML")
    for transect in lst_AOML
        lst_AOML_files=DataFrame("transect"=>String[],"cruise"=>Int[],"file"=>String[])
        println(transect)
        df=XBT.list_files_on_server(transect)
        for cr in 1:size(df,1)
            files=XBT.download_file_if_needed_AOML(transect,df[cr])

            df1=DataFrame("transect"=>fill(transect,length(files)),
                "cruise"=>fill(cr,length(files)),"file"=>[basename(f) for f in files])
            append!(lst_AOML_files,df1)

            path1=joinpath(path,transect*"_"*string(cr))
            mkdir(path1)
            [mv(f,joinpath(path1,basename(f))) for f in files]
        end
        fil="list_"*transect*".csv"
        CSV.write(joinpath(path,fil),lst_AOML_files)
    end
end

###

function scan_XBT_AOML(ii=0,jj=0; path="XBT_AOML")
    list1=glob("*.csv",path)
    if ii==0
        list1
    else
        list2=CSV.read(list1[ii],DataFrame) #ii
        list3=groupby(list2,:cruise)
        if jj==0
            list3
        else
            list3[jj] #jj
        end
    end
end

"""
    read_XBT_AOML(subfolder::String; path="XBT_AOML")

```
df0=XBT.valid_XBT_AOML()
XBT.read_XBT_AOML(df0.subfolder[100])
```
"""
function read_XBT_AOML(subfolder::String; path="XBT_AOML")
    transect,cruise=split(subfolder,"_")
    list1=readdir(joinpath(path,subfolder))
    list=DataFrame("file"=>list1)
    list.transect.=transect
    list.cruise.=cruise
    read_XBT_AOML(list; path=path)    
end
    
"""
    read_XBT_AOML(subfolder::String; path="XBT_AOML")

```
XBT.read_XBT_AOML(1,1)
```
"""
function read_XBT_AOML(ii=1,jj=1; path="XBT_AOML")
    list=scan_XBT_AOML(ii,jj)
    read_XBT_AOML(list; path=path) 
end

function read_XBT_AOML(list4::AbstractDataFrame; path="XBT_AOML")    
    transect=list4[1,:transect]
    cruise=list4[1,:cruise]
    subfolder=transect*"_"*string(cruise)

    path2=joinpath(path,subfolder)
    T_all,meta_all=read_NOAA_XBT(path2)
    XBTtransect("AOML",transect,[T_all,meta_all,subfolder],path2)
end

function valid_XBT_AOML(;path="XBT_AOML")
    list1=scan_XBT_AOML()
    df=DataFrame()
    for ii in 1:length(list1)
        list2=scan_XBT_AOML(ii)
        for jj in 1:length(list2)
            list4=scan_XBT_AOML(ii,jj)
            transect=list4[1,:transect]
            cruise=list4[1,:cruise]
            subfolder=transect*"_"*string(cruise)
            test=try
                read_XBT_AOML(ii,jj)
                true
            catch
                false
            end
            append!(df,DataFrame("transect"=>transect,"cruise"=>cruise,"subfolder"=>subfolder,"test"=>test))
        end
    end
    ok=findall(df.test)
    no=findall((!).(df.test))
    println("valid cruises      = "*string(length(ok)))
    println("unreadable cruises = "*string(length(no)))
    df[ok,:]
end

end
