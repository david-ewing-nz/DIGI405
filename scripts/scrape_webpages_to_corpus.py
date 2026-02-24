"""
scrape_webpages_to_corpus.py

Purpose:
    Scrape web pages and build a corpus, removing HTML/CSS/JavaScript formatting
    to extract only the text content.

Requirements:
    pip install beautifulsoup4 requests newspaper3k lxml pandas conc

Usage Examples:
    # Example 1: Scrape single page
    python scrape_webpages_to_corpus.py --url "https://example.com/article" --output articles/

    # Example 2: Scrape multiple URLs from file
    python scrape_webpages_to_corpus.py --urls-file urls.txt --output articles/

    # Example 3: Build corpus after scraping
    python scrape_webpages_to_corpus.py --build-corpus --name "My Corpus" --output articles/

Author: DIGI405 Course Materials
Date: 2026-02-24
"""

from bs4 import BeautifulSoup
import requests
import argparse
import os
import time
import pandas as pd
from pathlib import Path
from typing import List, Optional
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def scrape_webpage_to_text(url: str, output_file: str, 
                           remove_elements: Optional[List[str]] = None) -> Optional[str]:
    """
    Scrape a webpage and save only the text content, removing HTML formatting.
    
    Arguments:
        url: URL of the webpage to scrape
        output_file: Path where to save the extracted text
        remove_elements: List of HTML tags to remove (default: script, style, nav, footer, header, aside)
    
    Returns:
        Extracted text content, or None if failed
    """
    if remove_elements is None:
        remove_elements = ['script', 'style', 'nav', 'footer', 'header', 'aside', 'noscript']
    
    try:
        # Fetch the webpage
        logger.info(f"Fetching {url}")
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=30)
        response.raise_for_status()
        
        # Parse HTML
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Remove unwanted elements
        for element_type in remove_elements:
            for element in soup.find_all(element_type):
                element.decompose()
        
        # Extract text
        text = soup.get_text(separator=' ', strip=True)
        
        # Clean up whitespace
        lines = (line.strip() for line in text.splitlines())
        text = ' '.join(line for line in lines if line)
        
        # Create output directory if needed
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        
        # Save to file
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(text)
        
        logger.info(f"Saved {len(text)} characters to {output_file}")
        return text
        
    except Exception as e:
        logger.error(f"Error scraping {url}: {e}")
        return None


def scrape_with_css_selector(url: str, output_file: str, 
                             selector: str = 'article',
                             selector_type: str = 'tag') -> Optional[str]:
    """
    Extract text from specific parts of the page using CSS selectors.
    
    Arguments:
        url: URL of the webpage
        output_file: Path where to save extracted text
        selector: CSS selector, class name, or ID to target
        selector_type: 'tag', 'class', or 'id'
    
    Returns:
        Extracted text, or None if failed
    """
    try:
        logger.info(f"Fetching {url} with selector: {selector}")
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=30)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Find content based on selector type
        if selector_type == 'class':
            main_content = soup.find(class_=selector)
        elif selector_type == 'id':
            main_content = soup.find(id=selector)
        else:  # tag
            main_content = soup.find(selector)
        
        if main_content:
            text = main_content.get_text(separator=' ', strip=True)
            
            # Create output directory if needed
            os.makedirs(os.path.dirname(output_file), exist_ok=True)
            
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(text)
            
            logger.info(f"Saved {len(text)} characters to {output_file}")
            return text
        else:
            logger.warning(f"Could not find content with selector '{selector}' in {url}")
            return None
            
    except Exception as e:
        logger.error(f"Error scraping {url}: {e}")
        return None


def scrape_news_article(url: str, output_file: str) -> Optional[str]:
    """
    Extract article text using Newspaper3k (specialized for news articles).
    
    Arguments:
        url: URL of the news article
        output_file: Path where to save extracted text
    
    Returns:
        Extracted text, or None if failed
    """
    try:
        from newspaper import Article
        
        logger.info(f"Extracting article from {url}")
        article = Article(url)
        article.download()
        article.parse()
        
        text = article.text
        
        # Create output directory if needed
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        
        # Save text
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(text)
        
        # Also save metadata if available
        metadata = {
            'title': article.title,
            'authors': article.authors,
            'publish_date': str(article.publish_date) if article.publish_date else None,
            'url': url
        }
        
        logger.info(f"Saved article: {metadata['title']}")
        return text
        
    except ImportError:
        logger.error("newspaper3k not installed. Install with: pip install newspaper3k")
        return None
    except Exception as e:
        logger.error(f"Error extracting article from {url}: {e}")
        return None


def scrape_urls_to_csv(urls: List[str], output_csv: str, 
                       delay: float = 1.0) -> pd.DataFrame:
    """
    Scrape multiple URLs and save to CSV with metadata.
    
    Arguments:
        urls: List of URLs to scrape
        output_csv: Path to save CSV file
        delay: Delay in seconds between requests (be polite to servers)
    
    Returns:
        DataFrame with scraped data
    """
    data = []
    
    for i, url in enumerate(urls):
        logger.info(f"Scraping {i+1}/{len(urls)}: {url}")
        
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            }
            response = requests.get(url, headers=headers, timeout=30)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Remove unwanted elements
            for element in soup(['script', 'style', 'nav', 'footer', 'header', 'aside']):
                element.decompose()
            
            # Extract text
            text = soup.get_text(separator=' ', strip=True)
            lines = (line.strip() for line in text.splitlines())
            text = ' '.join(line for line in lines if line)
            
            # Extract title
            title = soup.find('title')
            title = title.get_text() if title else ''
            
            # Create document ID from URL
            doc_id = url.split('/')[-1] or f'doc_{i:04d}'
            
            data.append({
                'doc_id': doc_id,
                'url': url,
                'title': title,
                'text': text
            })
            
            # Be polite - don't overwhelm the server
            if i < len(urls) - 1:
                time.sleep(delay)
                
        except Exception as e:
            logger.error(f"Error scraping {url}: {e}")
            data.append({
                'doc_id': f'error_{i:04d}',
                'url': url,
                'title': '',
                'text': ''
            })
    
    # Create DataFrame
    df = pd.DataFrame(data)
    
    # Save to CSV
    df.to_csv(output_csv, index=False, encoding='utf-8')
    logger.info(f"Saved {len(df)} documents to {output_csv}")
    
    return df


def build_corpus_from_texts(text_dir: str, corpus_name: str, 
                           corpus_description: str, save_path: str):
    """
    Build a Conc corpus from scraped text files.
    
    Arguments:
        text_dir: Directory containing .txt files
        corpus_name: Name for the corpus
        corpus_description: Description of the corpus
        save_path: Directory where to save the .corpus
    """
    try:
        from conc.corpus import Corpus
        
        logger.info(f"Building corpus '{corpus_name}' from {text_dir}")
        
        corpus = Corpus(
            name=corpus_name,
            description=corpus_description
        ).build_from_files(text_dir, save_path)
        
        logger.info(f"Corpus built successfully!")
        logger.info(f"Total tokens: {corpus.total_tokens:,}")
        logger.info(f"Total types: {corpus.total_types:,}")
        logger.info(f"Documents: {corpus.num_documents}")
        
        return corpus
        
    except ImportError:
        logger.error("conc library not installed. Install with: pip install conc")
        return None
    except Exception as e:
        logger.error(f"Error building corpus: {e}")
        return None


def build_corpus_from_csv(csv_file: str, corpus_name: str,
                         corpus_description: str, save_path: str):
    """
    Build a Conc corpus from CSV file.
    
    Arguments:
        csv_file: Path to CSV file with 'doc_id' and 'text' columns
        corpus_name: Name for the corpus
        corpus_description: Description of the corpus
        save_path: Directory where to save the .corpus
    """
    try:
        from conc.corpus import Corpus
        
        logger.info(f"Building corpus '{corpus_name}' from {csv_file}")
        
        corpus = Corpus(
            name=corpus_name,
            description=corpus_description
        ).build_from_csv(csv_file, save_path)
        
        logger.info(f"Corpus built successfully!")
        logger.info(f"Total tokens: {corpus.total_tokens:,}")
        logger.info(f"Total types: {corpus.total_types:,}")
        logger.info(f"Documents: {corpus.num_documents}")
        
        return corpus
        
    except ImportError:
        logger.error("conc library not installed. Install with: pip install conc")
        return None
    except Exception as e:
        logger.error(f"Error building corpus: {e}")
        return None


def main():
    """Command line interface"""
    parser = argparse.ArgumentParser(
        description='Scrape web pages and build a corpus',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Scrape a single URL
  python scrape_webpages_to_corpus.py --url "https://example.com/article" --output articles/
  
  # Scrape multiple URLs from a file (one URL per line)
  python scrape_webpages_to_corpus.py --urls-file urls.txt --output articles/
  
  # Scrape and build corpus
  python scrape_webpages_to_corpus.py --urls-file urls.txt --output articles/ --build-corpus --name "My Corpus"
  
  # Use CSS selector
  python scrape_webpages_to_corpus.py --url "https://example.com" --output articles/ --selector "article-body" --selector-type class
        """
    )
    
    parser.add_argument('--url', type=str, help='Single URL to scrape')
    parser.add_argument('--urls-file', type=str, help='File with URLs (one per line)')
    parser.add_argument('--output', type=str, required=True, help='Output directory for text files')
    parser.add_argument('--csv', type=str, help='Save to CSV instead of text files')
    parser.add_argument('--selector', type=str, help='CSS selector for content extraction')
    parser.add_argument('--selector-type', type=str, choices=['tag', 'class', 'id'], 
                       default='tag', help='Type of selector')
    parser.add_argument('--delay', type=float, default=1.0, 
                       help='Delay between requests in seconds (default: 1.0)')
    parser.add_argument('--build-corpus', action='store_true', 
                       help='Build a Conc corpus after scraping')
    parser.add_argument('--name', type=str, default='Web Corpus', 
                       help='Corpus name (if building corpus)')
    parser.add_argument('--description', type=str, default='Corpus built from web pages',
                       help='Corpus description (if building corpus)')
    parser.add_argument('--corpus-path', type=str, default='./corpora/',
                       help='Path to save corpus (default: ./corpora/)')
    
    args = parser.parse_args()
    
    # Collect URLs
    urls = []
    if args.url:
        urls.append(args.url)
    if args.urls_file:
        with open(args.urls_file, 'r', encoding='utf-8') as f:
            urls.extend([line.strip() for line in f if line.strip()])
    
    if not urls:
        parser.error("Must provide either --url or --urls-file")
    
    logger.info(f"Found {len(urls)} URLs to scrape")
    
    # Scrape to CSV or text files
    if args.csv:
        df = scrape_urls_to_csv(urls, args.csv, delay=args.delay)
        
        if args.build_corpus:
            build_corpus_from_csv(args.csv, args.name, args.description, args.corpus_path)
    else:
        # Scrape to individual text files
        os.makedirs(args.output, exist_ok=True)
        
        for i, url in enumerate(urls):
            output_file = os.path.join(args.output, f"doc_{i:04d}.txt")
            
            if args.selector:
                scrape_with_css_selector(url, output_file, args.selector, args.selector_type)
            else:
                scrape_webpage_to_text(url, output_file)
            
            # Be polite
            if i < len(urls) - 1:
                time.sleep(args.delay)
        
        if args.build_corpus:
            build_corpus_from_texts(args.output, args.name, args.description, args.corpus_path)
    
    logger.info("Done!")


if __name__ == '__main__':
    main()
