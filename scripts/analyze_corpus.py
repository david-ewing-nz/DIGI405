"""
analyze_corpus.py

Purpose:
    Analyze Conc corpus objects with various metrics and statistical measures.
    All functions take a Corpus object as input and return structured results.

Requirements:
    pip install conc pandas

Usage:
    from conc.corpus import Corpus
    from scripts.analyze_corpus import *
    
    # Load corpus
    corpus = Corpus().load('path/to/my.corpus')
    
    # Get metrics
    metrics = get_basic_metrics(corpus)
    freq_df = get_frequency_table(corpus)
    ttr = calculate_ttr(corpus)

Author: DIGI405 Course Materials
Date: 2026-02-24
"""

import pandas as pd
from typing import Optional, List, Dict, Union
import logging
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def get_basic_metrics(corpus) -> Dict[str, Union[int, float, str]]:
    """
    Get basic corpus metrics.
    
    Arguments:
        corpus: Conc Corpus object
    
    Returns:
        Dictionary with basic metrics:
        - name: Corpus name
        - description: Corpus description
        - num_documents: Number of documents
        - total_tokens: Total word count
        - total_types: Number of unique words
        - avg_tokens_per_doc: Average document length
        - type_token_ratio: Lexical diversity (types/tokens)
    
    Example:
        >>> corpus = Corpus().load('my.corpus')
        >>> metrics = get_basic_metrics(corpus)
        >>> print(f"TTR: {metrics['type_token_ratio']:.4f}")
    """
    try:
        metrics = {
            'name': corpus.name,
            'description': corpus.description,
            'num_documents': corpus.num_documents,
            'total_tokens': corpus.total_tokens,
            'total_types': corpus.total_types,
            'avg_tokens_per_doc': corpus.total_tokens / corpus.num_documents if corpus.num_documents > 0 else 0,
            'type_token_ratio': corpus.total_types / corpus.total_tokens if corpus.total_tokens > 0 else 0
        }
        
        logger.info(f"Corpus: {metrics['name']}")
        logger.info(f"Documents: {metrics['num_documents']:,}")
        logger.info(f"Tokens: {metrics['total_tokens']:,}")
        logger.info(f"Types: {metrics['total_types']:,}")
        logger.info(f"TTR: {metrics['type_token_ratio']:.4f}")
        
        return metrics
        
    except Exception as e:
        logger.error(f"Error getting basic metrics: {e}")
        return {}


def calculate_ttr(corpus, first_n_tokens: Optional[int] = None) -> float:
    """
    Calculate Type-Token Ratio (lexical diversity).
    
    Arguments:
        corpus: Conc Corpus object
        first_n_tokens: Calculate TTR on first N tokens only (for standardization)
    
    Returns:
        TTR value (0.0 to 1.0)
        Higher = more diverse vocabulary
    
    Example:
        >>> ttr = calculate_ttr(corpus)
        >>> print(f"Lexical diversity: {ttr*100:.2f}%")
    """
    try:
        if first_n_tokens:
            # For fair comparison across different-sized corpora
            # (TTR increases with corpus size, so standardize)
            logger.warning("first_n_tokens standardization not fully implemented - using full corpus")
        
        ttr = corpus.total_types / corpus.total_tokens if corpus.total_tokens > 0 else 0.0
        
        logger.info(f"Type-Token Ratio: {ttr:.4f} ({ttr*100:.2f}%)")
        
        return ttr
        
    except Exception as e:
        logger.error(f"Error calculating TTR: {e}")
        return 0.0


def get_frequency_table(corpus, 
                       exclude_punctuation: bool = True,
                       exclude_tokens: Optional[List[str]] = None,
                       restrict_tokens: Optional[List[str]] = None,
                       min_freq: int = 1,
                       normalize_by: int = 1000,
                       top_n: Optional[int] = None) -> pd.DataFrame:
    """
    Get frequency table as pandas DataFrame.
    
    Arguments:
        corpus: Conc Corpus object
        exclude_punctuation: Remove punctuation tokens
        exclude_tokens: List of tokens to exclude (e.g., stopwords)
        restrict_tokens: Only include these tokens
        min_freq: Minimum frequency threshold
        normalize_by: Normalize frequencies per N tokens (e.g., 1000)
        top_n: Return only top N most frequent tokens
    
    Returns:
        DataFrame with columns: rank, token, frequency, normalized_frequency
    
    Example:
        >>> df = get_frequency_table(corpus, exclude_punctuation=True, top_n=100)
        >>> df.to_csv('frequencies.csv', index=False)
    """
    try:
        from conc.conc import Conc
        
        conc = Conc(corpus)
        
        # Get frequency data
        freq_result = conc.frequencies(
            exclude_punctuation=exclude_punctuation,
            exclude_tokens=exclude_tokens or [],
            restrict_tokens=restrict_tokens or [],
            normalize_by=normalize_by
        )
        
        # Convert to DataFrame
        data = []
        rank = 1
        for item in freq_result.results:
            if item['frequency'] >= min_freq:
                data.append({
                    'rank': rank,
                    'token': item['token'],
                    'frequency': item['frequency'],
                    'normalized_frequency': item['normalized_frequency']
                })
                rank += 1
        
        df = pd.DataFrame(data)
        
        if top_n:
            df = df.head(top_n)
        
        logger.info(f"Generated frequency table: {len(df)} tokens")
        
        return df
        
    except Exception as e:
        logger.error(f"Error generating frequency table: {e}")
        return pd.DataFrame()


def get_concordance(corpus, 
                   query: str,
                   context_length: int = 8,
                   max_results: Optional[int] = None) -> pd.DataFrame:
    """
    Get concordance (KWIC) results as DataFrame.
    
    Arguments:
        corpus: Conc Corpus object
        query: Search term
        context_length: Number of words before/after to show
        max_results: Maximum number of concordance lines
    
    Returns:
        DataFrame with columns: left_context, node, right_context, document
    
    Example:
        >>> conc_df = get_concordance(corpus, 'earthquake', max_results=100)
        >>> conc_df.to_csv('earthquake_concordance.csv', index=False)
    """
    try:
        from conc.conc import Conc
        
        conc = Conc(corpus)
        
        # Get concordance
        conc_result = conc.concordance(
            query=query,
            context_length=context_length
        )
        
        # Convert to DataFrame
        data = []
        for i, item in enumerate(conc_result.results):
            if max_results and i >= max_results:
                break
                
            data.append({
                'left_context': ' '.join(item['left']),
                'node': query,
                'right_context': ' '.join(item['right']),
                'document': item.get('doc_id', '')
            })
        
        df = pd.DataFrame(data)
        
        logger.info(f"Generated concordance for '{query}': {len(df)} hits")
        
        return df
        
    except Exception as e:
        logger.error(f"Error generating concordance: {e}")
        return pd.DataFrame()


def get_collocations(corpus,
                    node: str,
                    measure: str = 'MI',
                    window: int = 5,
                    min_freq: int = 5,
                    top_n: Optional[int] = None) -> pd.DataFrame:
    """
    Get collocation analysis results.
    
    Arguments:
        corpus: Conc Corpus object
        node: Target word
        measure: Statistical measure ('MI', 'LLR', 'T')
        window: Context window size (words before/after)
        min_freq: Minimum collocation frequency
        top_n: Return top N collocates
    
    Returns:
        DataFrame with columns: collocate, collocate_freq, total_freq, MI, LLR, T_score
    
    Example:
        >>> coll_df = get_collocations(corpus, 'earthquake', measure='MI', top_n=50)
        >>> coll_df.to_csv('earthquake_collocations.csv', index=False)
    """
    try:
        from conc.conc import Conc
        
        conc = Conc(corpus)
        
        # Get collocations
        coll_result = conc.collocations(
            node=node,
            measure=measure,
            window=window,
            min_freq=min_freq
        )
        
        # Convert to DataFrame
        data = []
        for item in coll_result.results:
            data.append({
                'collocate': item['collocate'],
                'collocate_frequency': item['collocate_frequency'],
                'total_frequency': item['frequency'],
                'mutual_information': item.get('MI', 0),
                'log_likelihood': item.get('LLR', 0),
                't_score': item.get('T', 0)
            })
        
        df = pd.DataFrame(data)
        
        if top_n:
            df = df.head(top_n)
        
        logger.info(f"Generated collocations for '{node}': {len(df)} collocates")
        
        return df
        
    except Exception as e:
        logger.error(f"Error generating collocations: {e}")
        return pd.DataFrame()


def get_keywords(corpus,
                reference_corpus,
                measure: str = 'LLR',
                min_freq: int = 5,
                top_n: Optional[int] = None) -> pd.DataFrame:
    """
    Get keyword analysis comparing two corpora.
    
    Arguments:
        corpus: Conc Corpus object (target)
        reference_corpus: Conc Corpus object (reference)
        measure: Statistical measure ('LLR', 'RR', 'MI')
        min_freq: Minimum frequency in target corpus
        top_n: Return top N keywords
    
    Returns:
        DataFrame with columns: keyword, freq_target, freq_ref, norm_target, 
                               norm_ref, relative_risk, log_likelihood
    
    Example:
        >>> target = Corpus().load('quake-stories.corpus')
        >>> reference = Corpus().load('brown.corpus')
        >>> kw_df = get_keywords(target, reference, top_n=100)
        >>> kw_df.to_csv('keywords.csv', index=False)
    """
    try:
        from conc.conc import Conc
        
        conc = Conc(corpus)
        conc.set_reference_corpus(reference_corpus)
        
        # Get keywords
        kw_result = conc.keywords(
            measure=measure,
            min_freq=min_freq
        )
        
        # Convert to DataFrame
        data = []
        for item in kw_result.results:
            data.append({
                'keyword': item['token'],
                'freq_target': item['frequency'],
                'freq_reference': item['frequency_reference'],
                'normalized_target': item['normalized_frequency'],
                'normalized_reference': item['normalized_frequency_reference'],
                'relative_risk': item.get('RR', 0),
                'log_likelihood': item.get('LLR', 0),
                'effect_size': item.get('effect_size', 0)
            })
        
        df = pd.DataFrame(data)
        
        if top_n:
            df = df.head(top_n)
        
        logger.info(f"Generated keywords: {len(df)} keywords")
        
        return df
        
    except Exception as e:
        logger.error(f"Error generating keywords: {e}")
        return pd.DataFrame()


def get_ngrams(corpus,
              n: int = 2,
              min_freq: int = 5,
              exclude_punctuation: bool = True,
              top_n: Optional[int] = None) -> pd.DataFrame:
    """
    Get n-gram frequency analysis.
    
    Arguments:
        corpus: Conc Corpus object
        n: Size of n-grams (2=bigrams, 3=trigrams, etc.)
        min_freq: Minimum frequency
        exclude_punctuation: Exclude n-grams with punctuation
        top_n: Return top N n-grams
    
    Returns:
        DataFrame with columns: ngram, frequency, normalized_frequency
    
    Example:
        >>> bigrams = get_ngrams(corpus, n=2, top_n=100)
        >>> trigrams = get_ngrams(corpus, n=3, top_n=100)
    """
    try:
        from conc.conc import Conc
        
        conc = Conc(corpus)
        
        # Get n-grams (using clusters function)
        ngram_result = conc.clusters(
            n=n,
            min_freq=min_freq
        )
        
        # Convert to DataFrame
        data = []
        for item in ngram_result.results:
            ngram = ' '.join(item['cluster'])
            
            # Skip if contains punctuation and excluding
            if exclude_punctuation and any(not tok.isalnum() for tok in item['cluster']):
                continue
            
            data.append({
                'ngram': ngram,
                'frequency': item['frequency'],
                'normalized_frequency': item.get('normalized_frequency', 0)
            })
        
        df = pd.DataFrame(data)
        
        if top_n:
            df = df.head(top_n)
        
        logger.info(f"Generated {n}-grams: {len(df)} n-grams")
        
        return df
        
    except Exception as e:
        logger.error(f"Error generating n-grams: {e}")
        return pd.DataFrame()


def export_full_analysis(corpus,
                        output_dir: str,
                        reference_corpus=None,
                        top_n: int = 100):
    """
    Export comprehensive corpus analysis to CSV files.
    
    Arguments:
        corpus: Conc Corpus object
        output_dir: Directory to save CSV files
        reference_corpus: Optional reference corpus for keyword analysis
        top_n: Number of top results to export
    
    Creates files:
        - metrics.csv: Basic corpus metrics
        - frequencies.csv: Token frequency table
        - bigrams.csv: Top bigrams
        - trigrams.csv: Top trigrams
        - keywords.csv: Keywords vs reference (if provided)
    
    Example:
        >>> export_full_analysis(corpus, 'analysis_output/', top_n=200)
    """
    try:
        from pathlib import Path
        import json
        
        # Create output directory
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"Exporting analysis to {output_dir}")
        
        # 1. Basic metrics
        metrics = get_basic_metrics(corpus)
        metrics_df = pd.DataFrame([metrics])
        metrics_df.to_csv(output_path / 'metrics.csv', index=False)
        logger.info(f"Saved metrics.csv")
        
        # Also save as JSON for easy reading
        with open(output_path / 'metrics.json', 'w') as f:
            json.dump(metrics, f, indent=2)
        
        # 2. Frequency table
        freq_df = get_frequency_table(corpus, exclude_punctuation=True, top_n=top_n)
        freq_df.to_csv(output_path / 'frequencies.csv', index=False)
        logger.info(f"Saved frequencies.csv ({len(freq_df)} tokens)")
        
        # 3. Bigrams
        bigrams_df = get_ngrams(corpus, n=2, top_n=top_n)
        bigrams_df.to_csv(output_path / 'bigrams.csv', index=False)
        logger.info(f"Saved bigrams.csv ({len(bigrams_df)} bigrams)")
        
        # 4. Trigrams
        trigrams_df = get_ngrams(corpus, n=3, top_n=top_n)
        trigrams_df.to_csv(output_path / 'trigrams.csv', index=False)
        logger.info(f"Saved trigrams.csv ({len(trigrams_df)} trigrams)")
        
        # 5. Keywords (if reference provided)
        if reference_corpus:
            keywords_df = get_keywords(corpus, reference_corpus, top_n=top_n)
            keywords_df.to_csv(output_path / 'keywords.csv', index=False)
            logger.info(f"Saved keywords.csv ({len(keywords_df)} keywords)")
        
        logger.info(f"Analysis complete! Files saved to {output_dir}")
        
        return True
        
    except Exception as e:
        logger.error(f"Error exporting analysis: {e}")
        return False


def compare_corpora(corpus1, corpus2, 
                   corpus1_name: str = 'Corpus 1',
                   corpus2_name: str = 'Corpus 2') -> pd.DataFrame:
    """
    Compare basic metrics between two corpora.
    
    Arguments:
        corpus1: First Conc Corpus object
        corpus2: Second Conc Corpus object
        corpus1_name: Label for first corpus
        corpus2_name: Label for second corpus
    
    Returns:
        DataFrame comparing the two corpora
    
    Example:
        >>> student_corpus = Corpus().load('student-writing.corpus')
        >>> news_corpus = Corpus().load('news-articles.corpus')
        >>> comparison = compare_corpora(student_corpus, news_corpus)
        >>> print(comparison)
    """
    try:
        metrics1 = get_basic_metrics(corpus1)
        metrics2 = get_basic_metrics(corpus2)
        
        comparison = pd.DataFrame({
            'Metric': [
                'Documents',
                'Total Tokens',
                'Total Types',
                'Avg Tokens/Doc',
                'Type-Token Ratio'
            ],
            corpus1_name: [
                metrics1['num_documents'],
                metrics1['total_tokens'],
                metrics1['total_types'],
                f"{metrics1['avg_tokens_per_doc']:.1f}",
                f"{metrics1['type_token_ratio']:.4f}"
            ],
            corpus2_name: [
                metrics2['num_documents'],
                metrics2['total_tokens'],
                metrics2['total_types'],
                f"{metrics2['avg_tokens_per_doc']:.1f}",
                f"{metrics2['type_token_ratio']:.4f}"
            ]
        })
        
        logger.info(f"Compared {corpus1_name} vs {corpus2_name}")
        
        return comparison
        
    except Exception as e:
        logger.error(f"Error comparing corpora: {e}")
        return pd.DataFrame()


# Command-line interface
if __name__ == '__main__':
    import argparse
    from conc.corpus import Corpus
    
    parser = argparse.ArgumentParser(description='Analyze a Conc corpus')
    parser.add_argument('corpus_path', help='Path to .corpus directory')
    parser.add_argument('--output', '-o', default='analysis_output/', 
                       help='Output directory for analysis files')
    parser.add_argument('--reference', '-r', help='Path to reference .corpus for keyword analysis')
    parser.add_argument('--top-n', '-n', type=int, default=100, 
                       help='Number of top results to export')
    
    args = parser.parse_args()
    
    # Load corpus
    logger.info(f"Loading corpus from {args.corpus_path}")
    corpus = Corpus().load(args.corpus_path)
    
    # Load reference if provided
    reference = None
    if args.reference:
        logger.info(f"Loading reference corpus from {args.reference}")
        reference = Corpus().load(args.reference)
    
    # Run full analysis
    export_full_analysis(corpus, args.output, reference, args.top_n)
