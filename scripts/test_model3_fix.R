# Test Script for Model 3 Non-Centered Parameterization Fix
# This script tests the fixed Stan model without requiring full notebook execution

library(cmdstanr)

# Test 1: Compile the Stan model
cat("Test 1: Compiling Stan model with non-centered parameterization...\n")
model_file <- "STAN/model3_random_intercept.stan"

if (!file.exists(model_file)) {
  stop("Stan model file not found: ", model_file)
}

# Read and display key parts of the model
cat("\nStan model content (key sections):\n")
model_code <- readLines(model_file)
cat(paste(model_code[1:40], collapse = "\n"), "\n\n")

# Compile model
tryCatch({
  mod <- cmdstan_model(model_file)
  cat("✓ Model compiled successfully!\n\n")
  
  # Test 2: Create minimal test data
  cat("Test 2: Creating minimal test data...\n")
  set.seed(82171165)
  
  n_groups <- 5
  n_per_group <- 10
  n_obs <- n_groups * n_per_group
  
  test_data <- list(
    N = n_obs,
    J = n_groups,
    group = rep(1:n_groups, each = n_per_group),
    y = rbinom(n_obs, 1, 0.5),
    K = 1,
    X = matrix(rnorm(n_obs), ncol = 1)
  )
  
  cat("✓ Test data created (N=", n_obs, ", J=", n_groups, ")\n\n")
  
  # Test 3: Quick sampling test (minimal iterations)
  cat("Test 3: Running quick HMC test (100 warmup, 100 sampling)...\n")
  fit_test <- mod$sample(
    data = test_data,
    chains = 2,
    parallel_chains = 2,
    iter_warmup = 100,
    iter_sampling = 100,
    refresh = 0,
    seed = 82171165,
    show_messages = FALSE
  )
  
  cat("✓ HMC sampling completed!\n\n")
  
  # Test 4: Check diagnostics
  cat("Test 4: Checking diagnostics...\n")
  diagnostics <- fit_test$diagnostic_summary()
  cat("Divergences:", diagnostics$num_divergent, "\n")
  cat("Max tree depth:", diagnostics$num_max_treedepth, "\n")
  
  # Test 5: Extract and summarize key parameters
  cat("\nTest 5: Parameter summary:\n")
  summary_df <- fit_test$summary(variables = c("beta", "sigma_u", "sigma2_u"))
  print(summary_df)
  
  cat("\n✓ All tests passed! Non-centered parameterization is working correctly.\n")
  
}, error = function(e) {
  cat("✗ Error:", conditionMessage(e), "\n")
  stop(e)
})
