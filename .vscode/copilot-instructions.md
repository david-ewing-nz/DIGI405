# GitHub Copilot Instructions for DIGI405

Note: A living document - Update it as the project evolves, assignment details emerge. Currently it is a guess as to what the project will look like, but it will be updated as the course progresses.

## Communication Preferences
- Use third person only - Avoid using "you" in all communications. Refer to the user in third person.
- Do not generate code until explicitly requested by the user.
- Planning time means dialogue is required, not code generation.
- Use British English in comments and text (analyse, organise, behaviour, colour, etc.)
- Commands and function names remain in American English (e.g., os.mkdir, analyze_data)
- Once a comment is edited by the user, do not rewrite it.
- Review means to examine and report on content, not to change or edit files.
- leave all english errors in comments and text, do not correct them.
- Ask permission before installing any packages or software

## Comment Style in Files
Generate comments following the style in 01_explore_corpus_structure.py:
- Minimal and informal - working notes rather than formal documentation
- Sparse formatting - basic markdown only, no decorative elements
- Concise language - short phrases, incomplete sentences where meaning is clear
- Functional and information-dense - no explanatory padding
- No decorative separator lines (print("=" * 80)) around section titles 

## Coding Style
- Align consecutive equals signs where possible 
- Use SERVER_PATH/LOCAL_PATH/BASE_PATH pattern for environment switching:
  ```python
  SERVER_PATH = '/srv/corpora/rnz-climate.corpus'
  LOCAL_PATH  = 'D:/github/DIGI405/data_raw/nzd-climate/rnz-climate.corpus'
  BASE_PATH   = LOCAL_PATH  # or SERVER_PATH, depending on where the corpus is stored
  ```
  This allows easy switching between JupyterHub and local environments without searching for paths throughout the code. 

## Output Formatting and Alignment
When creating text-based output files (e.g., frequency tables, comparative analyses):
- **Column alignment is critical** - All columns must align properly under their headers
- Keep total line width under 78-80 characters to prevent wrapping in standard terminals
- Use consistent column widths throughout each table
- Test alignment by viewing output in terminal before finalising
- For comparative analyses showing multiple corpora side-by-side:
  - Align numeric columns right-justified
  - Align text columns left-justified
  - Group related columns visually (e.g., Frequency columns together, then normalized frequency columns, then statistical measures)
  - Example format for comparisons:
    ```
    Term          Nat Freq  Int Freq  Norm Nat  Norm Int  RelRisk  LogRat  LogLik
                                        (per M)   (per M)
    ----------------------------------------------------------------------------
    climate         15,534    13,963    4418.2    6500.1     0.68   -0.56  1082.0
    ```
- Use separator lines that match the full width of the data rows
- When headers would exceed 80 chars, abbreviate column names (e.g., "RelRisk" not "Relative Risk")

## Project Context
This corpus linguistics project focusing on climate change discourse analysis using RNZ (Radio New Zealand) news articles.

## Conc by Dr Geoff Ford
- Conc: Custom Python library for corpus linguistics analysis in Jupyter notebooks
  - Developed by Dr Geoff Ford at University of Canterbury
  - Currently in beta (v1.0.2+)
  - Uses Polars dataframes and Parquet file format for efficiency 
- spaCy: Used by Conc for tokenisation

## Data Structure
- Source Data: RNZ climate corpus at /srv/source-data/  
- Corpora: source data at /srv/corpora/  
  - rnz-climate.corpus - main corpus (11,000+ documents, 6.4M tokens)
  - rnz-climate-national.corpus - domestic NZ news
  - rnz-climate-international.corpus - world news
  - rnz.listcorpus - reference corpus for keywords analysis (general news articles from RNZ)
- Local Data: Downloaded corpus at D:\github\DIGI405\data_raw\nzd-climate\
- Format: Parquet files (compressed columnar storage format)

## Environment
- JupyterHub: Unix-based server environment for analysis
- Local: Windows machine for development and results
- Python installed on D: drive
- Do not install or load software onto C: drive
- XeLaTeX is installed - preference for using xelatex when exporting notebooks to PDF

## Initial attempt at Corpus Analysis Methods (replicating the lab exercises and building on them)
Focus on these core corpus linguistics techniques:
1. Frequency analysis
2. Concordancing (KWIC)
3. Collocations
4. N-grams
5. Keywords analysis

## Library Usage 

### On JupyterHub (Conc)
```python
from conc.corpus import Corpus
from conc.conc import Conc

# Load corpus from server
corpus = Corpus().load('/srv/corpora/rnz-climate.corpus')

# Initialise analysis
conc = Conc(corpus)

# Common operations
conc.frequencies()
conc.concordance('climate')
conc.collocations()
conc.ngrams()
conc.keywords(reference_corpus)
```

### On Local Machine (Polars)
```python
import polars as pl
import time

# Local path
base_path = 'D:/github/DIGI405/data_raw/nzd-climate'

# Load parquet files
vocab    = pl.read_parquet(f'{base_path}/vocab.parquet')      # eager
tokens   = pl.scan_parquet(f'{base_path}/tokens.parquet')     # lazy
metadata = pl.read_parquet(f'{base_path}/metadata.parquet')

# Analyse
vocab.filter(pl.col('frequency_lower') > 100)
metadata.group_by('year').agg(pl.count())
```

## File Organisation
- corpus-analysis-labs-1.0.2/: Lab notebooks and exercises
- data_raw/: Raw data files
- data_processed/: Processed datasets
- scripts/: Analysis and utility scripts
- results/: Analysis outputs and reports
- reference/: Course materials and assignment specifications
- code/: Working analysis scripts

## Coding Preferences
- Use Conc library methods over raw NLTK/spaCy when appropriate
- Follow Jupyter notebook conventions for analysis
- Keep code pedagogical and well-commented
- Prefer Polars over Pandas when working with Conc data structures

## Assignment Focus
Climate change discourse in New Zealand media using RNZ corpus - specific assignment details pending.
 