import AmbitionsDesignSystem
import SwiftUI

extension QuietCommandSheetView {
    var memoryPrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Search stays local. Results open with source context and the owning surface.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: theme.spacing.sm) {
                TextField("Search context", text: $memoryQuery)
                    .textFieldStyle(.plain)
                    .font(theme.typography.body)
                    .padding(theme.spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .fill(theme.colors.surfaceOverlay)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                    )
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await refreshMemoryResults() }
                    }
                    .accessibilityIdentifier("shell.memory-lens.search-field")

                Button {
                    Task { await refreshMemoryResults() }
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                .accessibilityIdentifier("shell.memory-lens.search-button")
            }

            if isMemorySearchLoading {
                ProgressView()
                    .accessibilityIdentifier("shell.memory-lens.loading")
            }

            if let memoryStatusMessage {
                Text(memoryStatusMessage)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.memory-lens.status")
            }

            if memoryResults.isEmpty && isMemorySearchLoading == false {
                Text("No matching context yet. Try a goal, Capture phrase, correction, or handoff source.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.memory-lens.empty-state")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(memoryResults) { result in
                            memoryResultButton(result)
                        }
                    }
                    .padding(.vertical, theme.spacing.xs)
                }
                .frame(maxHeight: 360)
                .accessibilityIdentifier("shell.memory-lens.results")
            }
        }
    }

    func memoryResultButton(_ result: MemoryLensResult) -> some View {
        let handoff = result.trustedSearchHandoff(source: overlay.entrySource)
        return Button {
            onDismiss()
            let routedHandoff = appContainer?.commandRouter.route(searchResult: result, source: overlay.entrySource)
            memoryStatusMessage = routedHandoff?.body ?? handoff.body
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: result.systemImage)
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(theme.stateStyle(for: result.state).accent)
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(result.badgeTitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.stateStyle(for: result.state).accent)
                        Text(handoff.owner.title)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Spacer(minLength: theme.spacing.xs)
                        Text(result.actionTitle)
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                    }

                    Text(result.title)
                        .font(theme.typography.body.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(result.contextRetrievalSummary)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(theme.spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfaceOverlay)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.title), \(handoff.owner.accessibilityLabel), \(result.actionTitle)")
        .accessibilityHint("Opens this source-grounded result without changing saved memory.")
        .accessibilityIdentifier("shell.memory-lens.result.\(result.id)")
        .disabled(handoff.isTrusted == false)
    }

    @MainActor
    func refreshMemoryResults() async {
        guard let appContainer else {
            memoryResults = []
            memoryStatusMessage = "Search is unavailable without the app container."
            return
        }
        let query = memoryQuery
        isMemorySearchLoading = true
        let results = await appContainer.memoryLensService.search(
            query: query,
            seedIntent: overlay.intent ?? .memoryLens
        )
        guard query == memoryQuery else {
            isMemorySearchLoading = false
            return
        }
        memoryResults = results.filter { result in
            result.trustedSearchHandoff(source: overlay.entrySource).isTrusted
        }
        memoryStatusMessage = results.isEmpty ? "No local context matched this search." : "\(memoryResults.count) trusted result\(memoryResults.count == 1 ? "" : "s")"
        isMemorySearchLoading = false
    }
}
