module OceanRobotsMakieExt

using OceanRobots, Makie
import OceanRobots: Dates, CCHDO
import Makie: plot

## DRIFTERS

"""
    plot_drifter(ds)

Plot drifter data.        
"""
function plot_drifter(ds;size=(900,600),pol=Any[])	
	la=GDP.read_v(ds,"latitude")
	lo=GDP.read_v(ds,"longitude")
	lon360=GDP.read_v(ds,"lon360")
	tst=maximum(lo)-minimum(lo)>maximum(lon360)-minimum(lon360)+0.0001
	tst ? lo.=lon360 : nothing

	ve=GDP.read_v(ds,"ve")[:]
	vn=GDP.read_v(ds,"vn")[:]
	vel=sqrt.(ve.^2 .+ vn.^2)

	xlims=xrng(lo[:]); ylims=yrng(la[:])

	fig1 = Figure(size=size)
	ax1 = Axis(fig1[1,1], xlabel="longitude",ylabel="latitude",limits=(xlims,ylims))
	scatter!(ax1,lo[:],la[:],markersize=8,color=:red)
	!isempty(pol) ? [lines!(ax1,l1,color = :black, linewidth = 0.5) for l1 in pol] : nothing

	ax1 = Axis(fig1[1,2], xlabel="eastward vel.",ylabel="northward vel.")
	scatter!(ax1,ve[:],vn[:])

	tim=GDP.read_v(ds,"time")[:]
	sst=GDP.read_v(ds,"sst")[:]
	sst1=GDP.read_v(ds,"sst1")[:]

	ax2 = Axis(fig1[2,1:2], ylabel="m/s")
	lines!(ax2,tim,vel,color=:red,label="velocity",linewidth=1)
	lines!(ax2,tim,ve,color=:blue,label="eastward vel.",linewidth=1)
	lines!(ax2,tim,vn,color=:green,label="northward vel.",linewidth=1)
	fig1[2, 3] = Legend(fig1, ax2, framevisible = false)

	ax3 = Axis(fig1[3,1:2], ylabel="degC")
	lines!(tim,sst.-273.15,label="temperature")
	lines!(tim,sst1.-273.15,label="non-diurnal temp.")
	fig1[3, 3] = Legend(fig1, ax3, framevisible = false)

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
plot(x::SurfaceDrifter;size=(900,600),pol=Any[]) = plot_drifter(x.data,size=size,pol=pol)


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

	tim=arr.TIME

    f=Figure(size=size)
	ax1=Axis(f[1,1],ylabel=units.wspeed)
    lines!(ax1,tim[tt],arr.wspeed[tt],label="wspeed"); Legend(f[1,2],ax1)
	ax2=Axis(f[2,1],ylabel=units.AIRT)
    lines!(ax2,tim[tt],arr.AIRT[tt],label="AIRT"); Legend(f[2,2],ax2)
	ax3=Axis(f[3,1],ylabel=units.TEMP)
    lines!(ax3,tim[tt],arr.TEMP[tt],label="TEMP"); Legend(f[3,2],ax3)
	ax4=Axis(f[4,1],ylabel=units.RELH)
    lines!(ax4,tim[tt],arr.RELH[tt],label="RELH"); Legend(f[4,2],ax4)

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
plot(x::NOAAbuoy,vars; size=(900,600)) = begin
	f=Figure(size=size)
	sta=x.ID
	for vv in 1:length(vars)
		var=vars[vv]
		u=x.units[var]
		ax=Axis(f[vv,1],title="Station= $(sta), Variable= $(var)",ylabel=u)
		tim=DateTime.(x.data.YY,x.data.MM,x.data.DD,x.data.hh,x.data.mm)
		lines!(ax,tim,x.data[!,Symbol(var)])
		println(x.descriptions[var])
	end
	f
end

plot(x::NOAAbuoy,var::String; kwargs...) = plot(x,[var]; kwargs...)


"""
    plot(x::NOAAbuoy_monthly, var=""; option=:demo)
	
```
using OceanRobots
buoy=read(NOAAbuoy_monthly(),44013)
plot(buoy;option=:demo)
```
"""
plot(x::NOAAbuoy_monthly, var="T(°F)"; option=:demo, size=(900,600)) = begin
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
months=[:J :F :M :A :M :J :J :A :S :O :N :D]

function plot_summary(tbl,all,var,uni;size=(900,600))
	f=Figure(size=size)
	xlm=maximum(abs.(all[:])).*(-1,1)
	ax=Axis(f[1,1],title="full distribution of T1-T0 ",xlabel=uni,ylabel="counts",limits = (xlm, nothing)); hist!(ax,all)
	ax=Axis(f[1,2],title="mean(T1-T0) each month",xlabel=uni); barplot!(ax,[mean(tbl[m].T1)-mean(tbl[m].T0) for m in 1:12])
	ax=Axis(f[2,1:2],title="seasonal cycle of $(var)",xlabel="month",ylabel=uni);
	lines!(ax,[mean(tbl[m].T0) for m in 1:12],label="mean(T0)")
	lines!(ax,[mean(tbl[m].T1) for m in 1:12],label="mean(T1)")
	ax.xticks[]=1:12
	axislegend(ax)
	f
end

## Argo

function heatmap_profiles!(ax,TIME,TEMP,cmap)
	x=TIME[1,:]; y=collect(0.0:5:500.0)
	co=Float64.(permutedims(TEMP))
	rng=extrema(TEMP[:])
	sca=heatmap!(ax, x , y , co, colorrange=rng,colormap=cmap)
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
	a=[floor(minimum(skipmissing(lon))) ceil(maximum(skipmissing(lon)))]
	dx=max(diff(a[:])[1],10)
	b=(a[2]>180 ? +180 : 0)
	(max(a[1]-dx/2,-180+b),min(a[2]+dx/2,180+b))
end
yrng(lat)=begin
	a=[floor(minimum(skipmissing(lat))) ceil(maximum(skipmissing(lat)))]
	dx=max(diff(a[:])[1],10)
	b=(max(a[1]-dx/2,-90),min(a[2]+dx/2,90))
end

function plot_standard(wmo,arr,spd,T_std,S_std; markersize=2,pol=Any[],size=(900,600))

	xlims=xrng(arr.lon)
	ylims=yrng(arr.lat)
	
	fig1=Figure(size=size)

	ax=Axis(fig1[1,1])
	li1=plot_trajectory!(ax,arr.lon,arr.lat,arr.TIME[1,:];
		linewidth=5,pol=pol,xlims=xlims,ylims=ylims,
		title="time since launch, in days")
	Colorbar(fig1[1,2], li1, height=Relative(0.65))

	ax=Axis(fig1[1,3])
	li2=plot_trajectory!(ax,arr.lon,arr.lat,spd.speed;
		linewidth=5,pol=pol,xlims=xlims,ylims=ylims,
		title="estimated speed (m/s)")
	Colorbar(fig1[1,4], li2, height=Relative(0.65))

	ax=Axis(fig1[2,1:3],title="Temperature, °C")
	hm1=heatmap_profiles!(ax,arr.DATE,T_std,:thermal)
	Colorbar(fig1[2,4], hm1, height=Relative(0.65))
	ylims!(ax, 500, 0)

	ax=Axis(fig1[3,1:3],title="Salinity, [PSS-78]")
	hm2=heatmap_profiles!(ax,arr.DATE,S_std,:viridis)
	Colorbar(fig1[3,4], hm2, height=Relative(0.65))
	ylims!(ax, 500, 0)

	rowsize!(fig1.layout, 1, Relative(1/2))

	fig1
end

"""
    plot(x::ShipCruise; 
		markersize=6,pol=Any[],colorrange=(2,20),
		size=(900,600),variable="temperature",apply_log10=false)

```
using OceanRobots, CairoMakie
cruise=ShipCruise("33RR20160208")
plot(cruise)
```

or 
```
plot(cruise,variable="chi_up",apply_log10=true,colorrange=(-12,-10))
```
"""
function plot(x::ShipCruise; 
	markersize=6,pol=Any[],colorrange=(2,20),
	size=(900,600),variable="temperature",apply_log10=false)

	fig=Figure(size=size); ax=Axis(fig[1,1],title="$(variable) from cruise $(x.ID)")

	known_chipod_variables=["chi_up","chi_dn","KT_up","KT_dn"]
	if variable=="temperature"||variable=="salinity"
		list1=CCHDO.list_CTD_files(x)		
		for f in list1
			ds=CCHDO.NCDatasets.Dataset(f)
			tim=fill(ds["time"][1],ds.dim["pressure"])
			depth=-ds["pressure"][:]
			scatter!(tim,depth,color=ds[variable][:],markersize=markersize,colorrange=colorrange)
		end
	elseif variable in known_chipod_variables
		plot_chi!(x;variable=variable,apply_log10=apply_log10,
			colorrange=colorrange,markersize=markersize)
	end
	Colorbar(fig[1,2], colorrange=colorrange, height=Relative(0.65))
	fig
end

function plot_chi!(x;variable="chi_up",colorrange=(-12.0,-10.0),apply_log10=true,markersize=3)
	ds=CCHDO.open_chipod_file(x)

	time=permutedims(repeat(ds["time"][:],1,ds.dim["pressure"]))
	pressure=permutedims(repeat(ds["pressure"][:]',ds.dim["station"],1))
	y=ds[variable][:,:]
	u=ds[variable].attrib["units"]

	ii=findall((!ismissing).(y))
	a=DateTime.(time[ii])
	b=Float64.(-pressure[ii])
	c=(apply_log10 ? log10.(Float64.(y[ii])) : Float64.(y[ii]))
	l=(apply_log10 ? ", log10" : nothing)

	ax=current_axis()
	ax.title="variable = $(variable) (in $u$l) ; cruise = $(x.ID)"

	scatter!(a,b,color=c,markersize=markersize,colorrange=colorrange)
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

rng(x;mini=NaN,maxi=NaN,pad=0.1) = begin
	xlm=collect(extrema(skipmissing(x)))
	dxlm=diff(xlm)[1]
	xlm=[xlm[1]-pad*dxlm,xlm[2]+pad*dxlm]
	isfinite(mini) ? xlm[1]=max(mini,xlm[1]) : nothing
	isfinite(maxi) ? xlm[2]=min(maxi,xlm[2]) : nothing
	(xlm[1],xlm[2])
end

function plot_glider(df,gdf,ID;size=(900,600),pol=Any[])
	f=Figure(size=size)
#	xlims=rng(df.lon,mini=-180,maxi=180)
#	ylims=rng(df.lat,mini=-90,maxi=90)
	xlims=xrng(df.lon)
	ylims=yrng(df.lat)
	a_traj=Axis(f[1,1],title="Positions",limits = (xlims, ylims))
	p=scatter!(a_traj,df.lon,df.lat,markersize=1)
	p=scatter!(a_traj,gdf[ID].lon,gdf[ID].lat,color=:red)
	!isempty(pol) ? [lines!(a_traj,l1,color = :black, linewidth = 0.5) for l1 in pol] : nothing

	tim=DateTime.(gdf[ID].time[:])

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
    plot(x::Gliders,ID)

```
using OceanRobots, CairoMakie
gliders=read(Gliders(),"GulfStream.nc")
plot(gliders,1,size=(900,600))
```
"""
plot(x::Gliders,ID;size=(900,600),pol=Any[]) = begin
	gdf=GliderFiles.groupby(x.data,:ID)
	plot_glider(x.data,gdf,ID,size=size,pol=pol)
end

## OceanOPS

end

