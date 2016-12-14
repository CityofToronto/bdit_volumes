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
strSQL <- paste0("SELECT DISTINCT centreline_id, linear_name_id, linear_name_full, from_intersection_id as fnode, to_intersection_id as tnode, seg_dir(oneway_dir_code,dir,shape) as dir, shape_length ",
                  "FROM prj_volume.centreline ",
                  "INNER JOIN (SELECT linear_name_id, dir FROM prj_volume.corr_dir) cd USING (linear_name_id) ",
                  "WHERE feature_code_desc NOT IN ('Minor Arterial Ramp','Major Arterial Ramp')")
links <- dbGetQuery(con, strSQL)

corridors <- corridors[order(corridors$linear_name_id),]

corridor_links <- data.frame(centreline_id = numeric(0),
                             dir = character(),
                             linear_name_id = numeric(0),
                             order = numeric(0),
                             distance = numeric(0),
                             stringsAsFactors = F)

# 906 - should be labelled as ramp
excl_links <- c(906,911851,911872,911925,14615642,
                7930552,7974067,9071,14073454,14073455,
                912467,912385,14662488,5780712,14600817)

for (i in 1:nrow(corridors)){
  # Eglinton (125) - far east end, road splits
  # Leslie (225) - huge gap between Gerrard and Eglinton
  # Logan (228) - one-way streets in middle of corridor
  # Pape (280) - gap just north of Gerrard
  # St. Clair Ave E (339) - Gap across DVP
  # Bloor (458) - Gap at Kipling
  # Dufferin (557) - Gap at Allen
  # Keele (703) - Gaps at St. Clair, Eglinton
  # 427 S (1801) - Two links are identified as NB based on seg_dir
  # Islington (1863) - Weird directoinal segments at Rexdale
  # Lakeshore (1962) - Lakeshore WB weird interaction with Gardiner ramp
  # Martin Grove (2066) - Gap at Gaylord Ave
  # Avenue (2924) - Gap at Lonsdale
  # Davenport (3269) - Gap at Mcpherson
  
  if (!(i %in% c(9,10,12,13,14,15,16,17,18,19,20,23,24,25,26,33,34,35,36,43,44,60,61,62,66,67,68,79,80,81,82))){
    corridor_id <- as.numeric(corridors[i,"linear_name_id"])
    direction <- corridors[i,"dir"]
    sub_links <- subset(links, subset = (linear_name_id == corridor_id & !(centreline_id %in% excl_links)))
    sub_links <- subset(sub_links, subset = (dir %in% c("BOTH",direction)) )
    link_id <- as.numeric(corridors[i, "start_id"])
    node_id <- as.numeric(subset(links, subset = (centreline_id == link_id))$fnode)
    dist <- 0
    if (nrow(subset(sub_links, fnode == node_id | tnode == node_id)) == 1){
      node_id <- subset(links, subset = (centreline_id == link_id))$tnode
    }
    corridor_links <- rbind(corridor_links,data.frame(centreline_id = link_id, dir = direction, linear_name_id = corridor_id, order = 1, distance = dist))
    
    for (j in 2:nrow(sub_links)){
      sub_links <- subset(sub_links, subset = (centreline_id != link_id))
      link <- subset(sub_links, subset = (fnode %in% node_id | tnode %in% node_id))
      link_id <- as.numeric(link$centreline_id)
      node_id <- ifelse(node_id == link$fnode, link$tnode, link$fnode)
      dist <- dist + link$shape_length
      corridor_links <- rbind(corridor_links,data.frame(centreline_id = link_id, dir = direction, linear_name_id = corridor_id, order = j, distance = dist))
    }
  }
}

write.csv(sub_links, "out.csv")
