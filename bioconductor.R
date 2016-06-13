# bioconductor RNAseq processing #

# get bam files
filenames <- file.path("~/raw-data/GSE43504/RNAseq/bams", c("HU_rep1.bam", "HU_rep2.bam", "NT_rep1.bam", "NT_rep2.bam"))

# get csv metadata file
csvfile <- file.path("~/", "RNAseq_data.csv")

# parse csv file
(sampleTable <- read.csv(csvfile,row.names=1))

library("Rsamtools")

# FIXME check if yieldSize affects any downstream calculations
bamfiles<-BamFileList(filenames, yieldSize=2000000)

library("GenomicFeatures")

# get gene file
gtffile<-file.path("~/", "newNamesRefseqAll.gtf")

# parse into objects
(txdb <- makeTxDbFromGFF(gtffile, format="gtf", circ_seqs=character()))
(ebg <- exonsBy(txdb, by="gene"))

library("GenomicAlignments")
library("BiocParallel")
register(SerialParam())

# make summary object
se <- summarizeOverlaps(features=ebg, reads=bamfiles,
                        mode="Union",
                        singleEnd=TRUE, # single ended reads
                        ignore.strand=TRUE,
                        fragments=FALSE ) # if singleEnd = TRUE, this = FALSE 

# assign metadata to correct slot in summary object
(colData(se) <- DataFrame(sampleTable))

library("DESeq2")

# create DESeq object testing treatment
dds <- DESeqDataSet(se, design = ~ treat)

# rlog the data (accounts for high and low gene transforms)
rld <- rlog(dds)

# Euclidean distance
# using this on rlogged data means that the distance is not dominated by a few highly variable genes
sampleDists <- dist( t( assay(rld) ) )

# Trying to use Pearson corr 
# sampleDistsCor <- corDist( t( assay(rld) ) , method="pearson")

library("pheatmap")
library("RColorBrewer")

sampleDistMatrix <- as.matrix( sampleDists )
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)

pdf("Euclidean_heatmap.pdf")
pheatmap(sampleDistMatrix,
         clustering_distance_rows=sampleDists, # use manually calculated values
         clustering_distance_cols=sampleDists, # So we don't get every gene against every sample
         col=colors)
dev.off()

# Poisson distance
# takes into account variance of low and high
# DO NOT INPUT NORMALIZED COUNTS
# aka NO RLOG

library("PoiClaClu")

poisd <- PoissonDistance(t(counts(dds)))
samplePoisDistMatrix <- as.matrix( poisd$dd )

pdf("Poisson_heatmap.pdf")
pheatmap(samplePoisDistMatrix,
         clustering_distance_rows=poisd$dd,
         clustering_distance_cols=poisd$dd,
         col=colors)
dev.off()

# PCA plot
# DEseq function
# prints nothing?
pdf("PCA.pdf")
plotPCA(rld, intgroup = c("treat"))
dev.off()

# Analyzing differential expression
# rearrange the factor so we calculate log2 fold change of HU / NT or else R will do it alphabetically
dds$treat <- relevel(dds$treat, "NT")

# pipeline
dds <- DESeq(dds)

# get results
(res <- results(dds))

# summarize results
summary(res)

# simple MAplot
pdf("Simple_MA.pdf")
plotMA(res, ylim=c(-5,5))
dev.off()

# p-value histogram
pdf("p_val_hist_all.pdf")
hist(res$pvalue, breaks=20, col="grey50", border="white")
dev.off()

# p-value histogram excluding extremely low count genes
pdf("p_val_hist_excl_low_count.pdf")
hist(res$pvalue[res$baseMean > 1], breaks=20, col="grey50", border="white")
dev.off()

# PCA plot
# DEseq function
# prints now?
pdf("PCA2.pdf")
plotPCA(rld, intgroup = c("treat"))
dev.off()

# highly variable genes heatmap
library("genefilter")

topVarGenes <- head(order(-rowVars(assay(rld))),20)
mat <- assay(rld)[ topVarGenes, ]
mat <- mat - rowMeans(mat)
df <- as.data.frame(colData(rld)[ "treat" ])

pdf("gene_heatmap.pdf")
pheatmap(mat, annotation_col=df)
dev.off()

# modified MAnorm plot (-1.5 <, > 1.5 only considered significant)
resGA<-results(dds, lfcThreshold=1.5, altHypothesis="greaterAbs")

pdf("modified_MA.pdf")
plotMA(resGA, ylim=c(-5,5))
abline(h=c(-1.5, 1.5), col="dodgerblue",lwd=2)
dev.off()

