import AmbitionsNativeVisualFoundry
import SwiftUI

enum SearchNativeFoundryVariant: String {
    case origin = "snc-search-origin-dark"
    case entryFocused = "snc-search-entry-focused-dark"
    case results = "snc-search-results-dark"
    case inspectUnderstand = "snc-search-inspect-understand-dark"
    case ownerHandoff = "snc-search-owner-handoff-dark"
    case noResults = "snc-search-no-results-dark"
    case privacyDegraded = "snc-search-privacy-degraded-dark"
    case accessibilityResults = "snc-search-results-accessibility-dark"

    static var fromProcessArguments: SearchNativeFoundryVariant? {
        let arguments = ProcessInfo.processInfo.arguments
        for flag in ["-FoundryVariant", "-FoundryJourney"] {
            guard
                let flagIndex = arguments.firstIndex(of: flag),
                arguments.indices.contains(flagIndex + 1),
                let variant = SearchNativeFoundryVariant(rawValue: arguments[flagIndex + 1])
            else {
                continue
            }
            return variant
        }
        return nil
    }

    var dynamicTypeSize: DynamicTypeSize {
        self == .accessibilityResults ? .accessibility2 : .large
    }
}

struct SearchNativeFoundryHost: View {
    private let fixture = SearchNativeCalibrationFixture.flagship
    @State private var state = SearchNativeCalibrationJourneyState()
    @State private var didActivateVariant = false

    let variant: SearchNativeFoundryVariant

    var body: some View {
        SearchNativeCalibrationView(
            fixture: fixture,
            state: $state
        )
        .preferredColorScheme(.dark)
        .dynamicTypeSize(variant.dynamicTypeSize)
        .environment(\.locale, Locale(identifier: "en_US"))
        .environment(\.layoutDirection, LayoutDirection.leftToRight)
        .task {
            await activateVariantIfNeeded()
        }
    }

    @MainActor
    private func activateVariantIfNeeded() async {
        guard didActivateVariant == false else { return }
        didActivateVariant = true

        switch variant {
        case .origin:
            return
        case .entryFocused:
            _ = state.presentSearch()
        case .results, .accessibilityResults:
            _ = state.presentSearch(
                query: SearchNativeCalibrationFixture.representativeQuery
            )
        case .inspectUnderstand:
            _ = state.presentSearch(
                query: SearchNativeCalibrationFixture.representativeQuery
            )
            await allowPresentationToSettle()
            _ = state.openInspect(resultID: "event.dentist-appointment")
        case .ownerHandoff:
            _ = state.presentSearch(
                query: SearchNativeCalibrationFixture.actionQuery
            )
            await allowPresentationToSettle()
            _ = state.openOwnerHandoff()
        case .noResults:
            _ = state.presentSearch(
                query: SearchNativeCalibrationFixture.noResultsQuery
            )
        case .privacyDegraded:
            _ = state.presentSearch(
                query: SearchNativeCalibrationFixture.privacyQuery
            )
        }
    }

    @MainActor
    private func allowPresentationToSettle() async {
        try? await Task.sleep(for: .milliseconds(500))
    }
}
