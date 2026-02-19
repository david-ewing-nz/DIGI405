// Logistic regression model for Model 2
// Bayesian logistic regression with normal priors

data {
  int<lower=0> N;              // number of observations
  int<lower=0> K;              // number of predictors (including intercept)
  matrix[N, K] X;              // predictor matrix
  array[N] int<lower=0, upper=1> y;  // binary response variable
  
  // Prior hyperparameters
  vector[K] mu_beta;           // prior mean for beta
  real<lower=0> sigma_beta;    // prior sd for beta
}

parameters {
  vector[K] beta;              // regression coefficients
}

model {
  // Priors
  beta ~ normal(mu_beta, sigma_beta);
  
  // Likelihood
  y ~ bernoulli_logit(X * beta);
}

generated quantities {
  // Posterior predictive samples and log likelihood
  array[N] int y_rep;
  vector[N] log_lik;
  
  for (n in 1:N) {
    real eta = X[n] * beta;
    y_rep[n] = bernoulli_logit_rng(eta);
    log_lik[n] = bernoulli_logit_lpmf(y[n] | eta);
  }
}
