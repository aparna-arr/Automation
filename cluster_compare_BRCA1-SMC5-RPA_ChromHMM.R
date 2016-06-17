library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(gplots)

corLimit <- 0.9

BRCA1_RPA_SMC5<-read.delim("emm/original_emissions.txt", header=T)
BRCA1_RPA<-read.delim("emm/remove_SMC5_emissions.txt", header=T)
RAD51_RPA_SMC5<-read.delim("emm/replace_BRCA1_with_RAD51_emissions.txt", header=T)
RAD51_RPA<-read.delim("emm/replace_BRCA1_with_RAD51_remove_SMC5_emissions.txt", header=T)
BRCA1<-read.delim("emm/BRCA1_only_emissions.txt", header=T)
RPA<-read.delim("emm/RPA_only_emissions.txt", header=T)
SMC5<-read.delim("emm/SMC5_only_emissions.txt", header=T)
RAD51<-read.delim("emm/RAD51_only_emissions.txt", header=T)
BRCA1_RPA_SMC5_RAD51<-read.delim("emm/add_RAD51_emissions.txt", header=T)

BRCA1_RPA_SMC5<-BRCA1_RPA_SMC5[-1]
BRCA1_RPA<-BRCA1_RPA[-1]
RAD51_RPA_SMC5<-RAD51_RPA_SMC5[-1]
RAD51_RPA<-RAD51_RPA[-1]
BRCA1<-BRCA1[-1]
RPA<-RPA[-1]
SMC5<-SMC5[-1]
RAD51<-RAD51[-1]
BRCA1_RPA_SMC5_RAD51<-BRCA1_RPA_SMC5_RAD51[-1]

rownames(BRCA1_RPA_SMC5)<-paste0("BRCA1_RPA_SMC5_", seq(1,nrow(BRCA1_RPA_SMC5)))
rownames(BRCA1_RPA)<-paste0("BRCA1_RPA_", seq(1,nrow(BRCA1_RPA)))
rownames(RAD51_RPA_SMC5)<-paste0("RAD51_RPA_SMC5_", seq(1,nrow(RAD51_RPA_SMC5)))
rownames(RAD51_RPA)<-paste0("RAD51_RPA_", seq(1,nrow(RAD51_RPA)))
rownames(BRCA1)<-paste0("BRCA1_", seq(1,nrow(BRCA1)))
rownames(RPA)<-paste0("RPA_", seq(1,nrow(RPA)))
rownames(SMC5)<-paste0("SMC5_", seq(1,nrow(SMC5)))
rownames(RAD51)<-paste0("RAD51_", seq(1,nrow(RAD51)))
rownames(BRCA1_RPA_SMC5_RAD51)<-paste0("BRCA1_RPA_SMC5_RAD51", seq(1,nrow(BRCA1_RPA_SMC5_RAD51)))

pal_white_blue<-colorRampPalette(c("white", "blue"))(n=100)

## printing intermediate heatmaps ##
pdf("emissions_each_sample.pdf", width=8, height=15)

## BRCA1 RPA SMC5 ## 

id1<-grep("BRCA1", colnames(BRCA1_RPA_SMC5))
id2<-grep("RPA", colnames(BRCA1_RPA_SMC5))
id3<-grep("SMC5", colnames(BRCA1_RPA_SMC5))

BRCA1_RPA_SMC5_ord<-BRCA1_RPA_SMC5[order(BRCA1_RPA_SMC5[,id1] + BRCA1_RPA_SMC5[,id2] + BRCA1_RPA_SMC5[,id3], decreasing=TRUE),]

heatmap.2(as.matrix(BRCA1_RPA_SMC5_ord), col=pal_white_blue, trace="none", notecol="black", cellnote=round(BRCA1_RPA_SMC5_ord,2), scale="none", Rowv=FALSE, margin=c(10,10), dendrogram="column", key=FALSE, main="BRCA1 RPA SMC5")

## BRCA1 RPA ##

id1<-grep("BRCA1", colnames(BRCA1_RPA))
id2<-grep("RPA", colnames(BRCA1_RPA))

BRCA1_RPA_ord<-BRCA1_RPA[order(BRCA1_RPA[,id1] + BRCA1_RPA[,id2], decreasing=TRUE),]

heatmap.2(as.matrix(BRCA1_RPA_ord), col=pal_white_blue, trace="none", notecol="black", cellnote=round(BRCA1_RPA_ord,2), scale="none", Rowv=FALSE, margin=c(10,10), dendrogram="column", key=FALSE, main="BRCA1 RPA")

## RAD51 RPA SMC5 ## 

id1<-grep("RAD51", colnames(RAD51_RPA_SMC5))
id2<-grep("RPA", colnames(RAD51_RPA_SMC5))
id3<-grep("SMC5", colnames(RAD51_RPA_SMC5))

RAD51_RPA_SMC5_ord<-RAD51_RPA_SMC5[order(RAD51_RPA_SMC5[,id1] + RAD51_RPA_SMC5[,id2] + RAD51_RPA_SMC5[,id3], decreasing=TRUE),]

heatmap.2(as.matrix(RAD51_RPA_SMC5_ord), col=pal_white_blue, trace="none", notecol="black", cellnote=round(RAD51_RPA_SMC5_ord,2), scale="none", Rowv=FALSE, margin=c(10,10), dendrogram="column", key=FALSE, main="RAD51 RPA SMC5")

## RAD51 RPA ##

id1<-grep("RAD51", colnames(RAD51_RPA))
id2<-grep("RPA", colnames(RAD51_RPA))

RAD51_RPA_ord<-RAD51_RPA[order(RAD51_RPA[,id1] + RAD51_RPA[,id2], decreasing=TRUE),]

heatmap.2(as.matrix(RAD51_RPA_ord), col=pal_white_blue, trace="none", notecol="black", cellnote=round(RAD51_RPA_ord,2), scale="none", Rowv=FALSE, margin=c(10,10), dendrogram="column", key=FALSE, main="RAD51 RPA")

## BRCA1 ##
id1<-grep("BRCA1", colnames(BRCA1))

BRCA1_ord<-BRCA1[order(BRCA1[,id1], decreasing=TRUE),]

heatmap.2(as.matrix(BRCA1_ord), col=pal_white_blue, trace="none", notecol="black", cellnote=round(BRCA1_ord,2), scale="none", Rowv=FALSE, margin=c(10,10), dendrogram="column", key=FALSE, main="BRCA1")

## RPA ##
id1<-grep("RPA", colnames(RPA))

RPA_ord<-RPA[order(RPA[,id1], decreasing=TRUE),]

heatmap.2(as.matrix(RPA_ord), col=pal_white_blue, trace="none", notecol="black", cellnote=round(RPA_ord,2), scale="none", Rowv=FALSE, margin=c(10,10), dendrogram="column", key=FALSE, main="RPA")

## SMC5 ##
id1<-grep("SMC5", colnames(SMC5))

SMC5_ord<-SMC5[order(SMC5[,id1], decreasing=TRUE),]

heatmap.2(as.matrix(SMC5_ord), col=pal_white_blue, trace="none", notecol="black", cellnote=round(SMC5_ord,2), scale="none", Rowv=FALSE, margin=c(10,10), dendrogram="column", key=FALSE, main="SMC5")

## RAD51 ##
id1<-grep("RAD51", colnames(RAD51))

RAD51_ord<-RAD51[order(RAD51[,id1], decreasing=TRUE),]

heatmap.2(as.matrix(RAD51_ord), col=pal_white_blue, trace="none", notecol="black", cellnote=round(RAD51_ord,2), scale="none", Rowv=FALSE, margin=c(10,10), dendrogram="column", key=FALSE, main="RAD51")

## BRCA1 RPA SMC5 RAD51 ## 

id1<-grep("BRCA1", colnames(BRCA1_RPA_SMC5_RAD51))
id2<-grep("RPA", colnames(BRCA1_RPA_SMC5_RAD51))
id3<-grep("SMC5", colnames(BRCA1_RPA_SMC5_RAD51))
id4<-grep("RAD51", colnames(BRCA1_RPA_SMC5_RAD51))

BRCA1_RPA_SMC5_RAD51_ord<-BRCA1_RPA_SMC5_RAD51[order(BRCA1_RPA_SMC5_RAD51[,id1] + BRCA1_RPA_SMC5_RAD51[,id2] + BRCA1_RPA_SMC5_RAD51[,id3] + BRCA1_RPA_SMC5_RAD51[,id4], decreasing=TRUE),]

heatmap.2(as.matrix(BRCA1_RPA_SMC5_RAD51_ord), col=pal_white_blue, trace="none", notecol="black", cellnote=round(BRCA1_RPA_SMC5_RAD51_ord,2), scale="none", Rowv=FALSE, margin=c(10,10), dendrogram="column", key=FALSE, main="BRCA1 RPA SMC5 RAD51")
dev.off()

myrep<-rep(-1,nrow(BRCA1_RPA_SMC5)) # same num of rows for all samples

BRCA1_RPA_SMC5<-cbind(BRCA1_RPA_SMC5, myrep)
colnames(BRCA1_RPA_SMC5)[ncol(BRCA1_RPA_SMC5)] <- "RAD51"

BRCA1_RPA<-cbind(BRCA1_RPA, myrep)
colnames(BRCA1_RPA)[ncol(BRCA1_RPA)] <- "RAD51"
BRCA1_RPA<-cbind(BRCA1_RPA, myrep)
colnames(BRCA1_RPA)[ncol(BRCA1_RPA)] <- "SMC5"

RAD51_RPA_SMC5<-cbind(RAD51_RPA_SMC5, myrep)
colnames(RAD51_RPA_SMC5)[ncol(RAD51_RPA_SMC5)] <- "BRCA1"

RAD51_RPA<-cbind(RAD51_RPA, myrep)
colnames(RAD51_RPA)[ncol(RAD51_RPA)] <- "BRCA1"
RAD51_RPA<-cbind(RAD51_RPA, myrep)
colnames(RAD51_RPA)[ncol(RAD51_RPA)] <- "SMC5"

BRCA1<-cbind(BRCA1, myrep)
colnames(BRCA1)[ncol(BRCA1)] <- "RAD51"
BRCA1<-cbind(BRCA1, myrep)
colnames(BRCA1)[ncol(BRCA1)] <- "RPA"
BRCA1<-cbind(BRCA1, myrep)
colnames(BRCA1)[ncol(BRCA1)] <- "SMC5"

RPA<-cbind(RPA, myrep)
colnames(RPA)[ncol(RPA)] <- "RAD51"
RPA<-cbind(RPA, myrep)
colnames(RPA)[ncol(RPA)] <- "BRCA1"
RPA<-cbind(RPA, myrep)
colnames(RPA)[ncol(RPA)] <- "SMC5"

SMC5<-cbind(SMC5, myrep)
colnames(SMC5)[ncol(SMC5)] <- "RAD51"
SMC5<-cbind(SMC5, myrep)
colnames(SMC5)[ncol(SMC5)] <- "BRCA1"
SMC5<-cbind(SMC5, myrep)
colnames(SMC5)[ncol(SMC5)] <- "RPA"

RAD51<-cbind(RAD51, myrep)
colnames(RAD51)[ncol(RAD51)] <- "SMC5"
RAD51<-cbind(RAD51, myrep)
colnames(RAD51)[ncol(RAD51)] <- "BRCA1"
RAD51<-cbind(RAD51, myrep)
colnames(RAD51)[ncol(RAD51)] <- "RPA"

## combine data ##
all_data<-rbind(BRCA1_RPA_SMC5, BRCA1_RPA, RAD51_RPA_SMC5, RAD51_RPA, BRCA1, RPA, SMC5, RAD51, BRCA1_RPA_SMC5_RAD51)

cluster_data<-subset(all_data, select=-c(BRCA1, RPA, SMC5, RAD51))

clus<-hclust(dist(cluster_data))
b<-seq(-1,1, length.out=100)

pal1<-rep("#BEBEBE",49)
pal2<-colorRampPalette(c("white", "blue"))(n=50)

pal<-c(pal1, pal2)

idcols<-c("BRCA1", "RPA", "SMC5", "RAD51")
cols <- c(idcols, names(all_data)[-which(names(all_data) %in% idcols)])
all_data<-all_data[cols]

pdf("heat.pdf", height=35, width=10)
heatmap.2(as.matrix(all_data), col=pal, breaks=b, trace="none", notecol="black", cellnote=round(all_data,2), scale="none", Rowv=as.dendrogram(clus), margin=c(10,10), Colv=FALSE, dendrogram="row", key=FALSE)
dev.off()

# finding top hits
# corr on everything EXCEPT rad51, brca1, rpa, smc5

corr_dat<-cor(t(cluster_data))

# top states: 3,4,5,37,38

mat_3 <- as.matrix(corr_dat[corr_dat[,colnames(corr_dat) == "BRCA1_RPA_SMC5_3"] > corLimit,colnames(corr_dat) == "BRCA1_RPA_SMC5_3"])
mat_4 <- as.matrix(corr_dat[corr_dat[,colnames(corr_dat) == "BRCA1_RPA_SMC5_4"] > corLimit,colnames(corr_dat) == "BRCA1_RPA_SMC5_4"])
mat_5 <- as.matrix(corr_dat[corr_dat[,colnames(corr_dat) == "BRCA1_RPA_SMC5_5"] > corLimit,colnames(corr_dat) == "BRCA1_RPA_SMC5_5"])
mat_37 <- as.matrix(corr_dat[corr_dat[,colnames(corr_dat) == "BRCA1_RPA_SMC5_37"] > corLimit,colnames(corr_dat) == "BRCA1_RPA_SMC5_37"])
mat_38 <- as.matrix(corr_dat[corr_dat[,colnames(corr_dat) == "BRCA1_RPA_SMC5_38"] > corLimit,colnames(corr_dat) == "BRCA1_RPA_SMC5_38"])

#write.table(mat_3[order(mat_3[,1], decreasing=TRUE),], "replacement_3.txt", sep="\n",)
#write.table(mat_4[order(mat_4[,1], decreasing=TRUE),], "replacement_4.txt", sep="\n",)
#write.table(mat_5[order(mat_5[,1], decreasing=TRUE),], "replacement_5.txt", sep="\n",)
#write.table(mat_37[order(mat_37[,1], decreasing=TRUE),], "replacement_37.txt", sep="\n",)
#write.table(mat_38[order(mat_38[,1], decreasing=TRUE),], "replacement_38.txt", sep="\n",)

i1<-grep("BRCA1", colnames(all_data))
i2<-grep("RPA", colnames(all_data))
i3<-grep("SMC5", colnames(all_data))
i4<-grep("RAD51", colnames(all_data))

indicies<-c(i1,i2,i3,i4)

# 3
sub_data_3<-all_data[rownames(mat_3),indicies]
sub_data_3[sub_data_3 == -1] <- 100 # stupid way of dealing with -1 problem
high_3 <- sub_data_3[apply(sub_data_3, MARGIN=1, function(x) all(x > 0.5)),]
high_3_row<-rownames(high_3)

#4
sub_data_4<-all_data[rownames(mat_4),indicies]
sub_data_4[sub_data_4 == -1] <- 100 # stupid way of dealing with -1 problem
high_4 <- sub_data_4[apply(sub_data_4, MARGIN=1, function(x) all(x > 0.5)),]
high_4_row<-rownames(high_4)

#5
sub_data_5<-all_data[rownames(mat_5),indicies]
sub_data_5[sub_data_5 == -1] <- 100 # stupid way of dealing with -1 problem
high_5 <- sub_data_5[apply(sub_data_5, MARGIN=1, function(x) all(x > 0.5)),]
high_5_row<-rownames(high_5)

#37
sub_data_37<-all_data[rownames(mat_37),indicies]
sub_data_37[sub_data_37 == -1] <- 100 # stupid way of dealing with -1 problem
high_37 <- sub_data_37[apply(sub_data_37, MARGIN=1, function(x) all(x > 0.5)),]
high_37_row<-rownames(high_37)

#3
sub_data_38<-all_data[rownames(mat_38),indicies]
sub_data_38[sub_data_38 == -1] <- 100 # stupid way of dealing with -1 problem
high_38 <- sub_data_38[apply(sub_data_38, MARGIN=1, function(x) all(x > 0.5)),]
high_38_row<-rownames(high_38)

high_mat_3 <- as.matrix(mat_3[high_3_row,])
high_mat_4 <- as.matrix(mat_4[high_4_row,])
high_mat_5 <- as.matrix(mat_5[high_5_row,])
high_mat_37 <- as.matrix(mat_37[high_37_row,])
high_mat_38 <- as.matrix(mat_38[high_38_row,])

write.table(high_mat_3[order(high_mat_3[,1], decreasing=TRUE),], "replacement_3.txt", sep="\t",)
write.table(high_mat_4[order(high_mat_4[,1], decreasing=TRUE),], "replacement_4.txt", sep="\t",)
write.table(high_mat_5[order(high_mat_5[,1], decreasing=TRUE),], "replacement_5.txt", sep="\t",)
write.table(high_mat_37[order(high_mat_37[,1], decreasing=TRUE),], "replacement_37.txt", sep="\t",)
write.table(high_mat_38[order(high_mat_38[,1], decreasing=TRUE),], "replacement_38.txt", sep="\t",)
