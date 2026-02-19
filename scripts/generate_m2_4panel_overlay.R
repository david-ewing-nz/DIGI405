# Generate 4-panel M2 tau_u comparison (Q5, Q10, Q20, Q50)
# Each panel shows Gibbs vs VB overlaid

library(tidyverse)
library(patchwork)

# Load results
results_file <- "results/M2_results_multi.rds"

if (!file.exists(results_file)) {
  stop("Results file not found at: ", results_file)
}

cat("Loading M2 results from:", results_file, "\n")
results_multi <- readRDS(results_file)

# Parameters
tau_u_true <- 1

# Create 4 panels (one per configuration)
plot_list <- list()

for (i in seq_along(results_multi)) {
  result <- results_multi[[i]]
  config <- result$config
  
  # Extract Gibbs samples
  gibbs_tau_u <- result$gibbs[, "tau_u"]
  dens_gibbs <- density(gibbs_tau_u, adjust = 1.5)
  
  # Extract VB parameters
  a_vb <- result$vb$a_u_new
  b_vb <- result$vb$b_u_new
  
  # Create data frame for plotting
  x_range <- seq(0, 8, length.out = 500)
  
  df_plot <- data.frame(
    tau_u = c(dens_gibbs$x, x_range),
    density = c(dens_gibbs$y, dgamma(x_range, shape = a_vb, rate = b_vb)),
    method = rep(c("Gibbs", "VB"), c(length(dens_gibbs$x), length(x_range)))
  )
  
  # Calculate SD ratio for subtitle
  vb_sd <- sqrt(a_vb) / b_vb
  gibbs_sd <- sd(gibbs_tau_u)
  sd_ratio <- vb_sd / gibbs_sd
  
  # Create individual panel
  p <- ggplot(df_plot, aes(x = tau_u, y = density, color = method, linetype = method)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = tau_u_true, color = "red", linetype = "dotted", linewidth = 0.8) +
    scale_color_manual(
      values = c("VB" = "black", "Gibbs" = "#E7298A")
    ) +
    scale_linetype_manual(
      values = c("VB" = "solid", "Gibbs" = "dashed")
    ) +
    coord_cartesian(xlim = c(0, 4), ylim = c(0, 2.5)) +
    labs(
      title = config$label,
      subtitle = glue::glue("SD ratio: {round(sd_ratio, 3)}"),
      x = expression(tau[u]),
      y = "Density"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_text(size = 11, face = "bold"),
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11),
      axis.text = element_text(size = 11, face = "bold"),
      axis.title = element_text(size = 12, face = "bold")
    )
  
  plot_list[[i]] <- p
}

# Combine into 2×3 grid (5 plots + 1 blank)
combined_4panel <- (plot_list[[1]] | plot_list[[2]] | plot_list[[3]]) / 
                   (plot_list[[4]] | plot_list[[5]] | plot_spacer())

combined_4panel <- combined_4panel +
  plot_annotation(
    title = "VB vs Gibbs Posteriors for τᵤ Across Configurations",
    subtitle = "VB under-dispersion increases as sample size per group decreases",
    theme = theme(
      plot.title = element_text(size = 16, face = "bold", margin = margin(b = 10)),
      plot.subtitle = element_text(size = 12, margin = margin(b = 20))
    )
  ) &
  theme(
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  )

# Save to both locations (rename to 5panel since we have 5 configurations)
ggsave(
  filename = "figs/M2_tau_u_5panel_overlay.png",
  plot     = combined_4panel,
  width    = 16,
  height   = 7,
  dpi      = 300
)

ggsave(
  filename = "presentation/M2_tau_u_5panel_overlay.png",
  plot     = combined_4panel,
  width    = 16,
  height   = 7,
  dpi      = 300
)

cat("✓ M2_tau_u_5panel_overlay.png saved with all 5 configurations (Q5-Q100)\n")
