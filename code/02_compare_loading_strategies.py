"""
Compare Eager vs Lazy Loading in Polars
Demonstrate the timing difference between read_parquet() and scan_parquet()
"""

import polars as pl
from pathlib import Path
import time

SERVER_PATH = '/srv/corpora/rnz-climate.corpus'
LOCAL_PATH  = 'D:/github/DIGI405/data_raw/nzd-climate'
BASE_PATH   = Path(LOCAL_PATH)


 
print("POLARS LOADING STRATEGY COMPARISON")
 
print()

# Test file: tokens.parquet (21 MB, 6.4M rows)
test_file = BASE_PATH / 'tokens.parquet'

print(f"Testing with: {test_file.name}")
print(f"File size: {test_file.stat().st_size / (1024*1024):.2f} MB")
print()

# EAGER LOADING - pl.read_parquet()
print("-" * 80)
print("EAGER LOADING: pl.read_parquet()")
print("-" * 80)

start = time.perf_counter()
tokens_eager = pl.read_parquet(test_file)
end = time.perf_counter()
eager_time = end - start

print(f"Time to load: {eager_time:.4f} seconds")
print(f"Data loaded: {tokens_eager.shape[0]:,} rows × {tokens_eager.shape[1]} columns")
print(f"Memory: Data is in RAM immediately")
print()

# LAZY LOADING - pl.scan_parquet()
print("-" * 80)
print("LAZY LOADING: pl.scan_parquet() + .collect()")
print("-" * 80)

# Step 1: Create lazy frame (should be instant)
start_scan = time.perf_counter()
tokens_lazy = pl.scan_parquet(test_file)
end_scan = time.perf_counter()
scan_time = end_scan - start_scan

print(f"Step 1 - Create lazy frame: {scan_time:.6f} seconds (near instant)")
print(f"Memory: No data loaded yet - just query plan")
print()

# Step 2: Execute and collect (actual loading happens here)
start_collect = time.perf_counter()
tokens_lazy_result = tokens_lazy.collect()
end_collect = time.perf_counter()
collect_time = end_collect - start_collect

print(f"Step 2 - Execute .collect(): {collect_time:.4f} seconds")
print(f"Data loaded: {tokens_lazy_result.shape[0]:,} rows × {tokens_lazy_result.shape[1]} columns")
print()

total_lazy_time = scan_time + collect_time
print(f"Total lazy time: {total_lazy_time:.4f} seconds")
print()

# LAZY LOADING WITH OPTIMISATION
print("-" * 80)
print("LAZY LOADING WITH QUERY OPTIMISATION")
print("-" * 80)
print("Example: Only select 2 columns instead of all 4")
print()

start_opt = time.perf_counter()
tokens_optimised = (
    pl.scan_parquet(test_file)
    .select(['orth_index', 'token2doc_index'])  # Only 2 columns
    .collect()
)
end_opt = time.perf_counter()
opt_time = end_opt - start_opt

print(f"Time to load (2 columns only): {opt_time:.4f} seconds")
print(f"Data loaded: {tokens_optimised.shape[0]:,} rows × {tokens_optimised.shape[1]} columns")
print()

# SUMMARY
 
print("SUMMARY")
 
print(f"Eager loading (all columns):     {eager_time:.4f} seconds")
print(f"Lazy loading (all columns):      {total_lazy_time:.4f} seconds")
print(f"Lazy loading (2 columns only):   {opt_time:.4f} seconds")
print()
print(f"Optimisation benefit: {(eager_time - opt_time) / eager_time * 100:.1f}% faster")
print()
print("KEY INSIGHT:")
print("- Lazy loading allows query optimisation before execution")
print("- For large files, selecting only needed columns is much faster")
print("- Eager loading is simpler for small files or when all data is needed")
