# OceanRobots.jl

[![CI](https://github.com/JuliaOcean/OceanRobots.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaOcean/OceanRobots.jl/actions/workflows/ci.yml)
[![Codecov](https://codecov.io/gh/JuliaOcean/OceanRobots.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaOcean/OceanRobots.jl)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaOcean.github.io/OceanRobots.jl/dev)

[![DOI](https://proceedings.juliacon.org/papers/10.21105/jcon.00164/status.svg)](https://doi.org/10.21105/jcon.00164)
[![DOI](https://zenodo.org/badge/352859934.svg)](https://zenodo.org/badge/latestdoi/352859934)
 
This package can be used to access, analyze, process, and simulate data generated by _ocean robots_. These ocean observing platforms collect observations in the field, and allow us to monitor climate.

`OceanRobots.jl` includes profiling floats, drifters, gliders, and moorings as illustrated in the examples listed below. It provides a unified and simple user interface to each of these data sets.

### Data Sets

<details>
 <summary> Global Fleet Now </summary>
<p>

Explore data coverage and data platforms.

👉 [OceanOPS notebook](https://juliaocean.github.io/OceanRobots.jl/dev/examples/OceanOPS.html) 👈

Global Data Coverage | Individual Data Platforms
:------------------------------:|:---------------------------------:
![](https://user-images.githubusercontent.com/20276764/208552147-d433f802-9c09-41cc-bece-f0ef424f26ea.png) | ![](https://user-images.githubusercontent.com/20276764/208441408-1ffe7508-19da-4f41-b984-58820799785a.png) 

</p>
</details>

<details>
 <summary> Research Ships </summary>
<p>

👉 [CTD Profiles notebook](https://juliaocean.github.io/OceanRobots.jl/dev/examples/ShipCruise_CCHDO.html) 👈

</p>
</details>

<details>
 <summary> Commercial Ships </summary>
<p>

👉 [XBT\_transect.html](https://juliaocean.github.io/OceanRobots.jl/dev/examples/XBT_transect.html) 👈

</p>
</details>


<details>
 <summary> Profiling Floats </summary>
<p>

👉 [Argo Float notebook](https://juliaocean.github.io/OceanRobots.jl/dev/examples/Float_Argo.html) 👈

Argo Float Track            |  Argo Float Profiles 
:------------------------------:|:---------------------------------:
![](https://user-images.githubusercontent.com/20276764/166470235-467a9326-18ae-4934-a866-2da06ec9ec84.png)  |  ![](https://user-images.githubusercontent.com/20276764/166470217-f89d2374-f57e-4a28-8220-86179e6c1f86.png)

</p>
</details>

<details>
 <summary> Surface Drifters </summary>
<p>


👉 [Drifter notebook 1](https://juliaocean.github.io/OceanRobots.jl/dev/examples/Drifter_GDP.html) 👈

![](https://user-images.githubusercontent.com/20276764/149673826-a43e2a44-f4e5-437b-99cb-5e032228b3af.png)

👉 [Drifter notebook 2](https://juliaocean.github.io/OceanRobots.jl/dev/examples/Drifter_CloudDrift.html) 👈

![](https://user-images.githubusercontent.com/20276764/205257672-f8adc8fc-dea7-4dea-91dd-ab9e1c18c1c1.png)

</p>
</details>

<details>
 <summary> Underwater Gliders </summary>
<p>

👉 [Glider notebook](https://juliaocean.github.io/OceanRobots.jl/dev/examples/https://juliaocean.github.io/OceanRobots.jl/dev/examples/Glider_Spray.html) 👈

![](https://user-images.githubusercontent.com/20276764/166470390-952e89df-60ad-4a45-b015-9469c3c297de.png)

</p>
</details>

<details>
 <summary> Moored Buoys </summary>
<p>

👉 [Buoy NWP NOAA notebook](https://juliaocean.github.io/OceanRobots.jl/dev/examples/Buoy_NWP_NOAA.html) 👈

![](https://user-images.githubusercontent.com/20276764/166470257-8a0421ff-b147-46aa-b03b-43e5f8b4d1b3.png)

👉 [Buoy NWP NOAA monthly notebook](https://juliaocean.github.io/OceanRobots.jl/dev/examples/Buoy_NWP_NOAA_monthly.html) 👈

![](https://user-images.githubusercontent.com/20276764/205256659-6505f41f-577a-481d-99e6-424073702699.png)

</p>
</details>

<details>
 <summary> WHOTS Mooring </summary>
<p>

![](https://user-images.githubusercontent.com/20276764/149675305-82364bde-e3a9-4975-8fb2-fb67e17dacc5.png)

</p>
</details>

### Installation

To install `OceanRobots.jl` in `julia` proceed as usual via the package manager.

`using Pkg; Pkg.add("OceanRobots")`

To download OceanRobots.jl folder, which includes the notebooks folder, you can use `Git.jl`.

```
using Pkg; Pkg.add("Git"); using Git
url="https://github.com/JuliaOcean/OceanRobots.jl"
run(`$(git()) clone $(url)`)
```
