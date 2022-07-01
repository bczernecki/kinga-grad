#### Compute risk of hail based on ERA-5 dataset ####

## formula for lghail used:
## cdo -expr,'lghail=(1-(1/(1+(10*(1+BS_EFF_MU)*(-MU_LI))/MU_LCL_TEMP^2)))*MU_MIXR*0.5*(1+sqrt((1+BS_EFF_MU)*(-MU_LI)/10)' 2021.nc lghail.nc

setwd("data/francja_grad")
library(raster)
library(terra)
library(sf)

# get boundaries
fr = getData(name = "GADM", country = "FRA", level = 1)
fr = st_as_sf(fr)
fr = fr[-which(fr$VARNAME_1 == "Corsica"),]
fr = dplyr::select(fr, NAME_1)
plot(fr)

fr = terra::vect(fr)
fr_bnd = terra::aggregate(fr, dissolve = TRUE)
plot(fr)

lghail = terra::mask(mean(rast("lghail_p99.nc")), fr_bnd)
plot(lghail, xlim=c(-5.5, 8.5), ylim=c(42,51.3), main = "LGHAIL")
plot(fr_bnd, add = TRUE)
# izolinie = rasterToContour(raster(lghail),
#                            levels = seq(from = 10, to = 35, by = 10))
# plot(izolinie, add = TRUE)
writeRaster(lghail, filename = "lghail.tif")

ship = terra::mask(mean(rast("calosc_p99.nc", subds = "SHIP")), fr_bnd)
plot(ship, xlim=c(-5.5, 8.5), ylim=c(42,51.3), main = "SHIP")
plot(fr, add = TRUE)
writeRaster(ship, filename = "ship.tif")


hsi = terra::mask(mean(rast("calosc_p99.nc", subds = "HSI")), fr_bnd)
plot(hsi, xlim=c(-5.5, 8.5), ylim=c(42,51.3), main = "HSI")
plot(fr, add = TRUE)
writeRaster(hsi, filename = "hsi.tif")

(terra::scale(hsi, 0))
(terra::scale(ship, 0))
(terra::scale(lghail, 0))

library(tmap)

kolory = colorRampPalette(c("orange", "yellow", "white",  "lightblue"))
tm_shape(raster(hsi)) + tm_raster()


przedzialy <- c(6:26)*50
kolory <- rev(rainbow(20))
plot(r, breaks=przedzialy, col=colorRampPalette(kolory)(length(przedzialy)))

fr_bnd2 = sf::st_as_sf(fr_bnd)
fr2 = sf::st_as_sf(fr)

# rysowanie:
  tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
#  tm_text("NAME_1") +
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "HSI", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(raster(hsi)) +
  tm_raster(interpolate = FALSE,
            title = "(Hail Size Index)",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'pretty',
            n = 10,
            legend.is.portrait = TRUE,
            labels = as.character(sprintf("%.1f", seq(0.6,3.2,0.2)))) +
    tm_shape(fr_bnd2)+
    tm_borders() +
    tm_shape(fr2, col = "black")+
    tm_polygons(alpha = 0.10) -> p

  print(p)
tmap_save(tm = p, filename = "hsi.png")
