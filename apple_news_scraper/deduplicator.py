"""Deduplicator - URL normalization and duplicate detection"""

import re
from typing import List
from urllib.parse import urlparse, parse_qs, urlencode
from difflib import SequenceMatcher

class Deduplicator:
    """Intelligent deduplication by URL and title similarity"""

    def __init__(self, threshold: int = 85):
        self.threshold = threshold

    def normalize_url(self, url: str) -> str:
        """Normalize URL: remove tracking params, www, etc."""
        if not url:
            return ""

        url = url.strip().lower()

        # Remove tracking parameters
        tracking_params = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term', 'ref', 'fbclid']
        parsed = urlparse(url)
        params = parse_qs(parsed.query)

        for param in tracking_params:
            params.pop(param, None)

        new_query = urlencode(params, doseq=True)
        parsed = parsed._replace(query=new_query)
        url = parsed.geturl()

        # Remove www
        url = re.sub(r'://www\.', '://', url)

        # Remove trailing slash
        url = url.rstrip('/')

        return url

    def _similarity(self, s1: str, s2: str) -> int:
        """Calculate similarity percentage"""
        if not s1 or not s2:
            return 0

        s1 = s1.lower()
        s2 = s2.lower()

        if s1 == s2:
            return 100

        matcher = SequenceMatcher(None, s1, s2)
        ratio = matcher.ratio()
        return int(ratio * 100)

    def is_duplicate(self, article1, article2) -> bool:
        """Check if two articles are duplicates"""
        norm_url1 = self.normalize_url(article1.url)
        norm_url2 = self.normalize_url(article2.url)

        if norm_url1 and norm_url2 and norm_url1 == norm_url2:
            return True

        title_sim = self._similarity(article1.title, article2.title)
        if title_sim >= self.threshold:
            return True

        return False

    def deduplicate(self, articles: List) -> List:
        """Remove duplicates, keep most recent occurrence"""
        if not articles:
            return []

        unique = []

        sorted_articles = sorted(articles, key=lambda a: a.published, reverse=True)

        for article in sorted_articles:
            is_dup = False

            for unique_article in unique:
                if self.is_duplicate(article, unique_article):
                    is_dup = True
                    break

            if not is_dup:
                unique.append(article)

        return unique
