set.seed(50)
arterydata <- read.csv("csv/arterydata.csv")
rm(samples)

cases <- unique(arterydata[c("artery_type","match_on_case")])

for (i in c(1,2)){
  for (j in cases[cases$artery_type == i,]$match_on_case){
    ad_subset <- subset(arterydata,artery_type == i & match_on_case == j)
    sample_df <- NULL
    if (i == 1){
      if (j == 1){
        sample_df <- ad_subset[sample(nrow(ad_subset), 138),]
      }
      if (j == 2){
        sample_df <- ad_subset[sample(nrow(ad_subset), 130),]
      }
      if (j == 3){
        sample_df <- ad_subset[sample(nrow(ad_subset), 95),]
      }
      if (j == 12){
        sample_df <- ad_subset[sample(nrow(ad_subset), 130),]
      }
    }
    if (i == 2 & j == 6){
      sample_df <- ad_subset[sample(nrow(ad_subset), 189),]
    }
    if (exists("samples")){
      samples <- rbind(samples, sample_df)
    } else {
      samples <- sample_df
    }
    
  }
}

write.csv(samples, "ac_samples.csv")
