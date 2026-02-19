# Quick check if CmdStanR and CmdStan are installed
cat("Checking Stan installation...\n\n")

# Check if cmdstanr package is installed
if (!require("cmdstanr", quietly = TRUE)) {
  cat("cmdstanr package NOT installed.\n")
  cat("Please run: scripts/00_setup_stan.R first\n")
} else {
  cat("cmdstanr package is installed.\n")
  
  # Check if CmdStan is installed
  library(cmdstanr)
  
  if (!dir.exists(cmdstan_path())) {
    cat("\nCmdStan NOT found.\n")
    cat("Please run: scripts/00_setup_stan.R first\n")
  } else {
    cat("\nCmdStan is installed at:", cmdstan_path(), "\n")
    cat("CmdStan version:", cmdstan_version(), "\n")
    cat("\nReady to run 00_test_stan.R!\n")
  }
}
