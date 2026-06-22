import Foundation

enum TimeFieldMutationAction: String, CaseIterable, Sendable, Equatable, Hashable {
    case placeStep
    case protectWindow
    case notUsable
    case needsMoreTime
    case keepClear
    case makeTodayLighter

    var commandKind: AmbitionsCommandKind {
        switch self {
        case .placeStep:
            .placeStepInTime
        case .protectWindow:
            .protectTimeWindow
        case .notUsable, .needsMoreTime, .keepClear, .makeTodayLighter:
            .correctTimeWindow
        }
    }

    var timeMutationKind: TimeMutationActionKind {
        switch self {
        case .placeStep:
            .placeStep
        case .protectWindow:
            .protectWindow
        case .notUsable:
            .notUsable
        case .needsMoreTime:
            .needsMoreTime
        case .keepClear:
            .keepClear
        case .makeTodayLighter:
            .makeTodayLighter
        }
    }

    var title: String {
        switch self {
        case .placeStep:
            "Place Step"
        case .protectWindow:
            "Protect window"
        case .notUsable:
            "Not usable"
        case .needsMoreTime:
            "Needs more time"
        case .keepClear:
            "Keep this clear"
        case .makeTodayLighter:
            "Make today lighter"
        }
    }

    var targetLayer: LifeShapeLayer {
        switch self {
        case .protectWindow, .keepClear:
            .protected
        case .makeTodayLighter:
            .pressure
        case .placeStep, .notUsable, .needsMoreTime:
            .open
        }
    }

    var commandMetadata: [String: String] {
        switch self {
        case .notUsable, .needsMoreTime, .keepClear, .makeTodayLighter:
            ["correctionKind": timeMutationKind.rawValue]
        case .placeStep:
            ["durationMinutes": "15"]
        case .protectWindow:
            [:]
        }
    }
}
