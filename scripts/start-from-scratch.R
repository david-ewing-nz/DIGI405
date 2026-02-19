# Setup script for Model 1 (Linear Regression VB vs HMC)
# Run this once on a fresh R installation to set up everything needed

# 1. CREATE FOLDER STRUCTURE
cat("Creating folder structure...\n")
dir.create("R", showWarnings = FALSE)
dir.create("scripts", showWarnings = FALSE)
dir.create("data_raw", showWarnings = FALSE)
dir.create("data_processed", showWarnings = FALSE)
dir.create("STAN", showWarnings = FALSE)
dir.create("results/linear", recursive = TRUE, showWarnings = FALSE)
dir.create("figs", showWarnings = FALSE)
dir.create("reference", showWarnings = FALSE)
dir.create("report", showWarnings = FALSE)

# 2. INSTALL REQUIRED PACKAGES
cat("\nInstalling required packages...\n")

# Core packages
install.packages(c(
  "tidyverse",     # Data manipulation and ggplot2
  "glue",          # String interpolation
  "MASS",          # Boston Housing dataset
  "knitr",         # For R Markdown
  "grid",          # For plot display
  "patchwork",     # Combining plots
  "gt"             # Modern tables
))

# Stan ecosystem
install.packages(c(
  "remotes",       # For GitHub installs
  "posterior",     # Posterior analysis
  "loo",           # Model comparison
  "bayesplot"      # Bayesian plotting
))

# CmdStanR (Stan interface)
remotes::install_github("stan-dev/cmdstanr")

# 3. SETUP CMDSTAN
cat("\nSetting up CmdStan...\n")
library(cmdstanr)

# Check C++ toolchain
install.packages("pkgbuild")
pkgbuild::check_build_tools(debug = TRUE)

# Install CmdStan binary
install_cmdstan()

# Verify installation
cmdstan_path()
cmdstan_version()

# 4. VERIFY LIBRARIES LOAD
cat("\nVerifying all libraries load correctly...\n")
library(tidyverse)
library(bayesplot)
library(cmdstanr)
library(glue)
library(grid)
library(knitr)
library(MASS)
library(patchwork)
library(posterior)
library(gt)

cat("\n=== SETUP COMPLETE ===\n")
cat("All packages installed and folders created.\n")
cat("You can now run Model1_Boston.Rmd\n")

