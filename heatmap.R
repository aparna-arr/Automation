library(reshape2)
library(gplots)
library(RColorBrewer)

args<-commandArgs(trailingOnly=TRUE)

file<-args[1]

data<-read.delim(file, header=T)
mat<-data.matrix(data[,2:ncol(data)-1])

vec<-as.vector(mat)
vec<-vec[vec > 0]

quartiles<-as.double(quantile(vec))

second_quartile<-quartiles[2]
median<-quartiles[3]
third_quartile<-quartiles[4]
mean<-mean(vec)
stdev<-sd(vec)

break1 = 0

if (second_quartile < median) {
	break1 = median
} else {
	break1 = second_quartile
}

break2 = third_quartile

break3 = 0

if (as.integer(mean + 1) > third_quartile) {  
	break3 = as.integer(mean + 1) 
} else if (mean > third_quartile) { 
		break3 = mean 
} else { 
	break3 = third_quartile * 2 
}


break4 = as.integer(mean + 1)*1.5

break1
break2
break3
break4

#col_breaks = c( seq(0, break1, length=50), seq(break1, break2, length=50), seq(break2, break3, length=50), seq(break3, break4, length=50))
col_breaks = c( seq(0, break1, length=50), seq(break1, break2, length=50), seq(break2, break3, length=50))
#col_breaks = c( seq(0, break2, length=50), seq(break2, break3, length=50), seq(break3, break4, length=50))

col_breaks <- unique(col_breaks)
my_palette<-colorRampPalette(c("white", "yellow", "orange", "red"), space="Lab")(n=length(col_breaks)-1)

# add actual plot in perl or bash script that handles this
