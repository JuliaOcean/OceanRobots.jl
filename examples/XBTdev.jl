
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

xbt2_std_depth=XBT.to_standard_depth(xbt2)
plot(xbt2_std_depth,pol=pol)