import Foundation

enum ActivationMomentKind: String, CaseIterable, Sendable, Equatable {
    case firstMeaningfulGoal
    case firstCapturedLifeObject
    case firstTodayContract
    case firstRecoveryExample
    case firstExplanationReceipt
    case firstTrustAndExportMessage
    case firstReturnPath
}

struct ActivationPromise: Identifiable, Sendable, Equatable {
    let kind: ActivationMomentKind
    let title: String
    let explanation: String
    let primaryActionTitle: String?
    let primaryRoutingHint: DegradedStateRoutingHint?

    var id: String { kind.rawValue }
}

enum ActivationSurface: String, CaseIterable, Sendable, Equatable {
    case today
    case goals
    case capture
    case plan
    case you

    var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .capture: "Capture"
        case .plan: "Time"
        case .you: "You"
        }
    }
}

struct ActivationSurfaceEmptyStateRule: Identifiable, Sendable, Equatable {
    let surface: ActivationSurface
    let title: String
    let explanation: String
    let primaryAction: DegradedStateAction
    let secondaryAction: DegradedStateAction?
    let icon: String

    var id: String { surface.rawValue }
}

struct ActivationCopyRow: Sendable, Equatable {
    let title: String
    let detail: String
    let icon: String
}

struct ActivationTrustMessage: Sendable, Equatable {
    let title: String
    let explanation: String
    let rows: [ActivationCopyRow]
}

enum ActivationContract {
    static let firstTenMinutesPromise = "Start with one real thing. Ambitions turns it into one doable step, shows why it matters, offers a safe fallback, and stays honest about what is local."

    static let orientationTitle = "Ambitions is a life organization system"
    static let orientationSubtitle = "It works through five primary objects: Today, Goals, Time, Motion, and You, with Capture available as the global place to start. You only need one real thing to begin, and setup stays manual-first."

    static let startTitle = "Choose one honest first action"
    static let startSubtitle = "Create one specific goal, capture one loose thought, or open Today. Ambitions keeps the first step manual, local, and free of setup noise."

    static let trustMessage = ActivationTrustMessage(
        title: "Your work starts locally",
        explanation: "No Ambitions account, cloud provider, calendar connection, or external setup is required to begin. Permissions stay optional and contextual, and your first actions stay on-device.",
        rows: [
            ActivationCopyRow(title: "No account required", detail: "There is no in-app account setup on the current first-run path.", icon: "person.crop.circle.badge.xmark"),
            ActivationCopyRow(title: "Starts locally", detail: "Goals, captures, and planning signals begin on this device first.", icon: "lock.shield"),
            ActivationCopyRow(title: "Manual first", detail: "Ambitions asks you to choose one real thing before it suggests more structure.", icon: "hand.tap"),
            ActivationCopyRow(title: "Optional connections", detail: "Calendar and notifications are useful later, but neither is required to start.", icon: "bell.badge"),
            ActivationCopyRow(title: "Trust stays local", detail: "Local data keeps the first run inspectable, reversible, and honest about what is ready.", icon: "checkmark.shield")
        ]
    )

    static let onboardingSurfaceRows: [ActivationCopyRow] = [
        ActivationCopyRow(title: "Today", detail: "Keep one doable step visible and grounded in current reality.", icon: AppTab.today.systemImage),
        ActivationCopyRow(title: "Goals", detail: "Name one meaningful direction before you build a plan.", icon: AppTab.goals.systemImage),
        ActivationCopyRow(title: "Time", detail: "Shape the week only when something real asks for room.", icon: AppTab.time.systemImage),
        ActivationCopyRow(title: "Motion", detail: "Inspect proof, recovery, and re-entry without ranking progress.", icon: AppTab.motion.systemImage),
        ActivationCopyRow(title: "You", detail: "Check local trust, preferences, and optional permissions.", icon: AppTab.you.systemImage)
    ]

    static let onboardingKnownNowRows: [ActivationCopyRow] = [
        ActivationCopyRow(title: "One real thing is enough", detail: "You can start with one goal, one capture, or one Today step.", icon: "circle"),
        ActivationCopyRow(title: "The objects do the work", detail: "Today, Goals, Time, Motion, and You organize life while global Capture catches the first loose thing.", icon: "square.grid.2x2"),
        ActivationCopyRow(title: "Setup can wait", detail: "Anything that needs calendar access, notifications, or more structure can stay off the first-run path.", icon: "hourglass")
    ]

    static let onboardingBoundaryRows: [ActivationCopyRow] = [
        ActivationCopyRow(title: "Manual first", detail: "Ambitions waits for one real thing before it suggests more structure.", icon: "hand.tap"),
        ActivationCopyRow(title: "Calendar optional", detail: "Time can wait until you need scheduling help.", icon: "calendar"),
        ActivationCopyRow(title: "Notifications optional", detail: "Reminders can wait until you want them.", icon: "bell")
    ]

    static func promise(for kind: ActivationMomentKind) -> ActivationPromise {
        switch kind {
        case .firstMeaningfulGoal:
            return ActivationPromise(
                kind: kind,
                title: "First meaningful goal",
                explanation: "Start with one specific ambition in plain language. Ambitions shapes one doable first step without asking for a giant life plan.",
                primaryActionTitle: "Create first goal",
                primaryRoutingHint: .createGoal
            )
        case .firstCapturedLifeObject:
            return ActivationPromise(
                kind: kind,
                title: "First captured life object",
                explanation: "Capture is the singular intake for messy life: tasks, ideas, waiting items, seeds, and commitments can land here before they become anything bigger.",
                primaryActionTitle: "Capture first",
                primaryRoutingHint: .quickCapture
            )
        case .firstTodayContract:
            return ActivationPromise(
                kind: kind,
                title: "First Today Contract",
                explanation: "Today keeps one doable step visible and keeps support panels subordinate to the day.",
                primaryActionTitle: "Enter Today",
                primaryRoutingHint: .today
            )
        case .firstRecoveryExample:
            return ActivationPromise(
                kind: kind,
                title: "First recovery example",
                explanation: "Recovery is part of the plan. When the day breaks, Ambitions should offer a smaller, safer step without guilt or silent rescheduling.",
                primaryActionTitle: nil,
                primaryRoutingHint: nil
            )
        case .firstExplanationReceipt:
            return ActivationPromise(
                kind: kind,
                title: "First explanation",
                explanation: "Why this and why changed should be understandable trust concepts. Current surfaces explain local evidence and assumptions without pretending a receipt ledger is complete.",
                primaryActionTitle: nil,
                primaryRoutingHint: nil
            )
        case .firstTrustAndExportMessage:
            return ActivationPromise(
                kind: kind,
                title: "First trust message",
                explanation: "Your work starts locally. Export and sync are not required to begin, and current first-run copy must not claim a live sync or export flow.",
                primaryActionTitle: "Review You",
                primaryRoutingHint: .profileTrust
            )
        case .firstReturnPath:
            return ActivationPromise(
                kind: kind,
                title: "First return path",
                explanation: "A returning user should see where they left off, what is still safe, one re-entry step, and what can wait using only existing local data.",
                primaryActionTitle: "Come back to Today",
                primaryRoutingHint: .today
            )
        }
    }

    static func emptyStateRule(for surface: ActivationSurface) -> ActivationSurfaceEmptyStateRule {
        switch surface {
        case .today:
            return ActivationSurfaceEmptyStateRule(
                surface: surface,
                title: "Today is waiting for one real thing",
                explanation: "Add one meaningful goal or capture one loose thought. Today will keep one doable step visible when there is something real to act on.",
                primaryAction: DegradedStateAction(title: "Create first goal", systemImage: "target", routingHint: .createGoal),
                secondaryAction: DegradedStateAction(title: "Capture first", systemImage: "tray.and.arrow.down", routingHint: .quickCapture),
                icon: "sun.max"
            )
        case .goals:
            return ActivationSurfaceEmptyStateRule(
                surface: surface,
                title: "Start with one meaningful goal",
                explanation: "Name one specific ambition in plain language. Ambitions will shape a first doable path without asking for a whole life plan.",
                primaryAction: DegradedStateAction(title: "Create goal", systemImage: "plus", routingHint: .createGoal),
                secondaryAction: DegradedStateAction(title: "Capture an idea", systemImage: "tray.and.arrow.down", routingHint: .quickCapture),
                icon: "scope"
            )
        case .capture:
            return ActivationSurfaceEmptyStateRule(
                surface: surface,
                title: "Capture Anything",
                explanation: "Capture is the first stop for loose life. Type one real thing in the composer, then choose Start here, Create goal, Shape time, Close with proof, or Inspect what Ambitions knows when it needs a step, a direction, room, or review.",
                primaryAction: DegradedStateAction(title: "Start here", systemImage: AppTab.today.systemImage, routingHint: .today),
                secondaryAction: DegradedStateAction(title: "Create goal", systemImage: "target", routingHint: .createGoal),
                icon: "tray"
            )
        case .plan:
            return ActivationSurfaceEmptyStateRule(
                surface: surface,
                title: "The week has room",
                explanation: "Time works without calendar access. Add a goal or capture first, then shape only the work that truly needs room this week.",
                primaryAction: DegradedStateAction(title: "Create goal", systemImage: "target", routingHint: .createGoal),
                secondaryAction: DegradedStateAction(title: "Open Capture", systemImage: "tray.full", routingHint: .captures),
                icon: AppTab.time.systemImage
            )
        case .you:
            return ActivationSurfaceEmptyStateRule(
                surface: surface,
                title: "Your system starts local",
                explanation: "You can begin without connecting anything. Trust, preferences, and optional permissions live here without claiming sync or export is ready.",
                primaryAction: DegradedStateAction(title: "Review trust", systemImage: "checkmark.shield", routingHint: .profileTrust),
                secondaryAction: DegradedStateAction(title: "Open Today", systemImage: AppTab.today.systemImage, routingHint: .today),
                icon: AppTab.you.systemImage
            )
        }
    }
}
