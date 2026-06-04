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
        """Parse markdown table from Ressources.md - find 'Tableau de traçabilité' section"""
        sources = []
        lines = content.split('\n')

        # Find the "Tableau de traçabilité des sources consultées" section
        section_start = -1
        for idx, line in enumerate(lines):
            if 'Tableau de traçabilité' in line or 'sources consultées' in line:
                section_start = idx
                break

        if section_start == -1:
            print("⚠️ Warning: 'Tableau de traçabilité' section not found in RESSOURCES.md")
            return sources

        # Parse table rows starting after the header
        in_table = False
        for idx in range(section_start, len(lines)):
            line = lines[idx]

            if '|' not in line:
                continue

            # Skip separator line
            if '---' in line or '---|' in line:
                in_table = True
                continue

            if not in_table:
                continue

            # Stop at next section (blank line or new header)
            if line.strip() == '' or (line.strip().startswith('#') and 'Tableau' not in line):
                break

            # Parse table row
            parts = [p.strip() for p in line.split('|')]
            parts = [p for p in parts if p]  # Remove empty parts

            if len(parts) < 2:
                continue

            try:
                # Extract name (first column)
                name = parts[0]

                # Extract URL (second column) - may be in markdown link format
                url_raw = parts[1]
                url = self._extract_url_from_markdown(url_raw)

                if not url or not url.startswith('http'):
                    continue

                # Create source with RSS as default type (will be determined by fetcher)
                source = NewsSource(
                    name=name,
                    url=url,
                    source_type="rss",  # Default, fetcher will try RSS first
                    priority=1
                )
                sources.append(source)
                print(f"✅ Loaded source: {name} → {url}")
            except (ValueError, IndexError) as e:
                continue

        return sources

    def _extract_url_from_markdown(self, text: str) -> Optional[str]:
        """Extract URL from markdown link format [URL](URL) or backtick format"""
        # Try to extract from markdown link format: [text](url)
        match = re.search(r'\[([^\]]+)\]\(([^\)]+)\)', text)
        if match:
            return match.group(2)

        # Try to extract from backtick markdown link: `[text](url)`
        match = re.search(r'`\[([^\]]+)\]\(([^\)]+)\)`', text)
        if match:
            return match.group(2)

        # Try plain URL if no markdown format
        match = re.search(r'https?://[^\s`\]]+', text)
        if match:
            return match.group(0)

        return None
