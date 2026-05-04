#!/usr/bin/swift

import Foundation

// MARK: - Terminal Colors & Formatting

class TerminalColors {
    static let supportsColors = isColorSupported()

    static let reset = "\u{001B}[0m"
    static let bold = "\u{001B}[1m"
    static let dim = "\u{001B}[2m"

    static let green = "\u{001B}[32m"
    static let red = "\u{001B}[31m"
    static let yellow = "\u{001B}[33m"
    static let blue = "\u{001B}[34m"
    static let cyan = "\u{001B}[36m"
    static let magenta = "\u{001B}[35m"
    static let white = "\u{001B}[37m"

    static let bgGreen = "\u{001B}[42m"
    static let bgRed = "\u{001B}[41m"
    static let bgYellow = "\u{001B}[43m"

    static func isColorSupported() -> Bool {
        let term = ProcessInfo.processInfo.environment["TERM"] ?? ""
        return !term.isEmpty && term != "dumb"
    }

    static func colorize(_ text: String, color: String) -> String {
        return supportsColors ? "\(color)\(text)\(reset)" : text
    }
}

// MARK: - Enhanced Security Check Structure

struct EnhancedSecurityCheck {
    // System Information
    let macModel: String
    let osVersion: String
    let buildNumber: String
    let processorType: String
    let systemMemory: String

    // Firewall & Network
    let firewallStatus: Bool
    let firewallStealthMode: Bool
    let sshRemoteLogin: Bool
    let screenSharing: Bool
    let fileSharingEnabled: Bool
    let bluetoothEnabled: Bool
    let bluetoothDiscoverable: Bool
    let wakeOnNetwork: Bool
    let bonjourEnabled: Bool

    // Remote Access
    let sshPasswordAuth: Bool
    let sshRootLoginDisabled: Bool
    let screenSharingPassword: String?
    let remoteAppleEvents: Bool
    let ardEnabled: Bool

    // User Account Security
    let autoLoginDisabled: Bool
    let guestAccountDisabled: Bool
    let fastUserSwitching: Bool
    let adminAccountCount: Int
    let passwordPolicyEnforced: Bool
    let failedLoginLimit: Int

    // Privacy & Tracking
    let locationServicesEnabled: Bool
    let safariPrivacyEnabled: Bool
    let safariDoNotTrackEnabled: Bool
    let safariBlockCookies: Bool
    let siriEnabled: Bool
    let siriAnalyticsDisabled: Bool
    let spotlightPrivacyEnabled: Bool
    let microphoneIndicatorEnabled: Bool
    let cameraIndicatorEnabled: Bool

    // iCloud & Authentication
    let iCloudEnabled: Bool
    let twoFactorAuthEnabled: Bool
    let iCloudKeychainEnabled: Bool
    let findMyMacEnabled: Bool
    let handoffEnabled: Bool
    let iCloudDriveEnabled: Bool
    let secureTokenEnabled: Bool
    let touchIDEnabled: Bool

    // System Security Features
    let secureBoot: Bool
    let systemIntegrityProtection: Bool
    let signedSystemVolume: Bool
    let fileVaultEnabled: Bool
    let recoveryModePasswordSet: Bool
    let firmwarePasswordSet: Bool
    let usbRestrictedModeEnabled: Bool
    let developerModeDisabled: Bool
    let systemPrefsLocked: Bool

    // System Updates
    let autoSecurityUpdatesEnabled: Bool
    let autoSystemUpdatesEnabled: Bool
    let criticalUpdatesAvailable: Bool
    let lastUpdateCheck: String
    let securityPatchesUpToDate: Bool
    let xprotectUpdated: Bool
    let mrtUpdated: Bool

    // Advanced Features
    let kerberosEnabled: Bool
    let ntlmEnabled: Bool
    let ipv6Enabled: Bool
    let allowAllKernelExtensions: Bool
    let kernelCTRR: Bool
    let bootArgumentsFiltering: Bool
    let gatekeeper: Bool
    let xProtectStatus: String
    let mrtVersion: String

    // Metadata
    let checkCount: Int
    let passedCount: Int
    let riskCount: Int
    let warningCount: Int
    let unknownCount: Int
    let overallScore: Double
    let riskLevel: String
    let timestamp: String
}

// MARK: - Enhanced Security Checker

class EnhancedSecurityChecker {

    func checkSecurity() -> EnhancedSecurityCheck {
        let startTime = Date()

        // Basic system info
        let macModel = shell("sysctl -n hw.model").stdout
        let osVersion = shell("sw_vers -productVersion").stdout
        let buildNumber = shell("sw_vers -buildVersion").stdout
        let processorType = getProcessorType()
        let systemMemory = getSystemMemory()

        // Firewall checks
        let firewallStatus = checkFirewall()
        let firewallStealthMode = checkFirewallStealth()

        // Remote access checks
        let sshStatus = checkSSHStatus()
        let screenSharingStatus = checkScreenSharing()
        let fileSharingStatus = checkFileSharing()

        // User account checks
        let autoLoginDisabled = checkAutoLoginDisabled()
        let guestAccountDisabled = checkGuestAccountDisabled()

        // Privacy checks
        let locationServicesEnabled = checkLocationServices()
        let safariPrivacyEnabled = checkSafariPrivacy()
        let twoFactorAuthEnabled = check2FAEnabled()

        // System security
        let sipStatus = checkSIP()
        let fileVaultStatus = checkFileVault()
        let secureBoot = checkSecureBoot()

        // Updates
        let autoSecurityUpdates = checkAutoSecurityUpdates()
        let criticalUpdatesAvailable = checkCriticalUpdates()

        // Calculate scores
        let allChecks = collectAllChecks(
            firewall: firewallStatus,
            ssh: sshStatus,
            autoLogin: autoLoginDisabled,
            sip: sipStatus,
            fileVault: fileVaultStatus,
            twoFA: twoFactorAuthEnabled,
            autoUpdates: autoSecurityUpdates
        )

        let passedCount = allChecks.filter { $0.value }.count
        let riskCount = allChecks.filter { !$0.value && isRiskCheck($0.key) }.count
        let warningCount = allChecks.filter { !$0.value && isWarningCheck($0.key) }.count
        let unknownCount = allChecks.count - passedCount - riskCount - warningCount
        let overallScore = calculateScore(passedCount, allChecks.count)
        let riskLevel = getRiskLevel(overallScore)

        return EnhancedSecurityCheck(
            macModel: macModel,
            osVersion: osVersion,
            buildNumber: buildNumber,
            processorType: processorType,
            systemMemory: systemMemory,
            firewallStatus: firewallStatus,
            firewallStealthMode: firewallStealthMode,
            sshRemoteLogin: sshStatus,
            screenSharing: screenSharingStatus,
            fileSharingEnabled: fileSharingStatus,
            bluetoothEnabled: checkBluetooth(),
            bluetoothDiscoverable: checkBluetoothDiscoverable(),
            wakeOnNetwork: checkWakeOnNetwork(),
            bonjourEnabled: checkBonjour(),
            sshPasswordAuth: checkSSHPasswordAuth(),
            sshRootLoginDisabled: checkSSHRootLogin(),
            screenSharingPassword: nil,
            remoteAppleEvents: checkRemoteAppleEvents(),
            ardEnabled: checkARD(),
            autoLoginDisabled: autoLoginDisabled,
            guestAccountDisabled: guestAccountDisabled,
            fastUserSwitching: checkFastUserSwitching(),
            adminAccountCount: getAdminAccountCount(),
            passwordPolicyEnforced: checkPasswordPolicy(),
            failedLoginLimit: getFailedLoginLimit(),
            locationServicesEnabled: locationServicesEnabled,
            safariPrivacyEnabled: safariPrivacyEnabled,
            safariDoNotTrackEnabled: checkSafariDoNotTrack(),
            safariBlockCookies: checkSafariCookies(),
            siriEnabled: checkSiriEnabled(),
            siriAnalyticsDisabled: checkSiriAnalytics(),
            spotlightPrivacyEnabled: checkSpotlightPrivacy(),
            microphoneIndicatorEnabled: checkMicrophoneIndicator(),
            cameraIndicatorEnabled: checkCameraIndicator(),
            iCloudEnabled: checkiCloud(),
            twoFactorAuthEnabled: twoFactorAuthEnabled,
            iCloudKeychainEnabled: checkiCloudKeychain(),
            findMyMacEnabled: checkFindMyMac(),
            handoffEnabled: checkHandoff(),
            iCloudDriveEnabled: checkiCloudDrive(),
            secureTokenEnabled: checkSecureToken(),
            touchIDEnabled: checkTouchID(),
            secureBoot: secureBoot,
            systemIntegrityProtection: sipStatus,
            signedSystemVolume: checkSSV(),
            fileVaultEnabled: fileVaultStatus,
            recoveryModePasswordSet: checkRecoveryPassword(),
            firmwarePasswordSet: checkFirmwarePassword(),
            usbRestrictedModeEnabled: checkUSBRestricted(),
            developerModeDisabled: checkDeveloperMode(),
            systemPrefsLocked: checkSystemPrefsLocked(),
            autoSecurityUpdatesEnabled: autoSecurityUpdates,
            autoSystemUpdatesEnabled: checkAutoSystemUpdates(),
            criticalUpdatesAvailable: criticalUpdatesAvailable,
            lastUpdateCheck: getLastUpdateCheck(),
            securityPatchesUpToDate: checkSecurityPatches(),
            xprotectUpdated: checkXProtectUpdated(),
            mrtUpdated: checkMRTUpdated(),
            kerberosEnabled: checkKerberos(),
            ntlmEnabled: checkNTLM(),
            ipv6Enabled: checkIPv6(),
            allowAllKernelExtensions: checkAllowAllKEXT(),
            kernelCTRR: checkKernelCTRR(),
            bootArgumentsFiltering: checkBootArguments(),
            gatekeeper: checkGatekeeper(),
            xProtectStatus: getXProtectVersion(),
            mrtVersion: getMRTVersion(),
            checkCount: allChecks.count,
            passedCount: passedCount,
            riskCount: riskCount,
            warningCount: warningCount,
            unknownCount: unknownCount,
            overallScore: overallScore,
            riskLevel: riskLevel,
            timestamp: ISO8601DateFormatter().string(from: startTime)
        )
    }

    // MARK: - Shell Execution

    private func shell(_ command: String) -> (stdout: String, stderr: String, exitCode: Int32) {
        let task = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"

        do {
            try task.run()
            task.waitUntilExit()

            let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

            let stdout = String(data: stdoutData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let stderr = String(data: stderrData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            return (stdout, stderr, task.terminationStatus)
        } catch {
            return ("", error.localizedDescription, -1)
        }
    }

    // MARK: - System Information

    private func getProcessorType() -> String {
        let result = shell("sysctl -n machdep.cpu.brand_string")
        return !result.stdout.isEmpty ? result.stdout : shell("uname -m").stdout
    }

    private func getSystemMemory() -> String {
        let result = shell("sysctl -n hw.memsize")
        if let bytes = Int(result.stdout), bytes > 0 {
            let gb = Double(bytes) / (1024 * 1024 * 1024)
            return String(format: "%.1f GB", gb)
        }
        return "Unknown"
    }

    // MARK: - Firewall Checks

    private func checkFirewall() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null")
        return result.stdout != "0"
    }

    private func checkFirewallStealth() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.alf stealthenabled 2>/dev/null")
        return result.stdout == "1"
    }

    // MARK: - Remote Access Checks

    private func checkSSHStatus() -> Bool {
        let result = shell("sudo systemsetup -getremotelogin 2>/dev/null | grep -i 'On'")
        return !result.stdout.isEmpty
    }

    private func checkSSHPasswordAuth() -> Bool {
        let result = shell("sudo grep -w PasswordAuthentication /etc/ssh/sshd_config 2>/dev/null | grep -v '^#'")
        return result.stdout.contains("yes")
    }

    private func checkSSHRootLogin() -> Bool {
        let result = shell("sudo grep -w PermitRootLogin /etc/ssh/sshd_config 2>/dev/null | grep -v '^#'")
        return !result.stdout.contains("yes")
    }

    private func checkScreenSharing() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.screensharing VNCEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkFileSharing() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.AppleFileServer 2>/dev/null")
        return !result.stdout.isEmpty
    }

    private func checkRemoteAppleEvents() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.security.firewall AllowRemoteAppleEvents 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkARD() -> Bool {
        let result = shell("sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -status 2>/dev/null")
        return result.stdout.contains("Running")
    }

    // MARK: - Bluetooth & Connectivity

    private func checkBluetooth() -> Bool {
        let result = shell("defaults read com.apple.bluetooth.LEAudioEnabled 2>/dev/null")
        return !result.stdout.isEmpty
    }

    private func checkBluetoothDiscoverable() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkWakeOnNetwork() -> Bool {
        let result = shell("pmset -g | grep 'womp' | grep -i '1'")
        return !result.stdout.isEmpty
    }

    private func checkBonjour() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.mDNSResponder.plist 2>/dev/null")
        return !result.stdout.isEmpty
    }

    // MARK: - User Account Security

    private func checkAutoLoginDisabled() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null")
        return result.stdout.isEmpty
    }

    private func checkGuestAccountDisabled() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled 2>/dev/null")
        return result.stdout != "1"
    }

    private func checkFastUserSwitching() -> Bool {
        let result = shell("defaults read /Library/Preferences/.GlobalPreferences MultipleSessionEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func getAdminAccountCount() -> Int {
        let result = shell("dscl . list /Users AdminList 2>/dev/null | wc -l")
        return Int(result.stdout) ?? 0
    }

    private func checkPasswordPolicy() -> Bool {
        let result = shell("sudo pwpolicy getaccountpolicies 2>/dev/null | grep -i 'policy'")
        return !result.stdout.isEmpty
    }

    private func getFailedLoginLimit() -> Int {
        let result = shell("sudo pwpolicy getaccountpolicies 2>/dev/null | grep -i 'failedAttempts'")
        return !result.stdout.isEmpty ? 5 : 0
    }

    // MARK: - Privacy Checks

    private func checkLocationServices() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.locationd.plist LocationServicesEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkSafariPrivacy() -> Bool {
        let result = shell("defaults read com.apple.Safari SendDoNotTrackHTTPHeader 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkSafariDoNotTrack() -> Bool {
        let result = shell("defaults read com.apple.Safari SendDoNotTrackHTTPHeader 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkSafariCookies() -> Bool {
        let result = shell("defaults read com.apple.Safari BlockStoragePolicy 2>/dev/null")
        return result.stdout != "0"
    }

    private func checkSiriEnabled() -> Bool {
        let result = shell("defaults read com.apple.assistant.support 'Siri Data Store Opt-In' 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkSiriAnalytics() -> Bool {
        let result = shell("defaults read /Library/Application\\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit 2>/dev/null")
        return result.stdout != "1"
    }

    private func checkSpotlightPrivacy() -> Bool {
        let result = shell("defaults read com.apple.Spotlight orderedItems 2>/dev/null | grep -c 'Excluded'")
        return !result.stdout.isEmpty
    }

    private func checkMicrophoneIndicator() -> Bool {
        let result = shell("defaults read com.apple.controlcenter MicrophoneModule 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkCameraIndicator() -> Bool {
        let result = shell("defaults read com.apple.controlcenter CameraModule 2>/dev/null")
        return result.stdout == "1"
    }

    // MARK: - iCloud & Authentication

    private func checkiCloud() -> Bool {
        let result = shell("defaults read ~/Library/Preferences/com.apple.iCloud.plist iCloudAccountEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func check2FAEnabled() -> Bool {
        let result = shell("defaults read com.apple.accounts AppleAccountPreferenceActive 2>/dev/null")
        return !result.stdout.isEmpty
    }

    private func checkiCloudKeychain() -> Bool {
        let result = shell("defaults read com.apple.security.keychain KeychainEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkFindMyMac() -> Bool {
        let result = shell("defaults read ~/Library/Preferences/com.apple.iCloud.plist FindMyMacEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkHandoff() -> Bool {
        let result = shell("defaults read ~/Library/Preferences/com.apple.iCloud.plist HandoffEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkiCloudDrive() -> Bool {
        let result = shell("defaults read ~/Library/Preferences/com.apple.iCloud.plist DesktopAndDocumentsContainerEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkSecureToken() -> Bool {
        let result = shell("sudo dscl . list /Users SecureToken 2>/dev/null")
        return !result.stdout.isEmpty
    }

    private func checkTouchID() -> Bool {
        let result = shell("bioutil -r 2>/dev/null | grep -i enrolled")
        return !result.stdout.isEmpty
    }

    // MARK: - System Security

    private func checkSIP() -> Bool {
        let result = shell("csrutil status 2>/dev/null")
        return result.stdout.contains("enabled")
    }

    private func checkSSV() -> Bool {
        let result = shell("csrutil status 2>/dev/null | grep -i 'Signed System Volume'")
        return result.stdout.contains("enabled")
    }

    private func checkSecureBoot() -> Bool {
        let result = shell("nvram -p 2>/dev/null | grep -i 'secure-boot'")
        return !result.stdout.isEmpty
    }

    private func checkFileVault() -> Bool {
        let result = shell("fdesetup status 2>/dev/null")
        return result.stdout.contains("FileVault is On")
    }

    private func checkRecoveryPassword() -> Bool {
        let result = shell("sudo fdesetup list 2>/dev/null | grep -i recovery")
        return !result.stdout.isEmpty
    }

    private func checkFirmwarePassword() -> Bool {
        let result = shell("sudo firmwarepasswd -check 2>/dev/null")
        return result.stdout.contains("Yes")
    }

    private func checkUSBRestricted() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.security USBRestrictedModeEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkDeveloperMode() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.security.coresecurity DeveloperModeStatus 2>/dev/null")
        return result.stdout != "1"
    }

    private func checkSystemPrefsLocked() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.systempreferences PreferencesLocked 2>/dev/null")
        return result.stdout == "1"
    }

    // MARK: - System Updates

    private func checkAutoSecurityUpdates() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkAutoSystemUpdates() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticSecurityUpdatesEnabled 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkCriticalUpdates() -> Bool {
        let result = shell("softwareupdate -l 2>/dev/null | grep -i 'critical\\|security'")
        return !result.stdout.isEmpty
    }

    private func getLastUpdateCheck() -> String {
        let result = shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate LastFullSearchTime 2>/dev/null")
        return !result.stdout.isEmpty ? result.stdout : "Unknown"
    }

    private func checkSecurityPatches() -> Bool {
        let result = shell("softwareupdate -l 2>/dev/null | wc -l")
        return result.stdout == "0" || result.stdout == "1"
    }

    private func checkXProtectUpdated() -> Bool {
        let result = shell("stat -f %Sm /Library/Apple\\ System\\ Extension\\ Exclusions/com.apple.XProtectFramework.xpc 2>/dev/null")
        return !result.stdout.isEmpty
    }

    private func checkMRTUpdated() -> Bool {
        let result = shell("ls -1 /Library/Updates/MRTLauncher.app 2>/dev/null")
        return !result.stdout.isEmpty
    }

    // MARK: - Advanced Features

    private func checkKerberos() -> Bool {
        let result = shell("defaults read /Library/Preferences/com.apple.Kerberos.plist 2>/dev/null")
        return !result.stdout.isEmpty
    }

    private func checkNTLM() -> Bool {
        let result = shell("dscacheutil -q host -a name localhost 2>/dev/null | grep -i 'ntlm'")
        return !result.stdout.isEmpty
    }

    private func checkIPv6() -> Bool {
        let result = shell("ifconfig | grep inet6")
        return !result.stdout.isEmpty
    }

    private func checkAllowAllKEXT() -> Bool {
        let result = shell("nvram -p 2>/dev/null | grep -i 'allow-all-kext'")
        return result.stdout.isEmpty
    }

    private func checkKernelCTRR() -> Bool {
        let result = shell("sysctl -n hw.optional.arm64 2>/dev/null")
        return result.stdout == "1"
    }

    private func checkBootArguments() -> Bool {
        let result = shell("nvram -p 2>/dev/null | grep -i 'boot-args'")
        return result.stdout.isEmpty
    }

    private func checkGatekeeper() -> Bool {
        let result = shell("spctl --status 2>/dev/null")
        return result.stdout.contains("enabled")
    }

    private func getXProtectVersion() -> String {
        let result = shell("defaults read ~/Library/Preferences/com.apple.XProtect.plist CFBundleVersion 2>/dev/null")
        return !result.stdout.isEmpty ? result.stdout : "Unknown"
    }

    private func getMRTVersion() -> String {
        let result = shell("ls -1d /Library/Updates/MRTLauncher.app 2>/dev/null | head -1")
        return !result.stdout.isEmpty ? result.stdout : "Unknown"
    }

    // MARK: - Utility Functions

    private func collectAllChecks(firewall: Bool, ssh: Bool, autoLogin: Bool, sip: Bool, fileVault: Bool, twoFA: Bool, autoUpdates: Bool) -> [String: Bool] {
        return [
            "firewall": firewall,
            "ssh": ssh,
            "autoLogin": autoLogin,
            "sip": sip,
            "fileVault": fileVault,
            "twoFA": twoFA,
            "autoUpdates": autoUpdates
        ]
    }

    private func isRiskCheck(_ check: String) -> Bool {
        return ["ssh", "fileVault", "sip", "firewall"].contains(check)
    }

    private func isWarningCheck(_ check: String) -> Bool {
        return ["autoLogin", "autoUpdates"].contains(check)
    }

    private func calculateScore(_ passed: Int, _ total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(passed) / Double(total) * 10.0
    }

    private func getRiskLevel(_ score: Double) -> String {
        switch score {
        case 8.5...:
            return "EXCELLENT"
        case 7.0..<8.5:
            return "GOOD"
        case 5.0..<7.0:
            return "FAIR"
        case 3.0..<5.0:
            return "POOR"
        default:
            return "CRITICAL"
        }
    }
}

// MARK: - Terminal UI

class TerminalUI {
    static func printHeader(_ check: EnhancedSecurityCheck) {
        let colors = TerminalColors.supportsColors
        let greenCheck = colors ? TerminalColors.colorize("🔒", color: TerminalColors.green) : "[*]"
        let score = String(format: "%.1f", check.overallScore)

        print("\n" + String(repeating: "═", count: 65))
        print("\(greenCheck) macOS SECURITY AUDIT REPORT")
        print(String(repeating: "═", count: 65))
        print("\nSystem: \(check.macModel) | macOS \(check.osVersion) | \(check.processorType)")
        print("Status: \(check.passedCount)/\(check.checkCount) checks passed (\(String(format: "%.1f", Double(check.passedCount)/Double(check.checkCount)*100))%)")
        print("Score: \(score)/10 (\(check.riskLevel))")
        print("Timestamp: \(check.timestamp)")
        print()

        let percentage = Double(check.passedCount) / Double(check.checkCount)
        let barLength = 40
        let filledLength = Int(percentage * Double(barLength))
        let bar = String(repeating: "█", count: filledLength) + String(repeating: "░", count: barLength - filledLength)

        let scoreColor = colors ? colorForScore(check.overallScore) : ""
        print("Progress: \(scoreColor)\(bar)\(TerminalColors.reset) \(String(format: "%.1f", percentage*100))% (\(check.passedCount)/\(check.checkCount) passed)")
    }

    static func printSystemInfo(_ check: EnhancedSecurityCheck) {
        print("\n" + String(repeating: "═", count: 65))
        print("🖥️  SYSTEM INFORMATION")
        print(String(repeating: "═", count: 65))

        let rows = [
            ("Mac Model", check.macModel),
            ("macOS Version", check.osVersion),
            ("Build Number", check.buildNumber),
            ("Processor", check.processorType),
            ("System Memory", check.systemMemory)
        ]

        for (label, value) in rows {
            let status = colorStatus(true, label: label)
            print("  \(status) \(label.padding(toLength: 20, withPad: " ", startingAt: 0)) \(value)")
        }
    }

    static func printSecuritySummary(_ check: EnhancedSecurityCheck) {
        print("\n" + String(repeating: "═", count: 65))
        print("📊 SECURITY SUMMARY")
        print(String(repeating: "═", count: 65))

        let excellent = check.passedCount
        let good = check.warningCount
        let atRisk = check.riskCount
        let unknown = check.unknownCount

        print("\n  Excellent: \(excellent) checks (\(String(format: "%.0f", Double(excellent)/Double(check.checkCount)*100))%)  [✓ SECURE]")
        print("  Good:      \(good) checks (\(String(format: "%.0f", Double(good)/Double(check.checkCount)*100))%)     [⚠️  REVIEW]")
        print("  At Risk:   \(atRisk) checks (\(String(format: "%.0f", Double(atRisk)/Double(check.checkCount)*100))%)    [✗ ALERT]")
        print("  Unknown:   \(unknown) checks (\(String(format: "%.0f", Double(unknown)/Double(check.checkCount)*100))%)    [? N/A]")
        print("\n  Overall Score: \(String(format: "%.1f", check.overallScore))/10 (\(check.riskLevel))")
    }

    static func printFooter() {
        print("\n" + String(repeating: "═", count: 65))
        print("💡 For detailed recommendations, use: --recommendations")
        print("📄 For exports, use: --json, --csv, or --html")
        print(String(repeating: "═", count: 65) + "\n")
    }

    static func colorStatus(_ isSecure: Bool, label: String) -> String {
        let symbol = isSecure ? "✓" : "✗"
        if TerminalColors.supportsColors {
            let color = isSecure ? TerminalColors.green : TerminalColors.red
            return TerminalColors.colorize(symbol, color: color)
        }
        return symbol
    }

    static func colorForScore(_ score: Double) -> String {
        guard TerminalColors.supportsColors else { return "" }
        switch score {
        case 8.5...:
            return TerminalColors.green
        case 7.0..<8.5:
            return TerminalColors.cyan
        case 5.0..<7.0:
            return TerminalColors.yellow
        default:
            return TerminalColors.red
        }
    }
}

// MARK: - Main Execution

print("Starting macOS Security Audit...")
let checker = EnhancedSecurityChecker()
let results = checker.checkSecurity()

TerminalUI.printHeader(results)
TerminalUI.printSystemInfo(results)
TerminalUI.printSecuritySummary(results)
TerminalUI.printFooter()
