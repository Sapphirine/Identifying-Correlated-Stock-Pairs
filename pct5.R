# make interactions from x.data
require(data.table)

	y <- data.table(read.table('pnl.2011.txt',sep='\t',header=FALSE))
	x <- data.table(read.table('x.data.2011.txt',sep='\t',header=FALSE))
	
	index <- 1:nrow(y)
	y <- y[index %% 20==0]
	x <- x[index %% 20==0]

	write.table(y,file='pnl.pct5.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE)
	write.table(x,file='x.pct5.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE)

	xns <- copy(x)
	name.list <- copy(names(xns))

	for(i in 1:length(name.list)){
		for(j in i:length(name.list)){
			if(j==i){
				cat(paste0('i=',i,' j=',j,'\n'))
			}
			xns[,newvar:=get(name.list[i])*get(name.list[j])]
			setnames(xns,'newvar',paste(name.list[i],name.list[j],sep="X"))
		}
	}

	# convert xns to scaled data
	xns <- scale(xns)

saveRDS(xns,'xns.pct5.2011.rds')
write.table(xns,file='xns.pct5.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE)
