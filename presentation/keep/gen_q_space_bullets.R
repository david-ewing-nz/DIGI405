# Generates q-space bullets image with proper text wrapping
# Uses ggplot2 with manual text wrapping

library(ggplot2)
library(stringr)

wrap_text_custom <- function(text, width = 50) {
  sapply(seq_along(text), function(i) {
    x <- text[i]

    # Special handling for q_opt line only (index 4 after reordering)
    if (i == 4) {
      return("q_opt: The optimal approximate posterior\nwithin Q")
    }

    words <- strsplit(x, " ")[[1]]
    lines <- character()
    current_line <- ""
    for (word in words) {
      if (nchar(current_line) + nchar(word) + 1 <= width) {
        current_line <- paste(current_line, word)
      } else {
        if (current_line != "") lines <- c(lines, current_line)
        current_line <- word
      }
    }
    if (current_line != "") lines <- c(lines, current_line)
    paste(lines, collapse = "\n")
  }, USE.NAMES = FALSE)
}

# Create data frame with bullet information
original_labels <- c(
  "KL(q_opt || p(z|x)): The remaining divergence at optimum)",
  "Q: The space of all possible approximate distributions to choose from",
  "q_init: Your initial guess for the approximate posterior",
  "q_opt: The optimal approximate posterior within Q",
  "p(z|x): The true posterior — the target distribution"
)

wrapped_labels <- wrap_text_custom(original_labels, width = 55)

bullets_data <- data.frame(
  y = seq(6, 1, by = -1.25),
  label = wrapped_labels,
  colour = c("#20804e", "#d62828", "#1d5fa2", "#7b2cb5", "#20804e"),
  is_asterisk = c(TRUE, FALSE, FALSE, FALSE, FALSE),
  stringsAsFactors = FALSE
)

# Create ggplot
p <- ggplot(bullets_data, aes(x = 0, y = y)) +
  # Background
  theme(
    plot.background = element_rect(fill = "#f5eefe", colour = "#333333", linewidth = 2),
    panel.background = element_rect(fill = "#f5eefe", colour = NA),
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    plot.margin = unit(c(0.3, 0.5, 0.3, 0.5), "in")
  ) +
  # Add coloured bullets/asterisks
  geom_text(
    data = subset(bullets_data, !is_asterisk),
    aes(x = -0.05, y = y, color = colour),
    label = "●",
    size = 16,
    show.legend = FALSE
  ) +
  geom_text(
    data = subset(bullets_data, is_asterisk),
    aes(x = -0.05, y = y, color = colour),
    label = "*",
    size = 24,
    fontface = "bold",
    show.legend = FALSE
  ) +
  scale_color_identity() +
  # Add wrapped text
  geom_text(
    aes(x = 0.4, label = label),
    hjust = 0, vjust = 0.5,
    size = 14,
    family = "serif",
    fontface = "plain",
    colour = "#554d63",
    lineheight = 1.0
  ) +
  xlim(-0.1, 7) +
  ylim(0.3, 6.7)

# Save PNG only (no PDF)
ggsave("q-space-bullets-fixed.png", p, width = 16, height = 10, dpi = 150, bg = "#f5eefe")

cat("Generated q-space-bullets-fixed.png (PNG only)\n")
cat("Wrapped labels (reordered):\n")
for (i in seq_along(wrapped_labels)) {
  marker <- ifelse(bullets_data$is_asterisk[i], "*", "●")
  cat(sprintf("  %d [%s]: %s\n", i, marker, wrapped_labels[i]))
}
