# Corpus Analysis Script

## Overview

`analyze_corpus.py` provides functions for analyzing Conc corpus objects. All functions take a **Corpus object** as input and return structured results (DataFrames, dictionaries).

## Functions Available

### 1. Basic Metrics

```python
get_basic_metrics(corpus) -> dict
```

Returns:
- `name`, `description`
- `num_documents`, `total_tokens`, `total_types`
- `avg_tokens_per_doc`
- `type_token_ratio` (lexical diversity)

### 2. Type-Token Ratio

```python
calculate_ttr(corpus, first_n_tokens=None) -> float
```

Calculate lexical diversity (0.0-1.0, higher = more diverse).

### 3. Frequency Table

```python
get_frequency_table(corpus, 
                    exclude_punctuation=True,
                    exclude_tokens=None,
                    restrict_tokens=None,
                    min_freq=1,
                    normalize_by=1000,
                    top_n=None) -> DataFrame
```

Returns DataFrame with: `rank`, `token`, `frequency`, `normalized_frequency`

### 4. Concordance (KWIC)

```python
get_concordance(corpus, 
                query='earthquake',
                context_length=8,
                max_results=None) -> DataFrame
```

Returns DataFrame with: `left_context`, `node`, `right_context`, `document`

### 5. Collocations

```python
get_collocations(corpus,
                 node='earthquake',
                 measure='MI',
                 window=5,
                 min_freq=5,
                 top_n=None) -> DataFrame
```

Returns DataFrame with: `collocate`, `collocate_frequency`, `total_frequency`, `mutual_information`, `log_likelihood`, `t_score`

### 6. Keywords

```python
get_keywords(corpus,
             reference_corpus,
             measure='LLR',
             min_freq=5,
             top_n=None) -> DataFrame
```

Returns DataFrame with: `keyword`, `freq_target`, `freq_reference`, `normalized_target`, `normalized_reference`, `relative_risk`, `log_likelihood`, `effect_size`

### 7. N-grams

```python
get_ngrams(corpus,
           n=2,
           min_freq=5,
           exclude_punctuation=True,
           top_n=None) -> DataFrame
```

Returns DataFrame with: `ngram`, `frequency`, `normalized_frequency`

### 8. Full Analysis Export

```python
export_full_analysis(corpus,
                     output_dir='analysis_output/',
                     reference_corpus=None,
                     top_n=100)
```

Exports multiple CSV files:
- `metrics.csv` / `metrics.json`
- `frequencies.csv`
- `bigrams.csv`
- `trigrams.csv`
- `keywords.csv` (if reference provided)

### 9. Compare Corpora

```python
compare_corpora(corpus1, corpus2,
                corpus1_name='Corpus 1',
                corpus2_name='Corpus 2') -> DataFrame
```

Returns side-by-side comparison table.

---

## Usage Examples

### Example 1: Basic Analysis

```python
from conc.corpus import Corpus
from scripts.analyze_corpus import *

# Load corpus
corpus = Corpus().load('./corpora/my-corpus.corpus')

# Get basic metrics
metrics = get_basic_metrics(corpus)
print(f"Corpus: {metrics['name']}")
print(f"Documents: {metrics['num_documents']:,}")
print(f"Tokens: {metrics['total_tokens']:,}")
print(f"Types: {metrics['total_types']:,}")
print(f"TTR: {metrics['type_token_ratio']:.4f}")

# Calculate lexical diversity
ttr = calculate_ttr(corpus)
print(f"Lexical diversity: {ttr*100:.2f}%")
```

### Example 2: Frequency Analysis

```python
# Get top 100 most frequent words (excluding punctuation)
freq_df = get_frequency_table(
    corpus,
    exclude_punctuation=True,
    top_n=100
)

# Save to CSV
freq_df.to_csv('top_100_words.csv', index=False)

# Display top 10
print(freq_df.head(10))
```

### Example 3: Concordance Analysis

```python
# Find all occurrences of "earthquake"
conc_df = get_concordance(
    corpus,
    query='earthquake',
    context_length=8,
    max_results=500
)

# Save to CSV
conc_df.to_csv('earthquake_concordance.csv', index=False)

# Display first 5
print(conc_df.head())
```

### Example 4: Collocation Analysis

```python
# Find words that commonly appear with "earthquake"
coll_df = get_collocations(
    corpus,
    node='earthquake',
    measure='MI',
    window=5,
    min_freq=5,
    top_n=50
)

# Save to CSV
coll_df.to_csv('earthquake_collocations.csv', index=False)

# Display top collocates
print(coll_df.head(10))
```

### Example 5: Keyword Analysis

```python
# Compare two corpora
target = Corpus().load('./corpora/quake-stories.corpus')
reference = Corpus().load('./corpora/brown.corpus')

# Get keywords (distinctive words in target vs reference)
keywords_df = get_keywords(
    target,
    reference,
    measure='LLR',
    top_n=100
)

# Save to CSV
keywords_df.to_csv('distinctive_keywords.csv', index=False)

# Show words that are 10x more common in target
high_rr = keywords_df[keywords_df['relative_risk'] > 10]
print(high_rr)
```

### Example 6: N-gram Analysis

```python
# Get most common bigrams
bigrams = get_ngrams(corpus, n=2, top_n=100)
bigrams.to_csv('top_bigrams.csv', index=False)

# Get most common trigrams
trigrams = get_ngrams(corpus, n=3, top_n=100)
trigrams.to_csv('top_trigrams.csv', index=False)

# Get 4-grams
fourgrams = get_ngrams(corpus, n=4, top_n=50)
print(fourgrams.head())
```

### Example 7: Full Export

```python
# Export everything at once
export_full_analysis(
    corpus,
    output_dir='analysis_results/',
    reference_corpus=None,  # Optional
    top_n=200
)

# Creates:
# - analysis_results/metrics.csv
# - analysis_results/metrics.json
# - analysis_results/frequencies.csv
# - analysis_results/bigrams.csv
# - analysis_results/trigrams.csv
# - analysis_results/keywords.csv (if reference provided)
```

### Example 8: Compare Two Corpora

```python
student_writing = Corpus().load('./corpora/student-essays.corpus')
professional_writing = Corpus().load('./corpora/news-articles.corpus')

comparison = compare_corpora(
    student_writing,
    professional_writing,
    corpus1_name='Student Writing',
    corpus2_name='Professional Writing'
)

print(comparison)
comparison.to_csv('corpus_comparison.csv', index=False)
```

---

## Command-Line Usage

```powershell
# Basic analysis
python scripts\analyze_corpus.py path/to/my.corpus

# Specify output directory
python scripts\analyze_corpus.py path/to/my.corpus --output results/

# Include keyword analysis with reference corpus
python scripts\analyze_corpus.py path/to/target.corpus `
    --reference path/to/reference.corpus `
    --output results/

# Customize number of top results
python scripts\analyze_corpus.py path/to/my.corpus --top-n 200
```

---

## Complete Workflow: Scrape → Build → Analyze

```python
from conc.corpus import Corpus
from scripts.scrape_webpages_to_corpus import scrape_urls_to_csv, build_corpus_from_csv
from scripts.analyze_corpus import export_full_analysis

# 1. Scrape web pages
urls = ['https://example.com/article1', 'https://example.com/article2']
scrape_urls_to_csv(urls, 'web_data.csv')

# 2. Build corpus
corpus = build_corpus_from_csv(
    'web_data.csv',
    corpus_name='Web Articles',
    corpus_description='Articles from example.com',
    save_path='./corpora/'
)

# 3. Analyze corpus
export_full_analysis(
    corpus,
    output_dir='analysis_results/',
    top_n=100
)

# Done! All results in analysis_results/
```

---

## Integration with Lab Exercises

The functions in `analyze_corpus.py` mirror the Conc methods used in the labs:

| Lab Method | Script Function |
|------------|-----------------|
| `conc.frequencies().display()` | `get_frequency_table(corpus)` |
| `conc.concordance(query).display()` | `get_concordance(corpus, query)` |
| `conc.collocations(node).display()` | `get_collocations(corpus, node)` |
| `conc.keywords().display()` | `get_keywords(corpus, reference)` |
| `conc.clusters(n).display()` | `get_ngrams(corpus, n)` |

**Difference:** Script functions return **DataFrames** instead of displaying in notebook.

---

## Output Format Examples

### metrics.csv
```csv
name,description,num_documents,total_tokens,total_types,avg_tokens_per_doc,type_token_ratio
My Corpus,Web articles,50,125430,8234,2508.6,0.0656
```

### frequencies.csv
```csv
rank,token,frequency,normalized_frequency
1,the,8421,67.12
2,and,5231,41.70
3,to,4892,39.00
```

### concordance.csv
```csv
left_context,node,right_context,document
the ground began to,earthquake,struck at 12:51 pm,doc_001
after the devastating,earthquake,many buildings collapsed,doc_002
```

### collocations.csv
```csv
collocate,collocate_frequency,total_frequency,mutual_information,log_likelihood,t_score
devastating,45,52,8.23,234.5,6.7
major,38,156,6.12,187.3,5.9
```

---

## Notes

- All functions return **pandas DataFrames** for easy manipulation and export
- Functions handle errors gracefully and log progress
- Can be used programmatically or via command line
- Compatible with all Conc corpus objects
- Export formats: CSV, JSON

---

## Requirements

```powershell
pip install conc pandas
```
