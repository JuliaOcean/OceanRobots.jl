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
	using OceanRobots, CairoMakie, PlutoUI
end

# ╔═╡ 5fa93c17-0a01-44c6-8679-d712c786907a
md"""# OceanOPS reference data base

Source : <https://www.ocean-ops.org/board>, <https://www.ocean-ops.org/share/>
"""

# ╔═╡ ec963909-f9ee-4dd8-b9fa-4f34038c99e0
md"""## Select Additional Layer

The first two layers show 1. Argo floats currently in operation, and 2. Argo floats planned for deployment. The third layer is chosen via the selector below.
"""

# ╔═╡ f71390bd-6862-43be-84b9-005ff5742b5e
@bind s Select([:OceanOPS,:DBCP,:OceanGliders])

# ╔═╡ 1bf99223-ef46-4202-bdcc-8d7d6c561822
md"""## Appendices"""

# ╔═╡ 6d4c35fc-1a18-4fd7-a194-61fb387c7091
function plot_add(s=:OceanOPS,i=1)
	tab=OceanOPS.get_table(s,i)
	nam=OceanOPS.csv_listings()[s][i]
	scatter!(tab.DEPL_LON,tab.DEPL_LAT,label=nam,markersize=8,marker=:xcross)
end

# ╔═╡ fbff1986-68c0-4558-b29b-2c6b87ca85fe
function plot_base_Argo()
	fi0=Figure()
	ax0=Axis(fi0[1,1])	
	tab=OceanOPS.get_table(:Argo,1)
	nam=OceanOPS.csv_listings()[:Argo][1]
	scatter!(tab.LATEST_LOC_LON,tab.LATEST_LOC_LAT,label=nam,markersize=4)
	fi0,ax0
end

# ╔═╡ 4b3f3ede-f1f0-4df5-931b-982a29395a53
begin
	fi0,ax0=plot_base_Argo()
	plot_add(:Argo,2)
	plot_add(s,1)
	axislegend()
	fi0
end

# ╔═╡ Cell order:
# ╟─5fa93c17-0a01-44c6-8679-d712c786907a
# ╟─ec963909-f9ee-4dd8-b9fa-4f34038c99e0
# ╟─f71390bd-6862-43be-84b9-005ff5742b5e
# ╟─4b3f3ede-f1f0-4df5-931b-982a29395a53
# ╟─1bf99223-ef46-4202-bdcc-8d7d6c561822
# ╠═ccf98691-9386-41b9-a957-3cdeba51312b
# ╟─6d4c35fc-1a18-4fd7-a194-61fb387c7091
# ╟─fbff1986-68c0-4558-b29b-2c6b87ca85fe
