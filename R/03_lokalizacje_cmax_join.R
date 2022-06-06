library(rvest)
library(readxl)
library(mapdata)
library(terra)
library(sf)
library(rgdal)
library(sp)


lokalizacje = readxl::read_excel("data/lokalizacje.xlsx", col_types = c("guess", "date", "numeric", "numeric"))
head(lokalizacje)

geo_sf = st_as_sf(lokalizacje, coords = c("longitude", "latitude"), crs = "EPSG:4326")
#plot(geo_sf)
coordinates(lokalizacje) = ~longitude + latitude

files = dir("data/cmax/raster/", full.names = TRUE)
files
r = raster::stack(files)
plot(r)

#r = raster(r)
res = raster::extract(r, lokalizacje)

library(tidyr)
lok = as.data.frame(lokalizacje)

res = as.data.frame(res)
res$id = lok$id

res = gather(res, key = "key", value = "value", -id)


head(lok)
lok$hail_date = as.character(lok$hail_date)

head(lok)
head(res)
res$hail_date = as.character(as.Date(res$key, format = "X%Y%m%d"))
colnames(res)[which(colnames(res) == "value")] = "cmax"
head(res)

library(dplyr)
head(res)
head(lok)
wynik = left_join(lok, res)

wynik = select(wynik, -key)
wynik$cmax = (wynik$cmax / 255) * 100
saveRDS(wynik, "data/df_cmax.rds")

hist((wynik$cmax / 255) * 100)

plot(r[[1]]/3)
map("world", add = T)

saveRDS(w)
