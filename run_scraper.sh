#!/bin/bash

# Apple News Scraper - Wrapper Script for LaunchAgent
# This script activates the venv and runs the scraper

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VENV_DIR="$PROJECT_DIR/venv"

# Activate virtual environment
if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
else
    echo "❌ Error: Virtual environment not found at $VENV_DIR"
    exit 1
fi

# Change to project directory
cd "$PROJECT_DIR"

# Run the scraper
python apple_news_scraper/main.py
