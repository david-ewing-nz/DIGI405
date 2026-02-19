# plot_beta_panel.R
# Modular function to create beta parameter posterior plots
# 
# Parameters:
#   mu_beta, Sigma_betau: VB posterior for beta and u
#   gibbs_samples: Data frame with Gibbs samples (if run_gibbs=TRUE)
#   p: Number of fixed effects
#   beta_true: True beta values
#   run_gibbs: Logical flag for Gibbs overlay
#
# Returns:
#   List of ggplot objects (one per beta parameter)

plot_beta_panels <- function(mu_beta, Sigma_betau, gibbs_samples = NULL, 
                              p, beta_true, run_gibbs = TRUE) {
  
  library(ggplot2)
  
  beta_means <- mu_beta[1:p]
  plot_list <- list()
  
  for (i in 1:p) {
    # Determine x-axis range
    if (run_gibbs) {
      gibbs_col_name <- paste0('beta', i-1)
      gibbs_range <- range(density(gibbs_samples[, gibbs_col_name])$x)
      vb_width <- 3*sqrt(Sigma_betau[i,i])
      x_min <- max(gibbs_range[1], beta_means[i] - 2*vb_width)
      x_max <- min(gibbs_range[2], beta_means[i] + 2*vb_width)
    } else {
      vb_sd <- sqrt(Sigma_betau[i,i])
      if (!is.finite(vb_sd) || vb_sd <= 0) {
        cat(sprintf("Warning: Invalid SD for beta[%d]: %f\n", i-1, vb_sd))
        vb_sd <- 1
      }
      x_min <- beta_means[i] - 3*vb_sd
      x_max <- beta_means[i] + 3*vb_sd
    }
    
    if (!is.finite(x_min) || !is.finite(x_max)) {
      cat(sprintf("Error: Non-finite range for beta[%d]: [%f, %f]\n", i-1, x_min, x_max))
      next
    }
    
    x_seq <- seq(x_min, x_max, length = 200)
    
    # VB data
    vb_data <- data.frame(
      x       = x_seq,
      density = dnorm(x_seq, beta_means[i], sqrt(Sigma_betau[i,i])),
      method  = "VB"
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
      combined_data <- rbind(vb_data, gibbs_data)
      color_values <- c("VB" = "blue", "Gibbs" = "orange")
      linetype_values <- c("VB" = "solid", "Gibbs" = "dotdash")
      color_breaks <- c("VB", "Gibbs")
      label_text <- sprintf("VB/Gibbs: %.3f", 
                            sqrt(Sigma_betau[i,i]) / sd(gibbs_samples[, gibbs_col_name]))
      plot_title <- bquote(paste("VB vs Gibbs for ", beta[.(i-1)]))
    } else {
      combined_data <- vb_data
      color_values <- c("VB" = "blue")
      linetype_values <- c("VB" = "solid")
      color_breaks <- c("VB")
      label_text <- ""
      plot_title <- bquote(paste("VB posterior for ", beta[.(i-1)]))
    }
    
    p_temp <- ggplot(
      combined_data,
      aes(
        x        = x,
        y        = density,
        color    = method,
        linetype = method)) +
      geom_line(aes(linewidth = method)) +
      scale_linewidth_manual(values = c("VB" = 1.2, "Gibbs" = 2.4), guide = "none") +
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
        plot.title      = element_text(hjust = 0.5),
        panel.border    = element_rect(color = "black", fill = NA, linewidth = 1))
    
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
    
    plot_list[[i]] <- p_temp
  }
  
  return(plot_list)
}
