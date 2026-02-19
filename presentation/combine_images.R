library(magick)

# Read the two images
img1 <- image_read("q-space-visual.png")
img2 <- image_read("q-space-bullets.png")

# Stack images vertically
combined <- image_append(c(img1, img2), stack = TRUE)

# Save the combined image
image_write(combined, "q-space-combined.png")

cat("Combined image saved as q-space-combined.png\n")
