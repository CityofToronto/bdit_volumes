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

########################################
# ARTERYDATA - Upload differences to PG
########################################

# to be done
