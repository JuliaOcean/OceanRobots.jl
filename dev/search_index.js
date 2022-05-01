var documenterSearchIndex = {"docs":
[{"location":"#OceanRobots.jl","page":"Home","title":"OceanRobots.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Simulation, processing, and analysis of data generated by scientific robots in the Ocean. These include profiling floats (Argo), drifters (GDP), and moorings for examples.","category":"page"},{"location":"","page":"Home","title":"Home","text":"warning: Warning\nThis package is in early developement stage when breaking changes can be expected._","category":"page"},{"location":"","page":"Home","title":"Home","text":"The suite of examples includes :","category":"page"},{"location":"","page":"Home","title":"Home","text":"Buoy_NWP_NOAA.jl (➭ code link) : NOAA station data\nMooring_WHOTS.jl (➭ code link) : WHOTS mooring data\nDrifter_GDP.jl (➭ code link) : drifter time series\nFloat_Argo.jl (➭ code link) : Argo profiling float data\nSpray_Glider.jl (➭ code link) : underwater glider data.","category":"page"},{"location":"","page":"Home","title":"Home","text":"note: Note\nFor more on Argo : see companion package ArgoData.jl","category":"page"},{"location":"","page":"Home","title":"Home","text":"note: Note\nThe static html rendering of the notebooks (this website) lack the interactivity that comes from Running The Examples yourself.","category":"page"},{"location":"#Running-The-Examples","page":"Home","title":"Running The Examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The examples are most easily run using Pluto.jl. To do it this way, one just needs to copy a code link provided above and paste this URL into the Pluto.jl interface.","category":"page"},{"location":"#Additional-examples:","page":"Home","title":"Additional examples:","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Drifter_CloudDrift.jl ","category":"page"},{"location":"#Graphical-Examples","page":"Home","title":"Graphical Examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Argo Float Profiles Argo Float Track\n(Image: ) (Image: )\nSurface Drifter Track Mooring Time series\n(Image: ) (Image: )","category":"page"},{"location":"#Functionalities","page":"Home","title":"Functionalities","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [OceanRobots]","category":"page"},{"location":"#OceanRobots.add_attribute_rowsize","page":"Home","title":"OceanRobots.add_attribute_rowsize","text":"This modification to the original \"gdpv2.00.nc\" addeed the missing `sampledimensionattribute. Doing this is needed to use with e.g.NCDataset.loadragged`.\n\nds=Dataset(\"gdp_v2.00.nc\");\nsst=ds[\"sst\"]\nsst=loadragged(ds[\"sst\"],:);\nlatitude=loadragged(ds[\"latitude\"],:);\n\n\n\n\n\n","category":"function"},{"location":"#OceanRobots.drifters_hourly_download","page":"Home","title":"OceanRobots.drifters_hourly_download","text":"drifters_hourly_download(list_files,ii=1)\n\nDownload one drifter file from NOAA ftp server      ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v1.04/netcdf/\n\nlist_files=drifters_hourly_files()\nfil=drifters_hourly_download(list_files,1)\n\n\n\n\n\n","category":"function"},{"location":"#OceanRobots.drifters_hourly_files-Tuple{}","page":"Home","title":"OceanRobots.drifters_hourly_files","text":"drifters_hourly_files()\n\nGet list of drifter files from NOAA ftp server      ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v1.04/netcdf/\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.drifters_hourly_mat-Tuple{Number, Number}","page":"Home","title":"OceanRobots.drifters_hourly_mat","text":"drifters_hourly_mat(t0::Number,t1::Number)\n\nLoop over all files and call driftershourlymat with rng=(t0,t1)\n\n@everywhere using OceanRobots\n@distributed for y in 2005:2020\n    df=drifters_hourly_mat(y+0.0,y+1.0)\n    pth=joinpath(tempdir(),\"Drifter_hourly_v014\",\"csv\")\n    fil=joinpath(\"drifters_\"*string(y)*\".csv\")\n    OceanRobots.CSV.write(fil, df)\nend\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.drifters_hourly_mat-Tuple{String}","page":"Home","title":"OceanRobots.drifters_hourly_mat","text":"drifters_hourly_mat(pth,lst;chnk=Inf,rng=(-Inf,Inf))\n\nRead near-surface drifter data from the Global Drifter Program into a DataFrame.\n\npth,lst=drifters_hourly_mat()\ndf=drifters_hourly_mat( pth*lst[end], rng=(2014.1,2014.2) )\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.drifters_hourly_mat-Tuple{}","page":"Home","title":"OceanRobots.drifters_hourly_mat","text":"drifters_hourly_mat()\n\nPath name and file list for near-surface drifter data from the Global Drifter Program\n\npth,lst=drifters_hourly_mat()\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.drifters_hourly_read-Tuple{String}","page":"Home","title":"OceanRobots.drifters_hourly_read","text":"drifters_hourly_read(filename::String)\n\nDownload one drifter file from NOAA ftp server      ftp://ftp.aoml.noaa.gov/pub/phod/lumpkin/hourly/v1.04/netcdf/\n\nlist_files=drifters_hourly_files()\nfil=drifters_hourly_download(list_files,1)\nds=drifters_hourly_read(fil)\n\n\n\n\n\n","category":"method"},{"location":"#OceanRobots.parse_thredds_catalog","page":"Home","title":"OceanRobots.parse_thredds_catalog","text":"parse_thredds_catalog(url,recursive=true)\n\nStarting from an xml (not html) thredds catalog look for both subfolders and files; they are identified based on the href and urlPath attributes respectively. If recursive is set to true then go down in subfolders and do the same until only files are found; in this case the returned folders should be empty and files can be extensive.\n\nSee https://www.unidata.ucar.edu/software/tds/current/catalog/ for more on thredds.\n\nurl=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/long_timeseries/WHOTS/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/data/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites-tao/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/tao-ctd/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/hfradar/catalog.xml\"\n#url=\"https://dods.ndbc.noaa.gov/thredds/catalog/oceansites/catalog.xml\"\n\nfiles,folders=parse_thredds_catalog(url)\n\n\n\n\n\n","category":"function"}]
}
