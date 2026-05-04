#!/usr/bin/swift

// Cette extension ajoute l'interface de terminal magnifique complète

import Foundation

// MARK: - Extended Terminal UI with All Categories

class ExtendedTerminalUI {

    static func printComprehensiveReport(_ check: EnhancedSecurityCheck) {
        let colors = TerminalColors.supportsColors

        // Header
        printMainHeader(check)

        // System Info
        printSection(title: "🖥️  SYSTEM INFORMATION", checks: [
            ("Mac Model", check.macModel, true),
            ("macOS Version", check.osVersion, true),
            ("Build Number", check.buildNumber, true),
            ("Processor", check.processorType, true),
            ("System Memory", check.systemMemory, true)
        ])

        // Firewall & Network Security
        printSection(title: "🔥 FIREWALL & NETWORK SECURITY", checks: [
            ("Firewall Enabled", "", check.firewallStatus),
            ("Firewall Stealth Mode", "", check.firewallStealthMode),
            ("SSH Remote Login", "", check.sshRemoteLogin),
            ("Screen Sharing", "", check.screenSharing),
            ("File Sharing (SMB)", "", !check.fileSharingEnabled),
            ("Bluetooth Enabled", "", check.bluetoothEnabled),
            ("Bluetooth Discoverable", "", !check.bluetoothDiscoverable),
            ("Wake on Network", "", !check.wakeOnNetwork)
        ])

        // Remote Access Security
        printSection(title: "📱 REMOTE ACCESS CONFIGURATION", checks: [
            ("SSH Enabled", "", check.sshRemoteLogin),
            ("SSH Password Auth", "", !check.sshPasswordAuth),
            ("SSH Root Login Disabled", "", check.sshRootLoginDisabled),
            ("Remote Apple Events", "", check.remoteAppleEvents),
            ("ARD Enabled", "", check.ardEnabled)
        ])

        // User Account Security
        printSection(title: "👤 USER ACCOUNT SECURITY", checks: [
            ("Auto-Login Disabled", "", check.autoLoginDisabled),
            ("Guest Account Disabled", "", check.guestAccountDisabled),
            ("Fast User Switching", "", check.fastUserSwitching),
            ("Password Policy Enforced", "", check.passwordPolicyEnforced),
            ("Admin Accounts Count", "\(check.adminAccountCount)", check.adminAccountCount <= 2)
        ])

        // Privacy & Tracking
        printSection(title: "🔍 PRIVACY & TRACKING PROTECTION", checks: [
            ("Location Services", "", check.locationServicesEnabled),
            ("Safari Privacy Enabled", "", check.safariPrivacyEnabled),
            ("Safari Do Not Track", "", check.safariDoNotTrackEnabled),
            ("Safari Block Cookies", "", check.safariBlockCookies),
            ("Siri Suggestions Enabled", "", check.siriEnabled),
            ("Siri Analytics Disabled", "", check.siriAnalyticsDisabled),
            ("Spotlight Privacy", "", check.spotlightPrivacyEnabled),
            ("Microphone Indicator", "", check.microphoneIndicatorEnabled),
            ("Camera Indicator", "", check.cameraIndicatorEnabled)
        ])

        // iCloud & Authentication
        printSection(title: "☁️  iCLOUD & AUTHENTICATION", checks: [
            ("iCloud Enabled", "", check.iCloudEnabled),
            ("Two-Factor Auth", "", check.twoFactorAuthEnabled),
            ("iCloud Keychain", "", check.iCloudKeychainEnabled),
            ("Find My Mac", "", check.findMyMacEnabled),
            ("Handoff Enabled", "", check.handoffEnabled),
            ("iCloud Drive", "", check.iCloudDriveEnabled),
            ("Secure Token", "", check.secureTokenEnabled),
            ("Touch ID Enabled", "", check.touchIDEnabled)
        ])

        // Firmware & Boot Security
        printSection(title: "🛡️  FIRMWARE & BOOT SECURITY", checks: [
            ("Secure Boot", "", check.secureBoot),
            ("System Integrity Protection", "", check.systemIntegrityProtection),
            ("Signed System Volume", "", check.signedSystemVolume),
            ("FileVault Encryption", "", check.fileVaultEnabled),
            ("Recovery Mode Password", "", check.recoveryModePasswordSet),
            ("Firmware Password", "", check.firmwarePasswordSet),
            ("USB Restricted Mode", "", check.usbRestrictedModeEnabled),
            ("Developer Mode Disabled", "", check.developerModeDisabled),
            ("System Preferences Locked", "", check.systemPrefsLocked)
        ])

        // System Updates
        printSection(title: "🔄 SYSTEM UPDATES & PATCHES", checks: [
            ("Auto Security Updates", "", check.autoSecurityUpdatesEnabled),
            ("Auto System Updates", "", check.autoSystemUpdatesEnabled),
            ("Security Patches Current", "", !check.criticalUpdatesAvailable),
            ("XProtect Updated", "", check.xprotectUpdated),
            ("MRT Updated", "", check.mrtUpdated)
        ])

        // Advanced Security
        printSection(title: "⚙️  ADVANCED SECURITY FEATURES", checks: [
            ("Kernel CTRR", "", check.kernelCTRR),
            ("Boot Arguments Filtering", "", check.bootArgumentsFiltering),
            ("Allow All KEXT Disabled", "", !check.allowAllKernelExtensions),
            ("Gatekeeper Enabled", "", check.gatekeeper),
            ("IPv6 Enabled", "", check.ipv6Enabled),
            ("Kerberos Support", "", check.kerberosEnabled)
        ])

        // Overall Summary
        printSecuritySummary(check)

        // Warnings & Recommendations
        printWarningsAndRecommendations(check)

        // Footer
        printFooter()
    }

    static func printMainHeader(_ check: EnhancedSecurityCheck) {
        let colors = TerminalColors.supportsColors
        let scoreColor = colorForScore(check.overallScore)

        print("\n")
        print("┌" + String(repeating: "─", count: 63) + "┐")
        print("│" + center("🔒 macOS SECURITY AUDIT REPORT 🔒", width: 63) + "│")
        print("│" + center("", width: 63) + "│")
        print("│ System: \(check.macModel) - macOS \(check.osVersion)".padding(toLength: 64, withPad: " ", startingAt: 0) + "│")
        print("│ \(center(check.processorType, width: 61))" + "│")
        print("│" + center("", width: 63) + "│")
        print("│ Status: \(check.passedCount)/\(check.checkCount) checks passed (\(String(format: "%.1f", Double(check.passedCount)/Double(check.checkCount)*100))%)".padding(toLength: 64, withPad: " ", startingAt: 0) + "│")
        print("│ Score: \(scoreColor)\(String(format: "%.1f", check.overallScore))/10 - \(check.riskLevel)\(TerminalColors.reset)".padding(toLength: 64, withPad: " ", startingAt: 0) + "│")
        print("└" + String(repeating: "─", count: 63) + "┘")

        let percentage = Double(check.passedCount) / Double(check.checkCount)
        let barLength = 60
        let filledLength = Int(percentage * Double(barLength))
        let bar = String(repeating: "█", count: filledLength) + String(repeating: "░", count: barLength - filledLength)

        print("\n[\(scoreColor)\(bar)\(TerminalColors.reset)] \(String(format: "%.1f", percentage*100))%\n")
    }

    static func printSection(title: String, checks: [(label: String, value: String, status: Bool)]) {
        print("\n" + String(repeating: "═", count: 65))
        print(title)
        print(String(repeating: "═", count: 65))

        for (label, value, status) in checks {
            let symbol = getStatusSymbol(status)
            let valueStr = value.isEmpty ? (status ? "✓ YES" : "✗ NO") : value
            print("  \(symbol) \(label.padding(toLength: 35, withPad: " ", startingAt: 0)) \(valueStr)")
        }
    }

    static func printSecuritySummary(_ check: EnhancedSecurityCheck) {
        print("\n" + String(repeating: "═", count: 65))
        print("📊 SECURITY SUMMARY")
        print(String(repeating: "═", count: 65))

        let categories = [
            ("Passed Checks", check.passedCount, colorForSeverity("pass")),
            ("At Risk", check.riskCount, colorForSeverity("risk")),
            ("Warnings", check.warningCount, colorForSeverity("warning")),
            ("Unknown/N/A", check.unknownCount, colorForSeverity("unknown"))
        ]

        for (label, count, color) in categories {
            let percentage = Double(count) / Double(check.checkCount) * 100
            let barLength = 20
            let filledLength = Int(percentage / 100 * Double(barLength))
            let bar = String(repeating: "▮", count: filledLength) + String(repeating: "▯", count: barLength - filledLength)

            print("  \(label.padding(toLength: 15, withPad: " ", startingAt: 0)) \(color)\(bar)\(TerminalColors.reset) \(count) (\(String(format: "%.0f", percentage))%)")
        }

        print("\n  Overall Score: \(String(format: "%.1f", check.overallScore))/10")
        print("  Risk Level: \(check.riskLevel)")
        print("  Status: \(getOverallStatus(check.overallScore))")
    }

    static func printWarningsAndRecommendations(_ check: EnhancedSecurityCheck) {
        var warnings: [(String, String)] = []

        if check.sshRemoteLogin {
            warnings.append(("SSH Remote Access Enabled", "Disable if not needed, or restrict to SSH keys only"))
        }
        if check.bluetoothDiscoverable {
            warnings.append(("Bluetooth Discoverable", "Consider hiding your Mac from nearby Bluetooth devices"))
        }
        if !check.systemPrefsLocked {
            warnings.append(("System Preferences Unlocked", "Lock System Preferences to prevent unauthorized changes"))
        }
        if !check.fileVaultEnabled {
            warnings.append(("FileVault Disabled", "Enable full-disk encryption to protect your data"))
        }
        if !check.systemIntegrityProtection {
            warnings.append(("SIP Disabled", "System Integrity Protection should be enabled for security"))
        }
        if !check.autoSecurityUpdatesEnabled {
            warnings.append(("Auto Security Updates Disabled", "Enable automatic security updates"))
        }
        if check.criticalUpdatesAvailable {
            warnings.append(("Critical Updates Available", "Install pending security updates immediately"))
        }

        if !warnings.isEmpty {
            print("\n" + String(repeating: "═", count: 65))
            print("⚠️  SECURITY WARNINGS & RECOMMENDATIONS")
            print(String(repeating: "═", count: 65))

            for (i, (issue, recommendation)) in warnings.enumerated() {
                print("\n  [\(i + 1)] \(TerminalColors.colorize(issue, color: TerminalColors.yellow))")
                print("      → \(recommendation)")
            }
        }
    }

    static func printFooter() {
        print("\n" + String(repeating: "═", count: 65))
        print("📌 NEXT STEPS:")
        print("  • Review warnings above for improvement opportunities")
        print("  • Run daily audits to track security improvements")
        print("  • Keep system updated with latest security patches")
        print("  • Use --verbose for detailed check explanations")
        print(String(repeating: "═", count: 65) + "\n")
    }

    // MARK: - Helper Functions

    static func getStatusSymbol(_ status: Bool) -> String {
        if TerminalColors.supportsColors {
            return status ? TerminalColors.colorize("✓", color: TerminalColors.green) : TerminalColors.colorize("✗", color: TerminalColors.red)
        }
        return status ? "✓" : "✗"
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

    static func colorForSeverity(_ severity: String) -> String {
        guard TerminalColors.supportsColors else { return "" }
        switch severity {
        case "pass":
            return TerminalColors.green
        case "risk":
            return TerminalColors.red
        case "warning":
            return TerminalColors.yellow
        case "unknown":
            return TerminalColors.dim
        default:
            return TerminalColors.white
        }
    }

    static func getOverallStatus(_ score: Double) -> String {
        switch score {
        case 9.0...:
            return "🟢 EXCELLENT - Your system is very secure"
        case 8.0..<9.0:
            return "🟢 GOOD - Your system has good security"
        case 7.0..<8.0:
            return "🟡 FAIR - Some improvements recommended"
        case 5.0..<7.0:
            return "🟠 NEEDS ATTENTION - Several issues to address"
        default:
            return "🔴 CRITICAL - Immediate security improvements needed"
        }
    }

    static func center(_ text: String, width: Int) -> String {
        let padding = max(0, (width - text.count) / 2)
        let left = String(repeating: " ", count: padding)
        let right = String(repeating: " ", count: width - text.count - padding)
        return left + text + right
    }
}

// MARK: - JSON Report Generator

class JSONReportGenerator {
    static func generateJSONReport(_ check: EnhancedSecurityCheck) -> String {
        var dict: [String: Any] = [:]

        dict["metadata"] = [
            "timestamp": check.timestamp,
            "score": check.overallScore,
            "riskLevel": check.riskLevel,
            "checkCount": check.checkCount,
            "passedCount": check.passedCount,
            "riskCount": check.riskCount,
            "warningCount": check.warningCount
        ]

        dict["system"] = [
            "macModel": check.macModel,
            "osVersion": check.osVersion,
            "buildNumber": check.buildNumber,
            "processor": check.processorType,
            "memory": check.systemMemory
        ]

        dict["security"] = [
            "firewall": check.firewallStatus,
            "firewallStealth": check.firewallStealthMode,
            "ssh": check.sshRemoteLogin,
            "screenSharing": check.screenSharing,
            "fileSharing": check.fileSharingEnabled,
            "bluetooth": check.bluetoothEnabled,
            "fileVault": check.fileVaultEnabled,
            "sip": check.systemIntegrityProtection,
            "secureBoot": check.secureBoot
        ]

        dict["authentication"] = [
            "twoFactorAuth": check.twoFactorAuthEnabled,
            "iCloudKeychain": check.iCloudKeychainEnabled,
            "secureToken": check.secureTokenEnabled,
            "touchID": check.touchIDEnabled,
            "autoLogin": !check.autoLoginDisabled,
            "guestAccount": !check.guestAccountDisabled
        ]

        dict["privacy"] = [
            "locationServices": check.locationServicesEnabled,
            "safariPrivacy": check.safariPrivacyEnabled,
            "doNotTrack": check.safariDoNotTrackEnabled,
            "cookieBlocking": check.safariBlockCookies,
            "siriEnabled": check.siriEnabled,
            "spotlightPrivacy": check.spotlightPrivacyEnabled
        ]

        dict["updates"] = [
            "autoSecurityUpdates": check.autoSecurityUpdatesEnabled,
            "autoSystemUpdates": check.autoSystemUpdatesEnabled,
            "securityPatchesUpToDate": !check.criticalUpdatesAvailable,
            "xprotectUpdated": check.xprotectUpdated,
            "mrtUpdated": check.mrtUpdated
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }

        return "{}"
    }
}

// MARK: - CSV Report Generator

class CSVReportGenerator {
    static func generateCSVReport(_ check: EnhancedSecurityCheck) -> String {
        var csv = "Category,Check,Status,Details\n"

        let rows: [(String, String, Bool, String)] = [
            ("System", "Mac Model", true, check.macModel),
            ("System", "OS Version", true, check.osVersion),
            ("Firewall", "Firewall Enabled", check.firewallStatus, ""),
            ("Firewall", "Stealth Mode", check.firewallStealthMode, ""),
            ("Remote Access", "SSH Enabled", check.sshRemoteLogin, ""),
            ("Remote Access", "Screen Sharing", check.screenSharing, ""),
            ("User Security", "Auto-Login Disabled", check.autoLoginDisabled, ""),
            ("User Security", "Guest Account Disabled", check.guestAccountDisabled, ""),
            ("Privacy", "Location Services", check.locationServicesEnabled, ""),
            ("Privacy", "Safari Privacy", check.safariPrivacyEnabled, ""),
            ("iCloud", "Two-Factor Auth", check.twoFactorAuthEnabled, ""),
            ("iCloud", "iCloud Keychain", check.iCloudKeychainEnabled, ""),
            ("Encryption", "FileVault Enabled", check.fileVaultEnabled, ""),
            ("Encryption", "Secure Boot", check.secureBoot, ""),
            ("Encryption", "SIP Enabled", check.systemIntegrityProtection, ""),
            ("Updates", "Auto Security Updates", check.autoSecurityUpdatesEnabled, ""),
            ("Updates", "Security Patches Current", !check.criticalUpdatesAvailable, "")
        ]

        for (category, check_name, status, details) in rows {
            let statusStr = status ? "ENABLED" : "DISABLED"
            csv += "\(category),\(check_name),\(statusStr),\(details)\n"
        }

        return csv
    }
}

// Note: This file should be merged with the main Enhanced file for complete functionality
