
#- <http://www.soest.hawaii.edu/whots/wh_data.html>
#- <http://uop.whoi.edu/currentprojects/WHOTS/whotsarchive.html>
#- <http://uop.whoi.edu/currentprojects/WHOTS/whotsdata.html>
fil="http://tds0.ifremer.fr/thredds/dodsC/CORIOLIS-OCEANSITES-GDAC-OBS/long_timeseries/WHOTS/OS_WHOTS_200408-201809_D_MLTS-1H.nc"

using NCDatasets

ds=NCDataset(fil)
TIME = ds["TIME"][:,:]
AIRT = ds["AIRT"][:,:]
TEMP = ds["TEMP"][:,:]
PSAL = ds["PSAL"][:,:]
RAIN = ds["RAIN"][:,:]
RELH = ds["RELH"][:,:]
wspeed = sqrt.(ds["UWND"][:,:].^2+ds["VWND"][:,:].^2)
close(ds)

using CairoMakie

function timeseries(d0,d1)
    #t=Dates.value.(TIME.-TIME[1])/1000.0/86400.0
    #tt=findall((t.>110).*(t.<140))
    tt=findall((TIME.>d0).*(TIME.<=d1))
    t=Dates.value.(TIME.-d0)/1000.0/86400.0

    f=Figure()
    lines(f[1,1],t[tt],wspeed[tt],label="wspeed"); axislegend()
    lines(f[2,1],t[tt],AIRT[tt],label="AIRT"); axislegend()
    lines(f[3,1],t[tt],TEMP[tt],label="TEMP"); axislegend()
    lines(f[1,2],t[tt],RAIN[tt],label="RAIN"); axislegend()
    lines(f[2,2],t[tt],RELH[tt],label="RELH"); axislegend()
    lines(f[3,2],t[tt],PSAL[tt],label="PSAL"); axislegend()
    f
end

