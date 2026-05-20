import Foundation

enum ReleasePerformanceArea: String, CaseIterable, Sendable, Equatable {
    case appLaunch = "App launch"
    case tabSwitching = "Tab switching"
    case todayLoad = "Today load"
    case goalDetailLoad = "Goal Detail load"
    case planLoad = "Time load"
    case receiptHistoryQueries = "Receipt and history queries"
    case memoryReviewQueries = "Memory and review queries"
    case pathPortfolioQueries = "Path and portfolio queries"
    case externalSnapshots = "External snapshots"
}

enum ReleasePerformanceEvidenceLevel: String, Sendable, Equatable {
    case automatedSimulator = "Automated simulator evidence"
    case sourceBudget = "Source budget evidence"
    case manualDeviceRequired = "Manual device proof required"
}

enum ReleasePerformanceReadiness: String, Sendable, Equatable {
    case acceptableForInternalTesting = "Acceptable for internal testing"
    case boundedButDeviceProofRequired = "Bounded, device proof required"
    case platformProofRequired = "Platform proof required"
}

struct ReleasePerformanceCheck: Identifiable, Sendable, Equatable {
    let id: String
    let area: ReleasePerformanceArea
    let budget: String
    let evidence: String
    let evidenceLevel: ReleasePerformanceEvidenceLevel
    let readiness: ReleasePerformanceReadiness
    let limitation: String
}

enum ReleasePerformanceResponsivenessReport {
    static let checks: [ReleasePerformanceCheck] = [
        ReleasePerformanceCheck(
            id: "app-launch",
            area: .appLaunch,
            budget: "Launch must compile cleanly, avoid permission prompts during startup, and keep first-run claims conservative.",
            evidence: "R02 simulator build launches the native app target from generated Xcode project wiring; onboarding/calendar access remains Time-owned through the internal Plan compatibility seam and not startup-owned.",
            evidenceLevel: .automatedSimulator,
            readiness: .boundedButDeviceProofRequired,
            limitation: "Cold-start timing and memory pressure still require R03 device/TestFlight proof."
        ),
        ReleasePerformanceCheck(
            id: "tab-switching",
            area: .tabSwitching,
            budget: "The canonical five-tab shell must stay stable without hidden navigation or extra top-level surfaces.",
            evidence: "M12 shell continuity tests cover Today, Goals, Capture, Time, You, and review routes; R02 keeps this as a regression lane.",
            evidenceLevel: .automatedSimulator,
            readiness: .acceptableForInternalTesting,
            limitation: "Touch latency and animation smoothness need manual device review."
        ),
        ReleasePerformanceCheck(
            id: "today-load",
            area: .todayLoad,
            budget: "Today should project the current next step from bounded local state rather than recomputing broad history in view bodies.",
            evidence: "Core-surface scenario tests and Today service regressions cover the Golden Launch Loop, denied-calendar fallback, disrupted-day recovery, and next-step posture.",
            evidenceLevel: .automatedSimulator,
            readiness: .acceptableForInternalTesting,
            limitation: "Large-data scrolling and VoiceOver navigation remain manual/device checks."
        ),
        ReleasePerformanceCheck(
            id: "goal-detail-load",
            area: .goalDetailLoad,
            budget: "Goal Detail must keep Mission Control, Proof, Archive, and Path Builder projections bounded.",
            evidence: "Goal Detail strategic presentation tests cover Mission Control lanes, bounded Path Builder phases, proof rail behavior, and screen contracts.",
            evidenceLevel: .automatedSimulator,
            readiness: .acceptableForInternalTesting,
            limitation: "Very large goal portfolios still need device-volume scenario review."
        ),
        ReleasePerformanceCheck(
            id: "plan-load",
            area: .planLoad,
            budget: "Time must keep calendar-aware planning local and suggestion-first, with no silent calendar writes or stale top-level ownership drift.",
            evidence: "Time feature regressions cover believability, recovery, waiting/commitment posture, Save the Day boundaries, and denied-calendar fallback.",
            evidenceLevel: .automatedSimulator,
            readiness: .acceptableForInternalTesting,
            limitation: "Calendar permission permutations and real-device interaction timing remain R03 checks."
        ),
        ReleasePerformanceCheck(
            id: "receipt-history",
            area: .receiptHistoryQueries,
            budget: "Receipt and event history queries must stay explicitly limited and deterministic.",
            evidence: "Foundation performance tests cover bounded receipt summaries and recent event-ledger queries.",
            evidenceLevel: .sourceBudget,
            readiness: .acceptableForInternalTesting,
            limitation: "No persistent Trust Ledger load test exists yet; large historical stores remain a deferred measurement."
        ),
        ReleasePerformanceCheck(
            id: "memory-review",
            area: .memoryReviewQueries,
            budget: "Memory and reviews must project grouped, privacy-safe evidence instead of exposing raw logs or unbounded searches.",
            evidence: "Memory Lens, What Ambitions Knows, narrative memory, and review projector tests cover bounded local projections, source/freshness copy, correction posture, and review handoffs.",
            evidenceLevel: .automatedSimulator,
            readiness: .acceptableForInternalTesting,
            limitation: "Long-running memory history and manual correction speed need device-volume review."
        ),
        ReleasePerformanceCheck(
            id: "path-portfolio",
            area: .pathPortfolioQueries,
            budget: "Path and portfolio intelligence must remain qualitative, bounded, and free of hidden scoring.",
            evidence: "M05-M10 tests cover path families, domain packs, Path Builder, portfolio weather/scope, proof maturity, and qualitative momentum without fake precision.",
            evidenceLevel: .automatedSimulator,
            readiness: .acceptableForInternalTesting,
            limitation: "Broader semantic zoom and high-volume portfolio rendering remain future/device proof."
        ),
        ReleasePerformanceCheck(
            id: "external-snapshots",
            area: .externalSnapshots,
            budget: "External surfaces must consume lightweight privacy snapshots with stale-state truth and fallback routes.",
            evidence: "External snapshot, widget projection, Live Activity, App Intent, and M04 verification tests cover serialization, privacy redaction, stale/unavailable states, and command boundaries.",
            evidenceLevel: .automatedSimulator,
            readiness: .platformProofRequired,
            limitation: "Rendered widget gallery, Lock Screen/Dynamic Island lifecycle, Shortcuts/Siri invocation, notification delivery, and app-group I/O require device/platform proof."
        )
    ]

    static var readinessSummary: String {
        "This report records \(checks.count) performance and responsiveness checks for simulator/source evidence; device, TestFlight, and App Store proof remain separate gates."
    }

    static var unverifiedReadinessClaims: [String] {
        checks.compactMap { check in
            switch check.readiness {
            case .acceptableForInternalTesting:
                nil
            case .boundedButDeviceProofRequired, .platformProofRequired:
                "\(check.area.rawValue): \(check.limitation)"
            }
        }
    }
}
