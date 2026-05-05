# 🔒 macOS Security Checker v2.0

**Professional macOS Security Audit Tool** - Analyze 88 security parameters with beautiful terminal output

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)](https://www.swift.org)
[![macOS](https://img.shields.io/badge/macOS-11.0%2B-green.svg)](https://www.apple.com/macos)
[![Version](https://img.shields.io/badge/Version-2.0.1-brightgreen.svg)](https://github.com/hdrapin/macOSSecurityChecker/releases/tag/v2.0.1)

---

## ⚠️ Important: Version Information

**Current Version: v2.0.1** with 88 comprehensive security checks and multilingual support.

> **Note:** If you downloaded an older version (before May 2026) or see only 4-7 checks instead of 88, please update to v2.0.1 using one of the methods below. The older version is incomplete.

---

## 🎯 Quick Start

```bash
# Clone the latest version (RECOMMENDED)
git clone https://github.com/hdrapin/macOSSecurityChecker.git
cd macOSSecurityChecker

# Execute directly (no compilation)
./macOSSecurityChecker.release.swift

# Or with French output
./macOSSecurityChecker.release.swift --lang fr

# Or compile to native binary (2x faster)
./BUILD_FOR_MACOS.sh
./build/macOSSecurityChecker
```

---

## ✨ Features

### 🔍 88 Comprehensive Security Checks

Organized in **9 categories**:

| Category | Count | Focus |
|----------|-------|-------|
| 🖥️ System Information | 5 | Hardware & OS details |
| 🔥 Firewall & Network | 9 | Network security config |
| 📱 Remote Access | 8 | SSH, ARD, AirDrop controls |
| 👤 User Accounts | 6 | Account security settings |
| 🔍 Privacy & Tracking | 9 | Privacy and data collection |
| ☁️ iCloud & Auth | 8 | Cloud security & 2FA |
| 🛡️ Encryption & Boot | 9 | System encryption & firmware |
| 🔄 System Updates | 5 | Update & patch status |
| ⚙️ Advanced Features | 6 | Kernel & advanced security |

### 🎨 Beautiful Terminal Interface
- ✅ Auto-detecting ANSI color support
- ✅ Visual progress bars (█ and ░)
- ✅ Color-coded results (🟢 ✓ / 🔴 ✗ / 🟡 ⚠️)
- ✅ Organized by security category
- ✅ Security score 0-10 with risk level

### 📊 Multiple Output Formats
- **Text** - Beautiful formatted output (default)
- **JSON** - Machine-readable structured data
- **CSV** - Spreadsheet-compatible format
- **Verbose** - Detailed explanations

### 🌐 Multilingual Support
- 🇬🇧 **English** (default)
- 🇫🇷 **French** (`--lang fr`)

### ⚡ Fast & Efficient
- ⏱️ Complete audit in **4-5 seconds**
- 💾 Minimal resource usage (< 50 MB RAM)
- 🚀 No external dependencies
- 🔐 Local audit only (no network calls)

### 🔐 macOS Compatibility
- ✅ macOS 11 (Big Sur)
- ✅ macOS 12 (Monterey)
- ✅ macOS 13 (Ventura)
- ✅ macOS 14 (Sonoma)
- ✅ macOS 15 (Sequoia)
- ✅ **macOS 16 (Tahoe)** - Verified Compatible

---

## 📦 Installation Methods

### Method 1: One-Command Installation (Fastest ⚡)

**Ultra-fast 30-second installation** with curl - perfect for first-time users:

```bash
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/quick-install.sh | bash
macos-security-checker
```

Or with interactive options to choose between script/binary:
```bash
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/install.sh | bash
```

✅ Installs to `/usr/local/bin` for system-wide access  
✅ Automatic macOS compatibility check  
✅ Ready to use immediately  
📖 [Full installation guide](INSTALLATION_CURL.md)

---

### Method 2: Direct Execution (Recommended for Quick Audits)

⚠️ **IMPORTANT:** Use `macOSSecurityChecker.release.swift` - NOT `macOSSecurityChecker.swift`

```bash
chmod +x macOSSecurityChecker.release.swift
./macOSSecurityChecker.release.swift
```

Expected output:
- ✓ 88 security checks (not 4-7)
- ✓ 9 security categories
- ✓ Complete detailed report
- ⏱️ ~5 seconds (includes compilation)

**If you see only 4-7 checks:**
→ You have an older incomplete version. Clone the latest from GitHub or use curl installation.

### Method 3: Compiled Binary (Recommended for Production)
```bash
./BUILD_FOR_MACOS.sh          # Compile
./build/macOSSecurityChecker  # Run

# Or install system-wide
sudo cp build/macOSSecurityChecker /usr/local/bin/macos-security-checker
macos-security-checker --help
```
- ✓ 2x faster execution (~2 seconds)
- ✓ No Swift installation required
- ✓ Ready-to-distribute binary

### Method 4: From GitHub Releases
```bash
# Download pre-compiled binary from GitHub
# https://github.com/hdrapin/macOSSecurityChecker/releases

tar -xzf macOSSecurityChecker-macos-14.tar.gz
chmod +x macOSSecurityChecker-macos-14
./macOSSecurityChecker-macos-14
```

### Method 5: System-Wide Installation
```bash
sudo cp macOSSecurityChecker.release.swift /usr/local/bin/macos-security-checker
sudo chmod +x /usr/local/bin/macos-security-checker

# Use from anywhere
macos-security-checker --help
```

---

## 📖 Usage

### Basic Commands

```bash
# Default text output (English)
./macOSSecurityChecker.release.swift

# French output
./macOSSecurityChecker.release.swift --lang fr

# Verbose mode with detailed information
./macOSSecurityChecker.release.swift --verbose

# Combine options (now fully working!)
./macOSSecurityChecker.release.swift --lang fr --verbose

# Help and options
./macOSSecurityChecker.release.swift --help

# Show version
./macOSSecurityChecker.release.swift --version
```

**✨ NEW:** All command-line options now work together! Combine `--lang fr` with `--verbose`, `--json`, etc.

### Output Formats
```bash
# JSON export (for integration with other tools)
./macOSSecurityChecker.release.swift --json > audit.json

# CSV export (for spreadsheet analysis)
./macOSSecurityChecker.release.swift --csv > audit.csv

# Pipe to file while displaying
./macOSSecurityChecker.release.swift | tee audit.txt

# Combine language with output format
./macOSSecurityChecker.release.swift --lang fr --json > audit_fr.json
```

### Available Options

| Option | Description | Example |
|--------|-------------|---------|
| `--help` | Show help message | `./macOSSecurityChecker.release.swift --help` |
| `--version` | Show version information | `./macOSSecurityChecker.release.swift --version` |
| `--lang LANG` | Set language (en, fr) | `./macOSSecurityChecker.release.swift --lang fr` |
| `--verbose` | Show detailed explanations | `./macOSSecurityChecker.release.swift --verbose` |
| `--json` | JSON output format | `./macOSSecurityChecker.release.swift --json` |
| `--csv` | CSV output format | `./macOSSecurityChecker.release.swift --csv` |

### Language Options
```bash
# English (default)
./macOSSecurityChecker.release.swift --lang en

# French
./macOSSecurityChecker.release.swift --lang fr

# With other options
./macOSSecurityChecker.release.swift --lang fr --json
./macOSSecurityChecker.release.swift --lang en --verbose
```

### Common Use Cases
```bash
# Full audit with admin privileges (recommended)
sudo ./macOSSecurityChecker.release.swift

# Regular user audit (limited results)
./macOSSecurityChecker.release.swift

# Detailed compliance report
./macOSSecurityChecker.release.swift --verbose > compliance_report.txt

# Automated weekly audit
0 2 * * 0 /path/to/macOSSecurityChecker.release.swift --json >> /var/log/security_audits.json

# Parse specific results with jq
./macOSSecurityChecker.release.swift --json | jq '.metadata.score'
```

---

## 📊 Understanding the Output

### Security Score Scale
| Score | Level | Emoji | Meaning |
|-------|-------|-------|---------|
| 9.0-10.0 | EXCELLENT | 🟢 | Exceptional security posture |
| 8.0-8.9 | GOOD | 🟢 | Strong security implementation |
| 7.0-7.9 | FAIR | 🟡 | Some improvements recommended |
| 5.0-6.9 | NEEDS ATTENTION | 🟠 | Multiple issues to address |
| 0.0-4.9 | CRITICAL | 🔴 | Immediate action required |

### Status Indicators
- ✅ **Green (✓)** - Security feature is enabled/secure
- ❌ **Red (✗)** - Security feature is disabled/at risk
- ⚠️ **Yellow (⚠️)** - Warning: review recommended
- ❓ **Gray (?)** - Unknown: need admin access

---

## 🛠️ Command-Line Options

```bash
Usage: ./macOSSecurityChecker.release.swift [OPTIONS]

OPTIONS:
  --help, -h           Display help message
  --version            Show version information
  --verbose, -v        Show detailed explanations
  --lang LANGUAGE      Set language (en, fr)
  --json              Export as JSON
  --csv               Export as CSV
  --text              Plain text output (default)
  --format FORMAT     Specify format (text, json, csv)

EXAMPLES:
  ./macOSSecurityChecker.release.swift                    # Default
  ./macOSSecurityChecker.release.swift --json             # JSON export
  ./macOSSecurityChecker.release.swift --lang fr          # French
  ./macOSSecurityChecker.release.swift --verbose          # Detailed
  sudo ./macOSSecurityChecker.release.swift               # Admin mode
```

---

## 🔍 Security Checks Details

### 🖥️ System Information (5 checks)
- Mac Model identification
- macOS version and build number
- Processor type and count
- Available system memory
- Tahoe (macOS 16) compatibility

### 🔥 Firewall & Network (9 checks)
- Firewall enabled status
- Stealth mode configuration
- SSH remote access settings
- Screen sharing status
- File sharing (SMB) status
- Bluetooth status and discoverability
- Wake-on-Network configuration
- Bonjour/mDNS status

### 📱 Remote Access (8 checks)
- SSH password authentication
- SSH root login restrictions
- Remote Apple Events
- Apple Remote Desktop status
- Screen sharing configuration
- Remote management status
- AirDrop restrictions
- Universal Clipboard status

### 👤 User Account Security (6 checks)
- Auto-login disabled
- Guest account disabled
- Fast user switching status
- Admin account count
- Password policy enforcement
- Failed login attempt limits

### 🔍 Privacy & Tracking (9 checks)
- Location Services status
- Safari privacy settings
- Do Not Track preference
- Cookie blocking
- Siri suggestions and analytics
- Spotlight privacy
- Microphone access indicator
- Camera access indicator

### ☁️ iCloud & Authentication (8 checks)
- iCloud account status
- Two-factor authentication
- iCloud Keychain
- Find My Mac feature
- Handoff/Continuity
- iCloud Drive
- Secure Token status
- Touch ID enrollment

### 🛡️ Encryption & Boot (9 checks)
- FileVault encryption status
- Secure Boot configuration
- System Integrity Protection (SIP)
- Signed System Volume (SSV)
- Recovery mode password
- Firmware password
- USB Restricted Mode
- Developer Mode status
- System Preferences locking

### 🔄 System Updates (5 checks)
- Automatic security updates
- Automatic system updates
- Current security patch status
- Last update check timestamp
- XProtect and MRT updates

### ⚙️ Advanced Features (6 checks)
- Kernel CTRR (memory protection)
- Boot arguments filtering
- Gatekeeper code signing
- XProtect version
- MRT version
- IPv6 support status

---

## 📈 Example Output

```
╔═══════════════════════════════════════════════════════════════════╗
│  🔒 macOS SECURITY AUDIT REPORT v2.0.0 🔒                        │
│  MacBook Pro 16-inch M3 Max                                       │
│  macOS 15.1 (Sequoia)                                             │
│  Status: 75/88 checks passed (85.2%)                              │
│  Score: 8.5/10 - EXCELLENT                                        │
└═══════════════════════════════════════════════════════════════════┘

[███████████████████████████████████████░░░░░░░░░░] 85.2%

🔥 FIREWALL & NETWORK SECURITY (9/9 PASSED)
  ✓ Firewall Enabled                   ENABLED
  ✓ Firewall Stealth Mode              ENABLED
  ✗ SSH Enabled                        ENABLED (⚠️ review if needed)
  ...
```

---

## 🧪 Testing

The tool includes comprehensive tests:

```bash
# Run test suite
./macOSSecurityChecker-Tests.swift

# Expected: 25+ test cases
# Coverage: Unit tests, integration tests, edge cases
```

---

## 🛠️ Troubleshooting

### Script Won't Execute
```bash
# Check permissions
chmod +x macOSSecurityChecker.release.swift

# Run with Swift directly
swift macOSSecurityChecker.release.swift

# With admin if needed
sudo ./macOSSecurityChecker.release.swift
```

### Missing Values or "Unknown" Status
```bash
# Some checks require admin privileges
sudo ./macOSSecurityChecker.release.swift

# Or use combined with other options
sudo ./macOSSecurityChecker.release.swift --lang fr --json
```

### No Color Output
```bash
# Force color support
TERM=xterm-256color ./macOSSecurityChecker.release.swift

# Or use non-color format
./macOSSecurityChecker.release.swift --csv
./macOSSecurityChecker.release.swift --json
```

### Performance Issues
```bash
# Use compiled binary (2x faster)
./BUILD_FOR_MACOS.sh
./build/macOSSecurityChecker

# Or with optimizations
swift -O macOSSecurityChecker.release.swift
```

---

## 📚 Documentation

- **[README_DETAILED.md](README_DETAILED.md)** - Complete documentation (FR/EN)
- **[INSTALL_FOR_MACOS.md](INSTALL_FOR_MACOS.md)** - Installation guide
- **[VERSION_2_SUMMARY.md](VERSION_2_SUMMARY.md)** - Feature overview
- **[CODE_DOCUMENTATION.md](CODE_DOCUMENTATION.md)** - Code structure & API
- **[LOCALIZATION.md](LOCALIZATION.md)** - Language support guide
- **[DISTRIBUTION.md](DISTRIBUTION.md)** - Release & distribution guide

---

## 🔐 Security & Privacy

- ✅ **Local Audit Only** - No data sent externally
- ✅ **Read-Only Operations** - No system modifications
- ✅ **No Telemetry** - No tracking or analytics
- ✅ **No Dependencies** - Self-contained application
- ✅ **Open Source** - Full source code visibility

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commits
4. Add/update tests
5. Submit a pull request

**Development Guidelines:**
- Follow Swift conventions
- Include error handling
- Add tests for new features
- Update documentation
- Test on multiple macOS versions

---

## 📋 Requirements

### System
- **OS:** macOS 11.0 or later
- **CPU:** Intel or Apple Silicon (M1/M2/M3+)
- **Storage:** < 5 MB
- **RAM:** Minimal (< 50 MB)

### Software
- **Swift:** 5.5+ (pre-installed on macOS)
- **Bash:** Standard shell

### Privileges
- **User Mode:** Works for basic checks
- **Admin Mode:** Full results with `sudo`

---

## 📊 Version History

### v2.0.0 (May 2024)
- ✨ **New:** 88 comprehensive security checks (up from 18)
- ✨ **New:** Beautiful terminal UI with colors
- ✨ **New:** Security scoring system (0-10)
- ✨ **New:** Multilingual support (EN/FR)
- ✨ **New:** Multiple output formats (Text/JSON/CSV)
- ✨ **New:** Tahoe (macOS 16) compatibility
- 🔧 **Improved:** Dynamic system queries (no hardcoded values)
- 🔧 **Improved:** Comprehensive error handling
- 📝 **New:** Complete documentation

### v1.0 (November 2024)
- Initial release with basic security checks

---

## 🔧 Troubleshooting

### Problem: Script shows error "expected a macro identifier for a pound literal expression"

**Cause:** You're running an old version of the script (macOSSecurityChecker.swift) instead of the new version.

**Solution:**
```bash
# Make sure you're using the correct file:
./macOSSecurityChecker.release.swift

# NOT:
./macOSSecurityChecker.swift
```

### Problem: Only 4-7 checks instead of 88

**Cause:** You have an incomplete or outdated version of the script.

**Solution:**
```bash
# Update to the latest version
git clone https://github.com/hdrapin/macOSSecurityChecker.git
cd macOSSecurityChecker
./macOSSecurityChecker.release.swift

# Or use curl installation
curl -fsSL https://raw.githubusercontent.com/hdrapin/macOSSecurityChecker/main/quick-install.sh | bash
macos-security-checker
```

### Problem: "Permission denied" when running the script

**Solution:**
```bash
# Make the script executable
chmod +x macOSSecurityChecker.release.swift

# Then run it
./macOSSecurityChecker.release.swift
```

### Problem: Some checks show "Unknown" or "N/A"

**Cause:** The tool is running without admin privileges.

**Solution:**
```bash
# Run with sudo for complete results
sudo ./macOSSecurityChecker.release.swift

# Or use with admin account
sudo -u administrator ./macOSSecurityChecker.release.swift
```

### Problem: Command not found after curl installation

**Solution:**
```bash
# Refresh your shell session
source ~/.zprofile
# or
source ~/.bash_profile

# Then try again
macos-security-checker
```

### Problem: Can't execute script with Swift directly

**Solution - Try one of these methods:**

```bash
# Method 1: Use swift interpreter
swift ./macOSSecurityChecker.release.swift

# Method 2: Compile to binary first
./BUILD_FOR_MACOS.sh
./build/macOSSecurityChecker

# Method 3: Copy to system path
sudo cp macOSSecurityChecker.release.swift /usr/local/bin/macos-security-checker
sudo chmod +x /usr/local/bin/macos-security-checker
macos-security-checker
```

### Getting Help

If you encounter other issues:

1. **Check the version:**
   ```bash
   ./macOSSecurityChecker.release.swift --version
   ```
   Should show v2.0.1 or later.

2. **Enable verbose output:**
   ```bash
   ./macOSSecurityChecker.release.swift --verbose
   ```

3. **Export results for analysis:**
   ```bash
   ./macOSSecurityChecker.release.swift --json > results.json
   ```

4. **Check documentation:**
   - [Installation Guide](INSTALLATION_CURL.md)
   - [Complete Documentation](README_DETAILED.md)
   - [FAQ](FAQ_DISTRIBUTION.md)

---

## 📞 Support & Feedback

- **Issues:** [GitHub Issues](https://github.com/hdrapin/macOSSecurityChecker/issues)
- **Discussions:** [GitHub Discussions](https://github.com/hdrapin/macOSSecurityChecker/discussions)
- **Documentation:** See docs/ directory
- **Security:** Report issues responsibly

---

## 📄 License

**Apache License 2.0** - Free for personal and commercial use

See [LICENSE](LICENSE) file for details.

---

## 🎯 Recommended Next Steps

1. **Run the Audit** - Get your baseline security score
2. **Review Results** - Check areas marked for improvement
3. **Take Action** - Implement recommended security changes
4. **Schedule Regular Audits** - Track improvements over time
5. **Stay Updated** - Check for latest version periodically

---

**Last Updated:** May 2026  
**Version:** 2.0.1  
**Status:** Production Ready ✓  
**Downloads:** [GitHub Releases](https://github.com/hdrapin/macOSSecurityChecker/releases)  
**Support:** [Issues](https://github.com/hdrapin/macOSSecurityChecker/issues) | [Discussions](https://github.com/hdrapin/macOSSecurityChecker/discussions)

---

Made with ❤️ for macOS security
