#!/bin/bash

# macOS Security Checker - Installation Script
# Downloads and installs macOS Security Checker from GitHub
# Usage: curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="hdrapin/macOSSecurityChecker"
GITHUB_RELEASE_API="https://api.github.com/repos/$REPO/releases/latest"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="macos-security-checker"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}║     macOS Security Checker - Installation Script              ║${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: This installation script is for macOS only${NC}"
    echo "   Your system: $OSTYPE"
    exit 1
fi

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion)
MACOS_MAJOR=$(echo $MACOS_VERSION | cut -d. -f1)

echo -e "${YELLOW}📊 System Information:${NC}"
echo "   macOS Version: $MACOS_VERSION"
echo "   System: $(sw_vers -productName)"
echo ""

# Verify compatibility
if [ "$MACOS_MAJOR" -lt 11 ]; then
    echo -e "${RED}❌ Error: macOS 11.0 (Big Sur) or later required${NC}"
    exit 1
fi

echo -e "${GREEN}✓ macOS version compatible${NC}"
echo ""

# Installation options
echo -e "${BLUE}📦 Installation Options:${NC}"
echo "   1. Script (28 KB) - Direct execution, no compilation"
echo "   2. Binary (optimized) - Pre-compiled, faster"
echo ""
read -p "Choose installation method (1 or 2) [default: 1]: " INSTALL_METHOD
INSTALL_METHOD=${INSTALL_METHOD:-1}

echo ""

case $INSTALL_METHOD in
    1)
        echo -e "${YELLOW}📥 Downloading macOS Security Checker script...${NC}"

        # Download the script
        SCRIPT_URL="https://raw.githubusercontent.com/$REPO/main/macOSSecurityChecker.release.swift"

        if ! command -v curl &> /dev/null; then
            echo -e "${RED}❌ Error: curl is required for installation${NC}"
            exit 1
        fi

        # Create temp file
        TEMP_FILE=$(mktemp)
        trap "rm -f $TEMP_FILE" EXIT

        if curl -fsSL "$SCRIPT_URL" -o "$TEMP_FILE"; then
            # Check if download successful
            if [ ! -s "$TEMP_FILE" ]; then
                echo -e "${RED}❌ Error: Downloaded file is empty${NC}"
                exit 1
            fi

            # Create installation directory if needed
            if [ ! -d "$INSTALL_DIR" ]; then
                echo -e "${YELLOW}📁 Creating installation directory...${NC}"
                mkdir -p "$INSTALL_DIR"
            fi

            # Copy and make executable
            sudo cp "$TEMP_FILE" "$INSTALL_DIR/$SCRIPT_NAME"
            sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

            echo -e "${GREEN}✅ Installation successful!${NC}"
            echo ""
            echo -e "${BLUE}🚀 Usage:${NC}"
            echo "   $ $SCRIPT_NAME                    # English (default)"
            echo "   $ $SCRIPT_NAME --lang fr          # French"
            echo "   $ $SCRIPT_NAME --json             # JSON output"
            echo "   $ $SCRIPT_NAME --help             # Show help"
            echo ""
            echo -e "${BLUE}📖 First run:${NC}"
            echo "   $ $SCRIPT_NAME"
            echo ""
        else
            echo -e "${RED}❌ Error: Failed to download installation script${NC}"
            exit 1
        fi
        ;;

    2)
        echo -e "${YELLOW}📥 Downloading binary (this may take a moment)...${NC}"

        # Get latest release info
        RELEASE_INFO=$(curl -fsSL "$GITHUB_RELEASE_API" 2>/dev/null || echo "")

        if [ -z "$RELEASE_INFO" ]; then
            echo -e "${RED}❌ Error: Could not fetch latest release information${NC}"
            echo "   Please check your internet connection or try manual installation:"
            echo "   https://github.com/$REPO/releases"
            exit 1
        fi

        # Detect macOS version for binary download
        case $MACOS_MAJOR in
            11|12) BINARY_NAME="macOSSecurityChecker-macos-12.tar.gz" ;;
            13) BINARY_NAME="macOSSecurityChecker-macos-13.tar.gz" ;;
            14|15|16) BINARY_NAME="macOSSecurityChecker-macos-14.tar.gz" ;;
            *) BINARY_NAME="macOSSecurityChecker-macos-14.tar.gz" ;;
        esac

        # Get download URL
        DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -o "\"browser_download_url\": \"[^\"]*$BINARY_NAME" | head -1 | cut -d'"' -f4)

        if [ -z "$DOWNLOAD_URL" ]; then
            echo -e "${RED}❌ Error: Could not find binary for your macOS version${NC}"
            echo "   Please use installation method 1 (script) instead"
            exit 1
        fi

        # Create temp directory
        TEMP_DIR=$(mktemp -d)
        trap "rm -rf $TEMP_DIR" EXIT

        # Download binary
        if curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/$BINARY_NAME"; then
            echo -e "${YELLOW}📦 Extracting binary...${NC}"

            # Extract
            cd "$TEMP_DIR"
            tar -xzf "$BINARY_NAME"

            # Find binary (name may vary)
            BINARY_FILE=$(find "$TEMP_DIR" -type f -executable -name "macOSSecurityChecker*" | head -1)

            if [ -z "$BINARY_FILE" ]; then
                echo -e "${RED}❌ Error: Could not find executable in archive${NC}"
                exit 1
            fi

            # Create installation directory if needed
            if [ ! -d "$INSTALL_DIR" ]; then
                echo -e "${YELLOW}📁 Creating installation directory...${NC}"
                mkdir -p "$INSTALL_DIR"
            fi

            # Copy and make executable
            sudo cp "$BINARY_FILE" "$INSTALL_DIR/$SCRIPT_NAME"
            sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

            echo -e "${GREEN}✅ Installation successful!${NC}"
            echo ""
            echo -e "${BLUE}🚀 Usage:${NC}"
            echo "   $ $SCRIPT_NAME                    # English (default)"
            echo "   $ $SCRIPT_NAME --lang fr          # French"
            echo "   $ $SCRIPT_NAME --json             # JSON output"
            echo "   $ $SCRIPT_NAME --help             # Show help"
            echo ""
            echo -e "${BLUE}⚡ Performance:${NC}"
            echo "   Compiled binary is 2x faster than script"
            echo "   First run: ~2-3 seconds"
            echo ""
        else
            echo -e "${RED}❌ Error: Failed to download binary${NC}"
            exit 1
        fi
        ;;

    *)
        echo -e "${RED}❌ Invalid option: $INSTALL_METHOD${NC}"
        exit 1
        ;;
esac

# Verification
echo -e "${YELLOW}🔍 Verifying installation...${NC}"
if command -v $SCRIPT_NAME &> /dev/null; then
    VERSION=$($SCRIPT_NAME --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✅ Verification successful!${NC}"
    echo "   Version: $VERSION"
    echo ""
    echo -e "${BLUE}📚 Documentation:${NC}"
    echo "   • Help:        $SCRIPT_NAME --help"
    echo "   • Full Docs:   https://github.com/$REPO/blob/main/README.md"
    echo "   • French:      $SCRIPT_NAME --lang fr"
    echo ""
    echo -e "${GREEN}🎉 macOS Security Checker is ready to use!${NC}"
else
    echo -e "${RED}❌ Verification failed${NC}"
    echo "   Try running: source ~/.zprofile"
    exit 1
fi
