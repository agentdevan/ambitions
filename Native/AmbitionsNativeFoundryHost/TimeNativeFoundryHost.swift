import AmbitionsNativeVisualFoundry
import SwiftUI

enum TimeNativeFoundryVariant: String {
    case weekRoot = "tnc-d07-week-root-dark"
    case focusedWednesday = "tnc-d07-focused-wednesday"
    case objectDetail = "tnc-d07-object-detail"
    case conflictReview = "tnc-d07-conflict-review"
    case accessibilityChronology = "tnc-d07-accessibility-chronology"

    static var fromProcessArguments: TimeNativeFoundryVariant? {
        let arguments = ProcessInfo.processInfo.arguments
        for flag in ["-FoundryVariant", "-FoundryJourney"] {
            guard
                let flagIndex = arguments.firstIndex(of: flag),
                arguments.indices.contains(flagIndex + 1),
                let variant = TimeNativeFoundryVariant(rawValue: arguments[flagIndex + 1])
            else {
                continue
            }
            return variant
        }
        return nil
    }

    var dynamicTypeSize: DynamicTypeSize {
        self == .accessibilityChronology ? .accessibility2 : .large
    }
}

struct TimeNativeFoundryHost: View {
    private let fixture = TimeNativeCalibrationFixture.flagship
    @State private var state: TimeNativeCalibrationJourneyState

    let variant: TimeNativeFoundryVariant

    init(variant: TimeNativeFoundryVariant) {
        self.variant = variant
        var initialState = TimeNativeCalibrationJourneyState(
            fixture: TimeNativeCalibrationFixture.flagship
        )
        switch variant {
        case .weekRoot, .accessibilityChronology:
            break
        case .focusedWednesday:
            _ = initialState.openFocusedDay()
        case .objectDetail:
            _ = initialState.presentObject(id: "placement.send-launch-brief.wed-1400")
        case .conflictReview:
            _ = initialState.openConflictReview(
                proposalID: "proposal.launch-review.wed-1745"
            )
        }
        _state = State(initialValue: initialState)
    }

    var body: some View {
        TimeNativeCalibrationView(
            fixture: fixture,
            state: $state
        )
        .preferredColorScheme(.dark)
        .dynamicTypeSize(variant.dynamicTypeSize)
        .environment(\.locale, Locale(identifier: "en_US"))
    }
}
