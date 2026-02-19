# Quick check of Boston Housing dataset
library(MASS)
data(Boston)

cat("=== Boston Housing Dataset Check ===\n\n")

cat("Structure:\n")
str(Boston)

cat("\n\nDimensions:\n")
print(dim(Boston))

cat("\n\nFirst few rows:\n")
print(head(Boston))

cat("\n\nSummary:\n")
print(summary(Boston))

cat("\n\nMissing values per column:\n")
print(colSums(is.na(Boston)))

cat("\n\nColumn names and descriptions:\n")
cat("crim:    per capita crime rate\n")
cat("zn:      proportion of residential land zoned for lots over 25,000 sq.ft\n")
cat("indus:   proportion of non-retail business acres\n")
cat("chas:    Charles River dummy (1 if bounds river; 0 otherwise)\n")
cat("nox:     nitrogen oxides concentration (parts per 10 million)\n")
cat("rm:      average number of rooms per dwelling\n")
cat("age:     proportion of owner-occupied units built prior to 1940\n")
cat("dis:     weighted mean of distances to five Boston employment centres\n")
cat("rad:     index of accessibility to radial highways\n")
cat("tax:     full-value property-tax rate per $10,000\n")
cat("ptratio: pupil-teacher ratio by town\n")
cat("black:   1000(Bk - 0.63)^2 where Bk is the proportion of blacks\n")
cat("lstat:   lower status of the population (percent)\n")
cat("medv:    median value of owner-occupied homes in $1000s (TARGET)\n")
