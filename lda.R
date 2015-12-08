library(MASS)
library(caret)

file<-read.delim("lda_data.txt", header=T)
data<-as.data.frame(file)
data.t <- predict(preProcess(data, c("BoxCox", "center", "scale")), data)
r <- lda(formula = sample ~ .,
	data = data.t,
	prior = c(1,1)/2)

r
png("lda.png")
plot(r, col=as.integer(data$sample), pch=20, panel = function(x, y, ...) points(x, y, ...)) 
dev.off()

# plottin the lda:
# https://stat.ethz.ch/pipermail/r-help/2012-May/313988.html
#> png("lda.png")
#> plot(r, abbrev=TRUE, col=as.integer(data$sample))


