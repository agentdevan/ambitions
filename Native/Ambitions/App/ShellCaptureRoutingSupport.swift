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

}
