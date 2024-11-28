module Gulf_of_Mexico

using OceanRobots

#function read_polygons()
#    fil=MeshArrays.demo.download_polygons("ne_110m_admin_0_countries.shp")
#    MeshArrays.read_polygons(fil)
#end

function read_GDP_subset(file::String)
    GDP_CD=read(CloudDrift(),file)

    ii_box=findall( (GDP_CD.data.grid.lon.>=-100).&&(GDP_CD.data.grid.lon.<=-75) )
    jj_box=findall( (GDP_CD.data.grid.lat.>=17).&&(GDP_CD.data.grid.lat.<=33) )
    (ii_box,jj_box)

    x=GDP_CD.data.grid.lon[ii_box]
    y=GDP_CD.data.grid.lat[jj_box]
    u=GDP_CD.data.ve[ii_box,jj_box]
    v=GDP_CD.data.vn[ii_box,jj_box]

    GM=Dict("x"=>x,"y"=>y,"u"=>u,"v"=>v)
    
    GDP_CD,GM
end

"""
    Drifters_example_prep(file::String)

```
using OceanRobots

#pol=read_polygons()
pol=[]

#file="gdp-v2.01.nc"
file=GDP_CloudDrift.CloudDrift_subset_download()
GM=Gulf_of_Mexico.example_prep(file=file,pol=pol)

output_file=joinpath(tempdir(),"Drifters_example.jld2")
JLD2.jldsave(output_file,GM...)
```
"""
function example_prep(;file="", pol=[])
    GDP_CD,GM=read_GDP_subset(file)

    res=1/2
    dx=res*100000.0
    dT=1/4*86400
    nt=120*86400/dT

    uC=GM["u"]/dx; uC[isnan.(uC)].=0
    vC=GM["v"]/dx; vC[isnan.(vC)].=0
    "done with defining flow field at grid cell centers"

    u=0.5*(circshift(uC, (1,0))+uC) #staggered u converted to grid point units (m/s -> 1/s)
    v=0.5*(circshift(vC, (0,1))+vC) #staggered v converted to grid point units (m/s -> 1/s)
    T=(0.,dT)

    np,nq=size(u)
    x0=np*(0.5 .+ 0.3*rand(1000))
    y0=nq*(0.0 .+ 0.3*rand(1000))

    (drifters_real=GDP_CD.data.subset,
    u=u,v=v,x=GM["x"],y=GM["y"],x0=x0,y0=y0,polygons=pol,            
    res = res, dx = dx, dT = dT, nt = nt)
end

end

