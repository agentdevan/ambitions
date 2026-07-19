import AmbitionsDesignSystem
import SwiftUI

extension QuietCommandSheetView {
    var memoryLensBody: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            HStack(alignment: .center, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Search Ambitions")
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text("Local results from this iPhone.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer(minLength: theme.spacing.md)

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: theme.icon.smallSize, weight: .semibold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityLabel("Close Search")
                .accessibilityIdentifier("shell.search.close-button")
            }

            memoryPrompt
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.top, theme.spacing.xl)
        .padding(.bottom, theme.spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: theme.spacing.sm)
        }
    }

    var memoryPrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            TextField("Find goals, steps, captures, proof, settings", text: $memoryQuery)
                .textFieldStyle(.plain)
                .font(theme.typography.body)
                .focused($isMemoryFieldFocused)
                .padding(.horizontal, theme.spacing.md)
                .frame(minHeight: 52)
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
                .accessibilityLabel("Search Ambitions")
                .accessibilityHint("Find local goals, steps, captures, proof, receipts, Time, and You settings.")
                .accessibilityIdentifier("shell.memory-lens.search-field")

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
                memoryEmptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(memoryResults) { result in
                            memoryResultButton(result)
                        }
                    }
                    .padding(.vertical, theme.spacing.xs)
                }
                .frame(maxHeight: .infinity)
                .accessibilityIdentifier("shell.memory-lens.results")
            }
        }
    }

    var memoryEmptyState: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            let hasQuery = memoryQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            Text(hasQuery ? "No local match." : "Search local goals, steps, captures, proof, Time, and You.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("shell.memory-lens.empty-state")

            if hasQuery {
                Button {
                    let seedText = memoryQuery
                    onDismiss()
                    appContainer?.navigation.presentTypedCaptureComposer(
                        kind: .noteThought,
                        source: overlay.entrySource,
                        seedText: seedText
                    )
                } label: {
                    Label("Capture this", systemImage: "square.and.pencil")
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                .accessibilityIdentifier("shell.memory-lens.capture-query")
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
                        Text(result.searchFamily.title)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.stateStyle(for: result.state).accent)
                        Text(result.sourceAreaTitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(result.stateTitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Spacer(minLength: theme.spacing.xs)
                        Text(result.actionTitle)
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                        if result.inspectActionTitle != nil {
                            Image(systemName: "info.circle")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .accessibilityHidden(true)
                        }
                    }

                    Text(result.userFacingTitle)
                        .font(theme.typography.body.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(result.userFacingContext)
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
        .accessibilityLabel(result.userFacingAccessibilityLabel)
        .accessibilityHint("Opens this local result without changing saved data.")
        .accessibilityAction(named: Text(result.inspectActionTitle ?? "Open")) {
            onDismiss()
            _ = appContainer?.commandRouter.route(searchResult: result, source: overlay.entrySource)
        }
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
            seedIntent: overlay.intent ?? .memoryLens,
            origin: overlay.entrySource.originSurface
        )
        guard query == memoryQuery else {
            isMemorySearchLoading = false
            return
        }
        memoryResults = results.filter { result in
            result.trustedSearchHandoff(source: overlay.entrySource).isTrusted
        }
        memoryStatusMessage = results.isEmpty ? "No local result matched." : "\(memoryResults.count) local result\(memoryResults.count == 1 ? "" : "s")"
        isMemorySearchLoading = false
    }
}
