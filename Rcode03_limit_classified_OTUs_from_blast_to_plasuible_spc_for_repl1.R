#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

#____________________________________________________________________________#
# R-code provided for the project:
# invertebrate species in Danish freshwater streams

#remove everything in the working environment, without a warning!!
rm(list=ls())
library(readxl)
library(dplyr)
library(ggplot2)
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
inf03 <- "DADA2_nochim.table_repl1.txt"
# paste together path and input file
pthinf01 <- paste0(wd00,"/",inf01)
pthinf02 <- paste0(wdin01,"/",inf02)
pthinf03 <- paste0(wdin01,"/",inf03)
# read in files
df_p01 <- read.csv(pthinf01, header = T)
df_c01 <- read.table(pthinf02, sep="\t",header = T)
df_noch01 <- read.table(pthinf03, sep="\t",header = T)
# change column name of first column
colnames(df_noch01)[1] <- "seqid"
#match back taxonomic species category
df_noch01$species <- df_c01$species[match(df_noch01$seqid,df_c01$qseqid)]
# sum up read counts from different seqid within same species
df_noch02 <- aggregate(df_noch01[,sapply(df_noch01,is.numeric)],df_noch01["species"],sum)
# load the dplyr package
library(dplyr)
#Subsetting rows in nochim table based on data frame with plausible species
df_noch03 <- df_noch02 %>% dplyr::filter(species %in% df_p01$species)
# and subset to include those not in the list of plausible species
df_nonoch03 <- df_noch02 %>% dplyr::filter(!species %in% df_p01$species)
# count the number of rows in the dataframes
nrow(df_noch03)
nrow(df_nonoch03)
# reshape data frame from wide to long
df_noch04 <- reshape2::melt(df_noch03,id.vars = c("species"),value.name = "seqrd.cnt")
df_nonoch04 <- reshape2::melt(df_nonoch03,id.vars = c("species"),value.name = "seqrd.cnt")
#change column names
colnames(df_noch04) <- c("species","smplNo","seqrd.cnt")
colnames(df_nonoch04) <- c("species","smplNo","seqrd.cnt")
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

stbp07 <- ggplot(tibl06,aes(smplNo,seqrd.cnt  ,fill = phylum))+
  geom_bar(position = "fill",stat="identity", width = 0.9, 
           #the 'color="#000000",size=0.1' adds a thin line between 
           # individual parts of the bar in the stacked bar
           color="#000000",size=0.1)+
  geom_hline(yintercept=0.25, col = "black", lty=2) +
  geom_hline(yintercept=0.5,  col = "black",lty=2) +
  geom_hline(yintercept=0.75,  col = "black",lty=2) +
  theme_grey()+
  # add label above each bar to denote total number of reads
  geom_text(data=tibl06, aes(x = smplNo, y = 0.98,
              label = totrcnt), 
            hjust="right",
            vjust=0.5, angle = 90) +

  xlab("sample ID")+
  ylab("percentage of reads from plausible species")+
  #scale_fill_manual(values = vclr)+
  scale_y_continuous(labels = function(x) paste0(x*100, "%")) +
  ggtitle("A - replicate 1")+
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
  #facet_grid(.~MSTNo) +
  coord_cartesian(expand=F)
# see the plot
#stbp07


#plot_annotation(caption=inpf01) #& theme(legend.position = "bottom")
#p
#make filename to save plot to
figname08 <- paste0("Fig07B_stckbarplot_plausibl_spc_repl1_01.png")
#set variable to define if figures are to be saved
bSaveFigures<-T
#paste together path and file name
figname08 <- paste(wd00,"/",figname08,sep="")
# check if plot should be saved, and if TRUE , then save as '.png'
if(bSaveFigures==T){
  ggsave(stbp07,file=figname08,
         #width=210,height=297,
         width=297,height=210,
         units="mm",dpi=300)
}
