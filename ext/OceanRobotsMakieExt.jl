module OceanRobotsMakieExt

using OceanRobots, Makie
import OceanRobots: Dates

## DRIFTERS

"""
    plot_drifter(ds)

Plot drifter data.        
"""
function plot_drifter(ds)	
	la=GDP.read_v(ds,"latitude")
	lo=GDP.read_v(ds,"longitude")
	lon360=GDP.read_v(ds,"lon360")
	tst=maximum(lo)-minimum(lo)>maximum(lon360)-minimum(lon360)
	tst ? lo.=lon360 : nothing

	ve=GDP.read_v(ds,"ve")
	vn=GDP.read_v(ds,"vn")
	vel=sqrt.(ve.^2 .+ vn.^2)
		
	fig1 = Figure()
	ax1 = Axis(fig1[1,1], title="positions", xlabel="longitude",ylabel="latitude")
	lines!(ax1,lo[:],la[:])
	ax1 = Axis(fig1[1,2], title="velocities", xlabel="ve",ylabel="vn")
	scatter!(ax1,ve[:],vn[:],markersize=2.0)

	ax2 = Axis(fig1[2,1:2], title="speed (red), ve (blue), vn (green)", xlabel="time",ylabel="m/s")
	lines!(ax2,vel[:],color=:red)
	lines!(ax2,ve[:],color=:blue)
	lines!(ax2,vn[:],color=:green)
	
	fig1
end

## WHOTS

function plot_WHOTS(arr,units,d0,d1)
	
    tt=findall((arr.TIME.>d0).*(arr.TIME.<=d1))
    t=Dates.value.(arr.TIME.-d0)/1000.0/86400.0
	#or, e.g.:
    #t=Dates.value.(arr.TIME.-TIME[1])/1000.0/86400.0
    #tt=findall((t.>110).*(t.<140))

    f=Figure()
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

mean=NOAA.mean

function plot_summary(tbl,all)
	f=Figure(); 
	ax=Axis(f[1,1],title="full distribution of T1-T0 "); hist!(ax,all)
	ax=Axis(f[1,2],title="mean(T1-T0) each month"); barplot!(ax,[mean(tbl[m].T1)-mean(tbl[m].T0) for m in 1:12])
	ax=Axis(f[2,1:2],title="seasonal cycle");
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

function prep_movie(ds, topo; colormap=:PRGn, color=:black, 
	time=1, dates=[], showTopo=true, resolution = (600, 400))
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

	if showTopo
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

end

