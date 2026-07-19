import Foundation

enum ReleaseDeviceQAScope: String, CaseIterable, Sendable, Equatable {
    case realDeviceSmoke = "Real-device smoke"
    case freshInstall = "Fresh install"
    case returningUser = "Returning user"
    case deniedPermissions = "Denied permissions"
    case noData = "No data"
    case lotsOfData = "Lots of data"
    case missedWeek = "Recovery week"
    case exportImport = "Export / import"
    case externalSurfaces = "External surfaces"
    case representativeScenarios = "Representative scenarios"
}

enum ReleaseDeviceQAEvidenceState: String, Sendable, Equatable {
    case simulatorAutomated = "Simulator automated"
    case sourceFixture = "Source fixture"
    case deviceRequired = "Device required"
}

enum TestFlightReadinessPosture: String, Sendable, Equatable {
    case notCandidate = "Not a TestFlight candidate"
    case internalQAOnly = "Internal QA only"
    case candidateAfterDeviceSmoke = "Candidate after device smoke"
}

struct ReleaseDeviceQACheck: Identifiable, Sendable, Equatable {
    let id: String
    let scope: ReleaseDeviceQAScope
    let requiredJourney: String
    let evidence: String
    let evidenceState: ReleaseDeviceQAEvidenceState
    let blockerIfMissing: String
}

struct ReleaseRepresentativeScenarioFixture: Identifiable, Sendable, Equatable {
    let id: String
    let domain: String
    let scenario: String
    let surfaces: [RuntimeScenarioSurface]
    let guardrail: String
}

enum ReleaseDeviceQAReadinessReport {
    static let checks: [ReleaseDeviceQACheck] = [
        ReleaseDeviceQACheck(
            id: "real-device-smoke",
            scope: .realDeviceSmoke,
            requiredJourney: "Install and launch the app on a physical iPhone, then run the four-surface smoke and one create/capture/time/review loop.",
            evidence: "No physical iPhone execution was available in this environment; simulator build/test evidence is recorded instead.",
            evidenceState: .deviceRequired,
            blockerIfMissing: "Do not claim real-device validation or TestFlight readiness."
        ),
        ReleaseDeviceQACheck(
            id: "fresh-install",
            scope: .freshInstall,
            requiredJourney: "Start from no local app data and verify onboarding, first goal, global Capture path, and local-first trust copy.",
            evidence: "Focused UI smoke can force onboarding in preview bootstrap and unit tests cover empty-state activation contracts.",
            evidenceState: .simulatorAutomated,
            blockerIfMissing: "Fresh users may see a broken first-run path."
        ),
        ReleaseDeviceQACheck(
            id: "returning-user",
            scope: .returningUser,
            requiredJourney: "Launch with existing local data and verify Today, Goals, Time, You, Reviews, and receipts still orient the user.",
            evidence: "Preview bootstrap, core-surface scenario catalog, and repository-backed service tests cover returning-user local data paths.",
            evidenceState: .simulatorAutomated,
            blockerIfMissing: "Returning users may lose context or trust."
        ),
        ReleaseDeviceQACheck(
            id: "denied-permissions",
            scope: .deniedPermissions,
            requiredJourney: "Deny or restrict Calendar/notification-style permissions and verify user choice remains clear.",
            evidence: "Time, calendar reality, EventKit, activation, and external verification tests cover denied/unavailable permission fallback without silent writes.",
            evidenceState: .simulatorAutomated,
            blockerIfMissing: "The app may imply unavailable integrations or break manual planning."
        ),
        ReleaseDeviceQACheck(
            id: "no-data",
            scope: .noData,
            requiredJourney: "Open Today, Goals, Time, and You with no goals or captures, then invoke global Capture and verify calm useful empty states.",
            evidence: "Daily loop, activation, Today, Goals, Time, You, and global Capture tests cover no-data/empty-state behavior.",
            evidenceState: .simulatorAutomated,
            blockerIfMissing: "Empty states may feel blank or overclaim future systems."
        ),
        ReleaseDeviceQACheck(
            id: "lots-of-data",
            scope: .lotsOfData,
            requiredJourney: "Review a dense local portfolio with many goals, receipts, memories, captures, and path/review projections.",
            evidence: "Bounded source budgets and deterministic projection tests exist; high-volume physical-device scrolling remains unrun.",
            evidenceState: .deviceRequired,
            blockerIfMissing: "Do not claim large-data device responsiveness."
        ),
        ReleaseDeviceQACheck(
            id: "disrupted-week",
            scope: .missedWeek,
            requiredJourney: "Return after a week away and verify stale context, review needs, and one re-entry move.",
            evidence: "Scenario catalog and Today/Time/inspection tests cover stale-context and recovery posture.",
            evidenceState: .sourceFixture,
            blockerIfMissing: "Recovery after time away may be confusing or shame-prone."
        ),
        ReleaseDeviceQACheck(
            id: "export-import",
            scope: .exportImport,
            requiredJourney: "Run portable export/import and fresh-store restore scenarios without overwriting local data silently.",
            evidence: "M02-M03 portable snapshot tests cover selected export, malformed package safety, partial references, merge preservation, and fresh-store restore.",
            evidenceState: .simulatorAutomated,
            blockerIfMissing: "Local-first trust would lack practical recovery proof."
        ),
        ReleaseDeviceQACheck(
            id: "external-surfaces",
            scope: .externalSurfaces,
            requiredJourney: "Verify widgets, Live Activities, App Intents, Shortcuts, notifications, and shared-container behavior on device where implemented.",
            evidence: "D22-D25/M04/R02 tests cover contracts, snapshots, privacy, stale states, metadata, and source budgets; rendered platform behavior remains unverified.",
            evidenceState: .deviceRequired,
            blockerIfMissing: "Do not claim platform or TestFlight readiness for external surfaces."
        ),
        ReleaseDeviceQACheck(
            id: "representative-scenarios",
            scope: .representativeScenarios,
            requiredJourney: "Exercise family, career, creative, finance, and home/life-admin style journeys as fixtures, not user-specific defaults.",
            evidence: "R03 representative scenario fixtures keep domain examples as QA fixtures over existing surfaces, without hardcoding product assumptions.",
            evidenceState: .sourceFixture,
            blockerIfMissing: "Scenario review could become too narrow or accidentally productize personal assumptions."
        )
    ]

    static let representativeScenarios: [ReleaseRepresentativeScenarioFixture] = [
        ReleaseRepresentativeScenarioFixture(
            id: "family-week",
            domain: "Family / shared life",
            scenario: "A packed family week needs one protected next step, a waiting item, and non-shaming recovery.",
            surfaces: [.today, .time, .trustInspection, .you],
            guardrail: "Fixture only; do not infer family structure or social obligations."
        ),
        ReleaseRepresentativeScenarioFixture(
            id: "career-transition",
            domain: "Career",
            scenario: "A career transition goal needs path phases, proof, risks, and Today/Time handoff.",
            surfaces: [.goals, .today, .time],
            guardrail: "No professional advice or best-path certainty."
        ),
        ReleaseRepresentativeScenarioFixture(
            id: "creative-project",
            domain: "Creative project",
            scenario: "A creative launch needs Capture intake, Goal Detail proof, and a reviewable receipt trail.",
            surfaces: [.captureComposer, .goals, .trustInspection],
            guardrail: "No dashboard or fake momentum score."
        ),
        ReleaseRepresentativeScenarioFixture(
            id: "finance-admin",
            domain: "Finance / life admin",
            scenario: "A financial admin goal needs privacy-safe wording, proof requirements, and manual confirmation boundaries.",
            surfaces: [.goals, .time, .you],
            guardrail: "No financial advice claim or sensitive inference."
        ),
        ReleaseRepresentativeScenarioFixture(
            id: "home-maintenance",
            domain: "Home / life admin",
            scenario: "A home project needs waiting states, dependencies, and a clear next Step without becoming a project board.",
            surfaces: [.goals, .time, .today],
            guardrail: "No top-level Tasks or hidden project-management mode."
        )
    ]

    static var testFlightPosture: TestFlightReadinessPosture {
        checks.contains(where: { $0.evidenceState == .deviceRequired }) ? .candidateAfterDeviceSmoke : .internalQAOnly
    }

    static var readinessSummary: String {
        "R03 records simulator/source QA for \(checks.count) device-readiness scopes and keeps TestFlight gated on physical-device smoke; R05 owns final RC lock truth."
    }
}
