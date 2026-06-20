import Foundation

struct AppFeatureFlags: Equatable, Sendable {
    let stageOwnsRootShell: Bool
    let captureIsGlobalComposer: Bool
    let motionIsStageBehavior: Bool
    let trustIsInspectableDetail: Bool

    static let current = AppFeatureFlags(
        stageOwnsRootShell: true,
        captureIsGlobalComposer: true,
        motionIsStageBehavior: true,
        trustIsInspectableDetail: true
    )

    var validationIssues: [String] {
        var issues: [String] = []
        if stageOwnsRootShell == false {
            issues.append("Stage must own the root shell.")
        }
        if captureIsGlobalComposer == false {
            issues.append("Capture must remain the global composer.")
        }
        if motionIsStageBehavior == false {
            issues.append("Motion must remain Stage behavior.")
        }
        if trustIsInspectableDetail == false {
            issues.append("Trust must remain inspectable detail.")
        }
        return issues
    }
}
