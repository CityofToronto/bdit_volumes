library(RPostgreSQL)
library(rjson)
library(dplyr)
library(lubridate)

########################################
# CONNECT TO POSTGRESQL
########################################
drv <- dbDriver("PostgreSQL")
drv2 <- dbDriver("PostgreSQL")
source("connect/connect.R")

########################################
# ARTERYDATA - Check Differences
########################################
strSQL <- paste0("SELECT * FROM traffic.arterydata ORDER BY arterycode")
curr_ad <- dbGetQuery(con, strSQL)

strSQL <- paste0("SELECT * FROM o_arterydata ORDER BY arterycode")
live_ad <- dbGetQuery(con2, strSQL)

curr_ad <- data.frame(apply(curr_ad, 2, function(x) gsub("^$|% $", NA, x)), stringsAsFactors = FALSE)
curr_ad[,1] <- as.numeric(curr_ad[,1])
curr_ad[,2] <- as.numeric(curr_ad[,2])
curr_ad[,19] <- as.numeric(curr_ad[,19])

new_ad <- anti_join(live_ad, curr_ad)
new_ad <- new_ad[order(new_ad$arterycode),]

########################################
# ARTERYDATA - Upload differences to PG
########################################

dbWriteTable(con, c("prj_volume","new_arterydata"), new_ad, row.names = F, overwrite = T)

########################################
# COUNTINFO + CNT_DET
########################################

strSQL <- paste0("SELECT * FROM traffic.countinfo ORDER BY count_info_id")
curr_ci <- dbGetQuery(con, strSQL)
curr_ci <- data.frame(apply(curr_ci, 2, function(x) gsub("^$|% $", NA, x)), stringsAsFactors = FALSE)
curr_ci[,1] <- as.numeric(curr_ci[,1])
curr_ci[,2] <- as.numeric(curr_ci[,2])
curr_ci[,3] <- as.Date(curr_ci[,3])
curr_ci[,4] <- as.numeric(curr_ci[,4])
curr_ci[,9] <- date(curr_ci[,9])
curr_ci[,10] <- as.numeric(curr_ci[,10])
curr_ci[,11] <- as.numeric(curr_ci[,11])

strSQL <- paste0("SELECT * FROM o_countinfo ORDER BY count_info_id")
live_ci <- dbGetQuery(con2, strSQL)
live_ci[,9] <- date(live_ci[,9])

new_ci <- anti_join(live_ci, curr_ci)

dbWriteTable(con, c("prj_volume","new_countinfo"), new_ci, row.names = F, overwrite = T)
dbWriteTable(con2, c("new_countinfo"), new_ci, row.names = F, overwrite = T)

strSQL <- paste0("SELECT * FROM o_cnt_det INNER JOIN new_countinfo USING (count_info_id) ORDER BY id")
new_cnt_det <- dbGetQuery(con2, strSQL)
dbWriteTable(con, c("prj_volume","new_cnt_det"), new_cnt_det, row.names = F, overwrite = T)

########################################
# COUNTINFOMICS + DET
########################################


strSQL <- paste0("SELECT * FROM traffic.countinfomics ORDER BY count_info_id")
curr_ci <- dbGetQuery(con, strSQL)
curr_ci <- data.frame(apply(curr_ci, 2, function(x) gsub("^$|% $", NA, x)), stringsAsFactors = FALSE)
curr_ci[,1] <- as.numeric(curr_ci[,1])
curr_ci[,2] <- as.numeric(curr_ci[,2])
curr_ci[,4] <- date(curr_ci[,4])
curr_ci[,5] <- as.numeric(curr_ci[,5])
curr_ci[,8] <- date(curr_ci[,8])
curr_ci[,9] <- as.numeric(curr_ci[,9])
curr_ci[,10] <- as.numeric(curr_ci[,10])

strSQL <- paste0("SELECT * FROM o_countinfomics ORDER BY count_info_id")
live_ci <- dbGetQuery(con2, strSQL)
live_ci <- live_ci[,c(1:7,10:12)]
live_ci[,4] <- date(live_ci[,4])
live_ci[,8] <- date(live_ci[,8])

new_ci <- anti_join(live_ci, curr_ci)

dbWriteTable(con, c("prj_volume","new_countinfomics"), new_ci, row.names = F, overwrite = T)
dbWriteTable(con2, c("new_countinfomics"), new_ci, row.names = F, overwrite = T)

strSQL <- paste0("SELECT * FROM o_det INNER JOIN new_countinfomics USING (count_info_id) ORDER BY id")
new_det <- dbGetQuery(con2, strSQL)
dbWriteTable(con, c("prj_volume","new_det"), new_det, row.names = F, overwrite = T)
