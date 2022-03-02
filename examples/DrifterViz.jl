
module DrifterViz

using OceanRobots, MeshArrays
import OceanRobots.CSV as CSV
import OceanRobots.DataFrames as DataFrames
using CairoMakie
import Proj4

export proj_map, animate_positions
export background_stuff, drifters_load_csv!

"""
    animate_positions(fig1,B, time_axis_method = 1)

Scatter plot of positions from B.df, on top of background map B.z, and generate a movie from loop over time.

```
using Main.DrifterViz

B=background_stuff();
drifters_load_csv!(B;y1=2007);

fig1=proj_map(B)
file1=animate_positions(fig1,B, time_axis_method = 0)
fig1

B.df[1]
```
"""
function animate_positions(F,B; framerate = 20, time_axis_method = 0, time_stamps=missing)
    if time_axis_method==1
        ts=time_stamps
        #ts = ( 0.5*876000.0 .+ (1:109)*876000.0 ) / 86400.0
        time = Observable(time_stamps[1])
        dt=3.0
        ii = @lift(findall( (B.df[1].d .> $time-dt).*(B.df[1].d .< $time+dt) ))
        tt = @lift( string(round($time; sigdigits=2)) )
    else
        time = Observable(0.0)
        ts = 0.0:0.01:3.0
        dt=3.0
        dd=@lift( 360.0*($time-floor.($time)) )
        ii = @lift(findall( (abs.(B.df[1].d .- $dd).<dt).|(abs.(B.df[1].d .- $dd).> 360.0-dt) ))
        tt = @lift( string(Int(floor($dd))) )
    end
    
    nmax=100000 #3*length(unique(B.df[1].ID))
    x = @lift( [B.df[1].x[$ii];fill(NaN,nmax-length($ii))])
    y = @lift( [B.df[1].y[$ii];fill(NaN,nmax-length($ii))])
    c = @lift( [B.df[1].col[$ii] ;fill(0,nmax-length($ii))])

    ax = F[1, 1]
    pnts = scatter!(ax, x, y, color=c, 
           colorrange=B.cr[1], colormap=B.cm[1], markersize=B.ms[1], strokewidth=0.0)
    xy=Proj4.transform(B.source, B.dest, [70.0 50.0])
    txt=text!(ax,tt,position = (xy[1],xy[2]),color=:red) #textsize = 1e6

    record(F, joinpath(tempdir(),"tmp.mp4"), ts; framerate = framerate) do t
        time[] = t
        #println(t)
    end
end

"""
    update_stuff!(B,t0,t1)

deprecated?    
"""
function update_stuff!(B,t0,t1)
    tst=(maximum(B.df[1].t)>t1)||(minimum(B.df[1].t)<t0)
    if tst
        pth,lst=DrifterViz.drifters_hourly_mat()
        tmp=readdir(pth)
        tmp=tmp[findall(occursin.("csv/drifters_",tmp))]
        y0=Int(floor(minimum(B.df[1].t)))

        df1=DataFrames.DataFrame(CSV.File(pth*"csv/drifters_$(y0).csv"))
        df2=DataFrames.DataFrame(CSV.File(pth*"csv/drifters_$(y0+1).csv"))
        B.df[1]=vcat(df1,df2)

        tt=sort(unique(B.df[1].t))[1:24:end]
        B.df[1]=filter(row -> sum(row.t .== tt)>0 ,B.df[1])
    end
end

"""
    subset_positions(B,t0,t1)

deprecated?
"""
function subset_positions(B,t0,t1)

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

Geographic projection map of B.z using geomakie
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
    ax = f[1, 1] = Axis(f,xticks = [0.0])

    surf = surface!(ax,B.x,B.y,0*B.x; color=col, colorrange = B.rng, colormap=:grayC,
        shading = false)
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

Load grid, interpolation, and projection specs.    
"""
function background_stuff()
    Γ=GridLoad(GridSpec("LatLonCap",MeshArrays.GRID_LLC90),option="full")
    
    #Global Ocean
    lo=[collect(20.5:1.0:179.5); collect(-179.5:1.0:19.5)]
    la=collect(-78.5:0.5:78.5)

    #North Pacific 
    # lo=[collect(110.0:0.5:180.0); collect(-180.0:0.5:-90.0)]
    # la=collect(-20.0:0.25:50.0)

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

    df=[DataFrames.DataFrame()]

    #speed as color scale
    cr=[(0.0,1.0)]
    cm=[:turbo]
    ms=[2.0]

    return (;lon,lat,DL,x,y,z,rng,source,dest,df,cm,cr,ms)
end

"""
    drifters_load_csv!(df::NamedTuple;y0=2005,y1=2018)

Load annual csv files created from the mat files (see `?drifters_hourly_mat`)
and subset to 1 data point per day.
"""
function drifters_load_csv!(B::NamedTuple;y0=2005,y1=2018)
    pth,lst=drifters_hourly_mat();

    for y=y0:y1
        println("loading $(y)")
        tmp=DataFrames.DataFrame(CSV.File(joinpath(pth,"csv","drifters_$(y).csv")))
        tt=sort(unique(tmp.t))[1:24:end]
        tmp=filter(row -> sum(row.t .== tt)>0 ,tmp)

        #geographical projection for plotting
        if isa(B.source,Proj4.Projection)&&isa(B.dest,Proj4.Projection)
            xy=Proj4.transform(B.source, B.dest, [vec(tmp.lon) vec(tmp.lat)])
            tmp.x=xy[:,1]
            tmp.y=xy[:,2]
        else
            tmp.x=tmp.lon
            tmp.y=tmp.lat
        end

        #pseudo-day of 360-day-year
        tmp.d=360.0*(tmp.t-floor.(tmp.t))

        #log10 of speed as color scale
        tmp.col = log10.(sqrt.(tmp.u.^2+tmp.v.^2))

        B.df[1]=vcat(B.df[1],tmp)
    end

    #log10 of speed as color scale
    B.cr[1]=(-2.0,0.0)
    B.cm[1]=:turbo
end

end