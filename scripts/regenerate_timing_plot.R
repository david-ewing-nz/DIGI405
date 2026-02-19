#!/usr/bin/env Rscript
# Generate timing speedup barh plot with horizontal y-axis labels

library(tidyverse)
library(ggplot2)

# Load timing data
timing_data <- readRDS("results/timing_data.rds")

# Prepare data
if (is.null(timing_data)) {
  stop("timing_data.rds not found or empty")
}

# Ensure data has required columns
if (!all(c("Model", "vb_time", "gibbs_time") %in% names(timing_data))) {
  stop("timing_data missing required columns")
}

# Calculate speedup and clean data - remove M3 models
timing_data <- timing_data %>%
  filter(!grepl("M3", Model)) %>%
  filter(!is.infinite(speedup), !is.nan(speedup)) %>%
  mutate(
    Config = ifelse(is.na(Q), "M1", paste0(Model, " (Q=", Q, ")")),
    Model_type = ifelse(grepl("^M1", Model), "Model 1", "Model 2")
  )

# Create barh plot with horizontal y-axis labels
p <- ggplot(timing_data, aes(x = speedup, y = reorder(Config, speedup), fill = Model_type)) +
  geom_col() +
  scale_fill_manual(values = c("Model 1" = "steelblue", "Model 2" = "grey60"),
                     name = "Model") +
  labs(
    title = "Speedup Ratios: VB vs Gibbs Sampling",
    x = "Speedup Ratio",
    y = ""
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(angle = 0, hjust = 1, vjust = 0.5, size = 10),
    plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
    legend.position = "bottom"
  )

# Save plot
ggsave("figs/timing_speedup_barh.png", p, width = 8.5, height = 5, dpi = 300)
print("Plot saved to figs/timing_speedup_barh.png")
