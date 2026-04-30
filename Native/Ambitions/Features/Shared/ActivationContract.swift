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
        case .plan: "Plan"
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
    static let firstTenMinutesPromise = "Start with one real thing. Ambitions will turn it into one doable next step, show why it matters, give you a safe fallback, and stay honest about what is local."

    static let orientationTitle = "Start with one real thing"
    static let orientationSubtitle = "Ambitions becomes useful from one meaningful goal, one messy capture, or one calm return to Today. You do not need to set up your whole life first."

    static let startTitle = "Choose the first useful step"
    static let startSubtitle = "Create one specific goal or capture one loose thought. Either path keeps setup short and manual."

    static let trustMessage = ActivationTrustMessage(
        title: "Your work starts locally",
        explanation: "No Ambitions account, cloud provider, calendar connection, or external setup is required to begin. Permissions stay optional and contextual.",
        rows: [
            ActivationCopyRow(title: "No account required", detail: "There is no in-app account setup for the current first-run path.", icon: "person.crop.circle.badge.xmark"),
            ActivationCopyRow(title: "Starts locally", detail: "Goals, captures, and planning signals begin on this device.", icon: "lock.shield"),
            ActivationCopyRow(title: "Manual first", detail: "Ambitions asks you to choose the first real thing before it suggests more structure.", icon: "hand.tap"),
            ActivationCopyRow(title: "Optional connections", detail: "Calendar and notifications are useful later, but neither is required to start.", icon: "bell.badge")
        ]
    )

    static let onboardingSurfaceRows: [ActivationCopyRow] = [
        ActivationCopyRow(title: "Today", detail: "Choose one doable next step.", icon: AppTab.today.systemImage),
        ActivationCopyRow(title: "Goals", detail: "Name one meaningful direction.", icon: AppTab.goals.systemImage),
        ActivationCopyRow(title: "Capture", detail: "Put messy life here first.", icon: AppTab.captures.systemImage),
        ActivationCopyRow(title: "Plan", detail: "Shape the week only when something real asks for room.", icon: AppTab.plan.systemImage),
        ActivationCopyRow(title: "You", detail: "Check local trust, preferences, and optional permissions.", icon: AppTab.profile.systemImage)
    ]

    static func promise(for kind: ActivationMomentKind) -> ActivationPromise {
        switch kind {
        case .firstMeaningfulGoal:
            return ActivationPromise(
                kind: kind,
                title: "First meaningful goal",
                explanation: "Start with one specific ambition in plain language. Ambitions should shape a doable first step without asking for a giant life plan.",
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
                explanation: "Today keeps one doable step visible and keeps support panels subordinate to the day instead of becoming a dashboard.",
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
                title: "Capture messy life here",
                explanation: "Use Capture as the singular intake for loose thoughts, one-time tasks, waiting items, and seeds. Nothing here needs to become a full plan yet.",
                primaryAction: DegradedStateAction(title: "Capture now", systemImage: "square.and.pencil", routingHint: .quickCapture),
                secondaryAction: DegradedStateAction(title: "Return to Plan", systemImage: AppTab.plan.systemImage, routingHint: .plan),
                icon: "tray"
            )
        case .plan:
            return ActivationSurfaceEmptyStateRule(
                surface: surface,
                title: "The week has room",
                explanation: "Plan works without calendar access. Add a goal or capture first, then shape only the work that truly needs room this week.",
                primaryAction: DegradedStateAction(title: "Create goal", systemImage: "target", routingHint: .createGoal),
                secondaryAction: DegradedStateAction(title: "Open Capture", systemImage: "tray.full", routingHint: .captures),
                icon: AppTab.plan.systemImage
            )
        case .you:
            return ActivationSurfaceEmptyStateRule(
                surface: surface,
                title: "Your system starts local",
                explanation: "You can begin without connecting anything. Trust, preferences, and optional permissions live here without claiming sync or export is ready.",
                primaryAction: DegradedStateAction(title: "Review trust", systemImage: "checkmark.shield", routingHint: .profileTrust),
                secondaryAction: DegradedStateAction(title: "Open Today", systemImage: AppTab.today.systemImage, routingHint: .today),
                icon: AppTab.profile.systemImage
            )
        }
    }
}
