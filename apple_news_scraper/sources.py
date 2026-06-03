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
    source_type: str  # "rss" or "scrape"
    priority: int
    css_selector: Optional[str] = None

class SourcesLoader:
    """Load sources from Ressources.md"""

    def __init__(self, ressources_path: Path):
        self.ressources_path = ressources_path
        self.sources: List[NewsSource] = []

    def load(self) -> List[NewsSource]:
        """Load sources from Ressources.md"""
        if not self.ressources_path.exists():
            return []

        try:
            content = self.ressources_path.read_text(encoding='utf-8')
            self.sources = self._parse_markdown_table(content)
        except Exception as e:
            print(f"⚠️ Error loading sources: {e}")

        return self.sources

    def _parse_markdown_table(self, content: str) -> List[NewsSource]:
        """Parse markdown table from Ressources.md"""
        sources = []

        # Find table section
        lines = content.split('\n')
        in_table = False
        header_found = False

        for line in lines:
            # Skip until we find the table separator
            if '|' not in line:
                continue

            if not header_found and 'Source' in line:
                header_found = True
                continue

            # Skip separator line
            if '---' in line:
                in_table = True
                continue

            if not in_table:
                continue

            # Parse table row
            parts = [p.strip() for p in line.split('|')]
            # Filter out empty parts (from leading/trailing |)
            parts = [p for p in parts if p]

            if len(parts) < 4:
                continue

            try:
                source = NewsSource(
                    name=parts[0],
                    url=parts[1],
                    source_type=parts[2].lower(),
                    priority=int(parts[3]),
                    css_selector=parts[4] if len(parts) > 4 and parts[4] != 'N/A' else None
                )
                sources.append(source)
            except (ValueError, IndexError):
                continue

        return sources
