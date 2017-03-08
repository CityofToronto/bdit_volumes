library(RPostgreSQL)
library(ggplot2)
library(ggthemes)
library(viridis)
library(dplyr)

drv <- dbDriver("PostgreSQL")
source("connect/connect.R")

#### PERMANENT DATA
strSQL = paste("SELECT A.arterycode, A.count_type, A.loc, A.source, A.category_id, ",
               "EXTRACT (year from A.count_date) as yr, EXTRACT (month from A.count_date) as mth, ",
               "COUNT(*) AS num_days ",
               "FROM prj_volume.count_summary AS A ",
               "INNER JOIN (SELECT arterycode, count_type, COUNT(*) FROM prj_volume.count_summary ",
               "GROUP BY arterycode, count_type HAVING COUNT(*) > 150 ",
               "OR (count_type = 'PermAutom' AND COUNT(*) > 50)) AS B USING (arterycode) ",
               "GROUP BY A.arterycode, A.count_type, A.loc, A.source, A.category_id, ",
               "EXTRACT (year from A.count_date), EXTRACT (month from A.count_date) ",
               "ORDER BY A.arterycode, EXTRACT (year from A.count_date), EXTRACT (month from A.count_date)",
               sep = '')
data <- dbGetQuery(con, strSQL)

stations <- read.csv("perm_stations.csv")
data <- merge(data, stations, by = "arterycode")
data$mth_bin <- as.Date(paste(data$yr, data$mth, 1, sep = "."), format = "%Y.%m.%d")
data <- data[,c("arterycode","loc.x","type","road","mth_bin","num_days","road_rank","tot_days")]
data$name <- ifelse(data$type == "RESCU", paste(data$type, data$road, sep = " - "), "Other")


# HEAT MAP
gg <- ggplot(data, aes(x=mth_bin, y=loc.x, fill=num_days))
gg <- gg + geom_tile(color="grey", size=0.01)
gg <- gg + scale_fill_viridis(option = "magma", direction = -1,name="number of days", limits = c(0,32))
gg <- gg + labs(x = "Month",y = NULL, title="Permanent Count Stations in City of Toronto")
gg <- gg + theme_tufte(base_family = "arial")
gg <- gg + theme(legend.position="bottom")
gg <- gg + theme(plot.title=element_text(hjust=0, size=14))
gg <- gg + theme(legend.title=element_text(size=9))
gg <- gg + theme(legend.title.align=1)
gg <- gg + theme(legend.text=element_text(size=9))
gg <- gg + theme(axis.text.x = element_text(size = 5))
gg <- gg + theme(axis.text.y = element_text(size = 5))
gg <- gg + theme(legend.position="bottom")
gg <- gg + scale_x_date(breaks = scales::pretty_breaks(n=24))
ggsave("heatmap.svg",gg, width = 15, height = 15)

months <- as.data.frame(seq.Date(as.Date("1993/1/1"),as.Date("2016/9/1"),"months"))
colnames(months) <- "mth_bin"

summary <- summarise(group_by(data[data$num_days > 15, ], type, mth_bin), stations = n())

summary.1 <- merge(months, summary[summary$type == "RESCU",], by = "mth_bin", all.x = TRUE)
summary.1$type <- "RESCU"
summary.2 <- merge(months, summary[summary$type == "Other",], by = "mth_bin", all.x = TRUE)
summary.2$type <- "OTHER"

summary <- rbind(summary.1, summary.2)
rm(summary.1, summary.2, months)
summary[is.na(summary$stations), ]$stations <- 0
summary_pt <- summary[summary$mth_bin == as.Date("2016/9/1"),]

gg <- ggplot(summary, aes(x = mth_bin, y= stations, color = type))
gg <- gg + geom_point(data = summary_pt, size = 2)
gg <- gg + geom_line(size = .5)
gg <- gg + geom_label(data = summary_pt, aes(label = stations), nudge_x = 45, nudge_y = 2, show.legend = FALSE)
gg <- gg + theme_pander(base_family = "arial")
gg <- gg + ggtitle("Active Permanent Count Stations", subtitle = "Number of Stations in the City of Toronto")
gg <- gg + theme(axis.title.y = element_blank())
gg <- gg + labs(x = "Month")
gg <- gg + scale_x_date(breaks = scales::pretty_breaks(n=10))
gg <- gg + coord_cartesian(xlim = c(as.Date("1994/1/1"), as.Date("2016/6/1")))
gg <- gg + scale_y_continuous(breaks = scales::pretty_breaks(n=10))
gg <- gg + theme(legend.position = c(0.5, 0.95), legend.title = element_blank(), legend.direction = "horizontal")
gg
ggsave("activestations.png",gg, width = 10, height = 4.5)

#### ALL DATA
strSQL = paste("SELECT A.arterycode, A.source, COUNT(*) AS num_days ",
               "FROM prj_volume.count_summary AS A ",
               "WHERE EXTRACT(year FROM count_date) = 2015 ",
               "GROUP BY A.arterycode, A.source",
               sep = '')
data <- dbGetQuery(con, strSQL)
data$source <- ifelse(data$source == "RESCU", "RESCU", "OTHER")


# COUNT DAYS HISTOGRAM
gg1 <- ggplot(data, aes(x = num_days, fill = source))
gg1 <- gg1 + geom_histogram(binwidth = 7, size = 0.5, col = "black", boundary = -0.5)
gg1 <- gg1 + theme_pander(base_family = "arial")
gg1 <- gg1 + ggtitle("Count Stations by Data Availability (2015)", subtitle = "All Count Stations")
gg1 <- gg1 + theme(axis.title.y = element_blank())
gg1 <- gg1 + labs(x = "Number of Days")
gg1 <- gg1 + scale_x_continuous(breaks = scales::pretty_breaks(n=10))
gg1 <- gg1 + scale_y_continuous(breaks = scales::pretty_breaks(n=10))
gg1 <- gg1 + theme(legend.position = c(0.5, 0.95), legend.title = element_blank(), legend.direction = "horizontal")
gg1

gg2 <- ggplot(data[data$num_days >= 1 & data$num_days <= 10,], aes(x = num_days, fill = source))
gg2 <- gg2 + geom_histogram(binwidth = 1, size = 0.5, col = "black")
gg2 <- gg2 + theme_pander(base_family = "arial")
gg2 <- gg2 + ggtitle("Count Stations by Data Availability (2015)", subtitle = "Number of Days <= 10")
gg2 <- gg2 + theme(axis.title.y = element_blank())
gg2 <- gg2 + labs(x = "Number of Days")
gg2 <- gg2 + scale_x_continuous(breaks = scales::pretty_breaks(n=10))
gg2 <- gg2 + scale_y_continuous(breaks = scales::pretty_breaks(n=10), limits = c(0,500))
gg2 <- gg2 + theme(legend.position = c(0.5, 0.95), legend.title = element_blank(), legend.direction = "horizontal")
gg2

gg3 <- ggplot(data[data$num_days >= 25,], aes(x = num_days, fill = source))
gg3 <- gg3 + geom_histogram(binwidth = 25, size = 0.5, col = "black", boundary = -0.5)
gg3 <- gg3 + theme_pander(base_family = "arial")
gg3 <- gg3 + ggtitle("Count Stations by Data Availability (2015)", subtitle = "Number of Days >= 25")
gg3 <- gg3 + theme(axis.title.y = element_blank())
gg3 <- gg3 + labs(x = "Number of Days")
gg3 <- gg3 + scale_x_continuous(breaks = scales::pretty_breaks(n=12), limits = c(24,375))
gg3 <- gg3 + scale_y_continuous(breaks = scales::pretty_breaks(n=10), limits = c(0,50))
gg3 <- gg3 + theme(legend.position = c(0.5, 0.95), legend.title = element_blank(), legend.direction = "horizontal")
gg3

ggsave("hist01.svg",gg1, width = 10, height = 5)
ggsave("hist02.svg",gg2, width = 10, height = 5)
ggsave("hist03.svg",gg3, width = 10, height = 5)

#ALL DATA
strSQL = paste("SELECT A.arterycode, EXTRACT(year FROM A.count_date) as yr, COUNT(*) AS num_days ",
               "FROM prj_volume.count_summary AS A ",
               "GROUP BY A.arterycode, EXTRACT(year FROM A.count_date)",
               sep = '')
data <- dbGetQuery(con, strSQL)
stations <- read.csv("perm_stations.csv")
data <- merge(data, stations, by = "arterycode", all.x = TRUE)
data <- data[is.na(data$type),]
data <- data[,c("arterycode","yr")]
data$type <- "ATR"

strSQL = paste("SELECT A.arterycode, EXTRACT(year FROM A.count_date) as yr, COUNT(*) AS num_days ",
               "FROM prj_volume.count_summary_tmc AS A ",
               "GROUP BY A.arterycode, EXTRACT(year FROM A.count_date)",
               sep = '')
data_tmc <- dbGetQuery(con, strSQL)
data_tmc <- data_tmc[,c("arterycode","yr")]
data_tmc$type <- "TMC"

data_all <- rbind(data, data_tmc)

summary <- summarise(group_by(data_all, type, yr), stations = n())

gg <- ggplot(summary, aes(x = yr, y= stations, color = type))
gg <- gg + geom_line(size = 1.2, alpha = 0.8)
gg <- gg + geom_point(size = 2)
gg <- gg + theme_pander(base_family = "arial")
gg <- gg + ggtitle("Temporary Count Activity", subtitle = "Number of Unique Count Stations by Year")
gg <- gg + theme(axis.title.y = element_blank())
gg <- gg + labs(x = "Year")
gg <- gg + scale_x_continuous(breaks = scales::pretty_breaks(n=25), limits = c (1983, 2015))
gg <- gg + scale_y_continuous(breaks = scales::pretty_breaks(n=10), limits = c(0,3500))
gg <- gg + theme(legend.position = c(0.5, 0.95), legend.title = element_blank(), legend.direction = "horizontal")
gg
ggsave("tempstations.png",gg, width = 8, height = 4.5)
