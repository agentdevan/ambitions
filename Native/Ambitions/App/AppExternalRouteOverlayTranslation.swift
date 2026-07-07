import Foundation

extension AppExternalRouteTranslator {
    func isCaptureComposerOverlay(
        host: String,
        pathSegments: [String],
        query: [String: String]
    ) -> Bool {
        let first = (pathSegments.first ?? host).lowercased()
        guard query["intent"].flatMap(ShellCommandIntent.init(rawValue:)) == .quickCapture else {
            return false
        }
        return ["overlay", "command", "compose"].contains(host)
            && ["quiet-command-sheet", "command", "capture", "compose"].contains(first)
    }

    func isCaptureComposerPayload(values: [String: String], fallbackAction: String) -> Bool {
        if fallbackAction == "open-capture-composer" || values["surface"] == "capture-composer" {
            return true
        }
        let overlayName = (values["overlay"] ?? fallbackAction).lowercased()
        return values["intent"].flatMap(ShellCommandIntent.init(rawValue:)) == .quickCapture
            && ["quiet-command-sheet", "command", "quick-capture", "capture"].contains(overlayName)
    }

    func overlayRoute(
        host: String,
        pathSegments: [String],
        query: [String: String]
    ) -> ShellOverlayState? {
        let source: ShellCommandEntrySource = {
            if query["origin"] == ExternalSurfaceOrigin.appIntent.rawValue {
                return .appIntent
            }
            if query["origin"] == ExternalSurfaceOrigin.shareExtension.rawValue {
                return .shareExtension
            }
            return host == "compose" ? .appIntent : .deepLink
        }()
        let first = (pathSegments.first ?? host).lowercased()
        let intent = query["intent"].flatMap(ShellCommandIntent.init(rawValue:))

        switch first {
        case "quiet-command-sheet", "command":
            return .commandSheet(
                intent: intent,
                entrySource: source,
                presentationContext: intent?.presentationContext ?? .neutral
            )
        case "memory-lens", "memory", "search":
            return .memoryLens(
                intent: intent ?? .memoryLens,
                entrySource: source,
                presentationContext: .recall,
                query: query["q"] ?? query["query"] ?? "",
                goalID: query["goalID"],
                captureID: query["captureID"]
            )
        case "create-goal", "goal":
            return .createGoal(entrySource: source)
        case "capture":
            return .commandSheet(
                intent: .quickCapture,
                entrySource: source,
                presentationContext: .quickCapture
            )
        default:
            return nil
        }
    }

    func overlayRoute(
        values: [String: String],
        fallbackAction: String,
        source: ExternalActionSource
    ) -> ShellOverlayState? {
        let entrySource: ShellCommandEntrySource = {
            switch source {
            case .notification: .notification
            case .widget: .widget
            case .appIntent: .appIntent
            case .deepLink: .deepLink
            case .futureExternalPayload: .external
            }
        }()
        let intent = values["intent"].flatMap(ShellCommandIntent.init(rawValue:))
        let overlayName = (values["overlay"] ?? fallbackAction).lowercased()

        switch overlayName {
        case "quiet-command-sheet", "open-command", "command":
            return .commandSheet(
                intent: intent,
                entrySource: entrySource,
                presentationContext: intent?.presentationContext ?? .neutral
            )
        case "memory-lens", "open-memory-lens", "memory":
            return .memoryLens(
                intent: intent ?? .memoryLens,
                entrySource: entrySource,
                presentationContext: .recall,
                query: values["query"] ?? "",
                goalID: values["goalID"],
                captureID: values["captureID"]
            )
        case "create-goal":
            return .createGoal(entrySource: entrySource)
        case "quick-capture", "capture":
            return .commandSheet(
                intent: .quickCapture,
                entrySource: entrySource,
                presentationContext: .quickCapture
            )
        default:
            return nil
        }
    }
}
