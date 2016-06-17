# 
# panels.R
# 
# Description: 
# 	creates panelcor plot from an input data.frame
# 	showing correlation heatmap, distribution, scatterplot
# 	very useful for quickly checking several datasets
#
# Usage: Use within an R interactive environment or as part of a script
# 	This is not standalone.
#
# Author: Aparna Rajpurkar (2015)
#
# NO GUARANTEE IS MADE OR ASSUMED.
#

panelcor = function(df, title = "Test") {
panel.cor <- function(x, y, digits=2, cex.cor)
{
	colors<-colorRampPalette(c("darkblue", "white", "darkred"))
	colors.palette<-colors(200)

	usr <- par("usr"); on.exit(par(usr))
	par(usr = c(0, 1, 0, 1))
#	r <- abs(cor(x, y, method="p", use="na.or.complete"))
	r <- cor(x, y, method="spearman", use="na.or.complete")

	val <- round( r * 100 + 100, 1)
	bgcolor<-colors.palette[val] 

#	names(usr)<-c("xleft", "xright", "ybottom", "ytop")
#	do.call(rect, c(col = bgcolor, as.list(usr)))

	  rect(par("usr")[1], par("usr")[3],
              par("usr")[2], par("usr")[4], col=bgcolor)

	txt <- format(c(r, 0.123456789), digits=digits)[1]
	test <- cor.test(x,y, method="spearman", use="na.or.complete")
	Signif <- ifelse(round(test$p.value,3)<0.001,"p<0.001",paste("p=",round(test$p.value,3)))  
	text(0.5, 0.25, paste("r=",txt), cex=2)
	text(.5, .75, Signif, cex=2)
}

panel.smooth<-function (x, y, col = "black", bg = NA, pch = 18, 
				    cex = 0.8, col.smooth = "red", span = 2/3, iter = 3, ...) 
{
	points(x, y, pch = ".", col = col, bg = bg, cex = cex)
	ok <- is.finite(x) & is.finite(y)
	if (any(ok)) 
		lines(stats::lowess(x[ok], y[ok], f = span, iter = iter), 
			 col = col.smooth, ...)
}

panel.hist <- function(x, ...)
{
	usr <- par("usr"); on.exit(par(usr))
	par(usr = c(usr[1:2], 0, 1.5) )
	h <- hist(x, plot = FALSE)
	breaks <- h$breaks; nB <- length(breaks)
	y <- h$counts; y <- y/max(y)
	rect(breaks[-nB], 0, breaks[-1], y, col="darkgreen", ...)
}

p = pairs(df,
		lower.panel=panel.smooth, upper.panel=panel.cor,diag.panel=panel.hist, cex=5, cex.main=2, cex.labels=2, main=title)
}
