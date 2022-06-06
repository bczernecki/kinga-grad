# liczba dni z gradem w Polsce:
library(raster)
library(climate)
library(dplyr)
library(rgdal)
library(sp)


df = meteo_imgw_monthly(rank = "synop", year = 1971:2020)
wsp = meteo_imgw_monthly(rank = "synop", year = 1971:2020, coords = TRUE)


df %>%
  group_by(id) %>%
  summarise(grad = sum(hail_days),
            liczba = n()) %>%
  filter(liczba > 500) -> grad

stacje = select(wsp, id:station) %>% distinct()
grad = left_join(grad, stacje, by = c("id" = "id"))

grad = grad[!duplicated(grad$id),]
grad = grad[!grad$station == "CZĘSTOCHOWA",]
grad$wsp = 600/grad$liczba
grad$grad = grad$grad * grad$wsp
grad$grad = grad$grad / 50

plot(grad$X, grad$Y, cex = 0.01)
text(grad$X, grad$Y, round(grad$grad, 1))

coordinates(grad) = ~X + Y
proj4string(grad) = "+init=epsg:4326"
plot(grad)

r = getData(name = "alt", country = "POL")
crs(r) = crs(grad)
r2 = as(r, "SpatialGridDataFrame")
grad
mapa_idw <- gstat::idw(grad ~ 1, grad, newdata = r2, idp = 3)
plot(mapa_idw)

grad$alt = over(grad, r2)
as.data.frame(grad)
grad@data$alt$POL_msk_alt[3] = 1990
grad@data$alt$POL_msk_alt[46] = 5
grad$alt

#r = as(r, "SpatialGridDataFrame")
r3 = spTransform(r2, "+init=epsg:2180")
# to niestety bedzie miec swoje konsekwencje zwiazane z brakiem
# mozliwosci wygenerowanie automatycznie rastra
names(r3) = "alt"
names(grad)
r3$lon = coordinates(r3)[,1]
r3$lat = coordinates(r3)[,1]
names(r3)

names(grad)[6] = "alt"
grad = spTransform(grad,  "+init=epsg:2180")
grad$lon = coordinates(grad)[,1]
grad$lat = coordinates(grad)[,2]
head(grad)

library(automap)
names(grad)
grad@data$alt = grad@data$alt$POL_msk_alt
head(grad)
head(r3)

grad$alt[7] = 1600

krige
wynik = autoKrige(grad~lat+lon+alt, input_data = grad, verbose = TRUE,
                  new_data = r3)

plot(wynik)
col.regions = c("#EDF8B1", "#C7E9B4", "#7FCDBB", "#41B6C4",
                "#1D91C0", "#225EA8", "#0C2C84", "#5A005A")
spplot(wynik$krige_output, zcol = "var1.pred",
       cuts = length(col.regions) - 1)

library(gstat)
grad$grad_log = log(grad$grad)
vario = variogram(grad_log ~ lon+lat+alt, locations = grad)
plot(vario)
model = fit.variogram(vario, vgm(model = "Sph", nugget = 0.0))
ok = krige(grad_log ~ lon+lat+alt,
           locations = grad,
           newdata = r3,
           model = model)
plot(ok)
wynik$krige_output$var1.pred = ok$var1.pred

plot(wynik)
# musimy zatem zrasteryzowac punkty np. w ten sposob:
xy = wynik$krige_output@coords
z = wynik$krige_output$var1.pred[]
xyz = cbind.data.frame(xy, z)

colnames(xyz) = c("x", "y", "z")
coordinates(xyz) = ~x+y
crs(xyz) = "+init=epsg:2180"
# uzyjmy teraz pakietu terra, ktorego jeszcze nie znamy z zajec:
library(terra)
xyz = vect(xyz)
# tworzymy pusty raster na wyniki
r10 = rast(xyz, ncol = 500, nrows = 600)
res = terra::rasterize(x = xyz, r10, "z")
plot(exp(res))

izolinie = rasterToContour(raster(res),
                           levels = seq(from = 1, to = 10, by = 1))
plot(izolinie, add = TRUE)

pl = getData(name = "GADM", country = "POL", level = 1)
names(res) = "days"
# lub za pomoca tmapa:
grad$dane = round(grad$grad, 1)
kolory = colorRampPalette(c("orange", "yellow", "white",  "lightblue"))
library(tmap)
pl = spTransform(pl, crs(res))


grad$label = format(round(grad$grad, 1), nsmall = 1)

p = tm_shape(res) +
  tm_raster("days", n = 10, title = "events / year") +
  #palette=get_brewer_pal(palette="OrRd", n=5, plot=FALSE)
  tm_shape(grad) +
  #tm_bubbles("dane", col = "dane") +
  tm_text("label", col = "black", size = 0.6) +
  tm_shape(pl) +
  tm_borders() +
  tm_legend(show = TRUE) +
  tm_layout(main.title = "Modelled and observed hail probability per year (1971-2020)",
            main.title.size = 1, legend.outside = TRUE)

print(p)
tmap_save(p, filename = "data/figures/mapa.png")
tmap_save(p, filename = "data/figures/mapa.svg")
#tm_shape(izolinie) +
#  tm_iso(remove.overlap = TRUE, along.lines = TRUE)
