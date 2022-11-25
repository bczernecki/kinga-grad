library(raster)
setwd("~/github/kinga-grad/data/hiszpania_wiatr/uerra/")
rastry = dir(pattern = "tif")

plot(raster(rastry[1]))

for (i in 1:length(rastry)) {
  r = raster(rastry[i])
  r2 =  projectRaster(r, crs = "+init=epsg:25830")
  writeRaster(r2, filename = paste0(names(r), "_epsg_25830.tif"), overwrite = TRUE)
}

# do wizualizacji z obiektu fr z pliku: 31_era5_..R :
# fr2 = st_transform(fr, 2154)
# plot(r2)
# plot(fr2, add = TRUE)
