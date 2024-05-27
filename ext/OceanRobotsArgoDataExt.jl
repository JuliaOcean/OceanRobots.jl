
module OceanRobotsArgoDataExt

using OceanRobots, ArgoData
import Base: read

"""
    read(x::ArgoFloat,wmo=2900668,files_list=GDAC.files_list())

```
using OceanRobots, ArgoData

wmo=2900668
lst=GDAC.files_list()
read(ArgoFloat(),wmo=2900668,files_list=lst)
```
"""
read(x::ArgoFloat;wmo=2900668,files_list=GDAC.files_list()) = begin
    fil=ArgoFiles.download(files_list,wmo)
    arr=ArgoFiles.readfile(fil)
    ArgoFloat(wmo,arr)
end

end
