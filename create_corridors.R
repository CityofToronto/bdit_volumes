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
strSQL <- paste0("SELECT centreline_id, linear_name_id, linear_name_full, from_intersection_id as fnode, to_intersection_id as tnode, shape_length ",
                 "FROM prj_volume.centreline ",
                 "WHERE feature_code_desc NOT IN ('Minor Arterial Ramp')")
links <- dbGetQuery(con, strSQL)

corridors <- corridors[order(corridors$linear_name_id),]

corridor_links <- data.frame(centreline_id = numeric(0),
                             linear_name_id = numeric(0),
                             order = numeric(0),
                             distance = numeric(0))

for (i in 1:nrow(corridors)){
  if (i !=7 & i !=8){
    corridor_id <- as.numeric(corridors[i,"linear_name_id"])
    sub_links <- subset(links, subset = (linear_name_id == corridor_id))
    link_id <- as.numeric(corridors[i, "start_id"])
    node_id <- as.numeric(subset(links, subset = (centreline_id == link_id))$fnode)
    dist <- 0
    if (nrow(subset(sub_links, fnode == node_id | tnode == node_id)) == 1){
      node_id <- subset(links, subset = (centreline_id == link_id))$tnode
    }
    corridor_links <- rbind(corridor_links,data.frame(centreline_id = link_id, linear_name_id = corridor_id, order = 1, distance = dist))
    
    for (j in 2:nrow(sub_links)){
      sub_links <- subset(sub_links, subset = (centreline_id != link_id))
      link <- subset(sub_links, subset = (fnode %in% node_id | tnode %in% node_id))
      link_id <- as.numeric(link$centreline_id)
      node_id <- ifelse(node_id == link$fnode, link$tnode, link$fnode)
      dist <- dist + link$shape_length
      corridor_links <- rbind(corridor_links,data.frame(centreline_id = link_id, linear_name_id = corridor_id, order = j, distance = dist))
    }
  }
}

write.csv(sub_links, "out.csv")
