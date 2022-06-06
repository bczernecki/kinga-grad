cmax = readRDS("data/df_cmax.rds")
zhail = readRDS("data/df_zhail.rds")
eswd = readRDS("data/eswd.rds")

cmax_zhail = cbind.data.frame(cmax, zhail[,"zhail"])
colnames(cmax_zhail)[6] = "zhail"
head(cmax_zhail)
head(eswd)

eswd$id_duplicated = duplicated(eswd$id)
eswd2 = dplyr::filter(eswd, id_duplicated == FALSE)

res = dplyr::left_join(cmax_zhail, eswd2)
res$eswd = ifelse(res$id_duplicated == FALSE, 1, 0)
res$srednica = unlist(lapply(res$opis, function(x) strsplit(x, " cm")[[1]][2]))
res$srednica <- sub("^\\D+", "", res$srednica)
res = dplyr::select(res, -id_duplicated)
res = dplyr::select(res, -lokalizacja)
res$czas = gsub(r"{\s*\([^\)]+\)}","",as.character(res$czas))

writexl::write_xlsx(res, "data/wynik.xlsx")
