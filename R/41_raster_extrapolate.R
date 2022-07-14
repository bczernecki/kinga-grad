library(raster)
library(terra)
#r <- raster(system.file("external/test.grd", package="raster"))
r = raster("data/opad_reinterpol/francja_40_60_80_thresholds_geotiff_original.tif", band = 1)

raster_extrapolate = function(r, outputname = "data/opad_reinterpol/francja_40_thresholds_epsg2154.tif"){
  r = rast(r)
  bb = terra::ext(r)
  e = terra::ext(bb[1] - 0.2, bb[2] + 0.2, bb[3] - 0.2, bb[4] + 0.2)
  re = terra::extend(r, e)

  r_focal = raster::focal(raster(re), w = matrix(1,3,3), fun=function(x) mean(x, na.rm = TRUE))
  # plot(re, add = FALSE)
  # plot(r_focal, add = TRUE)

  values_re = getValues(raster(re))
  values_r_focal = getValues(raster(r_focal))

  wartosci = ifelse(is.na(values_re), values_r_focal, values_re)
  final_raster = raster(re)
  final_raster[] = wartosci

  output_raster =  projectRaster(final_raster, crs = "+init=epsg:2154")

  writeRaster(output_raster, filename = outputname, overwrite = TRUE)
  return(plot(output_raster))
}

r = raster("data/opad_reinterpol/francja_40_60_80_thresholds_geotiff_original.tif", band = 1)
raster_extrapolate(r, outputname = "data/opad_reinterpol/francja_40_thresholds_epsg2154.tif")

r = raster("data/opad_reinterpol/francja_40_60_80_thresholds_geotiff_original.tif", band = 2)
raster_extrapolate(r, outputname = "data/opad_reinterpol/francja_60_thresholds_epsg2154.tif")

r = raster("data/opad_reinterpol/francja_40_60_80_thresholds_geotiff_original.tif", band = 3)
raster_extrapolate(r, outputname = "data/opad_reinterpol/francja_80_thresholds_epsg2154.tif")
