import AmbitionsDesignSystem
import SwiftUI

struct CapturesScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var state: AsyncViewState<[Capture]> = .loading

    var body: some View {
        FeatureScaffoldView(
            eyebrow: "Inbox",
            title: "Captures",
            subtitle: "Review local captures collected from Ambitions and other on-device entry points."
        ) {
            switch state {
            case .loading:
                LoadingSkeletonCard(lineCount: 6)
                    .transition(.ambitionPanel)
            case let .failed(message):
                EmptyStateCard(
                    title: "Captures are unavailable",
                    message: message,
                    icon: "tray.full",
                    actionTitle: "Retry",
                    actionAccessibilityIdentifier: "captures.retry-button"
                ) {
                    Task { await load() }
                }
                .transition(.ambitionPanel)
            case let .loaded(captures):
                if captures.isEmpty {
                    EmptyStateCard(
                        title: "No captures yet",
                        message: "Quick capture, share extension intake, and future app intents will appear here once they create local records.",
                        icon: "tray"
                    )
                    .transition(.ambitionPanel)
                } else {
                    LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                        ForEach(captures) { capture in
                            AppCard {
                                VStack(alignment: .leading, spacing: theme.spacing.md) {
                                    Text(capture.rawText)
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(metadataText(for: capture))
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .accessibilityIdentifier("captures.metadata.\(capture.id)")
                                }
                            }
                            .accessibilityIdentifier("captures.card.\(capture.id)")
                        }
                    }
                    .transition(.ambitionPanel)
                }
            }
        }
        .navigationTitle("Captures")
        .refreshable {
            await load()
        }
        .accessibilityIdentifier("captures.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: stateKey)
        .task {
            guard case .loading = state else { return }
            await load()
        }
    }

    private func load() async {
        do {
            state = .loaded(try await container.captureService.listCaptures())
        } catch {
            state = .failed("Unable to load captures: \(error.localizedDescription)")
        }
    }

    private func metadataText(for capture: Capture) -> String {
        var parts = [capture.status.rawValue.capitalized]
        if let sourceType = capture.sourceType {
            parts.append(sourceLabel(for: sourceType))
        }
        parts.append(capture.updatedAt)
        return parts.joined(separator: " • ")
    }

    private func sourceLabel(for sourceType: CaptureSourceType) -> String {
        switch sourceType {
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

    private var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(captures):
            return "loaded:\(captures.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

#Preview("Captures Light") {
    NavigationStack {
        CapturesScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

#Preview("Captures Dark") {
    NavigationStack {
        CapturesScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}
