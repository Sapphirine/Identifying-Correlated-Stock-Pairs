require(data.table)
require(sm)

y2010 <- data.table(read.table('pnl.2010.txt',sep='\t',header=FALSE))
y2011 <- data.table(read.table('pnl.2011.txt',sep='\t',header=FALSE))

	y2010[,Year:=2010]
	y2011[,Year:=2011]

	y <- rbind(y2010,y2011)
	y[,Year:=factor(Year)]

	setnames(y,c("PNL","Year"))

png("pnl.density.png")

	sm.density.compare(y$PNL,y$Year,xlab="Return from Trading Strategy by Stock Pair")
	title(main="Distribution of Hypothetical PNL by Year")
	cofill <- c(2:(2+length(levels(y$Year))))
	legend("topright", inset=0.05, title="Year",legend = levels(y$Year), fill = cofill, horiz=FALSE)

dev.off()

sp500 <- data.table(read.table('sp500panel.txt',sep='\t',header=TRUE))

	sp500[,date:=as.Date(as.character(date),'%d-%b-%y')]
	sp500[,logret:=log(retx+1)]

	# perform this operation separately for
	# 2010 (training set) and 2011 (test set).
	sp500 <- sp500[,y:=factor(year(date))]

	# keep only those tickers with 100 obs in both years.
	sp500 <- sp500[!is.na(logret),]
	sp500[,n:=length(logret),by=list(ticker,y)]

	sp500 <- sp500[n==252]

png("yret.density.png")

	sm.density.compare(sp500$logret,sp500$y,xlab="Daily Return of Stock")
	title(main="Distribution of Stock Returns by Year")
	cofill <- c(2:(2+length(levels(sp500$y))))
	legend("topright", inset=0.05, title="Year",legend = levels(sp500$y), fill = cofill, horiz=FALSE)

dev.off()
