using GLMakie
AbstractPlotting.inline!(true)

#using ColorSchemes
#using FixedPointNumbers

module DrifterViz

using OceanRobots, MeshArrays, GLMakie, CSV, DataFrames
import Proj4

export proj_map, subset_positions, animate_positions
export background_stuff, update_stuff!

"""
    animate_positions()

Plot positions in a loop, generate a movie

```
#tt=collect(2000:0.1:2003)
animate_positions(B)
```
"""
function animate_positions(B)
    time = Node(2005.1)
    timestamps = 2005.1:0.01:2010.1
    framerate = 20

    dt=0.1
    t0 = @lift($time-dt)
    t1 = @lift($time+dt)
    #(x,y) = @lift( DrifterViz.subset_positions(B,$(t0),$(t1)) )
    xy = @lift( DrifterViz.subset_positions(B,$(t0),$(t1)) )
    x = @lift($xy[:,1])
    y = @lift($xy[:,2])
    
    #f=scatter(x,y)
    #record(f, "tmp.mp4", timestamps; framerate = 30) do t
    #    time[] = t
    #end
    
    F=DrifterViz.proj_map(B)
    ax = F[1, 1]
    pnts = scatter!(ax, x, y, show_axis = false, color=:white, markersize=3, strokewidth=0.0)

    #xy=Proj4.transform(B.source, B.dest, [70.0 50.0])
    #txt=text!(ax,"$t0",position = (xy[1],xy[2]),color=:red) #textsize = 1e6

    N=record(F, joinpath(tempdir(),"tmp.mp4"), timestamps; framerate = framerate) do t
        time[] = t
    end

    return F,N
end

"""
    update_stuff!(B,t0,t1)
"""
function update_stuff!(B,t0,t1)
    tst=(maximum(B.df[1].t)>t1)||(minimum(B.df[1].t)<t0)
    if tst
        pth,lst=DrifterViz.drifters_ElipotEtAl16()
        tmp=readdir(pth)
        tmp=tmp[findall(occursin.("driftertraj_",tmp))]
        y0=Int(floor(minimum(B.df[1].t)))
        df1=DataFrame(CSV.File(pth*"driftertraj_$(y0).csv"))
        df2=DataFrame(CSV.File(pth*"driftertraj_$(y0+1).csv"))
        B.df[1]=vcat(df1,df2)
    end
end

"""
    subset_positions(B,t0,t1)
"""
#update the observables
function subset_positions(B,t0,t1)
    update_stuff!(B,t0,t1)
    #
    df=B.df[1]
    df=df[df.t .> t0,:]
    df=df[df.t .<= t1,:]
    #
    nmax=1000000
    xy=fill(NaN,nmax,2)
    npos=length(df.lon)
    npos>nmax ? println("nmax exceeded; skipping data") : nothing #println("$npos")
    npos=min(npos,nmax)
    xy[1:npos,:]=Proj4.transform(B.source, B.dest, [vec(df.lon[1:npos]) vec(df.lat[1:npos])])
    #
    return xy
end

"""
    proj_map(B::NamedTuple)

Geographic projection map of c using geomakie

```
B=DrifterViz.background_stuff();
F=DrifterViz.proj_map(B);
#df=DrifterViz.subset_positions(B,2005.15,2005.16)
F,N=DrifterViz.animate_positions(B)
F
```
"""
function proj_map(B::NamedTuple)
#    @unpack x, y, DL= B

    col=deepcopy(B.z)
    msk=findall(isnan.(B.z))
    col[msk].=Inf

#    if isa(B.rng,Tuple)
#        col=get(ColorSchemes.balance, col, B.rng)
#        col=to_color.(col)
#        col[msk].=RGBA{Float64}(1.,1.,1.,0.)
#    end

    f = Figure()
    ax = f[1, 1] = Axis(f)

    surf = surface!(ax,B.x,B.y,0*B.x; color=col, colorrange = B.rng, 
        shading = false, scale_plot = false, axis = (xticks = [0.0],))
    cbar=Colorbar(f,surf, width = 20)
    f[1, 2] = cbar

    ii=[i for i in -180:45:180, j in -78.5:1.0:78.5]';
    jj=[j for i in -180:45:180, j in -78.5:1.0:78.5]';
    xl=vcat([[ii[:,i]; NaN] for i in 1:size(ii,2)]...)
    yl=vcat([[jj[:,i]; NaN] for i in 1:size(ii,2)]...)
    tmp=Proj4.transform(B.source, B.dest,[xl[:] yl[:]])
    xl=tmp[:,1]; yl=tmp[:,2]
    lines!(xl,yl, color = :white, linewidth = 0.5)

    tmp=circshift(-179.5:1.0:179.5,(-200))
    ii=[i for i in tmp, j in -75:15:75];
    jj=[j for i in tmp, j in -75:15:75];
    xl=vcat([[ii[:,i]; NaN] for i in 1:size(ii,2)]...)
    yl=vcat([[jj[:,i]; NaN] for i in 1:size(ii,2)]...)
    tmp=Proj4.transform(B.source, B.dest,[xl[:] yl[:]])
    xl=tmp[:,1]; yl=tmp[:,2]
    lines!(xl,yl, color = :white, linewidth = 0.5)

    hidespines!(ax)
    hidedecorations!.(ax)

    return f
end

##

"""
    background_stuff()
"""
function background_stuff()
    Γ=GridLoad(GridSpec("LatLonCap",MeshArrays.GRID_LLC90))
    
    lon=[i for i=-179.5:1.0:179.5, j=-78.5:1.0:78.5]
    lat=[j for i=-179.5:1.0:179.5, j=-78.5:1.0:78.5]
    (f,i,j,w)=InterpolationFactors(Γ,vec(lon),vec(lat))
    
    DL=log10.(Interpolate(Γ["Depth"],f,i,j,w))
    DL[findall((!isfinite).(DL))].=NaN
    DL=reshape(DL,size(lon))
    rng=(3.,4.)

    ##

    source=Proj4.Projection("+proj=longlat +datum=WGS84")
    dest=Proj4.Projection("+proj=wintri +lon_0=200.0 +lat_1=0.0 +x_0=0.0 +y_0=0.0 +ellps=GRS80")

    tmp=Proj4.transform(source, dest, [lon[:] lat[:]])
    x=circshift(reshape(tmp[:,1],size(lon)),(-200,0))
    y=circshift(reshape(tmp[:,2],size(lon)),(-200,0))
    z=circshift(DL,(-200,0))

    ##

    pth,lst=drifters_ElipotEtAl16();
    y0=2005
    df1=DataFrame(CSV.File(pth*"driftertraj_$(y0).csv"))
    df2=DataFrame(CSV.File(pth*"driftertraj_$(y0+1).csv"))
    df=[vcat(df1,df2)]

    return (;lon,lat,DL,x,y,z,rng,source,dest,df)
end

end