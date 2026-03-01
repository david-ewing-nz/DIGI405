"""
Build RNZ Climate National and International Conc Corpora from CSV files
"""
from conc.corpus import Corpus
from pathlib import Path
import polars as pl
import tempfile
import shutil

# Paths
DATA_PATH = Path('D:/github/DIGI405/data_raw')
CORPORA_PATH = Path('D:/github/DIGI405/corpora')

# Load CSV files
print("Loading CSV files...")
national_df = pl.read_csv(DATA_PATH / 'rnz_climate_national.csv.gz')
international_df = pl.read_csv(DATA_PATH / 'rnz_climate_international.csv.gz')

print(f"National: {len(national_df):,} articles")
print(f"International: {len(international_df):,} articles")

def build_corpus_from_df(df, corpus_name, description):
    """Build a Conc corpus from a dataframe with fulltext column"""
    print(f"\nBuilding {corpus_name}...")
    
    # Create temporary directory for text files
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        
        # Write each article to a separate text file
        print(f"Writing {len(df):,} text files...")
        for i, row in enumerate(df.iter_rows(named=True)):
            if row['fulltext']:
                # Use article ID if available, otherwise use index
                article_id = row.get('id', i)
                filename = f"{article_id}.txt"
                file_path = temp_path / filename
                file_path.write_text(row['fulltext'], encoding='utf-8')
        
        # Build corpus from text files
        print(f"Building corpus (this may take several minutes)...")
        corpus = Corpus(
            name=corpus_name,
            description=description
        ).build_from_files(
            str(temp_path),
            str(CORPORA_PATH) + '/'
        )
        
        print(f"Corpus saved")
        return corpus

# Build national corpus
national_corpus = build_corpus_from_df(
    national_df,
    corpus_name='RNZ Climate National',
    description='Radio New Zealand climate coverage focusing on domestic New Zealand news (2008-2024)'
)

# Build international corpus  
international_corpus = build_corpus_from_df(
    international_df,
    corpus_name='RNZ Climate International',
    description='Radio New Zealand climate coverage focusing on international/world news (2008-2024)'
)

print("\n" + "="*60)
print("Both corpora built successfully!")
print("="*60)
print(f"\nNational corpus:")
national_corpus.summary()
print(f"\nInternational corpus:")
international_corpus.summary()
