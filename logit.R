require(data.table)

# given beta, x, and tstar (notation from Maddala's textbook),
# compute the next Newton iteration of the logit MLE using
# the analytical derivatives.
newton <- function(beta,x,tstar){
        # convert to matrix for matrix multiplication.
        x <- as.matrix(x)
        exb <- exp(x %*% beta)

        # back to data.table for element-wise multiplication
        x <- data.table(x) 
        # multiply x by function of exb . . .
        xicoeff <- as.matrix(x*sqrt(exb)/(1+exb))
        # then compute x'x to get information matrix.
        fisher <- t(xicoeff) %*% xicoeff

        # different multiplication to get score.
        exbx <- x*(1-1/((1+exb)))
        # the score vector in the likelihood.
        score <- tstar -colSums(exbx)

        # Newton-Raphson iteration based upon analytical derivatives.
        return(beta + solve(fisher) %*% score)
}

logL <- function(beta,x,tstar){
        x <- as.matrix(x)
        exb1 <- log(1 + exp(x %*% beta))
        return(t(beta) %*% tstar -sum(exb1))
}

# loop through iterations of newton's method.
implement.newton <- function(beta.old,x,tstar,threshold,maxIter){
        iteration <- 0
        increment <- Inf
        beta.new <- beta.old
        logL.old <- logL(beta.old,x,tstar)
        logL.new <- logL.old
        while(increment > threshold & iteration < maxIter){
                beta.old <- beta.new
                logL.old <- logL.new
                beta.new <- newton(beta.old,x,tstar)
                logL.new <- logL(beta.new,x,tstar)
                iteration <- iteration+1
                cat(paste('completed iteration',iteration,'\n'))
                cat(paste('(1/n)*Log Likelihood is',logL.new,'\n'))
                increment <- logL.new -logL.old
        }
        return(beta.new)
}

logit.betas <- function(x.train,y.train,threshold,maxIter){
        beta0 <- rep(0,ncol(x.train))
        tstar <- colSums(x.train[y.train==1,])
        return(implement.newton(beta0,x.train,tstar,threshold,maxIter))
}

logit.classify <- function(x.test,beta){
        x.test <- as.matrix(x.test)
        exb <- exp(x.test %*% beta)

        py.b <- as.numeric(exb/(1+exb))

        py <- rep(0,length(py.b))

        if(length(py)>1){
                py[py.b>=0.5] <- 1
                return(py)
        } else if(py.b>=0.5){
                return(1)
        } else {
                return(0)
        }
}

classify_test <- function(x.test,b){
        x.test.pca <- as.matrix(x.test) %*% eigs
        x.test.pca <- cbind(rep(1,nrow(x.test.pca)),x.test.pca)
        return(logit.classify(x.test.pca,b))
}

y.train <- data.table(read.table('pnl.pct5.2010.txt',sep='\t',header=FALSE))
y.test <- data.table(read.table('pnl.pct5.2011.txt',sep='\t',header=FALSE))

# need to discretize our training data. 
y.train[V1<0.01,y:=0]
y.train[V1>=0.01,y:=1]
y.train <- y.train$y

y.test[V1<0.01,y:=0]
y.test[V1>=0.01,y:=1]
y.test <- y.test$y

# alternate commands for using un-interacted or interacted x-variables.
x.train <- data.table(read.table('xns.pct5.2010.txt',sep='\t',header=FALSE))
# x.train <- readRDS('xns.2010.rds')
x.test <- data.table(read.table('xns.pct5.2011.txt',sep='\t',header=FALSE))
# x.test <- readRDS('xns.2011.rds')

x.train <- scale(x.train)
x.test <- scale(x.test)

cov.train <- cov(x.train)
eigs <- eigen(cov.train)
# vary number of eigenvectors to use.
eigs <- eigs$vectors[,1:150]

x.train.pca <- as.matrix(x.train) %*% eigs
# add a constant for the regression
x.train.pca <- cbind(rep(1,nrow(x.train.pca)),x.train.pca)

b <- logit.betas(x.train.pca,y.train,1e-10,30)

classes <- classify_test(x.test,b)
summary(classes)
table(classes,y.test)
