
module OceanRobotsArgoDataExt

using OceanRobots, ArgoData
import Base: read

"""
    read(x::ArgoFloat;wmo=2900668)

Note: the first time this method is used, it calls `ArgoData.GDAC.files_list()` 
to get the list of Argo floats from server, and save it to a temporary file.

```
using OceanRobots, ArgoData
read(ArgoFloat(),wmo=2900668)
```
"""
read(x::ArgoFloat;wmo=2900668,files_list="") = begin
    isempty(files_list) ? nothing : @warn "specifycing files_list here is deprecated"
    lst=try
        ArgoFiles.list_floats()
    catch
        println("downloading floats list via ArgoData.jl")
        ArgoFiles.list_floats(list=GDAC.files_list())
    end
    fil=ArgoFiles.download(lst,wmo)
    arr=ArgoFiles.readfile(fil)
    ArgoFloat(wmo,arr)
end

end
