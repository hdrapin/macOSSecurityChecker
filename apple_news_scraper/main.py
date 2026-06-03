"""Main - Orchestration of the entire scraper"""

import sys
import time
from datetime import datetime
from pathlib import Path

# Support both module import and direct script execution
try:
    from .config import get_config
    from .sources import SourcesLoader
    from .fetcher import NewsFetcher
    from .deduplicator import Deduplicator
    from .logger import MdLogger
except ImportError:
    from config import get_config
    from sources import SourcesLoader
    from fetcher import NewsFetcher
    from deduplicator import Deduplicator
    from logger import MdLogger

def main():
    """Main execution flow"""
    print("🚀 Starting Apple News Scraper...")

    # Load config
    base_dir = Path(__file__).parent.parent
    config = get_config(base_dir)

    # Load sources
    sources_loader = SourcesLoader(config.RESSOURCES_PATH)
    sources = sources_loader.load()

    if not sources:
        print("❌ No sources found in Ressources.md")
        return

    print(f"📡 Loaded {len(sources)} sources")

    # Initialize components
    fetcher = NewsFetcher(config)
    deduplicator = Deduplicator(config.DEDUP_THRESHOLD)
    logger = MdLogger(config.LOGS_DIR)

    # Fetch articles from all sources
    all_articles = []
    total_before_dedup = 0

    for source in sources:
        print(f"  📰 Fetching {source.name}...", end=" ", flush=True)
        articles, status, duration, error = fetcher.fetch_with_retry(source)
        logger.log_source(source.name, len(articles), duration, status, error)
        print(f"{status} ({len(articles)} articles, {duration:.1f}s)")

        all_articles.extend(articles)
        total_before_dedup += len(articles)

    print(f"\n📊 Total articles before dedup: {total_before_dedup}")

    # Deduplicate
    unique_articles = deduplicator.deduplicate(all_articles)
    duplicates_removed = total_before_dedup - len(unique_articles)

    print(f"✂️  Duplicates removed: {duplicates_removed}")
    print(f"✅ Unique articles: {len(unique_articles)}")

    # Generate output files
    now = datetime.now()

    # Generate News file
    news_file = generate_news_file(config.NEWS_DIR, unique_articles, now)
    print(f"📄 News file: {news_file}")

    # Generate Log file
    log_file = logger.save_to_file(now, len(unique_articles), duplicates_removed)
    print(f"📋 Log file: {log_file}")

    print(f"\n✅ Scraping complete at {now.strftime('%H:%M:%S %Z')}")

def generate_news_file(news_dir: Path, articles, date: datetime) -> Path:
    """Generate News/dd-mm-yyyy.md file"""
    filename = date.strftime("%d-%m-%Y") + ".md"
    file_path = news_dir / filename

    content = f"# Actualités Apple & Tech - {date.strftime('%d %b %Y')}\n\n"
    content += f"**Nombre d'articles:** {len(articles)} | **Dernière mise à jour:** {date.strftime('%d-%m-%Y %H:%M')} UTC\n\n"

    if articles:
        content += "## Articles\n\n"

        # Sort by date descending
        sorted_articles = sorted(articles, key=lambda a: a.published, reverse=True)

        for article in sorted_articles:
            pub_date = article.published.strftime('%d %b %H:%M')
            content += f"- **[{article.title}]({article.url})** | {article.source} | {pub_date}\n"

    # Write file
    try:
        file_path.write_text(content, encoding='utf-8')
    except Exception as e:
        print(f"⚠️ Error writing news file: {e}")

    return file_path

if __name__ == "__main__":
    main()
