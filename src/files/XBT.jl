
module XBT

import Lexbor
using HTTP, Downloads, CodecZlib, Dates, Glob
using DataFrames, CSV, Dataverse, Interpolations
import OceanRobots: XBTtransect, query, THREDDS, Dataset
import Base: read

## General, Driver, Methods

### Read Method

"""
    read(x::XBTtransect;transect="PX05",cr=1,cruise="")

```
using OceanRobots
read(XBTtransect(),source="SIO",transect="PX05",cruise="0910")
```
"""
function read(x::XBTtransect;source="SIO",transect="PX05",cr=1,cruise="")
    cruises=list_of_cruises(transect,source=source)
    if source=="SIO"
        CR=(isempty(cruise) ? cr : findall(cruises.cruise.==cruise)[1])
        url1=cruises.url[CR]
        url2=get_url_to_download(url1)
        path2=download_SIO_cruise(url2)
        data,meta=read_SIO_XBT(path2)
        XBTtransect(source,source,transect,cruise,path2,data,meta)
    elseif source=="AOML"
#       list2=XBT.get_url_to_transect(transect)
        CR=(isempty(cruise) ? cr : findall(cruises.File.==cruise)[1])
        cru=cruises.File[CR]
        files=download_AOML_cruise(transect,cru)
        if !isempty(files)
            path=dirname(files[1])
            (data,meta)=read_NOAA_XBT(path)
            tr=string(transect)
            XBTtransect(source,source,basename(path),tr,path,data,meta)
        else
            XBTtransect()
        end
    elseif source=="IMOS"
        cr=transect*"_"*cruise
        CR=findall([a.cruise==cr for a in keys(cruises)])[1]
        df=DataFrame(cruises[CR])
        df.file=download_IMOS_cruise(cruises[CR])
        data,meta=read_IMOS_XBT(df)
        meta.file=basename.(df.file)
        XBTtransect(source,source,cr,transect,dirname(df.file[1]),data,meta)
    else
        @warn "unknown source"
    end
end

### Query Methods

"""
    list_transects(; source="SIO")

known groups : AOML, SIO, IMOS 

```
using OceanRobots
OceanRobots.XBT.list_transects(source="SIO")
```
"""
function list_transects(group="deprecated"; source="SIO")
    src=(group=="deprecated" ? source : group)
    if src=="AOML"
        list_of_transects_AOML()
    elseif src=="SIO"
        list_of_transects_SIO()
    elseif src=="IMOS"
        list_of_transects_IMOS().transect
    else
        @warn "unknown group"
        []
    end
end

"""
    list_of_cruises(transect)

```
transect="PX05"
cruises,years,months,url_base=list_of_cruises(transect)

CR=cruises[1]
url1=url_base*CR*".html"
url2=get_url_to_download(url1)

path2=download_file(url2)
```
"""
function list_of_cruises(tr="deprecated"; source="SIO", transect="PX05", option="cruises")
    trnsct=(tr=="deprecated" ? transect : tr)
    all=if source=="SIO"
        list_of_cruises_SIO(trnsct) #requires web access
    elseif source=="AOML"
        list_of_cruises_AOML(trnsct) #requires web access
    elseif source=="IMOS"
        list_of_cruises_IMOS(trnsct)
    else
        @warn "unknown source"
        DataFrame()
    end
        
end

### SIO transects

dep = (5:10:895) # Depth (m), same for all profiles

function get_url_to_download(url1)
    r = HTTP.get(url1)
    h = String(r.body)
    tmp=split(split(h,"../www-hrx/")[2],".gz")[1]
    "https://www-hrx.ucsd.edu/www-hrx/"*tmp*".gz"
end

function download_SIO_cruise(url2)
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

    (np,nz)=size(T_all)
    lon=meta_all[:,1]*ones(1,nz)
    lat=meta_all[:,2]*ones(1,nz)
    t=repeat(meta_all[:,3],1,nz)
    c=repeat(meta_all[:,4],1,nz)
    d=ones(np,1)*transpose(dep)

    ii=findall((!isnan).(T_all))
    data=DataFrame("cast"=>c[ii],"lon"=>lon[ii],"lat"=>lat[ii],
        "depth"=>d[ii],"time"=>t[ii],"temp"=>T_all[ii])
    meta=DataFrame("lon"=>meta_all[:,1],"lat"=>meta_all[:,2],
        "time"=>meta_all[:,3],"profile_number"=>meta_all[:,4])
	data,meta
end

### Query Methods

function list_of_transects_SIO()
    ["PX05", "PX06", "PX30", "PX34", "PX37", "PX37-South", "PX38", "PX40", 
	"PX06-Loop", "PX08", "PX10", "PX25", "PX44", "PX50", "PX81", 
	"AX22", "IX15", "IX28"]
end

"""
    scan_SIO()

"""
function scan_SIO()
    source="SIO"
    list=query(XBTtransect,source)
    data=DataFrame()
    for transect in list
        try
            println(transect)
            cruises=list_of_cruises(transect,source=source)
            append!(data,cruises)
        catch
            println(transect*" [FAILED]")
        end
    end
    data.source.="SIO"
    data
end

# use Lexbor.jl to extract list of cruises from SIO webpage

node_text(n::Lexbor.Node) = replace(Lexbor._content(n.ptr), '\u00a0' => ' ', '\r' => "")

table_rows(t) = [[node_text(c) for c in Lexbor.query(tr, "th, td")]
                 for tr in Lexbor.query(t, "tr")]

function scrape_tables_SIO(url; leaves_only=true)
    html = sprint(io -> Downloads.download(url, io))
    doc  = Lexbor.Document(html)
    tbls = Lexbor.query(doc, "table")
    leaves_only && (tbls = filter(t -> isempty(Lexbor.query(t, "table")), tbls))
    [table_rows(t) for t in tbls]
end

function list_of_cruises_SIO(transect="PX05")
	PX=transect[3:end]
	PX=( transect=="PX06-South" ? "37s" : PX )
	PX=( transect=="PX06-Loop" ? "06" : PX )

	pp="p"
	pp=( transect[1]=='I' ? "i" : pp )
	pp=( transect[1]=='A' ? "a" : pp )
	
    url0="https://www-hrx.ucsd.edu/$(pp)x$(PX).html"
    url_base=url0[1:end-5]*"/$(pp)$(PX)"
    x=scrape_tables_SIO(url0)
    y=x[2]
    
    months=Int[]; years=Int[]; cruises=String[]; url00=String[]; 
    for row in 3:length(y)
        z=y[row]
        a=cleanup_2(cleanup_1.(z))
        for k in 2:length(a)
            push!(months,parse(Int,a[k][3:4]))
            push!(years,parse(Int,z[1]))
            push!(cruises,transect*"_"*a[k])
            push!(url00,a[k])
        end
    end

    url1=.*(.*(url_base,url00),".html")
    DataFrame("cruise" => cruises, "year" => years, "month" => months, "url" => url1)
end

cleanup_1(x)=strip.(split(x,"\n"))
function cleanup_2(x)
    y=[]
    for xx in x
       isempty(xx) ? nothing : push!(y,xx...)
    end
    y[findall(.!(y.==""))]
end

## NOAA AOML data

##### single-cast reader

yr4(y) = y < 50 ? 2000 + y : y < 100 ? 1900 + y : y

"""
    read_hrx_profile(fil; missval=nothing)

Parse one NOAA/AOML high-resolution XBT cast file. Returns a `DataFrame` of the
profile block, with cast position/time and the free-form header stored as
table-level metadata (`:note` style).

Handles the space-padded year in the cast line (e.g. `01/10/ 2`), locates the
numeric block from the file's own `columns represent :` marker, and tolerates an
optional units line.

Pass `missval=-9.0` to convert the fill value to `missing`.
"""
function read_hrx_profile(fil; missval=nothing)
    ls = readlines(fil)
    length(ls) < 2 && error("file too short: $fil")

    ## 1 - cast line: tolerates "01/10/ 2", " 1/10/02", "01/10/2002"
    m = match(r"""^\s*(\d+)\s+(-?[\d.]+)\s+(-?[\d.]+)\s+(-?[\d.]+)\s+
                  (\d{1,2})\s*/\s*(\d{1,2})\s*/\s*(\d{1,4})\s+(\d{1,4})"""x, ls[2])
    isnothing(m) && error("cannot parse cast line of $fil: ", repr(ls[2]))

    yraw = parse(Int, m[7])
    year = length(strip(m[7])) >= 4 ? yraw : yr4(yraw)
    date = Date(year, parse(Int, m[5]), parse(Int, m[6]))
    gmt  = parse(Int, m[8])

    cast = Dict{String,Any}(
        "cast" => parse(Int,     m[1]),
        "lat"  => parse(Float64, m[2]),
        "lon"  => parse(Float64, m[3]),
        "jday" => parse(Int,     m[4]),
        "gmt"  => gmt,
        "date" => date,
        "time" => DateTime(date) + Hour(gmt ÷ 100) + Minute(gmt % 100))

    ## 2 - locate numeric block (replaces hard-coded header=11, skipto=13)
    i = findfirst(l -> occursin(r"columns\s+represent", l), ls)
    isnothing(i) && error("no 'columns represent' marker in $fil")
    cols = Symbol.(split(ls[i+1]))
    u    = i+2 <= length(ls) ? split(ls[i+2]) : String[]
    numeric_u = !isempty(u) && all(x -> !isnothing(tryparse(Float64, x)), u)
    j     = numeric_u ? i+2 : i+3
    units = numeric_u ? fill("", length(cols)) :
            [u; fill("", max(0, length(cols) - length(u)))]

    ## 3 - free-form metadata ("Key: value", several per line)
    meta = Dict{String,Any}()
    for l in ls[3:i-1]
        for mm in eachmatch(
                r"([A-Za-z_][A-Za-z_0-9]*):\s*(.*?)(?=\s{2,}[A-Za-z_][A-Za-z_0-9]*:|\s*$)", l)
            v = strip(mm[2])
            isempty(v) || (meta[mm[1]] = (v == "NA" ? missing : v))
        end
    end
    free = filter(l -> !occursin(':', l) && !isempty(strip(l)), ls[3:i-1])
    isempty(free) || (meta["comments"] = strip.(free))

    ## 4 - the profile itself
    body = filter(!isempty ∘ strip, ls[j:end])
    df = CSV.read(IOBuffer(join(body, '\n')), DataFrame;
                  header=cols, delim=' ', ignorerepeated=true,
                  types=Float64,  on_error=:collect)

    if missval !== nothing
        for c in propertynames(df)
            df[!, c] = [ismissing(x) || x == missval ? missing : x for x in df[!, c]]
        end
    end

    for (k, v) in cast; metadata!(df, k, v; style=:note); end
    for (k, v) in meta; metadata!(df, k, v; style=:note); end
    for (c, un) in zip(cols, units)
        isempty(un) || colmetadata!(df, c, "units", un; style=:note)
    end
    return df
end

##### directory-level wrapper

"""
    read_NOAA_XBT(path; output_format="DataFrame", temp_var=:th, missval=nothing)

Read all NOAA/AOML high-resolution XBT cast files found in `path`.
Returns `(data, meta)`, where `meta` has one row per cast
(`lon`, `lat`, `time`, `cast`) and `data` holds the profiles.

```
using OceanRobots
files=XBT.download_AOML_cruise("AX08","ax80102_qc.tgz")
(data,meta)=XBT.read_NOAA_XBT(dirname(files[1]))
```

Output formats:

- `output_format="DataFrame"` (default) : `cast`, `lon`, `lat`, `time`,
  `depth` (= `de`), `temp` (= `temp_var`, `:th` by default).
- anything else : all columns found in the files, as named below, plus
  `cast`, `lon`, `lat`, `time`.

List of variables (as named in the files):

- "pr" is for pressure
- "te" is for in situ temperature
- "th" is for potential temperature
- "sa" for salinity (climatology from WOA)
- "ht" for dynamic height referenced to sea surface
- "de" for depth
- "ox" for oxygen (present only in files that report it)
- "cast" for the cast number

Notes:

- `-9.000` is the fill value; pass `missval=-9.0` to get `missing` instead.
- Columns are taken from each file's own `columns represent :` block, so files
  with different variable sets can be mixed (absent columns become `missing`).
- Per-cast header info (`Ship_name`, `Probe_type`, `Bottom_depth`, ...) is
  available via `metadata()` on the per-file `read_hrx_profile` result.
- `on_error=:collect` skips unparseable files with a warning; anything else
  rethrows.
"""
function read_NOAA_XBT(path; on_error=:collect, output_format="DataFrame",
                       temp_var=:th, missval=nothing, verbose=false)
    temp_var = Symbol(temp_var)
    list = glob("*.???", path)
    data = DataFrame()
    meta = DataFrame()

    for fil in list
        verbose && println(fil)
        df = try
            read_hrx_profile(fil; missval)
        catch err
            on_error === :collect || rethrow()
            @warn "skipping $fil" exception=(err, catch_backtrace())
            continue
        end

        append!(meta, DataFrame("lon"  => metadata(df, "lon"),
                                "lat"  => metadata(df, "lat"),
                                "time" => metadata(df, "time"),
                                "cast" => metadata(df, "cast")))

        df.lon  .= metadata(df, "lon")
        df.lat  .= metadata(df, "lat")
        df.time .= metadata(df, "time")
        df.cast .= metadata(df, "cast")
        append!(data, df; cols=:union)
    end

    isempty(data) && return (data, meta)

    if output_format == "DataFrame"
        tv = hasproperty(data, temp_var) ? temp_var : (temp_var === :th ? :te : :th)
        da = DataFrame("cast" => data.cast, "lon" => data.lon, "lat" => data.lat,
                       "time" => data.time, "depth" => data.de, "temp" => data[!, tv])
        colmetadata!(da, :temp,  "variable", string(tv); style=:note)
        colmetadata!(da, :depth, "variable", "de";       style=:note)
        return (da, meta)
    else
        return (data, meta)
    end
end

### Query and helper methods

function list_of_transects_AOML()
    ["AX01","AX02","AX04","AX07","AX08","AX10","AX18","AX20","AX25","AX32","AX90","AX97",
    "AXCOAST","AXWBTS","MX01","MX02","MX04"]
end

function list_of_cruises_AOML(transect)
    files=list_files_on_server(transect)
    DataFrame("File"=>files)
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
    XBT.download_AOML_cruise(transect="AX08",file="ax80102_qc.tgz")

```
using OceanRobots

list=XBT.list_transects("AOML")

transect="AX08"
list1=XBT.list_files_on_server(transect)
list2=XBT.get_url_to_transect(transect)

files=XBT.download_AOML_cruise(transect,"ax80102_qc.tgz")
path=dirname(files[1])
(data,meta)=XBT.read_NOAA_XBT(path)
```
"""
function download_AOML_cruise(transect="AX08",file="ax80102_qc.tgz")
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

"""
    download_all_AOML(;path="XBT_AOML",quick_test=false)

Download XBT data files from AOML site.
"""
function download_all_AOML(;path="XBT_AOML",quick_test=false)
    !ispath(path) ? mkdir(path) : nothing
    lst_AOML=query(XBTtransect,"AOML").transect
    lst_AOML=(quick_test ? lst_AOML[1:2] : lst_AOML)
    for transect in lst_AOML
        println(transect)
        lst_AOML_files=DataFrame("transect"=>String[],"cruise"=>Int[],"file"=>String[])
        df=list_files_on_server(transect)
        for cr in 1:size(df,1)
            files=download_AOML_cruise(transect,df[cr])

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

"""
    scan_AOML()

"""
function scan_AOML()
    source="AOML"
    list=query(XBTtransect,source)
    data=DataFrame()
    for transect in list
        cruises=list_of_cruises(transect,source=source)
        append!(data,cruises)
    end
    data.source.=source
    data
end

"""
    scan_XBT_AOML(ii=0,jj=0; path="XBT_AOML")

- if `ii==0` then list all sections
- if only `ii` is specified, then list of files for section `ii`
- if `ii` & `jj` are specified, then list files in cruise `jj` of section `ii`
"""
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
    list=scan_XBT_AOML(ii,jj,path=path)
    read_XBT_AOML(list; path=path) 
end

function read_XBT_AOML(list4::AbstractDataFrame; path="XBT_AOML")  
    transect=list4[1,:transect]
    cruise=string(list4[1,:cruise])
    subfolder=transect*"_"*cruise

    path2=joinpath(path,subfolder)
#    T_all,meta_all=read_NOAA_XBT(path2,output_format="legacy")
#    XBTtransect("AOML","AOML",cruise,transect,path2,[T_all,meta_all,subfolder],DataFrame())
    data,meta=read_NOAA_XBT(path2)
    XBTtransect("AOML","AOML",cruise,transect,path2,data,meta)
end

### helper methods

function valid_XBT_AOML(;path="XBT_AOML",verbose=true)
    list1=scan_XBT_AOML(path=path)
    df=DataFrame()
    for ii in 1:length(list1)
        list2=scan_XBT_AOML(ii,path=path)
        for jj in 1:length(list2)
            list4=scan_XBT_AOML(ii,jj,path=path)
            transect=list4[1,:transect]
            cruise=string(list4[1,:cruise])
            subfolder=transect*"_"*cruise
            test=try
                read_XBT_AOML(ii,jj,path=path)
                true
            catch
                @warn "failed to read "*subfolder
                false
            end
            append!(df,DataFrame("transect"=>transect,
                "cruise"=>cruise,"subfolder"=>subfolder,"test"=>test))
        end
    end
    ok=findall(df.test)
    no=findall((!).(df.test))
    println("valid cruises      = "*string(length(ok)))
    println("unreadable cruises = "*string(length(no)))
    df[ok,:]
end

### interpolate to standard depth (AOML format -> SIO format)

"""
     to_standard_depth(xbt)

- interpolate to `SIO`'s standard depth levels.
- output as a `SIO`-formatted `XBTtransect`.

```
using OceanRobots, DataFrames
xbt=read(XBTtransect(),source="AOML",transect="AX08",cr=1);
xbt2=XBT.to_standard_depth(xbt);

using CairoMakie
x=groupby(xbt.data,:cast)[1]; lines(x.temp,-x.depth)
x=groupby(xbt2.data,:cast)[1]; scatter!(x.temp,-x.depth,color=:red)
```     
"""
function to_standard_depth(xbt2)
    xbt2.source=="AOML" ? nothing : error("option not available")
    zz=XBT.dep
    nz=length(zz)
    gdf=groupby(xbt2.data,:time) #group by profile
    np=length(gdf)
    arr=zeros(np,nz)
    for pp in 1:np
        x,y=(gdf[pp][:,:depth],gdf[pp][:,:temp])
        interp_linear = linear_interpolation(x,y,extrapolation_bc=NaN)
        arr[pp,:].=interp_linear(zz)
    end
    lon,lat,tim=[[df[1,val] for df in gdf] for val in (:lon,:lat,:time)]
    meta_all=[lon[:] lat[:] tim[:] 1:length(tim)]

    (np,nz)=size(arr)
    lon=lon*ones(1,nz)
    lat=lat*ones(1,nz)
    t=repeat(tim,1,nz)
    c=repeat(1:np,1,nz)
    d=ones(np,1)*transpose(zz)

    ii=findall((!isnan).(arr))
    data=DataFrame("cast"=>c[ii],"lon"=>lon[ii],"lat"=>lat[ii],
        "depth"=>d[ii],"time"=>t[ii],"temp"=>arr[ii])
    meta=DataFrame("lon"=>meta_all[:,1],"lat"=>meta_all[:,2],
        "time"=>meta_all[:,3],"profile_number"=>meta_all[:,4])

    XBTtransect("AOML","SIO",xbt2.mission,xbt2.transect,xbt2.folder,
        sort(data,:time),sort(meta,:time))
end

## IMOS data (Australia)

function list_of_transects_IMOS()
    url="https://thredds.aodn.org.au/thredds/catalog/IMOS/SOOP/SOOP-XBT/DELAYED/catalog.xml"
    fil=joinpath(tempdir(),"list_of_transects_IMOS.csv")
    if isfile(fil)
        CSV.read(fil,DataFrame)
    else
        x=THREDDS.parse_catalog(url,false)[2]
        x1=[split(y,"/")[1] for y in x]
        for i in findall(occursin.("Line_",x))
            x1[i]=split(x[i],"_")[2]
    #        x1[i]=split(split(x[i],"_")[2],"_")[1]
        end
        x2=[dirname(url)*"/"*y for y in x]
        df=DataFrame("transect"=>String.(x1),"url"=>x2)
        CSV.write(fil,df)
        df
    end
end

function list_of_cruises_IMOS(transect)
    list_files_path=joinpath(tempdir(),"files_"*transect*".csv")
    if !isfile(list_files_path)
        list_IMOS=list_of_transects_IMOS()
        ii=findall(list_IMOS.transect.==transect)[1]
        list_files=THREDDS.parse_catalog(list_IMOS.url[ii],true)[1]
        CSV.write(list_files_path,DataFrame("files"=>list_files))
    end
    list_files=CSV.read(list_files_path,DataFrame).files

    urls=["https://thredds.aodn.org.au/thredds/fileServer/"*f for f in list_files]
    years=[parse(Int64,split(f,"/")[end-1]) for f in list_files]

    groupby(DataFrame("transect" => fill(transect,length(years)), 
        "cruise" => (transect*"_").*string.(years), 
        "year" => years, "url" => urls),:cruise)
#    path1=joinpath(tempdir(),transect*"_"*cruise)
end

"""
    download_IMOS_cruise(files; path=tempdir(), verbose=false)

"""
function download_IMOS_cruise(files; path=tempdir(), verbose=false)
    path1=joinpath(path,files[1,:cruise])
    isdir(path1) ? nothing : mkdir(path1)
    for i in 1:size(files,1)
        url=files[i,:url]
        fil=joinpath(path1,basename(url))
        verbose ? (isfile(fil) ? nothing : println(basename(url))) : nothing
        try
            isfile(fil) ? nothing : Downloads.download(url,fil)
        catch
            println("FAILED to download "*fil)
        end
    end
    [joinpath(path1,basename(url)) for url in files.url]
end

"""
    download_IMOS_transect(; path=tempname(),transect="PX05")

"""
function download_IMOS_transect(; path=tempname(),transect="PX05")
    ispath(path) ? nothing : mkdir(path)
    cruises=list_of_cruises(transect,source="IMOS")
    for cr in cruises
        println(cr)
        download_IMOS_cruise(cr; path=path)
    end
    path
end

"""
    scan_IMOS()

"""
function scan_IMOS()
    source="IMOS"
    list=query(XBTtransect,source)
    data=DataFrame()
    for transect in list
        cruises=list_of_cruises(transect,source=source)
        for cruise in cruises
            append!(data,cruise)
        end
    end
    data.source.="IMOS"
    data
end

"""
    read_IMOS_XBT(df)

"""
function read_IMOS_XBT(df)
    data=DataFrame("temp"=>Float64[], "depth"=>Float64[], 
        "time"=>DateTime[], "lon"=>Float64[], "lat"=>Float64[])
    meta=DataFrame()
    for f in df.file
#        println(f)
        ds=Dataset(f)
        (lo,la,tim)=(ds["LONGITUDE"][1],ds["LATITUDE"][1],ds["TIME"][1])
        cruise=split(f,"/")[end-1]
        append!(meta,DataFrame("lon"=>lo,"lat"=>la,"time"=>tim,"cruise"=>cruise))
        temp=ds["TEMP"][:]
        dep=ds["DEPTH"][:]
        ii=setdiff(1:length(dep),findall(temp.==temp[end]))
        ni=length(ii)
        append!(data,DataFrame("temp"=>temp[ii], "depth"=>dep[ii],
            "time"=>fill(tim,ni), "lon"=>fill(lo,ni), "lat"=>fill(la,ni)))
    end
    data,meta
end

end
