#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

#____________________________________________________________________________#
# R-code provided for the project:
# invertebrate species in Danish freshwater streams

#remove everything in the working environment, without a warning!!
rm(list=ls())
# load libraries for packages
library(readxl)
library(dplyr)
library(ggplot2)
library(grid)

# define working directory
wd00 <- "/home/hal9000/Documents/shrfldubuntu18/invertebrate_eDNA_freshwater_samples"
wdin01 <- "/home/hal9000/Documents/shrfldubuntu18/metabarflow01"
# The 'wdin01' is a separate side directory and not a part of the github directory.
# This is to avoid the input files are stored inside the github directory
# The path above can be changed if it is preferable to have input files somewhere else
#setwd(wd00)
# define input file
inf01 <- "part07_table_plausible_species.csv"
inf02 <- "classified.txt"
inf03 <- "DADA2_nochim.table_repl1and2.txt"
inf04 <- "part07_table_used_in_DSFI.csv"
inf05 <- "Overview_Samples.xlsx"
inf06 <- "Koordinater.xlsx"
# paste together path and input file
pthinf01 <- paste0(wd00,"/",inf01)
pthinf02 <- paste0(wdin01,"/",inf02)
pthinf03 <- paste0(wdin01,"/",inf03)
pthinf04 <- paste0(wd00,"/",inf04)
pthinf05 <- paste0(wd00,"/",inf05)
pthinf06 <- paste0(wd00,"/",inf06)
# read in files
df_p01 <- read.csv(pthinf01, header = T)
df_c01 <- read.table(pthinf02, sep="\t",header = T)
df_noch01 <- read.table(pthinf03, sep="\t",header = T)
df_uiDSFI01 <- read.csv(pthinf04, header = F)
df_poss01 <- readxl::read_xlsx(pthinf05)
tibl_cordDSFI01 <- readxl::read_xlsx(pthinf06)
# change column name of first column
colnames(df_noch01)[1] <- "seqid"
colnames(df_uiDSFI01)[1] <- "genus"
colnames(df_poss01)[1] <- "arbitNo"
#replace in column names
colnames(df_poss01) <- gsub("\\(","",colnames(df_poss01))
colnames(df_poss01) <- gsub("\\)","",colnames(df_poss01))
colnames(df_poss01) <- gsub("\\/","_",colnames(df_poss01))
colnames(df_poss01) <- gsub(" ","_",colnames(df_poss01))
colnames(df_poss01) <- gsub("º","",colnames(df_poss01))
#modify contents of columns
tmID <- gsub("ID","",df_poss01$Sample_number)
smptmID <- tmID[!grepl("NK",tmID)]
NKtmID <- tmID[grepl("NK",tmID)]
#pad with zero
smptmID <-stringr::str_pad(smptmID, 3, pad = "0")
#paste together with 'ID' handle
smptmID <-  paste0("ID",smptmID)
# make a new vector and add back in to data frame
df_poss01$Sample_number <- c(smptmID,NKtmID)
#replace in columns
df_poss01$Location <- gsub(" ","_",df_poss01$Location)
df_poss01$Location <- gsub("Å","AA",df_poss01$Location)
df_poss01$Location <- gsub("Æ","AE",df_poss01$Location)
df_poss01$Location <- gsub("Ø","OE",df_poss01$Location)
df_poss01$Location <- gsub("å","aa",df_poss01$Location)
df_poss01$Location <- gsub("æ","ae",df_poss01$Location)
df_poss01$Location <- gsub("ø","oe",df_poss01$Location)
df_poss01$Location <- gsub(",","",df_poss01$Location)
#replace in columns
tibl_cordDSFI01$Location <- gsub(" ","_",tibl_cordDSFI01$Location)
tibl_cordDSFI01$Location <- gsub("Å","AA",tibl_cordDSFI01$Location)
tibl_cordDSFI01$Location <- gsub("Æ","AE",tibl_cordDSFI01$Location)
tibl_cordDSFI01$Location <- gsub("Ø","OE",tibl_cordDSFI01$Location)
tibl_cordDSFI01$Location <- gsub("å","aa",tibl_cordDSFI01$Location)
tibl_cordDSFI01$Location <- gsub("æ","ae",tibl_cordDSFI01$Location)
tibl_cordDSFI01$Location <- gsub("ø","oe",tibl_cordDSFI01$Location)
tibl_cordDSFI01$Location <- gsub(",","",tibl_cordDSFI01$Location)
# split a column
df_poss01 <- tidyr::separate(df_poss01, Sampletype, sep = ", ", into = paste0(c("filtertp","smpltype"), 1:2), fill = "right")
# make column numeric
df_poss01$Water_volume_filtered_mL <- as.numeric(df_poss01$Water_volume_filtered_mL)
df_poss01$pH <- as.numeric(df_poss01$pH)
df_poss01$Temperature_C <- as.numeric(df_poss01$Temperature_C)
df_poss01$Latitude <- as.numeric(df_poss01$Latitude)
df_poss01$Longitude <- as.numeric(df_poss01$Longitude)
df_poss01$Qubit_tube_concentration_with_2ul_sample_ng_ml <- as.numeric(df_poss01$Qubit_tube_concentration_with_2ul_sample_ng_ml)

##########################################################################################
# begin -  Function to fill NAs with previous value
##########################################################################################
#fill NAs with latest non-NA value
#http://www.cookbook-r.com/Manipulating_data/Filling_in_NAs_with_last_non-NA_value/
#https://stackoverflow.com/questions/7735647/replacing-nas-with-latest-non-na-value
fillNAgaps <- function(x, firstBack=FALSE) {
  ## NA's in a vector or factor are replaced with last non-NA values
  ## If firstBack is TRUE, it will fill in leading NA's with the first
  ## non-NA value. If FALSE, it will not change leading NA's.
  # If it's a factor, store the level labels and convert to integer
  lvls <- NULL
  if (is.factor(x)) {
    lvls <- levels(x)
    x    <- as.integer(x)
  }
  goodIdx <- !is.na(x)
  # These are the non-NA values from x only
  # Add a leading NA or take the first good value, depending on firstBack   
  if (firstBack)   goodVals <- c(x[goodIdx][1], x[goodIdx])
  else             goodVals <- c(NA,            x[goodIdx])
  # Fill the indices of the output vector with the indices pulled from
  # these offsets of goodVals. Add 1 to avoid indexing to zero.
  fillIdx <- cumsum(goodIdx)+1
  x <- goodVals[fillIdx]
  # If it was originally a factor, convert it back
  if (!is.null(lvls)) {
    x <- factor(x, levels=seq_along(lvls), labels=lvls)
  }
  x
}
##########################################################################################
# end -  Function to fill NAs with previous value
##########################################################################################
#use funciton 'fillNAgaps' to replace NAs with values in the row above
df_poss01$arbitNo <- fillNAgaps(df_poss01$arbitNo)
df_poss01$Latitude <- fillNAgaps(df_poss01$Latitude)
df_poss01$Longitude <- fillNAgaps(df_poss01$Longitude)
# get the highest arbitrary number
maxarbno <- max(df_poss01$arbitNo)
# increase this count by one and add it back to the NK samples
df_poss01$arbitNo[grepl("NK", df_poss01$Sample_number)] <- maxarbno+1
#replace the incorrect added longitude and incorrect latitudes
df_poss01$Longitude[grepl("NK", df_poss01$Sample_number)] <- NA
df_poss01$Latitude[grepl("NK", df_poss01$Sample_number)] <- NA
# group by arbitrary number to get unique rows , and count
tibl_02 <- df_poss01%>%group_by(arbitNo,Location,Sample_number,Latitude,Longitude) %>%count()
# match location names between data frames to get DVFI index code appended on to tibble
tibl_02$DVFI <- tibl_cordDSFI01$DVFI[match(tibl_02$Location,tibl_cordDSFI01$Location)]

  
#match back taxonomic species category
df_noch01$species <- df_c01$species[match(df_noch01$seqid,df_c01$qseqid)]
# sum up read counts from different seqid within same species
df_noch02 <- aggregate(df_noch01[,sapply(df_noch01,is.numeric)],df_noch01["species"],sum)
# duplicate the data fram
df_noch05 <- df_noch02
# split a column
df_noch05 <- tidyr::separate(df_noch05, species, sep = " ", into = paste0("spc", 1:4), fill = "right")
# duplicate columns and store under different column name
df_noch05$spcNm <- df_noch05$spc2
df_noch05$genNm <- df_noch05$spc1
# paste columns together
df_noch05$species <- paste0(df_noch05$genNm," ",df_noch05$spcNm)
# ensure the column is a character column
df_noch05$genNm <- as.character(df_noch05$genNm)
df_noch05$species <- as.character(df_noch05$species)
# load the dplyr package
library(dplyr)
#Subsetting rows in nochim table based on data frame with plausible species
df_noch03 <- df_noch02 %>% dplyr::filter(species %in% df_p01$species)
# first subset by plausiable species
df_noch05 <- df_noch05 %>% dplyr::filter(species %in% df_p01$species)
# then subset again by DSFI index genus names
df_noch05.uiDSFI <- df_noch05 %>% dplyr::filter(genNm %in% df_uiDSFI01$genus)
# and subset to include those not in the list of plausible species
df_nonoch03 <- df_noch02 %>% dplyr::filter(!species %in% df_p01$species)
# grep column names that start with NK or ID
NKcols <- colnames(df_noch05.uiDSFI)[grepl("^NK",colnames(df_noch05.uiDSFI))]
IDcols <- colnames(df_noch05.uiDSFI)[grepl("^ID",colnames(df_noch05.uiDSFI))]
# make a vector with column names
nke <- c("genNm",IDcols,NKcols)
# use this vector to exlude column names not in the vector
df_noch05.uiDSFI <- df_noch05.uiDSFI[nke]
# sum up read counts from different seqid within same genNm
df_noch05.uiDSFI <- aggregate(df_noch05.uiDSFI[,sapply(df_noch05.uiDSFI,is.numeric)],df_noch05.uiDSFI["genNm"],sum)

# count the number of rows in the dataframes
nrow(df_noch03)
nrow(df_nonoch03)
# reshape data frame from wide to long
df_noch04 <- reshape2::melt(df_noch03,id.vars = c("species"),value.name = "seqrd.cnt")
df_nonoch04 <- reshape2::melt(df_nonoch03,id.vars = c("species"),value.name = "seqrd.cnt")
#change column names
colnames(df_noch04) <- c("species","smplNo","seqrd.cnt")
colnames(df_nonoch04) <- c("species","smplNo","seqrd.cnt")
#split sampleNo ID to get a column with repl no
# use mutate and gsub to split string by delimter
# https://stackoverflow.com/questions/44981338/r-split-string-by-delimiter-in-a-column  
library(dplyr)
# split to get ID of sample number
df_noch04  <- df_noch04 %>% dplyr::mutate(smplID=gsub("_.*","",smplNo))
df_nonoch04  <- df_nonoch04 %>% dplyr::mutate(smplID=gsub("_.*","",smplNo))
# and split to get replicate number from sample number
df_noch04  <- df_noch04 %>% dplyr::mutate(replNo=gsub(".*_","",smplNo))
df_nonoch04  <- df_nonoch04 %>% dplyr::mutate(replNo=gsub(".*_","",smplNo))
#match back taxonomic categories
df_noch04$kingdom <- df_c01$kingdom[match(df_noch04$species,df_c01$species)]
df_noch04$phylum <- df_c01$phylum[match(df_noch04$species,df_c01$species)]
df_noch04$class <- df_c01$class[match(df_noch04$species,df_c01$species)]
df_noch04$order <- df_c01$order[match(df_noch04$species,df_c01$species)]
df_noch04$family <- df_c01$family[match(df_noch04$species,df_c01$species)]
df_noch04$genus <- df_c01$genus[match(df_noch04$species,df_c01$species)]
#match back taxonomic categories
df_nonoch04$kingdom <- df_c01$kingdom[match(df_nonoch04$species,df_c01$species)]
df_nonoch04$phylum <- df_c01$phylum[match(df_nonoch04$species,df_c01$species)]
df_nonoch04$class <- df_c01$class[match(df_nonoch04$species,df_c01$species)]
df_nonoch04$order <- df_c01$order[match(df_nonoch04$species,df_c01$species)]
df_nonoch04$family <- df_c01$family[match(df_nonoch04$species,df_c01$species)]
df_nonoch04$genus <- df_c01$genus[match(df_nonoch04$species,df_c01$species)]
# see number of taxonomical categories per taxonomical level 
# among the plausible species
length(unique(df_noch04$phylum))
length(unique(df_noch04$class))
length(unique(df_noch04$order))
length(unique(df_noch04$family))
# see number of taxonomical categories per taxonomical level 
# among the non-plausible species
length(unique(df_nonoch04$phylum))
length(unique(df_nonoch04$class))
length(unique(df_nonoch04$order))
length(unique(df_nonoch04$family))
# paste taxonomic categoreis together
df_noch04$pcofg <- paste(df_noch04$phylum,
                         df_noch04$class,
                         df_noch04$order,
                         df_noch04$family,
                         df_noch04$genus,
                         sep="_")
# use the dplyr package to count up read counts per Sample site
tibl_04 <- df_noch04 %>%
  dplyr::group_by(smplNo) %>%
  dplyr::summarise(Freq = sum(seqrd.cnt ))
# use the dplyr package to count up read counts per Sample site
# but this time for the non-plausible species
tibl_nonoch04 <- df_nonoch04 %>%
  dplyr::group_by(smplNo) %>%
  dplyr::summarise(Freq = sum(seqrd.cnt ))
# make viridis colour range
vclr <- pals::viridis(length(unique(df_noch04$pcofg)))

#add back the total count of reads for sample site
# calculated in the tibble - for the plausible species
df_noch04$totrcnt <- tibl_04$Freq[match(df_noch04$smplNo,tibl_04$smplNo)]
# and do it for  the non- plausible species
df_nonoch04$totrcnt <- tibl_nonoch04$Freq[match(df_nonoch04$smplNo,tibl_nonoch04$smplNo)]
#arrrange tibble
tibl06 <- df_noch04 %>% group_by(species, smplNo) 
#add a line break to species names
tibl06 <- tibl06 %>%
  group_by(smplNo) %>%
  mutate(pct=100*totrcnt/sum(totrcnt,na.rm=T)) %>%
  ungroup() %>%
  mutate(gnsp2=ifelse(pct>3,
                      stringr::str_replace(species," ","\n"),
                      ""))
#match sample ID between tibbles to get DVFI index appended on to tibble
tibl06$DVFI <- tibl_02$DVFI[match(tibl06$smplID,tibl_02$Sample_number)]
tibl06$Location <- tibl_cordDSFI01$Location[match(tibl06$smplID,tibl_02$Sample_number)]
# match location names between data frames to get longitude and latitude
tibl06$dec.lon <- tibl_cordDSFI01$long[match(tibl06$Location,tibl_cordDSFI01$Location)]
tibl06$dec.lat <- tibl_cordDSFI01$lat[match(tibl06$Location,tibl_cordDSFI01$Location)]
