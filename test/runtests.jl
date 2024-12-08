using OceanRobots, DataFrames, CairoMakie
using Test

@testset "OceanRobots.jl" begin

    list1=OceanRobots.query(SurfaceDrifter)
    @test isa(list1,Vector)

    url="https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/long_timeseries/WHOTS/catalog.xml"
    files,folders=OceanRobots.THREDDS.parse_catalog(url)

    @test isa(files[1],String)
    @test isempty(folders)

    b=read(SurfaceDrifter(),ID=300234065515480)
    @test haskey(b.data,"ve")

    f3=plot(b)
    @test isa(f3,Figure)

    #

    b=read(CloudDrift(),"")
    @test isa(b,CloudDrift)

    file=GDP_CloudDrift.CloudDrift_subset_download()
    GM=OceanRobots.Gulf_of_Mexico.example_prep(file=file)
    @test isa(GM.drifters_real,DataFrame)

    #

    oceansites_index=OceanSites.index()
    @test !isempty(oceansites_index)

    b=read(OceanSite(),:WHOTS)
    f3=plot(b,DateTime(2005,1,1),DateTime(2005,2,1))
    @test isa(f3,Figure)

    file="DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc"
    data=OceanSites.read_variables(file,:lon,:lat,:time,:TEMP)
    @test !isempty(data.TEMP)

    #

    b=read(ArgoFloat(),wmo=2900668)
    @test isa(b,ArgoFloat)

    f1=plot(b,option=:samples)
    @test isa(f1,Figure)
        
    #

    b=read(Gliders(),"GulfStream.nc")
    @test isa(b,Gliders)
    f3=plot(b,1)
    @test isa(f3,Figure)

    ##

    allstations=query(NOAAbuoy)
    @test isa(allstations,Vector)

    metstations=NOAA.list_realtime(ext=:txt)
    stations=metstations[1:200:end]
    ids=NOAA.download(stations)

    b=read(NOAAbuoy(),41044)
    plot(b,"PRES")
    @test isa(b,NOAAbuoy)

    ##

    buoyID=44013
    years=1985:1986

    NOAA.download_historical_txt(buoyID,years)
    df=NOAA.read_historical_txt(buoyID,years[1])
    @test isa(df,DataFrame)

    b=read(NOAAbuoy_monthly(),buoyID,years)
    @test isa(b,NOAAbuoy_monthly)

    a=read(NOAAbuoy_monthly(),44013)
    b=plot(a)
    @test isa(b,Figure)

    files_year,files_url=OceanRobots.THREDDS.parse_catalog_NOAA_buoy()
    @test !isempty(files_url)

    ##

    list_Argo=OceanOPS.get_list(:Argo)
    @test isa(list_Argo,Vector)

    tmp=OceanOPS.get_platform(list_Argo[1000])
    @test tmp.status=="OPERATIONAL"

    tmp=OceanOPS.get_list_pos(:Drifter)
    @test isa(tmp.lon,Vector)

    tmp=OceanOPS.list_platform_types()
    @test isa(tmp.name,Vector)

    ##

    list1=OceanRobots.query(ShipCruise)
    @test isa(list1,Vector)

    ID="33RR20160208"
    path=CCHDO.download(ID)
    @test ispath(path)

    cruise=read(ShipCruise(),ID)
    @test isa(cruise,ShipCruise)

    fig=plot(cruise)
    @test isa(fig,Figure)

end
