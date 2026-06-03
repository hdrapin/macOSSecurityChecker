#!/bin/bash
# Setup macOS - Complete installation of the scraper

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🔧 Setup Apple News Scraper"
echo "📍 Directory: $DIR"

# 1. Create virtual environment
echo ""
echo "1️⃣ Creating virtual environment..."
if [ -d "$DIR/venv" ]; then
    echo "✅ venv already exists"
else
    python3 -m venv "$DIR/venv"
    echo "✅ venv created"
fi

# 2. Activate venv and install dependencies
echo ""
echo "2️⃣ Installing dependencies..."
source "$DIR/venv/bin/activate"
pip install --upgrade pip > /dev/null 2>&1
pip install -q -r "$DIR/requirements.txt"
echo "✅ Dependencies installed"

# 3. Create directories
echo ""
echo "3️⃣ Creating directories..."
mkdir -p "$DIR/News" "$DIR/Logs" "$DIR/Cache"
echo "✅ Directories created"

# 4. Quick test
echo ""
echo "4️⃣ Testing execution..."
cd "$DIR"
python apple_news_scraper/main.py > /dev/null 2>&1 && echo "✅ Script works" || echo "⚠️ Error in test"

# 5. Setup LaunchAgent (optional)
echo ""
echo "5️⃣ Setup LaunchAgent macOS (optional)"
echo ""
echo "To install daily execution at 14:00 UTC:"
echo ""
echo "  cp '$DIR/com.hdrapin.apple-news.plist' ~/Library/LaunchAgents/"
echo "  launchctl load ~/Library/LaunchAgents/com.hdrapin.apple-news.plist"
echo ""
echo "To verify installation:"
echo "  launchctl list | grep apple-news"
echo ""
echo "To run manually:"
echo "  launchctl start com.hdrapin.apple-news"
echo ""
echo "To see LaunchAgent logs:"
echo "  tail -f '$DIR/LaunchAgent.log'"
echo ""
echo "To see daily script logs:"
echo "  ls -la '$DIR/Logs/'"
echo "  cat '$DIR/Logs/03-06-2026.md'"
echo ""

echo "✅ Setup complete!"
echo ""
echo "Immediate usage:"
echo "  source $DIR/venv/bin/activate"
echo "  python apple_news_scraper/main.py"
