var documenterSearchIndex = {"docs":
[{"location":"visuals/#Visual-Examples","page":"Visuals","title":"Visual Examples","text":"","category":"section"},{"location":"visuals/","page":"Visuals","title":"Visuals","text":"The plots below are generated by the notebook examples listed earlier.","category":"page"},{"location":"visuals/","page":"Visuals","title":"Visuals","text":"Argo Float Track Argo Float Profiles\n(Image: ) (Image: )\nGDP Surface Drifter Data WHOTS Mooring Data\n(Image: ) (Image: )\nSpray Glider Data NOAA Time series\n(Image: ) (Image: )","category":"page"},{"location":"examples/#Notebooks","page":"Notebooks","title":"Notebooks","text":"","category":"section"},{"location":"examples/#Examples-Suite","page":"Notebooks","title":"Examples Suite","text":"","category":"section"},{"location":"examples/","page":"Notebooks","title":"Notebooks","text":"The suite of examples includes :","category":"page"},{"location":"examples/","page":"Notebooks","title":"Notebooks","text":"OceanOPS.jl (➭ code link) : global ocean observing systems\nBuoy_NWP_NOAA.jl (➭ code link) : NOAA station data (a few days)\nBuoy_NWP_NOAA_monthly.jl (➭ code link) : NOAA station data (monthly means) \nMooring_WHOTS.jl (➭ code link) : WHOTS mooring data\nDrifter_GDP.jl (➭ code link) : drifter time series\nDrifter_CloudDrift.jl (➭ code link) : drifter statistics\nFloat_Argo.jl (➭ code link) : Argo profiling float data\nGlider_Spray.jl (➭ code link) : underwater glider data.","category":"page"},{"location":"examples/","page":"Notebooks","title":"Notebooks","text":"note: Note\nThe static html rendering of the notebooks (this website) lack the interactivity that comes from Running The Examples yourself.","category":"page"},{"location":"examples/#Additional-Examples","page":"Notebooks","title":"Additional Examples","text":"","category":"section"},{"location":"examples/","page":"Notebooks","title":"Notebooks","text":"For Argo and state estimates, see ArgoData.jl\nFor drifter data simulations, see IndividualDisplacements.jl","category":"page"},{"location":"examples/#Running-Examples","page":"Notebooks","title":"Running Examples","text":"","category":"section"},{"location":"examples/","page":"Notebooks","title":"Notebooks","text":"The examples are most easily run using Pluto.jl. To do it this way, one just needs to copy a code link provided above and paste this URL into the Pluto.jl interface.","category":"page"},{"location":"reference/#Reference-Manual","page":"Reference","title":"Reference Manual","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Modules = [OceanOPS, GDP, NOAA, GliderFiles, ArgoFiles, OceanSites, THREDDS]","category":"page"},{"location":"reference/#OceanRobots.OceanOPS.csv_listings-Tuple{}","page":"Reference","title":"OceanRobots.OceanOPS.csv_listings","text":"csv_listings()\n\nList csv files available on the https://www.ocean-ops.org/share/ server.\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.OceanOPS.get_list","page":"Reference","title":"OceanRobots.OceanOPS.get_list","text":"get_list(nam=:Argo; status=\"OPERATIONAL\")\n\nGet list of platform IDs from OceanOPS API.\n\nFor more information see \n\nhttps://www.ocean-ops.org/api/1/help/\nhttps://www.ocean-ops.org/api/1/help/?param=platformstatus\n\nlist_Argo1=OceanOPS.get_list(:Argo,status=\"OPERATIONAL\")\nlist_Argo2=OceanOPS.get_list(:Argo,status=\"CONFIRMED\")\nlist_Argo3=OceanOPS.get_list(:Argo,status=\"REGISTERED\")\nlist_Argo4=OceanOPS.get_list(:Argo,status=\"INACTIVE\")\n\n\n\n\n\n","category":"function"},{"location":"reference/#OceanRobots.OceanOPS.get_list_pos","page":"Reference","title":"OceanRobots.OceanOPS.get_list_pos","text":"get_list_pos(nam=:Argo; status=\"OPERATIONAL\")\n\nGet list of platform positions from OceanOPS API.\n\nFor more information see \n\nhttps://www.ocean-ops.org/api/1/help/\nhttps://www.ocean-ops.org/api/1/help/?param=platformstatus\n\n\n\n\n\n","category":"function"},{"location":"reference/#OceanRobots.OceanOPS.get_platform-Tuple{Any}","page":"Reference","title":"OceanRobots.OceanOPS.get_platform","text":"get_platform(i)\n\nGet info on platform with id=i (e.g., float or drifter) from OceanOPS API.\n\nFor more information see https://www.ocean-ops.org/api/1/help/\n\nlist_Drifter=OceanOPS.get_list(:Drifter)\ntmp=OceanOPS.get_platform(list_Drifter[1000])\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.OceanOPS.get_table","page":"Reference","title":"OceanRobots.OceanOPS.get_table","text":"get_table(s::Symbol,i=1)\n\nRead the csv_listings()[s][i] table. Download file if needed. \n\nusing OceanRobots\ntab_Argo=OceanOPS.get_table(:Argo,1)\n\n\n\n\n\n","category":"function"},{"location":"reference/#OceanRobots.OceanOPS.get_url","page":"Reference","title":"OceanRobots.OceanOPS.get_url","text":"get_url(nam=:Argo; status=\"OPERATIONAL\")\n\nAPI/GET URL to OceanOPS API that will list platforms of chosen type.\n\nTwo URLs are reported; the second includes platform positions.\n\nFor more information see \n\nhttps://www.ocean-ops.org/api/1/help/\nhttps://www.ocean-ops.org/api/1/help/?param=platformstatus\nhttps://www.ocean-ops.org/api/1/help/?param=platformtype\n\n\n\n\n\n","category":"function"},{"location":"reference/#OceanRobots.GDP.download","page":"Reference","title":"OceanRobots.GDP.download","text":"download(list_files,ii=1)\n\nDownload one drifter file from NOAA ftp server.\n\nftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/\n\nlist_files=GDP.list_files()\nfil=GDP.download(list_files,1)\n\n\n\n\n\n","category":"function"},{"location":"reference/#OceanRobots.GDP.list_files-Tuple{}","page":"Reference","title":"OceanRobots.GDP.list_files","text":"list_files()\n\nGet list of drifter files from NOAA ftp server or the corresponding webpage.\n\nftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/\nhttps://www.aoml.noaa.gov/ftp/pub/phod/lumpkin/hourly/v2.00/netcdf/\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.GDP.read-Tuple{String}","page":"Reference","title":"OceanRobots.GDP.read","text":"read(filename::String)\n\nOpen file from NOAA ftp server using NCDatasets.Dataset.\n\nftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v2.00/netcdf/ or the corresponding webpage \n\nlist_files=GDP.list_files()\nfil=GDP.download(list_files,1)\nds=GDP.read(fil)\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.NOAA.download-Tuple{Any}","page":"Reference","title":"OceanRobots.NOAA.download","text":"NOAA.download(MC::ModelConfig)\n\nDownload files listed in MC.inputs[\"stations\"] from ndbc.noaa.gov to pathof(MC).\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.NOAA.download_historical_txt-Tuple{Any, Any}","page":"Reference","title":"OceanRobots.NOAA.download_historical_txt","text":"NOAA.download_historical_txt(ID,years)\n\nDownload files from https://www.ndbc.noaa.gov to temporary folder for chosen float ID and years.\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.NOAA.read-Tuple{Any, Any}","page":"Reference","title":"OceanRobots.NOAA.read","text":"NOAA.read(MC,sta)\n\nRead station sta file from pathof(MC). Meta-data is provided in NOAA.units and NOAA.descriptions.\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.NOAA.read_historical_monthly","page":"Reference","title":"OceanRobots.NOAA.read_historical_monthly","text":"NOAA.read_historical_monthly(ID,years)\n\nRead files from https://www.ndbc.noaa.gov to temporary folder for chosen float ID and year y.\n\n\n\n\n\n","category":"function"},{"location":"reference/#OceanRobots.NOAA.read_historical_nc-Tuple{Any, Any}","page":"Reference","title":"OceanRobots.NOAA.read_historical_nc","text":"NOAA.read_historical_nc(ID,year)\n\nRead files from https://www.ndbc.noaa.gov to temporary folder for chosen float ID and year y.\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.NOAA.read_historical_txt-Tuple{Any, Any}","page":"Reference","title":"OceanRobots.NOAA.read_historical_txt","text":"NOAA.read_historical_txt(ID,y)\n\nRead files from https://www.ndbc.noaa.gov to temporary folder for chosen float ID and year y.\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.GliderFiles.read-Tuple{String}","page":"Reference","title":"OceanRobots.GliderFiles.read","text":"GliderFiles.read(file::String)\n\nRead a Spray Glider file.    \n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.ArgoFiles.download-Tuple{Any, Any}","page":"Reference","title":"OceanRobots.ArgoFiles.download","text":"ArgoFiles.download(files_list,wmo)\n\nDownload an Argo profiler file.    \n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.ArgoFiles.read-Tuple{Any}","page":"Reference","title":"OceanRobots.ArgoFiles.read","text":"ArgoFiles.read(fil)\n\nRead an Argo profiler file.    \n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.ArgoFiles.scan_txt","page":"Reference","title":"OceanRobots.ArgoFiles.scan_txt","text":"ArgoFiles.scan_txt(fil=\"ar_index_global_prof.txt\"; do_write=false)\n\nScan the Argo file lists and return summary tables in DataFrame format.  Write to csv file if istrue(do_write).\n\nArgoFiles.scan_txt(\"ar_index_global_prof.txt\",do_write=true)\nArgoFiles.scan_txt(\"argo_synthetic-profile_index.txt\",do_write=true)\n\n\n\n\n\n","category":"function"},{"location":"reference/#OceanRobots.OceanSites.index-Tuple{}","page":"Reference","title":"OceanRobots.OceanSites.index","text":"index()\n\nDownload, read and process the oceansites_index.txt file. Return a DataFrame.\n\noceansites_index=OceanSites.index()\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.OceanSites.read-Tuple{Any, Vararg{Any}}","page":"Reference","title":"OceanRobots.OceanSites.read","text":"read(file,args...)\n\nOpen file from opendap server.\n\nfile=\"DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc\"\nOceanSites.read(file,:lon,:lat,:time,:TEMP)\n\n\n\n\n\n","category":"method"},{"location":"reference/#OceanRobots.OceanSites.read_WHOTS","page":"Reference","title":"OceanRobots.OceanSites.read_WHOTS","text":"read_WHOTS(fil)\n\nRead an WHOTS file.    \n\nfile=\"DATA_GRIDDED/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc\"\ndata,units=OceanSites.read_WHOTS(file)\n\n\n\n\n\n","category":"function"},{"location":"reference/#OceanRobots.THREDDS.parse_catalog","page":"Reference","title":"OceanRobots.THREDDS.parse_catalog","text":"parse_catalog(url,recursive=true)\n\nStarting from an xml (not html) thredds catalog look for both subfolders and files; they are identified based on the href and urlPath attributes respectively. If recursive is set to true then go down in subfolders and do the same until only files are found; in this case the returned folders should be empty and files can be extensive.\n\nFor more on thredds servers, see https://www.unidata.ucar.edu/software/tds/current/catalog/.\n\nurl=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/long_timeseries/WHOTS/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/data/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites-tao/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/tao-ctd/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/hfradar/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/catalog.xml\"\n\nfiles,folders=parse_catalog(url)\n\n\n\n\n\n","category":"function"},{"location":"reference/#OceanRobots.THREDDS.parse_catalog_NOAA_buoy","page":"Reference","title":"OceanRobots.THREDDS.parse_catalog_NOAA_buoy","text":"parse_catalog_NOAA_buoy(ID=44013)\n\nUse parse_catalog_NOAA_buoy to build files_year,files_url lists for buoy ID.   \n\n\n\n\n\n","category":"function"},{"location":"#OceanRobots.jl","page":"Home","title":"OceanRobots.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Simulation, processing, and analysis of data generated by scientific robots in the Ocean. These include profiling floats, drifters, gliders, and moorings for examples.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Pages = [\n    \"examples.md\",\n    \"visuals.md\",\n    \"reference.md\",\n]\nDepth = 2","category":"page"}]
}
