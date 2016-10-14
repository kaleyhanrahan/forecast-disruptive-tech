library(MASS)
library(car)
library(lars)

# We are trying to figure out Ridge and Lasso Regression for Dr. Gerber's class

data(Prestige)

##### Ridge Regression #####

# The base case of ridge parameter = 0 produces OLS results.
lm.fit = lm(prestige ~ ., data = Prestige)
summary(lm.fit)
lm.ridge.fit = lm.ridge(prestige ~ ., data = Prestige, lambda = 0)
lm.ridge.fit

# Try some actual ridge regression regularization levels.
lm.ridge(prestige ~ ., data = Prestige, lambda = c(0, 0.5, 1, 100))

##### Lasso Regression #####
lasso.predictors = as.matrix(Prestige[,-c(4,6)])
lasso.response = as.numeric(Prestige[,4])
lasso.fit = lars(lasso.predictors, lasso.response, type = "lasso")
coef(lasso.fit)
lasso.fit$lambda

# Will the lasso regression lambdas change if we rescale the predictors to [0,1]?
normalized.lasso.predictors = apply(lasso.predictors, 2, function(lasso.predictor)
{
  (lasso.predictor - min(lasso.predictor)) / (max(lasso.predictor) - min(lasso.predictor))
})

normalized.lasso.fit = lars(normalized.lasso.predictors, lasso.response, type = "lasso")
coef(normalized.lasso.fit)
normalized.lasso.fit$lambda # Answer:  No
