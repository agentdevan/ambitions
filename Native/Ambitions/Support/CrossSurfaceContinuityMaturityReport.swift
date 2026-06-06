import AmbitionsDesignSystem
import Foundation

enum CrossSurfaceContinuityState: String, Sendable, Equatable {
    case verified = "Verified"
    case needsManualProof = "Needs manual proof"
    case releaseGate = "Release gate"
}

struct CrossSurfaceContinuityHandoff: Identifiable, Sendable, Equatable {
    let id: String
    let surface: CoreSurfaceScenarioSurface
    let modeLens: AmbitionModeLens
    let continuityBehavior: String
    let owningRoute: String
    let state: CrossSurfaceContinuityState
    let limitation: String
}

struct MatureInventionPerformanceCheck: Identifiable, Sendable, Equatable {
    let id: String
    let area: String
    let budget: String
    let evidence: String
    let state: CrossSurfaceContinuityState
}

struct Layer3ReadinessBlocker: Identifiable, Sendable, Equatable {
    let id: String
    let ownerBatch: String
    let title: String
    let requiredEvidence: String
}

enum CrossSurfaceContinuityMaturityReport {
    static let handoffs: [CrossSurfaceContinuityHandoff] = [
        CrossSurfaceContinuityHandoff(
            id: "today-next-move",
            surface: .today,
            modeLens: .focus,
            continuityBehavior: "Today remains the protected next-move landing surface and can receive focus or recovery entry context.",
            owningRoute: "Today tab",
            state: .verified,
            limitation: "Real-device returning-user proof remains R03."
        ),
        CrossSurfaceContinuityHandoff(
            id: "capture-routing",
            surface: .capture,
            modeLens: .triage,
            continuityBehavior: "Capture keeps intake singular and routes uncertain items through Needs a Place without widening top-level navigation.",
            owningRoute: "Global Capture action",
            state: .verified,
            limitation: "Share-extension rendered intake proof remains external-surface work."
        ),
        CrossSurfaceContinuityHandoff(
            id: "goals-direction",
            surface: .goals,
            modeLens: .focus,
            continuityBehavior: "Goals carries direction, scope, weather, and Path Builder handoff back to Today or Time without becoming a board.",
            owningRoute: "Goals tab and Goal Detail",
            state: .verified,
            limitation: "Confirmed path editing remains future maturity work."
        ),
        CrossSurfaceContinuityHandoff(
            id: "plan-recovery",
            surface: .plan,
            modeLens: .plan,
            continuityBehavior: "Time owns week shaping, calendar boundaries, Save the Day, waiting, commitments, and confirmation-first recovery through Plan compatibility services.",
            owningRoute: "Time tab and Weekly Review",
            state: .verified,
            limitation: "No silent calendar writes are available or claimed."
        ),
        CrossSurfaceContinuityHandoff(
            id: "you-trust",
            surface: .you,
            modeLens: .focus,
            continuityBehavior: "You keeps trust, controls, What Ambitions Knows, history, privacy, export/import, and memory correction visible.",
            owningRoute: "You tab",
            state: .verified,
            limitation: "Public accessibility and release claims remain locked until R01-R05."
        ),
        CrossSurfaceContinuityHandoff(
            id: "reviews-handoff",
            surface: .reviews,
            modeLens: .review,
            continuityBehavior: "Reviews live under You and Time, summarizing proof, decisions, recovery, and carry-forward guidance without silent plan mutation.",
            owningRoute: "You / Time review routes",
            state: .verified,
            limitation: "Manual scenario review remains R03."
        ),
        CrossSurfaceContinuityHandoff(
            id: "external-surfaces",
            surface: .externalSurfaces,
            modeLens: .focus,
            continuityBehavior: "External surfaces use privacy snapshots, stale-state truth, open-route fallback, and receipt boundaries.",
            owningRoute: "Shared external snapshot and command contracts",
            state: .needsManualProof,
            limitation: "Rendered widgets, Live Activities, Shortcuts, notification delivery, and device app-group I/O remain platform verification gates."
        ),
        CrossSurfaceContinuityHandoff(
            id: "path-builder",
            surface: .goalDetail,
            modeLens: .focus,
            continuityBehavior: "Path Builder stays inside Goal Detail and hands phases, forks, proof, Today, and Time context back to owning surfaces.",
            owningRoute: "Goal Detail Path lane",
            state: .verified,
            limitation: "Path Builder is not a top-level tab and does not auto-edit roadmaps."
        )
    ]

    static let performanceChecks: [MatureInventionPerformanceCheck] = [
        MatureInventionPerformanceCheck(
            id: "life-graph",
            area: "Life graph / breadcrumbs",
            budget: "Bound traversal depth and cycle-safe projection.",
            evidence: "Foundation performance tests cover bounded breadcrumb traversal and deterministic projections.",
            state: .verified
        ),
        MatureInventionPerformanceCheck(
            id: "ledger-receipts",
            area: "Event ledger / receipts",
            budget: "Recent queries and display summaries remain explicitly limited.",
            evidence: "Foundation performance tests cover bounded recent-event and receipt summary queries.",
            state: .verified
        ),
        MatureInventionPerformanceCheck(
            id: "trust-memory",
            area: "Trust and memory panels",
            budget: "Projection surfaces stay grouped, local, and privacy-safe instead of exposing raw logs.",
            evidence: "D18, D19, and M08 service tests cover Trust Center, What Ambitions Knows, and narrative memory projections.",
            state: .verified
        ),
        MatureInventionPerformanceCheck(
            id: "path-portfolio",
            area: "Path and portfolio projections",
            budget: "Qualitative path/portfolio projections stay bounded and avoid hidden scoring.",
            evidence: "M05-M10 tests cover path intelligence, domain packs, Path Builder, and Goals portfolio maturity.",
            state: .verified
        ),
        MatureInventionPerformanceCheck(
            id: "external-snapshots",
            area: "Widgets and Live Activities",
            budget: "Snapshots stay lightweight, stale-aware, and privacy-safe.",
            evidence: "D22-D25 and M04 tests cover external-surface contracts and verification checklists.",
            state: .needsManualProof
        ),
        MatureInventionPerformanceCheck(
            id: "device-responsiveness",
            area: "Device responsiveness",
            budget: "Launch, tab switching, and heavy surface load must be measured on realistic device scenarios.",
            evidence: "Simulator build/test proof exists; final measurements remain R02/R03.",
            state: .releaseGate
        )
    ]

    static let layer3Blockers: [Layer3ReadinessBlocker] = [
        Layer3ReadinessBlocker(
            id: "r01-accessibility-claims",
            ownerBatch: "R01",
            title: "Public accessibility claims remain locked.",
            requiredEvidence: "VoiceOver, Dynamic Type, Reduce Motion, contrast, motor, and external-surface accessibility review."
        ),
        Layer3ReadinessBlocker(
            id: "r02-performance",
            ownerBatch: "R02",
            title: "Final performance and responsiveness measurements remain unverified on realistic scenarios.",
            requiredEvidence: "Launch, tab switching, Today, Goal Detail, Time, receipt/history, memory/review, path/portfolio, and external snapshot measurements."
        ),
        Layer3ReadinessBlocker(
            id: "r03-device-qa",
            ownerBatch: "R03",
            title: "Real-device and TestFlight readiness still need representative journey proof.",
            requiredEvidence: "Fresh install, returning user, denied permissions, data volume, disrupted week, export/import, and external surface device checks."
        ),
        Layer3ReadinessBlocker(
            id: "r04-r05-release-truth",
            ownerBatch: "R04-R05",
            title: "App Store, privacy, demo, and RC lock need explicit evidence and human approval.",
            requiredEvidence: "Current screenshots, privacy labels, reviewer notes, release notes, demo material, blocker list, and approval gate."
        )
    ]

    static var completionSummary: String {
        "M12 verifies continuity across \(handoffs.count) handoff areas and records \(performanceChecks.count) mature performance checks; R04/R05 own remaining external release truth and RC lock gates."
    }
}
