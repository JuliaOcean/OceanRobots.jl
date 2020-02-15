# ---
# jupyter:
#   jupytext:
#     formats: ipynb,jl:light
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.2.4
#   kernelspec:
#     display_name: Julia 1.3.0-rc4
#     language: julia
#     name: julia-1.3
# ---

# # Access Argo data using [ArgoVis](https://argovis.colorado.edu/ng/home) in Julia
#
# Citation for the Argovis web application and the Argovis database: 
# Tucker, T., D. Giglio, M. Scanderbeg, and S.S.P. Shen, 0: Argovis: A Web Application for Fast Delivery, Visualization, and Analysis of Argo Data. J. Atmos. Oceanic Technol., 0, https://doi.org/10.1175/JTECH-D-19-0041.1
#
# Argo data reference 
# " These data were collected and made freely available by the International Argo Program and the national programs that contribute to it. (http://www.argo.ucsd.edu, http://argo.jcommops.org). The Argo Program is part of the Global Ocean Observing System. " 
# Argo (2000). Argo float data and metadata from Global Data Assembly Centre (Argo GDAC). SEANOE. http://doi.org/10.17882/42182

# +
#run(pipeline(`which python`,"whichpython.txt")) #external python path
#ENV["PYTHON"]=readline("whichpython.txt")
#import Pkg; Pkg.build("PyCall")

using PyCall

requests = pyimport("requests")
pd = pyimport("pandas")
np = pyimport("numpy")
sp = pyimport("scipy.interpolate")
griddata=sp.griddata
datetime = pyimport("datetime")
pdb = pyimport("pdb")
os = pyimport("os")
netCDF4 = pyimport("netCDF4")
netcdf_dataset=netCDF4.Dataset

# +
function get_monthly_profile_pos(month, year)
    baseURL = "https://argovis.colorado.edu/selection/profiles"
    url = baseURL*"/"*string(month)*"/"*string(year)
    resp = requests.get(url)
    monthlyProfilePos = resp.json()
    return monthlyProfilePos
end

function parse_meta_into_df(profiles)
    #initialize dict
    df = pd.DataFrame(profiles)
    return df
end

# set month and year for metadata
month = 1
year = 2004
metaProfiles = get_monthly_profile_pos(month, year)
metaDf = parse_meta_into_df(metaProfiles)
# -


