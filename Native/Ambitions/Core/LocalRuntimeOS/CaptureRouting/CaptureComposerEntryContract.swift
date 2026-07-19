import Foundation

enum CaptureComposerEntryPoint: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case globalButton = "global_button"
    case shareExtension = "share_extension"
    case appIntent = "app_intent"
    case notificationAction = "notification_action"
    case deepLink = "deep_link"
}

struct CaptureComposerEntryContract: Codable, Sendable, Equatable, Hashable, Identifiable {
    let entryPoint: CaptureComposerEntryPoint
    let captureSourceType: CaptureSourceType
    let commandSource: AmbitionsCommandSource
    let sourceSurface: String
    let requiresSharedCommandExecutor: Bool
    let mutatesOnlyAfterLocalCommand: Bool
    let storesRawInputLocalOnly: Bool
    let opensGlobalComposer: Bool
    let requiresAccessibleReview: Bool

    var id: String { entryPoint.rawValue }

    static let current: [CaptureComposerEntryContract] = [
        CaptureComposerEntryContract(
            entryPoint: .globalButton,
            captureSourceType: .shellComposer,
            commandSource: .capture,
            sourceSurface: "Capture",
            requiresSharedCommandExecutor: true,
            mutatesOnlyAfterLocalCommand: true,
            storesRawInputLocalOnly: true,
            opensGlobalComposer: true,
            requiresAccessibleReview: true
        ),
        CaptureComposerEntryContract(
            entryPoint: .shareExtension,
            captureSourceType: .shareExtensionText,
            commandSource: .deepLink,
            sourceSurface: "share_extension",
            requiresSharedCommandExecutor: true,
            mutatesOnlyAfterLocalCommand: true,
            storesRawInputLocalOnly: true,
            opensGlobalComposer: true,
            requiresAccessibleReview: true
        ),
        CaptureComposerEntryContract(
            entryPoint: .appIntent,
            captureSourceType: .appIntent,
            commandSource: .appIntent,
            sourceSurface: "app_intent",
            requiresSharedCommandExecutor: true,
            mutatesOnlyAfterLocalCommand: true,
            storesRawInputLocalOnly: true,
            opensGlobalComposer: true,
            requiresAccessibleReview: true
        ),
        CaptureComposerEntryContract(
            entryPoint: .notificationAction,
            captureSourceType: .notification,
            commandSource: .notification,
            sourceSurface: "notification",
            requiresSharedCommandExecutor: true,
            mutatesOnlyAfterLocalCommand: true,
            storesRawInputLocalOnly: true,
            opensGlobalComposer: true,
            requiresAccessibleReview: true
        ),
        CaptureComposerEntryContract(
            entryPoint: .deepLink,
            captureSourceType: .shellComposer,
            commandSource: .deepLink,
            sourceSurface: "deep_link",
            requiresSharedCommandExecutor: true,
            mutatesOnlyAfterLocalCommand: true,
            storesRawInputLocalOnly: true,
            opensGlobalComposer: true,
            requiresAccessibleReview: true
        ),
    ]
}
