Hej Steen

Jeg har siddet og leget med data osv osv
Kan ikke rigtig bruge rådata da de ikke indeholder konventionelle data
Er kommet frem til det her 
#ORDINATION-------------------https://www.rpubs.com/RGrieger/545184
library(ggplot2)
library(readxl)
library(ggsci)
library(ggrepel)
library(ggforce)
library(vegan)
#load and modify dataset
dsf <- read.csv("~/Desktop/Kandidat/Data/table_foundfamily_all_avg_csv.csv", header = T)

#make column into rownames
library(tidyverse)
dsf1 <- dsf %>% remove_rownames %>% column_to_rownames(var="X")

#check for nonnumerical cells
which(is.na(as.numeric(as.character(dsf1[[1]]))))

#remove any NA
dsf1[is.na(dsf1)] = 0

#make mds
dsf2.mds <- metaMDS(df5, distance = "bray", autotransform = FALSE)

#plot
plot(df1.mds)
Men får nu hele tiden den her fejl
Fejl i cmdscale(dist, k = k) : NA values not allowed in ‘d'
Men alle mine felter er tal???
Har prøvet at søge på fejlkode men den sagde bare konverter dine na til “0”