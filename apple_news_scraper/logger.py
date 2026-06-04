"""Logger - Generate markdown logs with source statistics"""

from datetime import datetime
from pathlib import Path
from typing import List, Optional

class MdLogger:
    """Generate markdown logs with execution details"""

    def __init__(self, logs_dir: Path):
        self.logs_dir = logs_dir
        self.sources_data: List[dict] = []
        self.start_time = datetime.now()

    def log_source(self, name: str, count: int, duration: float, status: str, error: Optional[str] = None):
        """Log source fetch result"""
        self.sources_data.append({
            'name': name,
            'count': count,
            'duration': duration,
            'status': status,
            'error': error
        })

    def save_to_file(self, date: Optional[datetime] = None, total_articles: int = 0, duplicates_removed: int = 0) -> Path:
        """Save logs to file"""
        if date is None:
            date = datetime.now()

        filename = date.strftime("%d-%m-%Y") + ".md"
        log_path = self.logs_dir / filename

        # Build content
        content = f"# Logs Exécution - {date.strftime('%d %b %Y')}\n\n"
        content += f"**Timestamp:** {date.strftime('%Y-%m-%d %H:%M:%S')} UTC\n\n"

        # Summary
        content += "## 📊 Résumé Sources\n\n"

        if self.sources_data:
            content += "| Source | Articles | Statut | Durée | Erreur |\n"
            content += "|--------|----------|--------|-------|--------|\n"

            total_duration = 0
            for source in self.sources_data:
                error_col = source['error'] if source['error'] else ""
                content += f"| {source['name']} | {source['count']} | {source['status']} | {source['duration']:.1f}s | {error_col} |\n"
                total_duration += source['duration']

            content += f"\n**Durée totale:** {total_duration:.1f}s\n"
            content += f"**Articles totaux récupérés:** {total_articles}\n"
            content += f"**Doublons supprimés:** {duplicates_removed}\n"
        else:
            content += "Aucune source traitée.\n"

        # Write file
        try:
            log_path.write_text(content, encoding='utf-8')
        except Exception as e:
            print(f"⚠️ Error writing log file: {e}")

        return log_path
