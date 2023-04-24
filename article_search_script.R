library(rcrossref) #id_converter
library(rentrez) #query
library (miRetrieve) #parsing
library(tidytext)
library(tidyverse)
library(adjutant) # clusterization
library(plyr)
# grep PMCID and convert to pmid 
gepi_pmv <- gepi_layer1[grep("PMC", gepi_layer1$docid),]
gepi_pmv0 <- gepi_pmv[!duplicated(gepi_pmv$docid),]
pmid_200 <- id_converter(gepi_pmv0$docid[1:200])
pmid_400<- id_converter(gepi_pmv0$docid[201:385])

#summarize pmid
pmid_all <- data.frame(pmid=c(pmid_200$records$pmid, pmid_400$records$pmid), 
                          docid=c(pmid_200$records$pmcid, pmid_400$records$pmcid))
# merge with gepi_pmv  
gepi_pmid <- merge(gepi_pmv, pmid_all, by= "docid")
gepi_pmid$docid <- gepi_pmid$pmid
gepi_pmid$pmid <- NULL

#bind dataframes together
gepi_norm <- gepi_layer1[-grep("PMC", gepi_layer1$docid),]
gepi_together <- rbind(gepi_norm, gepi_pmid)


# split gepi_together to 200 rows dataframe(due to query limitation)
chunk <- 200
n <- nrow(gepi_together)
r  <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
d <- split(gepi_together,r)

# query data from pubmed and parsing it in dataframe

df_gepi <- map(d, function(x){
  abs <- entrez_fetch(db="pubmed", id=x$docid, rettype="medline")
  retr <- miRetrieve::read_pubmed(abs)
  retr
})
saveRDS(df_gepi, "./df_gepi.rds")

# making dataframe from list
df_gepi0 <- do.call("rbind", df_gepi)
df_gepi0 <- df_gepi0[!duplicated(df_gepi0$PMID), ]

#Generating a tidy text 
tidy_gepy <- tidyCorpus(corpus = df_gepi0)

#Performing a dimensionality reduction using t-SNE
tsneObj_gepy<-runTSNE(tidy_gepy,check_duplicates=FALSE)

#add t-SNE co-ordinates to df object
df_gepi0$PMID <- as.character(df_gepi0$PMID)
df_gepi0<-inner_join(df_gepi0,tsneObj_gepy$Y,by="PMID")

# plot the t-SNE results
ggplot(df_gepi0,aes(x=tsneComp1,y=tsneComp2))+
  geom_point(alpha=0.2)+
  theme_bw()

#run HDBSCAN and select the optimal cluster parameters automatically
optClusters <- optimalParam(df_gepi0)

#add the new cluster ID's the running dataset
df_gepi0<-inner_join(df_gepi0,optClusters$retItems,by="PMID") %>%
  mutate(tsneClusterStatus = ifelse(tsneCluster == 0, "not-clustered","clustered"))

# plot the HDBSCAN clusters 
clusterNames <- df_gepi0 %>%
  dplyr::group_by(tsneCluster) %>%
  dplyr::summarise(medX = median(tsneComp1),
                   medY = median(tsneComp2)) %>%
  dplyr::filter(tsneCluster != 0)

ggplot(df_gepi0,aes(x=tsneComp1,y=tsneComp2,group=tsneCluster))+
  geom_point(aes(colour = tsneClusterStatus),alpha=0.2)+
  geom_label(data=clusterNames,aes(x=medX,y=medY,label=tsneCluster),size=2,colour="red")+
  stat_ellipse(aes(alpha=tsneClusterStatus))+
  scale_colour_manual(values=c("black","blue"),name="cluster status")+
  scale_alpha_manual(values=c(1,0),name="cluster status")+ #remove the cluster for noise
  theme_bw()

