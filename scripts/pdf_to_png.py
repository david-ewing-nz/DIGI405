#!/usr/bin/env python3
"""
Convert PDF to PNG using pdf2image
"""
from pdf2image import convert_from_path
import os

os.chdir(r"d:\github\VI1\presentation")

# Convert PDF to PNG
pdf_path = "three_models_clean.pdf"
output_path = "three_models_clean.png"

try:
    images = convert_from_path(pdf_path, dpi=300)
    if images:
        images[0].save(output_path, 'PNG')
        print(f"Successfully converted {pdf_path} to {output_path}")
    else:
        print("No pages found in PDF")
except Exception as e:
    print(f"Error converting PDF: {e}")
