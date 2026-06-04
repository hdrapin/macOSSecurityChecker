"""Configuration - Parse Pref.md"""

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
        self.RESSOURCES_PATH = base_dir / "RESSOURCES.md"

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
        else:
            print(f"⚠️ Pref.md not found at {self.pref_path}, using defaults")

        # Create directories
        self._ensure_directories()

    def _parse_pref(self):
        """Parse Pref.md with simple format: KEY: VALUE"""
        try:
            content = self.pref_path.read_text(encoding='utf-8')

            # Parse key: value format
            for line in content.split('\n'):
                line = line.strip()
                if not line or line.startswith('#') or ':' not in line:
                    continue

                key, value = line.split(':', 1)
                key = key.strip()
                value = value.strip()

                # Parse paths
                if key == 'RESSOURCES_PATH':
                    self.RESSOURCES_PATH = self._resolve_path(value)
                    print(f"✅ Ressources: {self.RESSOURCES_PATH}")

                elif key == 'NEWS_DIR':
                    self.NEWS_DIR = self._resolve_path(value)
                    print(f"✅ News: {self.NEWS_DIR}")

                elif key == 'LOGS_DIR':
                    self.LOGS_DIR = self._resolve_path(value)
                    print(f"✅ Logs: {self.LOGS_DIR}")

                elif key == 'CACHE_DIR':
                    self.CACHE_DIR = self._resolve_path(value)

                # Parse numbers
                elif key == 'TIMEOUT_CONNECT':
                    self.TIMEOUT_CONNECT = int(value)
                elif key == 'TIMEOUT_READ':
                    self.TIMEOUT_READ = int(value)
                elif key == 'MAX_RETRIES':
                    self.MAX_RETRIES = int(value)
                elif key == 'MAX_ARTICLES_PER_SOURCE':
                    self.MAX_ARTICLES_PER_SOURCE = int(value)
                elif key == 'CACHE_TTL_HOURS':
                    self.CACHE_TTL_HOURS = int(value)
                elif key == 'DEDUP_THRESHOLD':
                    self.DEDUP_THRESHOLD = int(value)

        except Exception as e:
            print(f"⚠️ Error parsing Pref.md: {e}. Using defaults.")

    def _resolve_path(self, path_str: str) -> Path:
        """Resolve relative or absolute paths"""
        path_str = path_str.strip()

        # If absolute path (starts with /), use as-is
        if path_str.startswith('/'):
            return Path(path_str)

        # If relative path, resolve from base_dir
        if path_str.startswith("./"):
            path_str = path_str[2:]

        return self.base_dir / path_str

    def _ensure_directories(self):
        """Create missing directories"""
        for dir_path in [self.NEWS_DIR, self.LOGS_DIR, self.CACHE_DIR]:
            try:
                dir_path.mkdir(parents=True, exist_ok=True)
            except Exception as e:
                print(f"⚠️ Warning: Could not create {dir_path}: {e}")


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
