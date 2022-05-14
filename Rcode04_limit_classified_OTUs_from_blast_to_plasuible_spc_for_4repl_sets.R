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
inf03 <- "DADA2_nochim.table_repl1_4.txt"
inf04 <- "part07_table_used_in_DSFI.csv"
inf05 <- "DSFI_allmethods.xlsx"
inf06 <- "DVFI_TEST.xlsx"
inf07 <- "Overview_Samples.xlsx"
inf08 <- "Koordinater.xlsx"

# paste together path and input file
pthinf01 <- paste0(wd00,"/",inf01)
pthinf02 <- paste0(wdin01,"/",inf02)
pthinf03 <- paste0(wdin01,"/",inf03)
pthinf04 <- paste0(wd00,"/",inf04)
pthinf05 <- paste0(wd00,"/",inf05)
pthinf06 <- paste0(wd00,"/",inf06)
pthinf07 <- paste0(wd00,"/",inf07)
pthinf08 <- paste0(wd00,"/",inf08)
# read in files
df_p01 <- read.csv(pthinf01, header = T)
df_c01 <- read.table(pthinf02, sep="\t",header = T)
df_noch01 <- read.table(pthinf03, sep="\t",header = T)
df_uiDSFI01 <- read.csv(pthinf04, header = F)
df_DS01 <- readxl::read_xlsx(pthinf05)
df_SS01 <- readxl::read_xlsx(pthinf06)

df_poss01 <- readxl::read_xlsx(pthinf07)
tibl_cordDSFI01 <- readxl::read_xlsx(pthinf08)

# change column name of first column
colnames(df_noch01)[1] <- "seqid"
colnames(df_uiDSFI01)[1] <- "genus"
colnames(df_poss01)[1] <- "arbitNo"
# check if any column names include the number '42'
# the match later on with sampling locations and the attempt to make a 
# linear discriminant analysis using the 'BiodiversityR' package needs
# the sample location numbers in the two data frames that contains the number 
# sequence reads, and the data frame the contains the sampling information to
# match in number of rows. The data frame with sampling locations includes a 
# sample "ID042_2" , but this sample is absent from the original 'df_noch01'
# data frame
# I used this line here below to check this
colnames(df_noch01)[grepl("42",colnames(df_noch01))]
colnames(df_noch01)[grepl("NK",colnames(df_noch01))]
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
df_DS01$Location <- gsub(" ","_",df_DS01$Location)
df_DS01$Location <- gsub("Å","AA",df_DS01$Location)
df_DS01$Location <- gsub("Æ","AE",df_DS01$Location)
df_DS01$Location <- gsub("Ø","OE",df_DS01$Location)
df_DS01$Location <- gsub("å","aa",df_DS01$Location)
df_DS01$Location <- gsub("æ","ae",df_DS01$Location)
df_DS01$Location <- gsub("ø","oe",df_DS01$Location)
df_DS01$Location <- gsub(",","",df_DS01$Location)
# replace in location names - to make data frames match -  this will be important
# for the 'vegan::rda' function later on
df_DS01$Location <- gsub("Hestetangsaa","Hestetangs_AA",df_DS01$Location)
df_DS01$Location <- gsub("Hjelmsoelille_Susaa","Hjelmsoelille" ,df_DS01$Location)
df_DS01$Location <- gsub("Buske_Susaa","Buske" ,df_DS01$Location)
df_DS01$Location <- gsub("Lindes_AA","Lindesaa" ,df_DS01$Location)
# replace in location names - to make data frames match -  this will be important
# for the 'vegan::rda' function later on
df_DS01$Location <- gsub("_ned","_Ned" ,df_DS01$Location)
df_DS01$Location <- gsub("_op","_Op" ,df_DS01$Location)
df_DS01$Location <- gsub("_midt","_Midt" ,df_DS01$Location)
# get unique location names -  in order
uDS01 <- unique(df_DS01$Location)[order(unique(df_DS01$Location))]
udps01 <- unique(df_poss01$Location)[order(unique(df_poss01$Location))]
# compatre the unique location names in the two data frames -  there should
# not be any differences, otherwise the merge step later on will not work 
# as intended. The 'merge' function later on is dependent on exact matches
# betweenm location names
setdiff(uDS01,udps01)
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
#make the tibble a data frame
tb2 <- as.data.frame(tibl_02)
# merge data frames - Not you must specify all.x=TRUE  and all.y=TRUE
# to make the merge function include all cases of the 'Location' - even
# cases that are blank -  also see : https://www.programmingr.com/tutorial/left-join-in-r/

df_DS02<-merge(x=tb2,y=df_DS01,by="Location",all.x=TRUE,all.y=TRUE)

#unique(df_DS02$Location)[order(unique(df_DS02$Location))]
# change column name of first column
colnames(df_noch01)[1] <- "seqid"
colnames(df_uiDSFI01)[1] <- "genus"
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
colnames(df_noch03)
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
#______________________________________________________________________________

stbp07 <- ggplot(tibl06,aes(replNo,seqrd.cnt  ,fill = phylum))+
  geom_bar(position = "fill",stat="identity", width = 0.9, 
           
           #the 'color="#000000",size=0.1' adds a thin line between 
           # individual parts of the bar in the stacked bar
           color="#000000",size=0.1)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  # add label above each bar to denote total number of reads
  # geom_text(data=tibl06, aes(x = smplNo, y = 0.98,
  #             label = totrcnt), 
  #           hjust="right",
  #           vjust=0.5, angle = 90) +
  
  xlab("sample ID above, replicate number on bottom")+
  ylab("percentage of reads from plausible species")+
  #scale_fill_manual(values = vclr)+
  scale_y_continuous(labels = function(x) paste0(x*100, "%")) +
  ggtitle("A - replicate 1 - 4 ")+
  guides(fill= guide_legend(ncol=1)) +
  theme(legend.position = "right",
        axis.text.x = element_text(angle=90, vjust = 0.5),
        legend.text = element_text(size = 10),
        #use this line below instead if you need italic font
        #legend.text = element_text(size = 10,face="italic"),
        legend.title = element_text(size = 20),
        legend.key.size = unit(0.57,"cm"),
        legend.justification = "bottom",       
        axis.text.y = element_text(size = 20),
        strip.text.x = element_text(size = 10,face="bold"),
        title = element_text(size = 12))+
  facet_grid(.~smplID, scales="free", space = "free") +
  coord_cartesian(expand=F) +
  # change spacing between facet plots
  # see: https://stackoverflow.com/questions/3681647/ggplot-how-to-increase-spacing-between-faceted-plots
  theme(panel.spacing = unit(0.02, "lines"))
# see the plot
#stbp07
#plot_annotation(caption=inpf01) #& theme(legend.position = "bottom")
#p
#make filename to save plot to
figname08 <- paste0("Fig07B_stckbarplot_plausibl_spc_repl1and2_01.png")
figname08 <- paste0("Fig07B_stckbarplot_plausibl_spc_repl1_4_01.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname08 <- paste(wd00,"/",figname08,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(stbp07,file=figname08,
         #width=210,height=297,
         width=3*297,height=210,
         units="mm",dpi=300)
}

#_______________________________________________________________________________
# add a column for presence absence category
tibl06$prab <- 0
# if there is a read count, then assign it the value 1
# in order to record presence / absence
tibl06$prab[tibl06$seqrd.cnt>0] <- 1
#get unique orders
uord <- unique(tibl06$order)
# count unique orders
nuord <- length(uord)
# define a color palette
cbbPalette2 <- c("black","purple","blue","green","yellowgreen",
                 "yellow","white")
# make a color ramp function across the palette 
colfunc <- colorRampPalette(cbbPalette2)
#https://stackoverflow.com/questions/13353213/gradient-of-n-colors-ranging-from-color-1-and-color-2
# use the  color ramp function acorss the steps  -  one step per order
cl <- colfunc(nuord)
#make plot
stbp08 <- ggplot(tibl06,aes(replNo,prab  ,fill = order))+
  geom_bar(position = "fill",stat="identity", width = 0.9, 
           
           #the 'color="#000000",size=0.1' adds a thin line between 
           # individual parts of the bar in the stacked bar
           color="#000000",size=0.1)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  # add label above each bar to denote total number of reads
  # geom_text(data=tibl06, aes(x = smplNo, y = 0.98,
  #             label = totrcnt), 
  #           hjust="right",
  #           vjust=0.5, angle = 90) +
  
  xlab("sample ID is red, replicate number is blue")+
  ylab("presence of plausible species")+
  scale_fill_manual(values = cl)+
  scale_y_continuous(labels = function(x) paste0(x*100, "%")) +
  ggtitle("A - replicate 1 - 4. Presence/absence eval. All reads have been set to 1")+
  guides(fill= guide_legend(ncol=1)) +
  theme(legend.position = "right",
        # set angle and size of labels for tick marks on x axis
        axis.text.x = element_text(size= 12, angle=90, vjust = 0.5),
        legend.text = element_text(size = 10),
        #use this line below instead if you need italic font
        #legend.text = element_text(size = 10,face="italic"),
        legend.title = element_text(size = 20, angle=0),
        legend.key.size = unit(0.57,"cm"),
        legend.justification = "bottom",    
        # set text size on tick labels on y axis
        axis.text.y = element_text(size = 4, color = "blue"),
        #strip.text.x = element_text(size = 10,face="bold", color="blue", angle=90),
        # rotate lables in facet wrap title
        #https://stackoverflow.com/questions/40484090/rotate-switched-facet-labels-in-ggplot2-facet-grid
        strip.text.y = element_text(size = 8,face="bold", color="red", angle=360),
        title = element_text(size = 12))+
  
  #facet_grid(.~smplID, scales="free", space = "free") +
  # reverse the order of the variable and the '~.' as the 'coord_flip()' 
  # will turn the plot around
  facet_grid(smplID~., scales="free", space = "free") +
  #coord_cartesian(expand=F) +
  # change spacing between facet plots
  # see: https://stackoverflow.com/questions/3681647/ggplot-how-to-increase-spacing-between-faceted-plots
  theme(panel.spacing = unit(0.02, "lines")) +
  # turn axis of plot around
  coord_flip() 
# see the plot
#stbp08
# see this website:
#https://stackoverflow.com/questions/33322061/change-background-color-panel-based-on-year-in-ggplot-r
# for help on how to use geom_rect for separating the backgrounds. 

#plot_annotation(caption=inpf01) #& theme(legend.position = "bottom")
#p
#make filename to save plot to
figname08 <- paste0("Fig07C_stckbarplot_plausibl_spc_repl1_4_pr_ab_01.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname08 <- paste(wd00,"/",figname08,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(stbp08,file=figname08,
                  width=210,height=297,
                  #width=297,height=210,
                  #width=3*297,height=210,
                  units="mm",dpi=300)
}

#_______________________________________________________________________________
# Get unique sample IDs
usID <- unique(tibl06$smplID)
# count the  unique sample IDs
nusID <- length(usID)
# repeat a colur as the count of the  unique sample IDs
# this colur will be usde for the facet wrap headers
clsID <- rep("white",nusID)
# bind by columns the ID number and the color
df_clsID01 <- as.data.frame(cbind(usID, clsID))
# Edit the color for a couple of specific columns
# this can be used for 'DVFI' index categories
# e.g. use :
# For DVFI 1 - a dark color like: "gray58"
# For DVFI 2 - a blue color like: "royalblue2"
# For DVFI 3 - a purple color like: "darkorchid2"
# For DVFI 4 - a red color like: "firebrick12"
# For DVFI 5 - a orange color like: "orange2"
# For DVFI 6 - a yellow color like: "yellow2"
# For DVFI 7 - a white color like: "white" - this is the default color you have
# assigned to all 'clsID' in above
# now assign such colors to some selected ID-categories, as defined by column
# this can be edited to be based on another data frame


df_clsID01$clsID[c(2,8)] <- "gray58"
df_clsID01$clsID[c(3,9)] <- "royalblue2"
df_clsID01$clsID[c(5,12)] <- "darkorchid2"
df_clsID01$clsID[c(8,19)] <- "firebrick1"
df_clsID01$clsID[c(13,23)] <- "orange1"
df_clsID01$clsID[c(15,24:26)] <- "yellow1"


# also make it a data frame of color categories for 
df_DVFIclc <- as.data.frame(rbind(c(0,"black"),
c(1,"gray58"),
c(2,"royalblue2"),
c(3,"darkorchid2"),
c(4,"firebrick1"),
c(5,"orange1"),
c(6, "yellow1"),
c(7, "white")))
#change the column names
colnames(df_DVFIclc) <- c("DVFIcatNo","DVFIcatCol")

clsID01_Dcat <- df_DS02$DVFI[match(df_clsID01$usID,df_DS02$Sample_number)]
clsID01_Dcat[is.na(clsID01_Dcat)] <- 0

df_clsID01$clsID <- df_DVFIclc$DVFIcatCol[match(clsID01_Dcat,df_DVFIclc$DVFIcatNo)]
# sort the data frame by sample name to make it match the order of thw facet wraps
df_clsID01 <- df_clsID01[order(df_clsID01$usID),]
# assign the column in the data frame to a vector
clrID <- df_clsID01$clsID
# and give it a new name as a vector
fills <- c(clrID)
# duplicate the plot prepared
p1 <- stbp08
# try changing the text colur you assigned as red for the facet wrap headers, 
# to black instead of being red
p1 <- p1 + theme(strip.text.y = element_text(size = 8,face="bold", color="black", angle=360))
# Now see this webiste for preparing different colors in the facet wrap headers 
# https://stackoverflow.com/questions/41631806/change-facet-label-text-and-background-colour/60046113#60046113
g1 <- ggplot_gtable(ggplot_build(p1))
stripr1 <- which(grepl('strip-r', g1$layout$name))
# assign a count number 1 to begin with
k <- 1
#iterate over elements in 'stripr1' 
for (i in stripr1) {
  j <- which(grepl('rect', g1$grobs[[i]]$grobs[[1]]$childrenOrder))
  g1$grobs[[i]]$grobs[[1]]$children[[j]]$gp$fill <- fills[k]
  k <- k+1
}

#make filename to save plot to
fgn09pd <- paste0("Fig07D_stckbarplot_plausibl_spc_repl1and2_pr_ab_02.pdf")
fgn09pn <- paste0("Fig07D_stckbarplot_plausibl_spc_repl1and2_pr_ab_02.png")

fgn09pd <- paste0("Fig07D_stckbarplot_plausibl_spc_repl1_4_pr_ab_02.pdf")
fgn09pn <- paste0("Fig07D_stckbarplot_plausibl_spc_repl1_4_pr_ab_02.png")

#paste together path and file name
fgn09pn <- paste(wd00,"/",fgn09pn,sep="")
grf09 <- grid::grid.draw(g1)
#save plot
png(fgn09pn, 
    #width=(20*2.9232),
    #height=(20*8.2677),
    res=300 )
grid::grid.draw(g1)
dev.off()
# save as pdf file
pdf(fgn09pd, 
    #width and heigth is in inches. An A4 page is 2.9232 in * 8.2677 in
    width=(4*2.9232),
    height=(8.2677) )
grid::grid.draw(g1)
dev.off()

#_______________________________________________________________________________
# Try making box plots with diversity
#_______________________________________________________________________________

# use dplyr to count per group 
# see this example for help:
# https://dplyr.tidyverse.org/reference/count.html
tibl07 <-tibl06 %>% dplyr::group_by(smplID,replNo) %>% dplyr::tally(seqrd.cnt>0)
##https://stackoverflow.com/questions/31955772/ggplot2-reversing-the-order-of-discrete-categories-on-y-axis-in-scatterplot
# change column names
colnames(tibl07) <- c("smplID","replNo","no_of_spc" )
#make a plot with number of species
bpl01 <- ggplot(tibl07, aes(no_of_spc,smplID)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  geom_point(alpha=0.7) +
  coord_flip()#
# see the plot
#bpl01

# make a column for DVFI categories, and assign zero as default value
tibl06$DVFIcat <- 0 # black
df_DS02$Sample_number
#edit the zero DVFI category column based on IDsample number
tibl06$DVFIcat[tibl06$smplID %in% c("ID012", "ID014")] <- 1 # gray
tibl06$DVFIcat[tibl06$smplID %in% c("ID031", "ID032")] <- 2 # blue
tibl06$DVFIcat[tibl06$smplID %in% c("ID066", "ID021")] <- 3 # purple
tibl06$DVFIcat[tibl06$smplID %in% c("ID006", "ID007")] <- 4 # red
tibl06$DVFIcat[tibl06$smplID %in% c("ID008", "ID009")] <- 5 # orange
tibl06$DVFIcat[tibl06$smplID %in% c("ID038", "ID040")] <- 6 # yellow
tibl06$DVFIcat[tibl06$smplID %in% c("ID047", "ID048")] <- 7 # white

tibl06$DVFIcat <- df_DS02$DVFI[match(tibl06$smplID,df_DS02$Sample_number)]
tibl06$DSFI_CONVcat <- df_DS02$DSFI_CONV[match(tibl06$smplID,df_DS02$Sample_number)]
tibl06$DSFI_ew_cat <- df_DS02$DSFI_eDNA_water[match(tibl06$smplID,df_DS02$Sample_number)]
tibl06$DSFI_eb_cat <- df_DS02$DSFI_eDNA_bucket[match(tibl06$smplID,df_DS02$Sample_number)]
# replace NAs with zeroes
tibl06$DVFIcat[is.na(tibl06$DVFIcat)] <- 0
tibl06$DSFI_CONVcat[is.na(tibl06$DSFI_CONVcat)] <- 0
tibl06$DSFI_ew_cat[is.na(tibl06$DSFI_ew_cat)] <- 0
tibl06$DSFI_eb_cat[is.na(tibl06$DSFI_eb_cat)] <- 0
# match back DVFI category
tibl07$DVFIcat <- tibl06$DVFIcat[match(tibl07$smplID,tibl06$smplID)]
# match color category to main tibble
tibl07$DVFIcatCol <- df_DVFIclc$DVFIcatCol[match(tibl07$DVFIcat,df_DVFIclc$DVFIcatNo)]
# get unique sample IDs
usID <- unique(tibl07$smplID)
# count the unique sample IDs
nsID <-  length(usID)
# make a sequence series for sample IDs
sesID <- seq(1,nsID)
# make a data frame with lower and upper boundaries per sample ID category
df_bd <- as.data.frame(cbind(usID, sesID-0.5, sesID+0.5))
# change the column names
colnames(df_bd) <- c("smplID","bd_l","bd_u")
# Match back to the tibble
tibl07$bd_l <- df_bd$bd_l[match(tibl07$smplID,df_bd$smplID)]
tibl07$bd_u <- df_bd$bd_u[match(tibl07$smplID,df_bd$smplID)]
#make the new columns factors
tibl07$bd_l <- as.numeric(tibl07$bd_l)
tibl07$bd_u <- as.numeric(tibl07$bd_u)
# the boundaries for each sampleID is needed to make category colors on the plot
# as seen here:
# https://stackoverflow.com/questions/53416809/r-ggplot-background-color-boxplot
# make the category number  a character
tibl07$DVFIcat2 <-  as.character(tibl07$DVFIcat)
# make a box plot with category colors for each ID sample number, 
# where boundaries of categories
# are defined by the upper and lower limits calculated per category above
#Box plot with colored vertical backgrounds to make boxplots on species 
#inspired by figure 2 presented by Kuntke et al. (2020): 
# Kuntke, F., de Jonge, N., Hesselsøe, M., Nielsen, J.L., 2020. Stream water quality assessment by metabarcoding of invertebrates. Ecological Indicators 111, 105982. https://doi.org/10.1016/j.ecolind.2019.105982
bpl02 <- ggplot(tibl07, aes(y=no_of_spc, x=smplID)) + 
  geom_boxplot(aes(col=no_of_spc)) +
  geom_rect(aes(xmin = bd_l,
                xmax = bd_u,
                ymin = -Inf, ymax = Inf,
                fill = DVFIcat2), alpha = 0.3) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  ggplot2::ggtitle("B - inspired by fig2 in Kuntke et al. (2020)" ) +
  geom_point(alpha=0.7) 
# get unique color categories for DVFI categories , and assign to vector
cl2 <- unique(df_DVFIclc$DVFIcatCol)
# adjust the fill color of the geom_rect using the 'cl2' categories
bpl02  <- bpl02 + scale_fill_manual(values=c(cl2))
#make filename to save plot to
figname10 <- paste0("Fig07E_boxplot_plausibl_spc_repl1_4_pr_ab_01.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname10 <- paste(wd00,"/",figname10,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(bpl02,file=figname10,
                  #width=210,height=297,
                  width=297,height=210,
                  #width=3*297,height=210,
                  units="mm",dpi=300)
}

#_______________________________________________________________________________
# Make boxplot with only DSFI index genera within subset list of 
# plausible species
#_______________________________________________________________________________
# reshape data frame with only plausible DVFI index genera
df_nuD06 <- reshape2::melt(df_noch05.uiDSFI,id.vars = c("genNm"),value.name = "seqrd.cnt")
# assign new column names
colnames(df_nuD06) <- c("genus","smplIDNo","seqrd.cnt")
# and split to get replicate number from sample number
df_nuD06  <- df_nuD06 %>% dplyr::mutate(replNo=gsub(".*_","",smplIDNo))
df_nuD06  <- df_nuD06 %>% dplyr::mutate(smplID=gsub("_.*","",smplIDNo))
# use dplyr to count per group # see this example for help:
# https://dplyr.tidyverse.org/reference/count.html
df_nuD07 <-df_nuD06 %>% dplyr::group_by(smplID,replNo) %>% dplyr::tally(seqrd.cnt>0)
# change column names
colnames(df_nuD07) <- c("smplID","replNo","no_of_genera" )
# make a boxplot
bpl03 <- ggplot(df_nuD07, aes(y=no_of_genera, x=smplID)) + 
  geom_boxplot(aes(col=no_of_genera)) +
  # geom_rect(aes(xmin = bd_l,
  #               xmax = bd_u,
  #               ymin = -Inf, ymax = Inf,
  #               fill = DVFIcat2), alpha = 0.3) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  ggplot2::ggtitle("C - no of DSFI genera found in eDNA" ) +
  geom_point(alpha=0.7) 

#make filename to save plot to
figname11 <- paste0("Fig07F_boxplot_DSFI_genera_repl1_4_pr_ab_01.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname11 <- paste(wd00,"/",figname11,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(bpl03,file=figname11,
                  #width=210,height=297,
                  width=297,height=210,
                  #width=3*297,height=210,
                  units="mm",dpi=300)
}


#_______________________________________________________________________________

# http://www.sthda.com/english/articles/36-classification-methods-essentials/146-discriminant-analysis-essentials-in-r/
df_noch03$family <- df_p01$family[match(df_noch03$species, df_p01$species)]

#
df_noch03.1 <- df_noch03[, colSums(df_noch03 != 0) > 0]
famnms <- df_noch03.1[,ncl3]
#http://www.sthda.com/english/articles/31-principal-component-methods-in-r-practical-guide/122-multidimensional-scaling-essentials-algorithms-and-r-code/
# Load required packages
library(magrittr)
library(dplyr)
library(ggpubr)
# Cmpute MDS
mds <- df_noch03.1 %>%
  dist() %>%          
  cmdscale() %>%
  as_tibble()
colnames(mds) <- c("Dim.1", "Dim.2")
# Plot MDS
ggscatter(mds, x = "Dim.1", y = "Dim.2", 
          label = rownames(df_noch03.1),
          size = 1,
          repel = TRUE)
#

ncl3 <- ncol(df_noch03.1)
df_noch03.2 <- df_noch03.1[ , c(ncl3, seq(2,ncl3-1))] 
# https://stats.stackexchange.com/questions/121131/removing-collinear-variables-for-lda-qda-in-r
# https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html
library(corrplot)
# make all numeric
df_noch03.3 <- mutate_all(df_noch03.2, function(x) as.numeric(as.character(x)))
df_noch03.3$family <- famnms
df_noch03.3$family <- NULL
# identify colinear variation
CMX <- cor(df_noch03.3)
corrplot(CMX, method = 'shade', order = 'AOE', diag = FALSE)
corrplot(CMX, order = 'hclust', addrect = 2)
corrplot(CMX, method = 'square', diag = FALSE, order = 'hclust',
         addrect = 3, rect.col = 'blue', rect.lwd = 3, tl.pos = 'd')
#
testRes = cor.mtest(df_noch03.3, conf.level = 0.85)
## specialized the insignificant value according to the significant level
corrplot(CMX, p.mat = testRes$p, sig.level = 0.10, order = 'hclust', addrect = 2)
## leave blank on non-significant coefficient
## add significant correlation coefficients
corrplot(CMX, p.mat = testRes$p, method = 'circle', type = 'lower', insig='blank',
         addCoef.col ='black', number.cex = 0.8, order = 'AOE', diag=FALSE)

m2 <- lda(family~., data = df_noch03.2)

#f_DS02
#http://www.sthda.com/english/articles/31-principal-component-methods-in-r-practical-guide/122-multidimensional-scaling-essentials-algorithms-and-r-code/
# Load required packages
library(magrittr)
library(dplyr)
library(ggpubr)


colnames(df_noch03)

df_n04 <- as.data.frame(t(df_noch03))
colnames(df_n04) <- df_n04[1,]
df_n04 <- df_n04[-1,]
# convert an entire data.frame to numeric
#https://stackoverflow.com/questions/52909775/how-to-convert-an-entire-data-frame-to-numeric
df_n04[] <- lapply(df_n04, as.numeric)
df_n04[is.na(df_n04)] <- 0
idnmb <- gsub("^(.*)_(.*)$","\\1",rownames(df_n04))
DSFI_CONVcat.fl <- df_DS02$DSFI_CONV[match(idnmb,df_DS02$Sample_number)]
# Cmpute MDS
mds <- df_n04 %>%
  dist() %>%          
  cmdscale() %>%
  as_tibble()
colnames(mds) <- c("Dim.1", "Dim.2")
# Plot MDS
plmds <- ggscatter(mds, x = "Dim.1", y = "Dim.2", 
          label = DSFI_CONVcat.fl,
          shape=22,
          fill=c(DSFI_CONVcat.fl),
          size = 4,
          repel = TRUE)

#make filename to save plot to
figname12 <- paste0("Fig07G_mds.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname12 <- paste(wd00,"/",figname12,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(plmds,file=figname12,
                  width=210,height=297,
                  #width=297,height=210,
                  #width=3*297,height=210,
                  units="mm",dpi=300)
}

#_______________________________________________________________________________
#_______________________________________________________________________________
#_______________________________________________________________________________
#install.packages("BiodiversityR")
if(!require(BiodiversityR)){
  install.packages("BiodiversityR")
  library(BiodiversityR)
}
if(!require(pvclust)){
  install.packages('pvclust')
  library(pvclust)
}



library(BiodiversityR)
library(ggplot2)
library(ggforce)
# https://www.rdocumentation.org/packages/BiodiversityR/versions/2.14-2

data(dune)
str(dune)
data(dune.env)
summary(dune.env)
attach(dune.env)


# copy data frame
df_n05 <- df_n04
#rownames(df_n04)
#only include when row name is not "family"
df_n05$tmprwnm <- rownames(df_n05)
df_n05 <- df_n05[df_n05$tmprwnm!="family",]
#remove column
df_n05$tmprwnm <- NULL
# order the  data frame  by a column
df_DS02.env<- df_DS02[order(df_DS02$Sample_number), ]
# get the number of rows
nRdfDS02.e <- nrow(df_DS02.env)
# split sample number string by  '_' to get replicate numbers in a second column in a data frame
dfrelpNmbs<- data.frame(do.call('rbind', strsplit(as.character(row.names(df_n05)),'_',fixed=TRUE)))[2]
# get the unique elements in the first column and make them numeric
relpNmbs<- as.numeric(unique(dfrelpNmbs[,1]))
# get the highest replicate number
mxRplN <- max(relpNmbs)
# replicate rows n times  - see this question: https://stackoverflow.com/questions/8753531/repeat-rows-of-a-data-frame-n-times
n <- mxRplN
# repeat a sequence of numbers starting from 1 to the highest replicate number
sq.rplNmb <- rep(seq(1,n,1),nRdfDS02.e)
# order this sequence of numbers 
o.sq.rplNmb <- sq.rplNmb[order(sq.rplNmb)]
# repeat every row in the df_DS02.env data frame to equal the number of replicates
df_DS02.env <- do.call("rbind", replicate(n, df_DS02.env, simplify = FALSE))
# add back the PCR replicate number to the data frame
df_DS02.env$pcrrplNmb <- o.sq.rplNmb
# paste sample number and replicate number together
df_DS02.env$Sample_number2 <- paste(df_DS02.env$Sample_number,"_",df_DS02.env$pcrrplNmb,sep="")
#only include when row name is not "family"
df_n05$tmprwnm <- rownames(df_n05)
df_n05 <- df_n05[df_n05$tmprwnm!="family",]
#remove column
df_n05$tmprwnm <- NULL
# get the row names for the NK samples
rwnmNK<- rownames(df_n05)[grepl("NK",rownames(df_n05))]
# get the number of NK rows
nNKr <- length(rwnmNK)
# get the number of ID rows in the df_DS02.env data frame
nIDr <- nrow(df_DS02.env)
# add this amount of empty rows with NA to the sample environment data frame 
df_DS02.env[nrow(df_DS02.env)+nNKr,] <- NA
# add the NK sample number names for the NK samples
df_DS02.env$Sample_number2[(nIDr+1):(nIDr+nNKr)] <- rwnmNK
df_DS02.env$Sample_number[(nIDr+1):(nIDr+nNKr)] <- rwnmNK
# also add a location name for the NK samples
df_DS02.env$Location[(nIDr+1):(nIDr+nNKr)] <- "NegCont"
# the sample number 'ID042_2' is missing from the original 
# OTU table, because of this it is not possible to match it in the
# 'df_DS02.env' data frame. Because of this I remove this row
# from this data frame
df_DS02.env <- df_DS02.env[!df_DS02.env$Sample_number2=="ID042_2",]
# it is the same problem for "NK01_2". There is no '"NK01_2"' sample in the  original 
# OTU table, because of this it is not possible to match it in the
# 'df_DS02.env' data frame. Because of this I remove this row
# from this data frame
df_DS02.env <- df_DS02.env[!df_DS02.env$Sample_number2=="NK01_2",]
df_DS02.env <- df_DS02.env[!df_DS02.env$Sample_number2=="ID021_3",]
df_DS02.env <- df_DS02.env[!df_DS02.env$Sample_number2=="NK01_3",]
df_DS02.env <- df_DS02.env[!df_DS02.env$Sample_number2=="NK06_3",]

# count the number of rows in the 'df_DS02.env' data frame
nrow(df_DS02.env)
# find the sample numbers that are not included in the 'df_DS02.env' data frame 
length(df_DS02.env$Sample_number2)
length(unique(df_DS02.env$Sample_number2))
# retain not duplicated rows - 
# onøly considering duplicates for the 'Sample_number2'
# column-  see: https://stackoverflow.com/questions/13967063/remove-duplicated-rows
df_DS02.env <- df_DS02.env[!duplicated(df_DS02.env$Sample_number2), ]

# check there is an equal number of rows in the two data frames
# this is a requirement for the 'vegan::rda' function later on 
nrow(df_DS02.env) == nrow(df_n05)


# use this section here below to work out which parts are missing from the 
# data frames
notin_df_DS02.env <- setdiff(rownames(df_n05),df_DS02.env$Sample_number2)
notin_df_n05 <- setdiff(df_DS02.env$Sample_number2,rownames(df_n05))
# split sample number string by  '_' to get sample numbers in a first column in a data frame
notin_df_DS02.env<- data.frame(do.call('rbind', strsplit(as.character(notin_df_DS02.env),'_',fixed=TRUE)))[1]
#unique(notin_df_DS02.env[,1])

# make the ordination model on the example data
dune.Hellinger <- disttransform(dune, method='hellinger')
Ordination.model1 <- rda(dune.Hellinger ~ Management, 
                         data=dune.env, 
                         scaling="species")
summary(Ordination.model1)
# make the ordination model on your own data
df_n05.Hell <- disttransform(df_n05, method='hellinger')
ordM1 <- rda(df_n05.Hell ~ Sample_number2, 
             data=df_DS02.env, 
             scaling="species")

summary(ordM1)

# Prepare to modify the ggplot theme
BioR.theme <- ggplot2::theme(
  panel.background = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.line = element_line("gray25"),
  text = element_text(size = 12),
  axis.text = element_text(size = 10, colour = "gray25"),
  axis.title = element_text(size = 14, colour = "gray25"),
  legend.title = element_text(size = 14),
  legend.text = element_text(size = 14),
  legend.key = element_blank())

# Use 'ordiplot' function on example data
plot1 <- ordiplot(Ordination.model1, choices=c(1,2))
# Use 'ordiplot' function on your own data
plot1.e <- ordiplot(ordM1, choices=c(1,2))

#make sites long on example data
sites.long1 <- sites.long(plot1, env.data=dune.env)
#make sites long on your own data
sites.long1.e <- sites.long(plot1.e, env.data=df_DS02.env)
head(sites.long1)
head(sites.long1.e)
# make axis long for the example data
axis.long1 <- axis.long(Ordination.model1, choices=c(1, 2))
axis.long1
# make axis long for your own data
axis.long1.e <- axis.long(ordM1, choices=c(1, 2))
axis.long1.e

# make plot 1 for the example data
plotgg1 <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab(axis.long1[1, "label"]) +
  ylab(axis.long1[2, "label"]) +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  ggforce::geom_mark_ellipse(data=sites.long1, 
                             aes(x=axis1, y=axis2, colour=Management, 
                                 fill=after_scale(alpha(colour, 0.2))), 
                             expand=0, size=0.2, show.legend=FALSE) +
  geom_segment(data=centroids.long(sites.long1, grouping=Management), 
               aes(x=axis1c, y=axis2c, xend=axis1, yend=axis2, colour=Management), 
               size=1, show.legend=FALSE) +
  geom_point(data=sites.long1, 
             aes(x=axis1, y=axis2, colour=Management, shape=Management), 
             size=5) +
  BioR.theme +
  ggsci::scale_colour_npg() +
  coord_fixed(ratio=1)

plotgg1



# make the continuous character a category character
sites.long1.e$DSFI_eDNA_water <- as.character(sites.long1.e$DSFI_eDNA_water)
sites.long1.e$DVFI <- as.character(sites.long1.e$DVFI)
# make plot 1 for your own data using DSFI_eDNA_water
plotgg1.e <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab(axis.long1[1, "label"]) +
  ylab(axis.long1[2, "label"]) +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  ggforce::geom_mark_ellipse(data=sites.long1.e, 
                             aes(x=axis1, y=axis2, colour=DSFI_eDNA_water, 
                                 fill=after_scale(alpha(colour, 0.2))), 
                             expand=0, size=0.2, show.legend=FALSE) +
  # geom_segment(data=centroids.long(sites.long1.e, grouping=DSFI_eDNA_water),
  #              aes(x=axis1c, y=axis2c, xend=axis1, yend=axis2, colour=DSFI_eDNA_water),
  #              size=1, show.legend=FALSE) +
  geom_point(data=sites.long1.e, 
             aes(x=axis1, y=axis2, colour=DSFI_eDNA_water), 
             size=5) +
  BioR.theme +
  ggsci::scale_colour_npg() +
  coord_fixed(ratio=1)

plotgg1.e

#make filename to save plot to
figname13 <- paste0("Fig08A_RDA.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname13 <- paste(wd00,"/",figname13,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(plotgg1.e,file=figname13,
                  width=210,height=297,
                  #width=297,height=210,
                  #width=3*297,height=210,
                  units="mm",dpi=300)
}

# make plot 1 for your own data using DVFI
sites.long1.e$DVFI <- as.character(sites.long1.e$DVFI)
# make plot 1 for the example data
plotgg1.e <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab(axis.long1[1, "label"]) +
  ylab(axis.long1[2, "label"]) +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  ggforce::geom_mark_ellipse(data=sites.long1.e, 
                             aes(x=axis1, y=axis2, colour=DVFI, 
                                 fill=after_scale(alpha(colour, 0.2))), 
                             expand=0, size=0.2, show.legend=FALSE) +
  # geom_segment(data=centroids.long(sites.long1.e, grouping=DVFI),
  #              aes(x=axis1c, y=axis2c, xend=axis1, yend=axis2, colour=DVFI),
  #              size=1, show.legend=FALSE) +
  geom_point(data=sites.long1.e, 
             aes(x=axis1, y=axis2, colour=DVFI), 
             size=5) +
  BioR.theme +
  ggsci::scale_colour_npg() +
  coord_fixed(ratio=1)

plotgg1.e


#make filename to save plot to
figname13 <- paste0("Fig08B_RDA.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname13 <- paste(wd00,"/",figname13,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(plotgg1.e,file=figname13,
                  width=210,height=297,
                  #width=297,height=210,
                  #width=3*297,height=210,
                  units="mm",dpi=300)
}

# make plot 1 for your own data using DSFI_CONV
sites.long1.e$DSFI_CONV <- as.character(sites.long1.e$DSFI_CONV)
# make plot 1 for the example data
plotgg1.e <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab(axis.long1[1, "label"]) +
  ylab(axis.long1[2, "label"]) +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  ggforce::geom_mark_ellipse(data=sites.long1.e, 
                             aes(x=axis1, y=axis2, colour=DSFI_CONV, 
                                 fill=after_scale(alpha(colour, 0.2))), 
                             expand=0, size=0.2, show.legend=FALSE) +
  # geom_segment(data=centroids.long(sites.long1.e, grouping=DSFI_CONV),
  #              aes(x=axis1c, y=axis2c, xend=axis1, yend=axis2, colour=DSFI_CONV),
  #              size=1, show.legend=FALSE) +
  geom_point(data=sites.long1.e, 
             aes(x=axis1, y=axis2, colour=DSFI_CONV), 
             size=5) +
  BioR.theme +
  ggsci::scale_colour_npg() +
  coord_fixed(ratio=1)

plotgg1.e


#make filename to save plot to
figname13 <- paste0("Fig08C_RDA.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname13 <- paste(wd00,"/",figname13,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(plotgg1.e,file=figname13,
                  width=210,height=297,
                  #width=297,height=210,
                  #width=3*297,height=210,
                  units="mm",dpi=300)
}

# Example 2: Confidence ellipses for categorical variables

plot1 <- ordiplot(Ordination.model1, choices=c(1,2))
Management.ellipses <- ordiellipse(plot1, 
                                   groups=Management, 
                                   display="sites", 
                                   kind="sd")

Management.ellipses.long1 <- ordiellipse.long(Management.ellipses,
                                              grouping.name="Management")
# Generate the plot
plotgg2 <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab(axis.long1[1, "label"]) +
  ylab(axis.long1[2, "label"]) +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  geom_polygon(data=Management.ellipses.long1, 
               aes(x=axis1, y=axis2, 
                   colour=Management, 
                   fill=after_scale(alpha(colour, 0.2))), 
               size=0.2, show.legend=FALSE) +
  geom_segment(data=centroids.long(sites.long1, 
                                   grouping=Management), 
               aes(x=axis1c, y=axis2c, xend=axis1, yend=axis2, 
                   colour=Management), 
               size=1, show.legend=FALSE) +
  geom_point(data=sites.long1, 
             aes(x=axis1, y=axis2, colour=Management, shape=Management), 
             size=5) +
  BioR.theme +
  ggsci::scale_colour_npg() +
  coord_fixed(ratio=1)

plotgg2

# 
# Example 3: Smooth surfaces for continuous variables
# Extract the data
A1.surface <- ordisurf(plot1, y=A1)
A1.grid <- ordisurfgrid.long(A1.surface)
# Generate the plot
plotgg3 <- ggplot() + 
  geom_contour_filled(data=A1.grid, 
                      aes(x=x, y=y, z=z)) +
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab(axis.long1[1, "label"]) +
  ylab(axis.long1[2, "label"]) +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  geom_point(data=sites.long1, 
             aes(x=axis1, y=axis2, shape=Management), 
             colour="red", size=4) +
  BioR.theme +
  scale_fill_viridis_d() +
  labs(fill="A1") +
  coord_fixed(ratio=1)

plotgg3
# 
# Example 4: Add information from pvclust to ordination diagrams
# Extract the data
library(pvclust)
dune.pv <- pvclust(t(dune.Hellinger), 
                   method.hclust="mcquitty",
                   method.dist="euclidean",
                   nboot=1000)

plot1 <- ordiplot(Ordination.model1, choices=c(1,2), scaling='species')
cl.data1 <- ordicluster(plot1, 
                        cluster=as.hclust(dune.pv$hclust))


pvlong <- pvclust.long(dune.pv, cl.data1)
# Generate the plot

plotgg4 <- ggplot() + 
  geom_vline(xintercept = c(0), color = "grey70", linetype = 2) +
  geom_hline(yintercept = c(0), color = "grey70", linetype = 2) +  
  xlab(axis.long1[1, "label"]) +
  ylab(axis.long1[2, "label"]) +  
  scale_x_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels=NULL, name=NULL)) +
  geom_segment(data=subset(pvlong$segments, 
                           pvlong$segments$prune > 3),
               aes(x=x1, y=y1, xend=x2, yend=y2, 
                   colour=au>=0.89, 
                   size=au),
               show.legend=TRUE) +
  geom_point(data=subset(pvlong$nodes, 
                         pvlong$nodes$prune > 3), 
             aes(x=x, y=y, 
                 fill=au>=0.89), 
             shape=21, size=2, colour="black") +
  geom_point(data=sites.long1, 
             aes(x=axis1, y=axis2, shape=Management), 
             colour="darkolivegreen4", alpha=0.9, size=5) +
  geom_text(data=sites.long1,
            aes(x=axis1, y=axis2, label=labels)) +
  BioR.theme +
  ggsci::scale_colour_npg() +
  scale_size(range=c(0.3, 2)) +
  scale_shape_manual(values=c(15, 16, 17, 18)) +
  guides(shape = guide_legend(override.aes = list(linetype = 0))) +
  coord_fixed(ratio=1)

plotgg4
# 
# #_______________________________________________________________________________

# make the ordination model on your own data
df_n05.Hell <- disttransform(df_n05, method='hellinger')
ordM1 <- rda(df_n05.Hell ~ Sample_number2, 
             data=df_DS02.env, 
             scaling="species")
#df_n05[is.na(df_n05),]
ordM2 <- BiodiversityR::CAPdiscrim(df_n05 ~ Sample_number2, 
                                   data=df_DS02.env,
                          dist="bray", axes=2, m=0, add=FALSE)
# Ordination.model1 <- BiodiversityR::CAPdiscrim(reads~habitat.x,samples,
#                                 dist="bray", axes=2, m=0, add=FALSE)
Ordination.model1
plot1 <- ordiplot(Ordination.model1, type="none")
#ordisymbol(plot1, samples, "habitat.x", col = colvec[samples$habitat],pchs=FALSE,legend=FALSE)
ordihull(Ordination.model1,groups=samples$habitat,
         display="sites",col=colvec,alpha=100,draw="polygon",border=colvec)
plot(seq(1:14), rep(-1000, 14), xlim=c(1, 14), ylim=c(0, 100), xlab="m",
     ylab="classification success (percent)", type="n")
for (mseq in 1:14) {
  CAPdiscrim.result <- CAPdiscrim(reads~habitat.x,samples,
                                  dist="bray", axes=2, m=mseq)
  points(mseq, CAPdiscrim.result$percent)
}
#}

#Håber, det kan bruges :-) Funktionen CAPdiscrim er fra pakken BiodiversityR.

#_______________________________________________________________________________

# Make linear discriminant analysis
#_______________________________________________________________________________
#https://github.com/Statology/R-Guides/blob/main/linear_discriminant_analysis
#LOAD NECESSARY LIBRARIES
library(ggplot2)
library(MASS)
#FIT LDA MODEL 
# copy the data frame
df_n06 <- df_n05
#Match DVFI category to data frame
df_n06$DVFIcat <- df_DS02.env$DVFI[match(df_DS02.env$Sample_number2,row.names(df_n05))]
# for the missing DVFI categories assign zero
df_n06$DVFIcat[is.na(df_n06$DVFIcat)] <- 0
# make the DVFI categories  characters
df_n06$DVFIcat <- as.character(df_n06$DVFIcat)
# make the LDA model
m2 <- MASS::lda(DVFIcat ~ ., 
                data=df_n06)
#USE MODEL TO MAKE PREDICTIONS
pre2 <-predict(m2,df_n06)
mean(pre2$class==df_n06$DVFIcat)
#VISUALIZE LINEAR DISCRIMINANTS
lda_pl2 <- cbind(df_n06, predict(m2)$x)
# make  the plot
ldap01 <- ggplot(lda_pl2, aes(LD1, LD2)) +
  geom_point(aes(color = DVFIcat))
# change color of points
ldap01 <- ldap01 + scale_colour_brewer(palette="Dark2")
#ldap01
# plot with the two other LD axis
ldap02 <- ggplot(lda_pl2, aes(LD1, LD3)) +
  geom_point(aes(color = DVFIcat))
# change color of points
#https://statisticsglobe.com/scale-colour-fill-brewer-rcolorbrewer-package-r
ldap02 <- ldap02 + scale_colour_brewer(palette="Spectral")
ldap02 <- ldap02 + scale_colour_brewer(palette="Dark2")
#ldap02

# Add titles
# see this example: https://www.datanovia.com/en/blog/ggplot-title-subtitle-and-caption/
#caption = "Data source: ToothGrowth")
ldap01t <- ldap01 + labs(title = "a")#,
# Add titles
# p06t <- p06 + labs(title = "eDNA samples attempted",
#                    subtitle = "at least approv controls and 1 or 2 pos repl")#,
ldap02t <- ldap02 + labs(title = "b")#,
# ------------- plot Combined figure -------------
library(patchwork)
# set a variable to TRUE to determine whether to save figures
bSaveFigures <- T
#see this website: https://www.rdocumentation.org/packages/patchwork/versions/1.0.0
# on how to arrange plots in patchwork
clplot2 <-  ldap01t +
  ldap02t +
  
  plot_layout(nrow=2,byrow=T) + #xlab(xlabel) +
  plot_layout(guides = "collect") #+
  #plot_annotation(caption=inpf01) #& theme(legend.position = "bottom")
#p

#make filename to save plot to
figname14 <- paste0("Fig09A_LDA.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname14 <- paste(wd00,"/",figname14,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(clplot2,file=figname14,
                  width=210,height=297,
                  #width=297,height=210,
                  #width=3*297,height=210,
                  units="mm",dpi=300)
}

#_______________________________________________________________________________

#_______________________________________________________________________________

# Make linear discriminant analysis
# But this time without zero DVFI categories
#_______________________________________________________________________________
#https://github.com/Statology/R-Guides/blob/main/linear_discriminant_analysis
#LOAD NECESSARY LIBRARIES
library(ggplot2)
library(MASS)
#FIT LDA MODEL 
# copy the data frame
df_n06 <- df_n05
#Match DVFI category to data frame
df_n06$DVFIcat <- df_DS02.env$DVFI[match(df_DS02.env$Sample_number2,row.names(df_n05))]
# for the missing DVFI categories assign zero
df_n06$DVFIcat[is.na(df_n06$DVFIcat)] <- 0
df_n06 <- df_n06[df_n06$DVFIcat!=0,]
# make the DVFI categories  characters
df_n06$DVFIcat <- as.character(df_n06$DVFIcat)
# make the LDA model
m2 <- MASS::lda(DVFIcat ~ ., 
                data=df_n06)
#USE MODEL TO MAKE PREDICTIONS
pre2 <-predict(m2,df_n06)
mean(pre2$class==df_n06$DVFIcat)
#VISUALIZE LINEAR DISCRIMINANTS
lda_pl2 <- cbind(df_n06, predict(m2)$x)
# make  the plot
ldap01 <- ggplot(lda_pl2, aes(LD1, LD2)) +
  geom_point(aes(color = DVFIcat))
# change color of points
ldap01 <- ldap01 + scale_colour_brewer(palette="Dark2")
#ldap01
# plot with the two other LD axis
ldap02 <- ggplot(lda_pl2, aes(LD1, LD3)) +
  geom_point(aes(color = DVFIcat))
# change color of points
#https://statisticsglobe.com/scale-colour-fill-brewer-rcolorbrewer-package-r
ldap02 <- ldap02 + scale_colour_brewer(palette="Spectral")
ldap02 <- ldap02 + scale_colour_brewer(palette="Dark2")
#ldap02

# Add titles
# see this example: https://www.datanovia.com/en/blog/ggplot-title-subtitle-and-caption/
#caption = "Data source: ToothGrowth")
ldap01t <- ldap01 + labs(title = "a")#,
# Add titles
# p06t <- p06 + labs(title = "eDNA samples attempted",
#                    subtitle = "at least approv controls and 1 or 2 pos repl")#,
ldap02t <- ldap02 + labs(title = "b")#,
# ------------- plot Combined figure -------------
library(patchwork)
# set a variable to TRUE to determine whether to save figures
bSaveFigures <- T
#see this website: https://www.rdocumentation.org/packages/patchwork/versions/1.0.0
# on how to arrange plots in patchwork
clplot2 <-  ldap01t +
  ldap02t +
  
  plot_layout(nrow=2,byrow=T) + #xlab(xlabel) +
  plot_layout(guides = "collect") #+
#plot_annotation(caption=inpf01) #& theme(legend.position = "bottom")
#p

#make filename to save plot to
figname14 <- paste0("Fig09B_LDA_nozeroDVFIcat.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname14 <- paste(wd00,"/",figname14,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggplot2::ggsave(clplot2,file=figname14,
                  width=210,height=297,
                  #width=297,height=210,
                  #width=3*297,height=210,
                  units="mm",dpi=300)
}

