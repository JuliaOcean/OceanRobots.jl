
if !isdefined(Main,:xbt1)
    using OceanRobots, DataFrames, Interpolations, CairoMakie
    xbt1=read(XBTtransect(),source="SIO",transect="PX05",cr=1)

    begin
        using MeshArrays, Shapefile, DataDeps
        pol_file=demo.download_polygons("ne_110m_admin_0_countries.shp")
        pol=MeshArrays.read_polygons(pol_file)
    end
end

xbt2=read(XBTtransect(),source="AOML",transect="AX01",cr=2)

#fix : eliminate outliers in "AX01",cr=1
#a=xbt2.data[1][:,:te]; a[a.>20].=NaN; xbt2.data[1][:,:te].=a;

function to_standard_depth(xbt2)
    xbt2.source=="AOML" ? nothing : error("option not available")
    zz=-XBT.dep
    nz=length(zz)
    gdf=groupby(xbt2.data[1],:time) #group by profile
    np=length(gdf)
    arr=zeros(np,nz)
    for pp in 1:np
        x,y=(gdf[pp][:,:pr],gdf[pp][:,:te])
        interp_linear = linear_interpolation(x,y,extrapolation_bc=NaN)
        arr[pp,:].=interp_linear(zz)
    end
    lon,lat,tim=[[df[1,val] for df in gdf] for val in (:lon,:lat,:time)]
    meta_all=[lon[:] lat[:] tim[:] 1:length(tim)]
    #[arr,meta_all,xbt2.data[3]]
    XBTtransect("AOML","SIO",xbt2.ID,[arr,meta_all,xbt2.data[3]],xbt2.path)
end

xbt2_std_depth=to_standard_depth(xbt2)
plot(xbt2_std_depth,pol=pol)