#!/bin/bash

# macOS Security Checker - Quick Installation
# Ultra-fast installation with minimal output
# Usage: curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/quick-install.sh | bash

set -e

REPO="hdrapin/macOSSecurityChecker"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="macos-security-checker"

# Quick system check
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: macOS only" >&2
    exit 1
fi

# Get macOS version
MACOS_VERSION=$(sw_vers -productVersion)
MACOS_MAJOR=$(echo $MACOS_VERSION | cut -d. -f1)

if [ "$MACOS_MAJOR" -lt 11 ]; then
    echo "Error: macOS 11.0+ required" >&2
    exit 1
fi

echo "Installing macOS Security Checker..."

# Download script
SCRIPT_URL="https://raw.githubusercontent.com/$REPO/main/macOSSecurityChecker.release.swift"
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

if curl -fsSL "$SCRIPT_URL" -o "$TEMP_FILE"; then
    if [ ! -s "$TEMP_FILE" ]; then
        echo "Error: Download failed" >&2
        exit 1
    fi

    # Create dir if needed
    [ ! -d "$INSTALL_DIR" ] && mkdir -p "$INSTALL_DIR"

    # Install
    sudo cp "$TEMP_FILE" "$INSTALL_DIR/$SCRIPT_NAME"
    sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

    echo "✅ Installation complete!"
    echo ""
    echo "Usage:"
    echo "  $SCRIPT_NAME              # English"
    echo "  $SCRIPT_NAME --lang fr    # French"
    echo "  $SCRIPT_NAME --help       # Help"
else
    echo "Error: Download failed" >&2
    exit 1
fi
