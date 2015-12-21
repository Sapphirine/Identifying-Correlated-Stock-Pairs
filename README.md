# Identifying-Correlated-Stock-Pairs
This study aims to predict stocks that can be used for profitable pairs trading strategies.

# Project ID: 201512-77

# Columbia UNI: car2228

# Team Members:

Christopher Rohlfs car2228@columbia.edu

# Project Title: Identifying Correlated Stock Pairs

# Project Industry Area: Finance

# Project Goals Description:

Pairs trading is a well-established statistical aribtrage technique that involves identifying "mean reverting" pairs of stocks. The correlation between the two stocks' returns is estimated over the recent history. The trader supposes that any sharp movement that departs from this historical relationship is attributable to a temporary mispricing that will be corrected in the market. Hence, if stock x rises relative to y, then the researcher shorts x and buys y until the prices return to their stable relationship.

The question of how to identify correlated pairs represents a major gap in the literature on pairs trading. Historically, researchers simply pick the stocks of companies with similar characteristics, such as Conoco-Phillips and Exxon-Mobil, or they search for stocks with high correlations. There is little evidence, however, to suggest that correlated stock pairs are the ones for which pairs trading strategies are the most profitable.

To address this limitation in the literature, I construct a new dataset in which the level of observation is the stock pair and the outcome of interest is the profitability of a simple pairs trading strategy using those two stocks. I then use Machine Learning techniques to identify which pairs of stocks would lead to the most profitable trading strategies.

# Project Dataset Description:

The data that I used are from the Center for Research on Stock Prices (CRSP). These data include daily closing prices for different stocks. I selected all companies that were constituents of the S&P 500 Index over the period from 2010 to 2011. I used 2010 as the training period and 2011 as the test period. For each year, I included only companies with data for every trading day. Tickers (to identify company identities) and stock returns were the only data sources used in this project.

These data are not public, but many universities including Columbia purchase subscriptions to them. Interested researchers can request access from the reference librarians in the Business School. I downloaded them from the CRSP website, where one can name the relevant stocks or simply request all of the S&P 500 Constituents. I actually named the ones I wanted in my data request based upon public lists of the S&P 500 constituents.

The algorithms I use can be applied to any dataset of stock pairs, which can be constructed from any time-series on multiple stocks.

# Language/Platform Description:

Data cleaning performed in R. Classification algorithms coded in R and C++.

# Analytics Algorithms Description:

Much of the coding involved in this project was to construct the dataset of profitability for each stock pair---which involved running an algorithm on a year of data each pair of stocks in the data (roughly 115,000 for each year). This data cleaning was performed in R.

I looked into using Mahout, but given the large number of continuous regressors in my model, Naive Bayes didn't make sense, so I focused on two alternative methods: Logistic regression and K-nearest neighbor estimation. Rather than SGD, I used Newton's method for the Logistic regression, which I coded in R. For the K-nearest neighbor estimation, I used a Euclidean distance metric, which I coded in C++. I also looked into using the Perceptron algorithm (coded in C++), but the program was prohibitively slow, so I did obtain results from that method.
