
module THREDDS

using Downloads, LightXML

"""
    parse_catalog(url,recursive=true)

Starting from an `xml` (not `html`) `thredds` catalog look for both subfolders and files;
they are identified based on the `href` and `urlPath` attributes respectively. If `recursive`
is set to `true` then go down in subfolders and do the same until only files are found; in this
case the returned `folders` should be empty and `files` can be extensive.

For more on `thredds` servers, see <https://www.unidata.ucar.edu/software/tds/current/catalog/>.

```
url="https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/long_timeseries/WHOTS/catalog.xml"
#url="https://dods.ndbc.noaa.gov/thredds/catalog/data/catalog.xml"
#url="https://dods.ndbc.noaa.gov/thredds/catalog/oceansites-tao/catalog.xml"
#url="https://dods.ndbc.noaa.gov/thredds/catalog/tao-ctd/catalog.xml"
#url="https://dods.ndbc.noaa.gov/thredds/catalog/hfradar/catalog.xml"
#url="https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/catalog.xml"

files,folders=parse_catalog(url)
```
"""
function parse_catalog(url,recursive=true)
    fil=Downloads.download(url)

    xdoc=parse_file(fil);
    xroot=root(xdoc);
    e1=xroot["dataset"][1];
    e2=collect(child_elements(e1));

    files=String[]
    folders=String[]
    for i in e2
        j=attributes_dict(i)
        if haskey(j,"href")
            push!(folders,j["href"])
        elseif haskey(j,"urlPath")
            push!(files,j["urlPath"])
        end
    end

    if recursive
        while !isempty(folders)
            tmp=pop!(folders)
            url0=dirname(url)*"/"*tmp
            tmp1,tmp2=parse_catalog(url0)
            [push!(files,j) for j in tmp1]
        end
    end

    return files,folders
end

"""
    parse_catalog_NOAA_buoy(ID=44013)

Use `parse_catalog_NOAA_buoy` to build `files_year,files_url` lists for buoy `ID`.   
"""
function parse_catalog_NOAA_buoy(ID=44013)
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

end #module THREDDS
