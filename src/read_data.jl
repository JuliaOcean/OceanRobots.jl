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
pth,list=drifters_ElipotEtAl16()
```
"""
function drifters_ElipotEtAl16()
    pth="Drifter_hourly_v013/"
    lst=["driftertrajGPS_1.03.nc","driftertrajWMLE_1.02_block1.nc","driftertrajWMLE_1.02_block2.nc",
       "driftertrajWMLE_1.02_block3.nc","driftertrajWMLE_1.02_block4.nc","driftertrajWMLE_1.02_block5.nc",
       "driftertrajWMLE_1.02_block6.nc","driftertrajWMLE_1.03_block7.nc"]
    return pth,lst
 end   
 