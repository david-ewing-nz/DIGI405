# DIGI405 Course Materials

This directory contains lecture slides, reading materials, and other course content captured as screenshots and extracted text.

## Directory Structure

```
course-materials/
├── module-1-text-fundamentals/
│   ├── screenshots/
│   │   └── 2026-02-23/          (52 PNG files)
│   └── extracted-text/
│       └── 2026-02-23-module-1.txt
├── module-2-[topic]/
│   ├── screenshots/
│   └── extracted-text/
└── README.md
```

## Contents

### Module 1: Text Analysis Fundamentals
- **Topics covered:**
  - Tokenization and tokenisation methods (NLTK, spaCy)
  - Tokens vs Types (with British National Corpus examples)
  - Lemmatization and stemming (WordNet, Porter/Snowball stemmers)
  - Function words vs content words
  - Parts of speech tagging (Universal Dependencies, Penn Treebank)
  - NLP libraries: spaCy, NLTK, WordNet
  
- **Source:** Online learning modules/lecture slides
- **Date captured:** 2026-02-23
- **Files:** 52 screenshots + extracted OCR text

## Adding New Materials

When capturing new course content:

1. **Create dated screenshot folder:**
   ```
   module-N-[topic-name]/screenshots/YYYY-MM-DD/
   ```

2. **Save extracted text with descriptive name:**
   ```
   module-N-[topic-name]/extracted-text/YYYY-MM-DD-topic.txt
   ```

3. **Update this README** with module contents

## Relationship to Labs

- **course-materials/** = Theoretical/conceptual content (lectures, readings)
- **corpus-analysis-labs-1.0.2/** = Practical coding exercises (Jupyter notebooks)

The course materials provide the theoretical foundation; the labs provide hands-on practice applying those concepts.

## Text Extraction Scripts

OCR text extraction scripts are located in `../scripts/`:
- `extract_text_from_screenshots.ps1`
- `extract_text_ocr_api.ps1`
