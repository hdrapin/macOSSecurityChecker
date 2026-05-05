# macOSSecurityChecker v2.0 - Quick Start Guide

## Installation

```bash
cd macOSSecurityChecker
chmod +x macOSSecurityChecker-Enhanced.swift
```

## Basic Commands

### Run Full Security Audit (with beautiful UI)
```bash
./macOSSecurityChecker-Enhanced.swift
```

### Export as JSON (for integration/automation)
```bash
./macOSSecurityChecker-Enhanced.swift --json > security_audit.json
```

### Export as CSV (for spreadsheets)
```bash
./macOSSecurityChecker-Enhanced.swift --csv > security_report.csv
```

### Verbose Mode (with detailed explanations)
```bash
./macOSSecurityChecker-Enhanced.swift --verbose
```

### Get Help
```bash
./macOSSecurityChecker-Enhanced.swift --help
```

### Show Version
```bash
./macOSSecurityChecker-Enhanced.swift --version
```

## For Best Results (with full admin access)

```bash
sudo ./macOSSecurityChecker-Enhanced.swift
```

Some checks require administrative privileges for complete results.

## What You'll See

A beautiful terminal report showing:

```
┌────────────────────────────────────────┐
│  🔒 macOS SECURITY AUDIT REPORT        │
│                                        │
│  Status: 71/88 checks passed (80.7%)   │
│  Score: 8.1/10 - GOOD                  │
└────────────────────────────────────────┘

[████████████████████░░░░░░░░] 80.7%

═══════════════════════════════════════════
🖥️  SYSTEM INFORMATION
═══════════════════════════════════════════
  ✓ Mac Model        MacBook Pro
  ✓ macOS Version    14.2.1
  ...

═══════════════════════════════════════════
📊 SECURITY SUMMARY
═══════════════════════════════════════════
  Passed Checks: 71 (81%)
  At Risk:       3 (3%)
  Warnings:      6 (7%)
  Unknown:       8 (9%)

  Score: 8.1/10 (GOOD)

═══════════════════════════════════════════
⚠️  WARNINGS & RECOMMENDATIONS
═══════════════════════════════════════════
  [1] SSH Remote Access Enabled
      → Disable if not needed
  [2] Bluetooth Discoverable
      → Hide from nearby devices
```

## Understanding Your Score

| Score | Level | Status |
|-------|-------|--------|
| 9-10 | Excellent | 🟢 Exceptional security |
| 8-8.9 | Good | 🟢 Strong implementation |
| 7-7.9 | Fair | 🟡 Some improvements needed |
| 5-6.9 | Needs Attention | 🟠 Multiple issues |
| 0-4.9 | Critical | 🔴 Immediate action required |

## The 88 Security Checks

Organized into 9 categories:

1. **System Information** (5) - Mac details
2. **Firewall & Network** (9) - Network security
3. **Remote Access** (8) - SSH, Screen Sharing
4. **User Accounts** (6) - Login security
5. **Privacy & Tracking** (9) - Privacy settings
6. **iCloud & Auth** (8) - Authentication
7. **Encryption & Boot** (9) - Encryption status
8. **System Updates** (5) - Patch status
9. **Advanced Features** (6) - Kernel security

## Scheduling Regular Audits

### Run Weekly (via cron)
```bash
# Edit crontab
crontab -e

# Add this line for weekly audits on Monday at 8 AM
0 8 * * 1 /path/to/macOSSecurityChecker/macOSSecurityChecker-Enhanced.swift --json > /var/log/security_audit_$(date +\%Y\%m\%d).json
```

### Run Daily (via LaunchAgent)
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
        <string>/path/to/macOSSecurityChecker/macOSSecurityChecker-Enhanced.swift</string>
        <string>--json</string>
    </array>
    <key>StartInterval</key>
    <integer>86400</integer>
</dict>
</plist>
```

Then load it:
```bash
launchctl load ~/Library/LaunchAgents/com.security.checker.plist
```

## Integration Examples

### With jq (JSON parsing)
```bash
# Get only security status
./macOSSecurityChecker-Enhanced.swift --json | jq '.security'

# Get score
./macOSSecurityChecker-Enhanced.swift --json | jq '.metadata.score'

# Get only critical issues
./macOSSecurityChecker-Enhanced.swift --json | jq '.warnings'
```

### Send to Slack
```bash
REPORT=$(./macOSSecurityChecker-Enhanced.swift --json)
SCORE=$(echo $REPORT | jq '.metadata.score')

curl -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"Security Score: $SCORE/10\"}" \
  YOUR_WEBHOOK_URL
```

### Store in Database
```bash
# Export to JSON and pipe to your system
./macOSSecurityChecker-Enhanced.swift --json | \
  mysql -u user -p database -e "INSERT INTO audits (report) VALUES (LOAD_FILE('/path/to/audit.json'))"
```

## Troubleshooting

### Script Won't Execute
```bash
chmod +x macOSSecurityChecker-Enhanced.swift
```

### Some Checks Show "Unknown"
Run with sudo for complete results:
```bash
sudo ./macOSSecurityChecker-Enhanced.swift
```

### No Color Output
The tool auto-detects color support. Force it:
```bash
# Force colors (if supported by terminal)
TERM=xterm-256color ./macOSSecurityChecker-Enhanced.swift
```

### Need More Detailed Information
Use verbose mode:
```bash
./macOSSecurityChecker-Enhanced.swift --verbose
```

## Next Steps

1. **Review Your Score** - Is it 8.0+ (GOOD)?
2. **Address Warnings** - Fix issues marked as critical
3. **Follow Recommendations** - Implement suggested improvements
4. **Schedule Audits** - Run regularly to track progress
5. **Export Reports** - Keep historical records for compliance

## Files Reference

| File | Purpose |
|------|---------|
| `macOSSecurityChecker-Enhanced.swift` | Main enhanced checker |
| `macOSSecurityChecker-UI-Enhanced.swift` | Terminal UI components |
| `macOSSecurityChecker-Tests.swift` | Test suite |
| `VERSION_2_SUMMARY.md` | Complete feature list |
| `QUICK_START.md` | This file |
| `README.md` | Full documentation |

---

**Happy auditing! 🔒**

For more information, see `VERSION_2_SUMMARY.md` or `README.md`
