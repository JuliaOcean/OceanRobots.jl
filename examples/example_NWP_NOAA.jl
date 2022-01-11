
#See https://www.ndbc.noaa.gov/

using Downloads, ClimateModels
using CSV, DataFrames, Dates

parameters=Dict("stations" => [44066, 44017, 44097, 44013])

function get_NWP_NOAA(x)
    url0="https://www.ndbc.noaa.gov/data/realtime2/"
    pth0=pathof(x)

    for f in x.inputs["stations"]
        fil="$f.txt"
        url1=url0*fil
        fil1=joinpath(pth0,fil)
        Downloads.download(url1,fil1)
    end
    
    return x
end

MC=ModelConfig(model=get_NWP_NOAA,inputs=parameters)
setup(MC)
build(MC)
launch(MC)

##

pth0=pathof(MC)

fil=parameters["stations"][2]
fil1=joinpath(pth0,"$fil.txt")

x=DataFrame(CSV.File(fil1,skipto=3,
missingstring="MM",delim=' ',header=1,ignorerepeated=true))
rename!(x, Symbol("#YY") => :YY, :Column2 => :MM)

nt=size(x,1)

t=[DateTime(x.YY[t],x.MM[t],x.DD[t],x.hh[t],x.mm[t]) for t in 1:nt]
dt=t.-t[1]; dt=[dt[i].value for i in 1:nt]/1000/86400;
z=x.PRES[:]

# Plotting
# ```
# using CairoMakie
# lines(dt,z)
# ```
