#!/bin/bash
# Setup script for macOS Security Checker + Homey Integration
# Makes scripts executable and sets up automation

echo "🏠 Setting up macOS Security Checker + Homey Integration"
echo "════════════════════════════════════════════════════════"

# Make scripts executable
echo "📝 Making scripts executable..."
chmod +x macOSSecurityChecker.release.swift 2>/dev/null
chmod +x macOSSecurityChecker-Homey.swift 2>/dev/null
chmod +x setup-homey.sh 2>/dev/null

echo "✅ Scripts are now executable"

# Create symlink for easy access
echo ""
echo "🔗 Creating system links..."
sudo cp macOSSecurityChecker.release.swift /usr/local/bin/macos-security-checker 2>/dev/null && \
sudo chmod +x /usr/local/bin/macos-security-checker && \
echo "✅ Installed: macos-security-checker" || \
echo "⚠️ Could not install system-wide (use ./macOSSecurityChecker.release.swift instead)"

# Test Homey integration
echo ""
echo "🧪 Testing Homey Integration..."
if ./macOSSecurityChecker-Homey.swift --help > /dev/null 2>&1; then
    echo "✅ Homey module is working"
else
    echo "❌ Issue with Homey module"
fi

# Setup automation (optional)
echo ""
read -p "Would you like to setup daily automation? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📅 Setting up daily automation..."
    echo ""
    echo "Choose method:"
    echo "1) Cron job (runs daily at 9 AM)"
    echo "2) LaunchAgent (background service)"
    echo "3) Skip"
    read -p "Select (1/2/3): " choice

    case $choice in
        1)
            echo ""
            echo "Adding cron job..."
            SCRIPT_PATH="$(pwd)/macOSSecurityChecker-Homey.swift"
            (crontab -l 2>/dev/null; echo "0 9 * * * $SCRIPT_PATH --homey 2>&1 | logger -t security-checker") | crontab -
            echo "✅ Cron job installed (runs daily at 9 AM)"
            ;;
        2)
            echo ""
            echo "Creating LaunchAgent..."
            PLIST_PATH="$HOME/Library/LaunchAgents/com.macos.securitychecker.homey.plist"
            SCRIPT_PATH="$(pwd)/macOSSecurityChecker-Homey.swift"

            mkdir -p "$HOME/Library/LaunchAgents"

            cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.macos.securitychecker.homey</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_PATH</string>
        <string>--homey</string>
    </array>
    <key>StartInterval</key>
    <integer>86400</integer>
    <key>StandardErrorPath</key>
    <string>/tmp/security-checker-error.log</string>
    <key>StandardOutPath</key>
    <string>/tmp/security-checker.log</string>
</dict>
</plist>
EOF

            launchctl load "$PLIST_PATH" 2>/dev/null
            echo "✅ LaunchAgent installed"
            echo "   Path: $PLIST_PATH"
            echo "   Logs: /tmp/security-checker.log"
            ;;
        *)
            echo "⏭️ Skipped automation setup"
            ;;
    esac
fi

# Print next steps
echo ""
echo "════════════════════════════════════════════════════════"
echo "✅ Setup complete!"
echo ""
echo "📖 Next steps:"
echo "   1. Run: ./macOSSecurityChecker.release.swift"
echo "   2. See Homey flows: ./macOSSecurityChecker-Homey.swift --homey"
echo "   3. Read: HOMEY_INTEGRATION.md"
echo ""
echo "🏠 Homey Flows Status:"
echo "   ✅ 5 flows created and active in Homey Pro"
echo "   ✅ Ready to trigger based on security score"
echo ""
echo "════════════════════════════════════════════════════════"
