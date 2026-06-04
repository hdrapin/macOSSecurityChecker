"""Test sources parsing from RESSOURCES.md"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from apple_news_scraper.sources import SourcesLoader

def test_load_sources():
    """Test loading sources from RESSOURCES.md"""
    ressources_path = Path(__file__).parent.parent / "RESSOURCES.md"
    loader = SourcesLoader(ressources_path)
    sources = loader.load()

    assert len(sources) > 0, "Should load at least one source"
    assert all(hasattr(s, 'name') for s in sources), "All sources should have name"
    assert all(hasattr(s, 'url') for s in sources), "All sources should have url"
    assert all(s.url.startswith('http') for s in sources), "All URLs should be valid"

    print(f"✅ Loaded {len(sources)} sources successfully")
    return True

def test_extract_url_from_markdown():
    """Test URL extraction from markdown format"""
    loader = SourcesLoader(Path("."))

    # Test markdown link format
    url1 = loader._extract_url_from_markdown("[https://example.com/](https://example.com/)")
    assert url1 == "https://example.com/", f"Expected https://example.com/, got {url1}"

    # Test backtick markdown link format
    url2 = loader._extract_url_from_markdown("`[https://example.com/](https://example.com/)`")
    assert url2 == "https://example.com/", f"Expected https://example.com/, got {url2}"

    # Test plain URL
    url3 = loader._extract_url_from_markdown("https://example.com/")
    assert url3 == "https://example.com/", f"Expected https://example.com/, got {url3}"

    print("✅ URL extraction tests passed")
    return True

if __name__ == "__main__":
    test_load_sources()
    test_extract_url_from_markdown()
    print("\n✅ All tests passed!")
