#!/bin/bash

BLACKLIST="/home/arrajpur/data/mm9_blacklist.bed"
if [ $# -lt 1 ]
	then 
		echo -e "usage: $0 <bedfile of peaks> <BOOL 1 kb minimum? 0=n, 1=y>\n";
		exit 1
fi

peakfile=$1
bool=$2

bedtools intersect -f 0.5 -a $peakfile -b $BLACKLIST > $peakfile\.blacklisted

if [ `wc -l < $peakfile.blacklisted` -lt 1 ]
then
	cp $peakfile $peakfile\.blacklistrm.tmp
else
	bedtools intersect -v -a $peakfile -b $peakfile\.blacklisted > $peakfile\.blacklistrm.tmp
fi

bedtools intersect -a $peakfile\.blacklistrm.tmp -b $BLACKLIST > $peakfile\.someOverlap

cutPeaks.pl $peakfile\.blacklistrm.tmp $peakfile\.someOverlap > $peakfile\.blacklistrm

rm $peakfile\.blacklistrm.tmp
rm $peakfile\.blacklisted
rm $peakfile\.someOverlap


if [ $bool == 1 ]
	then
#		echo "1kb min"
		awk '{if ($3 - $2 > 1000) print;}' $peakfile\.blacklistrm > $peakfile\.blacklistrm.1kbmin
fi

