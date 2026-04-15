import Foundation

enum CaptureSourceType: String, Codable, Sendable, Equatable {
    case todayQuickCapture = "today_quick_capture"
    case notification = "notification"
    case shareExtensionText = "share_extension_text"
    case shareExtensionURL = "share_extension_url"
    case appIntent = "app_intent"
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
