# Minimal M1 plot regeneration - loads saved density data and regenerates PNG only
library(tidyverse)
library(patchwork)
library(png)
library(grid)

# Check if we have the density data stored anywhere
source_dir <- "d:/github/VI1/R"
results_dir <- "d:/github/VI1/results"

cat("Looking for density data files...\n")

# List what's in results directory
result_files <- list.files(results_dir, pattern = "\\.rds$")
cat("Available .rds files:\n")
print(result_files)

# Try to find density data
if ("M1_density_data.rds" %in% result_files) {
  cat("\nLoading M1 density data...\n")
  density_data_list <- readRDS(file.path(results_dir, "M1_density_data.rds"))
  
  # Extract Gibbs and VB data
  gibbs_data <- density_data_list[grepl("Gibbs", names(density_data_list))]
  vb_data <- density_data_list[grepl("VB", names(density_data_list))]
  
  gibbs_df <- bind_rows(gibbs_data, .id = "config")
  vb_df <- bind_rows(vb_data, .id = "config")
  
  cat("Gibbs data rows:", nrow(gibbs_df), "\n")
  cat("VB data rows:", nrow(vb_df), "\n")
  
  # Create plots
  p_gibbs <- ggplot(gibbs_df, aes(x = tau_u, y = density, color = config)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = gibbs_df$true_tau_u[1], linetype = "dashed", color = "gray30", linewidth = 0.8) +
    labs(title = "Gibbs Sampling Posteriors", x = expression(tau[u]), y = "Density", color = "Config") +
    theme_minimal(base_size = 12)
  
  p_vb <- ggplot(vb_df, aes(x = tau_u, y = density, color = config)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = vb_df$true_tau_u[1], linetype = "dashed", color = "gray30", linewidth = 0.8) +
    labs(title = "VB Posteriors", x = expression(tau[u]), y = "Density", color = "Config") +
    theme_minimal(base_size = 12)
  
  # Combine with vertical legend on right
  combined <- (p_gibbs | p_vb) &
    theme(
      legend.position = "right",
      legend.direction = "vertical",
      legend.box = "vertical",
      legend.margin = margin(l = 10),
      plot.margin = margin(t = 15, r = 10, b = 10, l = 10)
    )
  
  # Save
  ggsave(
    filename = "../figs/M1_tau_u_overlay_comparison.png",
    plot = combined,
    width = 14,
    height = 7,
    dpi = 300
  )
  cat("✓ M1 plot saved\n")
} else {
  cat("\nM1_density_data.rds not found.\n")
  cat("Need to run full M1-Simple-Linear-Diagnostic.Rmd first.\n")
}
