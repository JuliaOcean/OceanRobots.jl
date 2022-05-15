var documenterSearchIndex = {"docs":
[{"location":"#OceanRobots.jl","page":"Home","title":"OceanRobots.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Simulation, processing, and analysis of data generated by scientific robots in the Ocean. These include profiling floats, drifters, gliders, and moorings for examples.","category":"page"},{"location":"#Notebooks","page":"Home","title":"Notebooks","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The suite of examples includes :","category":"page"},{"location":"","page":"Home","title":"Home","text":"Buoy_NWP_NOAA.jl (➭ code link) : NOAA station data\nMooring_WHOTS.jl (➭ code link) : WHOTS mooring data\nDrifter_GDP.jl (➭ code link) : drifter time series\nFloat_Argo.jl (➭ code link) : Argo profiling float data\nGlider_Spray.jl (➭ code link) : underwater glider data.","category":"page"},{"location":"","page":"Home","title":"Home","text":"note: Note\nThe static html rendering of the notebooks (this website) lack the interactivity that comes from Running The Examples yourself.","category":"page"},{"location":"","page":"Home","title":"Home","text":"warning: Warning\nThis package is in early developement stage when breaking changes can be expected._","category":"page"},{"location":"#Running-The-Examples","page":"Home","title":"Running The Examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The examples are most easily run using Pluto.jl. To do it this way, one just needs to copy a code link provided above and paste this URL into the Pluto.jl interface.","category":"page"},{"location":"#Additional-examples","page":"Home","title":"Additional examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"For more on Argo : see ArgoData.jl\nDrifter_CloudDrift.jl \nBuoy_NWP_NOAA_monthly.jl ","category":"page"},{"location":"#Visual-Examples","page":"Home","title":"Visual Examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The plots below are generated by the notebook examples.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Argo Float Track Argo Float Profiles\n(Image: ) (Image: )\nGDP Surface Drifter Data WHOTS Mooring Data\n(Image: ) (Image: )\nSpray Glider Data NOAA Time series\n(Image: ) (Image: )","category":"page"},{"location":"#Functionalities","page":"Home","title":"Functionalities","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [GDP, NOAA, GliderFiles, ArgoFiles, OceanSites, THREDDS]","category":"page"},{"location":"#OceanRobots.GDP.download","page":"Home","title":"OceanRobots.GDP.download","text":"download(list_files,ii=1)\n\nDownload one drifter file from NOAA ftp server.\n\nftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/\n\nlist_files=GDP.list_files()\nfil=GDP.download(list_files,1)\n\n\n\n\n\n","category":"function"},{"location":"#OceanRobots.GDP.list_files-Tuple{}","page":"Home","title":"OceanRobots.GDP.list_files","text":"list_files()\n\nGet list of drifter files from NOAA ftp server or the corresponding webpage.\n\nftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/\nhttps://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.GDP.read-Tuple{String}","page":"Home","title":"OceanRobots.GDP.read","text":"read(filename::String)\n\nOpen file from NOAA ftp server using NCDatasets.Dataset.\n\nftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/ or the corresponding webpage \n\nlist_files=GDP.list_files()\nfil=GDP.download(list_files,1)\nds=GDP.read(fil)\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.NOAA.download-Tuple{Any}","page":"Home","title":"OceanRobots.NOAA.download","text":"NOAA.download(MC::ModelConfig)\n\nDownload files listed in MC.inputs[\"stations\"] from ndbc.noaa.gov to pathof(MC).\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.NOAA.read-Tuple{Any, Any}","page":"Home","title":"OceanRobots.NOAA.read","text":"NOAA.read(MC,sta)\n\nRead station sta file from pathof(MC). Meta-data is provided in NOAA.units and NOAA.descriptions.\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.GliderFiles.read-Tuple{String}","page":"Home","title":"OceanRobots.GliderFiles.read","text":"GliderFiles.read(file::String)\n\nRead a Spray Glider file.    \n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.ArgoFiles.download-Tuple{Any, Any}","page":"Home","title":"OceanRobots.ArgoFiles.download","text":"ArgoFiles.download(files_list,wmo)\n\nDownload an Argo profiler file.    \n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.ArgoFiles.read-Tuple{Any}","page":"Home","title":"OceanRobots.ArgoFiles.read","text":"ArgoFiles.read(fil)\n\nRead an Argo profiler file.    \n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.OceanSites.index-Tuple{}","page":"Home","title":"OceanRobots.OceanSites.index","text":"index()\n\nDownload, read and process the oceansites_index.txt file. Return a DataFrame.\n\noceansites_index=OceanSites.index()\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.OceanSites.read-Tuple{Any, Vararg{Any}}","page":"Home","title":"OceanRobots.OceanSites.read","text":"read(file,args...)\n\nOpen file from opendap server.\n\nfile=\"DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc\"\nOceanSites.read(file,:lon,:lat,:time,:TEMP)\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.OceanSites.read_WHOTS","page":"Home","title":"OceanRobots.OceanSites.read_WHOTS","text":"read_WHOTS(fil)\n\nRead an WHOTS file.    \n\nfile=\"DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc\"\ndata,units=OceanSites.read_WHOTS(file)\n\n\n\n\n\n","category":"function"},{"location":"#OceanRobots.THREDDS.parse_catalog","page":"Home","title":"OceanRobots.THREDDS.parse_catalog","text":"parse_catalog(url,recursive=true)\n\nStarting from an xml (not html) thredds catalog look for both subfolders and files; they are identified based on the href and urlPath attributes respectively. If recursive is set to true then go down in subfolders and do the same until only files are found; in this case the returned folders should be empty and files can be extensive.\n\nFor more on thredds servers, see https://www.unidata.ucar.edu/software/tds/current/catalog/.\n\nurl=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/long_timeseries/WHOTS/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/data/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites-tao/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/tao-ctd/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/hfradar/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/catalog.xml\"\n\nfiles,folders=parse_catalog(url)\n\n\n\n\n\n","category":"function"}]
}
