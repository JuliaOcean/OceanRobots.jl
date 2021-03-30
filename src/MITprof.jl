module MITprof

using NetCDF, Dates

"""
    read(f::String="MITprof/MITprof_mar2016_argo9506.nc")

Standard Depth Argo Data Example.

Here we read the `MITprof` standard depth data set from `https://doi.org/10.7910/DVN/EE3C40`
For more information, please refer to Forget, et al 2015 (`http://dx.doi.org/10.5194/gmd-8-3071-2015`)
The produced figure shows the number of profiles as function of time for a chosen file
    and maps out the locations of Argo profiles collected for a chosen year.

```
using OceanRobots, Plots

fi="MITprof/MITprof_mar2016_argo9506.nc"
(lo,la,ye)=MITprof.read(fi)

h = histogram(ye,bins=20,label=fi[end-10:end],title="Argo profiles")

ye0=2004; ye1=ye0.+1
kk=findall((ye.>ye0) .* (ye.<ye1))
scatter(lo[kk],la[kk],label=fi[end-10:end],title="Argo profiles count")
```
"""
function read(f::String="MITprof/MITprof_mar2016_argo9506.nc")
    #i = ncinfo(f)
    lo = ncread(f, "prof_lon")
    la = ncread(f, "prof_lat")
    x = ncread(f, "prof_date")
    t = julian2datetime.( datetime2julian(DateTime(0)) .+ x )
    ye = year.(t) + dayofyear.(t) ./ 365.0 #neglecting leap years ...
    return Float64.(lo),Float64.(la),Float64.(ye)
end

"""
    loop(pth::String="profiles/")

Standard Depth Argo Data Collection -- see `?MITprof.read` for detail.
"""
function loop(pth::String="profiles/")
    λ=("MITprof_mar2016_argo9506.nc","MITprof_mar2016_argo0708.nc",
    "MITprof_mar2016_argo0910.nc","MITprof_mar2016_argo1112.nc",
    "MITprof_mar2016_argo1314.nc","MITprof_mar2016_argo1515.nc")

    lo=[]; la=[]; ye=[];
    for f=1:length(λ)
        (tmplo,tmpla,tmpye)=read(pth*λ[f])
        lo=cat(lo,tmplo,dims=1)
        la=cat(la,tmpla,dims=1)
        ye=cat(ye,tmpye,dims=1)
    end

    return Float64.(lo),Float64.(la),Float64.(ye)
end

end
