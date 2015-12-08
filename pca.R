library(MASS)
library(devtools)
library(ggbiplot)
library(caret)
file<-read.delim("lda_data.txt", header=T)
data<-as.data.frame(file)


#data.n<-data
#data.n[data.n == 0] <- NA

#log.dat <- log(data.n[,1:length(data.n) - 1])
#data.n <- na.omit(data.n)
data.n <- data[,length(data)]

dat.t <- predict(preProcess(data, c("BoxCox", "center", "scale")), data)
dat.t<-dat.t[,1:length(dat.t) - 1]
dat.pca<-prcomp(dat.t)

print(dat.pca)

km<-kmeans(dat.t, centers=5)

var.explained = dat.pca$sdev^2 / sum(dat.pca$sdev^2) 

colors<-character(length(var.explained))
curr_sum <- 0
for (i in 1:length(var.explained)) {
	curr_sum <- curr_sum + var.explained[i]
	if (curr_sum < 0.90) {
		colors[i] <- c("red")
	} else {
		colors[i] <- c("grey")
	}
}


pdf("pca.pdf")

plot(dat.pca, type="l")

#ggbiplot(dat.pca, obs.scale=1, var.scale=1, groups=data.n, ellipse=TRUE, circle=TRUE) + scale_color_discrete(name='') + theme(legend.direction = 'horizontal', legend.position = 'top') + coord_cartesian(ylim=c(-5,5), xlim=c(-10, 10))

barplot(100*var.explained, las=2, xlab='PCs', names=seq(1:15), ylab='% Variance Explained', col=colors)

# no kmeans
ggbiplot(dat.pca, obs.scale=1, var.scale=1, groups=data.n, ellipse=TRUE, circle=TRUE) + scale_color_discrete(name='') + theme(legend.direction = 'horizontal', legend.position = 'top') + coord_cartesian(ylim=c(-10,10), xlim=c(-5, 15))

# include kmeans
ggbiplot(dat.pca, obs.scale=1, var.scale=1, groups=factor(km$cluster), ellipse=TRUE, circle=TRUE) + scale_color_discrete(name='') + theme(legend.direction = 'horizontal', legend.position = 'top') + coord_cartesian(ylim=c(-20,15), xlim=c(-10, 25))


#ggbiplot(dat.pca, obs.scale=1, var.scale=1, groups=data.n, ellipse=TRUE, circle=TRUE) + scale_color_discrete(name='') + theme(legend.direction = 'horizontal', legend.position = 'top') 

dev.off()
