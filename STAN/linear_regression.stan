// Linear regression model for Model 1
// Bayesian linear regression with conjugate Normal-Inverse-Gamma priors

data {
  int<lower=0> N;              // number of observations
  int<lower=0> K;              // number of predictors (including intercept)
  matrix[N, K] X;              // predictor matrix
  vector[N] y;                 // response variable
  
  // Prior hyperparameters (optional, with defaults)
  vector[K] mu_beta;           // prior mean for beta
  real<lower=0> sigma_beta;    // prior sd for beta
  real<lower=0> a_sigma;       // shape parameter for sigma prior
  real<lower=0> b_sigma;       // rate parameter for sigma prior
}

parameters {
  vector[K] beta;              // regression coefficients
  real<lower=0> sigma;         // residual standard deviation
}

model {
  // Priors
  beta ~ normal(mu_beta, sigma_beta);
  sigma ~ inv_gamma(a_sigma, b_sigma);
  
  // Likelihood
  y ~ normal(X * beta, sigma);
}

generated quantities {
  // Posterior predictive samples
  vector[N] y_rep;
  vector[N] log_lik;
  
  for (n in 1:N) {
    y_rep[n] = normal_rng(X[n] * beta, sigma);
    log_lik[n] = normal_lpdf(y[n] | X[n] * beta, sigma);
  }
}
