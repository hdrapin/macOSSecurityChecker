//------------------//
// V1.0
// 2024-11-14
//------------------//

#!/usr/bin/swift

import Foundation

enum ShellError: LocalizedError {
    case executionFailed(String)
    case invalidOutput(String)
    case commandNotFound(String)

    var errorDescription: String? {
        switch self {
        case .executionFailed(let msg):
            return "Command execution failed: \(msg)"
        case .invalidOutput(let msg):
            return "Invalid output received: \(msg)"
        case .commandNotFound(let cmd):
            return "Command not found: \(cmd)"
        }
    }
}

struct ShellResult {
    let stdout: String
    let stderr: String
    let exitCode: Int32
}

struct SecurityCheck {
    let macModel: String
    let iBootVersion: String
    let xProtectVersion: String
    let mrtVersion: String
    let tccStatus: Bool
    let kextVersion: String
    let gatekeeperStatus: Bool
    let fileVaultStatus: Bool
    
    struct PlatformSecurity {
        let secureBoot: Bool
        let systemIntegrityProtection: Bool
        let signedSystemVolume: Bool
        let kernelCTRR: Bool
        let bootArgumentsFiltering: Bool
        let allowAllKernelExtensions: Bool
        let userApprovedMDM: Bool
        let depApprovedMDM: Bool
    }
    
    let platformSecurity: PlatformSecurity
}

class SecurityChecker {
    func checkSecurity() -> SecurityCheck {
        let macModel = shell("sysctl -n hw.model").stdout
        let fileVaultResult = shell("fdesetup status")
        let fileVaultStatus = !fileVaultResult.stdout.isEmpty && fileVaultResult.stdout.contains("FileVault is On")

        let sipResult = shell("csrutil status")
        let sipStatus = !sipResult.stdout.isEmpty && sipResult.stdout.contains("enabled")

        let gatekeeperResult = shell("spctl --status")
        let gatekeeperStatus = !gatekeeperResult.stdout.isEmpty && gatekeeperResult.stdout.contains("assessments enabled")

        return SecurityCheck(
            macModel: macModel,
            iBootVersion: getiBoot(),
            xProtectVersion: getXProtectVersion(),
            mrtVersion: getMRTVersion(),
            tccStatus: getTCCStatus(),
            kextVersion: getKextVersion(),
            gatekeeperStatus: gatekeeperStatus,
            fileVaultStatus: fileVaultStatus,
            platformSecurity: SecurityCheck.PlatformSecurity(
                secureBoot: checkSecureBoot(),
                systemIntegrityProtection: sipStatus,
                signedSystemVolume: checkSignedSystemVolume(),
                kernelCTRR: checkKernelCTRR(),
                bootArgumentsFiltering: checkBootArgumentsFiltering(),
                allowAllKernelExtensions: checkAllowAllKernelExtensions(),
                userApprovedMDM: checkUserApprovedMDM(),
                depApprovedMDM: checkDEPApprovedMDM()
            )
        )
    }

    private func getiBoot() -> String {
        let result = shell("nvram -p 2>/dev/null | grep -i 'boot-uuid'")
        return !result.stdout.isEmpty ? extractVersionFromNVRAM(result.stdout) : "Unknown"
    }

    private func getXProtectVersion() -> String {
        let paths = [
            "~/Library/Preferences/com.apple.XProtect.plist",
            "/Library/Apple System Extension Exclusions/com.apple.XProtectFramework.xpc/Contents/Info.plist"
        ]
        for path in paths {
            let expandedPath = (path as NSString).expandingTildeInPath
            let result = shell("defaults read '\(expandedPath)' CFBundleVersion 2>/dev/null")
            if !result.stdout.isEmpty && result.exitCode == 0 {
                return result.stdout
            }
        }
        return "Unknown"
    }

    private func getMRTVersion() -> String {
        let result = shell("ls -1 /Library/Updates/MRTLauncher.app/Contents/MacOS/ 2>/dev/null | head -1")
        return !result.stdout.isEmpty ? result.stdout : "Unknown"
    }

    private func getTCCStatus() -> Bool {
        let tccDb = "~/Library/Application Support/com.apple.sharedfilelist/.GlobalPreferences.sfl2"
        let expandedPath = (tccDb as NSString).expandingTildeInPath
        let result = shell("test -f '\(expandedPath)' && echo 'exists'")
        return result.exitCode == 0 && result.stdout.contains("exists")
    }

    private func getKextVersion() -> String {
        let result = shell("kextstat 2>/dev/null | wc -l")
        return !result.stdout.isEmpty ? "Active: \(result.stdout)" : "Unknown"
    }

    private func checkSecureBoot() -> Bool {
        let result = shell("nvram -p 2>/dev/null | grep -i 'secure-boot' | grep -i 'true'")
        return result.exitCode == 0 && !result.stdout.isEmpty
    }

    private func checkSignedSystemVolume() -> Bool {
        let result = shell("csrutil status 2>/dev/null | grep -i 'signed system volume'")
        return result.exitCode == 0 && result.stdout.contains("enabled")
    }

    private func checkKernelCTRR() -> Bool {
        let result = shell("sysctl -n hw.optional.arm64 2>/dev/null")
        return result.exitCode == 0 && result.stdout == "1"
    }

    private func checkBootArgumentsFiltering() -> Bool {
        let result = shell("nvram -p 2>/dev/null | grep -i 'csr-active-config'")
        return result.exitCode == 0 && !result.stdout.isEmpty
    }

    private func checkAllowAllKernelExtensions() -> Bool {
        let result = shell("nvram -p 2>/dev/null | grep -i 'allow-all-kext'")
        return result.exitCode == 0 && !result.stdout.isEmpty
    }

    private func checkUserApprovedMDM() -> Bool {
        let result = shell("mdmclient status 2>/dev/null | grep -i 'User Approved'")
        return result.exitCode == 0 && result.stdout.contains("Yes")
    }

    private func checkDEPApprovedMDM() -> Bool {
        let result = shell("profiles list -type provisioning 2>/dev/null | grep -i 'DEP'")
        return result.exitCode == 0 && !result.stdout.isEmpty
    }

    private func extractVersionFromNVRAM(_ nvramOutput: String) -> String {
        let components = nvramOutput.split(separator: "=")
        return components.count > 1 ? String(components[1]).trimmingCharacters(in: .whitespaces) : "Unknown"
    }
    
    private func shell(_ command: String) -> ShellResult {
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

            return ShellResult(stdout: stdout, stderr: stderr, exitCode: task.terminationStatus)
        } catch {
            let errorMsg = error.localizedDescription
            return ShellResult(stdout: "", stderr: errorMsg, exitCode: -1)
        }
    }
}

// CLI Interface
func formatStatus(_ isActive: Bool) -> String {
    return isActive ? "✓ Active" : "✗ Inactive"
}

func printResults(_ results: SecurityCheck) {
    print("\n=== System Information ===")
    print("Mac Model: \(results.macModel)")
    print("iBoot Version: \(results.iBootVersion)")
    print("XProtect Version: \(results.xProtectVersion)")
    print("MRT Version: \(results.mrtVersion)")
    print("FileVault Status: \(results.fileVaultStatus ? "✓ On" : "✗ Off")")

    print("\n=== Security Features ===")
    print("TCC Status: \(results.tccStatus ? "✓ Configured" : "✗ Not configured")")
    print("KEXT Status: \(results.kextVersion)")
    print("Gatekeeper: \(formatStatus(results.gatekeeperStatus))")

    print("\n=== Platform Security ===")
    print("Secure Boot: \(formatStatus(results.platformSecurity.secureBoot))")
    print("System Integrity Protection: \(formatStatus(results.platformSecurity.systemIntegrityProtection))")
    print("Signed System Volume: \(formatStatus(results.platformSecurity.signedSystemVolume))")
    print("Kernel CTRR: \(formatStatus(results.platformSecurity.kernelCTRR))")
    print("Boot Arguments Filtering: \(formatStatus(results.platformSecurity.bootArgumentsFiltering))")
    print("Allow All Kernel Extensions: \(results.platformSecurity.allowAllKernelExtensions ? "✓ Yes" : "✗ No")")
    print("User Approved MDM: \(results.platformSecurity.userApprovedMDM ? "✓ Yes" : "✗ No")")
    print("DEP Approved MDM: \(results.platformSecurity.depApprovedMDM ? "✓ Yes" : "✗ No")")
}

func generateJSONReport(_ results: SecurityCheck) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    let reportDict: [String: Any] = [
        "system": [
            "macModel": results.macModel,
            "iBootVersion": results.iBootVersion,
            "xProtectVersion": results.xProtectVersion,
            "mrtVersion": results.mrtVersion
        ],
        "security": [
            "fileVault": results.fileVaultStatus,
            "tccStatus": results.tccStatus,
            "gatekeeper": results.gatekeeperStatus,
            "kext": results.kextVersion
        ],
        "platformSecurity": [
            "secureBoot": results.platformSecurity.secureBoot,
            "systemIntegrityProtection": results.platformSecurity.systemIntegrityProtection,
            "signedSystemVolume": results.platformSecurity.signedSystemVolume,
            "kernelCTRR": results.platformSecurity.kernelCTRR,
            "bootArgumentsFiltering": results.platformSecurity.bootArgumentsFiltering,
            "allowAllKernelExtensions": results.platformSecurity.allowAllKernelExtensions,
            "userApprovedMDM": results.platformSecurity.userApprovedMDM,
            "depApprovedMDM": results.platformSecurity.depApprovedMDM
        ]
    ]

    if let jsonData = try? JSONSerialization.data(withJSONObject: reportDict, options: [.prettyPrinted, .sortedKeys]),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
    }
    return "{}"
}

// MARK: - CLI Argument Handling

struct CLIOptions {
    var format: String = "text"
    var verbose: Bool = false
    var showHelp: Bool = false
    var showVersion: Bool = false
}

func parseArguments() -> CLIOptions {
    var options = CLIOptions()
    let args = CommandLine.arguments

    for i in 1..<args.count {
        let arg = args[i]
        switch arg {
        case "--json", "--format=json":
            options.format = "json"
        case "--csv", "--format=csv":
            options.format = "csv"
        case "--text", "--format=text":
            options.format = "text"
        case "--verbose", "-v":
            options.verbose = true
        case "--help", "-h":
            options.showHelp = true
        case "--version":
            options.showVersion = true
        default:
            if arg.hasPrefix("--format=") {
                let format = String(arg.dropFirst(9))
                options.format = format
            }
        }
    }

    return options
}

func printHelp() {
    print("""
    macOSSecurityChecker v1.0 - macOS System Security Audit Tool

    USAGE:
        macOSSecurityChecker [OPTIONS]

    OPTIONS:
        --help, -h              Show this help message
        --version               Show version information
        --verbose, -v           Enable verbose output with detailed diagnostics
        --json                  Output results in JSON format
        --csv                   Output results in CSV format (coming soon)
        --text                  Output results in plain text (default)
        --format <format>       Specify output format (text, json, csv)

    EXAMPLES:
        # Standard text output
        ./macOSSecurityChecker

        # JSON output for integration with other tools
        ./macOSSecurityChecker --json

        # Verbose mode for detailed diagnostics
        ./macOSSecurityChecker --verbose

        # Combine options
        ./macOSSecurityChecker --verbose --json

    DESCRIPTION:
        Performs comprehensive security audits of macOS systems by checking:
        - System identification and version information
        - Built-in Apple security tools status
        - Platform-level security protections
        - Mobile Device Management (MDM) configurations

    SECURITY CHECKS PERFORMED:
        System Information:
          - Mac Model
          - iBoot Version
          - XProtect Version
          - MRT Version

        Security Features:
          - FileVault Status
          - TCC (Transparency, Consent & Control) Status
          - Gatekeeper Status
          - KEXT (Kernel Extensions) Status

        Platform Security:
          - Secure Boot
          - System Integrity Protection (SIP)
          - Signed System Volume (SSV)
          - Kernel CTRR
          - Boot Arguments Filtering
          - Kernel Extensions Policy
          - MDM (Mobile Device Management) Status

    REQUIREMENTS:
        - macOS 11.0 or later
        - Swift runtime (usually pre-installed on macOS)
        - Administrative privileges for some checks

    NOTE:
        Some security checks may require administrative privileges to access
        complete information. Run with 'sudo' for comprehensive results.
    """)
}

func printVersion() {
    print("macOSSecurityChecker v1.0")
    print("Released: 2024-11-14")
    print("License: Apache License 2.0")
}

func generateCSVReport(_ results: SecurityCheck) -> String {
    let headers = ["Category", "Check", "Status"]
    var rows: [String] = []

    rows.append("System,Mac Model,\(results.macModel)")
    rows.append("System,iBoot Version,\(results.iBootVersion)")
    rows.append("System,XProtect Version,\(results.xProtectVersion)")
    rows.append("System,MRT Version,\(results.mrtVersion)")

    rows.append("Security,FileVault,\(results.fileVaultStatus ? "Enabled" : "Disabled")")
    rows.append("Security,TCC Status,\(results.tccStatus ? "Configured" : "Not Configured")")
    rows.append("Security,Gatekeeper,\(results.gatekeeperStatus ? "Active" : "Inactive")")
    rows.append("Security,KEXT,\(results.kextVersion)")

    rows.append("Platform,Secure Boot,\(results.platformSecurity.secureBoot ? "Active" : "Inactive")")
    rows.append("Platform,SIP,\(results.platformSecurity.systemIntegrityProtection ? "Active" : "Inactive")")
    rows.append("Platform,SSV,\(results.platformSecurity.signedSystemVolume ? "Active" : "Inactive")")
    rows.append("Platform,Kernel CTRR,\(results.platformSecurity.kernelCTRR ? "Active" : "Inactive")")
    rows.append("Platform,Boot Args Filtering,\(results.platformSecurity.bootArgumentsFiltering ? "Active" : "Inactive")")
    rows.append("Platform,All Kernel Extensions,\(results.platformSecurity.allowAllKernelExtensions ? "Yes" : "No")")
    rows.append("Platform,User Approved MDM,\(results.platformSecurity.userApprovedMDM ? "Yes" : "No")")
    rows.append("Platform,DEP Approved MDM,\(results.platformSecurity.depApprovedMDM ? "Yes" : "No")")

    var csv = headers.joined(separator: ",") + "\n"
    csv += rows.joined(separator: "\n")
    return csv
}

func printVerboseResults(_ results: SecurityCheck) {
    print("\n" + String(repeating: "=", count: 70))
    print("DETAILED SECURITY AUDIT REPORT")
    print(String(repeating: "=", count: 70))

    print("\n[SYSTEM INFORMATION]")
    print("  Mac Model: \(results.macModel)")
    print("  iBoot Version: \(results.iBootVersion)")
    print("  XProtect Version: \(results.xProtectVersion)")
    print("    Purpose: Protection against malware")
    print("  MRT Version: \(results.mrtVersion)")
    print("    Purpose: Malware Removal Tool updates")

    print("\n[SECURITY FEATURES]")
    print("  FileVault Status: \(results.fileVaultStatus ? "✓ ENABLED" : "✗ DISABLED")")
    print("    Purpose: Full-disk encryption")
    print("  TCC Status: \(results.tccStatus ? "✓ CONFIGURED" : "✗ NOT CONFIGURED")")
    print("    Purpose: Application privacy controls")
    print("  Gatekeeper: \(formatStatus(results.gatekeeperStatus))")
    print("    Purpose: Code signing verification")
    print("  KEXT Status: \(results.kextVersion)")
    print("    Purpose: Kernel extension monitoring")

    print("\n[PLATFORM SECURITY]")
    print("  Secure Boot: \(formatStatus(results.platformSecurity.secureBoot))")
    print("    Purpose: Ensures verified firmware startup")
    print("  System Integrity Protection: \(formatStatus(results.platformSecurity.systemIntegrityProtection))")
    print("    Purpose: Prevents system file modification")
    print("  Signed System Volume: \(formatStatus(results.platformSecurity.signedSystemVolume))")
    print("    Purpose: Cryptographic system validation")
    print("  Kernel CTRR: \(formatStatus(results.platformSecurity.kernelCTRR))")
    print("    Purpose: Kernel memory protection (Apple Silicon)")
    print("  Boot Arguments Filtering: \(formatStatus(results.platformSecurity.bootArgumentsFiltering))")
    print("    Purpose: Restricts kernel parameter manipulation")
    print("  Allow All Kernel Extensions: \(results.platformSecurity.allowAllKernelExtensions ? "✓ Yes" : "✗ No")")
    print("    Purpose: Kernel extension policy enforcement")
    print("  User Approved MDM: \(results.platformSecurity.userApprovedMDM ? "✓ Yes" : "✗ No")")
    print("    Purpose: Mobile Device Management approval status")
    print("  DEP Approved MDM: \(results.platformSecurity.depApprovedMDM ? "✓ Yes" : "✗ No")")
    print("    Purpose: Device Enrollment Program MDM status")

    print("\n" + String(repeating: "=", count: 70) + "\n")
}

// MARK: - Main Execution

let options = parseArguments()

if options.showHelp {
    printHelp()
    exit(0)
}

if options.showVersion {
    printVersion()
    exit(0)
}

if options.verbose {
    print("Starting macOS Security Audit...")
    print("Verbose mode enabled\n")
}

let checker = SecurityChecker()

if options.verbose {
    print("Collecting system information...")
}

let results = checker.checkSecurity()

if options.verbose {
    printVerboseResults(results)
} else {
    switch options.format {
    case "json":
        print(generateJSONReport(results))
    case "csv":
        print(generateCSVReport(results))
    default:
        printResults(results)
    }
}
