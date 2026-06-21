import Foundation

struct RealDeviceRenderChecklistItem: Identifiable, Sendable, Equatable {
    enum Requirement: String, CaseIterable, Sendable {
        case physicalDeviceRun
        case screenshotMatrix
        case dynamicType
        case reduceMotion
        case reduceTransparency
        case increaseContrast
        case voiceOver
        case performanceBudget
        case proofHonesty
    }

    let requirement: Requirement
    let owner: String
    let validationCommand: String
    let proofRequirement: String
    let blocksGreen: Bool

    var id: String {
        requirement.rawValue
    }
}

enum RealDeviceRenderChecklist {
    static let validationCommand = ShellPreviewMatrix.screenshotHook.uiTestName
    static let proofDirectory = ShellPreviewMatrix.screenshotHook.proofDirectory
    static let visualRegressionCommand = VisualRegressionHarness.screenshotCommand

    static let items: [RealDeviceRenderChecklistItem] = [
        item(.physicalDeviceRun, owner: "Quality/RealDeviceRenderChecklist", proof: "Record physical-device launch and visual review before public render claims."),
        item(.screenshotMatrix, owner: "Quality/VisualRegressionHarness", proof: VisualRegressionHarness.requiredReview),
        item(.dynamicType, owner: "DesignSystem/Accessibility/DynamicTypePolicy", proof: "Review primary object and action at Dynamic Type accessibility sizes."),
        item(.reduceMotion, owner: "DesignSystem/Accessibility/ReduceMotionPolicy", proof: "Review the same mutation with reduced motion enabled."),
        item(.reduceTransparency, owner: "DesignSystem/Accessibility/ReduceTransparencyPolicy", proof: "Review solid-material fallbacks and trust seams."),
        item(.increaseContrast, owner: "DesignSystem/Accessibility/ContrastPolicy", proof: "Review non-color meaning and contrast floors."),
        item(.voiceOver, owner: "DesignSystem/Accessibility/VoiceOverFocusPolicy", proof: "Record VoiceOver order, focus restoration, and mutation announcement."),
        item(.performanceBudget, owner: "Quality/PerformanceBudgets", proof: "Confirm surface render and first interaction budgets."),
        item(.proofHonesty, owner: "Quality/ReleaseProofHonesty", proof: "Do not claim screenshots, device proof, or accessibility proof until artifacts are reviewed.")
    ]

    static func validationFailures(_ items: [RealDeviceRenderChecklistItem] = items) -> [String] {
        var failures: [String] = []
        let requirements = items.map(\.requirement)

        for required in RealDeviceRenderChecklistItem.Requirement.allCases where requirements.contains(required) == false {
            failures.append("Missing real-device render checklist item: \(required.rawValue).")
        }
        if Set(requirements).count != requirements.count {
            failures.append("Real-device render checklist requirements must be unique.")
        }
        for item in items where item.blocksGreen == false {
            failures.append("\(item.requirement.rawValue) must block Green until proof exists.")
        }
        for item in items where item.validationCommand.isEmpty || item.proofRequirement.isEmpty {
            failures.append("\(item.requirement.rawValue) must include command and proof requirement.")
        }
        if PerformanceBudgets.surfaceRenderBudgetMilliseconds > 16 {
            failures.append("Surface render budget must stay at or below one 60Hz frame.")
        }
        if visualRegressionCommand.isEmpty || proofDirectory.isEmpty {
            failures.append("Visual regression command and proof directory are required.")
        }

        return failures
    }

    private static func item(
        _ requirement: RealDeviceRenderChecklistItem.Requirement,
        owner: String,
        proof: String
    ) -> RealDeviceRenderChecklistItem {
        RealDeviceRenderChecklistItem(
            requirement: requirement,
            owner: owner,
            validationCommand: visualRegressionCommand,
            proofRequirement: proof,
            blocksGreen: true
        )
    }
}
