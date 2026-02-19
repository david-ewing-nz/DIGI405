# Stan Installation and Setup Guide

This guide will help you install CmdStanR and CmdStan for your VI1 project.

## Prerequisites

1. **R and RStudio** - Already installed ✓
2. **C++ Toolchain** - Required for compiling Stan models:
   - **Windows**: RTools (download from https://cran.r-project.org/bin/windows/Rtools/)
   - Make sure to check "Add rtools to system PATH" during installation

## Installation Steps

### Step 1: Install RTools (Windows)

1. Download RTools from: https://cran.r-project.org/bin/windows/Rtools/
2. Run the installer
3. **Important**: Check the box "Add rtools to system PATH"
4. Restart RStudio after installation

### Step 2: Install CmdStanR

In RStudio, run:

```r
source("scripts/00_setup_stan.R")
```

This script will:
- Install the `cmdstanr` package
- Download and compile CmdStan
- Verify the installation

**Note**: The first installation takes 5-15 minutes as it compiles CmdStan.

### Step 3: Test Your Installation

Run:

```r
source("scripts/00_test_stan.R")
```

If you see parameter summaries at the end, Stan is working correctly!

## Common Issues

### Issue: "C++ toolchain not found"
**Solution**: Install RTools and make sure it's added to your PATH. Restart RStudio.

### Issue: "cmdstan_path() not found"
**Solution**: Run `install_cmdstan()` manually:
```r
library(cmdstanr)
install_cmdstan(cores = 2)
```

### Issue: Compilation errors
**Solution**: Make sure you have enough disk space (~2GB) and a stable internet connection.

## Verify Installation

After installation, you should be able to run:

```r
library(cmdstanr)
cmdstan_version()  # Should show version number
```

## Next Steps

Once Stan is installed, you can:

1. Run the Model 1 linear regression examples (synthetic and mtcars)
2. Compare VB vs Stan/NUTS posteriors
3. Quantify under-dispersion

## Files Created

- `scripts/00_setup_stan.R` - Installation script
- `scripts/00_test_stan.R` - Test script
- `STAN/linear_regression.stan` - Your first Stan model for Model 1

## Resources

- CmdStanR Documentation: https://mc-stan.org/cmdstanr/
- Stan User's Guide: https://mc-stan.org/docs/stan-users-guide/
- Stan Functions Reference: https://mc-stan.org/docs/functions-reference/
