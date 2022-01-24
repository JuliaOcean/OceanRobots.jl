

@everywhere using OceanRobots
@everywhere path=joinpath(tempdir(),"Argo_DAC_files")
@everywhere fil=joinpath(path,"Argo_float_files.csv")
#@everywhere ftp="ftp://usgodae.org/pub/outgoing/argo/dac/"

!isdir(path) ? mkdir(path) : nothing

if !isfile(fil)
    list_files=Argo_float_files()
    path=joinpath(tempdir(),"Argo_DAC_files")
    !isdir(path) ? mkdir(path) : nothing
    OceanRobots.CSV.write(joinpath(path,"Argo_float_files.csv"),list_files)
end

@everywhere list_files=OceanRobots.DataFrame(OceanRobots.CSV.File(fil))

for i in unique(list_files[:,:folder])
    !isdir(joinpath(path,i)) ? mkdir(joinpath(path,i)) : nothing
end

@everywhere n=10
@everywhere N=0
while N<size(list_files,1)
    @sync @distributed for m in 1:nworkers()
        ii=collect(N + (m-1)*n .+ (1:n))
        println(ii[1])
        #[Argo_float_download(list_files,i,"prof",ftp) for i in ii];
        [Argo_float_download(list_files,i,"prof") for i in ii];
    end
    @everywhere N=N+n*nworkers()
end
