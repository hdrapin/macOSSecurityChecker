"""Configuration - Parse Pref.md with regex"""

import re
from pathlib import Path
from typing import Optional

class Config:
    """Configuration parser for Pref.md"""

    def __init__(self, base_dir: Optional[Path] = None):
        if base_dir is None:
            base_dir = Path(__file__).parent.parent

        self.base_dir = base_dir
        self.pref_path = base_dir / "Pref.md"

        # Default values
        self.NEWS_DIR = base_dir / "News"
        self.LOGS_DIR = base_dir / "Logs"
        self.CACHE_DIR = base_dir / "Cache"
        self.RESSOURCES_PATH = base_dir / "Ressources.md"

        self.TIMEOUT_CONNECT = 5
        self.TIMEOUT_READ = 10
        self.MAX_RETRIES = 2
        self.RETRY_DELAY = 0.3
        self.USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Apple-News-Bot/1.0"

        self.MAX_ARTICLES_PER_SOURCE = 50
        self.CACHE_TTL_HOURS = 6
        self.DEDUP_THRESHOLD = 85

        self.TIMEZONE = "UTC"
        self.TIME_WINDOW_HOURS = 24

        # Parse Pref.md if it exists
        if self.pref_path.exists():
            self._parse_pref()

        # Create directories
        self._ensure_directories()

    def _parse_pref(self):
        """Parse Pref.md with regex"""
        try:
            content = self.pref_path.read_text(encoding='utf-8')

            # Parse paths
            if match := re.search(r"Sortie News:\s*`(.+?)`", content):
                path = match.group(1)
                self.NEWS_DIR = self._resolve_path(path)

            if match := re.search(r"Logs:\s*`(.+?)`", content):
                path = match.group(1)
                self.LOGS_DIR = self._resolve_path(path)

            if match := re.search(r"Cache:\s*`(.+?)`", content):
                path = match.group(1)
                self.CACHE_DIR = self._resolve_path(path)

            if match := re.search(r"Ressources:\s*`(.+?)`", content):
                path = match.group(1)
                self.RESSOURCES_PATH = self._resolve_path(path)

            # Parse timeouts
            if match := re.search(r"Timeout connexion:\s*`(\d+)`", content):
                self.TIMEOUT_CONNECT = int(match.group(1))

            if match := re.search(r"Timeout lecture:\s*`(\d+)`", content):
                self.TIMEOUT_READ = int(match.group(1))

            if match := re.search(r"Max retries:\s*`(\d+)`", content):
                self.MAX_RETRIES = int(match.group(1))

            # Parse other params
            if match := re.search(r"Max articles/source:\s*`(\d+)`", content):
                self.MAX_ARTICLES_PER_SOURCE = int(match.group(1))

            if match := re.search(r"Caching URLs:\s*`(\d+)`", content):
                self.CACHE_TTL_HOURS = int(match.group(1))

            if match := re.search(r"Dédup seuil titre:\s*`(\d+)`", content):
                self.DEDUP_THRESHOLD = int(match.group(1))

        except Exception as e:
            print(f"⚠️ Error parsing Pref.md: {e}. Using defaults.")

    def _resolve_path(self, path_str: str) -> Path:
        """Resolve relative paths"""
        path_str = path_str.strip()
        if path_str.startswith("./"):
            path_str = path_str[2:]

        return self.base_dir / path_str

    def _ensure_directories(self):
        """Create missing directories"""
        for dir_path in [self.NEWS_DIR, self.LOGS_DIR, self.CACHE_DIR]:
            dir_path.mkdir(parents=True, exist_ok=True)


# Global instance
_config = None

def get_config(base_dir: Optional[Path] = None) -> Config:
    """Get or create global config instance"""
    global _config
    if _config is None:
        _config = Config(base_dir)
    return _config

def reset_config():
    """Reset global config (for testing)"""
    global _config
    _config = None
