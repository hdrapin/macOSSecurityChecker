"""Sources - Parse Ressources.md and provide NewsSource dataclass"""

import re
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional, Dict

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

    # Manual URL mapping for sources
    URL_MAPPING = {
        "AnandTech (Archives/Analyses)": "https://www.anandtech.com/rss/",
        "Geekbench Browser": "https://www.geekbench.com/rss/",
        "Ars Technica (Section Apple)": "https://arstechnica.com/feed/",
        "Apple Developer": "https://developer.apple.com/news/releases/rss/releases.rss",
        "Notebookcheck (Apple)": "https://www.notebookcheck.com/Apple-Notebooks-rss.xml",
        "Bare Feats": "https://www.barefeats.com/feed/",
        "Digital Foundry (Apple Tech)": "https://www.digitalfoundry.net/feed",
        "Objective-See (Patrick Wardle)": "https://objective-see.org/blog.html",
        "Asahi Linux Blog": "https://asahilinux.org/blog/",
        "Eclectic Light Company (Howard Oakley)": "https://eclecticlight.co/",
        "The Apple Security Research Blog": "https://security.apple.com/blog/rss/",
        "Project Zero (Google - Apple Tag)": "https://googleprojectzero.blogspot.com/feeds/posts/default/-/Apple",
        "MacStories": "https://www.macstories.net/feed/",
        "Kodeco (anciennement Ray Wenderlich)": "https://www.kodeco.com/feed.xml",
        "Swift.org": "https://www.swift.org/blog/feed.xml",
        "Hacking with Swift": "https://www.hackingwithswift.com/feed.json",
        "Swift by Sundell": "https://www.swiftbysundell.com/feed.rss",
        "NSHipster": "https://nshipster.com/feed.xml",
        "iOS Dev Weekly": "https://iosdevweekly.com/issues.rss",
        "MacUpdate": "https://feeds.macupdate.com/",
        "iClarified": "https://www.iclarified.com/feed",
        "AppShopper": "https://www.appshopper.com/appshopper-rss.xml",
        "AlternativeTo (Apple)": "https://alternativeto.net/software/apple-os/rss.xml",
        "MacAppBox": "https://www.macappbox.com/feed/",
        "MacRumors": "https://www.macrumors.com/feed/",
        "9to5Mac": "https://9to5mac.com/feed/",
        "AppleInsider": "https://appleinsider.com/inside-the-apple-ecosystem.rss",
        "Bloomberg (Section Apple)": "https://www.bloomberg.com/feed/podcast/etf-report.rss",
        "Daring Fireball (John Gruber)": "https://daringfireball.net/feeds/main",
        "Stratechery (Ben Thompson)": "https://stratechery.com/feed/",
        "MacHash": "https://www.machash.com/feed/",
        "Apple 360 / iPhone.fr": "https://www.iphone.fr/feed/",
        "Support Apple Officiel": "https://support.apple.com/en-us/HT201897",
        "OS X Daily": "https://www.osxdaily.com/feed/",
        "Der Flounder (Rich Trouton)": "https://derflounder.wordpress.com/feed/",
        "TidBITS": "https://tidbits.com/feeds/tidbits-all.xml",
        "Macworld (Section How-To)": "https://www.macworld.com/feed/",
        "Cult of Mac": "https://www.cultofmac.com/feed/",
        "The Mac Observer": "https://www.macobserver.com/feed/",
        "Mac OS X Facile": "https://www.macosxfacile.com/feed/",
        "YouTalk (Jbmm)": "https://www.youtalk.app/feed/",
        "MacYourself": "https://www.macyourself.com/feed/"
    }

    def __init__(self, ressources_path: Path):
        self.ressources_path = ressources_path
        self.sources: List[NewsSource] = []

    def load(self) -> List[NewsSource]:
        """Load sources from Ressources.md - extract from all 4 categories + traceability table"""
        if not self.ressources_path.exists():
            return []

        try:
            content = self.ressources_path.read_text(encoding='utf-8')
            self.sources = self._parse_all_sources(content)
        except Exception as e:
            print(f"⚠️ Error loading sources: {e}")

        return self.sources

    def _parse_all_sources(self, content: str) -> List[NewsSource]:
        """Parse all sources from 4 categories and traceability table"""
        sources = []
        seen_urls = set()

        # First, get URLs from traceability table
        trace_urls = self._extract_traceability_urls(content)

        # Parse all 4 category tables
        for category_num in range(1, 5):
            category_sources = self._parse_category(content, category_num)
            for source in category_sources:
                # Check if URL already added
                if source.url not in seen_urls:
                    sources.append(source)
                    seen_urls.add(source.url)
                    print(f"✅ Loaded source: {source.name} → {source.url}")

        return sources

    def _extract_traceability_urls(self, content: str) -> Dict[str, str]:
        """Extract URLs from 'Tableau de traçabilité' section"""
        urls = {}
        lines = content.split('\n')

        section_start = -1
        for idx, line in enumerate(lines):
            if 'Tableau de traçabilité' in line:
                section_start = idx
                break

        if section_start == -1:
            return urls

        in_table = False
        for idx in range(section_start, len(lines)):
            line = lines[idx]

            if '---' in line or '---|' in line:
                in_table = True
                continue

            if not in_table or '|' not in line:
                continue

            if line.strip() == '':
                break

            parts = [p.strip() for p in line.split('|')]
            parts = [p for p in parts if p]

            if len(parts) >= 2:
                name = parts[0]
                url = self._extract_url_from_markdown(parts[1])
                if url:
                    urls[name] = url

        return urls

    def _parse_category(self, content: str, category_num: int) -> List[NewsSource]:
        """Parse a specific category table"""
        sources = []
        lines = content.split('\n')

        # Find category header
        category_pattern = f"## {category_num}. Catégorie"
        section_start = -1

        for idx, line in enumerate(lines):
            if category_pattern in line:
                section_start = idx
                break

        if section_start == -1:
            return sources

        # Find the next category or end of file
        section_end = len(lines)
        for idx in range(section_start + 1, len(lines)):
            if idx < len(lines) - 1 and lines[idx].startswith('##') and f'## {category_num + 1}' in lines[idx]:
                section_end = idx
                break
            if 'Tableau de traçabilité' in lines[idx]:
                section_end = idx
                break

        # Parse the table in this category
        in_table = False
        for idx in range(section_start, section_end):
            line = lines[idx]

            if '|' not in line:
                continue

            # Skip header and separator
            if '---' in line or '---|' in line:
                in_table = True
                continue

            if not in_table:
                continue

            # Parse table row
            parts = [p.strip() for p in line.split('|')]
            parts = [p for p in parts if p]

            if len(parts) < 1:
                continue

            try:
                # Extract name (first column, remove markdown bold)
                name = parts[0].replace('**', '').strip()

                if not name or name == 'Nom du site / blog':
                    continue

                # Try to get URL from mapping
                url = self.URL_MAPPING.get(name)

                if not url:
                    # Try to construct URL from name
                    url = self._construct_url(name)

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

    def _construct_url(self, name: str) -> str:
        """Construct URL from source name using heuristics"""
        # Remove parenthetical info
        clean_name = re.sub(r'\s*\([^)]*\)', '', name).strip().lower()

        # Common domain mappings
        domain_map = {
            'swift': 'swift.org',
            'macrumors': 'macrumors.com',
            '9to5mac': '9to5mac.com',
            'macstories': 'macstories.net',
            'macworld': 'macworld.com',
            'macupdate': 'macupdate.com',
            'cultofmac': 'cultofmac.com',
            'macobserver': 'macobserver.com',
            'daring fireball': 'daringfireball.net',
            'tidbits': 'tidbits.com',
            'nshipster': 'nshipster.com',
            'kodeco': 'kodeco.com',
        }

        for key, domain in domain_map.items():
            if key in clean_name:
                return f"https://www.{domain}/feed/"

        # Generic fallback
        domain = clean_name.replace(' ', '').replace('(', '').replace(')', '')
        if domain:
            return f"https://www.{domain}.com/feed/"

        return ""

    def _extract_url_from_markdown(self, text: str) -> Optional[str]:
        """Extract URL from markdown link format"""
        # Try markdown link format: [text](url)
        match = re.search(r'\[([^\]]+)\]\(([^\)]+)\)', text)
        if match:
            return match.group(2)

        # Try backtick markdown link: `[text](url)`
        match = re.search(r'`\[([^\]]+)\]\(([^\)]+)\)`', text)
        if match:
            return match.group(2)

        # Try plain URL
        match = re.search(r'https?://[^\s`\]]+', text)
        if match:
            return match.group(0)

        return None
