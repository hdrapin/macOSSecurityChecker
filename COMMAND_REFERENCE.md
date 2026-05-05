# Command Reference for macOS Security Audit Expansion
## Verified Commands, Output Examples, and Swift Parsing Implementations

---

## 1. FIREWALL COMMANDS

### 1.1 Get Firewall State
```bash
defaults read /Library/Preferences/com.apple.alf globalstate
```
**Output Examples**:
- `0` - Firewall disabled
- `1` - Firewall enabled
- `2` - Firewall enabled with stealth mode

**Swift Implementation**:
```swift
private func getFirewallState() -> (enabled: Bool, stealthMode: Bool) {
    let result = shell("defaults read /Library/Preferences/com.apple.alf globalstate")
    guard let state = Int(result.stdout.trimmingCharacters(in: .whitespaces)) else {
        return (false, false)
    }
    return (state > 0, state == 2)
}
```

### 1.2 Get Stealth Mode
```bash
defaults read /Library/Preferences/com.apple.alf stealthenabled
```
**Output**: `0` or `1`

### 1.3 Get Firewall Exceptions
```bash
defaults read /Library/Preferences/com.apple.alf allowsignedenabled
```
**Output**: `0` or `1`

---

## 2. REMOTE ACCESS COMMANDS

### 2.1 SSH Status (Method 1 - with sudo)
```bash
sudo systemsetup -getremotelogin
```
**Output Examples**:
```
Remote Login: On
Remote Login: Off
```

**Swift Implementation**:
```swift
private func checkSSHStatus() -> Bool {
    let result = shell("sudo systemsetup -getremotelogin")
    return result.stdout.contains("On") && result.exitCode == 0
}
```

### 2.2 SSH Status (Method 2 - without sudo)
```bash
launchctl list | grep -i sshd
```
**Output Examples**:
```
- - com.openssh.sshd
(empty if not running)
```

### 2.3 SSH Root Login Permission
```bash
sudo grep -i "^PermitRootLogin" /etc/ssh/sshd_config
```
**Output Examples**:
```
PermitRootLogin no
PermitRootLogin yes
PermitRootLogin prohibit-password
```

**Swift Implementation**:
```swift
private func checkSSHRootLogin() -> String {
    let result = shell("sudo grep -i '^PermitRootLogin' /etc/ssh/sshd_config")
    guard !result.stdout.isEmpty else { return "no" }
    let state = result.stdout.split(separator: " ").last.map(String.init) ?? "no"
    return state.lowercased()
}
```

### 2.4 SSH Password Authentication
```bash
sudo grep -i "^PasswordAuthentication" /etc/ssh/sshd_config
```
**Output Examples**:
```
PasswordAuthentication no
PasswordAuthentication yes
```

### 2.5 Remote Desktop Status
```bash
defaults read /Library/Preferences/com.apple.RemoteDesktop ARDAdminEnabled
```
**Output**: `0` or `1` (or error if key doesn't exist)

### 2.6 Screen Sharing Status
```bash
launchctl list | grep -i screensharing
```
**Output**:
```
(returns entry if enabled)
(empty if disabled)
```

---

## 3. USER ACCOUNT SECURITY COMMANDS

### 3.1 Auto-Login Check
```bash
defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser
```
**Output Examples**:
```
username
(error if not set)
```

**Swift Implementation**:
```swift
private func checkAutoLogin() -> (enabled: Bool, username: String?) {
    let result = shell("defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser")
    let enabled = result.exitCode == 0 && !result.stdout.isEmpty
    let username = result.stdout.trimmingCharacters(in: .whitespaces)
    return (enabled, username.isEmpty ? nil : username)
}
```

### 3.2 Guest Account Status
```bash
defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled
```
**Output**: `0` or `1`

### 3.3 Password Policy
```bash
sudo pwpolicy -getaccountpolicies 2>&1
```
**Output Example**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>policyCategoryAccountLockout</key>
    <dict>
        <key>policyIdentifier</key>
        <string>com.apple.policy.accountlockout</string>
        <key>policyParameters</key>
        <dict>
            <key>maxFailedAttempts</key>
            <integer>5</integer>
            <key>lockoutDurationSeconds</key>
            <integer>600</integer>
        </dict>
    </dict>
    <key>policyCategoryPasswordContent</key>
    <dict>
        <key>policyIdentifier</key>
        <string>com.apple.policy.passwordcontent</string>
        <key>policyParameters</key>
        <dict>
            <key>minimumLength</key>
            <integer>12</integer>
            <key>minimumSymbols</key>
            <integer>1</integer>
        </dict>
    </dict>
</dict>
</plist>
```

**Swift Implementation for Parsing**:
```swift
private func getPasswordPolicy() -> [String: Any] {
    let result = shell("sudo pwpolicy -getaccountpolicies 2>&1")
    var policy: [String: Any] = [:]
    
    // Parse XML - look for key patterns
    if result.stdout.contains("minimumLength") {
        if let match = result.stdout.range(of: "<integer>\\d+</integer>", options: .regularExpression) {
            let value = String(result.stdout[match])
            if let numStr = value.split(separator: ">").dropFirst().first?.split(separator: "<").first,
               let minLength = Int(numStr) {
                policy["minimumLength"] = minLength
            }
        }
    }
    
    policy["requiresSymbols"] = result.stdout.contains("minimumSymbols")
    policy["requiresNumbers"] = result.stdout.contains("minimumNumbers")
    policy["requiresUppercase"] = result.stdout.contains("minimumUppercaseCharacters")
    policy["requiresLowercase"] = result.stdout.contains("minimumLowercaseCharacters")
    
    return policy
}
```

### 3.4 User Accounts and Admin Status
```bash
dscl . -list /Users UniqueID
```
**Output Example**:
```
_accessorymanager         245
_accountsd                244
_amavisd                  83
_analyticsd               265
...
username                  501
anotheruser               502
```

```bash
dseditgroup -o checkmember -m username admin
```
**Output**:
- Exit code `0` = user is in admin group
- Exit code `1` = user not in admin group

**Swift Implementation**:
```swift
private func getAdminUsers() -> [String: Bool] {
    let usersResult = shell("dscl . -list /Users UniqueID")
    var userAdminStatus: [String: Bool] = [:]
    
    let users = usersResult.stdout.split(separator: "\n")
    for line in users {
        let components = line.split(separator: " ")
        guard let username = components.first else { continue }
        
        let checkResult = shell("dseditgroup -o checkmember -m \(username) admin")
        userAdminStatus[String(username)] = (checkResult.exitCode == 0)
    }
    
    return userAdminStatus
}
```

---

## 4. NETWORK SECURITY COMMANDS

### 4.1 Wake on Network
```bash
pmset -g | grep -i "womp\|Wake on"
```
**Output Examples**:
```
womp          1
Wake on Network: Yes
```

**Swift Implementation**:
```swift
private func checkWakeOnNetwork() -> Bool {
    let result = shell("pmset -g | grep -i 'womp\\|Wake on'")
    return (result.stdout.contains("1") || result.stdout.contains("Yes")) && result.exitCode == 0
}
```

### 4.2 Network Services List
```bash
networksetup -listallnetworkservices
```
**Output Example**:
```
An asterisk (*) denotes that a network service is disabled.
Ethernet
Wi-Fi
Bluetooth PAN
```

### 4.3 IPv6 Status
```bash
networksetup -getinfo "Wi-Fi"
```
**Output Example**:
```
DHCP Configuration
IP address: 192.168.1.100
Subnet mask: 255.255.255.0
Router: 192.168.1.1
IPv6: Automatic
IPv6 IP address: fe80::...
```

---

## 5. PRIVACY & TRACKING COMMANDS

### 5.1 Safari Privacy Settings
```bash
defaults read ~/Library/Safari/com.apple.Safari.plist
```
**Key identifiers**:
- `ContentBlockerEnabled` - Tracking prevention (0/1)
- `SendDoNotTrackHTTPHeader` - Do Not Track (0/1)
- `BlockStoragePolicy` - Cookie policy (integer)

**Swift Implementation**:
```swift
private func getSafariPrivacy() -> [String: Bool] {
    var settings: [String: Bool] = [:]
    
    let trackingResult = shell("defaults read ~/Library/Safari/com.apple.Safari.plist ContentBlockerEnabled")
    settings["trackingPrevention"] = trackingResult.stdout.contains("1") && trackingResult.exitCode == 0
    
    let dntResult = shell("defaults read ~/Library/Safari/com.apple.Safari.plist SendDoNotTrackHTTPHeader")
    settings["doNotTrack"] = dntResult.stdout.contains("1") && dntResult.exitCode == 0
    
    let cookieResult = shell("defaults read ~/Library/Safari/com.apple.Safari.plist BlockStoragePolicy")
    settings["blockThirdPartyCookies"] = !cookieResult.stdout.isEmpty && cookieResult.exitCode == 0
    
    return settings
}
```

### 5.2 Siri Status
```bash
defaults read ~/Library/Preferences/com.apple.assistant.support 'Siri Data Store Opt-In Status'
```
**Output**: `0` (disabled) or `1` (enabled)

### 5.3 Location Services Master
```bash
launchctl list | grep locationd
```
**Output**:
```
(returns entry if running)
(empty if not running)
```

### 5.4 Location Services by App
```bash
tccutil dump | grep kTCCServiceLocation
```
**Output Example**:
```
kTCCServiceLocation,/Applications/Maps.app,Allowed
kTCCServiceLocation,/Applications/Weather.app,Allowed
kTCCServiceLocation,/usr/libexec/mapsd,Allowed
```

**Swift Implementation**:
```swift
private func getLocationApps() -> [String: String] {
    let result = shell("tccutil dump | grep kTCCServiceLocation")
    var apps: [String: String] = [:]
    
    let lines = result.stdout.split(separator: "\n")
    for line in lines {
        let parts = line.split(separator: ",")
        if parts.count >= 3 {
            let app = String(parts[1])
            let status = String(parts[2]).trimmingCharacters(in: .whitespaces)
            apps[app] = status
        }
    }
    
    return apps
}
```

### 5.5 Diagnostics & Analytics
```bash
defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist
```
**Output Example**:
```
{
    AutoSubmit = 1;
    ThirdPartyDataCollectionEnabled = 1;
}
```

---

## 6. macOS SPECIFIC FEATURES

### 6.1 Developer Mode
```bash
sudo /usr/sbin/DevToolsSecurity -status
```
**Output Examples**:
```
Developer mode is currently enabled.
Developer mode is currently disabled.
```

**Swift Implementation**:
```swift
private func checkDeveloperMode() -> Bool {
    let result = shell("sudo /usr/sbin/DevToolsSecurity -status")
    return result.stdout.contains("enabled") && result.exitCode == 0
}
```

### 6.2 USB Restricted Mode
```bash
defaults read /Library/Preferences/.GlobalPreferences com.apple.usb.restrictMode
```
**Output**: `0` or `1`

### 6.3 Recovery Mode Password
```bash
sudo nvram -p | grep -i "recovery-mode-hash"
```
**Output Examples**:
```
recovery-mode-hash   %3a%42%C2%...
(empty if not set)
```

### 6.4 Firmware Password
```bash
sudo systemsetup -getofwpasswordstatus
```
**Output Examples**:
```
Firmware Password: Yes
Firmware Password: No
```

### 6.5 Bluetooth Status
```bash
defaults read /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState
```
**Output**: `0` (off) or `1` (on)

### 6.6 AirDrop Status
```bash
defaults read ~/Library/Preferences/com.apple.NetworkBrowser.plist DisableAirDrop
```
**Output**: `0` (enabled) or `1` (disabled)

---

## 7. iCLOUD & AUTHENTICATION

### 7.1 iCloud 2FA
```bash
defaults read ~/Library/Preferences/com.apple.iCloud.plist | grep -i "TwoFactor"
```
**Output**: Contains "1" or "true" if enabled

### 7.2 iCloud Keychain
```bash
defaults read ~/Library/Preferences/com.apple.iCloud.plist KeychainSyncEnabled
```
**Output**: `0` or `1`

### 7.3 Find My Mac
```bash
defaults read ~/Library/Preferences/com.apple.iCloud.plist FindMyEnabled
```
**Output**: `0` or `1`

### 7.4 iCloud Drive
```bash
defaults read ~/Library/Preferences/com.apple.iCloud.plist MobileDocumentsEnabled
```
**Output**: `0` or `1`

---

## 8. SYSTEM UPDATES

### 8.1 Automatic Updates
```bash
defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticUpdateEnabled
```
**Output**: `0` or `1`

### 8.2 Automatic Security Updates
```bash
defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall
```
**Output**: `0` or `1`

### 8.3 Automatic OS Updates
```bash
defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall
```
**Output**: `0` or `1`

### 8.4 Last Update Check
```bash
defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist LastSuccessfulDate
```
**Output Example**:
```
2024-12-15 14:32:01 +0000
```

### 8.5 Pending Updates
```bash
sudo softwareupdate -l 2>/dev/null
```
**Output Example**:
```
Software Update Tool
Finding available software
Software Update found the following New or Updated software:
* Security Update 2024-012 for macOS Sonoma 14.4.1-1
	Security Update 2024-012 (2.4.1), 124M [recommended] [restart]
* macOS Sonoma 14.5
	macOS Sonoma 14.5, 3.2G [restart]
```

**Swift Implementation**:
```swift
private func getPendingUpdates() -> (count: Int, list: [String]) {
    let result = shell("sudo softwareupdate -l 2>/dev/null")
    let lines = result.stdout.split(separator: "\n")
    
    var updates: [String] = []
    var count = 0
    
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("*") && !trimmed.contains("Software Update") {
            updates.append(String(trimmed.dropFirst()))
            count += 1
        }
    }
    
    return (count, updates)
}
```

---

## Common Parsing Patterns

### Pattern 1: Boolean from Default Keys
```swift
func getBoolDefault(key: String, domain: String, defaultValue: Bool = false) -> Bool {
    let result = shell("defaults read \(domain) \(key)")
    if result.exitCode != 0 { return defaultValue }
    let value = result.stdout.trimmingCharacters(in: .whitespaces)
    return value == "1" || value.lowercased() == "true"
}
```

### Pattern 2: String Containing Search
```swift
func getStringContains(command: String, searchTerm: String, caseSensitive: Bool = false) -> Bool {
    let result = shell(command)
    if result.exitCode != 0 { return false }
    return caseSensitive ? result.stdout.contains(searchTerm) : result.stdout.lowercased().contains(searchTerm.lowercased())
}
```

### Pattern 3: Exit Code Check
```swift
func isEnabled(command: String) -> Bool {
    let result = shell(command)
    return result.exitCode == 0 && !result.stdout.isEmpty
}
```

### Pattern 4: Parse Integer Value
```swift
func getIntValue(command: String, defaultValue: Int = 0) -> Int {
    let result = shell(command)
    if result.exitCode != 0 { return defaultValue }
    return Int(result.stdout.trimmingCharacters(in: .whitespaces)) ?? defaultValue
}
```

---

## Error Handling Considerations

### File Not Found
When defaults key doesn't exist:
```
2024-12-15 10:00:00.000 defaults[1234:567890] 
Domain (com.apple.example.plist) not found.
```

**Swift Handling**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.example.plist someKey")
if result.exitCode != 0 && result.stderr.contains("not found") {
    // Key doesn't exist - return safe default
    return false
}
```

### Permission Denied
When sudo required:
```
sudo: defaults read: command not found
```

**Swift Handling**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.example.plist someKey")
if result.exitCode != 0 && result.stderr.contains("Permission denied") {
    // Need sudo - inform user
    return nil
}
```

### Missing File
When plist file doesn't exist:
```
The file /Library/Preferences/com.apple.example.plist does not exist.
```

---

## macOS Version Compatibility

| Command | Min Version | Notes |
|---------|------------|-------|
| `defaults read` | 10.0 | Universal, but paths may vary |
| `systemsetup` | 10.0 | Requires admin privileges |
| `pwpolicy` | 10.3 | Password policy tool |
| `dscl` | 10.3 | Directory service command |
| `launchctl list` | 10.4 | Service listing |
| `spctl` | 10.5+ | Gatekeeper, notarization |
| `pmset` | 10.0 | Power management |
| `networksetup` | 10.2 | Network configuration |
| `tccutil` | 10.14 | TCC database access (Mojave+) |
| `DevToolsSecurity` | 10.14.4 | Developer Mode (Sonoma+) |
| `softwareupdate` | 10.0 | Software updates |

---

**Document Version**: 1.0  
**Created**: 2026-05-04
