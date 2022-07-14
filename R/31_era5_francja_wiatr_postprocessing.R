#### Compute risk of wind gust based on ERA-5 dataset ####

# cdo formulas:
# cdo -b F64 -mergetime poryw*.nc calosc.nc
# cdo yearpctl,99 calosc.nc -yearmin calosc.nc -yearmax calosc.nc calosc_p99.nc
# cdo yearmax calosc poryw_ymax.nc
# cdo yearsum -gec,15 calosc.nc poryw_over_15.nc
# cdo yearsum -gec,20 calosc.nc poryw_over_20.nc
# cdo yearsum -gec,25 calosc.nc poryw_over_25.nc
# cdo yearsum -gec,30 calosc.nc poryw_over_30.nc



setwd("~/github/kinga-grad/data/francja_wiatr")
library(raster)
library(terra)
library(sf)

# get boundaries
fr = getData(name = "GADM", country = "FRA", level = 1)
fr = st_as_sf(fr)
fr = fr[-which(fr$VARNAME_1 == "Corsica"),]
fr = dplyr::select(fr, NAME_1)
fr_buffer = st_buffer(fr, dist = 10000)
fr_buffer = terra::aggregate(terra::vect(fr_buffer), dissolve = TRUE)

fr = terra::vect(fr)
plot(fr)

# srednia liczba dni w roku z przekroczeniem porywu 20 m/s:
poryw_over_20 = terra::mask(mean(rast("poryw_over_20.nc")), fr_buffer)
plot(poryw_over_20)
plot(fr, add = TRUE)
raster::writeRaster(poryw_over_20, filename = "poryw_over_20.tif", overwrite = TRUE)

# srednia liczba dni w roku z przekroczeniem porywu 25 m/s:
poryw_over_25 = terra::mask(mean(rast("poryw_over_25.nc")), fr_buffer)
plot(poryw_over_25)
plot(fr, add = TRUE)
raster::writeRaster(poryw_over_25, filename = "poryw_over_25.tif" , overwrite = TRUE)

# srednia liczba dni w roku z przekroczeniem porywu 30 m/s:
poryw_over_30 = terra::mask(mean(rast("poryw_over_30.nc")), fr_buffer)
plot(poryw_over_30)
plot(fr, add = TRUE)
raster::writeRaster(poryw_over_30, filename = "poryw_over_30.tif", overwrite = TRUE)

# sredni max roczny:
wind_max = terra::mask(mean(rast("poryw_ymax.nc")), fr_buffer) * 1.03
plot(wind_max)
plot(fr, add = TRUE)
raster::writeRaster(wind_max, filename = "poryw_avg_annual_max.tif", overwrite = TRUE)

# historyczny max:
wind_max2 = terra::mask(max(rast("poryw_ymax.nc")), fr_buffer) * 1.03
plot(wind_max2)
plot(fr, add = TRUE)
raster::writeRaster(wind_max2, filename = "poryw_max_record.tif", overwrite = TRUE)

# max roczny o prawdpodobienstwa co 10 lat:
wind_max_10lat = terra::mask(quantile(rast("poryw_ymax.nc"), 0.9), fr_buffer)*1.03
plot(wind_max_10lat)
plot(fr, add = TRUE)
raster::writeRaster(wind_max_10lat, filename = "poryw_max_na_10_lat.tif", overwrite = TRUE)

# kwantyl 99 maksymalnej rocznej predkosci wiatru
wind_q99 = terra::mask(quantile(rast("poryw_p99.nc"), 0.9), fr_buffer)*1.03
plot(wind_q99)
plot(fr, add = TRUE)
raster::writeRaster(wind_q99, filename = "poryw_roczny_percentyl99.tif", overwrite = TRUE)
