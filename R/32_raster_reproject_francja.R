library(raster)
setwd("~/github/kinga-grad/")
# tylko konwersja dla danych z UERRA
setwd("data/francja_wiatr/uerra/")
rastry = dir(pattern = "tif")

plot(raster(rastry[1]))

for (i in 1:length(rastry)) {
  r = raster(rastry[i])
  r2 =  projectRaster(r, crs = "+init=epsg:2154")
  writeRaster(r2, filename = paste0(names(r), "_epsg_2154.tif"), overwrite = TRUE)
}
