library(raster)
library(terra)
#r <- raster(system.file("external/test.grd", package="raster"))
r = raster("data/opad_reinterpol/francja_40_60_80_thresholds_geotiff_original.tif", band = 1)
r = terra::rast("data/opad_reinterpol/francja_40_60_80_thresholds_geotiff_original.tif")

raster_extrapolate = function(filename = "data/opad_reinterpol/francja_40_60_80_thresholds_geotiff_original.tif",
                              outputname = "data/opad_reinterpol/francja_60_thresholds_epsg2154_v2.tif",
                              band = 2){
  r = terra::rast(filename)[[band]]
  #r = terra::rast(r)
  bb = terra::ext(r)
  e = terra::ext(bb[1] - 0.4, bb[2] + 0.4, bb[3] - 0.4, bb[4] + 0.4)
  re = raster::extend(r, e)

  r_focal = raster::focal(raster::raster(re), w = matrix(1,3,3),
                          fun = function(x) mean(x, na.rm = TRUE))
  # r_focal = raster::focal(r_focal, w = matrix(1,3,3),
  #                         fun = function(x) mean(x, na.rm = TRUE))

   plot(re, add = FALSE)
   plot(r_focal, add = TRUE)
   plot(re, add = TRUE)

  values_re = getValues(raster::raster(re))
  values_r_focal = getValues(r_focal)

  ind = which(is.na(values_re))
  values_re[ind] = values_r_focal[ind]
  final_raster = raster::raster(re)
  final_raster[] = values_re

  puste = which(is.na(values_re))
  values_re[puste] = values_r_focal[puste]
  final_raster = r_focal
  final_raster[] = values_re
  plot(final_raster)

  output_raster =  projectRaster(final_raster, crs = "+init=epsg:2154")

  writeRaster(output_raster, filename = outputname, overwrite = TRUE)
  return(plot(output_raster))
}

raster_extrapolate(outputname = "data/opad_reinterpol/francja_40_thresholds_epsg2154_v2.tif", band = 1)
raster_extrapolate(outputname = "data/opad_reinterpol/francja_60_thresholds_epsg2154_v2.tif", band = 2)
raster_extrapolate(outputname = "data/opad_reinterpol/francja_80_thresholds_epsg2154_v2.tif", band = 3)

