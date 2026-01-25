
## Glider_Spray

rng(x;mini=NaN,maxi=NaN,pad=0.1) = begin
	xlm=collect(extrema(skipmissing(x)))
	dxlm=diff(xlm)[1]
	xlm=[xlm[1]-pad*dxlm,xlm[2]+pad*dxlm]
	isfinite(mini) ? xlm[1]=max(mini,xlm[1]) : nothing
	isfinite(maxi) ? xlm[2]=min(maxi,xlm[2]) : nothing
	(xlm[1],xlm[2])
end

function convert_time(tim)
	y1=Dates.year(tim[1])
	y1.+(tim.-Dates.DateTime(y1))./Dates.Millisecond(1)/1000/86400/365.25
end

function plot_glider(df,gdf,ID;size=(900,600),pol=missing)
	f=Figure(size=size)
#	xlims=rng(df.lon,mini=-180,maxi=180)
#	ylims=rng(df.lat,mini=-90,maxi=90)
	xlims=xrng(df.lon)
	ylims=yrng(df.lat)
	a_traj=Axis(f[1,1],title="Positions",limits = (xlims, ylims))
	p=scatter!(a_traj,df.lon,df.lat,markersize=1)
	p=scatter!(a_traj,gdf[ID].lon,gdf[ID].lat,color=:red)
	ismissing(pol) ? nothing : lines!(pol,color = :black, linewidth = 0.5)

	tim=DateTime.(gdf[ID].time[:])
	tim=convert_time(tim) #this should not be needed (?)

	a_uv=Axis(f[1,2],title="Velocity (m/s, depth mean)")
	p=lines!(a_uv,tim,gdf[ID].u[:])
	p=lines!(a_uv,tim,gdf[ID].v[:])
	p=lines!(a_uv,tim,sqrt.(gdf[ID].u[:].^2 + gdf[ID].v[:].^2))

	a2=Axis(f[2,1],title="Temperature (degree C -- 10,100,500m depth)")

	lines!(a2,tim,gdf[ID].T10[:])	
	lines!(a2,tim,gdf[ID].T100[:])
	lines!(a2,tim,gdf[ID].T500[:])

	a3=Axis(f[2,2],title="Salinity (psu -- 10,100,500m depth)")

	lines!(a3,tim,gdf[ID].S10[:],label="10m")	
	lines!(a3,tim,gdf[ID].S100[:],label="100m")
	lines!(a3,tim,gdf[ID].S500[:],label="500m")

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
gliders=read(Glider_Spray(),"GulfStream.nc")
plot(gliders,1,size=(900,600))
```
"""
plot(x::Glider_Spray,ID;size=(900,600),pol=missing) = begin
	gdf=Glider_Spray_module.groupby(x.data,:ID)
	plot_glider(x.data,gdf,ID,size=size,pol=pol)
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
plot(x::Glider_EGO;size=(900,600),pol=missing) = begin
	plot_glider_EGO(; ds=x.data.ds, variable="CHLA")
end

function scatter_glider!(; ds=missing, variable="CHLA", cr=missing)
	if haskey(ds,variable)
		dt=ds["TIME"][:]
		dt=(dt.-minimum(dt))
		c=ds[variable][:]
		c[ismissing.(c)].=NaN
		loc_cr=(ismissing(cr) ? colorrange(c) : cr)
		scatter!(dt,-ds["PRES"][:],color=c,markersize=4,colorrange=loc_cr)
	end
end

function colorrange(x;positive=false)
	y=findall((!ismissing).(x)); z=x[y];
	y=findall((!isnan).(z)); z=z[y];
	if positive
		y=findall(x.>0); z=z[y];
	end
	quantile(z, 0.05),quantile(z, 0.95)
end

function plot_glider_EGO(; ds=missing, variable="CHLA")
	fig=Figure()
	Axis(fig[1,1],title="position"); scatter!(ds["LONGITUDE"][:],ds["LATITUDE"][:])
	Axis(fig[1,2],title=variable); scatter_glider!(ds=ds,variable=variable)
	Axis(fig[2,1],title="TEMP"); scatter_glider!(ds=ds,variable="TEMP")
	Axis(fig[2,2],title="PSAL"); scatter_glider!(ds=ds,variable="PSAL")
	fig
end

## Glider AOML


"""
    plot(x::Glider_AOML;size=(900,600),pol=missing)

```
using OceanRobots, CairoMakie
glider=read(Glider_EGO(),1);
plot(glider)
```
"""
plot(glider::Glider_AOML;size=(900,600),pol=missing) = begin
	plot_glider_AOML(glider)
end

function plot_glider_AOML(glider)
	da=glider.data
	fig=Figure(size=(1000,600))

	Axis(fig[1,1],title="position")
	scatter!(da.longitude,da.latitude,markersize=2)

	Axis(fig[2,1:2],title="temperature")
	tt=findall((!ismissing).(da.temperature))
	scatter!(DateTime.(da.time)[tt],-da.ctd_depth[tt],
		color=da.temperature[tt],markersize=2)

	Axis(fig[3,1:2],title="salinity")
	tt=findall((!ismissing).(da.salinity))
	scatter!(DateTime.(da.time)[tt],-da.ctd_depth[tt],
		color=da.salinity[tt],markersize=2)

	fig
end

