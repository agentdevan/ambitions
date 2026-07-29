import AmbitionsNativeVisualFoundry
import SwiftUI

enum GoalsNativeFoundryVariant: String {
    case rootLight = "gnc-f01"
    case rootDark = "gnc-f02"
    case selectedGoal = "gnc-f03"
    case linkedGoalLens = "gnc-f04"
    case focusedGoal = "gnc-f05"
    case consequentialRelationship = "gnc-f06"
    case goalPath = "gnc-f07"
    case accessibilityRoot = "gnc-f08"
    case synthesisRootDark = "gnc-synthesis-root-dark"
    case synthesisRootLight = "gnc-synthesis-root-light"
    case synthesisHomeDark = "gnc-synthesis-home-dark"
    case synthesisHomeLight = "gnc-synthesis-home-light"
    case synthesisFocusedDark = "gnc-synthesis-focused-dark"
    case synthesisFocusedLight = "gnc-synthesis-focused-light"
    case synthesisFocusedAccessibility = "gnc-synthesis-focused-accessibility"
    case synthesisFocusedReduceMotion = "gnc-synthesis-focused-reduce-motion"
    case synthesisRootReduceTransparency = "gnc-synthesis-root-reduce-transparency"

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
        switch self {
        case .rootLight, .synthesisRootLight, .synthesisHomeLight, .synthesisFocusedLight:
            .light
        default:
            .dark
        }
    }

    var lensExpanded: Bool {
        self == .linkedGoalLens
    }

    var opensHome: Bool {
        switch self {
        case .selectedGoal, .linkedGoalLens, .focusedGoal, .consequentialRelationship, .goalPath,
             .synthesisHomeDark, .synthesisHomeLight, .synthesisFocusedDark,
             .synthesisFocusedLight, .synthesisFocusedAccessibility, .synthesisFocusedReduceMotion:
            true
        default:
            false
        }
    }

    var opensFocusedGoal: Bool {
        switch self {
        case .focusedGoal, .consequentialRelationship, .goalPath, .synthesisFocusedDark,
             .synthesisFocusedLight, .synthesisFocusedAccessibility, .synthesisFocusedReduceMotion:
            true
        default:
            false
        }
    }

    var opensRelationship: Bool {
        self == .consequentialRelationship
    }

    var opensGoalPath: Bool {
        self == .goalPath
    }

    var dynamicTypeSize: DynamicTypeSize {
        self == .accessibilityRoot || self == .synthesisFocusedAccessibility
            ? .accessibility2
            : .large
    }

    var reducesMotion: Bool {
        self == .synthesisFocusedReduceMotion
    }

    var reducesTransparency: Bool {
        self == .synthesisRootReduceTransparency
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
        if variant.opensHome {
            _ = initialState.openLifeArea(id: "life-area.home")
        }
        if variant.opensFocusedGoal {
            _ = initialState.openSelectedGoal()
        }
        if variant.opensRelationship {
            _ = initialState.openRelationship()
        }
        if variant.opensGoalPath {
            _ = initialState.openGoalPath()
        }
        _state = State(
            initialValue: initialState
        )
    }

    var body: some View {
        GoalsNativeCalibrationView(content: content, state: $state)
            .preferredColorScheme(variant.colorScheme)
            .dynamicTypeSize(variant.dynamicTypeSize)
            .goalsNativeCalibrationAccessibilityOverrides(
                reduceMotion: variant.reducesMotion,
                reduceTransparency: variant.reducesTransparency
            )
    }
}
