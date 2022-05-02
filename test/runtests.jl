using OceanRobots
using Test

@testset "OceanRobots.jl" begin

    url="https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/long_timeseries/WHOTS/catalog.xml"
    files,folders=THREDDS.parse_catalog(url)

    @test isa(files[1],String)
    @test isempty(folders)

    list_files=GDP.list_files()
    fil=GDP.download(list_files,1)
    ds=GDP.read(fil)

    @test haskey(ds,"ve")

end
