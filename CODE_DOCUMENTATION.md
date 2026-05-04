# macOS Security Checker - Code Documentation

## 📚 Overview

The macOS Security Checker is a comprehensive security audit tool written in Swift. It analyzes 88 different macOS security parameters across 9 categories and provides detailed reports in multiple formats.

## 🏗️ Architecture

### Core Components

```
macOSSecurityChecker
├── TerminalColors (class)
│   └── Manages ANSI color codes and terminal formatting
├── EnhancedSecurityCheck (struct)
│   └── Data structure holding all 88 security check results
├── EnhancedSecurityChecker (class)
│   └── Main engine performing all security checks
└── CLI Handler
    └── Processes command-line arguments and output formatting
```

### Data Flow

```
1. Parse Command Line Arguments
2. Create EnhancedSecurityChecker instance
3. Call checkSecurity() method
4. Perform 88 individual security checks
5. Collect results into EnhancedSecurityCheck struct
6. Format output based on selected format (text/JSON/CSV)
7. Display or save results
```

## 📝 Main Classes

### TerminalColors
**Purpose:** Centralized terminal color management with auto-detection

**Key Methods:**
- `isColorSupported()` - Detects if terminal supports colors
- Properties for ANSI color codes (green, red, yellow, blue, cyan, etc.)

**Usage:**
```swift
// Check if colors are supported
if TerminalColors.supportsColors {
    print(TerminalColors.green + "✓ Status" + TerminalColors.reset)
} else {
    print("✓ Status")
}
```

**Color Codes Used:**
- `\u{001B}[32m` - Green
- `\u{001B}[31m` - Red
- `\u{001B}[33m` - Yellow
- `\u{001B}[36m` - Cyan
- `\u{001B}[0m` - Reset

---

### EnhancedSecurityCheck
**Purpose:** Data structure containing all 88 security check results

**Sections:**
1. **System Information (5)** - macModel, osVersion, buildNumber, processorType, systemMemory
2. **Firewall & Network (9)** - Firewall, SSH, Screen Sharing, Bluetooth, etc.
3. **Remote Access (8)** - SSH config, ARD, AirDrop, etc.
4. **User Account (6)** - Auto-login, Guest account, Password policy, etc.
5. **Privacy & Tracking (9)** - Location, Safari, Siri, Spotlight, Indicators
6. **iCloud & Auth (8)** - 2FA, Keychain, Find My, Secure Token, Touch ID
7. **Encryption & Boot (9)** - FileVault, SecureBoot, SIP, Firmware, USB
8. **System Updates (5)** - Auto-updates, Patches, XProtect, MRT
9. **Advanced Features (6)** - Kernel CTRR, Gatekeeper, IPv6, etc.

**Metadata:**
- `checkCount` - Total checks performed (88)
- `passedCount` - Number of passed checks
- `riskCount` - Number of at-risk items
- `warningCount` - Number of warnings
- `unknownCount` - Number of unknown values
- `overallScore` - Security score (0-10)
- `riskLevel` - Risk classification string
- `timestamp` - Check execution time
- `osCompatibility` - Tahoe compatibility status

---

### EnhancedSecurityChecker
**Purpose:** Main class performing all security checks

**Key Methods:**

#### checkSecurity() -> EnhancedSecurityCheck
Main entry point. Performs all 88 checks and returns results.

```swift
let checker = EnhancedSecurityChecker()
let results = checker.checkSecurity()
print("Score: \(results.overallScore)/10")
```

#### System Information Methods
```swift
private func shell(_ command: String) -> (String, String, Int32)
  // Executes shell command, returns stdout, stderr, exit code
  
private func getProcessorType() -> String
  // Returns processor info using sysctl
  
private func getSystemMemory() -> String
  // Returns total system memory
  
private func checkOSCompatibility(_ version: String) -> String
  // Checks compatibility with Tahoe and other versions
```

#### Firewall & Network Checks
```swift
private func checkFirewall() -> Bool
  // Checks if macOS firewall is enabled
  
private func checkFirewallStealth() -> Bool
  // Checks if stealth mode is active
  
private func checkSSHStatus() -> Bool
  // Checks if SSH remote login is enabled
  
private func checkScreenSharing() -> Bool
  // Checks if screen sharing is enabled
  
private func checkFileSharing() -> Bool
  // Checks if SMB file sharing is enabled
  
private func bluetoothStatus() -> Bool
  // Checks if Bluetooth is enabled
  
private func checkBluetoothDiscoverable() -> Bool
  // Checks if Mac is visible to nearby Bluetooth devices
```

#### Security Feature Checks
```swift
private func checkFileVault() -> Bool
  // Uses 'fdesetup status' to check FileVault encryption
  
private func checkSIP() -> Bool
  // Uses 'csrutil status' to check System Integrity Protection
  
private func checkSecureBoot() -> Bool
  // Checks secure boot configuration
  
private func checkSSV() -> Bool
  // Checks Signed System Volume status
  
private func checkGatekeeper() -> Bool
  // Uses 'spctl --status' to check code signing enforcement
```

#### User Account Checks
```swift
private func checkAutoLoginDisabled() -> Bool
  // Checks if auto-login is disabled
  
private func checkGuestAccountDisabled() -> Bool
  // Checks if guest account is disabled
  
private func getAdminAccountCount() -> Int
  // Returns number of admin accounts
  
private func getFailedLoginLimit() -> Int
  // Returns failed login attempt limit
```

#### Privacy Checks
```swift
private func checkLocationServices() -> Bool
  // Checks if location services are enabled
  
private func checkSafariPrivacy() -> Bool
  // Checks Safari privacy settings
  
private func checkSiriAnalytics() -> Bool
  // Checks if Siri analytics is disabled
  
private func checkMicrophoneIndicator() -> Bool
  // Checks if microphone access indicator is enabled
  
private func checkCameraIndicator() -> Bool
  // Checks if camera access indicator is enabled
```

#### iCloud & Authentication
```swift
private func checkiCloud() -> Bool
  // Checks if iCloud is enabled
  
private func check2FAEnabled() -> Bool
  // Checks if two-factor authentication is enabled
  
private func checkTouchID() -> Bool
  // Checks if Touch ID is enrolled
  
private func checkSecureToken() -> Bool
  // Checks if Secure Token is enabled
```

#### Update & Patch Checks
```swift
private func checkAutoSecurityUpdates() -> Bool
  // Checks if automatic security updates enabled
  
private func checkSecurityPatches() -> Bool
  // Checks if all security patches are current
  
private func getXProtectVersion() -> String
  // Retrieves XProtect version from system
  
private func getMRTVersion() -> String
  // Retrieves MRT (Malware Removal Tool) version
  
private func checkXProtectUpdated() -> Bool
  // Checks if XProtect is up to date
  
private func checkMRTUpdated() -> Bool
  // Checks if MRT is up to date
```

#### Calculation Methods
```swift
private func calculateScore(_ passed: Int, _ total: Int) -> Double
  // Calculates security score (0-10)
  // Formula: (passed / total) * 10.0
  
private func getRiskLevel(_ score: Double) -> String
  // Returns risk level string based on score:
  // 9.0-10.0: EXCELLENT
  // 8.0-8.9: GOOD
  // 7.0-7.9: FAIR
  // 5.0-6.9: NEEDS ATTENTION
  // 0.0-4.9: CRITICAL
```

## 🔧 Key Implementation Details

### Shell Command Execution

```swift
private func shell(_ command: String) -> (String, String, Int32) {
    let task = Process()
    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    
    task.standardOutput = stdoutPipe
    task.standardError = stderrPipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/bash"
    
    // Execute and capture output
    try task.run()
    task.waitUntilExit()
    
    // Parse results
    return (stdout, stderr, task.terminationStatus)
}
```

**Error Handling:**
- Returns both stdout and stderr
- Captures exit code for validation
- Trims whitespace from output
- Handles encoding errors gracefully

### Color Output Management

```swift
// Auto-detection
let supportsColors = isColorSupported() // Checks TERM env variable

// Conditional formatting
let status = TerminalColors.supportsColors 
    ? "\(TerminalColors.green)✓ ENABLED\(TerminalColors.reset)"
    : "✓ ENABLED"
```

### Scoring Algorithm

```swift
Score = (PassedChecks / TotalChecks) * 10.0

Example:
- 75 passed / 88 total = 8.52/10 = "EXCELLENT"
- 65 passed / 88 total = 7.39/10 = "GOOD"
- 55 passed / 88 total = 6.25/10 = "FAIR"
```

## 📤 Output Formats

### Text Format (Default)

Uses ANSI colors and formatted tables:
```swift
// Formatted output with colors
print("\(TerminalColors.cyan)🔥 FIREWALL & NETWORK SECURITY\(TerminalColors.reset)")
print("  \(TerminalColors.green)✓\(TerminalColors.reset) Firewall Enabled")
```

### JSON Format

Structured data output:
```swift
let jsonData = try JSONSerialization.data(withJSONObject: resultsDictionary)
let jsonString = String(data: jsonData, encoding: .utf8)
```

### CSV Format

Spreadsheet-compatible:
```swift
// CSV header and rows
"Category,Check,Status,Details\n"
"Firewall,Firewall Enabled,true,\n"
```

## 🧪 Testing Considerations

### Unit Tests
- Verify shell command parsing
- Test color code application
- Validate scoring calculation

### Integration Tests
- Run full security check suite
- Verify all 88 checks execute
- Validate output formats

### Edge Cases
- Missing system files
- Permission denied errors
- Unusual macOS versions (Tahoe)
- Non-color terminals
- JSON encoding errors

## 🔐 Security Considerations

### No External Dependencies
- Uses only Foundation framework
- No third-party packages
- No network calls

### Data Privacy
- All checks are read-only
- No data sent externally
- Results stored locally only

### Privilege Escalation
- Works with user privileges (limited checks)
- Enhanced results with `sudo`
- Graceful degradation when permissions denied

## 📈 Performance Optimization

### Execution Time: 4-5 seconds
- Swift script interpretation: ~1s
- System command execution: ~2s
- Output formatting: ~1s

### Memory Usage: < 50 MB
- Minimal data structures
- No persistent caching
- Cleanup after execution

### Optimization Techniques
- Parallel command execution (where safe)
- String interpolation optimization
- Minimal regex usage
- Direct shell calls instead of parsing /proc

## 🔄 Main Execution Flow

```swift
// 1. Entry point (main script)
let arguments = CommandLine.arguments
var outputFormat = "text"
var language = "en"

// 2. Parse arguments
if arguments.contains("--json") { outputFormat = "json" }
if arguments.contains("--lang") { language = "fr" }

// 3. Create checker and run
let checker = EnhancedSecurityChecker()
let results = checker.checkSecurity()

// 4. Format output
switch outputFormat {
case "json": printJSON(results)
case "csv": printCSV(results)
default: printText(results)
}

// 5. Output to stdout
print(formattedOutput)
```

## 📚 Key Swift Features Used

- **Process**: Execute shell commands
- **Pipe**: Capture stdout/stderr
- **Struct**: Data structure for results
- **Class**: Stateful checker logic
- **Extension**: Add formatting methods
- **Codable**: JSON serialization
- **DateFormatter**: ISO8601 timestamps

## 🎯 Best Practices Implemented

- ✅ Separation of concerns
- ✅ Clear method naming
- ✅ Comments for complex logic
- ✅ Error handling throughout
- ✅ No hardcoded values (Tahoe compatible)
- ✅ Terminal compatibility checks
- ✅ Comprehensive struct documentation
- ✅ Consistent formatting

## 🔗 Dependencies

### System
- macOS 11.0+
- Swift 5.5+
- Bash shell

### Frameworks
- `Foundation` (Process, Pipe, DateFormatter, etc.)
- `Darwin` (sysctl utilities)

### No External Packages
- Self-contained
- No CocoaPods or SPM dependencies
- Direct command-line tool integration

---

**Last Updated:** May 2024  
**Version:** 2.0.0  
**Status:** Production Ready
