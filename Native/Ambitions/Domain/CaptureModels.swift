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

enum CaptureStatus: String, Codable, Sendable, Equatable {
    case pending
    case processed
    case archived
}

struct Capture: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let rawText: String
    let sourceType: CaptureSourceType?
    let status: CaptureStatus
    let linkedGoalID: String?
}
