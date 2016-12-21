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

# Adding Streets that are missing
custom_links <- read.csv("custom_links.csv", stringsAsFactors = F)
links <- rbind(links,custom_links)

links[links$linear_name_id == 105,]$dir <- 'NB'
links[links$linear_name_id == 106,]$dir <- 'SB'
links[links$linear_name_id == 1801,]$dir <- 'SB'
links[links$centreline_id %in% c(908049,908024,14254835),]$dir <- 'SB'
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
                912467,912385,14662488,5780712,14600817,
                106620,2295374,14025307,14025308,6943002,
                4118784,112383,14066562,30003266,30003265,
                1145169,1145179,110325,110302,3484503,
                409,9038692,20037190,20037189)

for (i in 1:nrow(corridors)){
  # (FIXED) Don Mills Road (100) - Splits into Don Mills Road W + E for a portion
  # (FIXED) Eglinton (125) - far east end, road splits
  # (FIXED) Leslie (225) - huge gap between Gerrard and Eglinton
  # (EXCLUDED) Logan (228) - one-way streets in middle of corridor
  # (FIXED) Pape (280) - gap just north of Gerrard
  # (FIXED) St. Clair Ave E (339) - Gap across DVP
  # (FIXED) Bloor (458) - Gap at Kipling
  # (FIXED) Dufferin (557) - Gap at Allen
  # (FIXED) Keele (703) - Gaps at St. Clair, Eglinton
  # (FIXED) 427 S (1801) - Two links are identified as NB based on seg_dir
  # (FIXED) Islington (1863) - Weird directoinal segments at Rexdale
  # Lakeshore (1962) - Lakeshore WB weird interaction with Gardiner ramp
  # Martin Grove (2066) - Gap at Gaylord Ave
  # Avenue (2924) - Gap at Lonsdale
  # Davenport (3269) - Gap at Mcpherson
  # Eastern (3356) - Mistake in naming between Eastern Ave & Eastern Ave Dirversion
  # Gerrard St E (3495) - Gap at Coxwell
  # Lakeshore Blvd E (3803) - Gap at Cherry
  # Mount Pleasant (4022) - Gap at Lawrence
  # Pharmacy (8691) - Gap at 401
  
  corridor_id <- as.numeric(corridors[i,"linear_name_id"])
  
  if (!(corridor_id %in% c(228))){
    
    
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
    
    num_links <- nrow(sub_links)
    if (corridor_id == 3786){num_links <- 150}
    if (corridor_id == 3828){num_links <- 156} # Gap at Bayview
    if (corridor_id == 7145 & direction == "EB"){num_links <- 46} # York Mills / Parkwood Village weirdness
    if (corridor_id == 8454){num_links <- 62}
    if (corridor_id == 225){num_links <- 77}
    if (corridor_id == 280){num_links <- 39}
    if (corridor_id == 339){num_links <- 74}
    if (corridor_id == 557){num_links <- 159}
    if (corridor_id == 703){num_links <- 105}
    
    for (j in 2:num_links){
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
