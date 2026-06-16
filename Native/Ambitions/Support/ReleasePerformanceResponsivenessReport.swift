import Foundation

enum ReleasePerformanceArea: String, CaseIterable, Sendable, Equatable {
    case appLaunch = "App launch"
    case tabSwitching = "Tab switching"
    case todayLoad = "Today load"
    case goalDetailLoad = "Goal Detail load"
    case planLoad = "Time load"
    case observatoryFoundation = "Performance and energy observatory"
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

let releasePerformanceObservatorySchemaVersion = "release_performance_observatory.afep022.native.v1"
let releasePerformanceObservatoryLabel = "PerformanceBudget.afep022.performance-energy-observatory"

enum ReleasePerformanceSurface: String, CaseIterable, Sendable, Equatable, Hashable {
    case today
    case goals
    case time
    case motion
    case you
}

enum ReleasePerformanceObservatoryMetricKind: String, CaseIterable, Sendable, Equatable, Hashable {
    case queryBudget = "query_budget"
    case render
    case launch
    case scroll
    case backgroundMaintenance = "background_maintenance"
    case memory
    case wakeup
    case energyImpact = "energy_impact"
}

enum ReleasePerformanceBudgetLinkKind: String, Sendable, Equatable, Hashable {
    case afep004LocalProjection = "afep004_local_projection"
    case repositoryBudget = "repository_budget"
}

enum ReleasePerformanceValidationState: String, Sendable, Equatable, Hashable {
    case passed
    case blocked
    case skipped
}

struct ReleasePerformanceBudgetLink: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let kind: ReleasePerformanceBudgetLinkKind
    let reference: String

    var isWellFormed: Bool {
        id.isEmpty == false && reference.isEmpty == false
    }
}

struct ReleasePerformanceValidationPacket: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let observatoryLabel: String
    let command: String
    let artifactPath: String
    let sourceRecordReference: String
    let receiptReference: String
    let replayTraceReference: String
    let state: ReleasePerformanceValidationState
    let knownLimitation: String
    let owner: String

    var isWellFormed: Bool {
        id.isEmpty == false &&
            observatoryLabel == releasePerformanceObservatoryLabel &&
            command.isEmpty == false &&
            artifactPath.isEmpty == false &&
            sourceRecordReference.isEmpty == false &&
            receiptReference.isEmpty == false &&
            replayTraceReference.isEmpty == false &&
            knownLimitation.isEmpty == false &&
            owner.isEmpty == false
    }
}

struct ReleasePerformanceDegradationPlan: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let fallbackSummary: String
    let keepsElevatedVisualsOptional: Bool
    let keepsExpensiveRenderPathsOptional: Bool
    let defersBackgroundWork: Bool
    let preservesPrimaryAction: Bool
    let keepsUserExperienceLegible: Bool

    var isWellFormed: Bool {
        id.isEmpty == false &&
            fallbackSummary.isEmpty == false &&
            preservesPrimaryAction &&
            keepsUserExperienceLegible
    }
}

struct ReleasePerformanceClaimLock: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let currentEvidenceLevel: ReleasePerformanceEvidenceLevel
    let currentValidationState: ReleasePerformanceValidationState
    let currentMeasuredValidationExists: Bool
    let lockReason: String

    var allowsClaim: Bool {
        currentMeasuredValidationExists &&
            currentValidationState == .passed &&
            currentEvidenceLevel == .manualDeviceRequired
    }

    var isWellFormed: Bool {
        id.isEmpty == false && lockReason.isEmpty == false
    }
}

struct ReleasePerformanceObservatoryPlan: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let surface: ReleasePerformanceSurface
    let schemaVersion: String
    let metricKinds: [ReleasePerformanceObservatoryMetricKind]
    let budgetLinks: [ReleasePerformanceBudgetLink]
    let degradationPlan: ReleasePerformanceDegradationPlan
    let validationPacket: ReleasePerformanceValidationPacket
    let claimLock: ReleasePerformanceClaimLock

    var isWellFormed: Bool {
        id.isEmpty == false &&
            schemaVersion == releasePerformanceObservatorySchemaVersion &&
            metricKinds.isEmpty == false &&
            budgetLinks.isEmpty == false &&
            budgetLinks.allSatisfy(\.isWellFormed) &&
            degradationPlan.isWellFormed &&
            validationPacket.isWellFormed &&
            claimLock.isWellFormed
    }
}

enum ReleasePerformanceObservatoryRegistry {
    static let canonicalSurfacePlans: [ReleasePerformanceObservatoryPlan] = [
        makePlan(
            surface: .today,
            metricKinds: [.queryBudget, .launch, .scroll],
            fallbackSummary: "Keep Start Here readable, defer expensive motion, and prefer lower-cost rendering before the experience degrades.",
            owner: "Today performance observatory"
        ),
        makePlan(
            surface: .goals,
            metricKinds: [.queryBudget, .render, .memory],
            fallbackSummary: "Keep graph and detail work bounded, lower expensive rendering first, and defer heavy decoration.",
            owner: "Goals performance observatory"
        ),
        makePlan(
            surface: .motion,
            metricKinds: [.launch, .scroll, .wakeup],
            fallbackSummary: "Keep Motion proof and recovery inspection legible, defer background work, and preserve low-latency re-entry.",
            owner: "Motion performance observatory"
        ),
        makePlan(
            surface: .time,
            metricKinds: [.render, .backgroundMaintenance, .energyImpact],
            fallbackSummary: "Keep Time local and legible, prefer deferred maintenance, and reduce energy impact before heavier canvas work.",
            owner: "Time performance observatory"
        ),
        makePlan(
            surface: .you,
            metricKinds: [.queryBudget, .memory, .energyImpact],
            fallbackSummary: "Keep grouped settings responsive, defer non-critical work, and preserve trust controls.",
            owner: "You performance observatory"
        )
    ]

    private static func makePlan(
        surface: ReleasePerformanceSurface,
        metricKinds: [ReleasePerformanceObservatoryMetricKind],
        fallbackSummary: String,
        owner: String
    ) -> ReleasePerformanceObservatoryPlan {
        ReleasePerformanceObservatoryPlan(
            id: "\(surface.rawValue).observatory",
            surface: surface,
            schemaVersion: releasePerformanceObservatorySchemaVersion,
            metricKinds: metricKinds,
            budgetLinks: [
                ReleasePerformanceBudgetLink(
                    id: "\(surface.rawValue).afep004-local-projection",
                    kind: .afep004LocalProjection,
                    reference: "AFEP-004 local projection contract"
                ),
                ReleasePerformanceBudgetLink(
                    id: "\(surface.rawValue).repository-budget",
                    kind: .repositoryBudget,
                    reference: "Repository budget contract"
                )
            ],
            degradationPlan: ReleasePerformanceDegradationPlan(
                id: "\(surface.rawValue).degradation",
                fallbackSummary: fallbackSummary,
                keepsElevatedVisualsOptional: true,
                keepsExpensiveRenderPathsOptional: true,
                defersBackgroundWork: true,
                preservesPrimaryAction: true,
                keepsUserExperienceLegible: true
            ),
            validationPacket: ReleasePerformanceValidationPacket(
                id: "\(surface.rawValue).validation",
                observatoryLabel: releasePerformanceObservatoryLabel,
                command: "make xcode-focused-test BATCH=AFEP-022 TEST=AmbitionsTests/ReleasePerformanceResponsivenessReportTests",
                artifactPath: ".codex/xcode-results/afep-022/\(surface.rawValue)",
                sourceRecordReference: "SourceRecord reference required before measured evidence is attached.",
                receiptReference: "Receipt reference required before measured evidence is attached.",
                replayTraceReference: "ReplayTrace reference required before measured evidence is attached.",
                state: .skipped,
                knownLimitation: "No current measured validation is attached to the support scaffold.",
                owner: owner
            ),
            claimLock: ReleasePerformanceClaimLock(
                id: "\(surface.rawValue).public-release-claim",
                currentEvidenceLevel: .sourceBudget,
                currentValidationState: .skipped,
                currentMeasuredValidationExists: false,
                lockReason: "Release performance claims remain locked until current measured validation exists."
            )
        )
    }
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
            evidence: "M12 shell continuity tests cover Today, Goals, Time, Motion, You, global Capture, and review routes; R02 keeps this as a regression lane.",
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
            id: "afep-022-observatory-foundation",
            area: .observatoryFoundation,
            budget: "AFEP-022 observatory scaffolds surface plans, signposts, metric budgets, fallback decisions, and claim locks without asserting measured performance.",
            evidence: "ReleasePerformanceObservatoryRegistry covers Today, Goals, Time, Motion, and You with global Capture coverage, AFEP-004 local projection and repository budget links, explicit validation packets, and false-by-default public-release claim locks.",
            evidenceLevel: .sourceBudget,
            readiness: .acceptableForInternalTesting,
            limitation: "Measured device, Instruments, battery, thermal, and release-grade validation still need current evidence."
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
            evidence: "Search, What Ambitions Knows, narrative memory, and review projector tests cover bounded local projections, source/freshness copy, correction posture, and review handoffs.",
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
        "This report records \(checks.count) performance and responsiveness checks for simulator/source evidence; device, TestFlight, and App Store validation remain separate gates."
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
