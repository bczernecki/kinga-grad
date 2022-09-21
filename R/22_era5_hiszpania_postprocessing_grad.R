#### Compute risk of hail based on ERA-5 dataset ####

## formula for lghail used:
## cdo -expr,'lghail=(1-(1/(1+(10*(1+BS_EFF_MU)*(-MU_LI))/MU_LCL_TEMP^2)))*MU_MIXR*0.5*(1+sqrt((1+BS_EFF_MU)*(-MU_LI)/10)' 2021.nc lghail.nc

setwd("data/hiszpania_grad/")
library(raster)
library(terra)
library(sf)

# get boundaries
fr = getData(name = "GADM", country = "ESP", level = 1)
fr = st_as_sf(fr)
fr = fr[-which(fr$NAME_1 == "Islas Baleares"),]
fr = fr[-which(fr$NAME_1 == "Islas Canarias"),]
fr = dplyr::select(fr, NAME_1)
plot(fr)

fr = terra::vect(fr)
fr_bnd = terra::aggregate(fr, dissolve = TRUE)
fr_bnd = buffer(fr_bnd, width = 20000)
fr_bnd = terra::aggregate(fr_bnd, dissolve = TRUE)

plot(fr_bnd)
lghail = terra::mask(mean(rast("lghail_p99.nc"), na.rm = T), fr_bnd)
plot(lghail)
plot(fr,add = T)

#plot(lghail, xlim=c(-5.5, 8.5), ylim=c(42,51.3), main = "LGHAIL")
#plot(fr_bnd, add = TRUE)
# izolinie = rasterToContour(raster(lghail),
#                            levels = seq(from = 10, to = 35, by = 10))
# plot(izolinie, add = TRUE)
writeRaster(lghail, filename = "lghail.tif", overwrite = TRUE)

ship = terra::mask(mean(rast("calosc_p99.nc", subds = "SHIP")), fr_bnd)
plot(ship, main = "SHIP")
plot(fr, add = TRUE)
writeRaster(ship, filename = "ship.tif", overwrite = TRUE)

hsi = terra::mask(mean(rast("calosc_p99.nc", subds = "HSI")), fr_bnd)
plot(hsi, main = "HSI")
plot(fr, add = TRUE)
writeRaster(hsi, filename = "hsi.tif", overwrite = TRUE)

(terra::scale(hsi, 0))
(terra::scale(ship, 0))
(terra::scale(lghail, 0))

library(tmap)
# zmiana formatu na gadajacy z tmapem:
fr_bnd = readRDS("gadm36_ESP_1_sp.rds")
#fr2 = sf::st_as_sf(fr)
fr_bnd$NAME_1
fr_bnd = fr_bnd[-which(fr_bnd$NAME_1 == "Islas Baleares"),]
fr_bnd = fr_bnd[-which(fr_bnd$NAME_1 == "Islas Canarias"),]


# rysowanie HSI:
tm_shape(fr_bnd)+
  tm_borders() + # just for start to have extent:
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
  tm_shape(fr_bnd) +
  tm_borders() -> p

print(p)
tmap_save(tm = p, filename = "hsi.png")

# rysowanie LGHAIL:
tm_shape(fr_bnd) +
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "LGHAIL", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(raster(lghail)) +
  tm_raster(interpolate = FALSE,
            title = "(Large Hail Index)",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'pretty',
            n = 20,
            legend.is.portrait = TRUE,
            labels = as.character(sprintf("%.1f", seq(11,29,1)))) +
  tm_shape(fr_bnd) +
  tm_borders() -> p

print(p)
tmap_save(tm = p, filename = "lghail.png")


# rysowanie SHIP:
tm_shape(fr_bnd) +
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "SHIP", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(raster(ship)) +
  tm_raster(interpolate = FALSE,
            title = "(Significant Hail Parameter)",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'pretty',
            n = 20,
            legend.is.portrait = TRUE,
            labels = as.character(sprintf("%.2f", seq(0.0,0.8,0.05)))) +
  tm_shape(fr_bnd) +
  tm_borders() -> p

print(p)
tmap_save(tm = p, filename = "ship.png")


# na koniec zrobic skalowanie i synteze 3 produktow:
hsi_scaled = ((scale(hsi)+abs(min(scale(hsi[]), na.rm = T)))) / max((scale(hsi)+abs(min(scale(hsi[]), na.rm = T)))[], na.rm = T)
lghail_scaled = ((scale(lghail)+abs(min(scale(lghail[]), na.rm = T)))) / max((scale(lghail)+abs(min(scale(lghail[]), na.rm = T)))[], na.rm = T)
ship_scaled = ((scale(ship)+abs(min(scale(ship[]), na.rm = T)))) / max((scale(ship)+abs(min(scale(ship[]), na.rm = T)))[], na.rm = T)

synteza = (hsi_scaled + lghail_scaled + ship_scaled) / 3
synteza
plot(synteza)
writeRaster(synteza, filename = "hail_synthesis_scaled.tif")

# rysowanie syntezy:
tm_shape(fr_bnd)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "HAIL RISK", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(raster(synteza)) +
  tm_raster(interpolate = FALSE,
            title = "(scaled hail indices)",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'pretty',
            n = 20,
            legend.is.portrait = TRUE,
            labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd)+
  tm_borders() -> p

print(p)
tmap_save(tm = p, filename = "hail_synthesis.png")


# podsumowanie statystyczne w regionach
library(dplyr)
get_vals = function(input = synteza, index = "synthesis"){
  e = extract(input, fr, exact=TRUE, cells=TRUE)

  e %>% group_by(ID) %>% summarise(min = min(mean),
                                   max = max(mean),
                                   mean = mean(mean)) -> res

  res$provs = fr$NAME_1
  res$index = index
  return(res)
}

wsio = rbind.data.frame(
  get_vals(input = hsi, index = "HSI"),
  get_vals(input = ship, index = "SHIP"),
  get_vals(input = lghail, index = "LGHAIL"),
  get_vals(input = synteza, index = "SYNTHESIS")
)
writexl::write_xlsx(wsio, "grad_podsumowanie_tabela.xlsx")
