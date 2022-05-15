

using Statistics, DataFrames

"""
    monthly_buoy_data(ID=44013,years=1985:2021)

Compute monthly mean time series for a few select quantities for .

- units : https://www.ndbc.noaa.gov/measdes.shtml
- station page / main : https://www.ndbc.noaa.gov/station_page.php?station=44013
- station page / historical data : https://www.ndbc.noaa.gov/station_history.php?station=44013
- thredds server : https://dods.ndbc.noaa.gov/thredds/catalog/data/stdmet/44013/catalog.html

```
IDs=[44013, 44029, 44030, 44090, "bhbm3"]

ID=IDs[1]
years,_=parse_buoy_data_thredds(ID)
mdf=monthly_buoy_data(ID,years)
gmdf=groupby(mdf,"MM")

#fig1
lines(mdf.YY+mdf.MM/12,mdf.ATMP,label="ATMP")
lines!(mdf.YY+mdf.MM/12,mdf.WTMP,label="WTMP")
current_figure()

#fig2
fig=Figure(); ax=Axis(fig[1,1])
[lines!(ax,gmdf[m].YY,gmdf[m].WTMP) for m in 1:12] 
fig
```
"""
function monthly_buoy_data(ID=44013,years=1985:2021)
    #download_buoy_data_txt(ID,years)

    mdf=DataFrame(  YY=Int[],MM=Int[],ATMP=Float64[],
                    WTMP=Float64[],WSPD=Float64[],PRES=Float64[])
    for y in years
        println(y)
        df=read_buoy_data_nc(ID,y)

        gdf=groupby(df,"MM")
        df2=combine(gdf) do df
            try
                (ATMP=mean(skipmissing(df.ATMP)) , WTMP=mean(skipmissing(df.WTMP)) , 
                WSPD=mean(skipmissing(df.WSPD)) , PRES=mean(skipmissing(df.PRES)))
                #(ATMP=median(skipmissing(df.ATMP)) , WTMP=median(skipmissing(df.WTMP)) , 
                #WSPD=median(skipmissing(df.WSPD)) , PRES=median(skipmissing(df.PRES)))
            catch
                (ATMP=NaN , WTMP=NaN , WSPD=NaN , PRES=NaN)
            end    
        end
        df2.YY.=y
        append!(mdf,df2)
    end

    sort!(mdf, [:YY, :MM])
    return mdf
end

##

using Dates, NCDatasets, OceanRobots

"""
    parse_buoy_data_thredds(ID)

```
ID=44013
files_year,files_url=parse_buoy_data_thredds(ID)
```
"""
function parse_buoy_data_thredds(ID)
    url0="https://dods.ndbc.noaa.gov/thredds/catalog/data/stdmet/"
    url=url0*"$(ID)/catalog.xml"
    tmp=THREDDS.parse_catalog(url)

    ii=findall( length.(tmp[1]) .> 3)
    tmp1=tmp[1][ii]
    ii=findall( [jj[end-2:end]==".nc" for jj in tmp1])
    tmp2=tmp1[ii]

    yy=[parse(Int,jj[end-6:end-3]) for jj in tmp2]
    ii=findall(yy.<9999)
    files_url=[url0*jj for jj in tmp2[ii]]
    files_year=sort(yy[ii])

    return files_year,files_url
end

function read_buoy_data_nc(ID,y)
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

##

using Downloads, CSV, DataFrames

"""
    download_buoy_data_txt(ID,years)

Download text files to temporary folder.

```
years=1985:2021
buoyID=44013
download_buoy_data_txt(buoyID,years)
```
"""
function download_buoy_data_txt(ID,years)
    for y in years
        fil0="$(ID)h$(y).txt"
        url0="https://www.ndbc.noaa.gov/view_text_file.php?filename=$(fil0).gz&dir=data/historical/stdmet/"
        pth0=joinpath(tempdir(),"NDBC"); !isdir(pth0) ? mkdir(pth0) : nothing
        fil1=joinpath(pth0,fil0)
        !isfile(fil1) ? Downloads.download(url0,fil1) : nothing
    end
end

function read_buoy_data_txt(ID,y)
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
