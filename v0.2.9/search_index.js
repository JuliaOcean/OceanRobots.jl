var documenterSearchIndex = {"docs":
[{"location":"contributing/#User-Directions","page":"User Directions","title":"User Directions","text":"","category":"section"},{"location":"contributing/#Table-of-Contents","page":"User Directions","title":"Table of Contents","text":"","category":"section"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"How to Install and Use\nHow to Seek Support\nHow to Contribute\nReporting Bugs\nSuggesting Enhancements\nCode Contribution\nPull Request Process\nLicense","category":"page"},{"location":"contributing/#how-to-install-use","page":"User Directions","title":"How to Install and Use","text":"","category":"section"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"To install OceanRobots.jl in julia proceed as usual via the package manager (using Pkg; Pkg.add(\"OceanRobots\")).","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"To run a notebook interactively (.jl files) you want to use Pluto.jl. For example, copy and paste one of the above code links in the Pluto.jl interface. This will let you spin up the notebook in a web browser from the copied URL.","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"All you need to do beforehand is to install julia and Pluto.jl. The installation of OceanRobots.jl and other Julia packages will then happen automatically when you run the notebook. ","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"You can also download the notebooks folder and run them as normal Julia programs. We recommend runing each notebook in its own environment as shown below. ","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"note: Note\nTo download OceanRobots.jl folder, which includes the notebooks folder, you can use Git.jl.","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"using Pkg; Pkg.add(\"Git\"); using Git\nurl=\"https://github.com/JuliaOcean/OceanRobots.jl\"\nrun(`$(git()) clone $(url)`)","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"using Pkg; Pkg.add(\"Pluto\"); using Pluto\n\nnotebook=\"MITgcm.jl/examples/Float_Argo.jl\"\nimport OceanRobots; path=dirname(dirname(pathof(OceanRobots))) #hide\nnotebook=joinpath(path,\"examples\",\"Float_Argo.jl\") #hide\nPluto.activate_notebook_environment(notebook)\nPkg.instantiate()\ninclude(notebook)\nPkg.activate(\"..\") #hide","category":"page"},{"location":"contributing/#how-to-seek-support","page":"User Directions","title":"How to Seek Support","text":"","category":"section"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"If something is unclear or proves difficult to use, please seek support by opening an issue on the repository.","category":"page"},{"location":"contributing/#how-to-contribute","page":"User Directions","title":"How to Contribute","text":"","category":"section"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"Thank you for considering contributing to OceanRobots.jl! If you're interested in contributing we want your help no matter how big or small a contribution you make! ","category":"page"},{"location":"contributing/#reporting-bugs","page":"User Directions","title":"Reporting Bugs","text":"","category":"section"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"If you encounter a bug, please help us fix it by following these steps:","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"Ensure the bug is not already reported by checking the issue tracker.\nIf the bug isn't reported, open a new issue. Clearly describe the issue, including steps to reproduce it.","category":"page"},{"location":"contributing/#suggesting-enhancements","page":"User Directions","title":"Suggesting Enhancements","text":"","category":"section"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"If you have ideas for enhancements, new features, or improvements, we'd love to hear them! Follow these steps:","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"Check the issue tracker to see if your suggestion has been discussed.\nIf not, open a new issue, providing a detailed description of your suggestion and the use case it addresses.","category":"page"},{"location":"contributing/#code-contribution","page":"User Directions","title":"Code Contribution","text":"","category":"section"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"If you'd like to contribute code to the project:","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"Fork the repository.\nClone your fork: git clone https://github.com/juliaocean/OceanRobots.jl\nCreate a new branch for your changes: git checkout -b feature-branch\nMake your changes and commit them with a clear message.\nPush your changes to your fork: git push origin feature-branch\nOpen a pull request against the master branch of the main repository.","category":"page"},{"location":"contributing/#pull-request-process","page":"User Directions","title":"Pull Request Process","text":"","category":"section"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"Please ensure your pull request follows these guidelines:","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"Adheres to the coding standards.\nIncludes relevant tests for new functionality.\nHas a clear commit history and messages.\nReferences the relevant issue if applicable.","category":"page"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"Please don't hesistate to get in touch to discuss, or with any questions!","category":"page"},{"location":"contributing/#license","page":"User Directions","title":"License","text":"","category":"section"},{"location":"contributing/","page":"User Directions","title":"User Directions","text":"By contributing to this project, you agree that your contributions will be licensed under the LICENSE file of this repository.","category":"page"},{"location":"examples/#Tutorial-Notebooks","page":"Notebooks","title":"Tutorial Notebooks","text":"","category":"section"},{"location":"examples/","page":"Notebooks","title":"Notebooks","text":"note: Note\nThe version of the notebooks found in the online docs is static html rendering (this website).\nThe version found in the src folder is the underlying code of the notebooks (.jl files).\nTo run the notebooks interactively see How-To section.","category":"page"},{"location":"examples/#Included-Notebooks","page":"Notebooks","title":"Included Notebooks","text":"","category":"section"},{"location":"examples/","page":"Notebooks","title":"Notebooks","text":"OceanOPS.html (➭ code link) : global ocean observing systems\nShipCruise_CCHDO.html (➭ code link) : ship CTD and other data\nFloat_Argo.html (➭ code link) : Argo profiling float data\nDrifter_GDP.html (➭ code link) : drifter time series\nDrifter_CloudDrift.html (➭ code link) : drifter statistics\nGlider_Spray.html (➭ code link) : underwater glider data\nBuoy_NWP_NOAA.html (➭ code link) : NOAA station data (a few days)\nBuoy_NWP_NOAA_monthly.html (➭ code link) : NOAA station data (monthly means) \nMooring_WHOTS.html (➭ code link) : WHOTS mooring data","category":"page"},{"location":"examples/#More-Notebooks","page":"Notebooks","title":"More Notebooks","text":"","category":"section"},{"location":"examples/","page":"Notebooks","title":"Notebooks","text":"For Argo and state estimates, see ArgoData.jl\nFor simulations of drifter data, see IndividualDisplacements.jl","category":"page"},{"location":"reference/#User-Interface-(API)","page":"User Interface","title":"User Interface (API)","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"Each type of ocean data gets :","category":"page"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"a simple read function that downloads data if needed.\na default plot function that depicts some of the data.","category":"page"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using MeshArrays, Shapefile, DataDeps\npol_file=demo.download_polygons(\"ne_110m_admin_0_countries.shp\")\npol=MeshArrays.read_polygons(pol_file)\nnothing #hide","category":"page"},{"location":"reference/#Supported-Datasets","page":"User Interface","title":"Supported Datasets","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"OceanOPS data base (OceanOPS.jl)\nSurface Drifters (Drifter_GDP.jl , Drifter_CloudDrift.jl)\nArgo Profilers (Float_Argo.jl)\nShip-Based CTD (ShipCruise_CCHDO.jl)\nNOAA Buoys (Buoy_NWP_NOAA.jl , Buoy_NWP_NOAA_monthly.jl)\nSpray Gliders (Glider_Spray.jl)\nWHOTS Mooring (Mooring_WHOTS.jl)","category":"page"},{"location":"reference/#Surface-Drifters","page":"User Interface","title":"Surface Drifters","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using OceanRobots, CairoMakie\ndrifter=read(SurfaceDrifter(),1)\nplot(drifter,pol=pol)","category":"page"},{"location":"reference/#Argo-Profilers","page":"User Interface","title":"Argo Profilers","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using OceanRobots, CairoMakie\nargo=read(ArgoFloat(),wmo=2900668)\nplot(argo,pol=pol)","category":"page"},{"location":"reference/#Ship-Based-CTD","page":"User Interface","title":"Ship-Based CTD","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using OceanRobots, CairoMakie\ncruise=ShipCruise(\"33RR20160208\")\nplot(cruise,variable=\"salinity\",colorrange=(33.5,35.0))","category":"page"},{"location":"reference/#NOAA-Buoys","page":"User Interface","title":"NOAA Buoys","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using OceanRobots, CairoMakie\nbuoy=read(NOAAbuoy(),41044)\nplot(buoy,[\"PRES\",\"ATMP\",\"WTMP\"],size=(900,600))","category":"page"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using OceanRobots, CairoMakie\nbuoy=read(NOAAbuoy_monthly(),44013)\nplot(buoy)","category":"page"},{"location":"reference/#WHOTS-Mooring","page":"User Interface","title":"WHOTS Mooring","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using OceanRobots\nwhots=read(OceanSite(),:WHOTS)\n\nusing CairoMakie, Dates\ndate1=DateTime(2005,1,1)\ndate2=DateTime(2005,2,1)\nplot(whots,date1,date2)","category":"page"},{"location":"reference/#Spray-Gliders","page":"User Interface","title":"Spray Gliders","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using OceanRobots, CairoMakie\ngliders=read(Gliders(),\"GulfStream.nc\")\nplot(gliders,1,pol=pol)","category":"page"},{"location":"reference/#read-methods","page":"User Interface","title":"read methods","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"read","category":"page"},{"location":"reference/#Base.read","page":"User Interface","title":"Base.read","text":"read(x::OceanSite, ID=:WHOTS)\n\nRead OceanSite data.    \n\n\n\n\n\nread(x::ArgoFloat;wmo=2900668)\n\nNote: the first time this method is used, it calls ArgoData.GDAC.files_list()  to get the list of Argo floats from server, and save it to a temporary file.\n\nusing OceanRobots\nread(ArgoFloat(),wmo=2900668)\n\n\n\n\n\nread(x::SurfaceDrifter,ii::Int)\n\nOpen file number ii from NOAA ftp server using NCDatasets.jl.\n\nServer : ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/\n\nNote: the first time this method is used, it calls GDP.list_files()  to get the list of drifters from server, and save it to a temporary file.\n\nusing OceanRobots\nsd=read(SurfaceDrifter(),1)\n\n\n\n\n\nread(x::SurfaceDrifter; ID=300234065515480, version=\"v2.01\")\n\nDownload file from NOAA http server read it using NCDatasets.jl.\n\nServer : https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/\n\nusing OceanRobots\nsd=read(SurfaceDrifter(),ID=300234065515480)\n\n\n\n\n\nread(x::CloudDrift, file)\n\nRead a GDP/CloudDrift file.    \n\n\n\n\n\nread(x::NOAAbuoy,args...)\n\nRead a NOAA buoy file (past month).    \n\n\n\n\n\nread(x::NOAAbuoy_monthly,args...)\n\nRead a NOAA buoy file (historical).    \n\n\n\n\n\nread(x::Gliders, file::String)\n\nRead a Spray Glider file.    \n\n\n\n\n\n","category":"function"},{"location":"reference/#plot-methods","page":"User Interface","title":"plot methods","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"plot","category":"page"},{"location":"reference/#MakieCore.plot","page":"User Interface","title":"MakieCore.plot","text":"plot(x::SurfaceDrifter;size=(900,600),pol=Any[])\n\nDefault plot for surface drifter data.\n\nsize let's you set the figure dimensions\npol is a set of polygons (e.g., continents) \n\nusing OceanRobots, CairoMakie\ndrifter=read(SurfaceDrifter(),1)\nplot(drifter)\n\n\n\n\n\nplot(x::OceanSite,d0,d1;size=(900,600))\n\nDefault plot for OceanSite (mooring data).\n\nd0,d1 are two dates in DateTime format\t\nsize let's you set the figure dimensions\npol is a set of polygons (e.g., continents) \n\nusing OceanRobots, Dates\nwhots=read(OceanSite(),:WHOTS)\nplot(whots,DateTime(2005,1,1),DateTime(2005,2,1),size=(900,600))\n\n\n\n\n\nplot(x::NOAAbuoy,variables; size=(900,600))\n\nDefault plot for NOAAbuoy (moored buoy data).\n\nvariables (String, or array of String) are variables to plot\nsize let's you set the figure dimensions\n\nusing OceanRobots, CairoMakie\nbuoy=read(NOAAbuoy(),41044)\nplot(buoy,[\"PRES\" \"WTMP\"],size=(900,600))\n\n\n\n\n\nplot(x::NOAAbuoy_monthly, variable=\"T(°F)\"; size=(900,600))\n\nDefault plot for NOAAbuoy_monthly (monthly averaged moored buoy data).\n\nvariable (String) is the variable to plot\nsize let's you set the figure dimensions\n\nusing OceanRobots\nbuoy=read(NOAAbuoy_monthly(),44013)\nplot(buoy)\n\n\n\n\n\nplot(x::ShipCruise; \n\tmarkersize=6,pol=Any[],colorrange=(2,20),\n\tsize=(900,600),variable=\"temperature\",apply_log10=false)\n\nDefault plot for ShipCruise (source : https://cchdo.ucsd.edu).\n\nvariable (String) is the variable to plot\nsize let's you set the figure dimensions\npol is a set of polygons (e.g., continents) \nif apply_log10=true then we apply log10\nmarkersize and colorrange are plotting parameters\n\nnote : the list of valid expocode values (e.g., \"33RR20160208\") can be found at https://usgoship.ucsd.edu/data/\n\nusing OceanRobots, CairoMakie\ncruise=ShipCruise(\"33RR20160208\")\nplot(cruise)\n\nor \n\nplot(cruise,variable=\"chi_up\",apply_log10=true,colorrange=(-12,-10))\n\n\n\n\n\nplot(x::Gliders,ID;size=(900,600),pol=Any[])\n\nDefault plot for glider data.\n\nID is an integer (currently between 0 and 56)\nsize let's you set the figure dimensions\npol is a set of polygons (e.g., continents) \n\nusing OceanRobots, CairoMakie\ngliders=read(Gliders(),\"GulfStream.nc\")\nplot(gliders,1,size=(900,600))\n\n\n\n\n\n","category":"function"},{"location":"reference/#Add-Ons","page":"User Interface","title":"Add-Ons","text":"","category":"section"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"note: Note\nTo put data in context, it is useful to download country polygons.","category":"page"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using MeshArrays, Shapefile, DataDeps, CairoMakie\npol_file=demo.download_polygons(\"ne_110m_admin_0_countries.shp\")\npol=MeshArrays.read_polygons(pol_file)\nplot(argo,pol=pol)","category":"page"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"note: Note\nTo put data in context, it is useful to download gridded data sets.","category":"page"},{"location":"reference/","page":"User Interface","title":"User Interface","text":"using Climatology, CairoMakie, NCDatasets\nSLA=read(SeaLevelAnomaly(name=\"sla_podaac\"))\nplot(SLA)","category":"page"},{"location":"#OceanRobots.jl","page":"Home","title":"OceanRobots.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package can be used to access, analyze, process, and simulate data generated by ocean robots. These ocean observing platforms collect observations in the field, and allow us to monitor climate.","category":"page"},{"location":"","page":"Home","title":"Home","text":"OceanRobots.jl includes profiling floats, drifters, gliders, and moorings as illustrated in the examples. It provides a unified and simple user interface to each of these data sets.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Pages = [\n    \"reference.md\",\n    \"examples.md\",\n    \"internals.md\",\n]\nDepth = 2","category":"page"},{"location":"","page":"Home","title":"Home","text":"Global Data Coverage Individual Data Platforms\n(Image: ) (Image: )","category":"page"},{"location":"internals/#Internals","page":"Internals","title":"Internals","text":"","category":"section"},{"location":"internals/","page":"Internals","title":"Internals","text":"","category":"page"},{"location":"internals/","page":"Internals","title":"Internals","text":"Modules = [OceanOPS, GDP, GDP_CloudDrift, NOAA, GliderFiles, OceanSites, CCHDO]","category":"page"},{"location":"internals/#OceanRobots.OceanOPS.get_list","page":"Internals","title":"OceanRobots.OceanOPS.get_list","text":"get_list(nam=:Argo; status=\"OPERATIONAL\")\n\nGet list of platform IDs from OceanOPS API.\n\nFor more information see \n\nhttps://www.ocean-ops.org/api/1/help/\nhttps://www.ocean-ops.org/api/1/help/?param=platformstatus\n\nlist_Argo1=OceanOPS.get_list(:Argo,status=\"OPERATIONAL\")\nlist_Argo2=OceanOPS.get_list(:Argo,status=\"CONFIRMED\")\nlist_Argo3=OceanOPS.get_list(:Argo,status=\"REGISTERED\")\nlist_Argo4=OceanOPS.get_list(:Argo,status=\"INACTIVE\")\n\n\n\n\n\n","category":"function"},{"location":"internals/#OceanRobots.OceanOPS.get_list_pos","page":"Internals","title":"OceanRobots.OceanOPS.get_list_pos","text":"get_list_pos(nam=:Argo; status=\"OPERATIONAL\")\n\nGet list of platform positions from OceanOPS API.\n\nFor more information see \n\nhttps://www.ocean-ops.org/api/1/help/\nhttps://www.ocean-ops.org/api/1/help/?param=platformstatus\n\n\n\n\n\n","category":"function"},{"location":"internals/#OceanRobots.OceanOPS.get_platform-Tuple{Any}","page":"Internals","title":"OceanRobots.OceanOPS.get_platform","text":"get_platform(i)\n\nGet info on platform with id=i (e.g., float or drifter) from OceanOPS API.\n\nFor more information see https://www.ocean-ops.org/api/1/help/\n\nlist_Drifter=OceanOPS.get_list(:Drifter)\ntmp=OceanOPS.get_platform(list_Drifter[1000])\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.OceanOPS.get_url","page":"Internals","title":"OceanRobots.OceanOPS.get_url","text":"get_url(nam=:Argo; status=\"OPERATIONAL\")\n\nAPI/GET URL to OceanOPS API that will list platforms of chosen type.\n\nTwo URLs are reported; the second includes platform positions.\n\nFor more information see \n\nhttps://www.ocean-ops.org/api/1/help/\nhttps://www.ocean-ops.org/api/1/help/?param=platformstatus\nhttps://www.ocean-ops.org/api/1/help/?param=platformtype\n\n\n\n\n\n","category":"function"},{"location":"internals/#OceanRobots.OceanOPS.list_platform_types-Tuple{}","page":"Internals","title":"OceanRobots.OceanOPS.list_platform_types","text":"list_platform_types()\n\nList platform types.\n\n\n\n\n\n","category":"method"},{"location":"internals/#Base.read-Tuple{SurfaceDrifter, Int64}","page":"Internals","title":"Base.read","text":"read(x::SurfaceDrifter,ii::Int)\n\nOpen file number ii from NOAA ftp server using NCDatasets.jl.\n\nServer : ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/\n\nNote: the first time this method is used, it calls GDP.list_files()  to get the list of drifters from server, and save it to a temporary file.\n\nusing OceanRobots\nsd=read(SurfaceDrifter(),1)\n\n\n\n\n\n","category":"method"},{"location":"internals/#Base.read-Tuple{SurfaceDrifter}","page":"Internals","title":"Base.read","text":"read(x::SurfaceDrifter; ID=300234065515480, version=\"v2.01\")\n\nDownload file from NOAA http server read it using NCDatasets.jl.\n\nServer : https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/\n\nusing OceanRobots\nsd=read(SurfaceDrifter(),ID=300234065515480)\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.GDP.download","page":"Internals","title":"OceanRobots.GDP.download","text":"download(list_files,ii=1)\n\nDownload one drifter file from NOAA ftp server.\n\nftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/\n\nlist_files=GDP.list_files()\nfil=GDP.download(list_files,1)\n\n\n\n\n\n","category":"function"},{"location":"internals/#OceanRobots.GDP.list_files-Tuple{}","page":"Internals","title":"OceanRobots.GDP.list_files","text":"list_files()\n\nGet list of drifter files from NOAA ftp server or the corresponding webpage.\n\nftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/\nhttps://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/\n\n\n\n\n\n","category":"method"},{"location":"internals/#Base.read-Tuple{CloudDrift, Any}","page":"Internals","title":"Base.read","text":"read(x::CloudDrift, file)\n\nRead a GDP/CloudDrift file.    \n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.GDP_CloudDrift.add_ID!-Tuple{Any, Any}","page":"Internals","title":"OceanRobots.GDP_CloudDrift.add_ID!","text":"add_ID!(df,ds)\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.GDP_CloudDrift.add_index!-Tuple{Any}","page":"Internals","title":"OceanRobots.GDP_CloudDrift.add_index!","text":"add_index!(df)\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.GDP_CloudDrift.region_subset-NTuple{4, Any}","page":"Internals","title":"OceanRobots.GDP_CloudDrift.region_subset","text":"region_subset(df,lons,lats,dates)\n\nSubset of df that's within specified date and position ranges.    \n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.GDP_CloudDrift.to_DataFrame-Tuple{Any}","page":"Internals","title":"OceanRobots.GDP_CloudDrift.to_DataFrame","text":"to_DataFrame(ds)\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.GDP_CloudDrift.to_Grid-Tuple{Any, Any}","page":"Internals","title":"OceanRobots.GDP_CloudDrift.to_Grid","text":"to_Grid(gdf,grid)\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.GDP_CloudDrift.trajectory_stats-Tuple{Any}","page":"Internals","title":"OceanRobots.GDP_CloudDrift.trajectory_stats","text":"trajectory_stats(gdf)\n\n\n\n\n\n","category":"method"},{"location":"internals/#Base.read-Tuple{NOAAbuoy, Vararg{Any}}","page":"Internals","title":"Base.read","text":"read(x::NOAAbuoy,args...)\n\nRead a NOAA buoy file (past month).    \n\n\n\n\n\n","category":"method"},{"location":"internals/#Base.read-Tuple{NOAAbuoy_monthly, Vararg{Any}}","page":"Internals","title":"Base.read","text":"read(x::NOAAbuoy_monthly,args...)\n\nRead a NOAA buoy file (historical).    \n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.NOAA.download","page":"Internals","title":"OceanRobots.NOAA.download","text":"NOAA.download(stations::Union(Array,Int),path=tempdir())\n\nDownload files listed in stations from ndbc.noaa.gov to path.\n\n\n\n\n\n","category":"function"},{"location":"internals/#OceanRobots.NOAA.download-2","page":"Internals","title":"OceanRobots.NOAA.download","text":"NOAA.download(sta::String,path=tempdir())\n\nDownload files for stations sta from ndbc.noaa.gov to path.\n\n\n\n\n\n","category":"function"},{"location":"internals/#OceanRobots.NOAA.download-Tuple{Any}","page":"Internals","title":"OceanRobots.NOAA.download","text":"NOAA.download(MC::ModelConfig)\n\nDownload files listed in MC.inputs[\"stations\"] from ndbc.noaa.gov to pathof(MC).\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.NOAA.download_historical_txt-Tuple{Any, Any}","page":"Internals","title":"OceanRobots.NOAA.download_historical_txt","text":"NOAA.download_historical_txt(ID,years)\n\nDownload files from https://www.ndbc.noaa.gov to temporary folder for chosen float ID and years.\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.NOAA.list_realtime-Tuple{}","page":"Internals","title":"OceanRobots.NOAA.list_realtime","text":"NOAA.list_realtime(;ext=:all)\n\nGet either files list from https://www.ndbc.noaa.gov/data/realtime2/ or list of buoy codes that provide some file type  (e.g. \"txt\" for \"Standard Meteorological Data\")\n\nlst0=NOAA.list_realtime()\nlst1=NOAA.list_realtime(ext=:txt)\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.NOAA.list_stations-Tuple{}","page":"Internals","title":"OceanRobots.NOAA.list_stations","text":"NOAA.list_stations()\n\nGet stations list from https://www.ndbc.noaa.gov/to_station.shtml\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.NOAA.read_historical_monthly","page":"Internals","title":"OceanRobots.NOAA.read_historical_monthly","text":"NOAA.read_historical_monthly(ID,years)\n\nRead files from https://www.ndbc.noaa.gov to temporary folder for chosen float ID and year y.\n\n\n\n\n\n","category":"function"},{"location":"internals/#OceanRobots.NOAA.read_historical_nc-Tuple{Any, Any}","page":"Internals","title":"OceanRobots.NOAA.read_historical_nc","text":"NOAA.read_historical_nc(ID,year)\n\nRead files from https://www.ndbc.noaa.gov to temporary folder for chosen float ID and year y.\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.NOAA.read_historical_txt-Tuple{Any, Any}","page":"Internals","title":"OceanRobots.NOAA.read_historical_txt","text":"NOAA.read_historical_txt(ID,y)\n\nRead files from https://www.ndbc.noaa.gov to temporary folder for chosen float ID and year y.\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.NOAA.read_station","page":"Internals","title":"OceanRobots.NOAA.read_station","text":"NOAA.read_station(station,path=tempdir())\n\nRead station file from specified path, and add meta-data (units and descriptions).\n\n\n\n\n\n","category":"function"},{"location":"internals/#Base.read","page":"Internals","title":"Base.read","text":"read(x::Gliders, file::String)\n\nRead a Spray Glider file.    \n\n\n\n\n\n","category":"function"},{"location":"internals/#Base.read-2","page":"Internals","title":"Base.read","text":"read(x::OceanSite, ID=:WHOTS)\n\nRead OceanSite data.    \n\n\n\n\n\n","category":"function"},{"location":"internals/#OceanRobots.OceanSites.index-Tuple{}","page":"Internals","title":"OceanRobots.OceanSites.index","text":"index()\n\nDownload, read and process the oceansites_index.txt file. Return a DataFrame.\n\noceansites_index=OceanSites.index()\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.OceanSites.read_WHOTS","page":"Internals","title":"OceanRobots.OceanSites.read_WHOTS","text":"read_WHOTS(fil)\n\nRead an WHOTS file.    \n\nfile=\"DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc\"\ndata,units=OceanSites.read_WHOTS(file)\n\n\n\n\n\n","category":"function"},{"location":"internals/#OceanRobots.OceanSites.read_variables-Tuple{Any, Vararg{Any}}","page":"Internals","title":"OceanRobots.OceanSites.read_variables","text":"read_variables(file,args...)\n\nOpen file from opendap server.\n\nfile=\"DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc\"\nOceanSites.read_variables(file,:lon,:lat,:time,:TEMP)\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.CCHDO.ancillary_files-Tuple{Union{String, Symbol}}","page":"Internals","title":"OceanRobots.CCHDO.ancillary_files","text":"ancillary_files(cruise::Union{Symbol,String})\n\nusing OceanRobots\nID=\"33RR20230722\"\nlist=OceanRobots.CCHDO.ancillary_files(ID)\n\n\n\n\n\n","category":"method"},{"location":"internals/#OceanRobots.CCHDO.download","page":"Internals","title":"OceanRobots.CCHDO.download","text":"CCHDO.download(cruise::Union(Symbol,Symbol[]),path=tempdir())\n\nDownload files listed in stations from cchdo.ucsd.edu/cruise/ to path.\n\nusing OceanRobots\nID=\"33RR20160208\"\npath=OceanRobots.CCHDO.download(ID)\n\n\n\n\n\n","category":"function"}]
}
