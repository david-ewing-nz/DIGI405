# Setup script for installing CmdStanR and CmdStan
# Run this once to get Stan working with your R environment

# Install cmdstanr from the Stan repository
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))

# Load the package
library(cmdstanr)

# Check if CmdStan is already installed
if (!dir.exists(cmdstan_path())) {
  cat("CmdStan not found. Installing CmdStan...\n")
  install_cmdstan(cores = 2)  # Adjust cores based on your system
} else {
  cat("CmdStan is already installed at:", cmdstan_path(), "\n")
}

# Verify the installation
cmdstan_version()

# Optional: Check C++ toolchain
check_cmdstan_toolchain()

cat("\n=== Stan Setup Complete ===\n")
cat("CmdStanR and CmdStan are ready to use!\n")
