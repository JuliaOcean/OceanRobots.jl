module OceanRobotsMakieExt

using OceanRobots, Makie
import OceanRobots: Dates

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

end

