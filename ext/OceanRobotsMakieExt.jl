module OceanRobotsMakieExt

using OceanRobots, Makie
import OceanRobots: Dates
import Makie: plot

## DRIFTERS

"""
    plot_drifter(ds)

Plot drifter data.        
"""
function plot_drifter(ds;size=(600,900))	
	la=GDP.read_v(ds,"latitude")
	lo=GDP.read_v(ds,"longitude")
	lon360=GDP.read_v(ds,"lon360")
	tst=maximum(lo)-minimum(lo)>maximum(lon360)-minimum(lon360)
	tst ? lo.=lon360 : nothing

	ve=GDP.read_v(ds,"ve")[:]
	vn=GDP.read_v(ds,"vn")[:]
	vel=sqrt.(ve.^2 .+ vn.^2)
		
	fig1 = Figure(size=size)
	ax1 = Axis(fig1[1,1], title="positions", xlabel="longitude",ylabel="latitude")
	lines!(ax1,lo[:],la[:],linewidth=1)
	ax1 = Axis(fig1[1,2], title="velocity", xlabel="eastward vel.",ylabel="northward vel.")
	lines!(ax1,ve[:],vn[:],linewidth=0.5)

	tim=GDP.read_v(ds,"time")[:]
	sst=GDP.read_v(ds,"sst")[:]
	sst1=GDP.read_v(ds,"sst1")[:]

	ax2 = Axis(fig1[2,1:2], ylabel="m/s")
	lines!(ax2,tim,vel,color=:red,label="velocity",linewidth=1)
	lines!(ax2,tim,ve,color=:blue,label="eastward vel.",linewidth=1)
	lines!(ax2,tim,vn,color=:green,label="northward vel.",linewidth=1)
	axislegend(orientation = :horizontal)

	ax3 = Axis(fig1[3,1:2], ylabel="degC")
	lines!(tim,sst.-273.15,label="temperature")
	lines!(tim,sst1.-273.15,label="non-diurnal temp.")
	axislegend(orientation = :horizontal)

	fig1
end

"""
    plot(x::SurfaceDrifter)
	
```
using OceanRobots, CairoMakie
drifter=read(SurfaceDrifter(),1)
plot(drifter)
```
"""
plot(x::SurfaceDrifter;size=(600,900)) = plot_drifter(x.data,size=size)


## WHOTS

"""
    plot(x::OceanSite,args...)
	
```
using OceanRobots, Dates
whots=read(OceanSite(),:WHOTS)
plot(whots,DateTime(2005,1,1),DateTime(2005,2,1),size=(900,600))
```
"""
plot(x::OceanSite,args...;kwargs...)=plot_WHOTS(x.data,x.units,args...;kwargs...)

function plot_WHOTS(arr,units,d0,d1;size=(900,600))
	
    tt=findall((arr.TIME.>d0).*(arr.TIME.<=d1))
    t=Dates.value.(arr.TIME.-d0)/1000.0/86400.0
	#or, e.g.:
    #t=Dates.value.(arr.TIME.-TIME[1])/1000.0/86400.0
    #tt=findall((t.>110).*(t.<140))

    f=Figure(size=size)
	ax1=Axis(f[1,1],xlabel="days",ylabel=units.wspeed,title="wspeed")
    lines!(ax1,t[tt],arr.wspeed[tt])
	ax1=Axis(f[2,1],xlabel="days",ylabel=units.AIRT,title="AIRT")
    lines!(ax1,t[tt],arr.AIRT[tt])
	ax1=Axis(f[3,1],xlabel="days",ylabel=units.TEMP,title="TEMP")
    lines!(ax1,t[tt],arr.TEMP[tt])
	
	ax1=Axis(f[1,2],xlabel="days",ylabel=units.RAIN,title="RAIN")
    lines!(ax1,t[tt],arr.RAIN[tt])
	ax1=Axis(f[2,2],xlabel="days",ylabel=units.RELH,title="RELH")
    lines!(ax1,t[tt],arr.RELH[tt])
	ax1=Axis(f[3,2],xlabel="days",ylabel="x0"*units.PSAL,title="PSAL")
    lines!(ax1,t[tt],arr.PSAL[tt])
	
    f
end

## NOAA

"""
    plot(x::NOAAbuoy,var)
	
```
using OceanRobots, CairoMakie
buoy=read(NOAAbuoy(),41046)
plot(buoy,"PRES",size=(900,600))
```
"""
plot(x::NOAAbuoy,var; size=(600,900)) = begin
	f=Figure(size=size)
	u=x.units[var]
	sta=x.ID
	ax=Axis(f[1,1],title="Station $(sta), Variable $(var)",ylabel=u,xlabel="date")
	tim=DateTime.(x.data.YY,x.data.MM,x.data.DD,x.data.hh,x.data.mm)
	lines!(ax,tim,x.data[!,Symbol(var)])
	println(x.descriptions[var])
	f
end

"""
    plot(x::NOAAbuoy_monthly, var=""; option=:demo)
	
```
using OceanRobots
buoy=read(NOAAbuoy_monthly(),44013)
plot(buoy;option=:demo)
```
"""
plot(x::NOAAbuoy_monthly, var="T(°F)"; option=:demo, size=(600,900)) = begin
	if option==:demo
		gmdf=NOAA.groupby(x.data,"MM")
		tbl=[NOAA.summary_table(gmdf[m],25,var=var) for m in 1:12]
		all=[]; [push!(all,(tbl[m].T1-tbl[m].T0)...) for m in 1:12]
		uni=( var=="T(°F)" ? "°Fahrenheit" : x.units[var] )
		plot_summary(tbl,all,var,uni,size=size)
	else
		@warn "case not implemented"
	end
end

mean=NOAA.mean

function plot_summary(tbl,all,var,uni;size=(600,900))
	f=Figure(size=size); 
	ax=Axis(f[1,1],title="full distribution of T1-T0 "); hist!(ax,all)
	ax=Axis(f[1,2],title="mean(T1-T0) each month"); barplot!(ax,[mean(tbl[m].T1)-mean(tbl[m].T0) for m in 1:12])
	ax=Axis(f[2,1:2],title="seasonal cycle of $(var)",ylabel=uni);
	lines!(ax,[mean(tbl[m].T0) for m in 1:12],label="mean(T0)")
	lines!(ax,[mean(tbl[m].T1) for m in 1:12],label="mean(T1)")
	axislegend(ax)
	f
end

## Satellite

podaac_date(n)=Date("1992-10-05")+Dates.Day(5*n)
podaac_sample_dates=podaac_date.(18:73:2190)
cmems_date(n)=Date("1993-01-01")+Dates.Day(1*n)
podaac_all_dates=podaac_date.(1:2190)
cmems_all_dates=cmems_date.(1:10632)

sla_dates(fil) = ( fil=="sla_podaac.nc" ? podaac_all_dates : cmems_all_dates)

"""
    plot(b::SeaLevelAnomaly; dates=[], kwargs...)
	
```
using OceanRobots
sla=read(SeaLevelAnomaly(),:sla_podaac)
plot(sla)
```
"""
plot(b::SeaLevelAnomaly; dates=[], kwargs...) = begin
	ds=(isempty(dates) ? sla_dates(b.file) : dates)
	fig,_,_=prep_movie(b.data; dates=ds, kwargs...)
	fig
end

function prep_movie(ds; topo=[], colormap=:PRGn, color=:black, 
	time=1, dates=[], resolution = (600, 400))
	lon=ds["lon"][:]
	lat=ds["lat"][:]
	store=ds["SLA"][:,:,:]

	nt=size(store,3)
	kk=findall((!isnan).(store[:,:,end]))

	n=Observable(time)
	SLA=@lift(store[:,:,$n])
	SLA2=@lift($(SLA).-mean($(SLA)[kk]))

	fig=Figure(size=resolution,fontsize=11)
	ax=Axis(fig[1,1])
    hm=heatmap!(lon,lat,SLA2,colorrange=0.25.*(-1.0,1.0),colormap=colormap)

	if !isempty(topo)
		lon[1]>0.0 ? lon_off=360.0 : lon_off=0.0
		contour!(lon_off.+topo.lon,topo.lat,topo.z,levels=-300:100:300,color=color,linewidth=1)
		contour!(lon_off.+topo.lon,topo.lat,topo.z,levels=-2500:500:-500,color=color,linewidth=0.25)
		contour!(lon_off.+topo.lon,topo.lat,topo.z,levels=-6000:1000:-3000,color=color,linewidth=0.1)
	end

	lon0=minimum(lon)+(maximum(lon)-minimum(lon))/20.0
	lat0=maximum(lat)-(maximum(lat)-minimum(lat))/10.0
	
	if isempty(dates)
		println("no date")
	else
	    dtxt=@lift(string(dates[$n]))
		text!(lon0,lat0,text=dtxt,color=:blue2,fontsize=14,font = :bold)	
	end
	
	Colorbar(fig[1,2],hm)

	fig,n,nt
end

function make_movie(ds,tt; framerate = 90, dates=[])
	fig,n,nt=prep_movie(ds,dates=dates)
    record(fig,tempname()*".mp4", tt; framerate = framerate) do t
        n[] = t
    end
end

## Argo

function heatmap_profiles!(ax,TIME,TEMP,cmap)
	x=TIME[1,:]; y=collect(0.0:5:500.0)
	co=Float64.(permutedims(TEMP))
	rng=extrema(TEMP[:])
	sca=heatmap!(ax, x , y , co, colorrange=rng,colormap=cmap)
	ax.xlabel="time (day)"
	ax.ylabel="depth (m)"
	sca
end

function plot_profiles!(ax,TIME,PRES,TEMP,cmap)
	ii=findall(((!ismissing).(PRES)).*((!ismissing).(TEMP)))

	x=TIME[ii]
	y=-PRES[ii] #pressure in decibars ~ depth in meters
	co=Float64.(TEMP[ii])
	rng=extrema(co)

	sca=scatter!(ax, x , y ,color=co,colormap=cmap, markersize=5)

	ax.xlabel="time (day)"
	ax.ylabel="depth (m)"

	sca
end

function plot_trajectory!(ax,lon,lat,co;
		markersize=2,linewidth=3, pol=Any[],xlims=(-180,180),ylims=(-90,90),title="")
	li=lines!(ax,lon, lat, linewidth=linewidth, color=co, colormap=:turbo)
	scatter!(ax,lon, lat, marker=:circle, markersize=markersize, color=:black)
	!isempty(pol) ? [lines!(ax,l1,color = :black, linewidth = 0.5) for l1 in pol] : nothing
	ax.xlabel="longitude";  ax.ylabel="latitude"; ax.title=title
	xlims!(xlims...); ylims!(ylims...)
	li
end

xrng(lon)=begin
	a=[floor(minimum(lon)) ceil(maximum(lon))]
	dx=diff(a[:])[1]
	b=[max(a[1]-dx/2,-180) min(a[2]+dx/2,180)]
end
yrng(lat)=begin
	a=[floor(minimum(lat)) ceil(maximum(lat))]
	dx=diff(a[:])[1]
	b=[max(a[1]-dx/2,-90) min(a[2]+dx/2,90)]
end

function plot_standard(wmo,arr,spd,T_std,S_std; markersize=2,pol=Any[],size=(900,600))

	xlims=xrng(arr.lon)
	ylims=yrng(arr.lat)
	
	fig1=Figure(size=size)

	ax=Axis(fig1[1,1])
	li1=plot_trajectory!(ax,arr.lon,arr.lat,arr.TIME[1,:];
		linewidth=5,pol=pol,xlims=(-180,180),ylims=(-80,90),
		title="time since launch, in days")
	Colorbar(fig1[1,2], li1, height=Relative(0.65))

	ax=Axis(fig1[1,3])
	li2=plot_trajectory!(ax,arr.lon,arr.lat,spd.speed;
		markersize=2,pol=pol,xlims=xlims,ylims=ylims,
		title="estimated speed (m/s)")
	Colorbar(fig1[1,4], li2, height=Relative(0.65))

	ax=Axis(fig1[2,1:3],title="Temperature, °C")
	hm1=heatmap_profiles!(ax,arr.TIME,T_std,:thermal)
	Colorbar(fig1[2,4], hm1, height=Relative(0.65))
	ylims!(ax, 500, 0)

	ax=Axis(fig1[3,1:3],title="Salinity, [PSS-78]")
	hm2=heatmap_profiles!(ax,arr.TIME,S_std,:viridis)
	Colorbar(fig1[3,4], hm2, height=Relative(0.65))
	ylims!(ax, 500, 0)

	rowsize!(fig1.layout, 1, Relative(1/2))

	fig1
end

"""
    plot(x::ArgoFloat; option=:standard, markersize=2,pol=Any[])

```
using OceanRobots, ArgoData, CairoMakie

argo=read(ArgoFloat),wmo=2900668)

f1=plot(argo,option=:samples)
f2=plot(argo,option=:TS)
f3=plot(argo,option=:standard)
```
"""
plot(x::ArgoFloat; option=:standard, markersize=2,pol=Any[],size=(900,600)) = begin
	if option==:standard
		T_std,S_std=ArgoFiles.interp_z_all(x.data)
		spd=ArgoFiles.speed(x.data)
		plot_standard(x.ID,x.data,spd,T_std,S_std; markersize=markersize, pol=pol, size=size)
	elseif option==:samples
		plot_samples(x.data,x.ID)
	elseif option==:TS
		plot_TS(x.data,x.ID)
	end
end

function plot_TS(arr,wmo)
	fig1=Figure(size=(600,600))
	ax=Axis(fig1[1,1],title="Float wmo="*string(wmo),xlabel="Salinity",ylabel="Temperature")
	scatter!(ax,arr.PSAL[:],arr.TEMP[:],markersize=2.0)
	fig1
end

function plot_samples(arr,wmo;ylims=(-2000.0, 0.0))
	
	fig1=Figure(size = (1200, 900))
	lims=(nothing, nothing, ylims...)

	ttl="Float wmo="*string(wmo)
	ax=Axis(fig1[1,1],title=ttl*", temperature, degree C", limits=lims)
	hm1=OceanRobotsMakieExt.plot_profiles!(ax,arr.TIME,arr.PRES,arr.TEMP,:thermal)
	Colorbar(fig1[1,2], hm1, height=Relative(0.65))

	ax=Axis(fig1[2,1],title=ttl*", salinity, psu", limits=lims)
	hm2=OceanRobotsMakieExt.plot_profiles!(ax,arr.TIME,arr.PRES,arr.PSAL,:viridis)
	Colorbar(fig1[2,2], hm2, height=Relative(0.65))

	fig1
end

## Gliders

function plot_glider(df,gdf,ID;size=(900,600))
	f=Figure(size=size)
	
	a_traj=Axis(f[1,1],title="Positions")
	p=scatter!(a_traj,df.lon,df.lat,markersize=1)
	p=scatter!(a_traj,gdf[ID].lon,gdf[ID].lat,color=:red)

	a_uv=Axis(f[1,2],title="Velocity (m/s, depth mean)")
	p=lines!(a_uv,gdf[ID].u[:])
	p=lines!(a_uv,gdf[ID].v[:])
	p=lines!(a_uv,sqrt.(gdf[ID].u[:].^2 + gdf[ID].v[:].^2))

	a2=Axis(f[2,1],title="Temperature (degree C -- 10,100,500m depth)")

	lines!(a2,gdf[ID].T10[:])	
	lines!(a2,gdf[ID].T100[:])
	lines!(a2,gdf[ID].T500[:])

	a3=Axis(f[2,2],title="Salinity (psu -- 10,100,500m depth)")

	lines!(a3,gdf[ID].S10[:],label="10m")	
	lines!(a3,gdf[ID].S100[:],label="100m")
	lines!(a3,gdf[ID].S500[:],label="500m")

	f
end

"""
    plot(x::Gliders,ID)

```
using OceanRobots, CairoMakie
gliders=read(Gliders(),"GulfStream.nc")
plot(gliders,1,size=(900,600))
```
"""
plot(x::Gliders,ID;size=(900,600)) = begin
	gdf=GliderFiles.groupby(x.data,:ID)
	plot_glider(x.data,gdf,ID,size=size)
end

## OceanOPS

end

