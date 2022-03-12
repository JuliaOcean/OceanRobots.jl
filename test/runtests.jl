using OceanRobots
using Test

@testset "OceanRobots.jl" begin

    url="https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/long_timeseries/WHOTS/catalog.xml"
    files,folders=parse_thredds_catalog(url)

    @test isa(files[1],String)
    @test isempty(folders)

    list_files=drifters_hourly_files()
    fil=drifters_hourly_download(list_files,1)
    ds=drifters_hourly_read(fil)

    @test isa(ds["longitude"],OceanRobots.NCDatasets.CFVariable)


    fil="https://gaelforget.github.io/OceanRobots.jl/dev/examples/Argo_float_files.csv"
    Argo_float_files(fil)

    ii=10000
    list_files=Argo_float_files()
    Argo_float_download(list_files,ii)
    ftp="ftp://usgodae.org/pub/outgoing/argo/dac/"
    Argo_float_download(list_files,ii,"meta",ftp)

    wmo=list_files[ii,"wmo"]
    path=joinpath(tempdir(),"Argo_DAC_files",list_files[ii,"folder"])
    fil=joinpath(path,string(wmo),string(wmo)*"_meta.nc")
    @test isfile(fil)
end
