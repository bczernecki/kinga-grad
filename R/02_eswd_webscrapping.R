# skrapowanie ESWD na podstawie dat i wspolrzednych zawartych w pliku excela:

library(rvest)
library(readxl)
library(mapdata)
library(RSelenium)


lokalizacje = readxl::read_excel("data/lokalizacje.xlsx", col_types = c("guess", "date", "numeric", "numeric"))
head(lokalizacje)

plot(lokalizacje$longitude, lokalizacje$latitude)
map("world", add = TRUE)
sort(unique(lokalizacje$hail_date))

lok = split(lokalizacje, lokalizacje$hail_date)

# selenium - otwarcie sesji:

rD = rsDriver(port = 5004L, browser = "firefox") # uruchamiamy sesję
remDr = rD$client



for (day_no in 1:length(lok)) {
  print(day_no)
  remDr$navigate("https://eswd.eu/cgi-bin/eswd.cgi")
  min_lon = min(lok[[day_no]]$longitude - 0.5)
  min_lat = min(lok[[day_no]]$latitude - 0.5)
  max_lon = max(lok[[day_no]]$longitude + 0.5)
  max_lat = max(lok[[day_no]]$latitude + 0.5)

  dzien = as.Date(lok[[day_no]]$hail_date)[1]


  webElem = remDr$findElement(using = "css", "input[name='start_date']")
  webElem$highlightElement()
  webElem$clearElement()
  webElem$sendKeysToElement(list(dzien))

  webElem = remDr$findElement(using = "css", "input[name='end_date']")
  webElem$highlightElement()
  webElem$clearElement()
  webElem$sendKeysToElement(list(dzien, key = "enter"))

  # tego nie potrzebuje jesli i tak jade po wspolrzednych:
  # webElem = remDr$findElement(using = "name", value = "selected_countries")
  # webElem$highlightElement()
  # webElem$clickElement()
  # webElem$sendKeysToElement(list("Pol", key = "enter"))
  # webElem$clickElement()

  webElem = remDr$findElement(using = "name", value = "HAIL")
  webElem$highlightElement()
  webElem$clickElement()

  webElem = remDr$findElement(using = "name", value = "latitude_selected")
  webElem$highlightElement()
  webElem$clickElement()

  webElem = remDr$findElement(using = "name", value = "longitude_selected")
  webElem$highlightElement()
  webElem$clickElement()

  # wpisz wspolrzedne: - lat
  webElem = remDr$findElement(using = "name", value = "min_latitude")
  webElem$highlightElement()
  webElem$clearElement()
  webElem$sendKeysToElement(list(substr(as.character(min_lat), 1, 5)))

  webElem = remDr$findElement(using = "name", value = "max_latitude")
  webElem$highlightElement()
  webElem$clearElement()
  webElem$sendKeysToElement(list(substr(as.character(max_lat), 1, 5)))

  # wpisz wspolrzedne: - lon
  webElem = remDr$findElement(using = "name", value = "min_longitude")
  webElem$highlightElement()
  webElem$clearElement()
  webElem$sendKeysToElement(list(substr(as.character(min_lon), 1, 5)))

  webElem = remDr$findElement(using = "name", value = "max_longitude")
  webElem$highlightElement()
  webElem$clearElement()
  webElem$sendKeysToElement(list(substr(as.character(max_lon), 1, 5)))

  webElem = remDr$findElement(using = "id", value = "button1_bottom")
  webElem$highlightElement()
  webElem$clickElement()

  Sys.sleep(5)
#zrodlo = remDr$getPageSource() # źródło strony
#kod = zrodlo[[1]]


webElem = remDr$findElement(using = "class", value = "withmargin")
webElem$highlightElement()
b = webElem$getPageSource()[[1]]

b1 = read_html(b)
tabelka = html_table(b1)
test = lapply(tabelka, function(x) grepl(x = x$X1, pattern = "hailto"))
ind = which(unlist(lapply(test, any)))

if(length(ind) > 0) {
  tabelka = tabelka[[ind]]
} else {
  tabelka = data.frame(a = 1)
}

if (nrow(tabelka) == 1) {
  print("brak danych dla dnia")
  print(dzien)
} else {
  print("znaleziono dane dla dnia")
  print(dzien)

  tabelka = tabelka[grepl(x = tabelka$X1, pattern = "hailto"), ]
  print(paste("liczba wierszy to ", nrow(tabelka)))


  if (!exists("wynik")) {
    wynik = NULL
  }

for (i in seq_len(nrow(tabelka))) {
  tmp = strsplit(tabelka$X2[i], "\n")[[1]]
  res = data.frame(miejscowosc = tmp[1],
             lokalizacja = tmp[2],
             dzien = dzien,
             czas = tmp[3],
             opis = tabelka$X3[i])
  wynik = rbind.data.frame(wynik, res)
}

} # koniec elsa


} # end of loop for day_no
