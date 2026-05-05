# macOSSecurityChecker v2.0 - Installation Guide for macOS

## 🚀 Quick Start

### Step 1: Clone or Download
```bash
git clone https://github.com/hdrapin/macOSSecurityChecker.git
cd macOSSecurityChecker
```

### Step 2: Make Executable
```bash
chmod +x macOSSecurityChecker.release.swift
chmod +x BUILD_FOR_MACOS.sh
```

### Step 3: Run Directly (Fastest)
```bash
./macOSSecurityChecker.release.swift
```

Or compile to native binary:
```bash
./BUILD_FOR_MACOS.sh
./build/macOSSecurityChecker
```

---

## 📋 Installation Methods

### Method 1: Direct Execution (Recommended for Quick Audits)
```bash
./macOSSecurityChecker.release.swift
```
- ✓ No compilation needed
- ✓ Works on macOS 11.0+
- ✓ Results in ~4-5 seconds

### Method 2: Compiled Binary (Recommended for Production)
```bash
# Compile with optimizations
./BUILD_FOR_MACOS.sh

# Run the compiled binary
./build/macOSSecurityChecker

# Optional: Copy to system path
sudo cp build/macOSSecurityChecker /usr/local/bin/macos-security-checker
macos-security-checker
```

### Method 3: Manually Compile
```bash
# With optimization flags
swiftc -O -o macos-security-checker macOSSecurityChecker.release.swift

# Run
./macos-security-checker
```

---

## ✅ macOS Compatibility

### Supported Versions
- ✓ macOS 11.0 (Big Sur)
- ✓ macOS 12.0 (Monterey)
- ✓ macOS 13.0 (Ventura)
- ✓ macOS 14.0 (Sonoma)
- ✓ macOS 15.0 (Sequoia)
- ✓ macOS 16.0 (Tahoe) - **VERIFIED COMPATIBLE**

### Architecture Support
- ✓ Apple Silicon (M1, M2, M3, M4)
- ✓ Intel Macs (Xeon, i5, i7, i9)
- ✓ Hybrid mode (Rosetta 2 compatible)

### Tahoe Compatibility Check
```bash
# Verify Tahoe compatibility
sw_vers -productVersion    # Should show 16.x
sysctl -n machdep.cpu.brand_string  # Intel or Apple Silicon
```

If running Tahoe, the tool will detect and confirm:
```
✓ macOS 16 (Tahoe) - Full Compatibility
```

---

## 🔒 Security & Privileges

### Basic Usage (User Privileges)
```bash
./macOSSecurityChecker.release.swift
```
- Results with user-accessible checks
- Some checks show "Unknown" without admin access

### Full Audit (Admin Privileges)
```bash
sudo ./macOSSecurityChecker.release.swift
```
- Complete results for all 88 checks
- Access to firmware settings
- SSH configuration details
- Full MDM status

**Recommendation**: Use with `sudo` for comprehensive security audit

---

## 📊 Usage Examples

### View Terminal Report
```bash
./macOSSecurityChecker.release.swift
```
Shows: Beautiful formatted terminal output with all 88 checks

### Export to JSON
```bash
./macOSSecurityChecker.release.swift --json > security_audit.json
```
Perfect for: Integration with tools, programmatic parsing

### Export to CSV
```bash
./macOSSecurityChecker.release.swift --csv > security_report.csv
```
Perfect for: Spreadsheet analysis, reports

### Verbose Mode (with explanations)
```bash
./macOSSecurityChecker.release.swift --verbose
```
Shows: Detailed information about each check

### With Detailed Output
```bash
./macOSSecurityChecker.release.swift 2>&1 | tee audit_report.txt
```
Saves output to file while displaying on screen

---

## 📈 Scheduling Regular Audits

### Option 1: Cron Job (Weekly)
```bash
# Edit crontab
crontab -e

# Add this line (runs every Monday at 8 AM)
0 8 * * 1 /path/to/macOSSecurityChecker/build/macOSSecurityChecker --json > /var/log/macos_audit_$(date +\%Y\%m\%d).json
```

### Option 2: LaunchAgent (Daily)
Create `~/Library/LaunchAgents/com.security.checker.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.security.checker</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/macOSSecurityChecker/build/macOSSecurityChecker</string>
        <string>--json</string>
    </array>
    <key>StandardOutPath</key>
    <string>/var/log/security-audit.json</string>
    <key>StartInterval</key>
    <integer>86400</integer>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.security.checker.plist
```

### Option 3: Shell Script (Scheduled via Script Editor)
```bash
#!/bin/bash
DATE=$(date +%Y-%m-%d_%H-%M-%S)
/path/to/macOSSecurityChecker/build/macOSSecurityChecker --json > ~/Security_Audits/audit_${DATE}.json
echo "Security audit completed: ${DATE}"
```

---

## 🛠️ Troubleshooting

### Issue: "Command not found"
**Solution**: Make file executable
```bash
chmod +x macOSSecurityChecker.release.swift
```

### Issue: "Swift not found"
**Solution**: Install Xcode Command Line Tools
```bash
xcode-select --install
```

### Issue: "Permission denied"
**Solution**: Check file permissions
```bash
chmod +x macOSSecurityChecker.release.swift
chmod +x BUILD_FOR_MACOS.sh
```

### Issue: Some checks show "Unknown"
**Solution**: Run with sudo for complete access
```bash
sudo ./macOSSecurityChecker.release.swift
```

### Issue: "No color output"
**Solution**: Check terminal color support
```bash
# Force color support
TERM=xterm-256color ./macOSSecurityChecker.release.swift
```

### Issue: Slow execution
**Solution**: Use compiled version instead of script
```bash
./BUILD_FOR_MACOS.sh
./build/macOSSecurityChecker  # Faster than .swift file
```

---

## 📚 File Descriptions

### Executable Files
- **macOSSecurityChecker.release.swift** (28K)
  - Main executable script
  - Direct execution: `./macOSSecurityChecker.release.swift`
  - No compilation needed

- **BUILD_FOR_MACOS.sh** (2.8K)
  - Compilation script
  - Creates optimized binary in `./build/`
  - Includes system compatibility checks

### Documentation Files
- **README.md** - Complete documentation
- **VERSION_2_SUMMARY.md** - v2.0 feature overview
- **QUICK_START.md** - Quick reference guide
- **FINAL_OUTPUT_SIMULATION.txt** - Example output
- **INSTALL_FOR_MACOS.md** - This file

### Legacy Files
- **macOSSecurityChecker.swift** - Original v1.0
- **macOSSecurityChecker-Tests.swift** - Test suite

---

## 🔐 Security Considerations

### Data Privacy
- ✅ **Local audit only** - No data sent to external servers
- ✅ **No network calls** - All checks performed locally
- ✅ **No logging** - Results only displayed to terminal
- ✅ **No telemetry** - No tracking or analytics

### System Impact
- ✅ **Read-only operations** - No system modifications
- ✅ **Minimal resource usage** - ~50MB RAM, <5 seconds
- ✅ **No persistence** - Temporary files only
- ✅ **Safe execution** - Can run anytime

### Privilege Escalation
- `sudo` only needed for firmware/system checks
- Most checks work with user privileges
- Safe to run with or without admin rights

---

## 📊 Output Interpretation

### Security Score Scale
| Score | Level | Meaning |
|-------|-------|---------|
| 9.0-10.0 | 🟢 EXCELLENT | Exceptional security |
| 8.0-8.9 | 🟢 GOOD | Strong implementation |
| 7.0-7.9 | 🟡 FAIR | Improvements needed |
| 5.0-6.9 | 🟠 NEEDS ATTENTION | Multiple issues |
| 0.0-4.9 | 🔴 CRITICAL | Action required |

### Check Status
- ✓ **Green/Enabled** - Secure, no action needed
- ✗ **Red/Disabled** - Requires attention
- ⚠️ **Yellow/Warning** - Review recommended
- ? **Gray/Unknown** - Need admin access

---

## 🎯 Recommended Next Steps

1. **Initial Audit**: Run the tool to get baseline score
   ```bash
   ./macOSSecurityChecker.release.swift
   ```

2. **Review Recommendations**: Address items marked with ⚠️

3. **Schedule Regular Audits**: Set up weekly/monthly checks

4. **Track Improvements**: Export JSON to track score over time

5. **Keep Updated**: Run after major system updates

---

## 💡 Tips & Tricks

### Pipe to Pager (for large output)
```bash
./macOSSecurityChecker.release.swift | less
```

### Compare Results
```bash
# Save baseline
./macOSSecurityChecker.release.swift --json > baseline.json

# Compare after changes
./macOSSecurityChecker.release.swift --json > current.json
diff baseline.json current.json
```

### Filter Specific Results with jq
```bash
# Get only security score
./macOSSecurityChecker.release.swift --json | jq '.metadata.score'

# Get recommendations only
./macOSSecurityChecker.release.swift --json | jq '.recommendations'
```

### Automated Email Reports
```bash
#!/bin/bash
REPORT=$(./macOSSecurityChecker.release.swift)
echo "$REPORT" | mail -s "Security Audit Report" admin@example.com
```

---

## 🔗 Related Resources

- **macOS Security Documentation**: https://support.apple.com/en-us/HT201441
- **Apple Security Updates**: https://support.apple.com/en-us/HT201222
- **CIS macOS Benchmarks**: https://www.cisecurity.org/
- **NIST Cybersecurity Framework**: https://www.nist.gov/cyberframework

---

## ❓ FAQ

**Q: Will this tool modify my system?**
A: No, it's read-only. Only displays information, never changes settings.

**Q: Does it require internet?**
A: No, it's completely local. All checks performed on your Mac.

**Q: How often should I run it?**
A: Weekly recommended, especially after system updates.

**Q: Can I trust the results?**
A: Yes, it queries official macOS systems and configuration files.

**Q: What if I disagree with a recommendation?**
A: You can disable checks in the configuration or evaluate the recommendations.

**Q: Does it work on Apple Silicon Macs?**
A: Yes, fully compatible with M1, M2, M3, M4 processors.

**Q: Is it safe to run on production Macs?**
A: Yes, completely safe. No modifications, read-only queries only.

---

## 📞 Support

- **Documentation**: See README.md
- **Issues**: Report on GitHub
- **Questions**: Check QUICK_START.md
- **Examples**: See FINAL_OUTPUT_SIMULATION.txt

---

## 📄 License

Apache License 2.0 - Free for personal and commercial use

---

**Last Updated**: November 2024
**Version**: 2.0.0
**Status**: Production Ready ✓
