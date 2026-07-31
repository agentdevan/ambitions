import SwiftUI

public struct SearchNativeCalibrationView: View {
    private let fixture: SearchNativeCalibrationFixture
    @Binding private var state: SearchNativeCalibrationJourneyState
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var originSearchFocused: Bool

    public init(
        fixture: SearchNativeCalibrationFixture,
        state: Binding<SearchNativeCalibrationJourneyState>
    ) {
        self.fixture = fixture
        _state = state
    }

    public var body: some View {
        presentationHost
            .onChange(of: state.focusAnchor, initial: true) { _, anchor in
                originSearchFocused = state.isPresented == false && anchor == .originSearchTrigger
            }
    }

    @ViewBuilder
    private var presentationHost: some View {
        #if os(iOS)
        origin
            .fullScreenCover(isPresented: presentation) {
                SearchNativeCalibrationPassage(
                    fixture: fixture,
                    state: $state
                )
                .dynamicTypeSize(dynamicTypeSize)
                .interactiveDismissDisabled()
            }
        #else
        ZStack {
            origin
            if state.isPresented {
                SearchNativeCalibrationPassage(
                    fixture: fixture,
                    state: $state
                )
            }
        }
        #endif
    }

    private var presentation: Binding<Bool> {
        Binding(
            get: { state.isPresented },
            set: { isPresented in
                if isPresented == false {
                    state.dismissSearch()
                }
            }
        )
    }

    private var origin: some View {
        ZStack {
            SearchNativeCalibrationPalette(
                colorScheme: .dark,
                contrast: .standard
            )
            .canvas
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(state.origin.rootIdentity)
                        .font(.largeTitle.weight(.semibold))
                    Text("Your day remains here while Search is open.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("snc-origin-chrome")

                Button {
                    _ = state.presentSearch()
                } label: {
                    Label(state.origin.initiatingControl, systemImage: "magnifyingglass")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(SearchNativeCalibrationPalette(colorScheme: .dark, contrast: .standard).accent)
                .accessibilityValue(state.lastDismissedContext == nil ? "" : "Returned from Search")
                .accessibilityFocused($originSearchFocused)
                .accessibilityIdentifier("snc-origin-search-trigger")

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .foregroundStyle(.white)
        .accessibilityHidden(state.isPresented)
    }
}

private struct SearchNativeCalibrationPassage: View {
    let fixture: SearchNativeCalibrationFixture
    @Binding var state: SearchNativeCalibrationJourneyState

    var body: some View {
        NavigationStack(path: navigationPath) {
            SearchNativeCalibrationRoot(
                fixture: fixture,
                state: $state
            )
            .navigationDestination(for: SearchNativeCalibrationRoute.self) { route in
                destination(for: route)
            }
        }
    }

    private var navigationPath: Binding<[SearchNativeCalibrationRoute]> {
        Binding(
            get: { state.navigationPath },
            set: { state.restoreNavigationPath($0) }
        )
    }

    @ViewBuilder
    private func destination(for route: SearchNativeCalibrationRoute) -> some View {
        switch route {
        case let .inspect(resultID):
            if let result = fixture.result(id: resultID) {
                SearchNativeCalibrationInspectDepth(
                    result: result,
                    onCancel: { state.dismissSearch() }
                )
            }
        case .ownerHandoff:
            SearchNativeCalibrationHandoffDepth(
                handoff: fixture.handoff,
                onContinue: { state.recordFixtureOnlyHandoff() },
                onCancelSearch: { state.dismissSearch() }
            )
        }
    }
}

private struct SearchNativeCalibrationRoot: View {
    let fixture: SearchNativeCalibrationFixture
    @Binding var state: SearchNativeCalibrationJourneyState

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var queryFocused: Bool
    @AccessibilityFocusState private var focusedResultID: String?
    @AccessibilityFocusState private var handoffPreparationFocused: Bool
    @State private var keyboardClearance: CGFloat = 0

    private var palette: SearchNativeCalibrationPalette {
        SearchNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        VStack(spacing: 0) {
            searchChrome
            Rectangle()
                .fill(palette.separator)
                .frame(height: 1)
            content
        }
        .background(palette.canvas.ignoresSafeArea(.container))
        .foregroundStyle(palette.primary)
        .searchNativeCalibrationTracksKeyboardClearance($keyboardClearance)
        .searchNativeCalibrationHideNavigationBar()
        .onAppear {
            focusForCurrentAnchor()
        }
        .onChange(of: state.focusAnchor) { _, _ in
            focusForCurrentAnchor()
        }
    }

    private var searchChrome: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                Text("Search")
                    .font(.title2.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("snc-search-identity")

                Spacer(minLength: 8)

                Button("Cancel") {
                    queryFocused = false
                    state.dismissSearch()
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.accent)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityIdentifier("snc-search-cancel")
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.secondary)
                    .accessibilityHidden(true)

                TextField("Search Ambitions", text: query)
                    .font(.body)
                    .foregroundStyle(palette.primary)
                    .focused($queryFocused)
                    .submitLabel(.search)
                    .accessibilityLabel("Search Ambitions")
                    .accessibilityValue(state.query)
                    .accessibilityIdentifier("snc-search-query")

                if state.query.isEmpty == false {
                    Button {
                        state.updateQuery("")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(palette.tertiary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear query")
                    .accessibilityIdentifier("snc-search-clear-query")
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, state.query.isEmpty ? 14 : 2)
            .frame(minHeight: 50)
            .background(palette.field, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text("Local on this iPhone")
                .font(.caption)
                .foregroundStyle(palette.secondary)
                .accessibilityIdentifier("snc-search-local-posture")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 14)
        .background(palette.canvas)
    }

    private var query: Binding<String> {
        Binding(
            get: { state.query },
            set: { state.updateQuery($0) }
        )
    }

    @ViewBuilder
    private var content: some View {
        if state.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            entryState
        } else if fixture.isPrivacyQuery(state.query) {
            privacyState
        } else if fixture.isNoResultsQuery(state.query) {
            noResultsState
        } else if fixture.isActionQuery(state.query) {
            actionQueryState
        } else {
            resultsState
        }
    }

    private var entryState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Search across Ambitions.")
                .font(.body)
                .foregroundStyle(palette.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("snc-search-entry-state")
    }

    private var resultsState: some View {
        resultScrollView(results: fixture.results(for: state.query))
    }

    private var actionQueryState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SearchNativeCalibrationSection(
                    label: "Interpreted target",
                    title: fixture.handoff.targetIdentity,
                    detail: "\(fixture.handoff.owner.rawValue) · \(fixture.handoff.currentAcceptedTruth)",
                    identifier: "snc-action-query-target"
                )

                Button {
                    openOwnerHandoffAfterKeyboardResigns()
                } label: {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Review requested change")
                                .font(.headline)
                            Text(fixture.handoff.requestedChange)
                                .font(.subheadline)
                                .foregroundStyle(palette.secondary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.forward")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(palette.accent)
                            .accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Review requested change")
                .accessibilityValue(
                    "Dentist appointment. Event in Time. Current time, Tomorrow at 9:30 AM. Requested time, Tomorrow at 11:00 AM."
                )
                .accessibilityFocused($handoffPreparationFocused)
                .accessibilityIdentifier("snc-action-query-review")
                .padding(.horizontal, 20)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(palette.separator).frame(height: 1)
                }
            }
        }
        .searchNativeCalibrationNeverDismissesKeyboard()
    }

    private var noResultsState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("No matching local results")
                .font(.title3.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            Text("Check the query or Cancel.")
                .font(.body)
                .foregroundStyle(palette.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 20)
        .padding(.top, 26)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("snc-search-no-results")
    }

    private var privacyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(fixture.privacy.message)
                        .font(.title3.weight(.semibold))
                    Text(fixture.privacy.limitation)
                        .font(.body)
                        .foregroundStyle(palette.secondary)
                    Text("Visible local results remain available.")
                        .font(.subheadline)
                        .foregroundStyle(palette.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 22)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(fixture.privacy.message)
                .accessibilityValue(fixture.privacy.limitation)
                .accessibilityIdentifier("snc-search-privacy-suppression")
                .overlay(alignment: .bottom) {
                    Rectangle().fill(palette.separator).frame(height: 1)
                }

                ForEach(fixture.results(for: state.query)) { result in
                    resultRow(result)
                }
            }
        }
        .searchNativeCalibrationNeverDismissesKeyboard()
    }

    private func resultScrollView(results: [SearchNativeCalibrationResult]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(results) { result in
                    resultRow(result)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear
                .frame(height: keyboardClearance)
                .accessibilityHidden(true)
        }
        .clipped()
        .searchNativeCalibrationNeverDismissesKeyboard()
        .accessibilityIdentifier("snc-search-results-region")
    }

    private func resultRow(_ result: SearchNativeCalibrationResult) -> some View {
        Button {
            openInspectAfterKeyboardResigns(resultID: result.id)
        } label: {
            VStack(alignment: .leading, spacing: dynamicTypeSize.isAccessibilitySize ? 10 : 7) {
                Text(result.identity)
                    .font(.headline)
                    .foregroundStyle(palette.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(result.owner.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondary)

                Text(result.currentTruth)
                    .font(.body)
                    .foregroundStyle(palette.primary)
                    .fixedSize(horizontal: false, vertical: true)

                if result.matchReasonIsObvious == false {
                    Text(result.matchReason)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 7) {
                    Text(result.actionTitle)
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.forward")
                        .font(.caption.weight(.semibold))
                        .accessibilityHidden(true)
                }
                .foregroundStyle(palette.accent)
                .frame(minHeight: 44, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(result.identity)
        .accessibilityValue(resultAccessibilityValue(result))
        .accessibilityHint("Opens read-only inspection")
        .accessibilityFocused($focusedResultID, equals: result.id)
        .accessibilityIdentifier("snc-result-\(result.id)")
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.separator).frame(height: 1)
        }
    }

    private func resultAccessibilityValue(_ result: SearchNativeCalibrationResult) -> String {
        var parts = [
            result.owner.rawValue,
            result.currentTruth
        ]
        if result.matchReasonIsObvious == false {
            parts.append("Why it appeared, \(result.matchReason)")
        }
        parts.append(result.actionTitle)
        if state.focusAnchor == .result(result.id) {
            parts.append("Selected result")
        }
        return parts.joined(separator: ". ")
    }

    private func focusForCurrentAnchor() {
        switch state.focusAnchor {
        case .query:
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(250))
                queryFocused = true
            }
        case let .result(resultID):
            queryFocused = false
            focusedResultID = resultID
        case .handoffPreparation:
            queryFocused = false
            handoffPreparationFocused = true
        case .originSearchTrigger:
            queryFocused = false
        }
    }

    private func openInspectAfterKeyboardResigns(resultID: String) {
        queryFocused = false
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            _ = state.openInspect(resultID: resultID)
        }
    }

    private func openOwnerHandoffAfterKeyboardResigns() {
        queryFocused = false
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            _ = state.openOwnerHandoff()
        }
    }
}

private struct SearchNativeCalibrationInspectDepth: View {
    let result: SearchNativeCalibrationResult
    let onCancel: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    private var palette: SearchNativeCalibrationPalette {
        SearchNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SearchNativeCalibrationSection(
                    label: "Object",
                    title: result.identity,
                    detail: "\(result.kind.rawValue) in \(result.owner.rawValue)",
                    identifier: "snc-inspect-identity"
                )
                SearchNativeCalibrationSection(
                    label: "When",
                    title: result.currentTruth,
                    identifier: "snc-inspect-current"
                )
                SearchNativeCalibrationSection(
                    label: "Why it appeared",
                    title: "The title matches “appointment.”",
                    identifier: "snc-inspect-match",
                    emphasizesTitle: false
                )
                SearchNativeCalibrationSection(
                    label: "About this result",
                    title: "Search can show this event and open it. Time handles any changes.",
                    identifier: "snc-contextual-inspect-explanation",
                    emphasizesTitle: false
                )
            }
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primary)
        .navigationTitle("Details")
        .searchNativeCalibrationInlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Cancel", action: onCancel)
                    .foregroundStyle(palette.accent)
                    .accessibilityIdentifier("snc-search-cancel")
            }
        }
    }
}

private struct SearchNativeCalibrationHandoffDepth: View {
    let handoff: SearchNativeCalibrationHandoff
    let onContinue: () -> Void
    let onCancelSearch: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    private var palette: SearchNativeCalibrationPalette {
        SearchNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SearchNativeCalibrationSection(
                    label: "Object",
                    title: handoff.targetIdentity,
                    detail: "Event in \(handoff.owner.rawValue)",
                    identifier: "snc-handoff-target"
                )
                SearchNativeCalibrationSection(
                    label: "Current time",
                    title: handoff.currentAcceptedTruth,
                    detail: "Nothing has changed.",
                    identifier: "snc-handoff-current"
                )
                SearchNativeCalibrationSection(
                    label: "Requested time",
                    title: handoff.requestedChange,
                    detail: handoff.consequence,
                    identifier: "snc-handoff-requested"
                )
                SearchNativeCalibrationSection(
                    label: "Before anything changes",
                    title: handoff.limitation,
                    identifier: "snc-handoff-consequence",
                    emphasizesTitle: false
                )

                VStack(alignment: .leading, spacing: 12) {
                    Button(handoff.actionTitle, action: onContinue)
                        .buttonStyle(.borderedProminent)
                        .tint(palette.accent)
                        .frame(minHeight: 44)
                        .accessibilityHint("Continues this requested time for review in Time.")
                        .accessibilityIdentifier("snc-handoff-continue")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primary)
        .navigationTitle("Review in Time")
        .searchNativeCalibrationInlineNavigationTitle()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Cancel", action: onCancelSearch)
                    .foregroundStyle(palette.accent)
                    .accessibilityIdentifier("snc-search-cancel")
            }
        }
    }
}

private struct SearchNativeCalibrationSection: View {
    let label: String
    let title: String
    let detail: String?
    let identifier: String
    let emphasizesTitle: Bool

    init(
        label: String,
        title: String,
        detail: String? = nil,
        identifier: String,
        emphasizesTitle: Bool = true
    ) {
        self.label = label
        self.title = title
        self.detail = detail
        self.identifier = identifier
        self.emphasizesTitle = emphasizesTitle
    }

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    private var palette: SearchNativeCalibrationPalette {
        SearchNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondary)
            Text(title)
                .font(emphasizesTitle ? .title3.weight(.semibold) : .body)
                .fixedSize(horizontal: false, vertical: true)
            if let detail {
                Text(detail)
                    .font(.body)
                    .foregroundStyle(palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue([title, detail].compactMap { $0 }.joined(separator: ". "))
        .accessibilityIdentifier(identifier)
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.separator).frame(height: 1)
        }
    }
}
