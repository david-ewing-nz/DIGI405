# Dynamic plotting code to replace the hardcoded all_6_ggplots chunk
# This replaces lines ~1436-2020 in VI-example-RandomInterceptLinear-2.Rmd
# 
# Usage: Replace the entire all_6_ggplots chunk with this code
# 
# Features:
# - Loops over all p beta parameters
# - Keeps u1, u2, tau_e, tau_u
# - Total plots = p + 4
# - Dynamic grid layout
# - Dynamic filenames for saved plots

```{r all_dynamic_ggplots, echo=FALSE, fig.width=8, fig.height=11, out.width="100%", out.height="0.95\\textheight"}
library(ggplot2)
library(patchwork)
library(png)
library(grid)

# Dynamic plotting: p beta plots + 2 u plots + 2 tau plots = p+4 total plots
plot_list <- list()
plot_idx <- 1

# ============================================================================
# Loop over all p beta parameters
# ============================================================================
for (i in 1:p) {
  # Determine x-axis range
  if (run_gibbs) {
    gibbs_col_name <- paste0('beta', i-1)
    gibbs_range <- range(density(gibbs_samples[, gibbs_col_name])$x)
    vb_width <- 3*sqrt(Sigma_betau[i,i])
    x_min <- max(gibbs_range[1], mu_beta[i] - 2*vb_width)
    x_max <- min(gibbs_range[2], mu_beta[i] + 2*vb_width)
  } else {
    x_min <- mu_beta[i] - 3*sqrt(Sigma_betau[i,i])
    x_max <- mu_beta[i] + 3*sqrt(Sigma_betau[i,i])
  }
  x_seq <- seq(x_min, x_max, length = 200)
  
  # VB and Exact data
  vb_data <- data.frame(
    x       = x_seq,
    density = dnorm(x_seq, mu_beta[i], sqrt(Sigma_betau[i,i])),
    method  = "VB"
  )
  exact_data <- data.frame(
    x       = x_seq,
    density = dnorm(x_seq, mu_beta_exact[i], sqrt(Sigma_beta_exact[i,i])),
    method  = "Exact"
  )
  
  # Add Gibbs if available
  if (run_gibbs) {
    gibbs_density <- density(gibbs_samples[, gibbs_col_name])
    gibbs_interp <- approx(gibbs_density$x, gibbs_density$y, xout = x_seq, rule = 2)
    gibbs_data <- data.frame(
      x       = x_seq,
      density = gibbs_interp$y,
      method  = "Gibbs"
    )
    combined_data <- rbind(vb_data, exact_data, gibbs_data)
    color_values <- c("VB" = "blue", "Exact" = "#E7298A", "Gibbs" = "orange")
    linetype_values <- c("VB" = "solid", "Exact" = "dashed", "Gibbs" = "dotdash")
    color_breaks <- c("VB", "Exact", "Gibbs")
    label_text <- sprintf("VB/Exact: %.3f | VB/Gibbs: %.3f", 
                          sqrt(Sigma_betau[i,i]) / sqrt(Sigma_beta_exact[i,i]),
                          sqrt(Sigma_betau[i,i]) / sd(gibbs_samples[, gibbs_col_name]))
    plot_title <- bquote(paste("VB vs Exact vs Gibbs for ", beta[.(i-1)]))
  } else {
    combined_data <- rbind(vb_data, exact_data)
    color_values <- c("VB" = "blue", "Exact" = "#E7298A")
    linetype_values <- c("VB" = "solid", "Exact" = "dashed")
    color_breaks <- c("VB", "Exact")
    label_text <- sprintf("VB/Exact: %.3f", 
                          sqrt(Sigma_betau[i,i]) / sqrt(Sigma_beta_exact[i,i]))
    plot_title <- bquote(paste("VB vs Exact for ", beta[.(i-1)]))
  }
  
  p_temp <- ggplot(
    combined_data,
    aes(
      x        = x,
      y        = density,
      color    = method,
      linetype = method)) +
    geom_line(linewidth = 1.2) +
    geom_vline(
      xintercept = beta_true[i],
      color      = "darkgreen",
      linetype   = "dotted",
      linewidth  = 1) +
    scale_color_manual(
      name   = NULL,
      values = color_values,
      breaks = color_breaks) +
    scale_linetype_manual(
      name   = NULL,
      values = linetype_values,
      breaks = color_breaks) +
    labs(
      x     = bquote(beta[.(i-1)]),
      y     = "Density",
      title = plot_title) +
    theme_minimal() +
    theme(
      legend.position = "top",
      plot.title      = element_text(hjust = 0.5))
  
  if (run_gibbs && label_text != "") {
    p_temp <- p_temp + annotate(
      "text",
      x     = Inf,
      y     = Inf,
      label = label_text,
      hjust = 1.05,
      vjust = 2,
      size  = 3,
      color = "black")
  }
  
  plot_list[[plot_idx]] <- p_temp
  plot_idx <- plot_idx + 1
}

# ============================================================================
# u_1 and u_2 posteriors (first two random effects)
# ============================================================================
for (u_idx in 1:2) {
  if (run_gibbs) {
    gibbs_col <- paste0('u', u_idx)
    gibbs_range <- range(density(gibbs_samples[, gibbs_col])$x)
    vb_width <- 3*sqrt(Sigma_betau[p+u_idx, p+u_idx])
    x_min <- max(gibbs_range[1], mu_u[u_idx] - 2*vb_width)
    x_max <- min(gibbs_range[2], mu_u[u_idx] + 2*vb_width)
  } else {
    x_min <- mu_u[u_idx] - 3*sqrt(Sigma_betau[p+u_idx, p+u_idx])
    x_max <- mu_u[u_idx] + 3*sqrt(Sigma_betau[p+u_idx, p+u_idx])
  }
  x_seq <- seq(x_min, x_max, length = 200)
  
  vb_data <- data.frame(
    x       = x_seq,
    density = dnorm(x_seq, mu_u[u_idx], sqrt(Sigma_betau[p+u_idx, p+u_idx])),
    method  = "VB"
  )
  
  if (run_gibbs) {
    gibbs_u_density <- density(gibbs_samples[, gibbs_col])
    gibbs_interp <- approx(gibbs_u_density$x, gibbs_u_density$y, xout = x_seq, rule = 2)
    gibbs_data <- data.frame(
      x       = x_seq,
      density = gibbs_interp$y,
      method  = "Gibbs"
    )
    combined_data <- rbind(vb_data, gibbs_data)
    color_values <- c("VB" = "blue", "Gibbs" = "orange")
    linetype_values <- c("VB" = "solid", "Gibbs" = "dotdash")
    color_breaks <- c("VB", "Gibbs")
    label_text <- sprintf("VB/Gibbs: %.3f", 
                          sqrt(Sigma_betau[p+u_idx, p+u_idx]) / sd(gibbs_samples[, gibbs_col]))
    plot_title <- bquote(paste("VB vs Gibbs for ", u[.(u_idx)]))
  } else {
    combined_data <- vb_data
    color_values <- c("VB" = "blue")
    linetype_values <- c("VB" = "solid")
    color_breaks <- "VB"
    label_text <- ""
    plot_title <- bquote(paste("VB for ", u[.(u_idx)]))
  }
  
  p_u <- ggplot(
    combined_data,
    aes(
      x        = x,
      y        = density,
      color    = method,
      linetype = method)) +
    geom_line(linewidth = 1.2) +
    geom_vline(
      xintercept = u_true[u_idx],
      color      = "darkgreen",
      linetype   = "dotted",
      linewidth  = 1) +
    scale_color_manual(
      name   = NULL,
      values = color_values,
      breaks = color_breaks) +
    scale_linetype_manual(
      name   = NULL,
      values = linetype_values,
      breaks = color_breaks) +
    labs(
      x     = bquote(u[.(u_idx)]),
      y     = "Density",
      title = plot_title) +
    theme_minimal() +
    theme(
      legend.position = "top",
      plot.title      = element_text(hjust = 0.5))
  
  if (run_gibbs && label_text != "") {
    p_u <- p_u + annotate(
      "text",
      x     = Inf,
      y     = Inf,
      label = label_text,
      hjust = 1.05,
      vjust = 2,
      size  = 3,
      color = "black")
  }
  
  plot_list[[plot_idx]] <- p_u
  plot_idx <- plot_idx + 1
}

# ============================================================================
# tau_e and tau_u posteriors
# ============================================================================
for (tau_name in c("tau_e", "tau_u")) {
  if (tau_name == "tau_e") {
    E_tau <- E_tau_e
    a_new <- a_e_new
    b_new <- b_e_new
    tau_true <- tau_e_true
    gibbs_tau <- gibbs_tau_e
  } else {
    E_tau <- E_tau_u
    a_new <- a_u_new
    b_new <- b_u_new
    tau_true <- tau_u_true
    gibbs_tau <- gibbs_tau_u
  }
  
  if (run_gibbs) {
    gibbs_range <- range(density(gibbs_tau)$x)
    vb_width <- 3*sqrt(a_new/b_new^2)
    x_min <- max(0, gibbs_range[1], E_tau - 2*vb_width)
    x_max <- min(gibbs_range[2], E_tau + 2*vb_width)
  } else {
    x_min <- max(0, E_tau - 3*sqrt(a_new/b_new^2))
    x_max <- E_tau + 3*sqrt(a_new/b_new^2)
  }
  x_seq <- seq(x_min, x_max, length = 200)
  
  vb_data <- data.frame(
    x       = x_seq,
    density = dgamma(x_seq, shape = a_new, rate = b_new),
    method  = "VB"
  )
  
  if (run_gibbs) {
    gibbs_tau_density <- density(gibbs_tau)
    gibbs_interp <- approx(gibbs_tau_density$x, gibbs_tau_density$y, xout = x_seq, rule = 2)
    gibbs_data <- data.frame(
      x       = x_seq,
      density = gibbs_interp$y,
      method  = "Gibbs"
    )
    combined_data <- rbind(vb_data, gibbs_data)
    color_values <- c("VB" = "blue", "Gibbs" = "orange")
    linetype_values <- c("VB" = "solid", "Gibbs" = "dotdash")
    color_breaks <- c("VB", "Gibbs")
    label_text <- sprintf("VB/Gibbs: %.3f", sqrt(a_new/b_new^2) / sd(gibbs_tau))
    if (tau_name == "tau_e") {
      plot_title <- expression(paste("VB vs Gibbs for ", tau[e]))
    } else {
      plot_title <- expression(paste("VB vs Gibbs for ", tau[u]))
    }
  } else {
    combined_data <- vb_data
    color_values <- c("VB" = "blue")
    linetype_values <- c("VB" = "solid")
    color_breaks <- "VB"
    label_text <- ""
    if (tau_name == "tau_e") {
      plot_title <- expression(paste("VB for ", tau[e]))
    } else {
      plot_title <- expression(paste("VB for ", tau[u]))
    }
  }
  
  p_tau <- ggplot(
    combined_data,
    aes(
      x        = x,
      y        = density,
      color    = method,
      linetype = method)) +
    geom_line(linewidth = 1.2) +
    geom_vline(
      xintercept = tau_true,
      color      = "darkgreen",
      linetype   = "dotted",
      linewidth  = 1) +
    scale_color_manual(
      name   = NULL,
      values = color_values,
      breaks = color_breaks) +
    scale_linetype_manual(
      name   = NULL,
      values = linetype_values,
      breaks = color_breaks) +
    labs(
      x     = ifelse(tau_name == "tau_e", expression(tau[e]), expression(tau[u])),
      y     = "Density",
      title = plot_title) +
    theme_minimal() +
    theme(
      legend.position = "top",
      plot.title      = element_text(hjust = 0.5))
  
  if (run_gibbs && label_text != "") {
    p_tau <- p_tau + annotate(
      "text",
      x     = Inf,
      y     = Inf,
      label = label_text,
      hjust = 1.05,
      vjust = 2,
      size  = 3,
      color = "black")
  }
  
  plot_list[[plot_idx]] <- p_tau
  plot_idx <- plot_idx + 1
}

# ============================================================================
# Combine and save all plots
# ============================================================================
# Dynamic grid layout: total = p + 4 plots
total_plots <- p + 4
n_cols <- 2
n_rows <- ceiling(total_plots / n_cols)

# Build combined plot using patchwork
combined_plot <- wrap_plots(plot_list, ncol = n_cols)

# Save combined plot
ggsave(
  filename = sprintf("../figs/vb_%dPanel_ggplot.png", total_plots),
  plot     = combined_plot,
  width    = 20,
  height   = 5 * n_rows,
  dpi      = 300
)

# Save individual plots
for (i in 1:p) {
  ggsave(
    filename = sprintf("../figs/vb_beta%d_posterior.png", i-1),
    plot     = plot_list[[i]],
    width    = 6,
    height   = 5,
    dpi      = 300
  )
}
ggsave(filename = "../figs/vb_u1_posterior.png",    plot = plot_list[[p+1]], width = 6, height = 5, dpi = 300)
ggsave(filename = "../figs/vb_u2_posterior.png",    plot = plot_list[[p+2]], width = 6, height = 5, dpi = 300)
ggsave(filename = "../figs/vb_tau_e_posterior.png", plot = plot_list[[p+3]], width = 6, height = 5, dpi = 300)
ggsave(filename = "../figs/vb_tau_u_posterior.png", plot = plot_list[[p+4]], width = 6, height = 5, dpi = 300)

if (run_gibbs) {
  cat(sprintf("%d-panel ggplot with Gibbs overlays saved\n", total_plots))
} else {
  cat(sprintf("%d-panel ggplot (VB vs Exact) saved\n", total_plots))
}

# Display the saved plot
img_panel <- readPNG(sprintf("../figs/vb_%dPanel_ggplot.png", total_plots))
grid.newpage()
grid.raster(img_panel)
```
