"""Fetcher - HTTP pooling with exponential retry and intelligent HTML scraping fallback"""

import time
import feedparser
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import List, Optional, Tuple
from bs4 import BeautifulSoup
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

@dataclass
class Article:
    """Article representation"""
    title: str
    url: str
    source: str
    published: datetime
    summary: str = ""

class NewsFetcher:
    """HTTP fetcher with connection pooling, exponential retry, and intelligent HTML scraping"""

    # Sélecteurs CSS génériques à tester en dernier recours
    GENERIC_SELECTORS = [
        'article',
        'div.post',
        'div.article',
        'div[class*="post"]',
        'div[class*="article"]',
        'div[class*="news"]',
        'li.post',
        'li.article',
        'a.post-link',
        'a.article-link',
        'div.item',
    ]

    def __init__(self, config):
        self.config = config
        self.session = self._create_session()
        self.etags = {}

    def _create_session(self) -> requests.Session:
        """Create session with retry strategy"""
        session = requests.Session()

        retry_kwargs = {
            "total": self.config.MAX_RETRIES,
            "backoff_factor": 0.5,
            "status_forcelist": [429, 500, 502, 503, 504],
        }

        try:
            retry_strategy = Retry(**retry_kwargs, allowed_methods=["GET", "HEAD"])
        except TypeError:
            retry_strategy = Retry(**retry_kwargs, method_whitelist=["GET", "HEAD"])

        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        session.headers.update({"User-Agent": self.config.USER_AGENT})

        return session

    def fetch_with_retry(self, source, max_retries: Optional[int] = None) -> Tuple[List[Article], str, float, Optional[str]]:
        """Fetch source with exponential retry - try RSS first, then intelligent scraping"""
        if max_retries is None:
            max_retries = self.config.MAX_RETRIES

        articles = []
        start_time = time.time()
        last_error = None

        # Try RSS first
        try:
            articles = self._fetch_rss(source)
            if articles:
                duration = time.time() - start_time
                return articles, "✅ OK (RSS)", duration, None
        except Exception as e:
            last_error = f"RSS failed: {str(e)[:50]}"

        # If RSS failed, try HTML scraping with fallback URL
        if not articles and hasattr(source, 'fallback_url') and source.fallback_url:
            try:
                articles = self._fetch_scrape_fallback(source)
                if articles:
                    duration = time.time() - start_time
                    return articles, "✅ OK (Scrape)", duration, None
            except Exception as e:
                last_error = f"Scrape failed: {str(e)[:50]}"

        # Final fallback: try scraping the main RSS URL as HTML
        if not articles:
            try:
                articles = self._fetch_scrape(source)
                if articles:
                    duration = time.time() - start_time
                    return articles, "✅ OK (HTML)", duration, None
            except Exception as e:
                last_error = f"HTML scrape failed: {str(e)[:50]}"

        duration = time.time() - start_time
        return [], f"❌ {last_error}", duration, last_error

    def _fetch_rss(self, source) -> List[Article]:
        """Parse RSS feed"""
        articles = []

        try:
            response = self.session.get(
                source.url,
                timeout=(self.config.TIMEOUT_CONNECT, self.config.TIMEOUT_READ)
            )
            response.raise_for_status()

            feed = feedparser.parse(response.content)

            # FILTER: Only keep articles from last 24 hours
            now = datetime.now()
            cutoff_time = now - timedelta(hours=self.config.TIME_WINDOW_HOURS)

            for entry in feed.entries[:self.config.MAX_ARTICLES_PER_SOURCE]:
                try:
                    published = self._parse_date(entry)

                    # Filter by 24-hour window
                    if published < cutoff_time:
                        continue

                    article = Article(
                        title=entry.get('title', 'No title'),
                        url=entry.get('link', ''),
                        source=source.name,
                        published=published,
                        summary=entry.get('summary', '')[:200]
                    )
                    articles.append(article)
                except Exception:
                    continue

        except Exception as e:
            raise Exception(f"RSS Error: {e}")

        return articles

    def _fetch_scrape_fallback(self, source) -> List[Article]:
        """Scrape HTML from fallback URL with intelligent selector detection"""
        articles = []

        try:
            response = self.session.get(
                source.fallback_url,
                timeout=(self.config.TIMEOUT_CONNECT, self.config.TIMEOUT_READ)
            )
            response.raise_for_status()

            soup = BeautifulSoup(response.content, 'lxml')

            # Try the specified CSS selector first
            if source.css_selector:
                elements = soup.select(source.css_selector)
                articles = self._extract_articles_from_elements(elements, source)

            # If no elements found with specified selector, try intelligent detection
            if not articles:
                articles = self._intelligently_find_articles(soup, source)

        except Exception as e:
            raise Exception(f"Scrape fallback error: {e}")

        return articles

    def _fetch_scrape(self, source) -> List[Article]:
        """Scrape HTML - try intelligent detection"""
        articles = []

        try:
            response = self.session.get(
                source.url,
                timeout=(self.config.TIMEOUT_CONNECT, self.config.TIMEOUT_READ)
            )
            response.raise_for_status()

            soup = BeautifulSoup(response.content, 'lxml')

            if source.css_selector:
                elements = soup.select(source.css_selector)
                articles = self._extract_articles_from_elements(elements, source)

            if not articles:
                articles = self._intelligently_find_articles(soup, source)

        except Exception as e:
            raise Exception(f"Scrape Error: {e}")

        return articles

    def _intelligently_find_articles(self, soup, source) -> List[Article]:
        """Intelligently find articles by trying multiple selector strategies"""
        articles = []

        # Strategy 1: Try generic selectors
        for selector in self.GENERIC_SELECTORS:
            elements = soup.select(selector)
            if elements:
                articles = self._extract_articles_from_elements(elements, source)
                if articles:
                    break

        # Strategy 2: Find by common patterns
        if not articles:
            # Look for links with date patterns or article-like structure
            all_links = soup.find_all('a', href=True)
            article_links = []

            for link in all_links[:self.config.MAX_ARTICLES_PER_SOURCE * 2]:
                href = link.get('href', '')
                text = link.get_text(strip=True)

                # Filter out navigation/social links
                if any(skip in href.lower() for skip in ['#', 'javascript:', '/tag/', '/category/', '/author/']):
                    continue

                # Look for reasonable article titles (not too short)
                if len(text) > 10 and len(text) < 500:
                    article_links.append((text, href))

            # Convert to articles
            for title, url in article_links[:self.config.MAX_ARTICLES_PER_SOURCE]:
                if url.startswith('/'):
                    from urllib.parse import urljoin
                    url = urljoin(source.fallback_url if hasattr(source, 'fallback_url') else source.url, url)

                if url.startswith('http'):
                    article = Article(
                        title=title[:150],
                        url=url,
                        source=source.name,
                        published=datetime.now(),
                        summary=""
                    )
                    articles.append(article)

        return articles

    def _extract_articles_from_elements(self, elements, source) -> List[Article]:
        """Extract articles from HTML elements"""
        articles = []

        for elem in elements[:self.config.MAX_ARTICLES_PER_SOURCE]:
            try:
                # Find title
                title_elem = elem.find(['h1', 'h2', 'h3', 'h4', 'a', 'span'])
                title = title_elem.get_text(strip=True) if title_elem else elem.get_text(strip=True)

                if not title or len(title) < 5:
                    continue

                # Find URL
                link_elem = elem.find('a', href=True)
                if not link_elem:
                    link_elem = elem if elem.name == 'a' else None

                url = link_elem.get('href', '') if link_elem else ''

                # Make absolute URL if relative
                if url and url.startswith('/'):
                    from urllib.parse import urljoin
                    fallback = getattr(source, 'fallback_url', None)
                    base_url = fallback if fallback else source.url
                    url = urljoin(base_url, url)

                if not url or not url.startswith('http'):
                    continue

                article = Article(
                    title=title[:150],
                    url=url,
                    source=source.name,
                    published=datetime.now(),
                    summary=""
                )
                articles.append(article)
            except Exception:
                continue

        return articles

    def _parse_date(self, entry) -> datetime:
        """Parse date from RSS entry"""
        try:
            if hasattr(entry, 'published_parsed') and entry.published_parsed:
                return datetime(*entry.published_parsed[:6])
            elif hasattr(entry, 'updated_parsed') and entry.updated_parsed:
                return datetime(*entry.updated_parsed[:6])
        except Exception:
            pass

        return datetime.now()
