import Foundation

enum CaptureSourceType: String, Codable, Sendable, Equatable, CaseIterable {
    case todayQuickCapture = "today_quick_capture"
    case notification = "notification"
    case shareExtensionText = "share_extension_text"
    case shareExtensionURL = "share_extension_url"
    case appIntent = "app_intent"

    var title: String {
        switch self {
        case .todayQuickCapture:
            return "Today quick capture"
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
    case seed
    case actionable
    case goalBound = "goal_bound"
    case scheduled
    case delegated
    case archived

    var title: String {
        switch self {
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
        case .archived:
            return "Archived"
        }
    }

    func canTransition(to next: CaptureStatus) -> Bool {
        guard self != next else { return true }

        switch self {
        case .seed:
            return next == .actionable || next == .archived
        case .actionable:
            return next == .seed || next == .goalBound || next == .scheduled || next == .delegated || next == .archived
        case .goalBound, .scheduled, .delegated:
            return next == .archived
        case .archived:
            return false
        }
    }
}

enum CaptureTriageDestination: String, Codable, Sendable, Equatable, CaseIterable {
    case doSoon = "do_soon"
    case turnIntoGoal = "turn_into_goal"
    case attachToGoal = "attach_to_goal"
    case saveAsSeed = "save_as_seed"
    case archive

    var title: String {
        switch self {
        case .doSoon:
            return "Do soon"
        case .turnIntoGoal:
            return "Turn into goal"
        case .attachToGoal:
            return "Attach to goal"
        case .saveAsSeed:
            return "Save as seed"
        case .archive:
            return "Archive"
        }
    }
}

struct CaptureTriageMetadata: Codable, Sendable, Equatable {
    let destination: CaptureTriageDestination?
    let hint: String?

    init(destination: CaptureTriageDestination? = nil, hint: String? = nil) {
        self.destination = destination
        self.hint = hint
    }
}

struct Capture: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let rawText: String
    let sourceType: CaptureSourceType?
    let status: CaptureStatus
    let linkedGoalID: String?
    let triage: CaptureTriageMetadata?
    let revisitAfter: String?

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        rawText: String,
        sourceType: CaptureSourceType?,
        status: CaptureStatus,
        linkedGoalID: String?,
        triage: CaptureTriageMetadata? = nil,
        revisitAfter: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.rawText = rawText
        self.sourceType = sourceType
        self.status = status
        self.linkedGoalID = linkedGoalID
        self.triage = triage
        self.revisitAfter = revisitAfter
    }
}
