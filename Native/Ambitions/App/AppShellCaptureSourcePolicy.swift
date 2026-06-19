func appShellCaptureSourceType(for source: ShellCommandEntrySource) -> CaptureSourceType {
    switch source {
    case .todayQuickCapture:
        return .todayQuickCapture
    case .appIntent:
        return .appIntent
    case .notification:
        return .notification
    case .shareExtension:
        return .shareExtensionText
    case .shellCompose,
         .shellUtility,
         .goalsCreate,
         .goalsQuickCapture,
         .timeQuickCapture,
         .youQuickCapture,
         .globalCaptureComposer,
         .deepLink,
         .widget,
         .external:
        return .shellComposer
    }
}
