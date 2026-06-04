"""Test deduplicator functionality"""

import sys
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass

sys.path.insert(0, str(Path(__file__).parent.parent))

from apple_news_scraper.deduplicator import Deduplicator

@dataclass
class Article:
    """Test Article class"""
    title: str
    url: str
    source: str
    published: datetime
    summary: str = ""

def test_url_normalization():
    """Test URL normalization"""
    dedup = Deduplicator()

    # Test tracking param removal
    url1 = "https://example.com/article?utm_source=test&utm_medium=email"
    normalized = dedup.normalize_url(url1)
    assert "utm_source" not in normalized, "Should remove tracking params"

    # Test www removal
    url2 = "https://www.example.com/article"
    normalized = dedup.normalize_url(url2)
    assert "www" not in normalized, "Should remove www"

    # Test trailing slash
    url3 = "https://example.com/article/"
    normalized = dedup.normalize_url(url3)
    assert normalized.endswith("/") is False, "Should remove trailing slash"

    print("✅ URL normalization tests passed")
    return True

def test_duplicate_detection():
    """Test duplicate detection"""
    dedup = Deduplicator(threshold=85)

    article1 = Article(
        title="Apple Releases New iPhone",
        url="https://example.com/article1",
        source="TestSource",
        published=datetime.now()
    )

    article2 = Article(
        title="Apple Releases New iPhone",
        url="https://example.com/article1",
        source="OtherSource",
        published=datetime.now()
    )

    article3 = Article(
        title="Google Releases New Phone",
        url="https://different.com/article",
        source="TestSource",
        published=datetime.now()
    )

    # Same URL should be duplicate
    assert dedup.is_duplicate(article1, article2), "Same URL should be duplicate"

    # Different URL and title should not be duplicate
    assert not dedup.is_duplicate(article1, article3), "Different content should not be duplicate"

    print("✅ Duplicate detection tests passed")
    return True

def test_deduplication():
    """Test deduplication list"""
    dedup = Deduplicator(threshold=85)

    articles = [
        Article(title="Test Article", url="https://example.com/1", source="S1", published=datetime.now()),
        Article(title="Test Article", url="https://example.com/1", source="S2", published=datetime.now()),
        Article(title="Different Article", url="https://example.com/2", source="S3", published=datetime.now()),
    ]

    unique = dedup.deduplicate(articles)
    assert len(unique) == 2, f"Should have 2 unique articles, got {len(unique)}"

    print("✅ Deduplication tests passed")
    return True

if __name__ == "__main__":
    test_url_normalization()
    test_duplicate_detection()
    test_deduplication()
    print("\n✅ All deduplicator tests passed!")
