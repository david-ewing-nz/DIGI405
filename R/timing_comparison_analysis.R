# ============================================================================
# Timing Comparison Analysis
# Processes timing_data.rds and creates comprehensive timing visualizations
# Compares VB vs Gibbs computational costs across M1, M2, M3 models
# ============================================================================

library(ggplot2)
library(dplyr)
library(tidyr)
library(grid)
library(png)
library(glue)

set.seed(82171165)

# ============================================================================
# LOAD TIMING DATA
# ============================================================================

timing_path <- "../results/timing_data.rds"

if (!file.exists(timing_path)) {
  stop("timing_data.rds not found. Please run M1, M2, M3 notebooks first to collect timing data.")
}

timing_data <- readRDS(timing_path)

cat("\n=== LOADED TIMING DATA ===\n")
print(timing_data)
cat("\n")

# ============================================================================
# DATA PROCESSING
# ============================================================================

# Add model type classification and proper ordering
timing_data <- timing_data %>%
  mutate(
    model_type = case_when(
      grepl("^M1", Model) ~ "M1 (Linear)",
      grepl("^M2", Model) ~ "M2 (Hierarchical Linear)",
      grepl("^M3", Model) ~ "M3 (Hierarchical Logistic)",
      TRUE ~ "Unknown"
    ),
    model_number = as.integer(gsub("M([0-9]).*", "\\1", Model)),
    has_Q = !is.na(Q)
  )

# Set proper factor ordering for Model column
model_order <- c("M1", "M2_Q5", "M2_Q10", "M2_Q20", "M2_Q50", "M2_Q100",
                 "M3_Q5", "M3_Q10", "M3_Q20", "M3_Q50", "M3_Q100")
timing_data$Model <- factor(timing_data$Model, levels = model_order)

# Summary statistics
cat("=== TIMING SUMMARY ===\n")
cat(sprintf("Total VB time: %.2f seconds\n", sum(timing_data$vb_time, na.rm = TRUE)))
cat(sprintf("Total Gibbs time: %.2f seconds\n", sum(timing_data$gibbs_time, na.rm = TRUE)))
cat(sprintf("Overall speedup: %.1fx\n", sum(timing_data$gibbs_time, na.rm = TRUE) / sum(timing_data$vb_time, na.rm = TRUE)))
cat("\n")

cat("=== BY MODEL ===\n")
timing_data %>%
  group_by(model_type) %>%
  summarise(
    vb_total = sum(vb_time, na.rm = TRUE),
    gibbs_total = sum(gibbs_time, na.rm = TRUE),
    mean_speedup = mean(speedup, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()
cat("\n")

# ============================================================================
# PLOT 1: SIDE-BY-SIDE TIME COMPARISON (VB VS GIBBS)
# ============================================================================

timing_long <- timing_data %>%  filter(model_type != "M3 (Hierarchical Logistic)") %>%  # Remove M3 data  select(Model, model_type, Q, vb_time, gibbs_time) %>%
  pivot_longer(cols = c(vb_time, gibbs_time), names_to = "method", values_to = "time") %>%
  mutate(
    method_label = ifelse(method == "vb_time", "VB (MFVB)", "Gibbs (MCMC)"),
    time_label = ifelse(time < 0.01 & time > 0, "< 0.01s", sprintf("%.2fs", time))
  )

p1 <- ggplot(timing_long, aes(x = Model, y = time, fill = model_type, alpha = method_label)) +
  geom_bar(stat = "identity", position = position_dodge2(width = 0.7, preserve = "single"), width = 0.7) +
  geom_text(aes(label = time_label, hjust = ifelse(method_label == "VB (MFVB)", -0.3, 0.5)), 
            position = position_dodge(width = 0.7), 
            vjust = -0.7, size = 4.5, fontface = "bold") +
  scale_fill_manual(
    name = "Model",
    values = c(
      "M1 (Linear)" = "#1b9e77",
      "M2 (Hierarchical Linear)" = "#d95f02",
      "M3 (Hierarchical Logistic)" = "#7570b3"
    )
  ) +
  scale_alpha_manual(
    name = "Method",
    values = c("VB (MFVB)" = 0.6, "Gibbs (MCMC)" = 1.0)
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Computational Time: VB vs Gibbs Sampling (Lower is better — VB consistently faster)",
    x = "Model Configuration",
    y = "Elapsed Time (seconds)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "top",
    plot.title = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
    axis.text.y = element_text(size = 12, face = "bold"),
    axis.title.x = element_text(size = 12, face = "bold"),
    axis.title.y = element_text(size = 12, face = "bold")
  )

ggsave(
  filename = "../figs/timing_vb_vs_gibbs_bars.png",
  plot = p1,
  width = 10,
  height = 6,
  dpi = 300
)

cat("✓ Saved: timing_vb_vs_gibbs_bars.png\n")

# ============================================================================
# PLOT 2: SPEEDUP RATIOS (GIBBS/VB)
# ============================================================================

timing_data_speedup <- timing_data %>% 
  filter(!is.na(speedup), model_type != "M3 (Hierarchical Logistic)") %>%  # Remove M3 data
  mutate(
    speedup_label = ifelse(is.infinite(speedup), "> 1000x", sprintf("%.1fx", speedup))
  )

p2 <- ggplot(timing_data_speedup, 
             aes(x = Model, y = pmin(speedup, 200), fill = model_type)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray40", size = 0.8) +
  geom_text(aes(label = speedup_label), 
            vjust = -0.8, size = 5, fontface = "bold") +
  scale_fill_manual(
    values = c(
      "M1 (Linear)" = "#1b9e77",
      "M2 (Hierarchical Linear)" = "#d95f02",
      "M3 (Hierarchical Logistic)" = "#7570b3"
    )
  ) +
  scale_y_continuous(limits = c(0, 240), expand = expansion(mult = c(0, 0))) +
  labs(
    title = "Computational Speedup: Gibbs Time / VB Time (Ratios > 1 mean VB is faster)",
    x = "Model Configuration",
    y = "Speedup Ratio (Gibbs / VB, capped at 200)",
    fill = "Model Type"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "top",
    plot.title = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
    axis.text.y = element_text(size = 12, face = "bold"),
    axis.title.x = element_text(size = 12, face = "bold"),
    axis.title.y = element_text(size = 12, face = "bold"),
    panel.grid.major.x = element_blank()
  )

ggsave(
  filename = "../figs/timing_speedup_ratios.png",
  plot = p2,
  width = 10,
  height = 6,
  dpi = 300
)

cat("✓ Saved: timing_speedup_ratios.png\n")

# ============================================================================
# PLOT 3: SCALING WITH Q (M2 AND M3 ONLY) - SEPARATE PANELS
# ============================================================================

timing_hierarchical <- timing_data %>%
  filter(has_Q, model_type == "M2 (Hierarchical Linear)") %>%
  select(Model, model_type, Q, vb_time, gibbs_time) %>%
  pivot_longer(cols = c(vb_time, gibbs_time), names_to = "method", values_to = "time") %>%
  mutate(
    method_label = ifelse(method == "vb_time", "VB (MFVB)", "Gibbs (MCMC)")
  )

p3 <- ggplot(timing_hierarchical, aes(x = Q, y = time, color = method_label, linetype = method_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(
    name = "Method",
    values = c(
      "VB (MFVB)" = "#4575b4", 
      "Gibbs (MCMC)" = "#d73027"
    )
  ) +
  scale_linetype_manual(
    name = "Method",
    values = c(
      "VB (MFVB)" = "solid", 
      "Gibbs (MCMC)" = "dashed"
    )
  ) +
  labs(
    title = "M2: Computational Time vs Number of Groups (Q)",
    subtitle = "VB scales better than Gibbs — both show increasing computational cost with Q",
    x = "Number of Groups (Q)",
    y = "Elapsed Time (seconds)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11),
    axis.text.x = element_text(size = 11, face = "bold"),
    axis.text.y = element_text(size = 11, face = "bold")
  )

ggsave(
  filename = "../figs/timing_scaling_with_Q.png",
  plot = p3,
  width = 10,
  height = 8,
  dpi = 300
)

cat("✓ Saved: timing_scaling_with_Q.png\n")

# ============================================================================
# PLOT 4: COMPREHENSIVE COMPARISON TABLE
# ============================================================================

timing_table <- timing_data %>%
  arrange(model_number, Q) %>%
  mutate(
    VB_Time = ifelse(vb_time < 0.01 & vb_time > 0, "< 0.01s", sprintf("%.3fs", vb_time)),
    Gibbs_Time = sprintf("%.3fs", gibbs_time),
    Speedup = ifelse(is.infinite(speedup), "> 1000x", sprintf("%.1fx", speedup))
  ) %>%
  select(Model, Q, VB_Time, Gibbs_Time, Speedup)

# Create text table as plot
table_text <- paste(
  sprintf("%-15s %5s %12s %12s %10s", "Model", "Q", "VB Time", "Gibbs Time", "Speedup"),
  paste(rep("-", 60), collapse = ""),
  sep = "\n"
)

for (i in 1:nrow(timing_table)) {
  q_val <- ifelse(is.na(timing_table$Q[i]), "  -", sprintf("%3d", timing_table$Q[i]))
  table_text <- paste(
    table_text,
    sprintf("%-15s %5s %12s %12s %10s",
            timing_table$Model[i],
            q_val,
            timing_table$VB_Time[i],
            timing_table$Gibbs_Time[i],
            timing_table$Speedup[i]),
    sep = "\n"
  )
}

png("../figs/timing_comparison_table.png", width = 800, height = 400, res = 100)
par(mar = c(0, 0, 2, 0))
plot.new()
title("Timing Comparison Summary Table", cex.main = 1.5, font.main = 2)
text(0.5, 0.5, table_text, family = "mono", cex = 1.1, adj = c(0.5, 0.5))
dev.off()

cat("✓ Saved: timing_comparison_table.png\n")

# ============================================================================
# PLOT 5: LOG-SCALE COMPARISON (FOR LARGE DIFFERENCES)
# ============================================================================

p5 <- ggplot(timing_long, aes(x = Model, y = time, fill = method_label)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  scale_y_log10() +
  scale_fill_manual(
    values = c("VB (MFVB)" = "#4575b4", "Gibbs (MCMC)" = "#d73027")
  ) +
  labs(
    title = "Computational Time: VB vs Gibbs (Log Scale)",
    subtitle = "Log scale emphasizes relative differences across configurations",
    x = "Model Configuration",
    y = "Elapsed Time (seconds, log scale)",
    fill = "Method"
  ) +
  theme_minimal() +
  theme(
    legend.position = "top",
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  annotation_logticks(sides = "l")

ggsave(
  filename = "../figs/timing_vb_vs_gibbs_log.png",
  plot = p5,
  width = 10,
  height = 6,
  dpi = 300
)

cat("✓ Saved: timing_vb_vs_gibbs_log.png\n")

# ============================================================================
# PLOT 6: COMBINED DASHBOARD
# ============================================================================

library(patchwork)

# Create smaller versions for dashboard
p_dashboard_bars <- p1 + theme(legend.position = "none", plot.title = element_text(size = 11))
p_dashboard_speedup <- p2 + theme(legend.position = "none", plot.title = element_text(size = 11))
p_dashboard_scaling <- p3 + theme(legend.position = "bottom", plot.title = element_text(size = 11))

# Create blank plot for lower right
p_blank <- ggplot() + theme_void()

# Combine into dashboard with 2x2 layout
p_dashboard <- (p_dashboard_bars | p_dashboard_speedup) / (p_dashboard_scaling | p_blank) +
  plot_annotation(
    title = "Computational Performance: VB vs Gibbs Sampling",
    theme = theme(
      plot.title = element_text(size = 16, face = "bold")
    )
  )

ggsave(
  filename = "../figs/timing_dashboard.png",
  plot = p_dashboard,
  width = 16,
  height = 9,
  dpi = 300
)

cat("✓ Saved: timing_dashboard.png\n")

# ============================================================================
# SUMMARY REPORT
# ============================================================================

cat("\n===============================================\n")
cat("TIMING ANALYSIS COMPLETE\n")
cat("===============================================\n\n")

cat("Generated Visualizations:\n")
cat("1. timing_vb_vs_gibbs_bars.png    - Side-by-side bar comparison\n")
cat("2. timing_speedup_ratios.png      - Speedup ratios (Gibbs/VB)\n")
cat("3. timing_scaling_with_Q.png      - Scaling with number of groups\n")
cat("4. timing_comparison_table.png    - Comprehensive table\n")
cat("5. timing_vb_vs_gibbs_log.png     - Log-scale comparison\n")
cat("6. timing_dashboard.png           - Combined dashboard\n\n")

cat("Key Findings:\n")
cat(sprintf("• Overall speedup: %.1fx faster with VB\n", 
    sum(timing_data$gibbs_time, na.rm = TRUE) / sum(timing_data$vb_time, na.rm = TRUE)))
cat(sprintf("• M1 speedup: %.1fx\n", timing_data$speedup[timing_data$Model == "M1"]))
cat(sprintf("• M2 mean speedup: %.1fx\n", mean(timing_data$speedup[grepl("^M2", timing_data$Model)], na.rm = TRUE)))
cat(sprintf("• M3 mean speedup: %.1fx\n", mean(timing_data$speedup[grepl("^M3", timing_data$Model)], na.rm = TRUE)))
cat("\n")

cat("All plots saved to: figs/\n")
cat("Timing data location: results/timing_data.rds\n")
cat("===============================================\n")
