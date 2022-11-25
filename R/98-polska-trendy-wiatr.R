library(climate)
library(dplyr)
df = meteo_imgw_hourly(year = 1993:2022, coords = TRUE) # tylko jak jest duzo ramu
#df = meteo_imgw_hourly(year = 2021:2022, coords = TRUE)
test = select(df, id:hour, gust)
test = readRDS("~/Downloads/porywy_pl.rds")
test2 = filter(test, gust > 0)
tail(test2)
test2 %>% group_by(station, yy) %>% summarise(poryw_mx = max(gust, na.rm = T)) -> test3


test4 = test3 %>%
  filter(!station %in% c("KASPROWY WIERCH", "ŚNIEŻKA", "HALA GĄSIENICOWA"), yy > 1992)

library(ggplot2)

p = ggplot(data = test4, aes(x = as.factor(yy), y = poryw_mx, group = yy)) +
  geom_violin(fill = "lightblue") +
  scale_x_discrete(breaks = seq(1990, 2020, 5)) +
  labs(x = "lata", y = "poryw wiatru (m/s)",
       title = "Maksymalne porywy w Polsce",
       subtitle = "Wartości maksymalne w danych latach na stacjach IMGW-PIB (1993-2022)")  +
  theme_minimal()

p
ggsave(p, filename = "~/kinga-maksymalne-porywy-wg-imgw.png", width = 8, height = 5)


ggplot(data = test4, aes(x = yy, y = poryw_mx)) +
  geom_smooth(method="loess", se=F)  +
  geom_boxplot(aes(group = yy))
theme_minimal()
ggplot(data = test4, aes(x = as.factor(yy), y = poryw_mx)) + geom_violin()


test4 %>% group_by(yy) %>% summarise(mediana = quantile(poryw_mx, 0.97, na.rm = T)) %>% plot(., type = 'l')
test5 =test %>% group_by(station, yy) %>%
  summarise(q99 = quantile(gust, 0.99, na.rm = T),
            q90 = quantile(gust, 0.9, na.rm = T))

plot(test5, type = "lm")
lm(mediana ~ yy, test5)

head(test2)

b = test2 %>% group_by(yy) %>% summarise(powyzej_20ms = sum(gust>20),
                                         powyzej_25ms = sum(gust>25),
                                         powyzej_32ms = sum(gust>32))
head(b)
library(tidyr)
res = pivot_longer(b, -yy)
p2 = ggplot(res, aes(x = yy, y = value)) +
  geom_point() +
  geom_line() +
  geom_smooth(se = F) +
  geom_smooth(method = "lm", col = "red", se = F, lwd = 3) +
  facet_wrap(~name, scales = "free", ncol = 3)  +
  labs(x = "lata", y = "Łączny czas trwania porywów (godz)",
       title = "Czas trwania porywów powyżej 20, 25 i 32 m/s",
       subtitle = "Dane pomiarowe - IMGW-PIB (1993-2022)")  +
  theme_minimal()

ggsave(p2, filename = "~/kinga-porywy-czas-trwania-wg-imgw.png", width = 10, height = 5)
