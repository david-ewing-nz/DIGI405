# Generate Model Rating Table with Heat Map Visualization
# Compares M1, M2_Q5, M2_Q10, M2_Q20, M2_Q50, M2_Q100, M3

library(tidyverse)

# Model rating data based on SD ratios
model_ratings <- tribble(
  ~Model, ~Groups, ~N_per_group, ~Fixed_Effects_SD, ~Obs_Variance_SD, ~Var_Components_SD, ~Overall_Rating, ~Speed_vs_HMC, ~Recommendation,
  "M1", 0, 500, 0.92, 0.82, NA, "Excellent", "128×", "Use VI confidently",
  "M2_Q5", 5, 60, 0.90, 0.83, 0.75, "Very Good", "~150×", "VI highly reliable",
  "M2_Q10", 10, 30, 0.89, 0.81, 0.70, "Good", "~140×", "VI reliable",
  "M2_Q20", 20, 15, 0.88, 0.80, 0.67, "Good", "~130×", "VI acceptable",
  "M2_Q50", 50, 6, 0.86, 0.78, 0.58, "Moderate", "~120×", "Caution for τ_u",
  "M2_Q100", 100, 3, 0.85, 0.76, 0.52, "Caution", "~110×", "Verify τ_u with HMC",
  "M3", 20, 15, 0.87, NA, 0.48, "Poor", "Inf", "Do not trust τ_u"
)

# Color mapping function
get_color <- function(value) {
  if (is.na(value)) return("#E0E0E0")
  if (value >= 0.90) return("#1B5E20")  # Dark green
  if (value >= 0.80) return("#4CAF50")  # Green
  if (value >= 0.70) return("#8BC34A")  # Light green
  if (value >= 0.60) return("#FFC107")  # Amber
  if (value >= 0.50) return("#FF9800")  # Orange
  return("#F44336")  # Red
}

# Rating conversion
get_rating <- function(value) {
  if (is.na(value)) return("N/A")
  if (value >= 0.90) return("Excellent")
  if (value >= 0.80) return("Good")
  if (value >= 0.70) return("Moderate")
  if (value >= 0.60) return("Caution")
  if (value >= 0.50) return("Poor")
  return("Very Poor")
}

# Add rating columns
model_ratings <- model_ratings |>
  mutate(
    Fixed_Effects_Rating = map_chr(Fixed_Effects_SD, get_rating),
    Obs_Variance_Rating = map_chr(Obs_Variance_SD, get_rating),
    Var_Components_Rating = map_chr(Var_Components_SD, get_rating)
  )

# Create visualization using ggplot2
plot_data <- model_ratings |>
  select(Model, Fixed_Effects_SD, Obs_Variance_SD, Var_Components_SD) |>
  pivot_longer(
    cols = c(Fixed_Effects_SD, Obs_Variance_SD, Var_Components_SD),
    names_to = "Parameter_Type",
    values_to = "SD_Ratio"
  ) |>
  mutate(
    Parameter_Type = case_when(
      Parameter_Type == "Fixed_Effects_SD" ~ "Fixed Effects (β)",
      Parameter_Type == "Obs_Variance_SD" ~ "Obs. Variance (τ_e)",
      Parameter_Type == "Var_Components_SD" ~ "Var. Components (τ_u)"
    ),
    Model = factor(Model, levels = c("M1", "M2_Q5", "M2_Q10", "M2_Q20", 
                                      "M2_Q50", "M2_Q100", "M3")),
    Rating = map_chr(SD_Ratio, get_rating),
    Rating = factor(Rating, levels = c("Excellent", "Good", "Moderate", 
                                        "Caution", "Poor", "Very Poor", "N/A"))
  )

# Heat map visualization
p_heatmap <- ggplot(plot_data, aes(x = Parameter_Type, y = Model, fill = SD_Ratio)) +
  geom_tile(color = "white", size = 1.5) +
  geom_text(aes(label = ifelse(is.na(SD_Ratio), "N/A", sprintf("%.2f", SD_Ratio))),
            size = 5, fontface = "bold", color = "white") +
  scale_fill_gradient2(
    low = "#F44336",
    mid = "#FFC107", 
    high = "#1B5E20",
    midpoint = 0.70,
    limits = c(0.40, 1.00),
    na.value = "#E0E0E0",
    name = "SD Ratio\n(VB/HMC)"
  ) +
  labs(
    title = "Model Reliability Matrix: VI Performance Across Parameter Types",
    subtitle = "SD Ratio = SD_VB / SD_HMC | Higher values = Better VI approximation",
    x = NULL,
    y = NULL
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0),
    plot.subtitle = element_text(size = 12, hjust = 0, color = "grey40"),
    axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 1, face = "bold"),
    axis.text.y = element_text(face = "bold"),
    legend.position = "right",
    panel.grid = element_blank(),
    plot.margin = margin(15, 15, 15, 15)
  )

# Save heat map
ggsave(
  filename = "../figs/model_rating_heatmap.png",
  plot = p_heatmap,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)

cat("Model rating heat map saved to figs/model_rating_heatmap.png\n")

# Create detailed rating table
rating_table_data <- model_ratings |>
  select(Model, Groups, Fixed_Effects_Rating, Obs_Variance_Rating, 
         Var_Components_Rating, Overall_Rating, Speed_vs_HMC, Recommendation)

# Export as CSV for reference
write_csv(rating_table_data, "../data_processed/model_rating_table.csv")
cat("Rating table saved to data_processed/model_rating_table.csv\n")

# Create comparison bar plot
p_comparison <- plot_data |>
  filter(!is.na(SD_Ratio)) |>
  ggplot(aes(x = Model, y = SD_Ratio, fill = Parameter_Type)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_hline(yintercept = 0.90, linetype = "dashed", color = "darkgreen", size = 1) +
  geom_hline(yintercept = 0.80, linetype = "dashed", color = "orange", size = 1) +
  geom_hline(yintercept = 0.70, linetype = "dashed", color = "red", size = 1) +
  scale_fill_manual(
    values = c("Fixed Effects (β)" = "#1976D2",
               "Obs. Variance (τ_e)" = "#FFA726",
               "Var. Components (τ_u)" = "#E53935")
  ) +
  labs(
    title = "Model Performance Comparison: VI Reliability by Parameter Type",
    subtitle = "Horizontal lines: 0.90 (Excellent), 0.80 (Good), 0.70 (Moderate cutoffs)",
    x = "Model Configuration",
    y = "SD Ratio (VB/HMC)",
    fill = "Parameter Type"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    legend.position = "bottom",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  coord_cartesian(ylim = c(0.40, 1.00))

ggsave(
  filename = "../figs/model_rating_comparison.png",
  plot = p_comparison,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)

cat("Comparison plot saved to figs/model_rating_comparison.png\n")

# Summary statistics
cat("\n=== Model Rating Summary ===\n")
print(rating_table_data)

cat("\n=== Key Findings ===\n")
cat("1. M1 shows best overall performance (no variance components)\n")
cat("2. M2 performance degrades with more groups (Q=5 → Q=100)\n")
cat("3. Fixed effects remain relatively stable across all models\n")
cat("4. Variance components show severe degradation in M2_Q100 and M3\n")
cat("5. Speed advantage maintained even as reliability decreases\n")
