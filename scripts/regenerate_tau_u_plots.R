# Regenerate M1/M2/M3 tau_u overlay comparison plots with vertical legends
# Run this script after models have been run

library(tidyverse)
library(patchwork)
library(png)
library(grid)

# M1 tau_u plot
if (file.exists("d:/github/VI1/results/M1_all_configs_results.rds")) {
  cat("Regenerating M1 tau_u overlay plot...\n")
  all_configs <- readRDS("d:/github/VI1/results/M1_all_configs_results.rds")
  
  run_gibbs <- all_configs[["run_gibbs"]]
  density_data_list <- all_configs[["density_data_list"]]
  
  # Extract Gibbs data
  gibbs_data <- density_data_list[grepl("Gibbs", names(density_data_list))]
  gibbs_df <- bind_rows(gibbs_data, .id = "config")
  
  # Extract VB data
  vb_data <- density_data_list[grepl("VB", names(density_data_list))]
  vb_df <- bind_rows(vb_data, .id = "config")
  
  # Gibbs panel
  p_gibbs <- ggplot(gibbs_df, aes(x = tau_u, y = density, color = config, linetype = config)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = gibbs_df$true_tau_u[1], linetype = "dashed", color = "gray30", linewidth = 0.8) +
    scale_color_brewer(palette = "Set2") +
    labs(
      title = "Gibbs Sampling Posteriors",
      x = expression(tau[u]),
      y = "Density",
      color = "Configuration",
      linetype = "Configuration"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11)
    )
  
  # VB panel
  p_vb <- ggplot(vb_df, aes(x = tau_u, y = density, color = config, linetype = config)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = vb_df$true_tau_u[1], linetype = "dashed", color = "gray30", linewidth = 0.8) +
    scale_color_brewer(palette = "Set2") +
    labs(
      title = "VB Posteriors",
      x = expression(tau[u]),
      y = "Density",
      color = "Configuration",
      linetype = "Configuration"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11)
    )
  
  # Combine panels
  if (run_gibbs) {
    combined_overlay <- p_gibbs | p_vb
    plot_title <- "Comparison: Gibbs vs VB Across All Configurations"
    plot_subtitle <- "Gibbs posteriors are consistent; VB posteriors vary dramatically with sample size per group"
    plot_width <- 14
  } else {
    combined_overlay <- p_vb
    plot_title <- "VB Posteriors Across All Configurations"
    plot_subtitle <- "VB posterior quality varies dramatically with sample size per group"
    plot_width <- 8
  }
  
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
  
  # Save plot
  ggsave(
    filename = "../figs/M1_tau_u_overlay_comparison.png",
    plot     = combined_overlay,
    width    = plot_width,
    height   = 7,
    dpi      = 300
  )
  
  cat("✓ M1 tau_u overlay comparison plot saved to figs/M1_tau_u_overlay_comparison.png\n")
} else {
  cat("✗ M1 results file not found. Run M1-Simple-Linear-Diagnostic.Rmd first.\n")
}

# M2 tau_u plot
if (file.exists("d:/github/VI1/results/M2_all_configs_results.rds")) {
  cat("Regenerating M2 tau_u overlay plot...\n")
  all_configs <- readRDS("d:/github/VI1/results/M2_all_configs_results.rds")
  
  run_gibbs <- all_configs[["run_gibbs"]]
  density_data_list <- all_configs[["density_data_list"]]
  
  # Extract Gibbs data
  gibbs_data <- density_data_list[grepl("Gibbs", names(density_data_list))]
  gibbs_df <- bind_rows(gibbs_data, .id = "config")
  
  # Extract VB data
  vb_data <- density_data_list[grepl("VB", names(density_data_list))]
  vb_df <- bind_rows(vb_data, .id = "config")
  
  # Gibbs panel
  p_gibbs <- ggplot(gibbs_df, aes(x = tau_u, y = density, color = config, linetype = config)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = gibbs_df$true_tau_u[1], linetype = "dashed", color = "gray30", linewidth = 0.8) +
    scale_color_brewer(palette = "Set2") +
    labs(
      title = "Gibbs Sampling Posteriors",
      x = expression(tau[u]),
      y = "Density",
      color = "Configuration",
      linetype = "Configuration"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11)
    )
  
  # VB panel
  p_vb <- ggplot(vb_df, aes(x = tau_u, y = density, color = config, linetype = config)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = vb_df$true_tau_u[1], linetype = "dashed", color = "gray30", linewidth = 0.8) +
    scale_color_brewer(palette = "Set2") +
    labs(
      title = "VB Posteriors",
      x = expression(tau[u]),
      y = "Density",
      color = "Configuration",
      linetype = "Configuration"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11)
    )
  
  # Combine panels
  if (run_gibbs) {
    combined_overlay <- p_gibbs | p_vb
    plot_title <- "Comparison: Gibbs vs VB Across All Configurations"
    plot_subtitle <- "Gibbs posteriors are consistent; VB posteriors vary dramatically with sample size per group"
    plot_width <- 14
  } else {
    combined_overlay <- p_vb
    plot_title <- "VB Posteriors Across All Configurations"
    plot_subtitle <- "VB posterior quality varies dramatically with sample size per group"
    plot_width <- 8
  }
  
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
  
  # Save plot
  ggsave(
    filename = "../figs/M2_tau_u_overlay_comparison.png",
    plot     = combined_overlay,
    width    = plot_width,
    height   = 7,
    dpi      = 300
  )
  
  cat("✓ M2 tau_u overlay comparison plot saved to figs/M2_tau_u_overlay_comparison.png\n")
} else {
  cat("✗ M2 results file not found. Run M2-Hierarchical-Linear-Diagnostic.Rmd first.\n")
}

# M3 tau_u plot
if (file.exists("d:/github/VI1/results/M3_all_configs_results.rds")) {
  cat("Regenerating M3 tau_u overlay plot...\n")
  all_configs <- readRDS("d:/github/VI1/results/M3_all_configs_results.rds")
  
  run_gibbs <- all_configs[["run_gibbs"]]
  density_data_list <- all_configs[["density_data_list"]]
  
  # Extract Gibbs data
  gibbs_data <- density_data_list[grepl("Gibbs", names(density_data_list))]
  gibbs_df <- bind_rows(gibbs_data, .id = "config")
  
  # Extract VB data
  vb_data <- density_data_list[grepl("VB", names(density_data_list))]
  vb_df <- bind_rows(vb_data, .id = "config")
  
  # Gibbs panel
  p_gibbs <- ggplot(gibbs_df, aes(x = tau_u, y = density, color = config, linetype = config)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = gibbs_df$true_tau_u[1], linetype = "dashed", color = "gray30", linewidth = 0.8) +
    scale_color_brewer(palette = "Set2") +
    labs(
      title = "Gibbs Sampling Posteriors",
      x = expression(tau[u]),
      y = "Density",
      color = "Configuration",
      linetype = "Configuration"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11)
    )
  
  # VB panel
  p_vb <- ggplot(vb_df, aes(x = tau_u, y = density, color = config, linetype = config)) +
    geom_line(linewidth = 1.2) +
    geom_vline(xintercept = vb_df$true_tau_u[1], linetype = "dashed", color = "gray30", linewidth = 0.8) +
    scale_color_brewer(palette = "Set2") +
    labs(
      title = "VB Posteriors",
      x = expression(tau[u]),
      y = "Density",
      color = "Configuration",
      linetype = "Configuration"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      plot.subtitle = element_text(size = 11)
    )
  
  # Combine panels
  if (run_gibbs) {
    combined_overlay <- p_gibbs | p_vb
    plot_title <- "Comparison: Gibbs vs VB Across All Configurations"
    plot_subtitle <- "Gibbs posteriors are consistent; VB posteriors vary dramatically with sample size per group"
    plot_width <- 14
  } else {
    combined_overlay <- p_vb
    plot_title <- "VB Posteriors Across All Configurations"
    plot_subtitle <- "VB posterior quality varies dramatically with sample size per group"
    plot_width <- 8
  }
  
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
  
  # Save plot
  ggsave(
    filename = "../figs/M3_tau_u_overlay_comparison.png",
    plot     = combined_overlay,
    width    = plot_width,
    height   = 7,
    dpi      = 300
  )
  
  cat("✓ M3 tau_u overlay comparison plot saved to figs/M3_tau_u_overlay_comparison.png\n")
} else {
  cat("✗ M3 results file not found. Run M3-Hierarchical-Logistic-Diagnostic.Rmd first.\n")
}

cat("\n=================================\n")
cat("Plot regeneration complete.\n")
cat("=================================\n")
