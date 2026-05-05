# macOS Security Audit - Expansion Research
## Additional Security Settings for Comprehensive Audit

This document identifies important macOS security settings NOT currently included in the tool but should be added for comprehensive auditing. Already implemented checks are excluded: FileVault, Gatekeeper, SIP, Secure Boot, XProtect, MRT, TCC, KEXT, MDM, SSV, Kernel CTRR, Boot Arguments Filtering.

---

## 1. FIREWALL CONFIGURATION CHECKS

### 1.1 Firewall State
**What it checks**: Whether the macOS built-in firewall is enabled  
**Command**: `defaults read /Library/Preferences/com.apple.alf globalstate`  
**Sudo Required**: No  
**Output Type**: Integer (0=disabled, 1=enabled, 2=enabled with stealth mode)  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.alf globalstate")
let state = Int(result.stdout.trimmingCharacters(in: .whitespaces)) ?? 0
let firewallEnabled = state > 0
let stealthMode = state == 2
```
**Boolean Output**: `firewallEnabled: Bool`, `stealthMode: Bool`  
**Failure Mode**: If file doesn't exist, firewall is disabled

---

### 1.2 Firewall Stealth Mode
**What it checks**: Whether stealth mode is active (ignores ICMP pings, responds only to established connections)  
**Command**: `defaults read /Library/Preferences/com.apple.alf stealthenabled`  
**Sudo Required**: No  
**Output Type**: Integer (0=disabled, 1=enabled)  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.alf stealthenabled")
let stealthMode = result.stdout.trimmingCharacters(in: .whitespaces) == "1"
```
**Boolean Output**: `stealthMode: Bool`

---

### 1.3 Firewall Rules (Service Exceptions)
**What it checks**: Which apps/services are allowed through firewall  
**Command**: `defaults read /Library/Preferences/com.apple.alf allowdownloadsignedenabled && defaults read /Library/Preferences/com.apple.alf allowsignedenabled`  
**Alternative**: `spctl --list` (for notarization rules)  
**Sudo Required**: No  
**Output Type**: String (list of allowed apps)  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.alf allowsignedenabled")
let allowSignedEnabled = result.stdout.contains("1")

// For detailed rules:
let rulesResult = shell("defaults read /Library/Preferences/com.apple.alf explicitauths")
let rules = parseFirewallRules(rulesResult.stdout)
```
**String Output**: `allowedApps: [String]`, `signedAppsOnly: Bool`

---

## 2. REMOTE ACCESS SETTINGS

### 2.1 SSH (Remote Login) Status
**What it checks**: Whether SSH remote login is enabled  
**Command**: `systemsetup -getremotelogin` OR `defaults read /var/db/launchd.db/com.apple.launchd/overrides.plist | grep -i ssh`  
**Sudo Required**: Yes (for systemsetup), or No for defaults  
**Output Type**: String ("Remote Login: On" or "Remote Login: Off")  
**Parsing**:
```swift
// Method 1 - with sudo
let result = shell("sudo systemsetup -getremotelogin")
let sshEnabled = result.stdout.contains("Remote Login: On")

// Method 2 - no sudo needed
let result = shell("launchctl list | grep sshd")
let sshEnabled = result.exitCode == 0 && !result.stdout.isEmpty
```
**Boolean Output**: `sshEnabled: Bool`

---

### 2.2 SSH Root Login
**What it checks**: Whether root login via SSH is permitted  
**Command**: `sudo grep -i "^PermitRootLogin" /etc/ssh/sshd_config` OR `sudo defaults read /etc/ssh/sshd_config`  
**Sudo Required**: Yes  
**Output Type**: String ("yes", "no", "prohibit-password", "forced-commands-only", "without-password")  
**Parsing**:
```swift
let result = shell("sudo grep -i '^PermitRootLogin' /etc/ssh/sshd_config")
let permitRoot = !result.stdout.contains("no") && !result.stdout.isEmpty
let rootLoginState = result.stdout.split(separator: " ").last.map(String.init) ?? "no"
```
**String Output**: `rootLoginPermitted: String` (enum: "yes", "no", "other")

---

### 2.3 SSH Key-Only Authentication
**What it checks**: Whether password authentication is disabled (only key-based login allowed)  
**Command**: `sudo grep -i "^PasswordAuthentication" /etc/ssh/sshd_config`  
**Sudo Required**: Yes  
**Output Type**: String ("yes", "no")  
**Parsing**:
```swift
let result = shell("sudo grep -i '^PasswordAuthentication' /etc/ssh/sshd_config")
let passwordAuthDisabled = result.stdout.contains("no")
```
**Boolean Output**: `keyOnlyAuth: Bool`

---

### 2.4 Remote Desktop (ARD) Status
**What it checks**: Whether Apple Remote Desktop is enabled  
**Command**: `defaults read /Library/Preferences/com.apple.RemoteDesktop.plist | grep -i enabled`  
**Sudo Required**: No  
**Output Type**: String or Integer  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.RemoteDesktop ARDAdminEnabled")
let ardEnabled = result.stdout.contains("1") || result.stdout.contains("true")
```
**Boolean Output**: `remoteDesktopEnabled: Bool`

---

### 2.5 Screen Sharing Status
**What it checks**: Whether Screen Sharing (VNC) is enabled  
**Command**: `defaults read /Library/Preferences/com.apple.screensharing.agent.plist` OR `launchctl list | grep screensharing`  
**Sudo Required**: No (for defaults), Yes (for launchctl)  
**Output Type**: Integer (0/1) or String  
**Parsing**:
```swift
// Check if service is loaded
let result = shell("launchctl list | grep screensharing")
let screenSharingEnabled = result.exitCode == 0 && !result.stdout.isEmpty

// Alternative - check system preferences
let altResult = shell("defaults read /Library/Preferences/com.apple.screensharing RemoteManagement")
let altEnabled = altResult.exitCode == 0 && !altResult.stdout.isEmpty
```
**Boolean Output**: `screenSharingEnabled: Bool`

---

## 3. USER ACCOUNT SECURITY

### 3.1 Auto-Login Status
**What it checks**: Whether automatic login is enabled (security risk)  
**Command**: `defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser`  
**Sudo Required**: No  
**Output Type**: String (username) or empty  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser")
let autoLoginEnabled = !result.stdout.isEmpty && result.exitCode == 0
let autoLoginUser = result.stdout.trimmingCharacters(in: .whitespaces)
```
**String Output**: `autoLoginEnabled: Bool`, `autoLoginUser: String?`

---

### 3.2 Guest Account Status
**What it checks**: Whether guest account is enabled  
**Command**: `defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled`  
**Sudo Required**: No  
**Output Type**: Integer (0/1)  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled")
let guestAccountEnabled = result.stdout.trimmingCharacters(in: .whitespaces) == "1"
```
**Boolean Output**: `guestAccountEnabled: Bool`

---

### 3.3 Password Requirements
**What it checks**: System password policy configuration  
**Command**: `pwpolicy -getaccountpolicies` (for global policy) OR `pwpolicy -getglobalolicy`  
**Sudo Required**: Yes  
**Output Type**: XML plist structure  
**Parsing**:
```swift
let result = shell("sudo pwpolicy -getaccountpolicies 2>&1")
// Parse XML for:
// - Minimum password length
// - Complexity requirements
// - Password expiration
// - History requirements
let minLength = extractXMLValue(result.stdout, "minimumLength")
let requiresComplex = result.stdout.contains("requiresSymbols")
let expirationDays = extractXMLValue(result.stdout, "expirationTime")
```
**String/Integer Output**: 
```swift
passwordPolicy: [
  "minimumLength": Int,
  "requiresMixedCase": Bool,
  "requiresSymbols": Bool,
  "requiresNumbers": Bool,
  "expirationDays": Int?,
  "historyCount": Int?
]
```

---

### 3.4 Failed Login Attempts Lock
**What it checks**: Account lockout after failed login attempts  
**Command**: `pwpolicy -getaccountpolicies` (parse for maxFailedAttempts)  
**Sudo Required**: Yes  
**Output Type**: XML plist  
**Parsing**:
```swift
let result = shell("sudo pwpolicy -getaccountpolicies 2>&1")
let maxAttempts = extractXMLValue(result.stdout, "maxFailedAttempts")
let lockoutEnabled = !maxAttempts.isEmpty
```
**String/Integer Output**: `lockoutPolicy: [String: Any]`

---

### 3.5 User Account Types and Permissions
**What it checks**: Identify admin vs standard accounts  
**Command**: `dscl . -list /Users UniqueID` and `dscl . -read /Users/<username> RealName AdminIsMember`  
**Sudo Required**: No  
**Output Type**: String list  
**Parsing**:
```swift
let users = shell("dscl . -list /Users").stdout.split(separator: "\n")
for user in users {
  let isAdmin = shell("dseditgroup -o checkmember -m \(user) admin").exitCode == 0
  // Results: [User: String, IsAdmin: Bool]
}
```
**String Output**: `users: [String: Bool]` (username: isAdmin)

---

## 4. NETWORK SECURITY

### 4.1 Wake on Network (Magic Packet)
**What it checks**: Whether system can be woken via network  
**Command**: `pmset -g | grep -i "womp\|Wake on"` OR `sudo pmset -g`  
**Sudo Required**: No (for user info), Yes (for full details)  
**Output Type**: String or Integer  
**Parsing**:
```swift
let result = shell("pmset -g | grep -i 'womp\\|Wake on Network'")
let wakeOnNetworkEnabled = result.stdout.contains("1") || result.stdout.contains("on")
```
**Boolean Output**: `wakeOnNetworkEnabled: Bool`

---

### 4.2 UPnP/NAT-PMP Status
**What it checks**: Universal Plug and Play support (can expose services)  
**Command**: `defaults read /Library/Preferences/com.apple.UPnP.plist UPnPAdvertise` OR check launchd  
**Sudo Required**: No  
**Output Type**: Integer or String  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.nat.plist | grep -i upnp")
let upnpEnabled = !result.stdout.isEmpty && result.exitCode == 0
```
**Boolean Output**: `upnpEnabled: Bool`

---

### 4.3 IPv6 Status
**What it checks**: Whether IPv6 is enabled (may have security implications)  
**Command**: `networksetup -listallnetworkservices` and `networksetup -getinfo <service>`  
**Sudo Required**: No  
**Output Type**: String list  
**Parsing**:
```swift
let services = shell("networksetup -listallnetworkservices").stdout.split(separator: "\n")
var ipv6Status: [String: Bool] = [:]
for service in services {
  let info = shell("networksetup -getinfo \(service)")
  ipv6Status[service] = info.stdout.contains("IPv6") && !info.stdout.contains("Off")
}
```
**String Output**: `networkServices: [String: Bool]` (service: hasIPv6)

---

### 4.4 DNS Leak Prevention (Private Relay)
**What it checks**: Whether iCloud Private Relay is enabled  
**Command**: `defaults read /Library/Preferences/com.apple.networkd.plist | grep -i relay`  
**Sudo Required**: No  
**Output Type**: String or Integer  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.networkd.plist")
let privateRelayEnabled = result.stdout.contains("Relay") && result.stdout.contains("1")
```
**Boolean Output**: `privateRelayEnabled: Bool`

---

## 5. PRIVACY & TRACKING SETTINGS

### 5.1 Safari Privacy Settings
**What it checks**: Privacy mode, tracking prevention, advertising settings  
**Command**: `defaults read ~/Library/Safari/com.apple.Safari.plist` (various keys)  
**Sudo Required**: No  
**Output Type**: Integer (0/1) or String  
**Parsing**:
```swift
// Private browsing
let privResult = shell("defaults read ~/Library/Safari/com.apple.Safari.plist PreferenceVersion")

// Intelligent tracking prevention
let trackingResult = shell("defaults read ~/Library/Safari/com.apple.Safari.plist ContentBlockerEnabled")
let trackingPrevention = trackingResult.stdout.contains("1")

// Do Not Track
let dntResult = shell("defaults read ~/Library/Safari/com.apple.Safari.plist SendDoNotTrackHTTPHeader")
let dntEnabled = dntResult.stdout.contains("1")

// Cookie policy
let cookieResult = shell("defaults read ~/Library/Safari/com.apple.Safari.plist BlockStoragePolicy")
```
**String Output**: 
```swift
safariPrivacy: [
  "trackingPreventionEnabled": Bool,
  "doNotTrackEnabled": Bool,
  "blockThirdPartyCookies": Bool,
  "privatelyBrowseAtLaunch": Bool,
  "autoplayEnabled": Bool
]
```

---

### 5.2 Siri Usage & Recording
**What it checks**: Whether Siri is enabled and if it listens/records  
**Command**: `defaults read ~/Library/Preferences/com.apple.assistant.support 'Siri Data Store Opt-In Status'`  
**Sudo Required**: No  
**Output Type**: Integer (0/1)  
**Parsing**:
```swift
let result = shell("defaults read ~/Library/Preferences/com.apple.assistant.support 'Siri Data Store Opt-In Status'")
let siriEnabled = result.stdout.contains("1") || result.exitCode == 0

let micResult = shell("defaults read ~/Library/Preferences/com.apple.assistant.support 'Siri Voice Feedback Enabled'")
let siriMicrophoneEnabled = micResult.stdout.contains("1")
```
**Boolean Output**: `siriEnabled: Bool`, `siriMicrophoneActive: Bool`

---

### 5.3 Location Services Master Switch
**What it checks**: Whether Location Services are enabled system-wide  
**Command**: `defaults read /var/db/locationd/clients.plist | grep -i enabled`  
**Sudo Required**: Yes (for actual file), No (for user defaults)  
**Output Type**: String or Integer  
**Parsing**:
```swift
let result = shell("sudo launchctl list | grep locationd")
let locationServicesEnabled = result.exitCode == 0 && !result.stdout.isEmpty

// Alternative (user level):
let userResult = shell("defaults read ~/Library/Preferences/com.apple.locationmenu.plist ShowSystemServices")
```
**Boolean Output**: `locationServicesEnabled: Bool`

---

### 5.4 Location Services by App
**What it checks**: Which apps have location permission  
**Command**: `defaults read ~/Library/Preferences/com.apple.locationmenu.plist` OR `tccutil dump | grep kTCCServiceLocation`  
**Sudo Required**: No  
**Output Type**: Plist dictionary  
**Parsing**:
```swift
let result = shell("tccutil dump | grep kTCCServiceLocation")
let allowedApps = result.stdout.split(separator: "\n")
  .map { app in
    String($0).split(separator: ",").first.map(String.init) ?? ""
  }
```
**String Output**: `locationAppPermissions: [String: String]` (app: status)

---

### 5.5 Analytics & Diagnostic Data Sharing
**What it checks**: Whether system sends diagnostics/crash reports to Apple  
**Command**: `defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist`  
**Sudo Required**: No  
**Output Type**: Plist dictionary  
**Parsing**:
```swift
let result = shell("defaults read /Library/Application\\ Support/CrashReporter/DiagnosticMessagesHistory.plist")
let diagnosticsEnabled = !result.stdout.isEmpty && result.exitCode == 0

// Or check preferences:
let prefResult = shell("defaults read ~/Library/Preferences/com.apple.analytics.plist CollectingEnabled")
let analyticsEnabled = prefResult.stdout.contains("1")
```
**Boolean Output**: `diagnosticsEnabled: Bool`, `analyticsEnabled: Bool`

---

## 6. macOS SPECIFIC FEATURES

### 6.1 Developer Mode Status
**What it checks**: Whether Developer Mode is enabled (Sonoma+, relaxes security)  
**Command**: `/usr/sbin/DevToolsSecurity -status` OR `spctl -a -vvv -t open --context context:primary-source`  
**Sudo Required**: Yes  
**Output Type**: String  
**Parsing**:
```swift
let result = shell("sudo /usr/sbin/DevToolsSecurity -status")
let devModeEnabled = result.stdout.contains("Developer mode is currently enabled")
```
**Boolean Output**: `developerModeEnabled: Bool`

---

### 6.2 USB Restricted Mode
**What it checks**: Whether USB is restricted when locked (requires data transfer approvals)  
**Command**: `defaults read /Library/Preferences/.GlobalPreferences com.apple.usb.restrictMode`  
**Sudo Required**: No  
**Output Type**: Integer (0/1)  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/.GlobalPreferences com.apple.usb.restrictMode")
let usbRestrictedMode = result.stdout.contains("1")
```
**Boolean Output**: `usbRestrictedModeEnabled: Bool`

---

### 6.3 USB Accessory Mode
**What it checks**: USB can be used to unlock when computer is locked  
**Command**: `defaults read /Library/Preferences/com.apple.security pim-enabled`  
**Sudo Required**: No  
**Output Type**: Integer (0/1)  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.security pim-enabled")
let usbAccessoryModeEnabled = result.stdout.contains("1")
```
**Boolean Output**: `usbAccessoryModeEnabled: Bool`

---

### 6.4 Recovery Mode Password
**What it checks**: Whether Recovery Mode requires password  
**Command**: `sudo nvram -p | grep "recovery-mode-hash"`  
**Sudo Required**: Yes  
**Output Type**: String or empty  
**Parsing**:
```swift
let result = shell("sudo nvram -p | grep -i 'recovery-mode-hash'")
let recoveryPasswordSet = !result.stdout.isEmpty && result.stdout.contains("recovery-mode-hash")
```
**Boolean Output**: `recoveryModePasswordSet: Bool`

---

### 6.5 NVRAM Firmware Password
**What it checks**: Whether NVRAM/firmware password is set  
**Command**: `sudo systemsetup -getofwpasswordstatus` OR check NVRAM  
**Sudo Required**: Yes  
**Output Type**: String  
**Parsing**:
```swift
let result = shell("sudo systemsetup -getofwpasswordstatus")
let firmwarePasswordSet = result.stdout.contains("Yes") || result.stdout.contains("enabled")
```
**Boolean Output**: `firmwarePasswordSet: Bool`

---

### 6.6 Bluetooth Status
**What it checks**: Whether Bluetooth is enabled  
**Command**: `defaults read /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState`  
**Sudo Required**: No  
**Output Type**: Integer (0/1)  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState")
let bluetoothEnabled = result.stdout.contains("1")
```
**Boolean Output**: `bluetoothEnabled: Bool`

---

### 6.7 AirDrop Status
**What it checks**: Whether AirDrop is enabled  
**Command**: `defaults read ~/Library/Preferences/com.apple.NetworkBrowser.plist` or launchd  
**Sudo Required**: No  
**Output Type**: String or Integer  
**Parsing**:
```swift
let result = shell("defaults read ~/Library/Preferences/com.apple.NetworkBrowser.plist DisableAirDrop")
let airdropDisabled = result.stdout.contains("1")
let airdropEnabled = !airdropDisabled
```
**Boolean Output**: `airdropEnabled: Bool`

---

## 7. iCLOUD & AUTHENTICATION

### 7.1 Two-Factor Authentication (2FA) Status
**What it checks**: Whether 2FA is enabled for iCloud account  
**Command**: `security find-generic-password -w -l 'iCloud' 2>/dev/null` (indirect), or check iCloud preferences  
**Sudo Required**: No  
**Output Type**: String (multi-user)  
**Parsing**:
```swift
// Check iCloud account status
let result = shell("defaults read ~/Library/Preferences/MobileMeAccounts.plist Accounts")
// Look for "twoFactorAuthenticated" key

// More direct:
let icloudResult = shell("system_profiler SPardware | grep -i 'Serial'")
let cloudResult = shell("defaults read ~/Library/Preferences/com.apple.iCloud.plist | grep -i '2fa\\|two'")
let twoFactorEnabled = cloudResult.stdout.contains("1") || cloudResult.stdout.contains("true")
```
**Boolean Output**: `icloudTwoFactorEnabled: Bool`

---

### 7.2 iCloud Keychain Sync
**What it checks**: Whether password/credential sync is enabled  
**Command**: `security default-keychain` or iCloud preferences  
**Sudo Required**: No  
**Output Type**: String  
**Parsing**:
```swift
let result = shell("defaults read ~/Library/Preferences/com.apple.iCloud.plist | grep -i keychain")
let keychainSyncEnabled = result.stdout.contains("1") || result.stdout.contains("true")
```
**Boolean Output**: `keychainSyncEnabled: Bool`

---

### 7.3 Find My Mac Status
**What it checks**: Whether Find My Mac (Find My service) is enabled  
**Command**: `defaults read ~/Library/Preferences/com.apple.iCloud.plist | grep -i 'FindMyEnabled'`  
**Sudo Required**: No  
**Output Type**: Integer (0/1)  
**Parsing**:
```swift
let result = shell("defaults read ~/Library/Preferences/com.apple.iCloud.plist FindMyEnabled")
let findMyEnabled = result.stdout.contains("1")
```
**Boolean Output**: `findMyEnabled: Bool`

---

### 7.4 iCloud Drive Sync
**What it checks**: Whether iCloud Drive syncing is enabled  
**Command**: `defaults read ~/Library/Preferences/com.apple.iCloud.plist | grep -i 'MobileDocuments'`  
**Sudo Required**: No  
**Output Type**: Integer (0/1)  
**Parsing**:
```swift
let result = shell("defaults read ~/Library/Preferences/com.apple.iCloud.plist MobileDocumentsEnabled")
let icloudDriveSyncEnabled = result.stdout.contains("1")
```
**Boolean Output**: `icloudDriveSyncEnabled: Bool`

---

## 8. SYSTEM UPDATES

### 8.1 Automatic Security Updates
**What it checks**: Whether security updates install automatically  
**Command**: `defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist` (various keys)  
**Sudo Required**: No  
**Output Type**: Integer (0/1)  
**Parsing**:
```swift
// Check for automatic updates
let result = shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticUpdateEnabled")
let autoUpdatesEnabled = result.stdout.contains("1")

// Check for automatic critical security updates
let securityResult = shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall")
let autoSecurityUpdates = securityResult.stdout.contains("1")
```
**Boolean Output**: `autoUpdatesEnabled: Bool`, `autoSecurityUpdatesEnabled: Bool`

---

### 8.2 Automatic macOS Updates
**What it checks**: Whether OS major version updates are automatic  
**Command**: `softwareupdate -l` or defaults read  
**Sudo Required**: No (for preferences), Yes (for update list)  
**Output Type**: String or Integer  
**Parsing**:
```swift
// Check for OS update settings
let result = shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall")
let osUpdatesAuto = result.stdout.contains("1")

// Check for staged updates
let stagedResult = shell("sudo softwareupdate -l 2>/dev/null | grep -i 'Recommended'")
let pendingUpdates = !stagedResult.stdout.isEmpty
```
**Boolean Output**: `osAutomaticUpdates: Bool`, `pendingUpdates: Bool`

---

### 8.3 Last Update Check
**What it checks**: When system last checked for updates  
**Command**: `defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist LastSuccessfulDate`  
**Sudo Required**: No  
**Output Type**: String (date/timestamp)  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist LastSuccessfulDate")
let lastUpdateCheck = result.stdout.trimmingCharacters(in: .whitespaces)
let updatesStale = isDateOlderThanDays(lastUpdateCheck, 7)
```
**String Output**: `lastUpdateCheck: String`, `updatesStale: Bool`

---

### 8.4 Pending Security Updates
**What it checks**: Critical security updates waiting to install  
**Command**: `softwareupdate -l` or `softwareupdate --list`  
**Sudo Required**: Yes  
**Output Type**: String (multi-line list)  
**Parsing**:
```swift
let result = shell("sudo softwareupdate -l 2>/dev/null")
let updates = result.stdout.split(separator: "\n")
  .filter { !$0.contains("found") && !$0.contains("Software") }
  .map(String.init)

let securityUpdates = updates.filter { $0.lowercased().contains("security") }
```
**String Output**: `pendingUpdates: [String]`, `criticalUpdateCount: Int`

---

### 8.5 Restart Notifications
**What it checks**: Whether restart notifications are enabled for updates  
**Command**: `defaults read /Library/Preferences/com.apple.commerce AppleConfig`  
**Sudo Required**: No  
**Output Type**: Plist or string  
**Parsing**:
```swift
let result = shell("defaults read /Library/Preferences/com.apple.systempreferences.plist AutomaticallyInstallRestartAction")
// 0 = no action, 1 = install and notify, 2 = install and restart
let restartNotifyEnabled = !result.stdout.isEmpty && result.exitCode == 0
```
**Boolean Output**: `updateRestartNotifications: Bool`

---

## Summary Table: Quick Reference

| Category | Check Name | Command | Sudo | Output Type |
|----------|-----------|---------|------|------------|
| **Firewall** | State | `defaults read /Library/Preferences/com.apple.alf globalstate` | No | Bool |
| | Stealth Mode | `defaults read /Library/Preferences/com.apple.alf stealthenabled` | No | Bool |
| | Rules | `defaults read /Library/Preferences/com.apple.alf allowsignedenabled` | No | [String] |
| **Remote Access** | SSH Enabled | `systemsetup -getremotelogin` | Yes | Bool |
| | SSH Root Login | `sudo grep PermitRootLogin /etc/ssh/sshd_config` | Yes | String |
| | Key-Only Auth | `sudo grep PasswordAuthentication /etc/ssh/sshd_config` | Yes | Bool |
| | Remote Desktop | `defaults read com.apple.RemoteDesktop ARDAdminEnabled` | No | Bool |
| | Screen Sharing | `launchctl list \| grep screensharing` | No | Bool |
| **User Security** | Auto-Login | `defaults read com.apple.loginwindow autoLoginUser` | No | Bool |
| | Guest Account | `defaults read com.apple.loginwindow GuestEnabled` | No | Bool |
| | Password Policy | `pwpolicy -getaccountpolicies` | Yes | [String:Any] |
| | Account Lockout | `pwpolicy -getaccountpolicies` (parse) | Yes | Int |
| | User Types | `dscl` and `dseditgroup` | No | [String:Bool] |
| **Network** | Wake on Network | `pmset -g` | No | Bool |
| | UPnP | `defaults read com.apple.nat.plist` | No | Bool |
| | IPv6 Status | `networksetup -listallnetworkservices` | No | [String:Bool] |
| | Private Relay | `defaults read com.apple.networkd.plist` | No | Bool |
| **Privacy** | Safari Privacy | `defaults read ~/Library/Safari/com.apple.Safari.plist` | No | [String:Bool] |
| | Siri Enabled | `defaults read com.apple.assistant.support` | No | Bool |
| | Location Services | `launchctl list \| grep locationd` | Yes | Bool |
| | Location Apps | `tccutil dump` | No | [String] |
| | Analytics | `defaults read com.apple.analytics.plist` | No | Bool |
| **macOS Features** | Developer Mode | `DevToolsSecurity -status` | Yes | Bool |
| | USB Restricted | `defaults read com.apple.usb.restrictMode` | No | Bool |
| | USB Accessory | `defaults read com.apple.security pim-enabled` | No | Bool |
| | Recovery Password | `nvram -p \| grep recovery-mode-hash` | Yes | Bool |
| | Firmware Password | `systemsetup -getofwpasswordstatus` | Yes | Bool |
| | Bluetooth | `defaults read com.apple.Bluetooth.plist` | No | Bool |
| | AirDrop | `defaults read com.apple.NetworkBrowser.plist` | No | Bool |
| **iCloud** | 2FA Enabled | `defaults read com.apple.iCloud.plist` | No | Bool |
| | Keychain Sync | `defaults read com.apple.iCloud.plist` | No | Bool |
| | Find My Mac | `defaults read com.apple.iCloud.plist` | No | Bool |
| | iCloud Drive | `defaults read com.apple.iCloud.plist` | No | Bool |
| **Updates** | Auto Updates | `defaults read com.apple.SoftwareUpdate.plist` | No | Bool |
| | Auto Security | `defaults read com.apple.SoftwareUpdate.plist` | No | Bool |
| | OS Auto Updates | `defaults read com.apple.SoftwareUpdate.plist` | No | Bool |
| | Last Check | `defaults read com.apple.SoftwareUpdate.plist` | No | String |
| | Pending Updates | `softwareupdate -l` | Yes | [String] |

---

## Implementation Recommendations

### Priority Tiers

**HIGH PRIORITY** (Critical security impact):
1. Firewall configuration (all 3 checks)
2. SSH settings (all 3 checks)
3. Auto-login & guest account
4. Automatic security updates
5. 2FA status

**MEDIUM PRIORITY** (Important but less critical):
1. Screen sharing & Remote Desktop
2. Password policies
3. Location Services
4. USB Restricted Mode
5. Find My Mac

**LOWER PRIORITY** (Privacy/Optional features):
1. Analytics settings
2. Siri settings
3. Safari privacy
4. AirDrop
5. Bluetooth

### Data Structure Suggestion

```swift
struct ExpandedSecurityCheck {
  // Existing fields...
  
  struct FirewallSettings {
    let enabled: Bool
    let stealthMode: Bool
    let allowSignedOnly: Bool
  }
  
  struct RemoteAccessSettings {
    let sshEnabled: Bool
    let sshRootLoginPermitted: Bool
    let keyOnlyAuthRequired: Bool
    let remoteDesktopEnabled: Bool
    let screenSharingEnabled: Bool
  }
  
  struct UserAccountSecurity {
    let autoLoginEnabled: Bool
    let autoLoginUser: String?
    let guestAccountEnabled: Bool
    let passwordPolicyConfigured: Bool
    let failedLoginLockout: Bool
    let adminAccounts: Int
  }
  
  struct NetworkSecurity {
    let wakeOnNetworkEnabled: Bool
    let upnpEnabled: Bool
    let privateRelayEnabled: Bool
  }
  
  struct PrivacySettings {
    let locationServicesEnabled: Bool
    let analyticsEnabled: Bool
    let siriEnabled: Bool
  }
  
  struct SpecialFeatures {
    let developerModeEnabled: Bool
    let usbRestrictedModeEnabled: Bool
    let recoveryModePasswordSet: Bool
    let bluetoothEnabled: Bool
  }
  
  struct iCloudSecurity {
    let twoFactorAuthenticated: Bool
    let keychainSyncEnabled: Bool
    let findMyEnabled: Bool
  }
  
  struct UpdatesStatus {
    let autoUpdatesEnabled: Bool
    let autoSecurityUpdatesEnabled: Bool
    let lastUpdateCheck: String
    let pendingUpdates: Int
    let updatesStale: Bool
  }
  
  let firewall: FirewallSettings
  let remoteAccess: RemoteAccessSettings
  let userAccounts: UserAccountSecurity
  let network: NetworkSecurity
  let privacy: PrivacySettings
  let specialFeatures: SpecialFeatures
  let icloud: iCloudSecurity
  let updates: UpdatesStatus
}
```

---

## Testing Considerations

Each check should be tested for:
1. **Command availability**: Does the command exist on all supported macOS versions?
2. **Permission requirements**: Will it work for standard users? When does sudo become necessary?
3. **Output consistency**: Does output format vary across macOS versions?
4. **Graceful degradation**: What's the fallback when a feature is unavailable?
5. **False positives**: Could a setting be misinterpreted?

---

**Document Version**: 1.0  
**Created**: 2026-05-04  
**Scope**: macOS 11+ comprehensive security audit expansion
