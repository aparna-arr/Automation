#!/bin/bash

if [ $# -lt 5 ]
	then
		echo -e "usage: $0 <window to smooth> <shift to smooth> <region length> <wig file> <processed bed file of peaks>\nIMPORTANT: This script runs heatmap.cpp which has NO ERROR CHECKING. If your bed files are bad it will simply crash (probably with segfault)!\n"
	exit 1
fi

args=($@)

window=${args[0]}
step=${args[1]}
regionLen=${args[2]}
wig=${args[3]}
R=~/github/utilities/heatmap.R

path=`pwd`

echo "window $window step $step regionLen $regionLen wig $wig R $R"

for ((i=4;i<$#;i++))
do
	echo ${args[$i]}
	heatmap $wig ${args[$i]}
	mv heatmap_outfile.txt ${args[$i]}.heatmap

	echo "Smoothing heatmap"
	smooth_heatmap.pl ${args[$i]}.heatmap $window $step

	echo "Sorting all"
	sort_heatmap.pl ${args[$i]}.heatmap.smooth all $regionLen > ${args[$i]}.heatmap.smooth.all
	cp $R ${args[$i]}.all.R
	echo -e "pdf(\"${args[$i]}.all.pdf\")" >> ${args[$i]}.all.R
	echo -e "heatmap.2(mat, main=\"${args[$i]}\nsort=all\", density.info=\"histogram\", trace=\"none\", col=my_palette, breaks=col_breaks, dendrogram=\"none\", Rowv=\"NA\", Colv=\"NA\", scale=\"none\", denscol=\"black\", labRow=FALSE, labCol=FALSE)" >> ${args[$i]}.all.R
	echo -e "dev.off()" >> ${args[$i]}.all.R

	Rscript ${args[$i]}.all.R ${args[$i]}.heatmap.smooth.all
	convert ${args[$i]}.all.pdf ${args[$i]}.all.png

	echo "Sorting center"
	sort_heatmap.pl ${args[$i]}.heatmap.smooth center $regionLen > ${args[$i]}.heatmap.smooth.center
	cp $R ${args[$i]}.center.R
	echo -e "pdf(\"${args[$i]}.center.pdf\")" >> ${args[$i]}.center.R
	echo -e "heatmap.2(mat, main=\"${args[$i]}\nsort=center\", density.info=\"histogram\", trace=\"none\", col=my_palette, breaks=col_breaks, dendrogram=\"none\", Rowv=\"NA\", Colv=\"NA\", scale=\"none\", denscol=\"black\", labRow=FALSE, labCol=FALSE)" >> ${args[$i]}.center.R
	echo -e "dev.off()" >> ${args[$i]}.center.R

	Rscript ${args[$i]}.center.R ${args[$i]}.heatmap.smooth.center
	convert ${args[$i]}.center.pdf ${args[$i]}.center.png
done

