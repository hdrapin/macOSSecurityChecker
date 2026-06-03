"""Fetcher - HTTP pooling with retry exponentiel"""

import time
import feedparser
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional, Tuple
from bs4 import BeautifulSoup
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

@dataclass
class Article:
    """Représentation d'un article"""
    title: str
    url: str
    source: str
    published: datetime
    summary: str = ""

class NewsFetcher:
    """HTTP fetcher avec pool de connexions et retry exponentiel"""

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
        """Fetch source avec retry exponentiel"""
        if max_retries is None:
            max_retries = self.config.MAX_RETRIES

        articles = []
        start_time = time.time()
        last_error = None

        for attempt in range(max_retries + 1):
            try:
                articles = self._fetch_source(source)
                duration = time.time() - start_time
                return articles, "✅ OK", duration, None

            except requests.exceptions.Timeout:
                last_error = "Timeout"
                if attempt < max_retries:
                    wait_time = (2 ** attempt)
                    time.sleep(wait_time)
            except requests.exceptions.ConnectionError:
                last_error = "Erreur réseau"
                if attempt < max_retries:
                    wait_time = (2 ** attempt)
                    time.sleep(wait_time)
            except Exception as e:
                last_error = str(e)
                break

        duration = time.time() - start_time
        return [], f"❌ {last_error}", duration, last_error

    def _fetch_source(self, source) -> List[Article]:
        """Fetch et parse une source"""
        articles = []

        if source.source_type == "rss":
            articles = self._fetch_rss(source)
        elif source.source_type == "scrape":
            articles = self._fetch_scrape(source)

        return articles[:self.config.MAX_ARTICLES_PER_SOURCE]

    def _fetch_rss(self, source) -> List[Article]:
        """Parse flux RSS"""
        articles = []

        try:
            response = self.session.get(
                source.url,
                timeout=(self.config.TIMEOUT_CONNECT, self.config.TIMEOUT_READ)
            )
            response.raise_for_status()

            feed = feedparser.parse(response.content)

            for entry in feed.entries[:self.config.MAX_ARTICLES_PER_SOURCE]:
                try:
                    article = Article(
                        title=entry.get('title', 'Sans titre'),
                        url=entry.get('link', ''),
                        source=source.name,
                        published=self._parse_date(entry),
                        summary=entry.get('summary', '')[:200]
                    )
                    articles.append(article)
                except Exception:
                    continue

        except Exception as e:
            raise Exception(f"Erreur RSS {source.name}: {e}")

        return articles

    def _fetch_scrape(self, source) -> List[Article]:
        """Scrape HTML avec BeautifulSoup"""
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
                for elem in elements[:self.config.MAX_ARTICLES_PER_SOURCE]:
                    try:
                        link = elem.find('a')
                        article = Article(
                            title=elem.get_text(strip=True)[:100],
                            url=link['href'] if link and link.get('href') else '',
                            source=source.name,
                            published=datetime.now(),
                            summary=""
                        )
                        articles.append(article)
                    except Exception:
                        continue

        except Exception as e:
            raise Exception(f"Erreur scrape {source.name}: {e}")

        return articles

    def _parse_date(self, entry) -> datetime:
        """Parse date depuis entry RSS"""
        try:
            if hasattr(entry, 'published_parsed') and entry.published_parsed:
                return datetime(*entry.published_parsed[:6])
            elif hasattr(entry, 'updated_parsed') and entry.updated_parsed:
                return datetime(*entry.updated_parsed[:6])
        except Exception:
            pass

        return datetime.now()
