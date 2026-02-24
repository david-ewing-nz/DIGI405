"""
Extract text from screenshot images using OCR and organize into structured output.
"""

import os
from pathlib import Path
try:
    from PIL import Image
    import pytesseract
except ImportError:
    print("Required packages not installed. Installing...")
    import subprocess
    subprocess.check_call(['pip', 'install', 'pillow', 'pytesseract'])
    from PIL import Image
    import pytesseract

def extract_text_from_images(image_dir):
    """Extract text from all PNG images in the specified directory."""
    
    image_dir = Path(image_dir)
    image_files = sorted(image_dir.glob("Screenshot*.png"))
    
    results = []
    
    for i, img_path in enumerate(image_files, 1):
        print(f"Processing {i}/{len(image_files)}: {img_path.name}")
        
        try:
            # Open image and extract text
            img = Image.open(img_path)
            text = pytesseract.image_to_string(img)
            
            results.append({
                'filename': img_path.name,
                'text': text.strip(),
                'index': i
            })
            
        except Exception as e:
            print(f"Error processing {img_path.name}: {e}")
            results.append({
                'filename': img_path.name,
                'text': f"[ERROR: Could not extract text - {e}]",
                'index': i
            })
    
    return results

def save_extracted_text(results, output_file):
    """Save extracted text to a file."""
    with open(output_file, 'w', encoding='utf-8') as f:
        for result in results:
            f.write(f"\n{'='*80}\n")
            f.write(f"IMAGE {result['index']}: {result['filename']}\n")
            f.write(f"{'='*80}\n\n")
            f.write(result['text'])
            f.write("\n\n")

if __name__ == "__main__":
    # Extract text from figs folder
    figs_dir = Path(__file__).parent.parent / "figs"
    output_file = Path(__file__).parent.parent / "extracted_text.txt"
    
    print(f"Extracting text from images in: {figs_dir}")
    results = extract_text_from_images(figs_dir)
    
    print(f"\nSaving results to: {output_file}")
    save_extracted_text(results, output_file)
    
    print(f"\nDone! Processed {len(results)} images.")
    print(f"Output saved to: {output_file}")
