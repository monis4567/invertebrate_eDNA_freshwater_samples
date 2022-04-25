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
# paste together path and input file
pthinf01 <- paste0(wd00,"/",inf01)
pthinf02 <- paste0(wdin01,"/",inf02)
pthinf03 <- paste0(wdin01,"/",inf03)
pthinf04 <- paste0(wd00,"/",inf04)
# read in files
df_p01 <- read.csv(pthinf01, header = T)
df_c01 <- read.table(pthinf02, sep="\t",header = T)
df_noch01 <- read.table(pthinf03, sep="\t",header = T)
df_uiDSFI01 <- read.csv(pthinf04, header = F)
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
  ggtitle("A - replicate 1 and 2")+
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
  ggtitle("A - replicate 1 and 2. Presence/absence eval. All reads have been set to 1")+
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
figname08 <- paste0("Fig07C_stckbarplot_plausibl_spc_repl1and2_pr_ab_01.png")
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
#edit the zero DVFI category column based on IDsample number
tibl06$DVFIcat[tibl06$smplID %in% c("ID012", "ID014")] <- 1 # gray
tibl06$DVFIcat[tibl06$smplID %in% c("ID031", "ID032")] <- 2 # blue
tibl06$DVFIcat[tibl06$smplID %in% c("ID066", "ID021")] <- 3 # purple
tibl06$DVFIcat[tibl06$smplID %in% c("ID006", "ID007")] <- 4 # red
tibl06$DVFIcat[tibl06$smplID %in% c("ID008", "ID009")] <- 5 # orange
tibl06$DVFIcat[tibl06$smplID %in% c("ID038", "ID040")] <- 6 # yellow
tibl06$DVFIcat[tibl06$smplID %in% c("ID047", "ID048")] <- 7 # white
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
figname10 <- paste0("Fig07E_boxplot_plausibl_spc_repl1and2_pr_ab_01.png")
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
figname11 <- paste0("Fig07F_boxplot_DSFI_genera_repl1and2_pr_ab_01.png")
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
