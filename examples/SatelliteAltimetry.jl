### A Pluto.jl notebook ###
# v0.19.19

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

# ╔═╡ a8e0b727-a416-4aad-b660-69e5470c7e9e
begin
	using Pkg; Pkg.activate()
	using GLMakie, OceanRobots, Statistics, NCDatasets, PlutoUI
end

# ╔═╡ ec8cbf44-82d9-11ed-0131-1bdea9285f79
module some_plots

using GLMakie, NCDatasets, Statistics

function prep_movie(ds)
	lon=ds["lon"][:]
	lat=ds["lat"][:]
	store=ds["SLA"][:]
	#store_mean=mean(store,dims=(1,2))[:]
	nt=size(store,3)
	kk=findall((!isnan).(store[:,:,end]))

	n=Observable(1)
	SLA=@lift(store[:,:,$n])
	SLA2=@lift($(SLA).-mean($(SLA)[kk]))
    fig,_,_=heatmap(lon,lat,SLA2,
        colorrange=0.2.*(-1.0,1.0),colormap=:thermal)

	fig,n,nt
end

function make_movie(ds,tt; framerate = 90)
	fig,n,nt=prep_movie(ds)
    record(fig,tempname()*".mp4", tt; framerate = framerate) do t
        n[] = t
    end
end

end #module plots


# ╔═╡ a58cc4b4-7023-4dcf-a5f4-6366be8047a3
TableOfContents()

# ╔═╡ 62e0b8a9-0025-4ce7-9538-b6114d97b762
md"""## Data and Viz"""

# ╔═╡ 311522c5-b456-4396-8503-d7cd208c3f9a
@bind fil Select(["sla_podaac.nc","sla_cmems.nc"])

# ╔═╡ 9b3c3856-9fe1-43ba-97a2-abcd5b385c1d
ds=Dataset(fil)

# ╔═╡ a45bbdbd-3793-4e69-b042-39a4a1ac7ed7
begin
	fig,n,nt=some_plots.prep_movie(ds)
	fig
end

# ╔═╡ 8fbd1b1d-affe-4e30-a3b2-f2584e459003
fil_mp4=some_plots.make_movie(ds,1:nt,framerate=Int(floor(nt/60)))
#fil_mp4="/var/folders/1m/ddjxkwvn7bz7z9shdnh8q3040000gn/T/jl_pCZyXaVwFi.mp4"

# ╔═╡ 2d5611a9-b8ea-4d26-8ca3-edff9f2ebfdd
#PlutoUI.Resource("https://i.imgur.com/SAzsMMA.jpg")
#PlutoUI.Resource(fil_mp4)
LocalResource(fil_mp4,:width=>400)

# ╔═╡ 1cf2cdb9-3c09-4b39-81cf-49318c16f531
md"""## Julia Codes"""

# ╔═╡ Cell order:
# ╠═a58cc4b4-7023-4dcf-a5f4-6366be8047a3
# ╟─62e0b8a9-0025-4ce7-9538-b6114d97b762
# ╟─311522c5-b456-4396-8503-d7cd208c3f9a
# ╟─a45bbdbd-3793-4e69-b042-39a4a1ac7ed7
# ╠═8fbd1b1d-affe-4e30-a3b2-f2584e459003
# ╟─2d5611a9-b8ea-4d26-8ca3-edff9f2ebfdd
# ╟─9b3c3856-9fe1-43ba-97a2-abcd5b385c1d
# ╟─1cf2cdb9-3c09-4b39-81cf-49318c16f531
# ╟─ec8cbf44-82d9-11ed-0131-1bdea9285f79
# ╠═a8e0b727-a416-4aad-b660-69e5470c7e9e
