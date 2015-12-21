pairs.R - This file takes panel data on the S&P 500 constituents from CRSP and constructs pair-specific measures of the PNL that would be obtained from using a simple pairs trading strategy on that pair. This tab-delimited text file has header that looks like follows:

ticker	date	comnam	shrout	prc	retx
A	4-Jan-10	AGILENT TECHNOLOGIES INC	348831	31.3	0.007403
AA	4-Jan-10	ALCOA INC	974378	16.65	0.032878
AAPL	4-Jan-10	APPLE INC	906282	214.01	0.015555
ABC	4-Jan-10	AMERISOURCEBERGEN CORP	284892	26.63	0.021481
ABT	4-Jan-10	ABBOTT LABORATORIES	1546738	54.46	0.008705
ADBE	4-Jan-10	ADOBE SYSTEMS INC	522657	37.09	0.008429
ADI	4-Jan-10	ANALOG DEVICES INC	291862	31.67	0.00285
ADM	4-Jan-10	ARCHER DANIELS MIDLAND CO	642352	31.47	0.00511
ADP	4-Jan-10	AUTOMATIC DATA PROCESSING INC	502900	42.83	0.00023

The value of y (2010 or 2011) is specified in the beginning of the file; it should be run for both years. The resulting output is text files named pnl.2010.txt, pnl.2011.txt, x.data.2010.txt, and x.data.2011.txt.

pnl.graph.R - This file constructs the density graph shown in the slides and the paper, taking as inputs the files from pairs.R

xns.R and pct5.R - These files were not used in the current version but generate pairwise interactions for the x-variables and reduce the datasets to 5% samples.

logit.R - This file performs logit estimation on the output from pairs.R. The number of eigenvectors to use is specified in line 107.

euclid.cpp - This function performs k-nearest-neighbor estimation given input files and regressors. The input file for the dependent variable should be a binary version of the output from pairs.R (1 or 0 values and based upon either a 0.00 or 0.01 threshold). The input x files are the same as the output from pairs.R. These filenames are specified in lines 207-211.
