# plot_vb_posteriors.R
# Function to create dynamic posterior plots for VB hierarchical model
# 
# Parameters:
#   mu_beta, Sigma_betau: VB posterior for beta and u
#   mu_beta_exact, Sigma_beta_exact: Exact posterior for beta
#   gibbs_samples: Data frame with Gibbs samples (if run_gibbs=TRUE)
#   p, q: Dimensions (p fixed effects, q random effects)
#   beta_true, u_true, tau_e_true, tau_u_true: True parameter values
#   E_tau_e, E_tau_u: VB estimates for tau
#   a_e_new, b_e_new, a_u_new, b_u_new: VB Gamma parameters
#   gibbs_tau_e, gibbs_tau_u: Gibbs samples for tau (if run_gibbs=TRUE)
#   run_gibbs: Logical flag for Gibbs overlay
#
# Returns:
#   Combined patchwork plot (p+4 panels)

plot_vb_posteriors <- function(mu_beta, Sigma_betau, mu_beta_exact, Sigma_beta_exact,
                                 gibbs_samples, p, q, beta_true, u_true, 
                                 tau_e_true, tau_u_true, E_tau_e, E_tau_u,
                                 a_e_new, b_e_new, a_u_new, b_u_new,
                                 gibbs_tau_e, gibbs_tau_u, run_gibbs) {
  
  library(ggplot2)
  library(patchwork)
  
  # Extract beta and u from combined vector
  # mu_beta is (p+q) vector: first p are beta, last q are u
  beta_means <- mu_beta[1:p]
  mu_u <- mu_beta[(p+1):(p+q)]
  
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
      x_min <- max(gibbs_range[1], beta_means[i] - 2*vb_width)
      x_max <- min(gibbs_range[2], beta_means[i] + 2*vb_width)
    } else {
      vb_sd <- sqrt(Sigma_betau[i,i])
      # Check for valid variance
      if (!is.finite(vb_sd) || vb_sd <= 0) {
        cat(sprintf("Warning: Invalid SD for beta[%d]: %f\n", i-1, vb_sd))
        vb_sd <- 1  # Fallback
      }
      x_min <- beta_means[i] - 3*vb_sd
      x_max <- beta_means[i] + 3*vb_sd
    }
    
    # Check for finite values before seq()
    if (!is.finite(x_min) || !is.finite(x_max)) {
      cat(sprintf("Error: Non-finite range for beta[%d]: [%f, %f]\n", i-1, x_min, x_max))
      cat(sprintf("  beta_means[%d] = %f, SD = %f\n", i, beta_means[i], sqrt(Sigma_betau[i,i])))
      next  # Skip this plot
    }
    
    x_seq <- seq(x_min, x_max, length = 200)
    
    # VB and Exact data
    vb_data <- data.frame(
      x       = x_seq,
      density = dnorm(x_seq, beta_means[i], sqrt(Sigma_betau[i,i])),
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
      geom_line(aes(linewidth = method)) +
      scale_linewidth_manual(values = c("VB" = 1.2, "Exact" = 1.2, "Gibbs" = 2.4), guide = "none") +
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
      geom_line(aes(linewidth = method)) +
      scale_linewidth_manual(values = c("VB" = 1.2, "Gibbs" = 2.4), guide = "none") +
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
        plot.title      = element_text(hjust = 0.5),
        panel.border    = element_rect(color = "black", fill = NA, linewidth = 1))
    
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
  # Combine all plots
  # ============================================================================
  total_plots <- p + 4
  n_cols <- 2
  
  # Build combined plot using patchwork
  combined_plot <- wrap_plots(plot_list, ncol = n_cols)
  
  return(combined_plot)
}
