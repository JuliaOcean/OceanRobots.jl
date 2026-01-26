
## Glider_Spray

function convert_time(tim)
	y1=Dates.year(tim[1])
	y1.+(tim.-Dates.DateTime(y1))./Dates.Millisecond(1)/1000/86400/365.25
end

"""
    plot_glider_Spray_v1(df,gdf,ID;size=(900,600),pol=missing)

Read a Spray Glider file (alternative to `plot_glider_default`).

```
begin
	using OceanRobots, CairoMakie
	OceanRobotsMakieExt = Base.get_extension(OceanRobots, :OceanRobotsMakieExt);
	x=read(Glider_Spray(),"GulfStream.nc",1,-1);
	gdf=Glider_Spray_module.groupby(x.data,:ID);
	OceanRobotsMakieExt.plot_glider_Spray_v1(gl_Spray_v1.data,gdf,1)
end
```
"""
function plot_glider_Spray_v1(df,gdf,ID;size=(900,600),pol=missing)
	gdf_ID=gdf[ID]
	f=Figure(size=size)
#	xlims=rng(df.lon,mini=-180,maxi=180)
#	ylims=rng(df.lat,mini=-90,maxi=90)
	xlims=xrng(df.lon)
	ylims=yrng(df.lat)
	a_traj=Axis(f[1,1],title="Positions",limits = (xlims, ylims))
	p=scatter!(a_traj,df.lon,df.lat,markersize=1)
	p=scatter!(a_traj,gdf_ID.lon,gdf_ID.lat,color=:red)
	ismissing(pol) ? nothing : lines!(pol,color = :black, linewidth = 0.5)

	tim=DateTime.(gdf_ID.time[:])
	tim=convert_time(tim) #this should not be needed (?)

	a_uv=Axis(f[1,2],title="Velocity (m/s, depth mean)")
	p=lines!(a_uv,tim,gdf_ID.u[:])
	p=lines!(a_uv,tim,gdf_ID.v[:])
	p=lines!(a_uv,tim,sqrt.(gdf_ID.u[:].^2 + gdf_ID.v[:].^2))

	a2=Axis(f[2,1],title="Temperature (degree C -- 10,100,500m depth)")

	lines!(a2,tim,gdf_ID.T10[:])	
	lines!(a2,tim,gdf_ID.T100[:])
	lines!(a2,tim,gdf_ID.T500[:])

	a3=Axis(f[2,2],title="Salinity (psu -- 10,100,500m depth)")

	lines!(a3,tim,gdf_ID.S10[:],label="10m")	
	lines!(a3,tim,gdf_ID.S100[:],label="100m")
	lines!(a3,tim,gdf_ID.S500[:],label="500m")

	f
end

"""
    plot(x::Glider_Spray,ID;size=(900,600),pol=missing)

Default plot for glider data.
	
- ID is an integer (currently between 0 and 56)
- size let's you set the figure dimensions
- pol is a set of polygons (e.g., continents) 

```
using OceanRobots, CairoMakie
glider=read(Glider_Spray(),"GulfStream.nc",1)
plot(glider)
```
"""
function plot(x::Glider_Spray; size=(900,600), pol=missing)
	plot_glider_default(x,markersize=4,pol=pol)
end

## Glider EGO

"""
    plot(x::Glider_EGO;size=(900,600),pol=missing)

```
using OceanRobots, CairoMakie
glider=read(Glider_EGO(),1);
plot(glider)
```
"""
function plot(x::Glider_EGO; size=(900,600),pol=missing,markersize=2)
	plot_glider_default(x,markersize=markersize,pol=pol)
end

function colorrange(x;positive=false)
	y=findall((!ismissing).(x)); z=x[y];
	y=findall((!isnan).(z)); z=z[y];
	if positive
		y=findall(x.>0); z=z[y];
	end
	quantile(z, 0.05),quantile(z, 0.95)
end


## Glider AOML

"""
    plot(x::Glider_AOML;size=(900,600),pol=missing)

```
using OceanRobots, CairoMakie
sample_file=Glider_AOML_module.sample_file()
glider=read(Glider_AOML(),sample_file)
plot(glider,markersize=8)
```
"""
plot(glider::Glider_AOML; size=(1000,600), markersize=2, pol=missing) = begin
	plot_glider_default(glider,markersize=markersize,size=size,pol=pol)
end

##


"""
    plot_glider_default(glider; markersize=2, 
		size=(600,800), pol=missing, pad=2.0)

```
using OceanRobots
glider=read(Glider_EGO(),1)

using MeshArrays, GeoJSON, DataDeps
pol=MeshArrays.Dataset("countries_geojson1")

plot(glider,pol=pol)
```
"""
function plot_glider_default(glider; markersize=2, 
			size=(600,800), pol=missing, pad=2.0)
	da=glider.data
	fig=Figure(size=size)

	tim=DateTime.(da.time)
	dt=tim.-minimum(tim)
	dt=Dates.value.(dt)./(60*60*24*1000)

	tt=findall(	(!ismissing).(da.temperature) .&& 
				(!ismissing).(da.salinity)	)
	xlims=rng(da.longitude,mini=-180,maxi=180,pad=pad)
	ylims=rng(da.latitude,mini=-90,maxi=90,pad=pad)

	Axis(fig[1,1],title="time",limits = (xlims, ylims))
	scatter!(da.longitude[tt],da.latitude[tt],color=dt[tt],markersize=2)
	ismissing(pol) ? nothing : lines!(pol,color = :black, linewidth = 0.5)

	Axis(fig[1,2],title="depth",limits = (xlims, ylims))
	scatter!(da.longitude[tt],da.latitude[tt],color=da.depth[tt],markersize=2)
	ismissing(pol) ? nothing : lines!(pol,color = :black, linewidth = 0.5)

	Axis(fig[2,1:2],title="temperature")
	hm=scatter!(tim[tt],-da.depth[tt],color=da.temperature[tt],markersize=markersize)
	Colorbar(fig[2,3],hm)
	Axis(fig[3,1:2],title="salinity")
	hm=scatter!(tim[tt],-da.depth[tt],color=da.salinity[tt],markersize=markersize)
	Colorbar(fig[3,3],hm)

	fig
end

