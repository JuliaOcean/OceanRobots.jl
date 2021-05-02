using GLMakie
AbstractPlotting.inline!(true)

#using ColorSchemes
#using FixedPointNumbers

module DrifterViz

using OceanRobots, MeshArrays, GLMakie, CSV, DataFrames
import Proj4

export animate_positions, proj_map, map_positions, background_stuff

"""
    animate_positions()

Plot positions in a loop, generate a movie

```
#tt=collect(2000:0.1:2003)
#df.y=2000 .+ df.t ./86400/365

#source = LonLat(); dest = WinkelTripel();
#scene = proj_map(DL,colorrange=(3.,4.))
#animate_positions(scene,df,tt,"tmp.mp4")
```
"""
function animate_positions()
    return false
end

function map_positions(F,B,df)
    ax = F[1, 1]

    nmax=10000
    x=fill(NaN,nmax)
    y=fill(NaN,nmax)
    x=df.lon; y=df.lat

    xy=Proj4.transform(B.source, B.dest, [vec(x) vec(y)])

    pnts = scatter!(ax,xy[:,1], xy[:,2],show_axis = false, color=:white, markersize=5)

    t0=1.2345678 #round(tt[1],digits=2)
    xy=Proj4.transform(B.source, B.dest, [70.0 50.0])
    txt=text!(ax,"$t0",position = (xy[1],xy[2]),color=:red) #textsize = 1e6

    return pnts,txt
end

"""
    proj_map(B::NamedTuple)

Geographic projection map of c using geomakie

```
B=DrifterViz.background_stuff();
F=DrifterViz.proj_map(B);
df=B.df[1:1000:end,:]
pnts,txt=DrifterViz.map_positions(F,B,df);
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
    df=DataFrame(CSV.File(pth*"driftertraj_2010.csv"))

    return (;lon,lat,DL,x,y,z,rng,source,dest,df)
end

end