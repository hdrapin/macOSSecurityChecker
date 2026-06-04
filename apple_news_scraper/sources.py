"""Sources - Parse Ressources.md and provide NewsSource dataclass"""

import re
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional

@dataclass
class NewsSource:
    """Represents a news source"""
    name: str
    url: str
    source_type: str
    priority: int = 1
    css_selector: Optional[str] = None
    fallback_url: Optional[str] = None

class SourcesLoader:
    """Load sources from Ressources.md"""

    def __init__(self, ressources_path: Path):
        self.ressources_path = ressources_path
        self.sources: List[NewsSource] = []

    def load(self) -> List[NewsSource]:
        """Load sources from Ressources.md - extract from all 4 categories"""
        if not self.ressources_path.exists():
            return []

        try:
            content = self.ressources_path.read_text(encoding='utf-8')
            self.sources = self._parse_all_categories(content)
        except Exception as e:
            print(f"⚠️ Error loading sources: {e}")

        return self.sources

    def _parse_all_categories(self, content: str) -> List[NewsSource]:
        """Parse all 4 category tables and extract sources with URLs"""
        sources = []
        seen_urls = set()

        # Parse each category (1-4)
        for category_num in range(1, 5):
            category_sources = self._parse_category_table(content, category_num)
            for source in category_sources:
                # Avoid duplicates
                if source.url not in seen_urls:
                    sources.append(source)
                    seen_urls.add(source.url)
                    print(f"✅ Loaded source: {source.name} → {source.url}")

        return sources

    def _parse_category_table(self, content: str, category_num: int) -> List[NewsSource]:
        """Parse a specific category table"""
        sources = []
        lines = content.split('\n')

        # Find the category header
        category_pattern = f"## {category_num}. "
        section_start = -1

        for idx, line in enumerate(lines):
            if category_pattern in line:
                section_start = idx
                break

        if section_start == -1:
            return sources

        # Find where this category ends (next category or end of file)
        section_end = len(lines)
        for idx in range(section_start + 1, len(lines)):
            if lines[idx].startswith('## ') and idx > section_start + 1:
                section_end = idx
                break

        # Parse the markdown table in this category
        # Format: |**Nom**|**Objet**|**Note**|**RSS / URL**|
        in_table = False
        for idx in range(section_start, section_end):
            line = lines[idx].strip()

            if not line or '|' not in line:
                continue

            # Skip table header and separator
            if 'Nom du site' in line or ('---' in line and '|' in line):
                in_table = True
                continue

            if not in_table:
                continue

            # Parse table row: split by |
            parts = [p.strip() for p in line.split('|')]
            parts = [p for p in parts if p]  # Remove empty parts

            if len(parts) < 4:
                continue

            try:
                # Column 1: Source name (remove bold markdown)
                name = parts[0].replace('**', '').strip()

                # Skip header row
                if not name or 'Nom du site' in name:
                    continue

                # Column 4: RSS/URL (may be plain URL or markdown link)
                url_col = parts[3].replace('**', '').strip()
                url = self._extract_url(url_col)

                if url and url.startswith('http'):
                    source = NewsSource(
                        name=name,
                        url=url,
                        source_type="rss",
                        priority=category_num
                    )
                    sources.append(source)
            except (ValueError, IndexError):
                continue

        return sources

    def _extract_url(self, text: str) -> Optional[str]:
        """Extract URL from various formats"""
        if not text:
            return None

        # Try markdown link format: [text](url)
        match = re.search(r'\[([^\]]+)\]\(([^\)]+)\)', text)
        if match:
            return match.group(2)

        # Try backtick markdown link: `[text](url)`
        match = re.search(r'`\[([^\]]+)\]\(([^\)]+)\)`', text)
        if match:
            return match.group(2)

        # Try plain URL (most common in new format)
        match = re.search(r'https?://[^\s`\]|]+', text)
        if match:
            return match.group(0).strip()

        return None
