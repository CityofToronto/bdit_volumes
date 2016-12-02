library(RPostgreSQL)

##############################################
# IMPORT RAW DATA FROM POSTGRESQL
##############################################

drv <- dbDriver("PostgreSQL")
source("connect/connect.R")

##############################################
# FUNCTION DEFINITIONS
##############################################

strSQL <- "SELECT * FROM prj_volume.corr_dir"
corridors <- dbGetQuery(con, strSQL)
strSQL <- "SELECT centreline_id, linear_name_id, linear_name_full, from_intersection_id as fnode, to_intersection_id as tnode FROM prj_volume.centreline"
links <- dbGetQuery(con, strSQL)

corridors <- corridors[order(corridors$linear_name_id),]

corridor_links <- data.frame(centreline_id = numeric(0),
                             linear_name_id = numeric(0),
                             order = numeric(0))

for (i in 1:nrow(corridors)){
  corridor_id <- corridors[1,"linear_name_id"]
  sub_links <- subset(links, subset = (linear_name_id == corridor_id))
  link_id <- corridors[i, "start_id"]
  node_id <- subset(links, subset = (centreline_id == link_id))$fnode
  if (nrow(subset(sub_links, fnode == node_id | tnode == node_id)) == 1){
    node_id <- subset(links, subset = (centreline_id == link_id))$tnode
  }
  corridor_links <- rbind(corridor_links,data.frame(centreline_id = corridor_id, linear_name_id = link_id, order = i))
  
}
