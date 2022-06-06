# najpierw nalezy odpalic konwersje blobow zhail do zlib'a
# potem interesuja nas tylko pliki .out
#

# konwersja blobow do rastrow:
files = dir("data/zhail/", pattern = "out", full.names = TRUE)

for (i in 1:length(files)) {
  print(paste(i, ": ", files[i]))
  a <- readBin(files[i], "int", 9000000, size = 1, signed = F)
  bok <- sqrt(length(a))
  a <- t(matrix(a, ncol = bok, nrow = bok, byrow = F))

  r = raster(nrows = 900, ncols = 900,
             xmn  = -449997.5,
             xmx = 451000.5,
             ymn = -450992.5,
             ymx = 450009.4,
             vals = a,
             crs = "+proj=aeqd +lat_0=52.3468 +lon_0=19.0926 +x_0=0 +y_0=0 +ellps=sphere +units=m +no_defs")

  writeRaster(r, filename = paste0("data/zhail/raster/", basename(files[i]), ".tif"), overwrite = TRUE)
}
# r2 =  projectRaster(r, crs = "+init=epsg:4326")
# plot(r2); map("world", add = T)


lokalizacje = readxl::read_excel("data/lokalizacje.xlsx", col_types = c("guess", "date", "numeric", "numeric"))
head(lokalizacje)

mm = substr(unique(lokalizacje$hail_date), 1, 2)
dd = substr(unique(lokalizacje$hail_date), 9, 10)

library(terra)
files = dir("data/zhail/raster", full.names = TRUE, pattern = ".tif")

dni = format(unique(lokalizacje$hail_date), "%Y%m%d")
# na dany dzien:
for (i in 1:length(dni)) {
  print(dni[i])
  pliki = files[grep(x = files, pattern = dni[i])]
  temp_rasters <- rast(pliki)

  a = max(temp_rasters, na.rm = TRUE)
  a[a == 0 ] = NA
  a = a/255
  #plot(a)
  r = raster(a)
  r2 =  projectRaster(r, crs = "+init=epsg:4326")
  plot(r2)
  map("world", add = TRUE)
  writeRaster(r2,
              filename = paste0("data/zhail/raster/dobowo/", dni[i],".tif"),
              overwrite = TRUE)

}


lokalizacje = readxl::read_excel("data/lokalizacje.xlsx", col_types = c("guess", "date", "numeric", "numeric"))
head(lokalizacje)
coordinates(lokalizacje) = ~longitude + latitude

files = dir("data/zhail/raster/dobowo/", full.names = TRUE)
files
r = raster::stack(files)
plot(r)
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
colnames(res)[which(colnames(res) == "value")] = "zhail"
head(res)

library(dplyr)
head(res)
head(lok)
wynik = left_join(lok, res)

wynik = dplyr::select(wynik, -key)

saveRDS(wynik, "data/df_zhail.rds")

plot(r[[1]])
map("world", add = T)
