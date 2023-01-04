using Documenter, OceanRobots, PlutoSliderServer

##

using Pkg
ENV["PYTHON"]=""
Pkg.build("PyCall")

using Dataverse
(DataAccessApi,NativeApi)=pyDataverse.APIs()

DOI="doi:10.7910/DVN/OYBLGK"
df=pyDataverse.dataset_file_list(DOI)
lst=DataverseDownloads.download_urls(df)

filenames=["exportImage_60arc.tiff","sla_podaac.nc"]
pth0=joinpath(tempdir(),"azores_region_data")
for filename in filenames
 file0=joinpath(pth0,filename)
 !ispath(pth0) ? mkdir(pth0) : nothing
 !isfile(file0) ? DataverseDownloads.download_files(lst,filename,pth0) : nothing
end

##

makedocs(;
    modules=[OceanRobots],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Notebooks" => "examples.md",
        "Reference" => "reference.md",
        "Visuals" => "visuals.md",
        ],
    repo="https://github.com/JuliaOcean/OceanRobots.jl/blob/{commit}{path}#L{line}",
    sitename="OceanRobots.jl",
    authors="JuliaOcean <gforget@mit.edu>",
    assets=String[],
    )

OceanRobots.check_for_file("Glider_Spray","GulfStream.nc")
OceanRobots.check_for_file("Glider_Spray","CUGN_along.nc")

lst=("SatelliteAltimetry.jl","Buoy_NWP_NOAA_monthly.jl","Glider_Spray.jl","OceanOPS.jl",
    "Buoy_NWP_NOAA.jl","Mooring_WHOTS.jl","Drifter_GDP.jl","Float_Argo.jl")
for i in lst
    fil_in=joinpath(@__DIR__,"..","examples",i)
    fil_out=joinpath(@__DIR__,"build","examples",i[1:end-2]*"html")
    PlutoSliderServer.export_notebook(fil_in)
    mv(fil_in[1:end-2]*"html",fil_out)
    cp(fil_in,fil_out[1:end-4]*"jl")
end

for fil in ["argo_synthetic-profile_index.txt", "ar_index_global_prof.txt"]
    ArgoFiles.scan_txt(fil,do_write=true)
    fil_in=joinpath(tempdir(),fil[1:end-4]*".csv")
    fil_out=joinpath(@__DIR__,"build", fil[1:end-4]*".csv")
    mv(fil_in,fil_out)
end

deploydocs(;
    repo="github.com/JuliaOcean/OceanRobots.jl",
)
