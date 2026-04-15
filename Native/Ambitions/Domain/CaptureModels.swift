import Foundation

enum CaptureSourceType: String, Codable, Sendable, Equatable {
    case todayQuickCapture = "today_quick_capture"
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
