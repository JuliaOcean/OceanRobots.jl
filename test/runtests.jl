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
    @test isa(ds,OceanRobots.NCDataset)

end
