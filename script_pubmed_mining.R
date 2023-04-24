library(rentrez) #query
library(data.table)
library(RISmed)
library(easyPubMed)
library(GEOmetadb)


###RENTREZ###
#get the data about genes of interest
df<-entrez_search(db="pubmed",term="lung adenocarcinoma AND RNAseq",retmax=12000)
df0 <- data.frame(df$ids)


# split id list to 200 rows (due to query limitation)
chunk <- 200
n_df <- nrow(df0)
r_df <- rep(1:ceiling(n_df/chunk),each=chunk)[1:n_df]
d_df <- split(df0,r_df)

# query data from pubmed and parsing it in dataframe

df_nsl <- map(d_df, function(x){
  abs <- entrez_fetch(db="pubmed", id=x$df.ids, rettype="medline")
  retr <- miRetrieve::read_pubmed(abs)
  retr
})
saveRDS(df_nsl, "./df_nsl.rds")

# making dataframe from list
df_nsl0 <- do.call("rbind", df_nsl)
df_nsl0 <- as.data.frame(df_nsl0)
fwrite(df_nsl0, "./datasets/df_load.csv")

#exclude review articles
df_nsl0 <- df_nsl0[- grep("eview", df_nsl0$Title),]



