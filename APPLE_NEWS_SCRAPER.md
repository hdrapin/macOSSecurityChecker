# Apple News Scraper

Automated scraper that fetches Apple and tech news from multiple RSS feeds and blogs, deduplicates articles, and generates daily markdown reports.

## Features

- **Dynamic Source Loading**: Reads all sources from `RESSOURCES.md` (no hardcoded URLs)
- **24-Hour Filtering**: Only includes articles published in the last 24 hours
- **HTTP Connection Pooling**: Efficient reuse of connections with exponential backoff retry
- **Smart Deduplication**: Removes duplicates by URL normalization and title similarity (85% threshold)
- **Local Caching**: JSON-based caching with 6-hour TTL to reduce unnecessary requests
- **Markdown Output**: Generates clean daily reports with articles organized by source
- **Detailed Logging**: Comprehensive logs with source statistics and error tracking
- **Modular Design**: Separate modules for config, sources, fetching, deduplication, and logging

## Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Settings

Edit `Pref.md` to customize paths and parameters:

```markdown
# Preferences
RESSOURCES_PATH: ./RESSOURCES.md
NEWS_DIR: ./News/
LOGS_DIR: ./Logs/
CACHE_DIR: ./Cache/
TIMEOUT_CONNECT: 5
TIMEOUT_READ: 10
MAX_RETRIES: 2
```

### 3. Add News Sources

Edit `RESSOURCES.md` and add sources to the "Tableau de traçabilité des sources consultées" section:

```markdown
|**Title**|**URL**|**Date**|
|---|---|---|
|Source Name|`[https://example.com/feed/](https://example.com/feed/)`|2026-06-04|
```

### 4. Run the Scraper

```bash
python -m apple_news_scraper.main
```

Or directly:

```bash
python apple_news_scraper/main.py
```

## Output

### News Files

Daily news articles are saved to `News/dd-mm-yyyy.md`:

```markdown
# Actualités Apple & Tech - 04 Jun 2026

**Nombre d'articles:** 24 | **Dernière mise à jour:** 04-06-2026 14:35 UTC

## Articles

- **[Article Title](https://example.com/article)** | MacRumors | 04 Jun 14:00
- **[Another Article](https://example.com/article2)** | 9to5Mac | 04 Jun 13:30
```

### Log Files

Detailed execution logs are saved to `Logs/dd-mm-yyyy.md`:

```markdown
# Logs Exécution - 04 Jun 2026

**Timestamp:** 2026-06-04 14:35:00 UTC

## 📊 Résumé Sources

| Source | Articles | Statut | Durée | Erreur |
|--------|----------|--------|-------|--------|
| MacRumors | 5 | ✅ OK (RSS) | 2.3s |  |
| 9to5Mac | 3 | ✅ OK (RSS) | 1.8s |  |

**Durée totale:** 45.2s
**Articles totaux récupérés:** 24
**Doublons supprimés:** 3
```

## Configuration

### Pref.md Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `RESSOURCES_PATH` | Path to sources file | `./RESSOURCES.md` |
| `NEWS_DIR` | Output directory for news | `./News/` |
| `LOGS_DIR` | Output directory for logs | `./Logs/` |
| `CACHE_DIR` | Cache directory | `./Cache/` |
| `TIMEOUT_CONNECT` | Connection timeout (seconds) | `5` |
| `TIMEOUT_READ` | Read timeout (seconds) | `10` |
| `MAX_RETRIES` | Retry attempts on failure | `2` |
| `MAX_ARTICLES_PER_SOURCE` | Max articles per source | `50` |
| `CACHE_TTL_HOURS` | Cache expiration time | `6` |
| `DEDUP_THRESHOLD` | Title similarity threshold (0-100) | `85` |

## Module Structure

- **`config.py`**: Loads and validates configuration from `Pref.md`
- **`sources.py`**: Parses sources from `RESSOURCES.md` markdown table
- **`fetcher.py`**: HTTP pooling, RSS/HTML parsing, 24-hour filtering
- **`deduplicator.py`**: URL normalization and duplicate detection
- **`cache.py`**: Local JSON caching with TTL support
- **`logger.py`**: Markdown log generation with statistics
- **`main.py`**: Orchestration and output file generation

## Fetching Strategy

The scraper uses a multi-strategy approach:

1. **RSS Feed** (Primary): Parse RSS feeds for articles with metadata
2. **HTML Scraping** (Fallback): If RSS fails, scrape the fallback URL
3. **Intelligent Detection**: If custom selectors fail, try generic patterns

## Filtering

- **Time Window**: Only articles published in the last `TIME_WINDOW_HOURS` (24 by default)
- **Deduplication**: Removes articles with identical URLs or >85% title similarity
- **URL Normalization**: Removes tracking parameters (`utm_*`, `ref`, etc.) before comparison

## Testing

Run the test suite to verify functionality:

```bash
python tests/test_sources.py
python tests/test_deduplicator.py
```

## Troubleshooting

### No sources loaded

- Check `RESSOURCES_PATH` in `Pref.md` points to correct file
- Verify sources are in "Tableau de traçabilité des sources consultées" section
- Check URL format: `[https://example.com/](https://example.com/)`

### No articles fetched

- Check source URLs are accessible (no 403/404 errors)
- Verify RSS feeds are valid (try opening URLs in browser)
- Check `TIMEOUT_CONNECT` and `TIMEOUT_READ` aren't too short
- See `Logs/dd-mm-yyyy.md` for detailed error messages

### Duplicate articles appearing

- Adjust `DEDUP_THRESHOLD` in `Pref.md` (higher = stricter matching)
- Check if sources overlap (same content from different feeds)

## Performance

- **First run**: Full fetch from all sources (~30-60 seconds)
- **Subsequent runs**: ~10-20 seconds (cache + ETags reduce requests by 60-80%)
- **24-hour filter**: Reduces articles parsed by ~80% (focuses on recent content)

## Future Enhancements

- [ ] Category/tag classification via AI
- [ ] Article summarization
- [ ] Search indexing
- [ ] Email digest generation
- [ ] Web UI for browsing articles
