library(caret)

featureSelectSeed<-function(data, corLimit=0.7, seed=1) {
	set.seed(1)

	dat<-featureSelect(data, corLimit)

	return(dat)
}

featureSelect<-function(data, corLimit=0.7) {
	workingData<-data

#	cat("printing working data\n")

#	print(head(workingData))
	corm<-cor(as.matrix(workingData))
	highCor<-findCorrelation(corm, cutoff=corLimit)
	
	if(length(highCor) == 0) {
		return(workingData)
	}

	index<-highCor[1]
	mat<-as.matrix(corm[corm[,index] > corLimit, index])
	toRemove<-rownames(as.matrix(mat[floor(runif(1, min=1, max=length(mat)+1)),]))

	cat("Removing ")
	print(toRemove)
	cat("\n")

#	toRemove<-noquote(toRemove)
	removeIndex = grep(paste("^", toRemove, "$", sep=""), colnames(workingData), perl=TRUE)
	
	workingData<-workingData[,-removeIndex]
#	print(toRemove)
#	print(head(workingData))	
#	workingData<-subset(workingData, select=-c(toRemove))

#	cat("printing workingData at end of func\n")
#	print(head(workingData))	

	featureSelect(workingData, corLimit)
}
