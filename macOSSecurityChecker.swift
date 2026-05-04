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

// Main execution
print("Checking macOS Security Parameters...")
let checker = SecurityChecker()
let results = checker.checkSecurity()

// Check for JSON output flag
let args = CommandLine.arguments
if args.contains("--json") {
    print(generateJSONReport(results))
} else {
    printResults(results)
}
