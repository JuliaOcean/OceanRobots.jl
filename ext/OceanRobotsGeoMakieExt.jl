module OceanRobotsGeoMakieExt

using OceanRobots, GeoMakie

## OceanOPS

function plot_add(s=:OceanOPS,i=1;col=:red)
	tab=OceanOPS.get_table(s,i)
	nam=OceanOPS.csv_listings()[s][i]
	scatter!(tab.DEPL_LON,tab.DEPL_LAT,label=nam,markersize=8,marker=:xcross,color=col)
end

function plot_base_Argo()
	fi0=Figure()
	ax0=GeoAxis(fi0[1,1])	
	tab=OceanOPS.get_table(:Argo,1)
	nam=OceanOPS.csv_listings()[:Argo][1]
	sc0=scatter!(tab.LATEST_LOC_LON,tab.LATEST_LOC_LAT,label=nam,markersize=4)
	lines!(ax0, GeoMakie.coastlines(),color=:black)
	fi0,ax0,sc0
end

plot_OceanOPS1(argo_operational,argo_planned,drifter_operational,more_operational,more_platform_name)=begin
	fi0=Figure()
	ax0=GeoAxis(fi0[1,1]) #,coastlines = true)	
	sc1=scatter!(argo_operational.lon,argo_operational.lat,
		label="Argo (operational)",color=:blue,markersize=4)
	sc2=scatter!(argo_planned.lon,argo_planned.lat,
		label="Argo (planned)",color=:red,marker=:xcross,markersize=8)
	sc3=scatter!(drifter_operational.lon,drifter_operational.lat,
		label="Drifter",color=:green2,marker='O',markersize=12)
	sc4=scatter!(more_operational.lon,more_operational.lat,
		label=more_platform_name,color=:gold2,marker=:star5,markersize=16)
	lines!(ax0, GeoMakie.coastlines(),color=:black)
	Legend(fi0[2, 1],[sc1,sc2,sc3,sc4],[sc1.label,sc2.label,sc3.label,sc4.label],
		orientation = :horizontal)
fi0
end

plot_OceanOPS2(s)=begin
	fi0,ax0,sc0=plot_base_Argo()
	sc1= (s==:ArgoPlanned ? plot_add(:Argo,2,col=:red) : plot_add(s,1,col=:red))
	Legend(fi0[2, 1],[sc0,sc1],[sc0.label,sc1.label],orientation = :horizontal)
	fi0
end

end

