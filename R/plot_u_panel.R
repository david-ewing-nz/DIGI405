# plot_u_panel.R
# Modular function to create random effects (u) posterior plots
# 
# Parameters:
#   mu_beta, Sigma_betau: VB posterior for beta and u
#   gibbs_samples: Data frame with Gibbs samples (if run_gibbs=TRUE)
#   p, q: Dimensions (p fixed effects, q random effects)
#   u_true: True u values
#   run_gibbs: Logical flag for Gibbs overlay
#
# Returns:
#   List of ggplot objects (first 2 random effects)

plot_u_panels <- function(mu_beta, Sigma_betau, gibbs_samples = NULL, 
                           p, q, u_true, run_gibbs = TRUE) {
  
  library(ggplot2)
  
  mu_u <- mu_beta[(p+1):(p+q)]
  plot_list <- list()
  
  # Plot first 2 random effects
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
      geom_line(aes(linewidth = method)) +
      scale_linewidth_manual(values = c("VB" = 1.2, "Gibbs" = 2.4), guide = "none") +
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
        plot.title      = element_text(hjust = 0.5),
        panel.border    = element_rect(color = "black", fill = NA, linewidth = 1))
    
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
    
    plot_list[[u_idx]] <- p_u
  }
  
  return(plot_list)
}
