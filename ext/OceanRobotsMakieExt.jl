module OceanRobotsMakieExt

using OceanRobots, Makie
import OceanRobots: Dates
import Makie: plot
using Statistics

## Argo

import OceanRobots: ArgoData
plot(x::ArgoFloat; kwargs...) = plot(ArgoData.OneArgoFloat(x.ID,x.data); kwargs...)

## various 

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

rng(x;mini=NaN,maxi=NaN,pad=0.1) = begin
	xlm=collect(extrema(skipmissing(x)))
	dxlm=diff(xlm)[1]
	xlm=[xlm[1]-pad*dxlm,xlm[2]+pad*dxlm]
	isfinite(mini) ? xlm[1]=max(mini,xlm[1]) : nothing
	isfinite(maxi) ? xlm[2]=min(maxi,xlm[2]) : nothing
	(xlm[1],xlm[2])
end

## DRIFTERS

"""
    plot_drifter(ds;size=(900,600),pol=missing)

Plot drifter data.        
"""
function plot_drifter(ds;size=(900,600),pol=missing)	
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
	ismissing(pol) ? nothing : lines!(pol,color = :black, linewidth = 0.5)

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
    plot(x::SurfaceDrifter;size=(900,600),pol=missing)

Default plot for surface drifter data.
	
- size let's you set the figure dimensions
- pol is a set of polygons (e.g., continents) 
	
```
using OceanRobots, CairoMakie
drifter=read(SurfaceDrifter(),1)
plot(drifter)
```
"""
plot(x::SurfaceDrifter;size=(900,600),pol=missing) = plot_drifter(x.data,size=size,pol=pol)


## WHOTS

"""
    plot(x::OceanSite,d0,d1;size=(900,600))
	
Default plot for OceanSite (mooring data).
	
- d0,d1 are two dates in DateTime format	
- size let's you set the figure dimensions
- pol is a set of polygons (e.g., continents) 

```
using OceanRobots, Dates
whots=read(OceanSite(),:WHOTS)
plot(whots,DateTime(2005,1,1),DateTime(2005,2,1),size=(900,600))
```
"""
plot(x::OceanSite,args...;kwargs...)=plot_WHOTS(x.data,x.meta,args...;kwargs...)

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
    plot(x::NOAAbuoy,variables; size=(900,600))

Default plot for NOAAbuoy (moored buoy data).
	
- variables (String, or array of String) are variables to plot
- size let's you set the figure dimensions

```
using OceanRobots, CairoMakie
buoy=read(NOAAbuoy(),41044)
plot(buoy,["PRES" "WTMP"],size=(900,600))
```
"""
plot(x::NOAAbuoy,variables; size=(900,600)) = begin
	f=Figure(size=size)
	sta=x.ID
	for vv in 1:length(variables)
		var=variables[vv]
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
    plot(x::NOAAbuoy_monthly, variable="T(°F)"; size=(900,600))

Default plot for NOAAbuoy_monthly (monthly averaged moored buoy data).
	
- variable (String) is the variable to plot
- size let's you set the figure dimensions

```
using OceanRobots
buoy=read(NOAAbuoy_monthly(),44013)
plot(buoy)
```
"""
plot(x::NOAAbuoy_monthly, variable="T(°F)"; size=(900,600)) = begin
	gmdf=NOAA.groupby(x.data,"MM")
	tbl=[NOAA.summary_table(gmdf[m],25,var=variable) for m in 1:12]
	all=[]; [push!(all,(tbl[m].T1-tbl[m].T0)...) for m in 1:12]
	uni=( variable=="T(°F)" ? "°Fahrenheit" : x.units[variable] )
	plot_summary(tbl,all,variable,uni,size=size)
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

##

"""
    plot(x::ShipCruise; 
		markersize=6,pol=missing,colorrange=(2,20),
		size=(900,600),variable="temperature",apply_log10=false)

Default plot for ShipCruise (source : https://cchdo.ucsd.edu).

- variable (String) is the variable to plot
- size let's you set the figure dimensions
- pol is a set of polygons (e.g., continents) 
- if `apply_log10=true` then we apply `log10`
- `markersize` and `colorrange` are plotting parameters
	
note : the list of valid `expocode` values (e.g., "33RR20160208") can be found at https://usgoship.ucsd.edu/data/

```
using OceanRobots, CairoMakie
cruise=read(ShipCruise(),"33RR20160208")
plot(cruise)
```

or 
```
plot(cruise,variable="chi_up",apply_log10=true,colorrange=(-12,-10))
```
"""
function plot(x::ShipCruise; 
	markersize=6,pol=missing,colorrange=(2,20),
	size=(900,600),variable="temperature",apply_log10=false)

	fig=Figure(size=size); ax=Axis(fig[1,1],title="$(variable) from cruise $(x.ID)")

	known_chipod_variables=["chi_up","chi_dn","KT_up","KT_dn"]
	if variable=="temperature"||variable=="salinity"
		df=x.data[1]
		scatter!(df.time,df.depth,color=df[!,variable],markersize=markersize,colorrange=colorrange)
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

## gliders

include("Makie/glider.jl")

## OceanOPS

## XBT

include("Makie/XBT.jl")

end

