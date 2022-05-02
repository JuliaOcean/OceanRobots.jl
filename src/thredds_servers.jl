
module THREDDS

using Downloads, LightXML

"""
    parse_catalog(url,recursive=true)

Starting from an `xml` (not `html`) _thredds catalog_ look for both subfolders and files;
they are identified based on the `href` and `urlPath` attributes respectively. If `recursive`
is set to `true` then go down in subfolders and do the same until only files are found; in this
case the returned `folders` should be empty and `files` can be extensive.

See <https://www.unidata.ucar.edu/software/tds/current/catalog/> for more on `thredds`.

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

end #module THREDDS
