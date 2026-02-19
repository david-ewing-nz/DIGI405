
```{r save_sd_ratios_m0, echo=FALSE}
# Extract and save M0 SD ratios
if (run_gibbs && length(results_multi) > 0) {
  sd_rows <- lapply(seq_along(results_multi), function(i) {
    result <- results_multi[[i]]
    q_val <- result$config$q
    
    if (!is.null(result$gibbs)) {
      vb_beta_sds <- sqrt(diag(result$vb$Sigma_betau)[1:p])
      vb_tau_e_sd <- sqrt(result$vb$a_e_new / (result$vb$b_e_new^2))
      vb_tau_u_sd <- sqrt(result$vb$a_u_new / (result$vb$b_u_new^2))
      
      gibbs_beta_sds <- apply(result$gibbs[, 1:p], 2, sd)
      gibbs_tau_e_sd <- sd(result$gibbs[, "tau_e"])
      gibbs_tau_u_sd <- sd(result$gibbs[, "tau_u"])
      
      data.frame(
        Model = paste0("M0_Q", q_val),
        Q = q_val,
        beta_0 = vb_beta_sds[1] / gibbs_beta_sds[1],
        beta_1 = vb_beta_sds[2] / gibbs_beta_sds[2],
        beta_2 = vb_beta_sds[3] / gibbs_beta_sds[3],
        tau_e = vb_tau_e_sd / gibbs_tau_e_sd,
        tau_u = vb_tau_u_sd / gibbs_tau_u_sd,
        sigma2_e = NA,
        sigma2_u = NA,
        stringsAsFactors = FALSE
      )
    } else { NULL }
  })
  
  sd_rows <- do.call(rbind, sd_rows[!sapply(sd_rows, is.null)])
  
  if (nrow(sd_rows) > 0) {
    rds_path <- "../results/all_sd_ratios.rds"
    if (file.exists(rds_path)) {
      all_sd <- readRDS(rds_path)
      all_sd <- all_sd[!grepl("^M0_", all_sd$Model), ]
      all_sd <- rbind(all_sd, sd_rows)
    } else {
      all_sd <- sd_rows
    }
    
    saveRDS(all_sd, rds_path)
    cat("\nSaved M0 SD ratios for", nrow(sd_rows), "configurations\n")
  }
}
```
