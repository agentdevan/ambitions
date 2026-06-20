import Foundation

extension ScreenContractRegistry {
    static let oneStepGoalDetail = ScreenContract(
        id: .oneStepGoalDetail,
        dominantQuestion: "What one-step outcome should happen?",
        requiredFirstScreenContent: ["Task identity", "Category", "Time", "Reminder", "Proof", "History"],
        requiredPanels: [.oneStepGoals, .receipt, .trust],
        optionalPanels: [.recovery, .schedule],
        forbiddenFirstScreenContent: ["Goal-only overload", "Top-level Tasks tab"],
        primaryActions: [.complete, .schedule, .attach, .promoteTask],
        drillDowns: ["Goal attach", "Plan", "Proof", "Review"],
        densityBehavior: "Detailed shows history after action.",
        panelSizeBehavior: "Compact keeps one primary action.",
        accessibilityRequirements: ["Must not require swipe.", "VoiceOver names task state and next available action."],
        trustPrivacyRequirements: ["Promotion and demotion create receipt metadata.", "Private Tasks can hide details."],
        dependencies: [.d04PanelDensitySize, .d05ReceiptsActionClosure, .d07LifeAreasAtlas, .d09OneStepGoals],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .foundationReady,
        owningBatch: "D14",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceFoundation, path: "Native/Ambitions/Domain/OneStepGoalModels.swift", note: "One-Step Goal foundation"),
            .init(kind: .sourceService, path: "Native/Ambitions/Services/OneStepGoalProjector.swift", note: "One-Step Goal projector"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Services/OneStepGoalProjectorTests.swift", note: "One-Step Goal projector tests")
        ]
    )

    static let review = ScreenContract(
        id: .review,
        dominantQuestion: "What changed, and what follows?",
        requiredFirstScreenContent: ["Recovery Review", "Life OS Receipt summary", "Carry-forward guidance"],
        requiredPanels: [.review, .receipt, .proofRail],
        optionalPanels: [.insight, .timeline],
        forbiddenFirstScreenContent: ["Shame language", "Score-only analytics"],
        primaryActions: [.accept, .correct, .carryForward, .openPlan],
        drillDowns: ["Goal Review", "Memory Review", "Correction Review"],
        densityBehavior: "Detailed supports chosen review.",
        panelSizeBehavior: "Large focuses one review narrative.",
        accessibilityRequirements: ["Consistent help.", "Reduced redundant entry."],
        trustPrivacyRequirements: ["Receipts hide sensitive details by default."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .plannedSurface,
        owningBatch: "M09",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceFoundation, path: "Native/Ambitions/Domain/ReviewsModels.swift", note: "Review foundation"),
            .init(kind: .sourceService, path: "Native/Ambitions/Services/ReviewsV1Projector.swift", note: "Review projector"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Services/ReviewsV1ProjectorTests.swift", note: "Review projector tests")
        ]
    )

    static let trustCenter = ScreenContract(
        id: .trustCenter,
        dominantQuestion: "Can I understand and control this?",
        requiredFirstScreenContent: ["Trust status", "Explanation routes", "Correction routes", "Privacy truth", "Export truth", "Sync truth"],
        requiredPanels: [.trust, .receipt, .groupedNavigationList],
        optionalPanels: [.statusNavigationRows],
        forbiddenFirstScreenContent: ["Marketing claims", "Raw debug logs"],
        primaryActions: [.inspect, .correct, .export],
        drillDowns: ["What Ambitions Knows", "Receipts", "Sync / Export"],
        densityBehavior: "Detailed only after route selection.",
        panelSizeBehavior: "Compact preserves row targets.",
        accessibilityRequirements: ["VoiceOver values name status.", "Controls have clear labels and hints."],
        trustPrivacyRequirements: ["Local-first and unavailable states explicit.", "Sensitive receipts collapsed."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .activeSurface,
        owningBatch: "D18",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceSurface, path: "Native/Ambitions/Surfaces/You/YouScreen.swift", note: "Current You-hosted trust entry"),
            .init(kind: .sourceService, path: "Native/Ambitions/Projection/SurfaceLenses/YouFeatureService.swift", note: "Trust projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/You/YouFeatureServiceTests.swift", note: "Trust and profile tests")
        ]
    )

    static let whatAmbitionsKnows = ScreenContract(
        id: .whatAmbitionsKnows,
        dominantQuestion: "What does Ambitions remember?",
        requiredFirstScreenContent: ["Memory categories", "Freshness labels", "Correction controls", "Delete controls"],
        requiredPanels: [.trust, .receipt, .groupedNavigationList],
        optionalPanels: [.timeline],
        forbiddenFirstScreenContent: ["Silent deletion", "Model terminology"],
        primaryActions: [.updatePreference, .correct, .delete, .restore],
        drillDowns: ["Memory item", "Receipts"],
        densityBehavior: "Detailed on selected memory.",
        panelSizeBehavior: "Large shows fewer memory groups.",
        accessibilityRequirements: ["Destructive controls require confirmation.", "Memory rows expose status values."],
        trustPrivacyRequirements: ["Current / May Need Review / Based on Older Context.", "No sensitive inference without confirmation."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .activeSurface,
        owningBatch: "D19",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceService, path: "Native/Ambitions/Services/MemoryLensService.swift", note: "Memory lens foundation"),
            .init(kind: .sourceSurface, path: "Native/Ambitions/Surfaces/You/YouScreen.swift", note: "Current You-hosted memory entry"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/You/YouFeatureServiceTests.swift", note: "Memory and You tests")
        ]
    )

    static let archive = ScreenContract(
        id: .archive,
        dominantQuestion: "What is preserved for learning?",
        requiredFirstScreenContent: ["Completed learning artifacts", "Parked learning artifacts", "Cancelled learning artifacts", "Dropped learning artifacts"],
        requiredPanels: [.timeline, .receipt, .proofRail],
        optionalPanels: [.review],
        forbiddenFirstScreenContent: ["Trash-bin framing"],
        primaryActions: [.restore, .inspect, .export],
        drillDowns: ["Goal archive", "Receipts"],
        densityBehavior: "Detailed because historical.",
        panelSizeBehavior: "Compact uses grouped states.",
        accessibilityRequirements: ["Search and filters must be accessible."],
        trustPrivacyRequirements: ["Privacy-sensitive receipts collapsed."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .plannedSurface,
        owningBatch: "M09",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceFoundation, path: "Native/Ambitions/Domain/ActionClosureReceiptModels.swift", note: "Receipt and archive metadata foundation"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Domain/ActionClosureReceiptModelsTests.swift", note: "Receipt tests")
        ]
    )

    static let externalSurfaces = ScreenContract(
        id: .externalSurfaces,
        dominantQuestion: "What can leave the app safely?",
        requiredFirstScreenContent: ["Shared snapshot privacy defaults", "Stale state", "Sensitive detail hiding", "Linked route fallback", "Receipt boundary"],
        requiredPanels: [.trust, .receipt, .continuityRibbon],
        optionalPanels: [.statusNavigationRows],
        forbiddenFirstScreenContent: ["Production readiness claim", "Sensitive lock-screen detail by default", "Duplicate command logic"],
        primaryActions: [.start, .move, .park, .markDone, .openPlan],
        drillDowns: ["Canonical destination", "Owning tab fallback"],
        densityBehavior: "External snapshots stay lightweight and family-specific.",
        panelSizeBehavior: "Platform families choose concise snapshot shapes.",
        accessibilityRequirements: ["Concise spoken summaries.", "Clear action names.", "No sensitive speech by default."],
        trustPrivacyRequirements: ["Details hidden by default.", "Stale and unavailable states explicit.", "Destructive or external effects require confirmation."],
        dependencies: [.d05ReceiptsActionClosure],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .contractOnly,
        owningBatch: "D22",
        evidenceAnchors: [
            screenMatrixAnchor,
            externalContractAnchor,
            .init(kind: .sourceFoundation, path: "Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift", note: "External snapshot contracts"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift", note: "External payload tests")
        ]
    )
}
