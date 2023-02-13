# Wykorzystując bazę SQLite zawartą pliku 'homework.db' oblicz MEDIANĘ liczby przylotów
# i odlotów na lotnisku w Los Angeles w każdym z 12 miesięcy w roku.
# Następnie zapisz wynik do pliku CSV. (oczekiwany wynik masz w pliku Zadanie_domowe_02_wynik.csv)
#
# Zwróc uwagę, że dla każdego miesiąca masz podane informacje o kilku rodzajów lotów. Należy
# więc je wstępnie zsumować.

library(DBI)
library(RSQLite)
library(dbplyr)
library(tidyverse)
library(lubridate)


drv <- dbDriver("SQLite")

con <- dbConnect(drv, "Zadanie_domowe_02_homework.db", flags = SQLITE_RO) # połączenie w trybie tylko do odczytu, aby przypadkiem nie zmodyfikować zawartości bazy

#dbplyr
tbl(con, 'flights')
#DBI
dbGetQuery(con, 'SELECT * FROM flights')

db_data = tbl(con, 'flights') %>% collect()

db_data %>% select(ReportPeriod, Arrival_Departure, FlightOpsCount) %>%  
  mutate( Date = mdy(substr(ReportPeriod,1,10)),
          Year = year(Date),
          Month = month(Date)) %>%
  group_by(Month, Year, Arrival_Departure) %>%
  summarise(Month_sum = sum(FlightOpsCount)) %>%
  group_by(Month, Arrival_Departure) %>% 
  summarise(FlightOpsCount = median(Month_sum)) %>%  
  mutate(Month = month.name[Month]) %>% 
  write_csv('Zadanie_domowe_02_wynik_MK.csv')

dbDisconnect(con)

# oczekiwany wynik:
readr::read_csv('Zadanie_domowe_02_wynik.csv')


