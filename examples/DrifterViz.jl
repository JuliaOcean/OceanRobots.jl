#using GLMakie
#AbstractPlotting.inline!(true)
using CairoMakie

#using ColorSchemes
#using FixedPointNumbers

module DrifterViz

using OceanRobots, MeshArrays, CSV, DataFrames, Makie
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
    #timestamps = 2005.1:0.01:2018.9
    timestamps = 0.0:0.01:3.0
    framerate = 20

    #dt=0.1
    #ii = @lift(findall( (B.df[1].t .> $time-dt).*(B.df[1].t .< $time+dt) ))
    #tt = @lift( string($time) )

    dt=3.0
    dd=@lift( 360.0*($time-floor.($time)) )
    ii = @lift(findall( (abs.(B.df[1].d .- $dd).<dt).|(abs.(B.df[1].d .- $dd).> 360.0-dt) ))
    tt = @lift( string(Int(floor($dd))) )
    
    nmax=100000
    x = @lift( [B.df[1].x[$ii];fill(NaN,nmax-length($ii))])
    y = @lift( [B.df[1].y[$ii];fill(NaN,nmax-length($ii))])
    if true        
        c = @lift( [ sqrt.(B.df[1].u[$ii].^2+B.df[1].v[$ii].^2) ;fill(NaN,nmax-length($ii))])
        cr=(0.,5.0)
    else
        c = @lift( [B.df[1].u[$ii];fill(NaN,nmax-length($ii))])
        cr = (-0.4, 0.4)
    end

    F=DrifterViz.proj_map(B)
    ax = F[1, 1]
    pnts = scatter!(ax, x, y, show_axis = false, color=c, colorrange=cr,
    colormap=:turbo, markersize=2, strokewidth=0.0)

    xy=Proj4.transform(B.source, B.dest, [70.0 50.0])
    txt=text!(ax,tt,position = (xy[1],xy[2]),color=:red) #textsize = 1e6

    N=record(F, joinpath(tempdir(),"tmp.mp4"), timestamps; framerate = framerate) do t
        time[] = t
        #println(t)
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
        tmp=tmp[findall(occursin.("csv/drifters_",tmp))]
        y0=Int(floor(minimum(B.df[1].t)))

        df1=DataFrame(CSV.File(pth*"csv/drifters_$(y0).csv"))
        df2=DataFrame(CSV.File(pth*"csv/drifters_$(y0+1).csv"))
        B.df[1]=vcat(df1,df2)

        tt=sort(unique(B.df[1].t))[1:24:end]
        B.df[1]=filter(row -> sum(row.t .== tt)>0 ,B.df[1])
    end
end

"""
    subset_positions(B,t0,t1)
"""
#update the observables
function subset_positions(B,t0,t1)
    #update_stuff!(B,t0,t1)
    #
    df=B.df[1]
    df=df[df.t .> t0,:]
    df=df[df.t .<= t1,:]

    #
    nmax=100000
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

    surf = surface!(ax,B.x,B.y,0*B.x; color=col, colorrange = B.rng, colormap=:grayC,
        shading = false, scale_plot = false, axis = (xticks = [0.0],))
    #cbar=Colorbar(f,surf, width = 20)
    #f[1, 2] = cbar

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
    
#Global Ocean
    lo=[collect(20.5:1.0:179.5); collect(-179.5:1.0:19.5)]
    la=collect(-78.5:0.5:78.5)

#North Pacific 
#    lo=[collect(110.0:0.5:180.0); collect(-180.0:0.5:-90.0)]
#    la=collect(-20.0:0.25:50.0)

    lon=[i for i in lo, j in la]
    lat=[j for i in lo, j in la]

    (f,i,j,w)=InterpolationFactors(Γ,vec(lon),vec(lat))
    
    DL=log10.(Interpolate(Γ.Depth,f,i,j,w))
    DL[findall((!isfinite).(DL))].=NaN
    DL=reshape(DL,size(lon))
    rng=(3.,5.)

    ##

    source=Proj4.Projection("+proj=longlat +datum=WGS84")
    dest=Proj4.Projection("+proj=eqearth +lon_0=200.0 +lat_1=0.0 +x_0=0.0 +y_0=0.0 +ellps=GRS80")

    tmp=Proj4.transform(source, dest, [lon[:] lat[:]])
    x=reshape(tmp[:,1],size(lon))
    y=reshape(tmp[:,2],size(lon))
    z=DL

    ##

    pth,lst=drifters_ElipotEtAl16();

    y0=2005
    y1=2018
    df=[DataFrame()]
    for y=y0:y1
        println("loading $(y)")
        tmp=DataFrame(CSV.File(pth*"csv/drifters_$(y).csv"))
        tt=sort(unique(tmp.t))[1:24:end]
        tmp=filter(row -> sum(row.t .== tt)>0 ,tmp)

        #geographical projection for plotting
        xy=Proj4.transform(source, dest, [vec(tmp.lon) vec(tmp.lat)])
        tmp.x=xy[:,1]
        tmp.y=xy[:,2]

        #pseudo-day of 360-day-year
        tmp.d=360.0*(tmp.t-floor.(tmp.t))
    
        df[1]=vcat(df[1],tmp)
    end

    return (;lon,lat,DL,x,y,z,rng,source,dest,df)
end

end