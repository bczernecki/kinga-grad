library(raster)
setwd("data/francja_grad/")
rastry = dir(pattern = "tif")

plot(raster(rastry[1]))

for (i in 1:length(rastry)) {
  r = raster(rastry[i])
  r2 =  projectRaster(r, crs = "+init=epsg:2154")
  writeRaster(r2, filename = paste0(names(r), "_epsg_2154.tif"), overwrite = TRUE)
}

#
# plot(r)
# fr = getData(name = "GADM", country = "FRA", level = 1)
# plot(fr, add = TRUE)

# do wizualizacji w qgisie, zeby sprawdzicz czy sie pokrywa zasieg:
# library(rgdal)
# writeOGR(fr, dsn = "fr", layer = "fr", driver = "ESRI Shapefile")
