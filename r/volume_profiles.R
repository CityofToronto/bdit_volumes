library(RPostgreSQL)
library(tidyr)
library(dplyr)
library(ggplot2)


################################
# IMPORT FROM POSTGRESQL
################################
drv <- dbDriver("PostgreSQL")
source("connect/connect.R")

strSQL = 
  paste0("SELECT * ",
         "FROM prj_volume.vol_profiles_last")
data <- dbGetQuery(con, strSQL)
data$hour <- as.numeric(format(as.POSIXct(data$time_bin,format = "%H:%M:%S"), "%H"))
data$yr <- as.numeric(format(data$count_date, "%Y"))
data_hr <- summarise(group_by(data, arterycode, yr, hour), vol_weight = sum(vol_weight))

data_hr_wide <- spread(data_hr, key = hour, value = vol_weight)
data_clusters <- kmeans(data_hr_wide[,3:26], 6, nstart = 20)
data_hr_wide <- bind_cols(as.data.frame(data_hr_wide), as.data.frame(data_clusters$cluster))
names(data_hr_wide)[27] <- "cluster"

data_hr <- gather(data_hr_wide, hour, vol_weight, 3:26)
data_hr$hour <- as.numeric(data_hr$hour)
data_hr_avg <- summarise(group_by(data_hr, cluster, hour), vol_weight = mean(vol_weight))

ggplot(data_hr, aes(x = hour, y = vol_weight, group = arterycode, color = yr)) +
  geom_line(alpha = 0.3, size = 0.05) +
  geom_line(data = data_hr_avg, alpha = 1, group = 1, color = "black") +
  scale_x_continuous(breaks = c(0,4,8,12,16,20)) +
  facet_wrap(~ cluster)