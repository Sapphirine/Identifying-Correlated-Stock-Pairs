require(data.table)
require(parallel)

# length of period over
# which regressions are
# estimated.
training.period <- 100

# year for which to run
y <- 2011

# thresholds for signal. buy/sell are
# values needed to start position, and
# endbuy/endsell are values needed to
# end position.
buy <- -2
sell <- 2
endbuy <- -0.25
endsell <- 0.25

# return trading signal (residual)
# for last day of returns from
# vecy, vecx time-series
signal <- function(vecy,vecx){
	lasty <- vecy[length(vecy)]
	vecy[length(vecy)] <- NA
	reg <- lm(vecy ~ vecx)
	resid <- predict(reg,newdata=data.table(vecx))[length(vecx)]
	sd.resid <- sd(reg$residuals)
	if(length(reg$coefficients)>1){
		beta <- reg$coefficients[2]
	} else {
		beta <- 1
	}
	output <- list(signal = resid/sd.resid, beta=beta)
	return(output)
}

# return full time-series of
# trading signals for a pair y,x
# assuming regression sample of len.
signal.series <- function(y,x,len){
	resids <- c()
	betas <- c()
	for(i in seq(1,length(y)-len)){
		rb <- signal(y[seq(i,i+len)],x[seq(i,i+len)])
		resid <- rb$signal		
		beta <- rb$beta
		resids <- c(resids,resid)
		betas <- c(betas,beta)
	}
	output <- list(signals = as.vector(resids), betas=as.vector(betas))
	return(output)
}

# read in trading signals (residuals) and
# return full set of positions
positions <- function(signals){
	pos <- rep(0,length(signals))
	for(i in 2:length(signals)){
		if(signals[i-1]<buy){
			pos[i] <- 1
		} else if(signals[i-1]>sell){
			pos[i] <- -1
		} else if(pos[i-1]==-1 & signals[i-1]<endbuy | pos[i-1]==1 & signals[i-1]>endsell){
			pos[i] <- 0
		} else {
			pos[i] <- pos[i-1]
		}
	}
	# positions are zero for training dates.
	pos <- c(rep(0,training.period),pos)
	return(pos)
}

# the position that we go long or short on
# provides returns of yret -beta*xret.
rets <- function(yret,xret,betas){
	betas <- c(rep(1,training.period),betas)
	return(yret-betas*xret)
}

# calculate pnl from positions strategy
# in percentage terms.
profit <- function(positions,returns){
	return(sum(positions*returns))
}

# obtain data on the returns observed
# by these stocks over the days in the
# regression period.
extract.x.data <- function(yret,xret){
	yxret <- c(yret,xret)
	yxret <- data.table(t(yxret))
	return(yxret)
}

sp500 <- data.table(read.table('sp500panel.txt',sep='\t',header=TRUE))

	sp500[,date:=as.Date(as.character(date),'%d-%b-%y')]
	sp500[,logret:=log(retx+1)]

	# perform this operation separately for
	# 2010 (training set) and 2011 (test set).
	sp500 <- sp500[year(date)==y,]

	# keep only those tickers with 100 obs in both years.
	sp500 <- sp500[!is.na(logret),]
	sp500[,n:=length(logret),by=list(ticker)]
	sp500 <- sp500[n==252]

	# make lists of all 500+ series of returns
	spret <- mclapply(
		unique(sp500$ticker),
			function(input){
				return(sp500[ticker==input]$logret)
			},
		mc.cores=12)

# when debugging, only examine first N tickers.
#	spret <- spret[1:50]

	# list of every i,j combination of possible
	# pairs we can trade.
	ijgrid <- data.table(expand.grid(j=1:length(spret),i=1:length(spret)))
	ijgrid <- ijgrid[j>i,]
	setcolorder(ijgrid,c('i','j'))

	# compute the profit for each i,j pair
	# using multicore.
	ij.profit <- function(index){
		i <- ijgrid[index]$i
		j <- ijgrid[index]$j
		# provide update on how far along we are.
		if(index %% 100==0){
			cat(paste0('profit, index=',index,', i=',i,' j=',j,'\n'))
		}
		signals <- signal.series(spret[[i]],spret[[j]],training.period)
		ret.series <- rets(spret[[i]],spret[[j]],signals$betas)
		pos.series <- positions(signals$signals)
		profit.series <- profit(pos.series,ret.series)
		return(profit.series)
	}
	pnl <- unlist(lapply(1:nrow(ijgrid),ij.profit))

# save both training and test labels for the outcomes.
# don't discretize yet, as we may want to change thresholds.
write.table(pnl,paste0("pnl.",y,".txt"),row.names=FALSE,col.names=FALSE,sep='\t')

	# in addition to the outcome (profit) values,
	# we want predictors --the returns over the
	# days before trading begins.

	# shorten time-series to first
	# training.period observations.
	spret <- mclapply(
		spret,
			function(input){
				return(input[1:training.period])
			},
		mc.cores=12)

	xy.predictors <- function(index){
		i <- ijgrid[index]$i
		j <- ijgrid[index]$j
		if(index %% 100==0){
			cat(paste0('x.data, index=',index,', i=',i,' j=',j,'\n'))
		}
		return(extract.x.data(spret[[j]],spret[[i]]))
	}
	x.data <- lapply(1:nrow(ijgrid),xy.predictors)
	x.data <- do.call(rbind,x.data)
write.table(x.data,paste0("x.data.",y,".txt"),row.names=FALSE,col.names=FALSE,sep='\t')
