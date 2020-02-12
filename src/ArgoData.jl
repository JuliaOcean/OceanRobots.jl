module ArgoData

using NetCDF, Plots, Dates

export MITprof_read

"""
    MITprof_read(f::String="MITprof/MITprof_mar2016_argo9506.nc")

Standard Depth Argo Data Example.

Here we read the `MITprof` standard depth data set from https://doi.org/10.7910/DVN/EE3C40
For more information, please refer to Forget, et al 2015 (http://dx.doi.org/10.5194/gmd-8-3071-2015)
The produced figure shows the number of profiles as function of time for a chosen file
    and maps out the locations of Argo profiles collected for a chosen year.

```
using ArgoData, Plots

fi="MITprof/MITprof_mar2016_argo9506.nc"
(lo,la,ye)=MITprof_read(fi)

h = histogram(ye,bins=20,label=fi[end-10:end],title="Argo profiles")

ye0=2004; ye1=ye0.+1
kk=findall((ye.>ye0) .* (ye.<ye1))
scatter(lo[kk],la[kk],label=fi[end-10:end],title="Argo profiles count")
```
"""
function MITprof_read(f::String="MITprof/MITprof_mar2016_argo9506.nc")
    i = ncinfo(f)
    lo = ncread(f, "prof_lon")
    la = ncread(f, "prof_lat")
    x = ncread(f, "prof_date")
    t = julian2datetime.( datetime2julian(DateTime(0)) .+ x )
    ye = year.(t) + dayofyear.(t) ./ 365.0 #neglecting leap years ...
    return lo,la,ye
end

end # module
