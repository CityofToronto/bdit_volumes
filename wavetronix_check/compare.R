library(RPostgreSQL)

raw <- read.csv("csv/Parkside HD.csv", skip = 2, stringsAsFactors = F)
raw <- raw[,c(1:12, 14:17)]
colnames(raw) <- c("lane_name", "volume", "occupancy", "speed", "speed_85", "class_1","class_2", "class_3", "class_4","class_5","class_6", "class_7", "headway", "gap", "datetime_bin","interval")
raw[,15] <- as.POSIXct(raw[,15],format = "%d/%m/%y %H:%M:%S")

drv <- dbDriver("PostgreSQL")
source("connect/connect.R")
dbWriteTable(con, c("prj_volume","wavetronix_raw"), raw, row.names = F, overwrite = T)
