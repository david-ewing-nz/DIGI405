"""
example_complete_workflow.py

Complete workflow demonstrating:
1. Scrape web pages
2. Build corpus
3. Analyze corpus
4. Export results

Run this script to see the full pipeline in action.

Requirements:
    pip install beautifulsoup4 requests conc pandas
"""

from pathlib import Path
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)


def example_workflow():
    """
    Complete example: scrape → build → analyze
    """
    
    print("=" * 70)
    print("COMPLETE CORPUS ANALYSIS WORKFLOW")
    print("=" * 70)
    print()
    
    # ========================================================================
    # STEP 1: Scrape Web Pages
    # ========================================================================
    print("STEP 1: Scraping web pages...")
    print("-" * 70)
    
    from scripts.scrape_webpages_to_corpus import scrape_webpage_to_text
    
    # Example URLs (replace with your own)
    urls = [
        'https://en.wikipedia.org/wiki/2011_Christchurch_earthquake',
        'https://en.wikipedia.org/wiki/Natural_disaster',
        'https://en.wikipedia.org/wiki/Earthquake'
    ]
    
    # Create output directory
    text_dir = Path('example_texts')
    text_dir.mkdir(exist_ok=True)
    
    # Scrape each URL
    for i, url in enumerate(urls):
        output_file = text_dir / f'article_{i:03d}.txt'
        logger.info(f"Scraping {url}")
        
        text = scrape_webpage_to_text(str(url), str(output_file))
        
        if text:
            logger.info(f"✓ Saved to {output_file}")
        
        # Be polite
        import time
        time.sleep(1)
    
    print()
    
    # ========================================================================
    # STEP 2: Build Corpus
    # ========================================================================
    print("STEP 2: Building corpus...")
    print("-" * 70)
    
    from conc.corpus import Corpus
    
    corpus = Corpus(
        name='Example Web Corpus',
        description='Articles scraped from Wikipedia for demonstration'
    ).build_from_files(
        str(text_dir) + '/',
        './example_corpora/'
    )
    
    logger.info(f"✓ Corpus built successfully!")
    logger.info(f"  Documents: {corpus.num_documents}")
    logger.info(f"  Total tokens: {corpus.total_tokens:,}")
    logger.info(f"  Total types: {corpus.total_types:,}")
    
    print()
    
    # ========================================================================
    # STEP 3: Analyze Corpus
    # ========================================================================
    print("STEP 3: Analyzing corpus...")
    print("-" * 70)
    
    from scripts.analyze_corpus import (
        get_basic_metrics,
        calculate_ttr,
        get_frequency_table,
        get_concordance,
        get_ngrams,
        export_full_analysis
    )
    
    # 3a. Basic metrics
    print("\n3a. Basic Metrics:")
    metrics = get_basic_metrics(corpus)
    print(f"  Corpus: {metrics['name']}")
    print(f"  Documents: {metrics['num_documents']}")
    print(f"  Total tokens: {metrics['total_tokens']:,}")
    print(f"  Total types: {metrics['total_types']:,}")
    print(f"  Avg tokens/doc: {metrics['avg_tokens_per_doc']:.1f}")
    print(f"  Type-Token Ratio: {metrics['type_token_ratio']:.4f}")
    
    # 3b. Lexical diversity
    print("\n3b. Lexical Diversity:")
    ttr = calculate_ttr(corpus)
    print(f"  TTR: {ttr:.4f} ({ttr*100:.2f}%)")
    
    # 3c. Top 20 most frequent words
    print("\n3c. Top 20 Most Frequent Words:")
    freq_df = get_frequency_table(corpus, exclude_punctuation=True, top_n=20)
    print(freq_df.to_string(index=False))
    
    # 3d. Concordance for "earthquake" (if it exists)
    print("\n3d. Sample Concordance for 'earthquake':")
    try:
        conc_df = get_concordance(corpus, 'earthquake', max_results=5)
        if len(conc_df) > 0:
            for idx, row in conc_df.iterrows():
                print(f"  ...{row['left_context']} [{row['node']}] {row['right_context']}...")
        else:
            print("  (No occurrences found)")
    except:
        print("  (Could not generate concordance)")
    
    # 3e. Top bigrams
    print("\n3e. Top 10 Bigrams:")
    bigrams = get_ngrams(corpus, n=2, top_n=10)
    if len(bigrams) > 0:
        print(bigrams.to_string(index=False))
    
    print()
    
    # ========================================================================
    # STEP 4: Export Full Analysis
    # ========================================================================
    print("STEP 4: Exporting full analysis...")
    print("-" * 70)
    
    export_full_analysis(
        corpus,
        output_dir='example_analysis_results/',
        top_n=100
    )
    
    print()
    print("=" * 70)
    print("WORKFLOW COMPLETE!")
    print("=" * 70)
    print()
    print("Generated files:")
    print("  example_texts/                  - Scraped text files")
    print("  example_corpora/                - Built corpus")
    print("  example_analysis_results/       - Analysis CSV files")
    print()
    print("Next steps:")
    print("  1. Open CSV files in Excel/Pandas")
    print("  2. Visualize results")
    print("  3. Compare with reference corpus")
    print()


def example_with_reference_corpus():
    """
    Example showing keyword analysis with reference corpus
    """
    
    print("=" * 70)
    print("KEYWORD ANALYSIS WITH REFERENCE CORPUS")
    print("=" * 70)
    print()
    
    from conc.corpus import Corpus
    from scripts.analyze_corpus import get_keywords, compare_corpora
    
    # Load your corpus
    try:
        target = Corpus().load('./example_corpora/example-web-corpus.corpus')
        print(f"✓ Loaded target corpus: {target.name}")
        print(f"  Tokens: {target.total_tokens:,}")
        print()
    except:
        print("✗ Could not load example corpus. Run example_workflow() first.")
        return
    
    # Load reference corpus (if available)
    try:
        # Try to load Brown corpus (if you have it)
        reference = Corpus().load('./corpora/brown.corpus')
        print(f"✓ Loaded reference corpus: {reference.name}")
        print(f"  Tokens: {reference.total_tokens:,}")
        print()
    except:
        print("✗ Reference corpus not available")
        print("  To use keyword analysis, you need a reference corpus")
        print("  Try building Brown corpus from NLTK")
        return
    
    # Compare basic metrics
    print("Comparison:")
    print("-" * 70)
    comparison = compare_corpora(target, reference, 'Target', 'Reference')
    print(comparison.to_string(index=False))
    print()
    
    # Get keywords
    print("Top 20 Keywords (distinctive words in target vs reference):")
    print("-" * 70)
    keywords_df = get_keywords(target, reference, top_n=20)
    print(keywords_df[['keyword', 'freq_target', 'relative_risk', 'log_likelihood']])
    print()
    
    # Export
    keywords_df.to_csv('example_keywords.csv', index=False)
    print("✓ Saved to example_keywords.csv")
    print()


def example_custom_analysis():
    """
    Example showing custom analysis with specific parameters
    """
    
    print("=" * 70)
    print("CUSTOM ANALYSIS EXAMPLES")
    print("=" * 70)
    print()
    
    from conc.corpus import Corpus
    from scripts.analyze_corpus import get_frequency_table, get_concordance, get_collocations
    import pandas as pd
    
    # Load corpus
    try:
        corpus = Corpus().load('./example_corpora/example-web-corpus.corpus')
    except:
        print("✗ Could not load corpus. Run example_workflow() first.")
        return
    
    # Example 1: Frequency analysis excluding stopwords
    print("Example 1: Frequencies without stopwords")
    print("-" * 70)
    
    from conc.core import get_stop_words
    stopwords = get_stop_words()
    
    freq_no_stop = get_frequency_table(
        corpus,
        exclude_punctuation=True,
        exclude_tokens=stopwords,
        top_n=20
    )
    print(freq_no_stop.to_string(index=False))
    print()
    
    # Example 2: Find all technical terms (capitalized words)
    print("Example 2: Capitalized words (potential proper nouns)")
    print("-" * 70)
    
    # Get all frequencies
    all_freq = get_frequency_table(corpus, exclude_punctuation=True, min_freq=2)
    
    # Filter for capitalized words
    capitalized = all_freq[all_freq['token'].str[0].str.isupper()]
    print(capitalized.head(10).to_string(index=False))
    print()
    
    # Example 3: Words ending in -tion (nominalizations)
    print("Example 3: Words ending in -tion")
    print("-" * 70)
    
    tion_words = all_freq[all_freq['token'].str.endswith('tion')]
    print(tion_words.head(10).to_string(index=False))
    print()
    
    # Example 4: Search for multiple terms
    print("Example 4: Specific vocabulary items")
    print("-" * 70)
    
    search_terms = ['disaster', 'earthquake', 'damage', 'geological']
    specific_freq = get_frequency_table(
        corpus,
        restrict_tokens=search_terms
    )
    print(specific_freq.to_string(index=False))
    print()


if __name__ == '__main__':
    import sys
    
    print()
    print("Choose an example to run:")
    print("  1. Complete workflow (scrape → build → analyze)")
    print("  2. Keyword analysis with reference corpus")
    print("  3. Custom analysis examples")
    print()
    
    choice = input("Enter number (1-3): ").strip()
    
    if choice == '1':
        example_workflow()
    elif choice == '2':
        example_with_reference_corpus()
    elif choice == '3':
        example_custom_analysis()
    else:
        print("Invalid choice. Running complete workflow...")
        example_workflow()
