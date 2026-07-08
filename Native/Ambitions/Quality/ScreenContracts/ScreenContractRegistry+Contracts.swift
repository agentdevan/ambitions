import Foundation

extension ScreenContractRegistry {
    static let contracts: [ScreenContract] = [
        today,
        goals,
        goalDetail,
        capture,
        time,
        you,
        lifeAreasOverview,
        northStarDetail,
        oneStepGoalDetail,
        review,
        trustCenter,
        whatAmbitionsKnows,
        archive,
        externalSurfaces
    ]

    static func contract(for id: ScreenContractID) -> ScreenContract {
        guard let contract = contracts.first(where: { $0.id == id }) else {
            preconditionFailure("Missing screen contract for \(id.rawValue)")
        }
        return contract
    }


    static let commonTopLevelGuardrails: [ScreenContractGuardrail] = [
        .noSixthTab,
        .noTopLevelTasksTab,
        .noTopLevelInsightsTab,
        .noTopLevelHabitsTab,
        .noTopLevelCalendarTab,
        .noAIWrapperLanguage,
        .noFakePrecision,
        .noUnverifiedUserFacingClaims,
        .noColorOnlyMeaning,
        .noGestureOnlyNavigation,
        .privacySafeByDefault,
        .localFirstTruthfulState
    ]

    static let screenMatrixAnchor = ScreenContractEvidenceAnchor(
        kind: .designCanon,
        path: "docs/canon/design/screen-contract-matrix.md",
        note: "D10 source matrix"
    )

    static let accessibilityMatrixAnchor = ScreenContractEvidenceAnchor(
        kind: .designCanon,
        path: "docs/canon/design/accessibility-nutrition-screen-matrix.md",
        note: "Screen accessibility evidence requirements"
    )

    static let externalContractAnchor = ScreenContractEvidenceAnchor(
        kind: .externalContract,
        path: "docs/canon/design/external-surfaces-contract.md",
        note: "External surface contract"
    )

    static let today = ScreenContract(
        id: .today,
        dominantQuestion: "What matters now?",
        requiredFirstScreenContent: ["Reality Meridian", "Now Layer", "Today Shape Layer", "Compact timeline", "Relevant One-Step Goals", "Open-window awareness", "Recovery"],
        requiredPanels: [.heroDecision, .nowLayer, .todayPlan, .compactTimeline, .oneStepGoals, .schedule, .recovery],
        optionalPanels: [.insight, .trust, .receipt],
        forbiddenFirstScreenContent: ["Full analytics", "Raw ledger", "Permission prompt", "Standalone Habits"],
        primaryActions: [.start, .move, .parkNotToday, .markDone, .saveTheDay],
        drillDowns: ["Goal Detail", "Time", "Receipt", "Review"],
        densityBehavior: "Minimal shows now and day signal; Balanced shows day plan; Detailed adds evidence.",
        panelSizeBehavior: "Compact keeps one action visible; Large shows fewer larger sections.",
        accessibilityRequirements: ["Dynamic Type must not hide primary action.", "Gestures need buttons.", "VoiceOver summarizes status and next action."],
        trustPrivacyRequirements: ["Calendar labels distinguish source.", "Sensitive details stay compact."],
        dependencies: [.d04PanelDensitySize, .d05ReceiptsActionClosure, .d09OneStepGoals],
        guardrails: commonTopLevelGuardrails + [.noCalendarPromptOutsideTime, .receiptsForMeaningfulChanges],
        implementationStatus: .activeSurface,
        owningBatch: "D11",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceSurface, path: "Native/Ambitions/Surfaces/Today/TodaySurface.swift", note: "Current Today surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService.swift", note: "Today projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Today", note: "Focused Today tests where present")
        ]
    )

    static let goals = ScreenContract(
        id: .goals,
        dominantQuestion: "Where am I headed?",
        requiredFirstScreenContent: ["Your Direction", "Thread Focus", "Goal Lifecycle Rail", "Active goals", "North Stars rail", "Controlled One-Step Goals"],
        requiredPanels: [.progress, .lifeAreas, .oneStepGoals, .goalLifecycleRail, .northStarsRail],
        optionalPanels: [.insight, .proofRail, .continuityRibbon],
        forbiddenFirstScreenContent: ["Standalone task board", "Detached Insights dashboard"],
        primaryActions: [.openGoal, .createGoal, .promoteTask, .reviewParked],
        drillDowns: ["Goal Detail", "Life Areas Overview", "North Star Detail", "Archive"],
        densityBehavior: "Detailed may reveal more goal health; Minimal preserves direction.",
        panelSizeBehavior: "Large emphasizes fewer goals; Compact uses concise rows.",
        accessibilityRequirements: ["Semantic zoom requires list fallback.", "VoiceOver exposes qualitative weather and proof state."],
        trustPrivacyRequirements: ["Proof and weather explain uncertainty.", "Private direction can hide details."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure, .d07LifeAreasAtlas, .d08NorthStars, .d09OneStepGoals],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .activeSurface,
        owningBatch: "D13",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceSurface, path: "Native/Ambitions/Surfaces/Goals/GoalsSurface.swift", note: "Current Goals surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Surfaces/Goals/Projection/GoalsFeatureService.swift", note: "Goals projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Goals", note: "Focused Goals tests")
        ]
    )

    static let goalDetail = ScreenContract(
        id: .goalDetail,
        dominantQuestion: "What is the state of this goal, and what happens next?",
        requiredFirstScreenContent: ["Object identity header", "Goal detail lanes"],
        requiredPanels: [.objectIdentityHeader, .missionControlLanes, .progress, .timeline, .proofRail, .recovery, .trust, .receipt],
        optionalPanels: [.groupedNavigationList],
        forbiddenFirstScreenContent: ["Other-goal dashboard", "Unrelated settings"],
        primaryActions: [.startStep, .addProof, .changePath, .park, .archive],
        drillDowns: ["Overview", "Path", "Steps", "Proof", "Decisions", "Risks", "Archive"],
        densityBehavior: "Detailed allowed because object-scoped.",
        panelSizeBehavior: "Large uses lane focus; Compact uses collapsible signals.",
        accessibilityRequirements: ["VoiceOver must summarize status and next action.", "Lane navigation has visible alternatives."],
        trustPrivacyRequirements: ["Decisions and receipts are searchable.", "Sensitive proof can stay collapsed."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure, .d09OneStepGoals],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .activeSurface,
        owningBatch: "D14",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceSurface, path: "Native/Ambitions/Surfaces/Goals/GoalDetailScreen.swift", note: "Current Goal Detail surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Surfaces/Goals/Projection/GoalsFeatureService.swift", note: "Goal Detail projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift", note: "Goal Detail presentation tests")
        ]
    )

    static let capture = ScreenContract(
        id: .capture,
        dominantQuestion: "What should be held for review?",
        requiredFirstScreenContent: ["Field-first Capture", "Review first", "Ready to place", "Grow into goal", "Changeable route receipt"],
        requiredPanels: [.capture, .smartAttachmentReceipt, .receipt, .trust],
        optionalPanels: [.groupedNavigationList],
        forbiddenFirstScreenContent: ["Chat-first AI surface", "Long inbox as primary"],
        primaryActions: [.save, .attach, .changeRoute, .keepStandalone],
        drillDowns: ["Review first", "Object details", "Route settings"],
        densityBehavior: "Minimal favors input and receipt; Detailed shows suggestions.",
        panelSizeBehavior: "Compact preserves input target; Large avoids stretched empty space.",
        accessibilityRequirements: ["Clarification choices are reachable without typing.", "Input target remains reachable."],
        trustPrivacyRequirements: ["Receipts reveal route and correction.", "Sensitive details hidden by default."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure, .d06SmartAttachment, .d09OneStepGoals],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .composerOverlay,
        owningBatch: "D12",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceComposer, path: "Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift", note: "Composer screen pending Composer/Capture migration"),
            .init(kind: .sourceService, path: "Native/Ambitions/Services/SmartAttachmentService.swift", note: "Smart Attachment foundation"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Capture", note: "Focused Capture tests")
        ]
    )

    static let time = ScreenContract(
        id: .time,
        dominantQuestion: "What can my life actually hold?",
        requiredFirstScreenContent: ["Shape Time", "Life Calendar", "Open time", "Goal time", "Protected time", "Pressure", "Shape week", "Review pressure", "Manual mode"],
        requiredPanels: [.heroDecision, .schedule, .timeline, .weekShapeStrip, .recovery, .trust],
        optionalPanels: [.groupedNavigationList, .insight],
        forbiddenFirstScreenContent: ["Onboarding permission request", "Raw calendar list", "Calendar clone", "Agenda", "Analytics dashboard", "Red warning surface", "Silent scheduler"],
        primaryActions: [.makeCalendarAware, .findWindows, .move, .protect, .saveTheWeek],
        drillDowns: ["Calendar mode", "Rituals", "Review archive", "Receipts"],
        densityBehavior: "Detailed allowed for planning evidence below hero.",
        panelSizeBehavior: "Large focuses one week section; Compact uses timeline ribbon.",
        accessibilityRequirements: ["Life Calendar summarizes open time, goal time, protected time, and pressure.", "Calendar controls have permission rationale.", "Timeline has non-gesture controls."],
        trustPrivacyRequirements: ["Calendar appears only as a Time source or detail.", "External writes require confirmation."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure],
        guardrails: commonTopLevelGuardrails + [.noCalendarPromptOutsideTime, .receiptsForMeaningfulChanges],
        implementationStatus: .activeSurface,
        owningBatch: "D15",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceSurface, path: "Native/Ambitions/Surfaces/Time/TimeSurface.swift", note: "Current Time surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Surfaces/Time/Projection/TimeProjectionService.swift", note: "Time projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Time/TimeProjectionServiceTests.swift", note: "Focused Time tests")
        ]
    )

    static let you = ScreenContract(
        id: .you,
        dominantQuestion: "How does Ambitions work for me?",
        requiredFirstScreenContent: ["Your System", "User System You", "Planning Setup", "Privacy & automation", "Privacy", "Receipts & History", "Defaults", "Grouped Navigation Lists"],
        requiredPanels: [.trust, .review, .settingsPreference, .groupedNavigationList],
        optionalPanels: [.progress, .receipt],
        forbiddenFirstScreenContent: ["Primary execution UI", "Top-level Insights clone", "Social profile", "Admin console", "Account hub", "AI settings wall"],
        primaryActions: [.openSection, .updatePreference, .inspect],
        drillDowns: ["Trust Center", "What Ambitions Knows", "Accessibility", "Sync / Export", "Reviews"],
        densityBehavior: "Detailed allowed in subpages; root stays grouped.",
        panelSizeBehavior: "Large rows remain scannable; Compact uses stable target sizes.",
        accessibilityRequirements: ["Settings and lists support VoiceOver values and hints.", "Rows remain stable under Dynamic Type."],
        trustPrivacyRequirements: ["No unverified accessibility or sync claims.", "Unavailable states remain explicit."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure],
        guardrails: commonTopLevelGuardrails,
        implementationStatus: .activeSurface,
        owningBatch: "D17",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceSurface, path: "Native/Ambitions/Surfaces/You/YouSurface.swift", note: "Current You surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Surfaces/You/Projection/YouFeatureService.swift", note: "You projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/You/YouFeatureServiceTests.swift", note: "Focused You tests")
        ]
    )

    static let lifeAreasOverview = ScreenContract(
        id: .lifeAreasOverview,
        dominantQuestion: "Where does this part of life stand?",
        requiredFirstScreenContent: ["Life Area cards", "North Stars", "Active goals", "Proof signal", "Review signal"],
        requiredPanels: [.lifeAreas, .progress, .proofRail],
        optionalPanels: [.timeline, .insight],
        forbiddenFirstScreenContent: ["Sixth tab behavior"],
        primaryActions: [.openSection, .createGoalOrTask, .inspect],
        drillDowns: ["Life Area detail", "North Star", "Goals"],
        densityBehavior: "Detailed reveals nested objects only on demand.",
        panelSizeBehavior: "Large highlights fewer areas.",
        accessibilityRequirements: ["Semantic map has list fallback.", "Area cards have labels and values."],
        trustPrivacyRequirements: ["Sensitive area names can hide details."],
        dependencies: [.d04PanelDensitySize, .d07LifeAreasAtlas, .d08NorthStars, .d09OneStepGoals],
        guardrails: commonTopLevelGuardrails,
        implementationStatus: .foundationReady,
        owningBatch: "D13",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceFoundation, path: "Native/Ambitions/Core/Domain/LifeAreaModels.swift", note: "Life Areas model foundation"),
            .init(kind: .sourceService, path: "Native/Ambitions/Services/LifeAreaAtlasProjector.swift", note: "Life Areas Atlas projector"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Services/LifeAreaAtlasProjectorTests.swift", note: "Life Areas Atlas tests")
        ]
    )

    static let northStarDetail = ScreenContract(
        id: .northStarDetail,
        dominantQuestion: "What long-range direction is waiting?",
        requiredFirstScreenContent: ["North Star identity", "Dormant relationship", "Active relationship", "Possible goals"],
        requiredPanels: [.progress, .timeline, .trust],
        optionalPanels: [.insight],
        forbiddenFirstScreenContent: ["Forced plan creation"],
        primaryActions: [.promoteTask, .park, .attach],
        drillDowns: ["Goals", "Life Area", "Path"],
        densityBehavior: "Minimal keeps identity; Detailed adds candidate paths.",
        panelSizeBehavior: "Large is narrative, not stretched.",
        accessibilityRequirements: ["VoiceOver distinguishes dormant vs active direction."],
        trustPrivacyRequirements: ["No fake certainty on long-range paths.", "Private North Stars can hide details."],
        dependencies: [.d04PanelDensitySize, .d05ReceiptsActionClosure, .d07LifeAreasAtlas, .d08NorthStars],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .foundationReady,
        owningBatch: "D13",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceFoundation, path: "Native/Ambitions/Core/Domain/NorthStarModels.swift", note: "North Star foundation"),
            .init(kind: .sourceService, path: "Native/Ambitions/Services/NorthStarProjector.swift", note: "North Star projector"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Services/NorthStarProjectorTests.swift", note: "North Star projector tests")
        ]
    )
}
