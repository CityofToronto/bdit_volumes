library(RPostgreSQL)
library(tidyr)
library(dplyr)
library(ggplot2)
library(ggthemes)


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
data_clusters <- kmeans(data_hr_wide[,3:26], 6, nstart = 50)
data_hr_wide <- bind_cols(as.data.frame(data_hr_wide), as.data.frame(data_clusters$cluster))
names(data_hr_wide)[27] <- "cluster"

data_hr <- gather(data_hr_wide, hour, vol_weight, 3:26)
data_hr$hour <- as.numeric(data_hr$hour)
data_hr_avg <- summarise(group_by(data_hr, cluster, hour), vol_weight = mean(vol_weight))

clstr_plot <- ggplot(data_hr, aes(x = hour, y = vol_weight, group = arterycode)) +
  geom_line(alpha = 0.3, size = 0.05, color = "dodgerblue3") +
  geom_line(data = data_hr_avg, color = "black", group = 1) +
  scale_x_continuous(breaks = c(0,4,8,12,16,20)) +
  facet_wrap(~ cluster, ncol = 3) +
  theme_few()
ggsave(clstr_plot, file = "cluster.svg", width = 10, height = 10)

cluster_table <- data_hr_wide[,c(1,27)]
cluster_table$centreline_id <- 0
cluster_table$dir_bin <- 0

dbWriteTable(con, c("prj_volume","clusters"), value=cluster_table,overwrite=TRUE,row.names=FALSE)
