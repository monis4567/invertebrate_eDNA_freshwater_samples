
#ORDINATION-------------------
library(vegan)
library(ggplot2)
f01 <- "table_foundfamily_all_avg_csv.csv"
wd00 <- "/home/hal9000/Documents/shrfldubuntu18/invertebrate_eDNA_freshwater_samples"
pthf01 <- paste0(wd00,"/",f01)
#load and modify dataset
df <- read.csv(pthf01, header = T)
df$X <- NULL
#change column name fra NA to Y
df[is.na(df)] <- 'Y'
#make columnnames from first row
library(janitor)
df1 <- df %>%
  row_to_names(row_number = 1)
#check for nonnumerical cells
which(is.na(as.numeric(as.character(df1[[1]]))))
# convert an entire data.frame to numeric
#https://stackoverflow.com/questions/52909775/how-to-convert-an-entire-data-frame-to-numeric
df1[] <- lapply(df1, as.numeric)

df1$Acroloxidae
# replacing NA values in data frame
df1[is.na(df1)] = 0

mtc.mds <- metaMDS(mtcars, distance = "bray", autotransform = FALSE)
#make mds
#https://tousu.in/qa/?qa=381309/
ddf1<- dist(df1)
distconnected(ddf1)
df1.mds <- metaMDS(df1, distance = "bray", autotransform = FALSE, noshare = T)
plot(df1.mds)
plot(mtc.mds)
#Men får hele tiden en fejlkode om at der er ikke numeriske værdier i min dataframe
