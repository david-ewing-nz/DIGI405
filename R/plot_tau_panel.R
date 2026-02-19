# plot_tau_panel.R
# Modular function to create precision (tau) posterior plots
# 
# Parameters:
#   E_tau_e, E_tau_u: VB estimates for tau
#   a_e_new, b_e_new, a_u_new, b_u_new: VB Gamma parameters
#   tau_e_true, tau_u_true: True tau values
#   gibbs_tau_e, gibbs_tau_u: Gibbs samples for tau
#   run_gibbs: Logical flag for Gibbs overlay
#   model_type: "M1" or "M3"
#
# Returns:
#   List of ggplot objects (tau_e and tau_u)

plot_tau_panels <- function(E_tau_e, E_tau_u, a_e_new, b_e_new, a_u_new, b_u_new,
                             tau_e_true, tau_u_true, gibbs_tau_e = NULL, gibbs_tau_u = NULL,
                             run_gibbs = TRUE, model_type = "M3") {
  
  library(ggplot2)
  
  plot_list <- list()
  
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
    
    plot_list[[length(plot_list) + 1]] <- p_tau
  }
  
  return(plot_list)
}
