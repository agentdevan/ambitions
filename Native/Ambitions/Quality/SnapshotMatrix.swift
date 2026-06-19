import Foundation

enum SnapshotMatrix {
    static let requiredStates = ScenarioCatalog.requiredSurfaceStates
    static let requiredAccessibilityModes = ScenarioCatalog.requiredAccessibilityModes
    static let requiredDeviceContexts = ScenarioCatalog.requiredDeviceContexts

    static func validationIssues() -> [String] {
        ScenarioMatrix.validate().map(\.message)
    }
}

