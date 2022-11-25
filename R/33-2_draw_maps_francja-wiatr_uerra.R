# rysowanie map wiatrowych z wygenerowanych tifow:
library(terra)
library(tmap)
library(sf)


# get boundaries
fr = getData(name = "GADM", country = "FRA", level = 1)
fr = st_as_sf(fr)
fr = fr[-which(fr$VARNAME_1 == "Corsica"),]
fr = dplyr::select(fr, NAME_1)
#fr = terra::vect(fr)
plot(fr)
# zmiana formatu na gadajacy z tmapem:
fr_bnd2 = sf::st_as_sf(fr)
fr2 = sf::st_as_sf(fr)

fr_terra = terra::vect(fr)

r = terra::mask(mean(rast("poryw_avg_annual_max.tif")), fr_terra)
r = raster(r)
library(tmap)
# rysowanie Maksymalnego średniego porywu w roku:
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "Mean annual\n max. wind gust", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[m/s]",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'pretty',
            n = 20,
            legend.is.portrait = TRUE) +
            #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_avg_annual_max.png")




### rysowanie max. porywu o prawdopodobieństwie ~10 lat
r = terra::mask(mean(rast("poryw_max_na_10_lat.tif")), fr_terra)
r = raster(r)
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "Wind gust\nmax. speed\nper 10 years", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[m/s]",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'pretty',
            n = 20,
            legend.is.portrait = TRUE) +
  #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_max_na_10_lat.png")



### rysowanie max. historycznego porywu
r = terra::mask(mean(rast("poryw_max_record.tif")), fr_terra)
r = raster(r)
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "Record high\nwind gusts\n1961-2020", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[m/s]",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'pretty',
            n = 10,
            legend.is.portrait = TRUE) +
  #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_max_record.png")




### rysowanie sredniej liczby godziny powyzej 15 m/s
r = terra::mask(rast("poryw_over_15.tif"), fr_terra)
r = raster(r)
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "Mean annual\ntime with\nwind gusts\n > 15 m/s", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[hours]",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'quantile',
            n = 10,
            legend.is.portrait = TRUE) +
  #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_over_15.png")


r = terra::mask(rast("poryw_over_138.tif"), fr_terra)
r = raster(r)
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "Mean annual\ntime with\nwind gusts\n > 13.8 m/s", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[hours]",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'quantile',
            n = 15,
            legend.is.portrait = TRUE) +
  #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_over_138.png")


r = terra::mask(rast("poryw_over_175.tif"), fr_terra)
r = raster(r)
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "Mean annual\ntime with\nwind gusts\n > 17.5 m/s", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[hours]",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'quantile',
            n = 15,
            legend.is.portrait = TRUE) +
  #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_over_175.png")



### rysowanie sredniej liczby godziny powyzej 20 m/s
r = terra::mask(rast("poryw_over_20.tif"), fr_terra)
r = raster(r)
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "Mean annual\ntime with\nwind gusts\n > 20 m/s", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[hours]",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'quantile',
            n = 15,
            legend.is.portrait = TRUE) +
  #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_over_20.png")


### rysowanie sredniej liczby godziny powyzej 25 m/s
r = terra::mask(rast("poryw_over_25.tif"), fr_terra)
r = raster(r)
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "Mean annual\ntime with\nwind gusts\n > 25 m/s", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[hours]",
            #palette = rev("viridis"),
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'quantile',
            n = 15,
            #breaks = c(0:20/2, 30, 50, 70),
            legend.is.portrait = TRUE) +
  #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_over_25.png")



### rysowanie sredniej liczby godziny powyzej 30 m/s
r = terra::mask(rast("poryw_over_30.tif"), fr_terra)
r = raster(r)
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "Mean annual\ntime with\nwind gusts\n > 30 m/s", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[hours]",
            palette = ("viridis"),
            #pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'quantile',
            #breaks = c(0:20/4, 6, 8, 10, 12, 14),
            n = 15,
            legend.is.portrait = TRUE) +
  #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_over_30.png")


### rysowanie sredniego rocznego percentyla 99
r = terra::mask(rast("poryw_roczny_percentyl99.tif"), fr_terra)
r = raster(r)
tm_shape(fr_bnd2)+
  tm_borders() + # just for start to have extent:
  tm_layout(legend.outside.size = 0.15, legend.outside.position = "right", legend.outside = TRUE,
            legend.frame = FALSE, frame = FALSE) +
  tm_layout(title = "99th percentile\nof annual\nwind gusts", bg.color = "gray90") +
  tm_graticules(n.x = 6, n.y = 5, col= "white") +
  tm_scale_bar(breaks = c(0, 100, 200), position = c("left", "bottom")) +
  tm_compass(position = c("left", "top"), size = 2) +
  tm_shape(r) +
  tm_raster(interpolate = FALSE,
            title = "[m/s]",
            #palette = "viridis",
            pal = c("#E1F5C4", "#EDE574", "#F9D423", "#FC913A", "#FF4E50", "purple"),
            style = 'pretty',
            n = 10,
            legend.is.portrait = TRUE) +
  #labels = as.character(sprintf("%.2f", seq(0, 1, 0.05)))) +
  tm_shape(fr_bnd2)+
  tm_borders() +
  tm_shape(fr2, col = "black")+
  tm_polygons(alpha = 0.10) -> p

print(p)
tmap_save(tm = p, filename = "poryw_roczny_percentyl99.png")
