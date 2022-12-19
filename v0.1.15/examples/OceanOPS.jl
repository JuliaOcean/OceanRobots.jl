### A Pluto.jl notebook ###
# v0.19.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ ccf98691-9386-41b9-a957-3cdeba51312b
begin
	import Pkg; Pkg.activate()
	using OceanRobots, CairoMakie, PlutoUI, GeoMakie
end

# ╔═╡ 5fa93c17-0a01-44c6-8679-d712c786907a
md"""# OceanOPS : a Global Metadata Base

Source : <https://www.ocean-ops.org/board>, <https://www.ocean-ops.org/share/>
"""

# ╔═╡ 596bce95-e13f-4439-858f-e944834c0924
begin
	bind_nam = @bind nam Select([:Argo,:Drifter])
	md"""## Explore Meta-Data

	Here you can select a data set and then a platform. Meta-data from that platform is displayed as a result.
	
	Data set : $(bind_nam)
	"""
end

# ╔═╡ aa80092c-80b9-489c-97b9-06c3d39ac594
begin
	list_data=OceanOPS.get_list(nam)
	bind_id = @bind id Select(list_data)
	md"""Platform ID : $(bind_id)"""
end

# ╔═╡ 401180a9-cb62-4dc6-b0a1-35df35f834db
begin
	meta=OceanOPS.get_platform(id)
	md"""
	| Item         | Value |
	|--------------|:-----------|
	| platform ID  | $(meta.id) |
	| status      | $(meta.status) |
	| country      | $(meta.country) |
	| ship      | $(meta.ship) |
	| deployed      | $(meta.deployed) |
	"""
end

# ╔═╡ 1042f70c-4337-4bf2-b533-edf27a422365
md"""## Visualize Data Cover

Each color represents one type of observing platform.
"""

# ╔═╡ 52dc1cd5-e57a-43bb-82c9-feb1de25e5ca
begin
	argo_operational=OceanOPS.get_list_pos(:Argo)
	
	a0=OceanOPS.get_list_pos(:Argo,status=:PROBABLE)
	a1=OceanOPS.get_list_pos(:Argo,status=:CONFIRMED)
	a2=OceanOPS.get_list_pos(:Argo,status=:REGISTERED)
	
	argo_planned=( lon=vcat(a0.lon,a1.lon,a2.lon),
				lat=vcat(a0.lat,a1.lat,a2.lat),
				flag=vcat(a0.flag,a1.flag,a2.flag))

	drifter_operational=OceanOPS.get_list_pos(:Drifter)

	mooring_operational=OceanOPS.get_list_pos(:Mooring)	
end

# ╔═╡ b6a138b0-fce5-4767-b4d1-eed0d0560988
let
	fi0=Figure()
	ax0=GeoAxis(fi0[1,1],coastlines = true)	
	scatter!(argo_operational.lon,argo_operational.lat,
		label="Argo (operational)",color=:blue,markersize=4)
	scatter!(argo_planned.lon,argo_planned.lat,
		label="Argo (planned)",color=:orange,marker=:xcross,markersize=8)
	scatter!(drifter_operational.lon,drifter_operational.lat,
		label="Drifter (operational)",color=:green2,marker='O',markersize=8)
	scatter!(mooring_operational.lon,mooring_operational.lat,
		label="Mooring (operational)",color=:brown3,marker=:star5,markersize=16)
	Legend(fi0[2, 1],ax0,orientation = :horizontal)
	fi0
end

# ╔═╡ ec963909-f9ee-4dd8-b9fa-4f34038c99e0
md"""## Visualize Data Cover (2)

Bue points show all Argo floats currently in operation. Red crosses shows the other selected data set.

!!! note
    This example use CSV files prepared by OceanOPS (rather than their API directly).
"""

# ╔═╡ f71390bd-6862-43be-84b9-005ff5742b5e
@bind s Select([:ArgoPlanned,:OceanOPS,:DBCP,:OceanGliders])

# ╔═╡ 1bf99223-ef46-4202-bdcc-8d7d6c561822
md"""## Appendices"""

# ╔═╡ 6d4c35fc-1a18-4fd7-a194-61fb387c7091
function plot_add(s=:OceanOPS,i=1;col=:red)
	tab=OceanOPS.get_table(s,i)
	nam=OceanOPS.csv_listings()[s][i]
	scatter!(tab.DEPL_LON,tab.DEPL_LAT,label=nam,markersize=8,marker=:xcross,color=col)
end

# ╔═╡ fbff1986-68c0-4558-b29b-2c6b87ca85fe
function plot_base_Argo()
	fi0=Figure()
	ax0=GeoAxis(fi0[1,1],coastlines = true)	
	tab=OceanOPS.get_table(:Argo,1)
	nam=OceanOPS.csv_listings()[:Argo][1]
	scatter!(tab.LATEST_LOC_LON,tab.LATEST_LOC_LAT,label=nam,markersize=4)
	fi0,ax0
end

# ╔═╡ 4b3f3ede-f1f0-4df5-931b-982a29395a53
begin
	fi0,ax0=plot_base_Argo()
	if s==:ArgoPlanned
		plot_add(:Argo,2,col=:red)
	else
		plot_add(s,1,col=:red)
	end
	Legend(fi0[2, 1],ax0,orientation = :horizontal)
	fi0
end


# ╔═╡ Cell order:
# ╟─5fa93c17-0a01-44c6-8679-d712c786907a
# ╟─596bce95-e13f-4439-858f-e944834c0924
# ╟─aa80092c-80b9-489c-97b9-06c3d39ac594
# ╟─401180a9-cb62-4dc6-b0a1-35df35f834db
# ╟─1042f70c-4337-4bf2-b533-edf27a422365
# ╟─52dc1cd5-e57a-43bb-82c9-feb1de25e5ca
# ╟─b6a138b0-fce5-4767-b4d1-eed0d0560988
# ╟─ec963909-f9ee-4dd8-b9fa-4f34038c99e0
# ╟─f71390bd-6862-43be-84b9-005ff5742b5e
# ╟─4b3f3ede-f1f0-4df5-931b-982a29395a53
# ╟─1bf99223-ef46-4202-bdcc-8d7d6c561822
# ╠═ccf98691-9386-41b9-a957-3cdeba51312b
# ╟─6d4c35fc-1a18-4fd7-a194-61fb387c7091
# ╟─fbff1986-68c0-4558-b29b-2c6b87ca85fe
