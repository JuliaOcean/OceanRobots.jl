"""
    drifters_ElipotEtAl16(pth,lst;chnk=Inf,rng=(-Inf,Inf))

Read near-surface [drifter data](https://doi.org/10.1002/2016JC011716) from the
[Global Drifter Program](https://doi.org/10.25921/7ntx-z961) into a DataFrame.

```
pth,lst=drifters_ElipotEtAl16()
df=drifters_ElipotEtAl16( pth*lst[end], rng=(2014.1,2014.2) )
```
"""
function drifters_ElipotEtAl16(fil::String;chnk=1000,rng=(-Inf,Inf))
    t=ncread(fil,"TIME")
    t_u=ncgetatt(fil,"TIME","units")
    lo=ncread(fil,"LON")
    la=ncread(fil,"LAT")
 
    ##
 
    ii=findall(isfinite.(lo.*la.*t))
 
    t=t[ii]
    lo=lo[ii]
    la=la[ii]
    ID=ncread(fil,"ID")[ii]
    DROGUE=ncread(fil,"DROGUE")[ii]
    U=ncread(fil,"U")[ii]
    V=ncread(fil,"V")[ii]
 
    ##
 
    t=timedecode(t, t_u)
    tmp=dayofyear.(t)+(hour.(t) + minute.(t)/60 ) /24
    t=year.(t)+tmp./daysinyear.(t)
 
    ii=findall( (t.>rng[1]).&(t.<=rng[2]).*(DROGUE.==1) )
 
    t=t[ii]
    lo=lo[ii]
    la=la[ii]
    ID=ID[ii]
    DROGUE=DROGUE[ii]
    U=U[ii]
    V=V[ii]
 
    ##
 
    df = DataFrame(ID=Int[], lon=Float64[], lat=Float64[], t=Float64[])
    !isinf(chnk) ? nn=Int(ceil(length(ii)/chnk)) : nn=1
    for jj=1:nn
       #println([jj nn])
       !isinf(chnk) ? i=(jj-1)*chnk.+(1:chnk) : i=(1:length(ii))
       i=i[findall(i.<length(ii))]
       append!(df,DataFrame(lon=lo[i], lat=la[i], t=t[i], ID=Int.(ID[i])))
    end
 
    return df
end
 
"""
    drifters_ElipotEtAl16()

Path name and file list for near-surface [drifter data](https://doi.org/10.1002/2016JC011716)
from the [Global Drifter Program](https://doi.org/10.25921/7ntx-z961)

```
pth,lst=drifters_ElipotEtAl16()
```
"""
function drifters_ElipotEtAl16()
    pth="Drifter_hourly_v013/"
    lst=["driftertrajGPS_1.03.nc","driftertrajWMLE_1.02_block1.nc","driftertrajWMLE_1.02_block2.nc",
       "driftertrajWMLE_1.02_block3.nc","driftertrajWMLE_1.02_block4.nc","driftertrajWMLE_1.02_block5.nc",
       "driftertrajWMLE_1.02_block6.nc","driftertrajWMLE_1.03_block7.nc"]
    return pth,lst
 end   
 
 """
    drifters_ElipotEtAl16(t0::Number,t1::Number)

Loop over all files and call drifters_ElipotEtAl16 with rng=(t0,t1)

```
@everywhere using OceanRobots, CSV
@distributed for y in 2005:2020
    df=drifters_ElipotEtAl16(y+0.0,y+1.0)
    fil="Drifter_hourly_v013/driftertraj_"*string(y)*".csv"
    CSV.write(fil, df)
end
```
"""
function drifters_ElipotEtAl16( t0::Number,t1::Number )
    pth,lst=drifters_ElipotEtAl16()
    df = DataFrame([fill(Int, 1) ; fill(Float64, 3)], [:ID, :lon, :lat, :t])
    for fil in lst
       println(fil)
       append!(df,drifters_ElipotEtAl16( pth*fil,chnk=10000,rng=(t0,t1) ))
    end
    return df
 end
 