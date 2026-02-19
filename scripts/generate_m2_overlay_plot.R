# Manual script to generate M2_tau_u_overlay_comparison.png
# This script extracts just the plot generation code

library(tidyverse)
library(patchwork)
library(png)
library(grid)

# Load results from saved RDS
results_file <- "results/M2_results_multi.rds"

if (!file.exists(results_file)) {
  stop("Results file not found at: ", results_file, 
       "\nM2 knitting may not have completed or saved results properly.")
}

cat("Loading M2 results from:", results_file, "\n")
results_multi <- readRDS(results_file)

# Set parameters
run_gibbs <- TRUE  # Assuming Gibbs was run
tau_u_true <- 1    # True value

# Create 2-panel overlay plot
if (run_gibbs) {
  gibbs_combined <- data.frame()
  
  for (i in seq_along(results_multi)) {
    result <- results_multi[[i]]
    config <- result$config
    gibbs_tau_u <- result$gibbs[, "tau_u"]
    
    dens_gibbs <- density(gibbs_tau_u, adjust = 1.5)
    
    df_temp <- data.frame(
      tau_u   = dens_gibbs$x,
      density = dens_gibbs$y,
      config  = config$label
    )
    
    gibbs_combined <- rbind(gibbs_combined, df_temp)
  }
  
  # Gibbs panel
  p_gibbs <- ggplot(gibbs_combined, aes(x = tau_u, y = density, color = config)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = tau_u_true, color = "red", linetype = "dotted", linewidth = 0.8) +
    scale_color_manual(
      values = c(
        "Q=5 (n=60 per group)"  = "gray50",
        "Q=10 (n=30 per group)" = "#d95f02",
        "Q=20 (n=15 per group)" = "#7570b3",
        "Q=50 (n=6 per group)"  = "#e7298a",
        "Q=100 (n=3 per group)" = "#1b9e77"
      )
    ) +
    coord_cartesian(xlim = c(0, 8), ylim = c(0, 2.5)) +
    labs(
      title = "Gibbs Sampling Posteriors",
      subtitle = "All configurations show similar distributions",
      x = expression(tau[u]),
      y = "Density",
      color = "Configuration"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      legend.position = "right",
      legend.text = element_text(size = 11, face = "bold"),
      legend.title = element_text(size = 12, face = "bold"),
      plot.title = element_text(size = 16, face = "bold"),
      plot.subtitle = element_text(size = 12),
      axis.text = element_text(size = 12, face = "bold"),
      axis.title = element_text(size = 13, face = "bold")
    )
}

# Prepare data for VB panel
vb_combined <- data.frame()

for (i in seq_along(results_multi)) {
  result <- results_multi[[i]]
  config <- result$config
  
  a_vb <- result$vb$a_u_new
  b_vb <- result$vb$b_u_new
  
  # Use broad range to show all VB distributions
  x_range <- seq(0, 20, length.out = 500)
  vb_density <- dgamma(x_range, shape = a_vb, rate = b_vb)
  
  df_temp <- data.frame(
    tau_u   = x_range,
    density = vb_density,
    config  = config$label
  )
  
  vb_combined <- rbind(vb_combined, df_temp)
}

# VB panel
p_vb <- ggplot(vb_combined, aes(x = tau_u, y = density, color = config)) +
  geom_line(linewidth = 1.2) +
  geom_vline(xintercept = tau_u_true, color = "red", linetype = "dotted", linewidth = 0.8) +
  scale_color_manual(
    values = c(
      "Q=5 (n=60 per group)"  = "gray50",
      "Q=10 (n=30 per group)" = "#d95f02",
      "Q=20 (n=15 per group)" = "#7570b3",
      "Q=50 (n=6 per group)"  = "#e7298a",
      "Q=100 (n=3 per group)" = "#1b9e77"
    )
  ) +
  coord_cartesian(xlim = c(0, 8), ylim = c(0, 2.5)) +
  labs(
    title = "VB Posteriors",
    subtitle = "Consistent performance with sufficient groups",
    x = expression(tau[u]),
    y = "Density",
    color = "Configuration"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "right",
    legend.text = element_text(size = 11, face = "bold"),
    legend.title = element_text(size = 12, face = "bold"),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    axis.text = element_text(size = 12, face = "bold"),
    axis.title = element_text(size = 13, face = "bold")
  )

# Combine panels
combined_overlay <- p_gibbs | p_vb
plot_title <- "Comparison: Gibbs vs VB Across All Configurations"
plot_subtitle <- "Gibbs posteriors are consistent; VB posteriors vary dramatically with sample size per group"

combined_overlay <- combined_overlay +
  plot_annotation(
    title = plot_title,
    subtitle = plot_subtitle,
    theme = theme(
      plot.title = element_text(size = 16, face = "bold", margin = margin(b = 10)),
      plot.subtitle = element_text(size = 12, margin = margin(b = 20))
    )
  ) &
  theme(
    legend.position = "right",
    legend.direction = "vertical",
    legend.box = "vertical",
    legend.margin = margin(l = 10),
    plot.margin = margin(t = 15, r = 10, b = 10, l = 10)
  )

# Save plot to both locations
ggsave(
  filename = "figs/M2_tau_u_overlay_comparison.png",
  plot     = combined_overlay,
  width    = 14,
  height   = 7,
  dpi      = 300
)

ggsave(
  filename = "presentation/M2_tau_u_overlay_comparison.png",
  plot     = combined_overlay,
  width    = 14,
  height   = 7,
  dpi      = 300
)

cat("✓ M2_tau_u_overlay_comparison.png saved with matching y-axis scales (0-2.5) and bold axis text\n")
