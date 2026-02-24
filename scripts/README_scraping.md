# Web Scraping Script for Corpus Building

## Files Created

- **scrape_webpages_to_corpus.py** - Main script for web scraping
- **example_urls.txt** - Example URLs file format

## Installation

```powershell
pip install beautifulsoup4 requests newspaper3k lxml pandas conc
```

## Usage Examples

### 1. Scrape a Single URL

```powershell
python scripts\scrape_webpages_to_corpus.py --url "https://example.com/article" --output web_texts\
```

### 2. Scrape Multiple URLs from File

Create a text file with URLs (one per line):

```
https://example.com/article1
https://example.com/article2
https://example.com/article3
```

Then run:

```powershell
python scripts\scrape_webpages_to_corpus.py --urls-file urls.txt --output web_texts\
```

### 3. Scrape and Build Corpus

```powershell
python scripts\scrape_webpages_to_corpus.py --urls-file urls.txt --output web_texts\ --build-corpus --name "My Web Corpus" --description "Articles from example.com"
```

### 4. Save to CSV Instead of Text Files

```powershell
python scripts\scrape_webpages_to_corpus.py --urls-file urls.txt --csv web_corpus.csv
```

### 5. Use CSS Selector to Target Specific Content

```powershell
# Target by class name
python scripts\scrape_webpages_to_corpus.py --url "https://example.com" --output web_texts\ --selector "article-body" --selector-type class

# Target by ID
python scripts\scrape_webpages_to_corpus.py --url "https://example.com" --output web_texts\ --selector "main-content" --selector-type id

# Target by HTML tag
python scripts\scrape_webpages_to_corpus.py --url "https://example.com" --output web_texts\ --selector "article" --selector-type tag
```

### 6. Add Delay Between Requests (Be Polite)

```powershell
python scripts\scrape_webpages_to_corpus.py --urls-file urls.txt --output web_texts\ --delay 2.0
```

## Command Line Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `--url` | Single URL to scrape | No* |
| `--urls-file` | File with URLs (one per line) | No* |
| `--output` | Output directory for text files | Yes |
| `--csv` | Save to CSV instead of text files | No |
| `--selector` | CSS selector for content extraction | No |
| `--selector-type` | Type of selector: tag, class, or id | No |
| `--delay` | Delay between requests in seconds (default: 1.0) | No |
| `--build-corpus` | Build a Conc corpus after scraping | No |
| `--name` | Corpus name (if building corpus) | No |
| `--description` | Corpus description (if building corpus) | No |
| `--corpus-path` | Path to save corpus (default: ./corpora/) | No |

*Must provide either `--url` or `--urls-file`

## What Gets Removed

The script automatically removes common formatting elements:

- `<script>` - JavaScript code
- `<style>` - CSS styling
- `<nav>` - Navigation menus
- `<footer>` - Page footers
- `<header>` - Page headers
- `<aside>` - Sidebars
- `<noscript>` - Non-script content

## Functions Available for Import

You can also import and use the functions in your own scripts:

```python
from scripts.scrape_webpages_to_corpus import (
    scrape_webpage_to_text,
    scrape_with_css_selector,
    scrape_news_article,
    scrape_urls_to_csv,
    build_corpus_from_texts,
    build_corpus_from_csv
)

# Example: Scrape single page
text = scrape_webpage_to_text(
    url="https://example.com/article",
    output_file="articles/article_001.txt"
)

# Example: Build corpus from scraped files
corpus = build_corpus_from_texts(
    text_dir="articles/",
    corpus_name="My Corpus",
    corpus_description="Articles from example.com",
    save_path="./corpora/"
)
```

## Output Structure

### Text Files Output

```
web_texts/
├── doc_0000.txt
├── doc_0001.txt
├── doc_0002.txt
└── ...
```

### CSV Output

```csv
doc_id,url,title,text
doc_0000,https://example.com/article1,Article Title,"The actual text content here..."
doc_0001,https://example.com/article2,Another Title,"More clean text content..."
```

### Corpus Output (if --build-corpus used)

```
corpora/
└── my-web-corpus.corpus/
    ├── metadata.json
    ├── vocabulary.json
    ├── documents.json
    ├── tokens/
    └── index/
```

## Notes

- **Be polite**: Use `--delay` to avoid overwhelming servers (default is 1 second)
- **Check robots.txt**: Respect website scraping policies
- **User agent**: Script uses a legitimate browser user agent
- **Error handling**: Failed URLs are logged but don't stop the script
- **Encoding**: All files saved as UTF-8

## Troubleshooting

**"Module not found" errors:**
```powershell
pip install beautifulsoup4 requests newspaper3k lxml pandas conc
```

**"Permission denied" when saving:**
- Check directory permissions
- Use a different output directory

**No text extracted:**
- Try using `--selector` to target specific content
- Check if the page requires JavaScript (this script doesn't execute JS)
- Verify the URL is accessible

**Rate limiting / blocked:**
- Increase `--delay` value
- Check if the site blocks automated access
- Respect robots.txt
