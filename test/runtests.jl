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

    oceansites_index=OceanSites.index()
    @test !isempty(oceansites_index)

    data,units=OceanSites.read_WHOTS()
    @test !isempty(data.TIME)
    @test !isempty(units.TIME)

    file="DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc"
    data=OceanSites.read(file,:lon,:lat,:time,:TEMP)
    @test !isempty(data.TEMP)

end
