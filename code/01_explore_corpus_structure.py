"""
Explore RNZ Climate Corpus Structure
Examine the parquet files to understand the corpus data structure
"""

import polars as pl
from pathlib import Path

# Path to the corpus
BASE_PATH = Path('D:/github/DIGI405/corpora/nzd-climate')

# List of parquet files to examine
parquet_files = [
    'vocab.parquet',
    'tokens.parquet', 
    'metadata.parquet',
    'spaces.parquet',
    'puncts.parquet'
]

print("=" * 80)
print("RNZ CLIMATE CORPUS - DATA STRUCTURE EXPLORATION")
print("=" * 80)
print()

for filename in parquet_files:
    filepath = BASE_PATH / filename
    
    print(f"\n{'=' * 80}")
    print(f"FILE: {filename}")
    print(f"{'=' * 80}")
    
    # Load the parquet file
    df = pl.read_parquet(filepath)
    
    # Show dimensions
    print(f"\nDimensions: {df.shape[0]:,} rows × {df.shape[1]} columns")
    
    # Show column names and types
    print(f"\nColumns and Types:")
    for col_name, col_type in zip(df.columns, df.dtypes):
        print(f"  - {col_name}: {col_type}")
    
    # Show first 10 rows
    print(f"\nFirst 10 Rows:")
    print(df.head(10))
    
    # Show file size
    file_size_mb = filepath.stat().st_size / (1024 * 1024)
    print(f"\nFile Size: {file_size_mb:.2f} MB")
    
    print()

print("=" * 80)
print("EXPLORATION COMPLETE")
print("=" * 80)
