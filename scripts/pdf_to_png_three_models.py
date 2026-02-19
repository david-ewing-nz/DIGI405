#!/usr/bin/env python3
"""Convert three_models_comparison.pdf to PNG using PIL and PyMuPDF"""
import fitz  # PyMuPDF
from PIL import Image
import os

os.chdir(r"d:\github\VI1")

# Open PDF
pdf_path = "presentation/three_models_comparison.pdf"
output_path = "presentation/three_models_comparison.png"

# Open the PDF
doc = fitz.open(pdf_path)
page = doc[0]  # Get first page

# Render at high resolution (300 DPI)
zoom = 300 / 72  # PDF is 72 DPI by default
mat = fitz.Matrix(zoom, zoom)
pix = page.get_pixmap(matrix=mat)

# Save as PNG
pix.save(output_path)
doc.close()

print(f"Converted {pdf_path} to {output_path}")
print(f"Image dimensions: {pix.width} x {pix.height}")
