import AmbitionsNativeVisualFoundry
import SwiftUI

enum GoalsNativeFoundryVariant: String {
    case rootLight = "gnc-f01"
    case rootDark = "gnc-f02"
    case selectedGoal = "gnc-f03"
    case linkedGoalLens = "gnc-f04"
    case focusedGoal = "gnc-f05"
    case consequentialRelationship = "gnc-f06"

    static var fromProcessArguments: GoalsNativeFoundryVariant? {
        let arguments = ProcessInfo.processInfo.arguments
        for flag in ["-FoundryVariant", "-FoundryJourney"] {
            guard
                let flagIndex = arguments.firstIndex(of: flag),
                arguments.indices.contains(flagIndex + 1),
                let variant = GoalsNativeFoundryVariant(rawValue: arguments[flagIndex + 1])
            else {
                continue
            }
            return variant
        }
        return nil
    }

    var colorScheme: ColorScheme {
        self == .rootLight ? .light : .dark
    }

    var lensExpanded: Bool {
        switch self {
        case .linkedGoalLens, .focusedGoal, .consequentialRelationship:
            true
        default:
            false
        }
    }

    var opensFocusedGoal: Bool {
        self == .focusedGoal || self == .consequentialRelationship
    }

    var opensRelationship: Bool {
        self == .consequentialRelationship
    }
}

struct GoalsNativeFoundryHost: View {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby
    @State private var state: GoalsNativeCalibrationJourneyState

    let variant: GoalsNativeFoundryVariant

    init(variant: GoalsNativeFoundryVariant) {
        self.variant = variant
        var initialState = GoalsNativeCalibrationJourneyState(
            content: GoalsNativeCalibrationFixture.preparingForBaby,
            lensExpanded: variant.lensExpanded
        )
        if variant.opensFocusedGoal {
            _ = initialState.openSelectedGoal()
        }
        if variant.opensRelationship {
            _ = initialState.openRelationship()
        }
        _state = State(
            initialValue: initialState
        )
    }

    var body: some View {
        GoalsNativeCalibrationView(content: content, state: $state)
            .preferredColorScheme(variant.colorScheme)
            .dynamicTypeSize(.large)
    }
}
