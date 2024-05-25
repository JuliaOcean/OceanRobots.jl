using OceanRobots, ClimateModels, DataFrames, ArgoData, CairoMakie
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

    #

    ArgoFiles.scan_txt("ar_index_global_prof.txt",do_write=true)
    @test isfile(joinpath(tempdir(),"ar_index_global_prof.csv"))

    ArgoFiles.scan_txt("argo_synthetic-profile_index.txt",do_write=true)
    @test isfile(joinpath(tempdir(),"argo_synthetic-profile_index.csv"))

    wmo=2900668
    files_list=GDAC.files_list()
    fil=ArgoFiles.download(files_list,wmo)
    arr=ArgoFiles.read(fil)
    T_std,S_std=ArgoFiles.interp_z_all(arr)
	spd=ArgoFiles.speed(arr)
    @test isapprox(spd.speed_mean,0.06,atol=0.01)

    OceanRobotsMakieExt=Base.get_extension(OceanRobots, :OceanRobotsMakieExt)
    f1=OceanRobotsMakieExt.plot_samples(arr,wmo)
    f2=OceanRobotsMakieExt.plot_TS(arr,wmo)
    @test isa(f1,Figure)

#
    fil=check_for_file("Glider_Spray","GulfStream.nc")
    @test isfile(fil)

    df=GliderFiles.read(fil)
    @test isa(df,DataFrame)

    ##

    parameters=Dict("stations" => [41046, 44065])		
	MC=ModelConfig(model=NOAA.download,inputs=parameters)
	setup(MC)
	launch(MC)
    df=NOAA.read(MC,41046)
    @test isa(df,DataFrame)

    ##

    buoyID=44013
    years=1985:1986

    NOAA.download_historical_txt(buoyID,years)
    df=NOAA.read_historical_txt(buoyID,years[1])
    @test isa(df,DataFrame)

    df=NOAA.read_historical_monthly()
    @test isa(df,DataFrame)

    files_year,files_url=THREDDS.parse_catalog_NOAA_buoy()
    @test !isempty(files_url)

    list_Argo=OceanOPS.get_list(:Argo)
    @test isa(list_Argo,Vector)

    tmp=OceanOPS.get_platform(list_Argo[1000])
    @test tmp.status=="OPERATIONAL"

    tmp=OceanOPS.get_list_pos(:Drifter)
    @test isa(tmp.lon,Vector)
end
