
module Spray_Glider

function check_for_file_Spray_Glider(args...)
    if !isempty(args)
        url1="http://spraydata.ucsd.edu/media/data/binnednc/"*basename(args[1])
        pth0=dirname(args[1])
        isempty(pth0) ? pth1=joinpath(tempdir(),"tmp_glider_data") : pth1=pth0
        !isdir(pth1) ? mkdir(pth1) : nothing
        fil1=joinpath(pth1,basename(args[1]))
        !isfile(fil1) ? Downloads.download(url1,fil1) : nothing
    else
        pth0=joinpath(tempdir(),"tmp_glider_data")
        glob("*.nc",pth0)
    end
end

end #module Spray_Glider

##

module NOAA

function get_NWP_NOAA(x)
    url0="https://www.ndbc.noaa.gov/data/realtime2/"
    pth0=pathof(x)

    for f in x.inputs["stations"]
        fil="$f.txt"
        url1=url0*fil
        fil1=joinpath(pth0,fil)
        Downloads.download(url1,fil1)
    end
    
    return x
end

end #module NOAA

##

module GDP

"""
    drifters_hourly_files()

Get list of drifter files from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
or the corresponding webpage 
<https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/>.
"""
function drifters_hourly_files()
    list_files=DataFrame("folder" => [],"filename" => [])
    ftp=FTP("ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/")
    tmp=readdir(ftp)
    append!(list_files,DataFrame("folder" => "","filename" => tmp))
    list_files
end

# 6-hourly interpolated data product
# https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:AOML-GDP
# url="https://www.ncei.noaa.gov/thredds-ocean/fileServer/aoml/gdp/1982/drifter_7702192.nc"

"""
    drifters_hourly_download(list_files,ii=1)

Download one drifter file from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
or the corresponding webpage 
<https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/>.

```
list_files=drifters_hourly_files()
fil=drifters_hourly_download(list_files,1)
```
"""
function drifters_hourly_download(list_files,ii=1)
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
    drifters_hourly_read(filename::String)

Download one drifter file from NOAA ftp server     
<ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/>
or the corresponding webpage 
<https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/>.

```
list_files=drifters_hourly_files()
fil=drifters_hourly_download(list_files,1)
ds=drifters_hourly_read(fil)
```
"""
drifters_hourly_read(filename::String) = Dataset(filename)

end #module GDP

