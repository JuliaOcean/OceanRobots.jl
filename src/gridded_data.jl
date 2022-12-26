

module podaac_sla

using NCDatasets, Dates, DataStructures

url0="https://podaac-opendap.jpl.nasa.gov/opendap/allData/merged_alt/L4/cdr_grid/"
path0=joinpath(pwd(),"SEA_SURFACE_HEIGHT_ALT_GRIDS_L4_2SATS_5DAY_6THDEG_V_JPL2205")*"/"
##

function get_grid(;url0=url0,
        range_lon=360.0.+(-35.0,-22),
        range_lat=(34.0,45),
        )
    url=url0*"ssh_grids_v2205_1992101012.nc"
    ds=Dataset(url)
    lon=Float64.(ds["Longitude"][:])
    lat=Float64.(ds["Latitude"][:])

    ii=findall( (lon.>range_lon[1]) .& (lon.<range_lon[2]) )
    jj=findall( (lat.>range_lat[1]) .& (lat.<range_lat[2]) )

    (lon=lon,lat=lat,ii=ii,jj=jj,nt=2190,url0=url0)
end

function file_name(n)
    d0=Date("1992-10-05")
    d=d0+Dates.Day(n*5)
    dtxt=string(d)
    "ssh_grids_v2205_"*dtxt[1:4]*dtxt[6:7]*dtxt[9:10]*"12.nc"
end

function read_slice(url,gr)
    ds=Dataset(url)
    SLA=ds["SLA"][gr.ii,gr.jj,1]
    SLA[ismissing.(SLA)].=NaN
    Float64.(SLA)
end

"""
    podaac_sla.subset()

For download directions, see [this site](https://podaac.jpl.nasa.gov/dataset/MERGED_TP_J1_OSTM_OST_CYCLES_V51)

```
podaac_sla.subset()
```
"""
function subset(;
    url0="SEA_SURFACE_HEIGHT_ALT_GRIDS_L4_2SATS_5DAY_6THDEG_V_JPL2205/",
    username="unknown",
    password="unknown",
    range_lon=360.0.+(-35.0,-22),
    range_lat=(34.0,45),
    save_to_file=true,
    )
    
    gr=get_grid(url0=url0, range_lon=range_lon,range_lat=range_lat)
    i0=1; i1=gr.nt    
    data=zeros(length(gr.ii),length(gr.jj),i1-i0+1)
    for n=i0:i1
        mod(n,100)==0 ? println(n) : nothing
        data[:,:,n-i0+1]=read_slice(url0*file_name(n),gr)
    end

    if save_to_file
        fil=joinpath(tempdir(),"sla_$(i0)_$(i1).nc")
        Dataset(fil,"c",attrib = OrderedDict("title" => "Azores Regional Subset")) do ds
            defVar(ds,"SLA",data,("lon","lat","time"), attrib = OrderedDict(
                "units" => "m", "long_name" => "Sea Level Anomaly",
                "comments" => "source is https://sealevel.nasa.gov/data/dataset/?identifier=SLCP_SEA_SURFACE_HEIGHT_ALT_GRIDS_L4_2SATS_5DAY_6THDEG_V_JPL2205_2205")),
            defVar(ds,"lon",gr.lon[gr.ii],("lon",), attrib = OrderedDict(
                "units" => "degree", "long_name" => "Longitude"))
            defVar(ds,"lat",gr.lat[gr.jj],("lat",), attrib = OrderedDict(
                "units" => "degree", "long_name" => "Latitude"))
            end
        println("File name :")
        fil
    else
        data
    end

end

end #module podaac_sla

module cmems_sla

using NCDatasets, URIs, DataStructures

"""
    cmems_sla.subset()

For download directions, see [this site](https://marine.copernicus.eu)

```
cmems_sla.subset(username=username,password=password)
```
"""
function subset(;
    var="cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D",
    username="unknown",
    password="unknown",
    range_lon=(-35.0,-22),
    range_lat=(34.0,45),
    save_to_file=true,
    )

    url="https://my.cmems-du.eu/thredds/dodsC/"*var
    url2 = string(URI(URI(url),userinfo = string(username,":",password)))
    ds = NCDataset(url2)

    lon=ds["longitude"][:]
    lat=ds["latitude"][:]

    ii=findall( (lon.>range_lon[1]) .& (lon.<range_lon[2]) )
    jj=findall( (lat.>range_lat[1]) .& (lat.<range_lat[2]) )

    SSH=ds["sla"]

    data = SSH[ii,jj,:]
    if save_to_file
        fil=tempname()
        Dataset(fil,"c",attrib = OrderedDict("title" => "Azores Regional Subset")) do ds
            defVar(ds,"SLA",data,("lon","lat","time"), attrib = OrderedDict(
                "units" => "m", "long_name" => "Sea Level Anomaly",
                "comments" => "source is https://my.cmems-du.eu")),
            defVar(ds,"lon",lon[ii],("lon",), attrib = OrderedDict(
                "units" => "degree", "long_name" => "Longitude"))
            defVar(ds,"lat",lat[jj],("lat",), attrib = OrderedDict(
                "units" => "degree", "long_name" => "Latitude"))
            end
        println("File name :")
        fil
    else
        data
    end

end

end #module cmems_sla
