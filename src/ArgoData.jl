module ArgoData

using NetCDF, Plots, Dates

export MITprofDemo

"""
    MITprofDemo()

Standard Depth Argo Data Example.

Here we use the `MITprof` data sets from [https://doi.org/10.7910/DVN/EE3C40]()
For more information, please refer to [Forget, et al 2015] (http://dx.doi.org/10.5194/gmd-8-3071-2015)

- [x] provide doi & ref for MITprof data set
- [x] read in MITprof data using NCDatasets.jl
- [x] plot number of profiles as function of time

```
(f,i,h)=MITprofDemo()
display(h)
```
"""
function MITprofDemo()
    f = "MITprof/MITprof_mar2016_argo9506.nc"
    i = ncinfo(f)
    x = ncread(f, "prof_date")
    h = histogram(x,title="number of Argo profiles with time")
    return f,i,h
end

end # module
