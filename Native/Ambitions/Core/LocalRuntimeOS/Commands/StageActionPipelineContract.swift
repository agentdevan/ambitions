import Foundation

enum StageActionTaxonomy: String, Codable, Sendable, Equatable, Hashable {
    case shellNavigationOverlay = "shell_navigation_overlay"
    case productRuntime = "product_runtime"
}

enum StageActionPipelineRequirementState: String, Codable, Sendable, Equatable, Hashable {
    case satisfied
    case blocked
    case unavailable
    case notApplicable = "not_applicable"
}

struct StageActionPipelineRequirement: Codable, Sendable, Equatable, Hashable {
    let state: StageActionPipelineRequirementState
    let summary: String

    static func satisfied(_ summary: String) -> StageActionPipelineRequirement {
        StageActionPipelineRequirement(state: .satisfied, summary: summary)
    }

    static func blocked(_ summary: String) -> StageActionPipelineRequirement {
        StageActionPipelineRequirement(state: .blocked, summary: summary)
    }

    static func unavailable(_ summary: String) -> StageActionPipelineRequirement {
        StageActionPipelineRequirement(state: .unavailable, summary: summary)
    }

    static func notApplicable(_ summary: String) -> StageActionPipelineRequirement {
        StageActionPipelineRequirement(state: .notApplicable, summary: summary)
    }
}

struct StageActionPipelineTrace: Codable, Sendable, Equatable, Hashable {
    let inventoryID: String
    let taxonomy: StageActionTaxonomy
    let commandKind: AmbitionsCommandKind?
    let commandValidation: StageActionPipelineRequirement
    let runtimeMutation: StageActionPipelineRequirement
    let shellRouteChange: StageActionPipelineRequirement
    let visibleMutation: StageActionPipelineRequirement
    let proofReceipt: StageActionPipelineRequirement
    let accessibilityAnnouncement: StageActionPipelineRequirement
    let fallbackUndo: StageActionPipelineRequirement
    let scopedFlowIDs: [String]
    let knownIssueIDs: [String]

    var usesPipeline: Bool {
        commandValidation.state != .notApplicable
    }

    var isHonestShellNonRuntime: Bool {
        taxonomy == .shellNavigationOverlay &&
            runtimeMutation.state == .notApplicable &&
            visibleMutation.state == .notApplicable &&
            proofReceipt.state == .notApplicable
    }

    var isProductRuntimeBoundary: Bool {
        taxonomy == .productRuntime &&
            commandKind != nil &&
            shellRouteChange.state == .notApplicable
    }

    static func productRuntime(
        inventoryID: String,
        commandKind: AmbitionsCommandKind,
        commandValidation: StageActionPipelineRequirement,
        runtimeMutation: StageActionPipelineRequirement,
        visibleMutation: StageActionPipelineRequirement,
        proofReceipt: StageActionPipelineRequirement,
        accessibilityAnnouncement: StageActionPipelineRequirement,
        fallbackUndo: StageActionPipelineRequirement,
        scopedFlowIDs: [String],
        knownIssueIDs: [String]
    ) -> StageActionPipelineTrace {
        StageActionPipelineTrace(
            inventoryID: inventoryID,
            taxonomy: .productRuntime,
            commandKind: commandKind,
            commandValidation: commandValidation,
            runtimeMutation: runtimeMutation,
            shellRouteChange: .notApplicable("Product/runtime actions do not complete as shell-only route changes."),
            visibleMutation: visibleMutation,
            proofReceipt: proofReceipt,
            accessibilityAnnouncement: accessibilityAnnouncement,
            fallbackUndo: fallbackUndo,
            scopedFlowIDs: scopedFlowIDs,
            knownIssueIDs: knownIssueIDs
        )
    }

    static func shellNavigationOverlay(
        inventoryID: String,
        commandKind: AmbitionsCommandKind? = .openDestination,
        commandValidation: StageActionPipelineRequirement = .satisfied("Shell route is bounded to navigation or overlay presentation."),
        shellRouteChange: StageActionPipelineRequirement,
        accessibilityAnnouncement: StageActionPipelineRequirement,
        fallbackUndo: StageActionPipelineRequirement,
        scopedFlowIDs: [String],
        knownIssueIDs: [String]
    ) -> StageActionPipelineTrace {
        StageActionPipelineTrace(
            inventoryID: inventoryID,
            taxonomy: .shellNavigationOverlay,
            commandKind: commandKind,
            commandValidation: commandValidation,
            runtimeMutation: .notApplicable("Shell navigation and overlays do not claim runtime mutation."),
            shellRouteChange: shellRouteChange,
            visibleMutation: .notApplicable("Route presentation is visible shell state, not product/runtime mutation."),
            proofReceipt: .notApplicable("Shell routes may record continuity receipts, but they do not claim mutation proof."),
            accessibilityAnnouncement: accessibilityAnnouncement,
            fallbackUndo: fallbackUndo,
            scopedFlowIDs: scopedFlowIDs,
            knownIssueIDs: knownIssueIDs
        )
    }
}

enum StageActionPipelineInventory {
    static let captureSaveFlowIDs = ["SCG006-F03"]
    static let todayStepFlowIDs = ["SCG006-F07", "SCG006-F08", "SCG006-F09", "SCG006-F14"]
    static let timeHandoffFlowIDs = ["SCG006-F10", "SCG006-F11"]
    static let shellSearchInspectionFlowIDs = ["SCG006-F12", "SCG006-F13"]

    static let captureKnownIssueIDs = [
        "AMB-ISSUE-0003",
        "AMB-ISSUE-0008",
        "AMB-ISSUE-0012",
        "AMB-ISSUE-1101",
        "AMB-ISSUE-1102",
        "AMB-ISSUE-1103",
        "AMB-ISSUE-1104",
        "AMB-ISSUE-1105",
        "AMB-ISSUE-1106",
        "AMB-ISSUE-1107",
    ]

    static let todayKnownIssueIDs = [
        "AMB-ISSUE-0004",
        "AMB-ISSUE-0005",
        "AMB-ISSUE-1001",
        "AMB-ISSUE-1002",
        "AMB-ISSUE-1003",
        "AMB-ISSUE-1004",
        "AMB-ISSUE-1005",
        "AMB-ISSUE-1006",
        "AMB-ISSUE-1007",
        "AMB-ISSUE-0014",
        "AMB-ISSUE-0807",
        "AMB-ISSUE-1801",
        "AMB-ISSUE-1802",
    ]

    static let searchInspectionKnownIssueIDs = [
        "AMB-ISSUE-0701",
        "AMB-ISSUE-1601",
        "AMB-ISSUE-1602",
        "AMB-ISSUE-1603",
        "AMB-ISSUE-1604",
        "AMB-ISSUE-1605",
    ]

    static let timeHandoffKnownIssueIDs = [
        "AMB-ISSUE-0009",
        "AMB-ISSUE-0501",
        "AMB-ISSUE-0502",
        "AMB-ISSUE-0503",
        "AMB-ISSUE-0504",
        "AMB-ISSUE-0505",
        "AMB-ISSUE-0506",
        "AMB-ISSUE-0507",
        "AMB-ISSUE-0913",
        "AMB-ISSUE-1401",
        "AMB-ISSUE-1402",
        "AMB-ISSUE-1403",
        "AMB-ISSUE-1404",
    ]
}
