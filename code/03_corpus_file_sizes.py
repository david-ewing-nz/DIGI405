"""
Display Corpus File Sizes
Read all files in the corpus directory and display their sizes in a formatted table
"""

from pathlib import Path

SERVER_PATH = '/srv/corpora/rnz-climate.corpus'
LOCAL_PATH  = 'D:/github/DIGI405/corpora/nzd-climate'
BASE_PATH   = Path(LOCAL_PATH)

file_info = { 
    'corpus.json':      'Corpus metadata',
    'metadata.parquet': 'Document metadata (url, title, date, year, category)',
    'tokens.parquet':   'Token data (6.4M tokens)',
    'vocab.parquet':    'Vocabulary (105K unique tokens)',
    'spaces.parquet':   'Space positions',
    'puncts.parquet':   'Punctuation positions',
    'README.md':        'Documentation'
}


 
print("RNZ CLIMATE CORPUS - FILE SIZES")
 
print()

# Table header
print(f"{'File':<25} {'Size':>12}    {'Description'}")
print("-" * 80)

total_size = 0

# Read and display each file
for filename in sorted(file_info.keys()):
    filepath = BASE_PATH / filename
    
    if filepath.exists():
        # Get file size in bytes
        size_bytes = filepath.stat().st_size
        total_size += size_bytes
        
        # Format size nicely
        if size_bytes < 1024:
            size_str = f"{size_bytes} B"
        elif size_bytes < 1024 * 1024:
            size_str = f"{size_bytes / 1024:.2f} KB"
        else:
            size_str = f"{size_bytes / (1024 * 1024):.2f} MB"
        
        # Get description
        desc = file_info[filename]
        
        # Print row
        print(f"{filename:<25} {size_str:>12}    {desc}")
    else:
        print(f"{filename:<25} {'NOT FOUND':>12}    {file_info[filename]}")

# Print total
print("-" * 80)
total_mb = total_size / (1024 * 1024)
print(f"{'Total':<25} {total_mb:>9.2f} MB")
print()

# Additional statistics
 
print("CORPUS STATISTICS")
 
print(f"Total files: {len(file_info)}")
print(f"Total size: {total_mb:.2f} MB ({total_size:,} bytes)")
print(f"Largest file: tokens.parquet (~77% of total)")
