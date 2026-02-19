# Calculate H and W for each Q value
data <- readRDS('results/all_sd_ratios.rds')
m2_data <- subset(data, grepl('^M2_', Model))

for (q_val in c(5, 10, 20, 50, 100)) {
  row_data <- m2_data[m2_data$Q == q_val, ]
  
  ratios <- c(row_data$beta_0, row_data$beta_1, row_data$beta_2, 
              row_data$tau_e, row_data$tau_u)
  ratios <- ratios[!is.na(ratios)]
  
  H <- length(ratios) / sum(1/ratios)
  
  fixed_mean <- mean(c(row_data$beta_0, row_data$beta_1, row_data$beta_2))
  W <- 0.40 * fixed_mean + 0.30 * row_data$tau_e + 0.30 * row_data$tau_u
  
  cat(sprintf('Q=%3d: H=%.3f (%.1f%% narrower)  W=%.3f (%.1f%% narrower)  tau_u=%.3f\n', 
              q_val, H, (1-H)*100, W, (1-W)*100, row_data$tau_u))
}
