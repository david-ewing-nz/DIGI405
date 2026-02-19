
data {
  int<lower=0> N;              // Total number of observations
  int<lower=0> J;              // Number of groups
  array[N] int<lower=1,upper=J> group;  // Group ID for each observation
  array[N] int<lower=0,upper=1> y;      // Binary response
  int<lower=0> K;              // Number of predictors
  matrix[N,K] X;               // Predictor matrix
}

parameters {
  vector[K] beta;              // Fixed effects
  vector[J] u_raw;             // Random intercepts (non-centered parameterization)
  real<lower=0> sigma_u;       // SD of random intercepts (hyper-parameter)
}

transformed parameters {
  vector[J] u;                 // Actual random intercepts
  u = sigma_u * u_raw;         // Non-centered: u ~ N(0, sigma_u)
}

model {
  // Priors
  beta ~ normal(0, 5);
  sigma_u ~ cauchy(0, 2.5);    // Half-Cauchy prior for variance component
  u_raw ~ std_normal();        // Standard normal for non-centered parameterization
  
  // Likelihood
  y ~ bernoulli_logit(X * beta + u[group]);
}

generated quantities {
  real sigma2_u = sigma_u^2;   // Variance component
  real zeta = -log(sigma2_u);  // Log-transform for comparison
}

