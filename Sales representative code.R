######################################################################################
#                                                                                    #
# This data records the performance of sales representatives using the yearly sales  #
# in the representative's territory. The sales manager also collects the number of   #
# months the representative has been employed by the company, the sales of the       #
# company's product and competing products in the territory, dollar advertising in   #
# the territory, weighted average of the company's market share in the territory     #
# over the previous four years, change in the company's market share in the          #
# territory over the previous four years, number of accounts handled by the          #
# representative, average workload per account, and an aggregate rating on several   #
# dimensions of the representative's performance.                                    #
#                                                                                    #
######################################################################################
#KALEY'S CHANGE

#################################
#                               #
# This code illustrates:        #
#   -Ridge regression           #
#   -Lasso regression           #
#   -Model selection techniques #
#   -Cross-validation           #
#                               #
#################################

## Read in the data
sdata <- read.table("C:/Users/gaf9f/Documents/6021 Fall 2016/In-class examples/Sales representative data.txt", header=TRUE)

## Check that the data have been read in correctly
sdata


## Multicollinearity
####################

## Correlation matrix
cor(sdata[,2:9])

## Run the linear regresion on all variables
s.lm <- lm(Sales~., data=sdata)

## Calculating VIF_i
library(car)
vif(s.lm)

## Put data into a matrix for ridge regression
sdata.m <- as.matrix(sdata)

## Ridge regression
###################

## Setting alpha=0 designates ridge regression
## This function automatically standardizes the explanatory variables
library(glmnet)
s.ridge <- glmnet(sdata.m[,2:9], sdata.m[,1], alpha=0, lambda=0.01)

## Ridge coefficicent estimates
coef(s.ridge)

## Ridge regression can also be done with several lambda values
## This procedure will yield a matrix of coefficients
s.ridge <- glmnet(sdata.m[,2:9], sdata.m[,1], alpha=0)

## Create the ridge trace plot
plot(s.ridge,xvar="lambda",label=TRUE)

## To see the lambda value that was used and the corresponding coefficients
s.ridge$lambda[20]
coef(s.ridge)[,20]

## Lasso regression
###################

## Lasso regression uses the same function as ridge regression with alpha=1
s.lasso <- glmnet(sdata.m[,2:9], sdata.m[,1], alpha=1)
s.lasso$lambda[20]
coef(s.lasso)[,20]

## Model selection
##################

## Comparative model selection
library(leaps)
bestmod <- regsubsets(Sales~., data=sdata, nbest=10)

## The 10 best models for each number of explanatory variables in the model
summary(bestmod)

## The criterion values corresponding to each model
summary(bestmod)$rss
summary(bestmod)$adjr2
summary(bestmod)$cp
summary(bestmod)$bic

## Iterative model selection
## Begin by defining the models with no variables (null) and all variables (full)
s.null <- lm(Sales~1, data=sdata)
s.full <- lm(Sales~., data=sdata)

## Forward selection
step(s.null, scope=list(lower=s.null, upper=s.full), direction="forward")

## Backward selection
step(s.full, scope=list(lower=s.null, upper=s.full), direction="backward")

## Stepwise selection
step(s.null, scope=list(lower=s.null, upper=s.full), direction="both")

## Cross-validation
###################

## Choose a model 
s.lm.test <- lm(Sales ~ Adver + MktPoten + MktShare + Change + Time, data=sdata)

## Split data into two groups and cross-validate
library("DAAG")
cv.lm(data=sdata, form.lm=s.lm.test, m=2, plotit=F)


