# Extract text from screenshot images using tesseract OCR
# Install tesseract if needed

# Check and install required packages
if (!require("tesseract", quietly = TRUE)) {
  install.packages("tesseract", repos = "https://cloud.r-project.org")
}

if (!require("pdftools", quietly = TRUE)) {
  install.packages("pdftools", repos = "https://cloud.r-project.org")
}

library(tesseract)

# Set up paths
figs_dir <- "figs"
output_file <- "extracted_text.txt"

# Get all screenshot files
image_files <- list.files(
  path = figs_dir,
  pattern = "^Screenshot.*\\.png$",
  full.names = TRUE
)

image_files <- sort(image_files)

cat("Found", length(image_files), "images to process\n\n")

# Initialize OCR engine
eng <- tesseract("eng")

# Extract text from each image
results <- list()

for (i in seq_along(image_files)) {
  img_path <- image_files[i]
  img_name <- basename(img_path)
  
  cat(sprintf("Processing %d/%d: %s\n", i, length(image_files), img_name))
  
  tryCatch({
    # Extract text
    text <- tesseract::ocr(img_path, engine = eng)
    
    results[[i]] <- list(
      index = i,
      filename = img_name,
      text = trimws(text)
    )
  }, error = function(e) {
    cat(sprintf("  ERROR: %s\n", e$message))
    results[[i]] <- list(
      index = i,
      filename = img_name,
      text = paste0("[ERROR: Could not extract text - ", e$message, "]")
    )
  })
}

# Save results to file
cat("\n\nSaving results to:", output_file, "\n")

output_lines <- c()

for (result in results) {
  output_lines <- c(
    output_lines,
    "",
    paste(rep("=", 80), collapse = ""),
    sprintf("IMAGE %d: %s", result$index, result$filename),
    paste(rep("=", 80), collapse = ""),
    "",
    result$text,
    ""
  )
}

writeLines(output_lines, output_file, useBytes = TRUE)

cat("Done! Processed", length(results), "images.\n")
cat("Output saved to:", output_file, "\n")
