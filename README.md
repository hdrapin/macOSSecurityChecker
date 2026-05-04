# macOS Security Checker

A comprehensive, production-ready Swift CLI tool for auditing macOS system security configurations. Performs detailed security assessments by querying actual system state rather than relying on hardcoded values.

**Version:** 1.0  
**License:** Apache License 2.0  
**Last Updated:** 2024-11-14

## Overview

macOSSecurityChecker is a professional-grade security audit tool designed for system administrators and security professionals. It provides comprehensive security assessments by checking various security features and configurations on macOS systems.

### Key Improvements (v1.0)
- ✅ **Dynamic System Queries**: All checks now query actual system state (no hardcoded values)
- ✅ **Robust Error Handling**: Comprehensive error handling with stderr capture
- ✅ **Multiple Output Formats**: Text, JSON, CSV support
- ✅ **CLI Features**: Help, version info, verbose mode
- ✅ **Comprehensive Tests**: 25+ unit and integration tests
- ✅ **Better Validation**: Improved parsing and validation of command output

## Features

### System Information Checks
- **Mac Model**: System identifier via `sysctl`
- **iBoot Version**: Retrieved from NVRAM
- **XProtect Version**: Parsed from system preferences
- **MRT (Malware Removal Tool)**: Current version tracking
- **macOS Build Number**: Full version information

### Security Features Status
- **XProtect**: Real-time malware protection version
- **MRT Version**: Malware Removal Tool status
- **TCC (Transparency, Consent & Control)**: Application privacy database status
- **KEXT (Kernel Extensions)**: Active kernel extension monitoring
- **Gatekeeper**: Code signing and application verification
- **FileVault**: Full-disk encryption status

### Platform Security Checks
- **Secure Boot**: Firmware security verification
- **System Integrity Protection (SIP)**: System file protection status
- **Signed System Volume (SSV)**: Cryptographic system validation
- **Kernel CTRR**: Kernel memory protection (Apple Silicon)
- **Boot Arguments Filtering**: Kernel parameter restrictions
- **Kernel Extensions Policy**: Permission enforcement
- **MDM Operations**:
  - User-Approved MDM status
  - DEP-Approved MDM enrollment

## Installation

### Basic Setup
```bash
# Clone the repository
git clone https://github.com/hdrapin/macOSSecurityChecker.git
cd macOSSecurityChecker

# Make script executable
chmod +x macOSSecurityChecker.swift

# Run the security checker
./macOSSecurityChecker.swift
```

### Install System-Wide
```bash
# Copy to /usr/local/bin for system-wide access
sudo cp macOSSecurityChecker.swift /usr/local/bin/macos-security-checker
sudo chmod +x /usr/local/bin/macos-security-checker

# Run from anywhere
macos-security-checker --help
```

## Usage

### Basic Usage
```bash
# Default text output
./macOSSecurityChecker.swift

# With verbose diagnostics
./macOSSecurityChecker.swift --verbose

# Get help information
./macOSSecurityChecker.swift --help

# Show version
./macOSSecurityChecker.swift --version
```

### Output Formats

#### Text Output (Default)
```bash
./macOSSecurityChecker.swift
```
Produces human-readable formatted output with status indicators:
- ✓ indicates enabled/active features
- ✗ indicates disabled/inactive features

#### JSON Output (for integration)
```bash
./macOSSecurityChecker.swift --json
```
Outputs structured JSON for programmatic processing:
```json
{
  "system": {
    "macModel": "MacBookPro18,2",
    "iBootVersion": "...",
    "xProtectVersion": "...",
    "mrtVersion": "..."
  },
  "security": {
    "fileVault": true,
    "tccStatus": true,
    "gatekeeper": true,
    "kext": "..."
  },
  "platformSecurity": {
    "secureBoot": true,
    "systemIntegrityProtection": true,
    ...
  }
}
```

#### Verbose Mode
```bash
./macOSSecurityChecker.swift --verbose
```
Displays detailed information with:
- Explanations of each security feature
- Purpose of each check
- Detailed status information
- Diagnostic context

#### CSV Export (for reports)
```bash
./macOSSecurityChecker.swift --csv > security_report.csv
```

### Command-Line Options

| Option | Alias | Description | Example |
|--------|-------|-------------|---------|
| `--help` | `-h` | Display help message | `./macOSSecurityChecker.swift --help` |
| `--version` | | Show version info | `./macOSSecurityChecker.swift --version` |
| `--verbose` | `-v` | Enable detailed output | `./macOSSecurityChecker.swift --verbose` |
| `--json` | | JSON format output | `./macOSSecurityChecker.swift --json` |
| `--csv` | | CSV format output | `./macOSSecurityChecker.swift --csv` |
| `--text` | | Plain text output (default) | `./macOSSecurityChecker.swift --text` |
| `--format <fmt>` | | Specify format | `./macOSSecurityChecker.swift --format json` |

### Common Use Cases

#### Generate Security Report
```bash
# Save text report
./macOSSecurityChecker.swift > security_report.txt

# Save JSON report for processing
./macOSSecurityChecker.swift --json > security_audit.json

# Save CSV for spreadsheet analysis
./macOSSecurityChecker.swift --csv > security_metrics.csv
```

#### Integration with Scripts
```bash
# Parse JSON output for automation
RESULT=$(./macOSSecurityChecker.swift --json)
FILE_VAULT=$(echo "$RESULT" | jq '.security.fileVault')
echo "FileVault Status: $FILE_VAULT"

# Use in monitoring scripts
./macOSSecurityChecker.swift --json | jq '.platformSecurity.systemIntegrityProtection'
```

#### Compliance Auditing
```bash
# Verbose mode for detailed compliance reports
./macOSSecurityChecker.swift --verbose > compliance_audit_$(date +%Y%m%d).txt

# Automated periodic audits
0 2 * * * /path/to/macOSSecurityChecker.swift --json > /var/log/security_audit.json
```

## Testing

The tool includes comprehensive test suites for validation:

### Running Tests
```bash
# Run all tests (unit + integration)
./macOSSecurityChecker-Tests.swift

# Expected output includes:
# - 25+ individual test cases
# - Unit tests for each security check
# - Integration tests for complete audit
# - Edge case and error handling tests
# - Overall pass rate summary
```

### Test Coverage
- **Unit Tests**: Command output parsing, validation, formatting
- **Integration Tests**: Complete system audit execution
- **Edge Cases**: Empty output, error conditions, missing files
- **Data Validation**: Struct initialization, property access

### Test Results
The test suite validates:
- ✓ All security checks return actual system values
- ✓ No empty/missing data in responses
- ✓ Proper boolean handling
- ✓ Output formatting functions
- ✓ Command execution and error handling
- ✓ JSON report generation
- ✓ File system operations

## Requirements

### System Requirements
- **OS**: macOS 11.0 or later
- **CPU**: Intel or Apple Silicon (M1/M2/M3/etc.)
- **Storage**: < 5 MB
- **RAM**: Minimal (< 50 MB)

### Software Requirements
- **Swift**: 5.0 or later (pre-installed on macOS)
- **Bash**: Standard shell environment
- **Privileges**: Standard user for basic checks; Admin for detailed checks

### Supported macOS Versions
- macOS 11 (Big Sur)
- macOS 12 (Monterey)
- macOS 13 (Ventura)
- macOS 14 (Sonoma)
- macOS 15 (Sequoia)

## Security Check Details

### iBoot/Firmware Security
**Source**: NVRAM via `nvram -p`  
**Check**: Verifies firmware boot security configuration  
**Status Indicators**:
- Active = Secure boot enabled
- Inactive = Standard boot mode

### System Integrity Protection (SIP)
**Source**: `csrutil status`  
**Check**: Protects critical system files from modification  
**Status Indicators**:
- ✓ Active = System file modifications blocked
- ✗ Inactive = Full system write access (not recommended)

### FileVault Encryption
**Source**: `fdesetup status`  
**Check**: Full-disk encryption status  
**Status Indicators**:
- ✓ On = Disk encrypted with FileVault
- ✗ Off = No full-disk encryption

### Gatekeeper
**Source**: `spctl --status`  
**Check**: Code signing and app verification  
**Status Indicators**:
- ✓ Active = App signature verification enabled
- ✗ Inactive = Any app can run (security risk)

### TCC (Transparency, Consent & Control)
**Source**: File system check for TCC database  
**Check**: Privacy permissions database presence  
**Status**: Indicates application privacy controls

### XProtect & MRT
**Source**: System preferences and update directories  
**Check**: Apple's built-in malware detection  
**Status**: Version tracking for protection updates

## Best Practices

### Regular Auditing
```bash
# Create a daily audit script
cat > /usr/local/bin/daily_security_audit.sh <<'EOF'
#!/bin/bash
OUTPUT_DIR="/var/log/security_audits"
mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
/path/to/macOSSecurityChecker.swift --json > "$OUTPUT_DIR/audit_$TIMESTAMP.json"
EOF

chmod +x /usr/local/bin/daily_security_audit.sh
```

### Compliance Monitoring
```bash
# Check specific security features
./macOSSecurityChecker.swift --json | jq '.security.fileVault'
./macOSSecurityChecker.swift --json | jq '.platformSecurity.systemIntegrityProtection'
```

### Incident Response
```bash
# Quick security posture check
./macOSSecurityChecker.swift --verbose
```

## Troubleshooting

### Script Won't Execute
```bash
# Verify permissions
chmod +x macOSSecurityChecker.swift

# Run with explicit Swift
swift macOSSecurityChecker.swift

# Run with sudo if needed
sudo ./macOSSecurityChecker.swift
```

### Missing or "Unknown" Values
**Cause**: Some checks require specific privileges or conditions  
**Solution**: Run with `sudo` for complete information
```bash
sudo ./macOSSecurityChecker.swift --verbose
```

### Command Not Found Errors
**Cause**: Bash commands may not be in standard paths  
**Solution**: Check `/bin` and `/usr/bin` directory structure
```bash
which csrutil fdesetup spctl
```

### Permission Denied
**Cause**: Insufficient privileges for certain checks  
**Solution**: Administrative access needed for comprehensive audit
```bash
sudo ./macOSSecurityChecker.swift
```

## Known Limitations

1. **Administrative Privileges**: Some checks require `sudo` for complete results
2. **Hardware Dependencies**: Certain checks (CTRR, Secure Boot) vary by CPU
3. **macOS Version Differences**: Features vary across macOS versions
4. **MDM Status**: Requires proper MDM enrollment configuration

## Implementation Architecture

### Core Components
- **SecurityChecker**: Main audit engine
- **ShellResult**: Structured command output with error handling
- **SecurityCheck**: Data model containing all audit results
- **CLI Interface**: Command-line argument parsing and output formatting

### Error Handling
- Captures both stdout and stderr from system commands
- Returns exit codes for command validation
- Graceful degradation when commands fail
- Clear error messages for troubleshooting

### Output Formats
- **Text**: Human-readable with visual indicators
- **JSON**: Machine-readable structured data
- **CSV**: Spreadsheet-compatible format
- **Verbose**: Detailed explanations and context

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes with clear commit messages
4. Add tests for new functionality
5. Submit a pull request with description

### Development Guidelines
- Maintain 80%+ test coverage
- Follow Swift style conventions
- Include error handling for all system calls
- Document security check purposes
- Test on multiple macOS versions

## Changelog

### v1.0 (2024-11-14)
- ✨ **New**: Dynamic system state queries (no hardcoded values)
- ✨ **New**: Comprehensive error handling with stderr capture
- ✨ **New**: Multiple output formats (Text, JSON, CSV)
- ✨ **New**: CLI features (--help, --verbose, --json, --csv)
- ✨ **New**: 25+ unit and integration tests
- 🔧 **Improved**: Better parsing and validation of command output
- 🐛 **Fixed**: Silent command failures now properly reported
- 📝 **Docs**: Comprehensive README and inline documentation

## Disclaimer

This tool is provided as-is for security audit purposes. While it provides comprehensive security checks, always verify critical security settings through official Apple tools and management solutions. This tool is not a replacement for professional security assessments.

## License

Apache License 2.0 - See LICENSE file for details

## Support & Contact

- **Issues**: Create an issue in the GitHub repository
- **Questions**: Check existing documentation and discussions
- **Security**: Report security concerns responsibly to repository maintainers

---

**Last Updated**: November 2024  
**Maintained By**: Security Team  
**Repository**: https://github.com/hdrapin/macOSSecurityChecker
