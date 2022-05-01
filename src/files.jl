
function check_for_file(set::String,args...)
    if set=="Spray_Glider"
        check_for_file_Spray_Glider(args...)
    else
        println("unknown set")
    end
end

function check_for_file_Spray_Glider(args...)
    if !isempty(args)
        url1="http://spraydata.ucsd.edu/media/data/binnednc/"*basename(args[1])
        pth0=dirname(args[1])
        isempty(pth0) ? pth1=joinpath(tempdir(),"tmp_glider_data") : pth1=pth0
        !isdir(pth1) ? mkdir(pth1) : nothing
        fil1=joinpath(pth1,basename(args[1]))
        !isfile(fil1) ? Downloads.download(url1,fil1) : nothing
    else
        pth0=joinpath(tempdir(),"tmp_glider_data")
        glob("*.nc",pth0)
    end
end


