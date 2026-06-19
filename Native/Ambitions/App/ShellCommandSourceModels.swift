import Foundation

enum ShellCommandEntrySource: String, Hashable, Sendable, Codable {
    case shellCompose
    case shellUtility
    case goalsCreate
    case todayQuickCapture
    case goalsQuickCapture
    case timeQuickCapture
    case youQuickCapture
    case globalCaptureComposer
    case deepLink
    case appIntent
    case notification
    case widget
    case shareExtension
    case external

    var displayTitle: String {
        switch self {
        case .shellCompose: "Quick action"
        case .shellUtility: "Shell"
        case .goalsCreate: "Goals"
        case .todayQuickCapture: "Today"
        case .goalsQuickCapture: "Goals"
        case .timeQuickCapture: "Time"
        case .youQuickCapture: "You"
        case .globalCaptureComposer: "Capture"
        case .deepLink: "Linked route"
        case .appIntent: "Shortcut"
        case .notification: "Notification"
        case .widget: "Widget"
        case .shareExtension: "Share"
        case .external: "External surface"
        }
    }
}

struct ShellCommandHistoryEntry: Hashable, Identifiable, Sendable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let source: ShellCommandEntrySource
    let presentationContext: ShellCommandPresentationContext
    let destinationLabel: String
    let recordedAt: String

    init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        destinationLabel: String,
        recordedAt: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.source = source
        self.presentationContext = presentationContext
        self.destinationLabel = destinationLabel
        self.recordedAt = recordedAt
    }

    var sourceLabel: String { source.displayTitle }
}

struct ShellContinuityReceipt: Hashable, Identifiable, Sendable, Codable {
    let id: String
    let title: String
    let body: String
    let source: ShellCommandEntrySource
    let destinationLabel: String

    init(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        source: ShellCommandEntrySource,
        destinationLabel: String
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.source = source
        self.destinationLabel = destinationLabel
    }

    var sourceLabel: String { source.displayTitle }
}
