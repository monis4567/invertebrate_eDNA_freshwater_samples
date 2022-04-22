#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

#____________________________________________________________________________#
# R-code provided for the project:
# GBS Population genetics on thorny skates
library(readxl)
# define working directory
wd00 <- "/home/hal9000/Documents/shrfldubuntu18/invertebrate_eDNA_freshwater_samples"

# define input file
inf01 <- "Faunaliste_plausiblearter_færdig.xlsx"
# paste together path and input flie
pthinf01 <- paste0(wd00,"/",inf01)
# read in excel file as tibble, skip 2 rows
tibl_inx01 <- readxl::read_xlsx(pthinf01)
#head(tibl_inx01,3)
#substitute spaces underscores
# define columns to keep
ke <- c("Art")
# subset to only include specified columns
tibl_i02 <- tibl_inx01[ke]
#make it a data frame
df_plsp01 <- as.data.frame(tibl_i02)
#substitute in names
df_plsp01[,1] <- gsub(" sp\\.","",df_plsp01[,1])
df_plsp01[,1] <- gsub(" sp$","",df_plsp01[,1])
df_plsp01[,1] <- gsub(" gr\\.","",df_plsp01[,1])
df_plsp01[,1] <- gsub(" indet\\.","",df_plsp01[,1])
df_plsp01[,1] <- gsub(" A$","",df_plsp01[,1])
df_plsp01[,1] <- gsub("\\(.*\\)","",df_plsp01[,1])
# only retain unique values
df_plsp01[,1] <- unique(df_plsp01[,1])
  #https://catchenlab.life.illinois.edu/stacks/manual/#prun
outfl1 = "part07_list_of_plausible_species.txt"
# paste together path and input flie
pthoutf01 <- paste0(wd00,"/",outfl1)
# use tab as separator
write.table(df_plsp01, file=pthoutf01, sep="\t",
            row.names = F, # do not use row names
            col.names = F, # do not use columns names
            quote = F) # do not use quotes
# #write the tags files
# write.table(tibl_tags01, file=pthoutf01, sep="\t",
#             row.names = F, # do not use row names
#             col.names = F, # do not use columns names
#             quote = F) # do not use quotes
# 
#tail(tibl_inx01)

# Obtain a list of blast hits from the metabarflow:
# use this unix command to get unique species : 
# cat classified.txt | cut -f14 | sort | uniq -d > list_of_blast_result_species.txt
# then scp this locally and use for the next part

# define input file
inf02 <- "list_of_blast_result_species.txt"
# paste together path and input flie
pthinf02 <- paste0(wd00,"/",inf02)
# read in table file as tibble, fill empty
df_pl02 <- read.table(pthinf02,sep=" ", fill = T)
#change column names
colnames(df_pl02) <- c("genus", "species")
#head(df_pl02,30)
df_pl02$gen_spc <- paste(df_pl02$genus,df_pl02$species, sep=" ")
#match to get list of plausiebl species present in blast list
lst_psspr <- df_pl02$gen_spc[match(unique(df_plsp01[,1]), df_pl02$gen_spc)]
# limit to complete cases -  i.e. exclude NAs
lst_psspr <- lst_psspr[complete.cases(lst_psspr)]

df_plsp02 <- as.data.frame(lst_psspr)
df_plsp02$note <- NA
df_plsp02$Oceanic_region <- NA
df_plsp02$commentary<- NA
colnames(df_plsp02) <- c("species_after_filtration","note","Oceanic_region","commentary")

outfl2 = "part07_list_of_blasthits_evaluations.txt"
# paste together path and input flie
pthoutf02 <- paste0(wd00,"/",outfl2)
# use tab as separator
write.table(df_plsp02, file=pthoutf02, sep=",",
            row.names = F, # do not use row names
            col.names = T, # do not use columns names
            quote = F) # do not use quotes

# Modify uppercase taxonomical categories
# start by making the tibble data frame
df_pl03 <- as.data.frame(tibl_inx01)
# change column names
colnames(df_pl03) <- c("group","family","genus", "species")
# substitute comma  with nothing
df_pl03$group <- gsub(",","",df_pl03$group)
df_pl03$family <- gsub(",","",df_pl03$family)
df_pl03$genus <- gsub(",","",df_pl03$genus)
# split strings by space as delimiter
#https://stackoverflow.com/questions/36353707/warning-number-of-columns-of-result-is-not-a-multiple-of-vector-length-arg-1
library(tidyr)
df_pl03 <- tidyr::separate(df_pl03, group, sep = " ", into = paste0("grp", 1:3), fill = "right")
df_pl03 <- tidyr::separate(df_pl03, family, sep = " ", into = paste0("fam", 1:4), fill = "right")
df_pl03 <- tidyr::separate(df_pl03, genus, sep = " ", into = paste0("gen", 1:4), fill = "right")
# use 'sub' to keep first character in string, use 'tolower' to get lowercase characters
# https://stackoverflow.com/questions/28866317/replace-first-element-of-a-string-in-r-based-on-a-condition
df_pl03$group <- paste0(sub("(^.)(.*)", "\\1", df_pl03$grp1),tolower(sub("^.(.*)", "\\1", df_pl03$grp1)))
df_pl03$family <- paste0(sub("(^.)(.*)", "\\1", df_pl03$fam1),tolower(sub("^.(.*)", "\\1", df_pl03$fam1)))
df_pl03$genus <- paste0(sub("(^.)(.*)", "\\1", df_pl03$gen1),tolower(sub("^.(.*)", "\\1", df_pl03$gen1)))
#substitute in names
df_pl03$species <- gsub(" sp\\.","",df_pl03$species)
df_pl03$species <- gsub(" sp$","",df_pl03$species)
df_pl03$species <- gsub(" gr\\.","",df_pl03$species)
df_pl03$species <- gsub(" indet\\.","",df_pl03$species)
df_pl03$species <- gsub(" A$","",df_pl03$species)
df_pl03$species <- gsub("\\(.*\\)","",df_pl03$species)
# make vector of  column names
ke <- c("group","family","genus", "species")
# keep only selected columns
df_pl03 <- df_pl03[ke]
# define an output filename
outfl3 = "part07_table_plausible_species.csv"
# paste together path and input flie
pthoutf03 <- paste0(wd00,"/",outfl3)
# use tab as separator
write.table(df_pl03, file=pthoutf03, sep=",",
            row.names = F, # do not use row names
            col.names = T, # do not use columns names
            quote = F) # do not use quotes



#