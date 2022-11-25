#### Compute risk of wind gust based on ERA-5 dataset ####

# cdo formulas:
# cdo -b F64 -mergetime poryw*.nc calosc.nc
# cdo yearpctl,99 calosc.nc -yearmin calosc.nc -yearmax calosc.nc calosc_p99.nc
# cdo yearmax calosc poryw_ymax.nc
# cdo yearsum -gec,15 calosc.nc poryw_over_15.nc
# cdo yearsum -gec,20 calosc.nc poryw_over_20.nc
# cdo yearsum -gec,25 calosc.nc poryw_over_25.nc
# cdo yearsum -gec,30 calosc.nc poryw_over_30.nc



setwd("~/github/kinga-grad/data/polska_wiatr/uerra/")
library(raster)
library(terra)
library(sf)

# get boundaries
fr = getData(name = "GADM", country = "FRA", level = 1)
fr = st_as_sf(fr)
fr = fr[-which(fr$VARNAME_1 == "Corsica"),]
fr = dplyr::select(fr, NAME_1)
fr_buffer = st_buffer(fr, dist = 0.1)
fr_buffer = terra::aggregate(terra::vect(fr_buffer), dissolve = TRUE)

fr = terra::vect(fr)
plot(fr)

# srednia liczba dni w roku z przekroczeniem porywu 20 m/s:
sample_raster = mean(rast("poryw_over_20.nc"), na.rm=T)
a = project(fr_buffer, sample_raster)
plot(a)

poryw_over_138 = terra::mask(mean(rast("poryw_over_138.nc"), na.rm=T), a)
poryw_over_138 = terra::crop(poryw_over_138, a)
plot(poryw_over_138)
plot(a, add = TRUE)
raster::writeRaster(poryw_over_138, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_over_138.tif", overwrite = TRUE)

poryw_over_15 = terra::mask(mean(rast("poryw_over_15.nc"), na.rm=T), a)
poryw_over_15 = terra::crop(poryw_over_15, a)
plot(poryw_over_15)
plot(a, add = TRUE)
raster::writeRaster(poryw_over_15, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_over_15.tif", overwrite = TRUE)

poryw_over_175 = terra::mask(mean(rast("poryw_over_175.nc"), na.rm=T), a)
poryw_over_175 = terra::crop(poryw_over_175, a)
plot(poryw_over_175)
plot(a, add = TRUE)
raster::writeRaster(poryw_over_175, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_over_175.tif", overwrite = TRUE)

poryw_over_20 = terra::mask(mean(rast("poryw_over_20.nc"), na.rm=T), a)
poryw_over_20 = terra::crop(poryw_over_20, a)
plot(poryw_over_20)
plot(a, add = TRUE)
raster::writeRaster(poryw_over_20, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_over_20.tif", overwrite = TRUE)

# srednia liczba dni w roku z przekroczeniem porywu 25 m/s:
poryw_over_25 = terra::mask(mean(rast("poryw_over_25.nc"), na.rm=T), a)
poryw_over_25 = terra::crop(poryw_over_25, a)
plot(poryw_over_25)
plot(a, add = TRUE)
raster::writeRaster(poryw_over_25, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_over_25.tif", overwrite = TRUE)

# srednia liczba dni w roku z przekroczeniem porywu 30 m/s:
poryw_over_30 = terra::mask(mean(rast("poryw_over_30.nc"), na.rm=T), a)
poryw_over_30 = terra::crop(poryw_over_30, a)
plot(poryw_over_30)
plot(a, add = TRUE)
raster::writeRaster(poryw_over_30, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_over_30.tif", overwrite = TRUE)

# sredni max roczny:
wind_max = terra::mask(mean(rast("poryw_ymax.nc")), a)
wind_max = terra::crop(wind_max, a)
plot(wind_max, col = rainbow(40))
plot(a, add = TRUE)
raster::writeRaster(wind_max, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_avg_annual_max.tif", overwrite = TRUE)

# historyczny max:
wind_max2 = terra::mask(max(rast("poryw_ymax.nc")), a)
wind_max2 = terra::crop(wind_max2, a)
plot(wind_max2, col = rainbow(40))
plot(a, add = TRUE)
raster::writeRaster(wind_max2, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_max_record.tif", overwrite = TRUE)

# max roczny o prawdpodobienstwa co 10 lat:
wind_max_10lat = terra::mask(quantile(rast("poryw_ymax.nc"), 0.9), a)
wind_max_10lat = terra::crop(wind_max_10lat, a)
plot(wind_max_10lat)
plot(a, add = TRUE)
raster::writeRaster(wind_max_10lat, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_max_na_10_lat.tif", overwrite = TRUE)

# kwantyl 99 maksymalnej rocznej predkosci wiatru
wind_q99 = terra::mask(quantile(rast("calosc_p99.nc"), 0.9, na.rm=T), a)
wind_q99 = terra::crop(wind_q99, a)
plot(wind_q99)
plot(a, add = TRUE)
raster::writeRaster(wind_q99, filename = "~/github/kinga-grad/data/francja_wiatr/uerra/poryw_roczny_percentyl99.tif", overwrite = TRUE)
