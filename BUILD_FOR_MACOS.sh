#!/bin/bash

# macOSSecurityChecker Build Script for macOS
# This script compiles the security checker for native macOS execution

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║     macOS Security Checker - Build Script                      ║"
echo "║     Version 2.0.0                                              ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script must run on macOS"
    echo "   Your system: $OSTYPE"
    exit 1
fi

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion)
MACOS_MAJOR=$(echo $MACOS_VERSION | cut -d. -f1)

echo "📊 System Information:"
echo "   macOS Version: $MACOS_VERSION"
echo "   System: $(sw_vers -productName)"
echo "   Processor: $(sysctl -n machdep.cpu.brand_string)"
echo ""

# Check Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Error: Swift is not installed"
    echo "   Swift is required to compile this application"
    echo "   Install Xcode or Swift separately"
    exit 1
fi

SWIFT_VERSION=$(swift --version | head -1)
echo "✓ Swift Compiler: $SWIFT_VERSION"
echo ""

# Verify compatibility
if [ "$MACOS_MAJOR" -lt 11 ]; then
    echo "❌ Error: macOS 11.0 (Big Sur) or later required"
    exit 1
fi

if [ "$MACOS_MAJOR" -eq 16 ]; then
    echo "✓ macOS 16 (Tahoe) - Full Compatibility"
elif [ "$MACOS_MAJOR" -eq 15 ]; then
    echo "✓ macOS 15 (Sequoia) - Full Compatibility"
elif [ "$MACOS_MAJOR" -eq 14 ]; then
    echo "✓ macOS 14 (Sonoma) - Compatible"
elif [ "$MACOS_MAJOR" -eq 13 ]; then
    echo "✓ macOS 13 (Ventura) - Compatible"
elif [ "$MACOS_MAJOR" -eq 12 ]; then
    echo "✓ macOS 12 (Monterey) - Compatible"
elif [ "$MACOS_MAJOR" -eq 11 ]; then
    echo "✓ macOS 11 (Big Sur) - Compatible"
fi
echo ""

# Determine output directory
OUTPUT_DIR="./build"
EXECUTABLE_NAME="macOSSecurityChecker"

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "📁 Creating build directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

echo "🔨 Compiling macOSSecurityChecker..."
echo "   Source: macOSSecurityChecker.release.swift"
echo "   Output: $OUTPUT_DIR/$EXECUTABLE_NAME"
echo ""

# Compile with optimizations
swiftc -O \
    -o "$OUTPUT_DIR/$EXECUTABLE_NAME" \
    macOSSecurityChecker.release.swift

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful!"
    echo ""

    # Make executable
    chmod +x "$OUTPUT_DIR/$EXECUTABLE_NAME"

    # Show file info
    FILE_SIZE=$(ls -lh "$OUTPUT_DIR/$EXECUTABLE_NAME" | awk '{print $5}')
    echo "📊 Build Information:"
    echo "   Binary: $OUTPUT_DIR/$EXECUTABLE_NAME"
    echo "   Size: $FILE_SIZE"
    echo ""

    # Verify binary
    file "$OUTPUT_DIR/$EXECUTABLE_NAME"
    echo ""

    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                   BUILD SUCCESSFUL! ✓                          ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🚀 To run the security checker:"
    echo "   ./$OUTPUT_DIR/$EXECUTABLE_NAME"
    echo ""
    echo "📋 To see all options:"
    echo "   ./$OUTPUT_DIR/$EXECUTABLE_NAME --help"
    echo ""
    echo "💾 To export as JSON:"
    echo "   ./$OUTPUT_DIR/$EXECUTABLE_NAME --json > audit.json"
    echo ""
    echo "📊 To export as CSV:"
    echo "   ./$OUTPUT_DIR/$EXECUTABLE_NAME --csv > audit.csv"
    echo ""
    echo "For admin checks (full results):"
    echo "   sudo ./$OUTPUT_DIR/$EXECUTABLE_NAME"
    echo ""
else
    echo "❌ Compilation failed!"
    exit 1
fi
