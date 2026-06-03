# Apple News Scraper

Automated daily retrieval of Apple & Tech news for blog publication.

## Quick Start (macOS)

### 1. Initial Setup

```bash
cd /Users/nburma/Documents/Projects/appleNewsScrapper
chmod +x setup_macos.sh run_scraper.sh
./setup_macos.sh
```

This will:
- Create Python virtual environment
- Install dependencies (feedparser, requests, beautifulsoup4, etc.)
- Create News/, Logs/, Cache/ directories
- Test that the script works

### 2. Manual Execution

```bash
source venv/bin/activate
python apple_news_scraper/main.py
```

Generates:
- `News/dd-mm-yyyy.md` - Today's articles
- `Logs/dd-mm-yyyy.md` - Detailed execution logs

### 3. macOS Automation (LaunchAgent)

For **daily execution at 14:00 UTC**:

```bash
# Install LaunchAgent
mkdir -p ~/Library/LaunchAgents
cp com.hdrapin.apple-news.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.hdrapin.apple-news.plist
```

**Verify installation:**
```bash
launchctl list | grep apple-news
```

**Run manually:**
```bash
launchctl start com.hdrapin.apple-news
```

**View LaunchAgent logs:**
```bash
tail -f /Users/nburma/Documents/Projects/appleNewsScrapper/LaunchAgent.log
```

**View daily script logs:**
```bash
ls -la /Users/nburma/Documents/Projects/appleNewsScrapper/Logs/
cat /Users/nburma/Documents/Projects/appleNewsScrapper/Logs/03-06-2026.md
```

**Disable:**
```bash
launchctl unload ~/Library/LaunchAgents/com.hdrapin.apple-news.plist
```

## Configuration

### `Pref.md` - Parameters
Modify to customize:
- Paths (News/, Logs/, Cache/)
- HTTP timeouts
- Deduplication threshold
- Retry settings

### `Ressources.md` - Sources
Add/remove RSS sources in the table.

## Architecture

```
apple_news_scraper/
├── main.py           # Orchestration + entry point
├── config.py         # Parse Pref.md configuration
├── sources.py        # Load sources from Ressources.md
├── fetcher.py        # HTTP pooling + exponential retry
├── deduplicator.py   # Remove duplicates intelligently
├── cache.py          # Local JSON caching
└── logger.py         # Generate .md logs with stats
```

## Generated Files

### News/dd-mm-yyyy.md
Simple list of articles:
```markdown
# Actualités Apple & Tech - 03 Jun 2026

**Nombre d'articles:** 24 | **Dernière mise à jour:** 03-06-2026 14:35 UTC

## Articles

- **[Article Title]** | MacRumors | 03 Jun 14:00
- **[Article Title]** | Apple Newsroom | 03 Jun 10:30
...
```

### Logs/dd-mm-yyyy.md
Source statistics:
```markdown
# Logs Exécution - 03 Jun 2026

## 📊 Résumé Sources

| Source | Articles | Statut | Durée | Erreur |
|--------|----------|--------|-------|--------|
| MacRumors | 5 | ✅ OK | 10.2s | |
| Apple Newsroom | 3 | ✅ OK | 5.1s | |
...
```

## Troubleshooting

### ❌ "No module named feedparser"
```bash
source venv/bin/activate
pip install -r requirements.txt
```

### ❌ LaunchAgent doesn't execute
```bash
# Check exact path
plutil -p ~/Library/LaunchAgents/com.hdrapin.apple-news.plist

# Restart
launchctl unload ~/Library/LaunchAgents/com.hdrapin.apple-news.plist
launchctl load ~/Library/LaunchAgents/com.hdrapin.apple-news.plist
```

### ❌ No articles generated
- Check `Ressources.md` contains sources
- Test URLs manually
- Check logs for specific errors

## Development

### Unit Tests
```bash
source venv/bin/activate
python -m pytest tests/ -v
```

### Modify Code
1. Edit `.py` files in `apple_news_scraper/`
2. Test: `python apple_news_scraper/main.py`
3. Commit/Push to branch

## Performance

- **Execution time:** ~30-60s (depends on number of sources)
- **Local cache:** Reduces requests by 60-80% after 2-3 days
- **HTTP pooling:** Reuses TCP connections
- **Retry:** Exponential backoff (1s, 2s, 4s)

## License & Author

hdrapin © 2026
