var documenterSearchIndex = {"docs":
[{"location":"#OceanRobots.jl","page":"Home","title":"OceanRobots.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Simulation, processing, and analysis of data generated by scientific robots in the Ocean. These include profiling floats (Argo), drifters (GDP), and moorings for examples.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The suite of examples includes :","category":"page"},{"location":"","page":"Home","title":"Home","text":"Buoy_NWP_NOAA.jl (➭ code link) : NOAA station data\nMooring_WHOTS.jl (➭ code link) : WHOTS mooring data\nDrifter_GDP.jl (➭ code link) : drifter time series\nFloat_Argo.jl (➭ code link) : Argo profiling float data\nSpray_Glider.jl (➭ code link) : underwater glider data.","category":"page"},{"location":"","page":"Home","title":"Home","text":"note: Note\nThe static html rendering of the notebooks (this website) lack the interactivity that comes from Running The Examples yourself.","category":"page"},{"location":"","page":"Home","title":"Home","text":"warning: Warning\nThis package is in early developement stage when breaking changes can be expected._","category":"page"},{"location":"#Running-The-Examples","page":"Home","title":"Running The Examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The examples are most easily run using Pluto.jl. To do it this way, one just needs to copy a code link provided above and paste this URL into the Pluto.jl interface.","category":"page"},{"location":"#Additional-examples:","page":"Home","title":"Additional examples:","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"For more on Argo : see companion package ArgoData.jl\nDrifter_CloudDrift.jl ","category":"page"},{"location":"#Graphical-Examples","page":"Home","title":"Graphical Examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Argo Float Profiles Argo Float Track\n(Image: ) (Image: )\nSurface Drifter Track Mooring Time series\n(Image: ) (Image: )","category":"page"},{"location":"#Functionalities","page":"Home","title":"Functionalities","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [OceanRobots, GDP, NOAA, Spray_Glider, ArgoFiles, WHOTS, THREDDS]","category":"page"},{"location":"#OceanRobots.GDP.download","page":"Home","title":"OceanRobots.GDP.download","text":"download(list_files,ii=1)\n\nDownload one drifter file from NOAA ftp server      ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/ or the corresponding webpage  https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/.\n\nlist_files=GDP.list_files()\nfil=GDP.download(list_files,1)\n\n\n\n\n\n","category":"function"},{"location":"#OceanRobots.GDP.list_files-Tuple{}","page":"Home","title":"OceanRobots.GDP.list_files","text":"list_files()\n\nGet list of drifter files from NOAA ftp server      ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/ or the corresponding webpage  https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/.\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.GDP.read-Tuple{String}","page":"Home","title":"OceanRobots.GDP.read","text":"read(filename::String)\n\nDownload one drifter file from NOAA ftp server      ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/ or the corresponding webpage  https://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/.\n\nlist_files=GDP.list_files()\nfil=GDP.download(list_files,1)\nds=GDP.read(fil)\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.THREDDS.parse_catalog","page":"Home","title":"OceanRobots.THREDDS.parse_catalog","text":"parse_catalog(url,recursive=true)\n\nStarting from an xml (not html) thredds catalog look for both subfolders and files; they are identified based on the href and urlPath attributes respectively. If recursive is set to true then go down in subfolders and do the same until only files are found; in this case the returned folders should be empty and files can be extensive.\n\nSee https://www.unidata.ucar.edu/software/tds/current/catalog/ for more on thredds.\n\nurl=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/long_timeseries/WHOTS/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/data/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites-tao/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/tao-ctd/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/hfradar/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/catalog.xml\"\n\nfiles,folders=parse_catalog(url)\n\n\n\n\n\n","category":"function"}]
}
