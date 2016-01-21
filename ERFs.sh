#!/bin/bash

# Laura fastq files
# Data: drop box "b cell input"

# raw fastq files
BRCA1_rep1_raw_fastq=SRR648775.fastq
BRCA1_rep2_raw_fastq=SRR648776.fastq
RPA_rep1_raw_fastq=SRR648773.fastq
RPA_rep2_raw_fastq=SRR648774.fastq
SMC5_rep1_raw_fastq=SRR648777.fastq
SMC5_rep2_raw_fastq=SRR648778.fastq

WCE_rep1_raw_fastq="laura_1.fastq"
WCE_rep2_raw_fastq="laura_2.fastq"
WCE_rep3_raw_fastq="laura_3.fastq"
WCE_rep4_raw_fastq="laura_4.fastq"
WCE_rep5_raw_fastq="laura_5.fastq"

# mm9 bowtie index
BOWTIE_INDEX=~/bowtie2_index/mm9

# Adaptors fa list from Stella
ADAPTORS=adaptors_list.fa
LAURA_ADAPTORS=adaptors_laura.fa

# rep1 and rep2 trimmed fastq files
BRCA1_rep1_fastq=BRCA1_rep1.trim.fastq
BRCA1_rep2_fastq=BRCA1_rep1.trim.fastq
RPA_rep1_fastq=RPA_rep1.trim.fastq
RPA_rep2_fastq=RPA_rep1.trim.fastq
SMC5_rep1_fastq=RPA_rep1.trim.fastq
SMC5_rep2_fastq=RPA_rep1.trim.fastq

WCE_rep1_fastq=wce_rep1.fastq
WCE_rep2_fastq=wce_rep2.fastq
WCE_rep3_fastq=wce_rep3.fastq
WCE_rep4_fastq=wce_rep4.fastq
WCE_rep5_fastq=wce_rep5.fastq

# rep1 and rep2 bam files
BRCA1_rep1_bam=BRCA1_rep1.trim.fastq.bam
BRCA1_rep2_bam=BRCA1_rep2.trim.fastq.bam
RPA_rep1_bam=RPA_rep1.trim.fastq.bam
RPA_rep2_bam=RPA_rep2.trim.fastq.bam
SMC5_rep1_bam=SMC5_rep1.trim.fastq.bam
SMC5_rep2_bam=SMC5_rep2.trim.fastq.bam

WCE_rep1_bam=wce_rep1.bam
WCE_rep2_bam=wce_rep2.bam
WCE_rep3_bam=wce_rep3.bam
WCE_rep4_bam=wce_rep4.bam
WCE_rep5_bam=wce_rep5.bam

# merge bam files
BRCA1_bam=BRCA1_merge.bam
RPA_bam=RPA_merge.bam
SMC5_bam=SMC5_merge.bam

WCE_bam=WCE_merge.bam

# sam files
BRCA1_sam=BRCA1_merge.sam
RPA_sam=RPA_merge.sam
SMC5_sam=SMC5_merge.sam

WCE_sam=WCE_merge.sam

# binned files
BRCA1_bin=BRCA1_merge_10bp_bin.bedgraph
RPA_bin=RPA_merge_10bp_bin.bedgraph
SMC5_bin=SMC5_merge_10bp_bin.bedgraph

WCE_bin=WCE_merge_10bp_bin.bedgraph

# broadpeak files
BRCA1_broad=BRCA1/BRCA1_broad_peak_unsupervised/BRCA1_broad_peak_unsuperivised.bed 
RPA_broad=RPA/RPA_broad_peak_unsupervised/RPA_broad_peak_unsupervised.bed
SMC5_broad=SMC5/SMC5_broad_peak_unsupervised/SMC5_broad_peak_unsupervised.bed

WCE_broad=WCE/WCE_broad_peak_unsupervised/WCE_broad_peak_unsupervised.bed

# PeakSplitter directory
PeakSplitterDir=PeakSplitter_Cpp/PeakSplitter_Linux64/

# peaksplit files
BRCA1_peaksplit=BRCA1_split.bed
RPA_peaksplit=RPA_split.bed
SMC5_peaksplit=SMC5_split.bed

WCE_peaksplit=WCE_split.bed

# read files 
BRCA1_reads=BRCA1_merge_4col_reads.bed
RPA_reads=RPA_merge_4col_reads.bed
SMC5_reads=SMC5_merge_4col_reads.bed
WCE_reads=WCE_merge_4col_reads.bed

# MAnorm xls files
BRCA1_xls=BRCA1_peaksplit_WCE_result.xls
RPA_xls=RPA_xls_peaksplit_WCE_result.xls
SMC5_xls=SMC5_xls_peaksplit_WCE_result.xls

# trim fastq files
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 $ADAPTORS $BRCA1_rep1_raw_fastq > $BRCA1_rep1_fastq 
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 $ADAPTORS $BRCA1_rep2_raw_fastq > $BRCA1_rep2_fastq 
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 $ADAPTORS $RPA_rep1_raw_fastq > $RPA_rep1_fastq 
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 $ADAPTORS $RPA_rep2_raw_fastq > $RPA_rep2_fastq 
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 $ADAPTORS $SMC5_rep1_raw_fastq > $SMC5_rep1_fastq 
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 $ADAPTORS $SMC5_rep2_raw_fastq > $SMC5_rep2_fastq 

# NOTE: in original, the adaptor list was ONLY the laura adaptors, and the -l was used
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 -l 35 $LAURA_ADAPTORS $WCE_rep1_raw_fastq > $WCE_rep1_fastq 
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 -l 35 $LAURA_ADAPTORS $WCE_rep2_raw_fastq > $WCE_rep2_fastq 
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 -l 35 $LAURA_ADAPTORS $WCE_rep3_raw_fastq > $WCE_rep3_fastq 
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 -l 35 $LAURA_ADAPTORS $WCE_rep4_raw_fastq > $WCE_rep4_fastq 
./fastq-mcf -C 10000000 -u -x 0.01 -q 25 -l 35 $LAURA_ADAPTORS $WCE_rep5_raw_fastq > $WCE_rep5_fastq 

# convert fastq to bam
bowtie2 -x $BOWTIE_INDEX -U $BRCA1_rep1_fastq -S tmpsam
samtools view -bS tmpsam > $BRCA1_rep1_bam
rm tmpsam 
bowtie2 -x $BOWTIE_INDEX -U $BRCA1_rep2_fastq -S tmpsam
samtools view -bS tmpsam > $BRCA1_rep2_bam
rm tmpsam 

bowtie2 -x $BOWTIE_INDEX -U $RPA_rep1_fastq -S tmpsam
samtools view -bS tmpsam > $RPA_rep1_bam
rm tmpsam 
bowtie2 -x $BOWTIE_INDEX -U $RPA_rep2_fastq -S tmpsam
samtools view -bS tmpsam > $RPA_rep2_bam
rm tmpsam 

bowtie2 -x $BOWTIE_INDEX -U $SMC5_rep1_fastq -S tmpsam
samtools view -bS tmpsam > $SMC5_rep1_bam
rm tmpsam 
bowtie2 -x $BOWTIE_INDEX -U $SMC5_rep2_fastq -S tmpsam
samtools view -bS tmpsam > $SMC5_rep2_bam
rm tmpsam 

bowtie2 -x $BOWTIE_INDEX -U $WCE_rep1_fastq -S tmpsam
samtools view -bS tmpsam > $WCE_rep1_bam
rm tmpsam 
bowtie2 -x $BOWTIE_INDEX -U $WCE_rep2_fastq -S tmpsam
samtools view -bS tmpsam > $WCE_rep2_bam
rm tmpsam 
bowtie2 -x $BOWTIE_INDEX -U $WCE_rep3_fastq -S tmpsam
samtools view -bS tmpsam > $WCE_rep3_bam
rm tmpsam 
bowtie2 -x $BOWTIE_INDEX -U $WCE_rep4_fastq -S tmpsam
samtools view -bS tmpsam > $WCE_rep4_bam
rm tmpsam 
bowtie2 -x $BOWTIE_INDEX -U $WCE_rep5_fastq -S tmpsam
samtools view -bS tmpsam > $WCE_rep5_bam
rm tmpsam 

# merge rep1 and rep2 bam files
samtools merge -f $BRCA1_bam $BRCA1_rep1_bam $BRCA1_rep2_bam
samtools merge -f $RPA_bam $RPA_rep1_bam $RPA_rep2_bam
samtools merge -f $SMC5_bam $SMC5_rep1_bam $SMC5_rep2_bam

samtools merge -f $WCE_bam $WCE_rep1_bam $WCE_rep2_bam $WCE_rep3_bam $WCE_rep4_bam $WCE_rep5_bam

# convert bam files to sam files
samtools view -h $BRCA1_bam > $BRCA1_sam
samtools view -h $RPA_bam > $RPA_sam
samtools view -h $SMC5_bam > $SMC5_sam

samtools view -h $WCE_bam > $WCE_sam

# bin files
./read_depth.pl 10 1 $BRCA1_sam > $BRCA1_bin
./read_depth.pl 10 1 $RPA_sam > $RPA_bin
./read_depth.pl 10 1 $SMC5_sam > $SMC5_bin

./read_depth.pl 10 1 $WCE_sam > $WCE_bin

# clean bedgraphs
./clean_bedgraphs.pl $BRCA1_bin BRCA1 mm9.chrom
./clean_bedgraphs.pl $RPA_bin RPA mm9.chrom
./clean_bedgraphs.pl $SMC5_bin SMC5 mm9.chrom

./clean_bedgraphs.pl $WCE_bin WCE mm9.chrom

# run BroadPeak 
BroadPeak -i $BRCA1_bin  -m BRCA1 -g 2725765481 -t unsupervised -b 10
BroadPeak -i $RPA_bin  -m RPA -g 2725765481 -t unsupervised -b 10
BroadPeak -i $SMC5_bin  -m SMC5 -g 2725765481 -t unsupervised -b 10

BroadPeak -i $WCE_bin  -m WCE -g 2725765481 -t unsupervised -b 10

# run PeakSplitter 
$PeakSplitterDir/PeakSplitter -p $BRCA1_broad -w $BRCA1_broad -o . -u http://www.ensembl.org/~Cm38.reference/ -n 0
cut -f 1,2,3 BRCA1_broad_peak_unsupervised.subpeaks.bed > $BRCA1_peaksplit

$PeakSplitterDir/PeakSplitter -p $RPA_broad -w $RPA_broad -o . -u http://www.ensembl.org/~Cm38.reference/ -n 0
cut -f 1,2,3 RPA_broad_peak_unsupervised.subpeaks.bed > $RPA_peaksplit

$PeakSplitterDir/PeakSplitter -p $SMC5_broad -w $SMC5_broad -o . -u http://www.ensembl.org/~Cm38.reference/ -n 0
cut -f 1,2,3 SMC5_broad_peak_unsupervised.subpeaks.bed > $SMC5_peaksplit

$PeakSplitterDir/PeakSplitter -p $WCE_broad -w $WCE_broad -o . -u http://www.ensembl.org/~Cm38.reference/ -n 0
cut -f 1,2,3 SMC5_broad_peak_unsupervised.subpeaks.bed > $WCE_peaksplit

# get reads
bamToBed -i $BRCA1_bam | cut -f 1,2,3,6 - > $BRCA1_reads
bamToBed -i $RPA_bam | cut -f 1,2,3,6 - > $RPA_reads
bamToBed -i $SMC5_bam | cut -f 1,2,3,6 - > $SMC5_reads

bamToBed -i $WCE_bam | cut -f 1,2,3,6 - > $WCE_reads

# run MAnorm for all three proteins
./MAnorm.sh $BRCA1_peaksplit $WCE_peaksplit $BRCA1_reads $WCE_reads 25 25
mv MAnorm_result.xls $BRCA1_xls

./MAnorm.sh $RPA_peaksplit $WCE_peaksplit $RPA_reads $WCE_reads 25 25
mv MAnorm_result.xls $RPA_xls

./MAnorm.sh $SMC5_peaksplit $WCE_peaksplit $SMC5_reads $WCE_reads 25 25
mv MAnorm_result.xls $SMC5_xls

# pre/post merge cutoffs and min length
PREMERGE=5000
POSTMERGE=300000
MIN=1000

# M and P value cut offs
M=2
P=2

# perform M and P value cutoff filter on all xls files
awk -v Mval=$M -v Pval=$P '{if (($4 == "unique_peak1" || $4 == "common_peak1") && $7 > Mval && $9 > Pval) print $1 "\t" $2 "\t" $3;}' $BRCA1_xls > $BRCA1_xls\.filter 
awk -v Mval=$M -v Pval=$P '{if (($4 == "unique_peak1" || $4 == "common_peak1") && $7 > Mval && $9 > Pval) print $1 "\t" $2 "\t" $3;}' $RPA_xls > $RPA_xls\.filter 
awk -v Mval=$M -v Pval=$P '{if (($4 == "unique_peak1" || $4 == "common_peak1") && $7 > Mval && $9 > Pval) print $1 "\t" $2 "\t" $3;}' $SMC5_xls > $SMC5_xls\.filter 

# sort and apply pre merge
sort -k 1,1 -k 2,2n $BRCA1_xls\.filter | bedtools merge -d $PREMERGE -i - > tmp 
mv tmp $BRCA1_xls\.filter

sort -k 1,1 -k 2,2n $RPA_xls\.filter | bedtools merge -d $PREMERGE -i - > tmp 
mv tmp $RPA_xls\.filter

sort -k 1,1 -k 2,2n $SMC5_xls\.filter | bedtools merge -d $PREMERGE -i - > tmp 
mv tmp $SMC5_xls\.filter

# intersect all three files and apply post merge and min length filter
bedtools intersect -a $BRCA1_xls\.filter -b $RPA_xls\.filter > tmp
bedtools intersect -a tmp -b $SMC5_xls\.filter | sort -k 1,1 -k 2,2n | bedtools merge -d $POSTMERGE -i - | awk -v len=$MIN '{if ($3 - $2 > len) print $1 "\t" $2 "\t" $3}' > AltERFs.bed
rm tmp
