using OceanRobots, DataFrames, CairoMakie
using Test

@testset "SurfaceDrifter" begin

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

end

@testset "OceanSites" begin

    oceansites_index=OceanSites.index()
    @test !isempty(oceansites_index)

    b=read(OceanSite(),:WHOTS)
    f3=plot(b,DateTime(2005,1,1),DateTime(2005,2,1))
    @test isa(f3,Figure)

    file="DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc"
    data=OceanSites.read_variables(file,:lon,:lat,:time,:TEMP)
    @test !isempty(data.TEMP)

end

@testset "ArgoFloat" begin
    b=read(ArgoFloat(),wmo=2900668)
    @test isa(b,ArgoFloat)

    f1=plot(b,option=:samples)
    @test isa(f1,Figure)
end

@testset "Glider_Spray" begin
    b=read(Glider_Spray(),"GulfStream.nc",1)
    @test isa(b,Glider_Spray)
    f3=plot(b)
    @test isa(f3,Figure)

    #specific plot that currently cannot be replicated with default format
	OceanRobotsMakieExt = Base.get_extension(OceanRobots, :OceanRobotsMakieExt);
	x=read(Glider_Spray(),"GulfStream.nc",1,-1);
	gdf=Glider_Spray_module.groupby(x.data,:ID);
	fig=OceanRobotsMakieExt.plot_glider_Spray_v1(x.data,gdf,1)
    @test isa(fig,Figure)
end

@testset "Glider_EGO" begin
    b=read(Glider_EGO(),1)
    @test isa(b,Glider_EGO)
    f3=plot(b)
    @test isa(f3,Figure)
end

@testset "Glider_AOML" begin
    file=Glider_AOML_module.sample_file()
    Glider_AOML_module.download_AOML(file)
    @test isfile(file)

    data=read(Glider_AOML(),file)
    @test isa(data,Glider_AOML)

    f=plot(data)
    @test isa(f,Figure)
end

@testset "NOAAbuoy" begin
    allstations=OceanRobots.query(NOAAbuoy)
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
end

@testset "OceanOPS" begin
    list_Argo=OceanOPS.get_list(:Argo)
    @test isa(list_Argo,Vector)

    tmp=OceanOPS.get_platform(list_Argo[1000])
    @test tmp.status=="OPERATIONAL"

    tmp=OceanOPS.get_list_pos(:Drifter)
    @test isa(tmp.lon,Vector)

    tmp=OceanOPS.list_platform_types()
    @test isa(tmp.name,Vector)
end

@testset "CCHDO" begin
#    list1=OceanRobots.query(ShipCruise)
#    @test isa(list1,Vector)

    ID="33RR20160208"
    path=CCHDO.download(ID)
    @test ispath(path)

    cruise=read(ShipCruise(),ID)
    @test isa(cruise,ShipCruise)

    fig=plot(cruise)
    @test isa(fig,Figure)
end

@testset "XBT" begin
    xbt=read(XBTtransect(),source="IMOS",transect="IX21",cruise="2006")
    fig=plot(xbt)
    @test isa(fig,Figure)

    list=OceanRobots.query(XBTtransect,"SIO")
    cruises=XBT.list_of_cruises("PX05")
    
    xbt=read(XBTtransect(),source="SIO",transect="PX05",cruise="PX05_0910")
    fig=plot(xbt)
    @test isa(fig,Figure)

    ##

    list=OceanRobots.query(XBTtransect,"AOML")
    list1=XBT.list_files_on_server("AX08")
    list2=XBT.get_url_to_transect("AX08")

    xbt=read(XBTtransect(),source="AOML",transect="AX08",cr=1)
    fig=plot(xbt)
    @test isa(fig,Figure)

    xbt2=XBT.to_standard_depth(xbt)
    show(xbt2)
    @test isa(xbt2,XBTtransect)

    ##

    path0=tempname()
    mkdir(path0)
    XBT.download_all_AOML(path=path0,quick_test=true)
    @test isfile(joinpath(path0,"list_AX01.csv"))

    df0=XBT.valid_XBT_AOML(path=path0)
    xbt=XBT.read_XBT_AOML(df0.subfolder[1],path=path0)
    @test isa(xbt,XBTtransect)
end

