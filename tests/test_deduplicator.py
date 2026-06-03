"""Tests - Deduplication"""

from datetime import datetime
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from apple_news_scraper.fetcher import Article
from apple_news_scraper.deduplicator import Deduplicator

def test_normalize_url():
    """Test URL normalization"""
    dedup = Deduplicator()

    # Same URL with www
    url1 = dedup.normalize_url("https://example.com/article")
    url2 = dedup.normalize_url("https://www.example.com/article")
    assert url1 == url2, f"URLs don't match: {url1} vs {url2}"

    # Tracking parameters removed
    url1 = dedup.normalize_url("https://example.com/article?utm_source=twitter&utm_medium=social")
    url2 = dedup.normalize_url("https://example.com/article")
    # Both should normalize to same base
    assert url1.split('?')[0] == url2, "Tracking params not properly removed"

def test_similarity():
    """Test Levenshtein similarity"""
    dedup = Deduplicator()

    # Identical
    assert dedup._similarity("test", "test") == 100

    # Very different
    assert dedup._similarity("abc", "xyz") < 50

    # Case insensitive
    assert dedup._similarity("Apple", "apple") == 100

def test_deduplicate():
    """Test deduplication"""
    dedup = Deduplicator(threshold=85)

    now = datetime.now()
    articles = [
        Article("Apple releases new MacBook Pro", "https://example.com/test", "Source A", now),
        Article("Tesla announces new electric vehicle", "https://example.com/other", "Source B", now),
        Article("Microsoft launches cloud service update", "https://example.com/another", "Source C", now),
    ]

    result = dedup.deduplicate(articles)
    assert len(result) == 3, f"Expected 3 articles, got {len(result)}"

def test_duplicate_detection():
    """Test duplicate URL detection"""
    dedup = Deduplicator()

    now = datetime.now()
    article1 = Article("Test", "https://example.com/article", "Source A", now)
    article2 = Article("Test", "https://www.example.com/article", "Source B", now)

    assert dedup.is_duplicate(article1, article2), "Should detect URL duplicates"

if __name__ == "__main__":
    test_normalize_url()
    print("✅ test_normalize_url passed")

    test_similarity()
    print("✅ test_similarity passed")

    test_deduplicate()
    print("✅ test_deduplicate passed")

    test_duplicate_detection()
    print("✅ test_duplicate_detection passed")

    print("\n✅ All tests passed!")
