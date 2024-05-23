module OceanRobotsMakieExt

using OceanRobots, Makie

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

export plot_drifter

end

