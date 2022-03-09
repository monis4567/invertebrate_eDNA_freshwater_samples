#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

#____________________________________________________________________________#
# R-code provided for the project:
# GBS Population genetics on thorny skates
library(readxl)
# define working directory
wd00 <- "/home/hal9000/Documents/shrfldubuntu18/invertebrate_novogene_2022mar"

# define input file
inf01 <- "tagged_primers_BF1_BR1_for_eDNA_metabarcod_invertebr_2021oct26.xlsx"
# paste together path and input flie
pthinf01 <- paste0(wd00,"/",inf01)
# read in excel file as tibble, skip 2 rows
tibl_inx01 <- readxl::read_xlsx(pthinf01, skip=2)
#substitute spaces underscores
colnames(tibl_inx01) <- gsub(" ","_",colnames(tibl_inx01) )



#https://catchenlab.life.illinois.edu/stacks/manual/#prun
outfl1 = "part01A_tag01_96_BF1BR1.txt"
# paste together path and input flie
pthoutf01 <- paste0(wd00,"/",outfl1)

# use tab as separator
write.table(tibl_inx01, file=pthoutf01, sep="\t",
            row.names = F, # do not use row names
            col.names = F, # do not use columns names
            quote = F) # do not use quotes

#tail(tibl_inx01)




#