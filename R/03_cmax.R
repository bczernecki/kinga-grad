library(raster)

lokalizacje = readxl::read_excel("data/lokalizacje.xlsx", col_types = c("guess", "date", "numeric", "numeric"))
head(lokalizacje)

mm = substr(unique(lokalizacje$data2), 1, 2)
dd = substr(unique(lokalizacje$data2), 4, 5)


# url = paste0("https://danepubliczne.imgw.pl/datastore/getfiledown/Arch/Polrad/Produkty/POLCOMP/COMPO_CMAX_250.comp.cmax/2021/",
#              mm, "/COMPO_CMAX_250.comp.cmax_2021-", mm, "-", dd, ".zip")

url  = paste0("https://danepubliczne.imgw.pl/datastore/getfiledown/Arch/Polrad/Produkty/POLCOMP/COMPO_ZHAIL.comp.zhail/2021/",
              mm, "/COMPO_ZHAIL.comp.zhail_2021-", mm, "-", dd, ".zip")
#dir.create("data/cmax")
for (i in 1:length(url)) {
  download.file(url = url[i],
                #destfile = paste0("data/cmax/", basename(url[i])),
                destfile = paste0("data/zhail/", basename(url[i])),
                mode = "wb")
}

# files = dir("data/cmax/", full.names = TRUE)
files = dir("data/zhail/", full.names = TRUE)
sapply(files, unzip)
library(terra)


  #files = dir("data/cmax/", full.names = TRUE, pattern = ".h5")
  files = dir("data/zhail/", full.names = TRUE, pattern = ".h5")

  dni = format(unique(lokalizacje$hail_date), "%Y%m%d")
  # na dany dzien:
  for (i in 1:length(dni)) {
    print(dni[i])
    pliki = files[grep(x = files, pattern = dni[i])]
    temp_rasters <- rast(pliki)

  a = max(temp_rasters, na.rm = TRUE)
 # plot(a)

  a[a == 255] = NA
  a[a <= 1 ] = NA
#  plot(a)
  r = raster(a)
  r2 =  projectRaster(r, crs = "+init=epsg:4326")
  plot(r2)
  writeRaster(r2,
              #filename = paste0("data/cmax/raster/", dni[i],".tif"),
              filename = paste0("data/zhail/raster/", dni[i],".tif"),
              overwrite = TRUE)

  }


lokalizacje$longitude
