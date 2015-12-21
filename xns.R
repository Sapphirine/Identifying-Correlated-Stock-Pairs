# make interactions from x.data
require(data.table)

	x <- data.table(read.table('x.data.2011.txt',sep='\t',header=FALSE))

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

saveRDS(xns,'xns.2011.rds')

write.table(xns[1:10000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE)
write.table(xns[10001:20000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[20001:30000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[30001:40000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[40001:50000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[50001:60000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[60001:70000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[70001:80000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[80001:90000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[90001:100000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[100001:110000,],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
write.table(xns[110001:dim(xns)[1],],file='xns.2011.txt',sep='\t',quote=FALSE,row.names=FALSE,col.names=FALSE,append=TRUE)
