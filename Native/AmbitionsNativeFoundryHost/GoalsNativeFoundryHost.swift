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
    case r03PathDark = "gnc-r03-path-dark"
    case r03PathEvidence = "gnc-r03-path-evidence"
    case r03PathFuture = "gnc-r03-path-future"
    case r03PathLight = "gnc-r03-path-light"
    case r03Relationship = "gnc-r03-relationship"
    case r03RecoveryEntry = "gnc-r03-recovery-entry"
    case r03Recovery = "gnc-r03-recovery"
    case r03ClosureEntry = "gnc-r03-closure-entry"
    case r03Closure = "gnc-r03-closure"
    case r03ClosureHistory = "gnc-r03-closure-history"
    case r03PathAccessibility = "gnc-r03-path-accessibility"
    case r03RelationshipAccessibility = "gnc-r03-relationship-accessibility"
    case r03PathReduceTransparency = "gnc-r03-path-reduce-transparency"
    case r03RelationshipContrastNoColor = "gnc-r03-relationship-contrast-no-color"
    case r03ReturnedFocused = "gnc-r03-returned-focused"

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
        case .rootLight, .synthesisRootLight, .synthesisHomeLight, .synthesisFocusedLight,
             .r03PathLight:
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
             .synthesisFocusedLight, .synthesisFocusedAccessibility, .synthesisFocusedReduceMotion,
             .r03PathDark, .r03PathEvidence, .r03PathFuture, .r03PathLight,
             .r03Relationship, .r03RecoveryEntry, .r03Recovery,
             .r03ClosureEntry, .r03Closure, .r03ClosureHistory,
             .r03PathAccessibility, .r03RelationshipAccessibility,
             .r03PathReduceTransparency, .r03RelationshipContrastNoColor,
             .r03ReturnedFocused:
            true
        default:
            false
        }
    }

    var opensFocusedGoal: Bool {
        switch self {
        case .focusedGoal, .consequentialRelationship, .goalPath, .synthesisFocusedDark,
             .synthesisFocusedLight, .synthesisFocusedAccessibility, .synthesisFocusedReduceMotion,
             .r03PathDark, .r03PathEvidence, .r03PathFuture, .r03PathLight,
             .r03Relationship, .r03RecoveryEntry, .r03Recovery,
             .r03ClosureEntry, .r03Closure, .r03ClosureHistory,
             .r03PathAccessibility, .r03RelationshipAccessibility,
             .r03PathReduceTransparency, .r03RelationshipContrastNoColor,
             .r03ReturnedFocused:
            true
        default:
            false
        }
    }

    var opensRelationship: Bool {
        switch self {
        case .consequentialRelationship, .r03Relationship, .r03RelationshipAccessibility,
             .r03RelationshipContrastNoColor:
            true
        default:
            false
        }
    }

    var opensGoalPath: Bool {
        switch self {
        case .goalPath, .r03PathDark, .r03PathEvidence, .r03PathFuture, .r03PathLight,
             .r03PathAccessibility, .r03PathReduceTransparency:
            true
        default:
            false
        }
    }

    var dynamicTypeSize: DynamicTypeSize {
        self == .accessibilityRoot || self == .synthesisFocusedAccessibility
            || self == .r03PathAccessibility || self == .r03RelationshipAccessibility
            ? .accessibility2
            : .large
    }

    var reducesMotion: Bool {
        self == .synthesisFocusedReduceMotion
    }

    var reducesTransparency: Bool {
        self == .synthesisRootReduceTransparency || self == .r03PathReduceTransparency
    }

    var differentiateWithoutColor: Bool {
        self == .r03RelationshipContrastNoColor
    }

    var depthEntryMode: GoalsNativeCalibrationDepthEntryMode {
        switch self {
        case .r03RecoveryEntry, .r03Recovery:
            .recovery
        case .r03ClosureEntry, .r03Closure, .r03ClosureHistory:
            .closure
        default:
            .active
        }
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
        if variant == .r03PathEvidence {
            _ = initialState.selectPathNode(id: "pathnode.prime-wall-color")
        } else if variant == .r03PathFuture {
            _ = initialState.selectPathNode(id: "pathnode.assemble-crib")
        } else if variant == .r03Recovery {
            _ = initialState.openRecovery()
        } else if variant == .r03Closure || variant == .r03ClosureHistory {
            _ = initialState.openClosure()
            if variant == .r03ClosureHistory {
                _ = initialState.openClosureHistory()
            }
        }
        _state = State(
            initialValue: initialState
        )
    }

    var body: some View {
        GoalsNativeCalibrationView(
            content: content,
            state: $state,
            depthEntryMode: variant.depthEntryMode
        )
            .preferredColorScheme(variant.colorScheme)
            .dynamicTypeSize(variant.dynamicTypeSize)
            .environment(
                \._accessibilityDifferentiateWithoutColor,
                variant.differentiateWithoutColor
            )
            .goalsNativeCalibrationAccessibilityOverrides(
                reduceMotion: variant.reducesMotion,
                reduceTransparency: variant.reducesTransparency
            )
    }
}
