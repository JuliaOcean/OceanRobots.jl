
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
function read(x::ArgoFloat;wmo=2900668,files_list="")
    y=read(ArgoData.OneArgoFloat(),wmo=wmo,files_list=files_list)
    ArgoFloat(y.ID,y.data)
end

end
