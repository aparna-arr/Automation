#!/bin/bash

BLACKLIST="/home/arrajpur/data/mm9_blacklist.bed"
if [ $# -lt 1 ]
	then 
		echo -e "usage: $0 <bedfile of peaks>\n";
		exit 1
fi

peakfile=$1

bedtools intersect -f 0.5 -a $peakfile -b $BLACKLIST > $peakfile\.blacklisted

if [ `wc -l < $peakfile.blacklisted` -lt 1 ]
then
	cp $peakfile $peakfile\.blacklistrm.tmp
else
	bedtools intersect -v -a $peakfile -b $peakfile\.blacklisted > $peakfile\.blacklistrm.tmp
fi

#bedtools intersect -a $peakfile\.blacklistrm.tmp -b $BLACKLIST > $peakfile\.someOverlap

#cutPeaks.pl $peakfile\.blacklistrm.tmp $peakfile\.someOverlap > $peakfile\.blacklistrm

bedtools intersect -wao -a $peakfile\.blacklistrm.tmp -b $BLACKLIST > $peakfile\.someOverlap

newCutPeaks.pl $peakfile\.someOverlap > $peakfile\.blacklistrm

sort -k 1,1 -k 2,2n $peakfile\.blacklistrm > tmp 
mv tmp $peakfile\.blacklistrm

rm $peakfile\.blacklistrm.tmp
rm $peakfile\.blacklisted
rm $peakfile\.someOverlap


awk '{if ($3 - $2 > 1000) print;}' $peakfile\.blacklistrm > $peakfile\.blacklistrm.1kbmin

