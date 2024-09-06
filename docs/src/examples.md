# Tutorial Notebooks

!!! note
    - The version of the notebooks found in the online docs is static `html` rendering (this website).
    - The version found in the `src` folder is the underlying code of the notebooks (`.jl` files).
    - To run the notebooks interactively see [How-To](@ref) section.

## Included Notebooks

- [OceanOPS.html](OceanOPS.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/OceanOPS.jl)) : global ocean observing systems
- [ShipCruise\_CCHDO.html](ShipCruise_CCHDO.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/ShipCruise_CCHDO.jl)) : [ship](https://cchdo.ucsd.edu) CTD and other data
- [Float\_Argo.html](Float_Argo.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Float_Argo.jl)) : Argo profiling [float](https://argo.ucsd.edu) data
- [Drifter\_GDP.html](Drifter_GDP.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Drifter_GDP.jl)) : [drifter](https://www.aoml.noaa.gov/phod/gdp/hourly_data.php) time series
- [Drifter\_CloudDrift.html](Drifter_CloudDrift.html) (➭ [code link](https://github.com/JuliaOcean/OceanRobots.jl/blob/master/examples/Drifter_CloudDrift.jl)) : drifter statistics
- [Glider\_Spray.html](Glider_Spray.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Glider_Spray.jl)) : underwater [glider](http://spraydata.ucsd.edu/projects/) data
- [Buoy\_NWP\_NOAA.html](Buoy_NWP_NOAA.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Buoy_NWP_NOAA.jl)) : NOAA [station](https://www.ndbc.noaa.gov/) data (a few days)
- [Buoy\_NWP\_NOAA\_monthly.html](Buoy_NWP_NOAA_monthly.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Buoy_NWP_NOAA_monthly.jl)) : NOAA [station](https://www.ndbc.noaa.gov/) data (monthly means) 
- [Mooring\_WHOTS.html](Mooring_WHOTS.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Mooring_WHOTS.jl)) : WHOTS [mooring](http://www.soest.hawaii.edu/whots/wh_data.html) data
	
## More Notebooks

- For Argo and state estimates, see [ArgoData.jl](https://github.com/JuliaOcean/ArgoData.jl)
- For simulations of drifter data, see [IndividualDisplacements.jl](https://github.com/JuliaClimate/IndividualDisplacements.jl)
- [SatelliteAltimetry.html](SatelliteAltimetry.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/SatelliteAltimetry.jl)) : gridded satellite data

## How-To

To install `OceanRobots.jl` in `julia` proceed as usual via the package manager (`using Pkg; Pkg.add(OceanRobots)`).

To run a notebook interactively (`.jl` files) you want to use [Pluto.jl](https://github.com/fonsp/Pluto.jl). For example, copy and paste one of the above `code link`s in the [Pluto.jl interface](https://github.com/fonsp/Pluto.jl/wiki/🔎-Basic-Commands-in-Pluto). This will let you spin up the notebook in a web browser from the copied URL.

All you need to do beforehand is to install [julia](https://julialang.org) and `Pluto.jl`. The installation of OceanRobots.jl and other Julia packages will then happen automatically when you run the notebook. 

You can also download the notebooks folder and run them as normal Julia programs. We recommend runing each notebook in its own environment as shown below. 

!!! note
    To download OceanRobots.jl folder, which includes the notebooks folder, you can use `Git.jl`.

```
using Pkg; Pkg.add("Git"); using Git
url="https://github.com/JuliaOcean/OceanRobots.jl"
run(`$(git()) clone $(url)`)
```

```@example 1
using Pkg; Pkg.add("Pluto"); using Pluto

notebook="MITgcm.jl/examples/Float_Argo.jl"
import OceanRobots; path=dirname(dirname(pathof(OceanRobots))) #hide
notebook=joinpath(path,"examples","Float_Argo.jl") #hide
Pluto.activate_notebook_environment(notebook)
Pkg.instantiate()
include(notebook)
Pkg.activate("..") #hide
```
