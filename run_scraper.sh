#!/bin/bash
# Wrapper for LaunchAgent execution

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"
source "$DIR/venv/bin/activate"
python apple_news_scraper/main.py 2>&1
