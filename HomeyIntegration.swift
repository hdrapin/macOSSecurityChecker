#!/usr/bin/env swift
// Homey Integration Module for macOS Security Checker
// Triggers Homey flows based on security score

import Foundation

// MARK: - Homey Flow Manager
class HomeyFlowManager {
    // Flow IDs created via MCP Homey API
    static let FLOW_IDS = [
        "excellent": "ce6c9cc2-d93d-4e2f-be67-48729272fa0e",    // 🟢 9-10
        "good": "c03e3b80-ce09-4e1c-a332-652230c8e135",          // 🟡 7-9
        "attention": "81c2617f-640b-4b67-bb9b-44d2fd4803c3",     // 🟠 5-7
        "critical": "832a8e34-a856-412f-826b-c15da3f5fcee",      // 🔴 <5
        "daily": "928b250e-ddc3-4ca7-8efb-771133a36122"          // 🔄 Daily check
    ]

    // Homey Pro Instance ID
    static let HOMEY_ID = "664354c5793f18df3856475e"

    // API Configuration
    static let API_BASE = "https://api.homey.app/api"
    static let API_VERSION = "v1"

    enum SecurityLevel {
        case excellent  // 9-10
        case good       // 7-9
        case attention  // 5-7
        case critical   // <5

        var flowKey: String {
            switch self {
            case .excellent: return "excellent"
            case .good: return "good"
            case .attention: return "attention"
            case .critical: return "critical"
            }
        }

        var emoji: String {
            switch self {
            case .excellent: return "🟢"
            case .good: return "🟡"
            case .attention: return "🟠"
            case .critical: return "🔴"
            }
        }

        var description: String {
            switch self {
            case .excellent: return "EXCELLENTE"
            case .good: return "BONNE"
            case .attention: return "ATTENTION"
            case .critical: return "CRITIQUE"
            }
        }
    }

    // Determine security level from score
    static func getSecurityLevel(score: Double) -> SecurityLevel {
        switch score {
        case 9.0...10.0:
            return .excellent
        case 7.0..<9.0:
            return .good
        case 5.0..<7.0:
            return .attention
        default:
            return .critical
        }
    }

    // Trigger a Homey flow by ID
    static func triggerFlow(flowId: String, tag: [String: Any]? = nil) {
        let urlString = "\(API_BASE)/\(API_VERSION)/homeys/\(HOMEY_ID)/flows/\(flowId)/trigger"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid Homey API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add optional tag data
        if let tag = tag {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: ["tag": tag])
            } catch {
                print("❌ Failed to serialize tag data: \(error)")
            }
        }

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Homey API Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    print("✅ Flow triggered successfully")
                } else {
                    print("⚠️ Homey API returned status: \(httpResponse.statusCode)")
                }
            }
        }

        task.resume()
    }

    // Main trigger function based on security score
    static func triggerFlowForScore(_ score: Double) {
        let level = getSecurityLevel(score: score)
        let flowId = FLOW_IDS[level.flowKey] ?? ""

        print("\n🔗 \(level.emoji) Triggering Homey flow: \(level.description)")
        print("   Score: \(String(format: "%.1f", score))/10")
        print("   Flow ID: \(flowId)")

        triggerFlow(flowId: flowId)
    }

    // Trigger daily check flow
    static func triggerDailyCheck() {
        guard let flowId = FLOW_IDS["daily"] else { return }
        print("\n🔄 Triggering daily security check notification...")
        triggerFlow(flowId: flowId)
    }

    // Generate Homey flow summary
    static func printFlowSummary() {
        print("\n" + String(repeating: "═", count: 80))
        print("🏠 HOMEY PRO - FLOWS DE SÉCURITÉ MACOS")
        print(String(repeating: "═", count: 80))
        print("""

        Flows créés et actifs:

        🟢 EXCELLENTE (9-10)    → Notification + Lumière Salon
        🟡 BONNE (7-9)          → Notification simple
        🟠 ATTENTION (5-7)      → Notification + Lumière Petit Salon
        🔴 CRITIQUE (<5)        → Push + Lumière Entrée + Alarme
        🔄 QUOTIDIENNE          → Rapport automatisé

        """)
        print(String(repeating: "═", count: 80) + "\n")
    }
}

// MARK: - Test Function
func testHomeyIntegration() {
    print("\n🧪 Testing Homey Integration...")

    // Test different security levels
    let testScores: [(Double, String)] = [
        (9.5, "Excellent"),
        (8.0, "Good"),
        (6.0, "Attention"),
        (3.5, "Critical")
    ]

    for (score, label) in testScores {
        print("\n📊 Testing \(label) level (score: \(score))...")
        let level = HomeyFlowManager.getSecurityLevel(score: score)
        print("   Level: \(level.description) \(level.emoji)")
        print("   Flow ID: \(HomeyFlowManager.FLOW_IDS[level.flowKey] ?? "N/A")")
    }

    print("\n✅ Homey Integration module ready!")
}

// Test if called directly
if CommandLine.arguments.contains("--test-homey") {
    testHomeyIntegration()
}
