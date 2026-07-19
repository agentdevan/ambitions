import Foundation

extension DefaultShellCommandRouter {
    func captureComposerDestination(source: ShellCommandEntrySource) -> ShellCommandDestination {
        .overlay(
            .commandSheet(
                intent: .quickCapture,
                entrySource: source,
                presentationContext: .quickCapture
            )
        )
    }

    func fallbackDecision(for text: String, source: ShellCommandEntrySource) -> SmartAttachmentCaptureDecision {
        SmartAttachmentCaptureAdapter().decision(
            rawText: text,
            sourceType: appShellCaptureSourceType(for: source),
            sourceSurface: source.displayTitle,
            selectedRouteType: .idea
        )!
    }

    func captureCommandMetadata(
        sourceType: CaptureSourceType,
        routeType: SmartAttachmentRouteType,
        source: ShellCommandEntrySource
    ) -> [String: String] {
        [
            ExternalCreationCommandMetadataKey.sourceType: sourceType.rawValue,
            "captureEntryPoint": source.rawValue,
            "captureRouteType": routeType.rawValue,
            "captureCommandPath": "shell_command_router"
        ]
    }

    func ambitionsCommandSource(for source: ShellCommandEntrySource) -> AmbitionsCommandSource {
        switch source {
        case .todayQuickCapture:
            return .today
        case .goalsCreate, .goalsQuickCapture:
            return .goals
        case .timeQuickCapture:
            return .time
        case .youQuickCapture:
            return .you
        case .appIntent:
            return .appIntent
        case .notification:
            return .notification
        case .widget:
            return .widget
        case .deepLink, .shareExtension:
            return .deepLink
        case .shellCompose, .shellUtility, .globalCaptureComposer, .external:
            return .capture
        }
    }
}
