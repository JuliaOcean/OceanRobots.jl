# Tutorial Notebooks

!!! note
    - The version of the notebooks found in the online docs is static `html` rendering (this website).
    - The version found in the `src` folder is the underlying code of the notebooks (`.jl` files).
    - To run the notebooks interactively see [How-To](@ref) section.

## Dataset Notebooks

Ship-based Observatories : 

- [ShipCruise\_CCHDO.html](ShipCruise_CCHDO.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/ShipCruise_CCHDO.jl)) : [CTD rosette](https://cchdo.ucsd.edu) and related data
- [XBT\_transect.html](XBT_transect.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/XBT_transect.jl)) : expendable Bathythermograph ([XBT](https://www-hrx.ucsd.edu/index.html)) data

Drifting Observatories : 

- [Float\_Argo.html](Float_Argo.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Float_Argo.jl)) : Argo profiling [float](https://argo.ucsd.edu) data
- [Drifter\_GDP.html](Drifter_GDP.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Drifter_GDP.jl)) : near-surface [drifter](https://www.aoml.noaa.gov/phod/gdp/hourly_data.php) time series
- [Drifter\_CloudDrift.html](Drifter_CloudDrift.html) (➭ [code link](https://github.com/JuliaOcean/OceanRobots.jl/blob/master/examples/Drifter_CloudDrift.jl)) : near-surface drifter statistics
- [Glider\_Spray.html](Glider_Spray.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Glider_Spray.jl)) : underwater [glider](http://spraydata.ucsd.edu/projects/) data
- [CPR\_notebook.html](CPR_notebook.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/CPR_notebook.jl) : Continuous Plankton Recorder (PCR) data

Moored Observatories : 

- [Buoy\_NWP\_NOAA.html](Buoy_NWP_NOAA.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Buoy_NWP_NOAA.jl)) : NOAA [station](https://www.ndbc.noaa.gov/) data (a few days)
- [Buoy\_NWP\_NOAA\_monthly.html](Buoy_NWP_NOAA_monthly.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Buoy_NWP_NOAA_monthly.jl)) : NOAA [station](https://www.ndbc.noaa.gov/) data (monthly means) 
- [Mooring\_WHOTS.html](Mooring_WHOTS.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Mooring_WHOTS.jl)) : WHOTS [mooring](http://www.soest.hawaii.edu/whots/wh_data.html) data

## External APIs

- [OceanOPS.html](OceanOPS.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/OceanOPS.jl)) : global fleet of ocean observing systems
- [Roce\_interop.jl](Roce_interop.html) (➭ [code link](https://raw.githubusercontent.com/JuliaOcean/OceanRobots.jl/master/examples/Roce_interop.jl)) : [R-oce toolbox](https://dankelley.github.io/oce/).
- [Argo\_argopy.html](https://euroargodev.github.io/ArgoData.jl/dev/Argo_argopy.html) (➭ [code link](https://raw.githubusercontent.com/euroargodev/ArgoData.jl/refs/heads/master/examples/Argo_argopy.jl)) : [argopy python toolbox](https://github.com/euroargodev/argopy#readme).
	
## More Notebooks

- For Argo and state estimates, see [ArgoData.jl](https://github.com/JuliaOcean/ArgoData.jl)
- For simulations of drifter data, see [IndividualDisplacements.jl](https://github.com/JuliaClimate/IndividualDisplacements.jl)
