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
# Ordination.model1 <- BiodiversityR::CAPdiscrim(reads~habitat.x,samples,
#                                 dist="bray", axes=2, m=0, add=FALSE)
# Ordination.model1
# plot1 <- ordiplot(Ordination.model1, type="none")
# #ordisymbol(plot1, samples, "habitat.x", col = colvec[samples$habitat],pchs=FALSE,legend=FALSE)
# ordihull(Ordination.model1,groups=samples$habitat,
#          display="sites",col=colvec,alpha=100,draw="polygon",border=colvec)
# plot(seq(1:14), rep(-1000, 14), xlim=c(1, 14), ylim=c(0, 100), xlab="m",
#      ylab="classification success (percent)", type="n")
# for (mseq in 1:14) {
#   CAPdiscrim.result <- CAPdiscrim(reads~habitat.x,samples,
#                                   dist="bray", axes=2, m=mseq)
#   points(mseq, CAPdiscrim.result$percent)
# }
# }
# 
# #Håber, det kan bruges :-) Funktionen CAPdiscrim er fra pakken BiodiversityR.
