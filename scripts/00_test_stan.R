# Test script to verify Stan installation
# Run this after 00_setup_stan.R to make sure everything works

library(cmdstanr)

cat("=== Testing Stan Installation ===\n\n")

# Create a simple test Stan model
test_model_code <- "
data {
  int<lower=0> N;
  vector[N] y;
}
parameters {
  real mu;
  real<lower=0> sigma;
}
model {
  mu ~ normal(0, 10);
  sigma ~ exponential(1);
  y ~ normal(mu, sigma);
}
"

# Write to a temporary file
test_file <- file.path(tempdir(), "test_model.stan")
writeLines(test_model_code, test_file)

cat("1. Compiling test model...\n")
mod <- cmdstan_model(test_file)

cat("\n2. Generating test data...\n")
set.seed(82171165)
test_data <- list(
  N = 100,
  y = rnorm(100, mean = 5, sd = 2)
)

cat("\n3. Running MCMC sampling...\n")
fit <- mod$sample(
  data = test_data,
  chains = 2,
  parallel_chains = 2,
  iter_warmup = 500,
  iter_sampling = 500,
  refresh = 100,
  show_messages = FALSE
)

cat("\n4. Checking results...\n")
fit$summary(c("mu", "sigma"))

cat("\n=== Stan Test Complete! ===\n")
cat("If you see parameter summaries above, Stan is working correctly.\n")
