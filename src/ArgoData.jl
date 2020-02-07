module ArgoData

using NetCDF, Plots, Dates

export MITprofDemo

"""
    MITprofDemo(f::String="MITprof/MITprof_mar2016_argo9506.nc")

Standard Depth Argo Data Example.

Here we use the `MITprof` data sets from [https://doi.org/10.7910/DVN/EE3C40]()
For more information, please refer to [Forget, et al 2015] (http://dx.doi.org/10.5194/gmd-8-3071-2015)
The produced figure shows the number of profiles as function of time for one file

```
(f,h)=MITprofDemo()
display(h)
```
"""
function MITprofDemo(f::String="MITprof/MITprof_mar2016_argo9506.nc")
    i = ncinfo(f)
    x = ncread(f, "prof_date")
    t = julian2datetime.( datetime2julian(DateTime(0)) .+ x )
    y = year.(t) + dayofyear.(t) ./ 365.0 #neglecting leap years ...
    h = histogram(y,bins=20,label=f,title=
        "number of Argo profiles with time")
    return f,h
end

end # module
