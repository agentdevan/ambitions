import Foundation

enum CoreSurfaceScenarioSurface: String, CaseIterable, Sendable, Equatable {
    case today = "Today"
    case goals = "Goals"
    case capture = "Capture"
    case plan = "Plan"
    case you = "You"
    case goalDetail = "Goal Detail"
    case reviews = "Reviews"
    case externalSurfaces = "External surfaces"
}

enum CoreSurfaceLaunchLoopStep: String, CaseIterable, Sendable, Equatable {
    case capture = "Capture"
    case place = "Place / routing"
    case plan = "Plan / doable path"
    case today = "Today / next action"
    case recovery = "Recovery"
    case proof = "Proof / receipt"
    case trust = "Trust / privacy"
}

enum CoreSurfaceScenarioSeverity: String, Sendable, Equatable {
    case blocking = "Blocking"
    case high = "High"
    case medium = "Medium"
    case watch = "Watch"
}

struct CoreSurfaceIntegrationScenario: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let intent: String
    let surfaces: [CoreSurfaceScenarioSurface]
    let launchLoopSteps: [CoreSurfaceLaunchLoopStep]
    let manualSteps: [String]
    let expectedEvidence: [String]
    let blockerIfBroken: String
    let severity: CoreSurfaceScenarioSeverity
}

struct CoreSurfaceMaturityBlocker: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let ownerBatch: String
    let severity: CoreSurfaceScenarioSeverity
    let evidenceNeeded: String
}

enum CoreSurfaceIntegrationScenarioCatalog {
    static let scenarios: [CoreSurfaceIntegrationScenario] = [
        CoreSurfaceIntegrationScenario(
            id: "meaningful-goal",
            title: "Create a meaningful goal",
            intent: "A user can name one specific ambition and see a useful next step without setting up their whole life.",
            surfaces: [.goals, .goalDetail, .today, .plan],
            launchLoopSteps: [.plan, .today, .proof, .trust],
            manualSteps: [
                "Create one ordinary but meaningful goal.",
                "Confirm Goals shows direction, next step, and how it is going.",
                "Open Goal Detail and confirm Steps, Proof, Decisions, Risks, and Archive stay contained there.",
                "Return to Today and confirm the next useful step is visible."
            ],
            expectedEvidence: ["Goal exists", "Next step visible", "Contained Steps language", "No Tasks tab"],
            blockerIfBroken: "Core goal-to-next-action loop is not coherent.",
            severity: .blocking
        ),
        CoreSurfaceIntegrationScenario(
            id: "capture-place-thought",
            title: "Capture a loose thought and place it",
            intent: "A loose thought enters Capture, gets a suggested place, and remains recoverable through Needs a Place when uncertain.",
            surfaces: [.capture, .goals, .plan, .today],
            launchLoopSteps: [.capture, .place, .proof, .trust],
            manualSteps: [
                "Open Capture and enter a loose thought.",
                "Confirm the suggested place uses plain copy and has a correction path.",
                "Route it to the safest available destination or Needs a Place.",
                "Confirm the receipt says what happened without implying hidden automation."
            ],
            expectedEvidence: ["Capture saved", "Suggested place or Needs a Place", "Route receipt", "Correction available"],
            blockerIfBroken: "Intake cannot be trusted as the first step of the launch loop.",
            severity: .blocking
        ),
        CoreSurfaceIntegrationScenario(
            id: "disrupted-day-recovery",
            title: "Recover after a disrupted day",
            intent: "A disrupted day turns into one smaller next step without shame or silent rescheduling.",
            surfaces: [.today, .plan, .reviews, .you],
            launchLoopSteps: [.today, .recovery, .proof, .trust],
            manualSteps: [
                "Use a state where yesterday slipped or an action was skipped.",
                "Confirm Today offers recovery without blame.",
                "Open Plan only when a broader adjustment is needed.",
                "Confirm receipts/reviews can explain what changed or did not change."
            ],
            expectedEvidence: ["Recovery copy is non-shaming", "No silent calendar write", "Review/receipt context visible"],
            blockerIfBroken: "Recovery is not safe enough for real-life use.",
            severity: .high
        ),
        CoreSurfaceIntegrationScenario(
            id: "overloaded-week",
            title: "Resolve an overloaded week",
            intent: "Plan can show what does not fit and offer confirmation-bound changes.",
            surfaces: [.plan, .today, .goals, .you],
            launchLoopSteps: [.plan, .recovery, .proof, .trust],
            manualSteps: [
                "Load a week with too much planned.",
                "Confirm Plan says what is tight or too much in plain language.",
                "Use Save the Day or recovery only with confirmation for meaningful changes.",
                "Confirm nothing writes to Calendar silently."
            ],
            expectedEvidence: ["Too much planned state", "Confirmation boundary", "No silent external write"],
            blockerIfBroken: "Plan cannot negotiate with reality safely.",
            severity: .blocking
        ),
        CoreSurfaceIntegrationScenario(
            id: "proof-receipts-review",
            title: "Review proof and receipts",
            intent: "Progress has inspectable proof or receipts that say what changed.",
            surfaces: [.goalDetail, .reviews, .you],
            launchLoopSteps: [.proof, .trust],
            manualSteps: [
                "Open a goal with proof or a recent receipt.",
                "Confirm Goal Detail shows proof without fake precision.",
                "Open Reviews or You and confirm receipt/proof summaries remain local and correctable.",
                "Confirm private details stay collapsible or redacted where needed."
            ],
            expectedEvidence: ["Proof visible", "Receipt summary", "Privacy-safe wording"],
            blockerIfBroken: "Progress cannot be audited by the user.",
            severity: .high
        ),
        CoreSurfaceIntegrationScenario(
            id: "what-ambitions-knows",
            title: "Inspect What Ambitions Knows",
            intent: "The user can see local memory sources, freshness, use, and safe-vs-blocked controls.",
            surfaces: [.you, .reviews],
            launchLoopSteps: [.trust],
            manualSteps: [
                "Open You.",
                "Open What Ambitions Knows.",
                "Confirm each memory area names source, freshness, and what it is used for.",
                "Confirm blocked controls do not claim destructive deletion or cloud memory."
            ],
            expectedEvidence: ["Source labels", "Freshness labels", "Used-for copy", "Safe blocked controls"],
            blockerIfBroken: "Memory could feel hidden or overclaimed.",
            severity: .blocking
        ),
        CoreSurfaceIntegrationScenario(
            id: "calendar-denied",
            title: "Use denied-calendar fallback",
            intent: "Manual planning still works when Calendar is denied or unavailable.",
            surfaces: [.plan, .today, .you],
            launchLoopSteps: [.plan, .today, .recovery, .trust],
            manualSteps: [
                "Simulate denied or unavailable Calendar access.",
                "Confirm Plan offers manual fallback.",
                "Confirm Today does not request Calendar access.",
                "Confirm You/Trust copy does not imply Calendar is connected."
            ],
            expectedEvidence: ["Manual fallback", "Plan-owned permission boundary", "No connected-calendar claim"],
            blockerIfBroken: "Calendar denial breaks the core planning loop.",
            severity: .blocking
        ),
        CoreSurfaceIntegrationScenario(
            id: "one-step-goal",
            title: "Start with a One-Step Goal",
            intent: "A standalone Task can be created without adding a top-level Tasks tab or confusing contained Steps.",
            surfaces: [.capture, .today, .goals],
            launchLoopSteps: [.capture, .place, .today, .proof],
            manualSteps: [
                "Capture a one-off outcome.",
                "Confirm it is treated as a Task / One-Step Goal where appropriate.",
                "Confirm contained Goal Detail actions still say Steps.",
                "Confirm Today can surface the one-step item without a Tasks tab."
            ],
            expectedEvidence: ["Task is standalone", "Steps remain contained", "No Tasks tab"],
            blockerIfBroken: "Task/Step terminology becomes unsafe for users.",
            severity: .high
        ),
        CoreSurfaceIntegrationScenario(
            id: "park-defer-drop",
            title: "Park, defer, or drop noncritical work",
            intent: "Noncritical work can move out of Today without shame or hidden deletion.",
            surfaces: [.today, .plan, .goals, .reviews],
            launchLoopSteps: [.today, .recovery, .proof],
            manualSteps: [
                "Identify work that should not stay on today.",
                "Use Park, Not Today, or a drop/cancel path where available.",
                "Confirm the copy is non-shaming.",
                "Confirm a receipt or review context can explain the change."
            ],
            expectedEvidence: ["Park/defer/drop available where supported", "Non-shaming copy", "Change remains explainable"],
            blockerIfBroken: "The app pressures users to perform progress instead of choosing truthfully.",
            severity: .medium
        ),
        CoreSurfaceIntegrationScenario(
            id: "week-away-return",
            title: "Return after a week away",
            intent: "A returning user sees what is still safe, what changed, and one re-entry move.",
            surfaces: [.today, .plan, .goals, .reviews, .you],
            launchLoopSteps: [.today, .recovery, .proof, .trust],
            manualSteps: [
                "Use stale or older local context.",
                "Confirm Today gives one re-entry move.",
                "Confirm Plan/Goals distinguish current from stale context.",
                "Confirm You and Reviews make source/freshness/review needs visible."
            ],
            expectedEvidence: ["One re-entry move", "Stale context visible", "Review need visible"],
            blockerIfBroken: "Returning users cannot regain trust after time away.",
            severity: .high
        )
    ]

    static let blockers: [CoreSurfaceMaturityBlocker] = [
        CoreSurfaceMaturityBlocker(id: "m02-export-import", title: "Export/import disaster drill is still unproven", ownerBatch: "M02", severity: .blocking, evidenceNeeded: "Portable export/import scenario, safe failure state, and restore proof."),
        CoreSurfaceMaturityBlocker(id: "m03-data-safety", title: "No-lost-data and migration hardening needs dedicated proof", ownerBatch: "M03", severity: .blocking, evidenceNeeded: "Offline, migration, corrupt/partial data, and receipt integrity tests."),
        CoreSurfaceMaturityBlocker(id: "m04-external-platform", title: "External surfaces need platform verification", ownerBatch: "M04", severity: .high, evidenceNeeded: "Rendered widget, Live Activity, notification, App Intent, shortcut, and shared-container proof where available."),
        CoreSurfaceMaturityBlocker(id: "m05-m07-path", title: "Path intelligence and Path Builder remain maturity work", ownerBatch: "M05-M07", severity: .medium, evidenceNeeded: "Qualitative path contract, domain packs, fork comparison, accessible roadmap UI."),
        CoreSurfaceMaturityBlocker(id: "m08-memory", title: "Memory correction and narrative memory need deeper controls", ownerBatch: "M08", severity: .high, evidenceNeeded: "Editable/correctable memory flows, review signals, pause/delete boundaries, and receipts."),
        CoreSurfaceMaturityBlocker(id: "m09-reviews", title: "Reviews and Life OS Receipt need scenario maturity", ownerBatch: "M09", severity: .medium, evidenceNeeded: "Weekly/monthly/recovery review scenarios tied to proof, decisions, and carry/drop guidance."),
        CoreSurfaceMaturityBlocker(id: "m10-m11-surface-maturity", title: "Portfolio and recovery maturity need broad scenario proof", ownerBatch: "M10-M11", severity: .medium, evidenceNeeded: "Goal Weather/scope checks, waiting/commitment behavior, Save-the-Day maturity, and undo/receipt proof."),
        CoreSurfaceMaturityBlocker(id: "r02-performance", title: "Final responsiveness measurements remain a release gate", ownerBatch: "R02", severity: .high, evidenceNeeded: "Realistic launch, navigation, heavy-surface, memory/review, path/portfolio, and external snapshot measurements."),
        CoreSurfaceMaturityBlocker(id: "r01-accessibility-claims", title: "Public accessibility claims remain locked", ownerBatch: "R01", severity: .blocking, evidenceNeeded: "VoiceOver, Dynamic Type, Reduce Motion, contrast, motor, and external-surface accessibility review."),
        CoreSurfaceMaturityBlocker(id: "r03-r05-release", title: "Device QA, App Store materials, and RC lock need human/device gates", ownerBatch: "R03-R05", severity: .blocking, evidenceNeeded: "Real-device QA, TestFlight/readiness evidence, privacy/demo materials, and explicit human approval gate.")
    ]

    static var manualChecklist: [String] {
        scenarios.map { scenario in
            let surfaces = scenario.surfaces.map(\.rawValue).joined(separator: " / ")
            let evidence = scenario.expectedEvidence.joined(separator: "; ")
            return "\(scenario.title) [\(surfaces)]: \(scenario.manualSteps.joined(separator: " -> ")) Evidence: \(evidence)."
        }
    }
}
