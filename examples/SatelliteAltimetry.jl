### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ a8e0b727-a416-4aad-b660-69e5470c7e9e
begin
	using Pkg; Pkg.activate()
	using GLMakie, OceanRobots, Statistics, NCDatasets
end

# ╔═╡ ec8cbf44-82d9-11ed-0131-1bdea9285f79
module cmems_plots

using GLMakie, NCDatasets, Statistics

function prep_movie(ds)
	lon=ds["lon"][:]
	lat=ds["lat"][:]
	store=ds["SLA"][:]
	store_mean=mean(store,dims=(1,2))[:]
	nt=length(store_mean)

	n=Observable(1)
    fig,_,_=heatmap(lon,lat,@lift(store[:,:,$n].-store_mean[$n]),
        colorrange=0.2.*(-1.0,1.0),colormap=:thermal)

	fig,n,nt
end

function make_movie(ds,tt)
	fig,n,nt=prep_movie(ds)
    record(fig,tempname()*".mp4", tt; framerate = 90) do t
        n[] = t
    end
end

end #module plots


# ╔═╡ 311522c5-b456-4396-8503-d7cd208c3f9a
fil="/var/folders/1m/ddjxkwvn7bz7z9shdnh8q3040000gn/T/jl_hgzKNcXCJS"

# ╔═╡ 9b3c3856-9fe1-43ba-97a2-abcd5b385c1d
ds=Dataset(fil)

# ╔═╡ a45bbdbd-3793-4e69-b042-39a4a1ac7ed7
begin
	fig,n,nt=cmems_plots.prep_movie(ds)
	fig
end

# ╔═╡ 58aa9f11-0bcf-4347-984e-e022e66c15ac
nt

# ╔═╡ 8fbd1b1d-affe-4e30-a3b2-f2584e459003
cmems_plots.make_movie(ds,9000:10000)

# ╔═╡ Cell order:
# ╠═a8e0b727-a416-4aad-b660-69e5470c7e9e
# ╠═311522c5-b456-4396-8503-d7cd208c3f9a
# ╟─9b3c3856-9fe1-43ba-97a2-abcd5b385c1d
# ╠═a45bbdbd-3793-4e69-b042-39a4a1ac7ed7
# ╠═58aa9f11-0bcf-4347-984e-e022e66c15ac
# ╠═8fbd1b1d-affe-4e30-a3b2-f2584e459003
# ╟─ec8cbf44-82d9-11ed-0131-1bdea9285f79
