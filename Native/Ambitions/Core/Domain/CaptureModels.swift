import Foundation

enum CaptureSourceType: String, Codable, Sendable, Equatable, CaseIterable {
    case todayQuickCapture = "today_quick_capture"
    case shellComposer = "shell_composer"
    case notification = "notification"
    case shareExtensionText = "share_extension_text"
    case shareExtensionURL = "share_extension_url"
    case appIntent = "app_intent"

    var title: String {
        switch self {
        case .todayQuickCapture:
            return "Today quick capture"
        case .shellComposer:
            return "Global Capture"
        case .notification:
            return "Notification"
        case .shareExtensionText:
            return "Share extension text"
        case .shareExtensionURL:
            return "Share extension URL"
        case .appIntent:
            return "App Intent"
        }
    }
}

enum CaptureStatus: String, Codable, Sendable, Equatable, CaseIterable {
    case needsTriage = "needs_triage"
    case seed
    case actionable
    case goalBound = "goal_bound"
    case scheduled
    case delegated
    case waiting
    case optionalSomeday = "optional_someday"
    case archived

    var title: String {
        switch self {
        case .needsTriage:
            return "Needs triage"
        case .seed:
            return "Seed"
        case .actionable:
            return "Actionable"
        case .goalBound:
            return "Goal-bound"
        case .scheduled:
            return "Scheduled"
        case .delegated:
            return "Delegated"
        case .waiting:
            return "Waiting"
        case .optionalSomeday:
            return "Optional / Someday"
        case .archived:
            return "Archived"
        }
    }

    func canTransition(to next: CaptureStatus) -> Bool {
        guard self != next else { return true }

        switch self {
        case .needsTriage:
            return next == .seed || next == .actionable || next == .goalBound || next == .scheduled || next == .delegated || next == .waiting || next == .optionalSomeday || next == .archived
        case .seed:
            return next == .actionable || next == .goalBound || next == .scheduled || next == .waiting || next == .optionalSomeday || next == .archived
        case .actionable:
            return next == .needsTriage || next == .seed || next == .goalBound || next == .scheduled || next == .delegated || next == .waiting || next == .optionalSomeday || next == .archived
        case .goalBound, .scheduled, .delegated, .waiting, .optionalSomeday:
            return next == .needsTriage || next == .seed || next == .actionable || next == .goalBound || next == .scheduled || next == .delegated || next == .waiting || next == .optionalSomeday || next == .archived
        case .archived:
            return false
        }
    }
}

enum CaptureTriageDestination: String, Codable, Sendable, Equatable, CaseIterable {
    case needsTriage = "needs_triage"
    case timeSeed = "time_seed"
    case doSoon = "do_soon"
    case turnIntoGoal = "turn_into_goal"
    case attachToGoal = "attach_to_goal"
    case saveAsSeed = "save_as_seed"
    case waiting
    case optionalSomeday = "optional_someday"
    case deliverableSeed = "deliverable_seed"
    case archive

    var title: String {
        switch self {
        case .needsTriage:
            return "Needs triage"
        case .timeSeed:
            return "Time idea"
        case .doSoon:
            return "Do soon"
        case .turnIntoGoal:
            return "Turn into goal"
        case .attachToGoal:
            return "Attach to goal"
        case .saveAsSeed:
            return "Save as seed"
        case .waiting:
            return "Waiting"
        case .optionalSomeday:
            return "Optional / Someday"
        case .deliverableSeed:
            return "Deliverable seed"
        case .archive:
            return "Archive"
        }
    }
}

enum CaptureBackgroundFactRoute: String, Codable, Sendable, Equatable, CaseIterable {
    case needsPlace = "needs_place"
    case needsReview = "needs_review"

    var title: String {
        switch self {
        case .needsPlace:
            return "Needs a Place"
        case .needsReview:
            return "Needs Review"
        }
    }

    var explanation: String {
        switch self {
        case .needsPlace:
            return "Context that still needs a calm owning surface."
        case .needsReview:
            return "Context that should be checked before runtime use."
        }
    }
}

enum CaptureStagedInputKind: String, Codable, Sendable, Equatable, CaseIterable {
    case text
    case voice
    case image
    case share
    case proof
    case context

    var title: String {
        switch self {
        case .text:
            return "Text"
        case .voice:
            return "Voice"
        case .image:
            return "Image"
        case .share:
            return "Share"
        case .proof:
            return "Proof"
        case .context:
            return "Context"
        }
    }
}

struct CaptureStagedRouteCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let route: CaptureRoute
    let title: String
    let privacyLabel: String
    let exportLabel: String
    let redactionLabel: String
    let retentionLabel: String

    init(
        id: String,
        route: CaptureRoute,
        title: String,
        privacyLabel: String,
        exportLabel: String,
        redactionLabel: String,
        retentionLabel: String
    ) {
        self.id = Self.normalizedRequired(id)
        self.route = route
        self.title = Self.normalizedRequired(title)
        self.privacyLabel = Self.normalizedRequired(privacyLabel)
        self.exportLabel = Self.normalizedRequired(exportLabel)
        self.redactionLabel = Self.normalizedRequired(redactionLabel)
        self.retentionLabel = Self.normalizedRequired(retentionLabel)
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
