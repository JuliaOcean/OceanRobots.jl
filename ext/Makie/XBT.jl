
"""
    plot(x::XBTtransect;pol=missing)	

Default plot for XBT data.
	
```
using OceanRobots, CairoMakie
xbt=read(XBTtransect(),transect="PX05",cruise="0910")
plot(xbt)
```
"""
function plot(x::XBTtransect;pol=missing)	
	if x.format=="AOML"
        plot_XBT_AOML(x,pol=pol)
    elseif x.format=="SIO"
        plot_XBT_SIO(x,pol=pol)
    elseif x.format=="IMOS"
        plot_XBT_IMOS(x,pol=pol)
    else
        @warn "unknown source"
        Figure()
    end
end

function plot_XBT_SIO(x::XBTtransect;pol=missing)	
	transect=x.ID
	T_all=x.data[1]
	meta_all=x.data[2]
	CR=x.data[3]
	dep=XBT.dep
	tim=convert_time(meta_all[:,3])

	fig=Figure()
	
	ax=Axis(fig[1,1],title=transect*" -- cruise "*CR,ylabel="depth")
	hm=heatmap!(tim,dep,T_all)
	Colorbar(fig[1,2],hm)

	ax=Axis(fig[2,1:2],title=transect*" -- cruise "*CR)
	ismissing(pol) ? nothing : lines!(pol,color = :black, linewidth = 0.5)
	scatter!(meta_all[:,1],meta_all[:,2],color=:red)
	xlims!(-180,180); ylims!(-90,90)

	fig
end

function plot_XBT_AOML(x::XBTtransect;pol=missing)	
	transect=x.ID
	d=x.data[1]
	m=x.data[2]
	CR=x.data[3]
	dep=XBT.dep

	fig=Figure()
	ax=Axis(fig[1,1],title=transect*" -- cruise "*CR,ylabel="depth")
	hm=scatter!(d.time,-d.de,color=d.th)
	Colorbar(fig[1,2],hm)

	ax=Axis(fig[2,1:2],title=transect*" -- cruise "*CR)
	ismissing(pol) ? nothing : lines!(pol,color = :black, linewidth = 0.5)
	scatter!(m.lon,m.lat,color=:red)
	xlims!(-180,180); ylims!(-90,90)

	fig
end

function plot_XBT_IMOS(x::XBTtransect;pol=missing)	
	ID=x.ID
#	transect_year=x.data[2].cruise[1]
	d=x.data[1]
	m=x.data[2]

	fig=Figure()
	ax=Axis(fig[1,1],title=ID ,ylabel="depth")
	hm=scatter!(d.time,-d.depth,color=d.temp)
	Colorbar(fig[1,2],hm)

	ax=Axis(fig[2,1:2],title=ID)
	ismissing(pol) ? nothing : lines!(pol,color = :black, linewidth = 0.5)
	scatter!(m.lon,m.lat,color=:red)
	xlims!(-180,180); ylims!(-90,90)

	fig
end

