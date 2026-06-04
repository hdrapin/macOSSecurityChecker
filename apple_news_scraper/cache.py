"""Cache - Local JSON caching to reduce HTTP requests"""

import json
import time
import hashlib
from pathlib import Path
from typing import Optional, Dict

class LocalCache:
    """Local cache using JSON files"""

    def __init__(self, cache_dir: Path, ttl_hours: int = 6):
        self.cache_dir = cache_dir
        self.ttl_seconds = ttl_hours * 3600

        self.url_hashes_path = cache_dir / "url_hashes.json"
        self.etags_path = cache_dir / "etags.json"

        self.url_hashes: Dict[str, float] = {}
        self.etags: Dict[str, str] = {}

        self._load()

    def _load(self):
        """Load cache from disk"""
        try:
            if self.url_hashes_path.exists():
                self.url_hashes = json.loads(self.url_hashes_path.read_text())
        except Exception:
            self.url_hashes = {}

        try:
            if self.etags_path.exists():
                self.etags = json.loads(self.etags_path.read_text())
        except Exception:
            self.etags = {}

    def _save(self):
        """Save cache to disk"""
        try:
            self.url_hashes_path.write_text(json.dumps(self.url_hashes))
            self.etags_path.write_text(json.dumps(self.etags))
        except Exception as e:
            print(f"⚠️ Error saving cache: {e}")

    def _hash_url(self, url: str) -> str:
        """Create hash of URL"""
        return hashlib.md5(url.encode()).hexdigest()

    def should_fetch(self, url: str) -> bool:
        """Check if URL is fresh (not cached or expired)"""
        url_hash = self._hash_url(url)
        if url_hash not in self.url_hashes:
            return True

        last_seen = self.url_hashes[url_hash]
        age = time.time() - last_seen

        return age > self.ttl_seconds

    def mark_fetched(self, url: str):
        """Mark URL as recently fetched"""
        url_hash = self._hash_url(url)
        self.url_hashes[url_hash] = time.time()
        self._save()

    def get_etag(self, url: str) -> Optional[str]:
        """Get ETag for URL if exists"""
        return self.etags.get(url)

    def set_etag(self, url: str, etag: str):
        """Store ETag for URL"""
        self.etags[url] = etag
        self._save()

    def clear_expired(self):
        """Remove expired entries"""
        now = time.time()
        expired = [k for k, v in self.url_hashes.items() if (now - v) > self.ttl_seconds]

        for key in expired:
            del self.url_hashes[key]

        if expired:
            self._save()
