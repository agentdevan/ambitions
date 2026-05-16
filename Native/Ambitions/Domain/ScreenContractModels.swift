import Foundation

enum ScreenContractID: String, CaseIterable, Codable, Hashable, Sendable {
    case today
    case goals
    case goalDetail
    case capture
    case plan
    case you
    case lifeAreasOverview
    case northStarDetail
    case oneStepGoalDetail
    case review
    case trustCenter
    case whatAmbitionsKnows
    case archive
    case externalSurfaces

    var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .goalDetail: "Goal Detail"
        case .capture: "Capture"
        case .plan: "Time"
        case .you: "You"
        case .lifeAreasOverview: "Life Areas Overview"
        case .northStarDetail: "North Star Detail"
        case .oneStepGoalDetail: "Task / One-Step Goal Detail"
        case .review: "Review"
        case .trustCenter: "Trust Center"
        case .whatAmbitionsKnows: "What Ambitions Knows"
        case .archive: "Archive"
        case .externalSurfaces: "External Surfaces"
        }
    }

    var canonicalTopLevelTitle: String? {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .capture: "Capture"
        case .plan: "Time"
        case .you: "You"
        case .goalDetail,
             .lifeAreasOverview,
             .northStarDetail,
             .oneStepGoalDetail,
             .review,
             .trustCenter,
             .whatAmbitionsKnows,
             .archive,
             .externalSurfaces:
            nil
        }
    }
}

enum ScreenContractImplementationStatus: String, Codable, Hashable, Sendable {
    case activeSurface
    case foundationReady
    case plannedSurface
    case contractOnly
}

enum ScreenContractPanel: String, CaseIterable, Codable, Hashable, Sendable {
    case archive
    case capture
    case compactTimeline
    case continuityRibbon
    case goalLifecycleRail
    case groupedNavigationList
    case heroDecision
    case insight
    case lifeAreas
    case missionControlLanes
    case northStarsRail
    case nowLayer
    case objectIdentityHeader
    case oneStepGoals
    case progress
    case proofRail
    case receipt
    case recovery
    case review
    case schedule
    case settingsPreference
    case smartAttachmentReceipt
    case statusNavigationRows
    case timeline
    case todayPlan
    case trust
    case weeklyPlanStrip
}

enum ScreenContractAction: String, CaseIterable, Codable, Hashable, Sendable {
    case accept
    case addProof
    case archive
    case attach
    case carryForward
    case changePath
    case changeRoute
    case complete
    case correct
    case createGoal
    case createGoalOrTask
    case delete
    case export
    case findWindows
    case inspect
    case keepStandalone
    case makeCalendarAware
    case markDone
    case move
    case openGoal
    case openPlan
    case openSection
    case park
    case parkNotToday
    case promoteTask
    case protect
    case reviewParked
    case restore
    case save
    case saveTheDay
    case saveTheWeek
    case schedule
    case start
    case startStep
    case updatePreference
}

enum ScreenContractDependency: String, CaseIterable, Codable, Hashable, Sendable {
    case d03GroupedNavigationList
    case d04PanelDensitySize
    case d05ReceiptsActionClosure
    case d06SmartAttachment
    case d07LifeAreasAtlas
    case d08NorthStars
    case d09OneStepGoals
}

enum ScreenContractGuardrail: String, CaseIterable, Codable, Hashable, Sendable {
    case noSixthTab
    case noTopLevelTasksTab
    case noTopLevelInsightsTab
    case noTopLevelHabitsTab
    case noTopLevelCalendarTab
    case noCalendarPromptOutsidePlan
    case noAIWrapperLanguage
    case noFakePrecision
    case noUnverifiedUserFacingClaims
    case noColorOnlyMeaning
    case noGestureOnlyNavigation
    case privacySafeByDefault
    case receiptsForMeaningfulChanges
    case localFirstTruthfulState
}

enum ScreenContractEvidenceKind: String, Codable, Hashable, Sendable {
    case designCanon
    case sourceSurface
    case sourceFoundation
    case sourceService
    case testCoverage
    case externalContract
}

struct ScreenContractEvidenceAnchor: Codable, Hashable, Sendable {
    let kind: ScreenContractEvidenceKind
    let path: String
    let note: String
}

struct ScreenContract: Identifiable, Codable, Hashable, Sendable {
    let id: ScreenContractID
    let dominantQuestion: String
    let requiredFirstScreenContent: [String]
    let requiredPanels: [ScreenContractPanel]
    let optionalPanels: [ScreenContractPanel]
    let forbiddenFirstScreenContent: [String]
    let primaryActions: [ScreenContractAction]
    let drillDowns: [String]
    let densityBehavior: String
    let panelSizeBehavior: String
    let accessibilityRequirements: [String]
    let trustPrivacyRequirements: [String]
    let dependencies: [ScreenContractDependency]
    let guardrails: [ScreenContractGuardrail]
    let implementationStatus: ScreenContractImplementationStatus
    let owningBatch: String
    let evidenceAnchors: [ScreenContractEvidenceAnchor]

    var title: String { id.title }
    var canonicalTopLevelTitle: String? { id.canonicalTopLevelTitle }
}

struct ScreenContractImplementationSnapshot: Codable, Hashable, Sendable {
    let screenID: ScreenContractID
    var firstScreenContent: [String]
    var panels: [ScreenContractPanel]
    var actions: [ScreenContractAction]
    var drillDowns: [String]
    var copySamples: [String]
    var topLevelTabTitles: [String]
    var supportsDensityBehavior: Bool
    var supportsPanelSizeBehavior: Bool
    var hasAccessibilitySummary: Bool
    var hasPrivacySafeState: Bool
    var hasGestureAlternative: Bool

    init(
        screenID: ScreenContractID,
        firstScreenContent: [String] = [],
        panels: [ScreenContractPanel] = [],
        actions: [ScreenContractAction] = [],
        drillDowns: [String] = [],
        copySamples: [String] = [],
        topLevelTabTitles: [String] = [],
        supportsDensityBehavior: Bool = false,
        supportsPanelSizeBehavior: Bool = false,
        hasAccessibilitySummary: Bool = false,
        hasPrivacySafeState: Bool = false,
        hasGestureAlternative: Bool = false
    ) {
        self.screenID = screenID
        self.firstScreenContent = firstScreenContent
        self.panels = panels
        self.actions = actions
        self.drillDowns = drillDowns
        self.copySamples = copySamples
        self.topLevelTabTitles = topLevelTabTitles
        self.supportsDensityBehavior = supportsDensityBehavior
        self.supportsPanelSizeBehavior = supportsPanelSizeBehavior
        self.hasAccessibilitySummary = hasAccessibilitySummary
        self.hasPrivacySafeState = hasPrivacySafeState
        self.hasGestureAlternative = hasGestureAlternative
    }
}

enum ScreenContractValidationIssueKind: String, Codable, Hashable, Sendable {
    case missingFirstScreenContent
    case missingRequiredPanel
    case missingPrimaryAction
    case forbiddenFirstScreenContent
    case forbiddenCopy
    case invalidTopLevelTabs
    case missingDensityBehavior
    case missingPanelSizeBehavior
    case missingAccessibilitySummary
    case missingPrivacySafeState
    case missingGestureAlternative
}

struct ScreenContractValidationIssue: Codable, Hashable, Sendable {
    let screenID: ScreenContractID
    let kind: ScreenContractValidationIssueKind
    let requirement: String
    let message: String
}

enum ScreenContractValidator {
    static let canonicalTopLevelTabs = ["Today", "Goals", "Capture", "Time", "You"]

    static let forbiddenTopLevelTabTitles = [
        "Tasks",
        "Insights",
        "Habits",
        "Calendar",
        "You"
    ]

    static let forbiddenCopyFragments = [
        "AI Confidence",
        "AI Explanation",
        "Model Reasoning",
        "Confidence score",
        "Fix AI",
        "Mission Control",
        "User System You",
        "Action Closure",
        "Proof Rail",
        "Believability hero",
        "Low score",
        "You are behind",
        "Neglected",
        "Unoptimized",
        "Failed"
    ]

    static func validate(
        snapshot: ScreenContractImplementationSnapshot,
        against contract: ScreenContract
    ) -> [ScreenContractValidationIssue] {
        var issues: [ScreenContractValidationIssue] = []

        for content in contract.requiredFirstScreenContent {
            if !snapshot.firstScreenContent.contains(where: { matches($0, content) }) {
                issues.append(issue(.missingFirstScreenContent, contract.id, content, "First-screen content is missing."))
            }
        }

        let snapshotPanels = Set(snapshot.panels)
        for panel in contract.requiredPanels where !snapshotPanels.contains(panel) {
            issues.append(issue(.missingRequiredPanel, contract.id, panel.rawValue, "Required panel is missing."))
        }

        let snapshotActions = Set(snapshot.actions)
        for action in contract.primaryActions where !snapshotActions.contains(action) {
            issues.append(issue(.missingPrimaryAction, contract.id, action.rawValue, "Primary action is missing."))
        }

        let textSamples = snapshot.firstScreenContent + snapshot.copySamples
        for forbidden in contract.forbiddenFirstScreenContent {
            if textSamples.contains(where: { contains($0, forbidden) }) {
                issues.append(issue(.forbiddenFirstScreenContent, contract.id, forbidden, "Forbidden first-screen content is present."))
            }
        }

        for forbidden in forbiddenCopyFragments {
            if textSamples.contains(where: { contains($0, forbidden) }) {
                issues.append(issue(.forbiddenCopy, contract.id, forbidden, "Forbidden copy fragment is present."))
            }
        }

        if !snapshot.topLevelTabTitles.isEmpty {
            if snapshot.topLevelTabTitles != canonicalTopLevelTabs ||
                snapshot.topLevelTabTitles.contains(where: { forbiddenTopLevelTabTitles.contains($0) }) {
                issues.append(issue(.invalidTopLevelTabs, contract.id, snapshot.topLevelTabTitles.joined(separator: ", "), "Top-level tabs must remain Today, Goals, Capture, Time, You."))
            }
        }

        if !snapshot.supportsDensityBehavior {
            issues.append(issue(.missingDensityBehavior, contract.id, contract.densityBehavior, "Density behavior is not represented."))
        }

        if !snapshot.supportsPanelSizeBehavior {
            issues.append(issue(.missingPanelSizeBehavior, contract.id, contract.panelSizeBehavior, "Panel size behavior is not represented."))
        }

        if !snapshot.hasAccessibilitySummary {
            issues.append(issue(.missingAccessibilitySummary, contract.id, contract.accessibilityRequirements.joined(separator: " | "), "Accessibility summary is missing."))
        }

        if !snapshot.hasPrivacySafeState {
            issues.append(issue(.missingPrivacySafeState, contract.id, contract.trustPrivacyRequirements.joined(separator: " | "), "Privacy-safe state is missing."))
        }

        if !snapshot.hasGestureAlternative {
            issues.append(issue(.missingGestureAlternative, contract.id, ScreenContractGuardrail.noGestureOnlyNavigation.rawValue, "Visible gesture alternative is missing."))
        }

        return issues
    }

    static func validateRegistry(_ contracts: [ScreenContract]) -> [ScreenContractValidationIssue] {
        let topLevelTitles = contracts.compactMap(\.canonicalTopLevelTitle)
        guard topLevelTitles != canonicalTopLevelTabs else { return [] }

        return [
            issue(
                .invalidTopLevelTabs,
                .today,
                topLevelTitles.joined(separator: ", "),
                "Contract registry top-level screens must remain Today, Goals, Capture, Time, You."
            )
        ]
    }

    private static func issue(
        _ kind: ScreenContractValidationIssueKind,
        _ screenID: ScreenContractID,
        _ requirement: String,
        _ message: String
    ) -> ScreenContractValidationIssue {
        ScreenContractValidationIssue(
            screenID: screenID,
            kind: kind,
            requirement: requirement,
            message: message
        )
    }

    private static func matches(_ candidate: String, _ requirement: String) -> Bool {
        candidate.compare(requirement, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
    }

    private static func contains(_ candidate: String, _ fragment: String) -> Bool {
        candidate.range(of: fragment, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}

enum ScreenContractRegistry {
    static let contracts: [ScreenContract] = [
        today,
        goals,
        goalDetail,
        capture,
        plan,
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

    private static let commonTopLevelGuardrails: [ScreenContractGuardrail] = [
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

    private static let screenMatrixAnchor = ScreenContractEvidenceAnchor(
        kind: .designCanon,
        path: "docs/canon/design/screen-contract-matrix.md",
        note: "D10 source matrix"
    )

    private static let accessibilityMatrixAnchor = ScreenContractEvidenceAnchor(
        kind: .designCanon,
        path: "docs/canon/design/accessibility-nutrition-screen-matrix.md",
        note: "Screen accessibility evidence requirements"
    )

    private static let externalContractAnchor = ScreenContractEvidenceAnchor(
        kind: .externalContract,
        path: "docs/canon/design/external-surfaces-contract.md",
        note: "External surface contract"
    )

    private static let today = ScreenContract(
        id: .today,
        dominantQuestion: "What matters now?",
        requiredFirstScreenContent: ["Reality Meridian", "Now Layer", "Today Plan Layer", "Compact timeline", "Relevant One-Step Goals", "Open-window awareness", "Recovery"],
        requiredPanels: [.heroDecision, .nowLayer, .todayPlan, .compactTimeline, .oneStepGoals, .schedule, .recovery],
        optionalPanels: [.insight, .trust, .receipt],
        forbiddenFirstScreenContent: ["Full analytics", "Raw ledger", "Permission prompt", "Standalone Habits"],
        primaryActions: [.start, .move, .parkNotToday, .markDone, .saveTheDay],
        drillDowns: ["Goal Detail", "Plan", "Receipt", "Review"],
        densityBehavior: "Minimal shows now and day signal; Balanced shows day plan; Detailed adds evidence.",
        panelSizeBehavior: "Compact keeps one action visible; Large shows fewer larger sections.",
        accessibilityRequirements: ["Dynamic Type must not hide primary action.", "Gestures need buttons.", "VoiceOver summarizes status and next action."],
        trustPrivacyRequirements: ["Calendar labels distinguish source.", "Sensitive details stay compact."],
        dependencies: [.d04PanelDensitySize, .d05ReceiptsActionClosure, .d09OneStepGoals],
        guardrails: commonTopLevelGuardrails + [.noCalendarPromptOutsidePlan, .receiptsForMeaningfulChanges],
        implementationStatus: .activeSurface,
        owningBatch: "D11",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceSurface, path: "Native/Ambitions/Features/Today/TodayScreen.swift", note: "Current Today surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Features/Today/TodayFeatureService.swift", note: "Today projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Today", note: "Focused Today tests where present")
        ]
    )

    private static let goals = ScreenContract(
        id: .goals,
        dominantQuestion: "Where am I headed?",
        requiredFirstScreenContent: ["Your Direction", "Constellation Atlas", "Orbital Lens", "Goal Lifecycle Rail", "Active goals", "North Stars rail", "Controlled One-Step Goals"],
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
            .init(kind: .sourceSurface, path: "Native/Ambitions/Features/Goals/GoalsScreen.swift", note: "Current Goals surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Features/Goals/GoalsFeatureService.swift", note: "Goals projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Goals", note: "Focused Goals tests")
        ]
    )

    private static let goalDetail = ScreenContract(
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
            .init(kind: .sourceSurface, path: "Native/Ambitions/Features/Goals/GoalDetailScreen.swift", note: "Current Goal Detail surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Features/Goals/GoalsFeatureService.swift", note: "Goal Detail projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift", note: "Goal Detail presentation tests")
        ]
    )

    private static let capture = ScreenContract(
        id: .capture,
        dominantQuestion: "What needs a place?",
        requiredFirstScreenContent: ["Capture Anything", "Atmosphere Composer", "Needs a Place", "Ready to Place", "Grow into Goal", "Changeable route receipt"],
        requiredPanels: [.capture, .smartAttachmentReceipt, .receipt, .trust],
        optionalPanels: [.groupedNavigationList],
        forbiddenFirstScreenContent: ["Chat-first AI surface", "Long inbox as primary"],
        primaryActions: [.save, .attach, .changeRoute, .keepStandalone],
        drillDowns: ["Needs a Place", "Object details", "Route settings"],
        densityBehavior: "Minimal favors input and receipt; Detailed shows suggestions.",
        panelSizeBehavior: "Compact preserves input target; Large avoids stretched empty space.",
        accessibilityRequirements: ["Clarification choices are reachable without typing.", "Input target remains reachable."],
        trustPrivacyRequirements: ["Receipts reveal route and correction.", "Sensitive details hidden by default."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure, .d06SmartAttachment, .d09OneStepGoals],
        guardrails: commonTopLevelGuardrails + [.receiptsForMeaningfulChanges],
        implementationStatus: .activeSurface,
        owningBatch: "D12",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceSurface, path: "Native/Ambitions/Features/Captures/CapturesScreen.swift", note: "Current Capture surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Services/SmartAttachmentService.swift", note: "Smart Attachment foundation"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Captures", note: "Focused Capture tests")
        ]
    )

    private static let plan = ScreenContract(
        id: .plan,
        dominantQuestion: "What can my life actually hold?",
        requiredFirstScreenContent: ["Shape Time", "LifeShape Field", "Open time", "Goal time", "Protected time", "Pressure", "Shape week", "Review pressure", "Manual mode"],
        requiredPanels: [.heroDecision, .schedule, .timeline, .weeklyPlanStrip, .recovery, .trust],
        optionalPanels: [.groupedNavigationList, .insight],
        forbiddenFirstScreenContent: ["Onboarding permission request", "Raw calendar list", "Calendar clone", "Agenda", "Analytics dashboard", "Red warning surface", "Silent scheduler"],
        primaryActions: [.makeCalendarAware, .findWindows, .move, .protect, .saveTheWeek],
        drillDowns: ["Calendar mode", "Rituals", "Review archive", "Receipts"],
        densityBehavior: "Detailed allowed for planning evidence below hero.",
        panelSizeBehavior: "Large focuses one week section; Compact uses timeline ribbon.",
        accessibilityRequirements: ["LifeShape Field summarizes open time, goal time, protected time, and pressure.", "Calendar controls have permission rationale.", "Timeline has non-gesture controls."],
        trustPrivacyRequirements: ["Calendar appears only as a Time source or detail.", "External writes require confirmation."],
        dependencies: [.d03GroupedNavigationList, .d04PanelDensitySize, .d05ReceiptsActionClosure],
        guardrails: commonTopLevelGuardrails + [.noCalendarPromptOutsidePlan, .receiptsForMeaningfulChanges],
        implementationStatus: .activeSurface,
        owningBatch: "D15",
        evidenceAnchors: [
            screenMatrixAnchor,
            accessibilityMatrixAnchor,
            .init(kind: .sourceSurface, path: "Native/Ambitions/Features/Time/TimeScreen.swift", note: "Current Time surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Features/Plan/PlanFeatureService.swift", note: "Plan projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Plan/PlanFeatureServiceTests.swift", note: "Focused Plan tests")
        ]
    )

    private static let you = ScreenContract(
        id: .you,
        dominantQuestion: "How does Ambitions work for me?",
        requiredFirstScreenContent: ["Your System", "User System You", "Planning Setup", "Trust & Automation", "Privacy", "Receipts & History", "Defaults", "Grouped Navigation Lists"],
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
            .init(kind: .sourceSurface, path: "Native/Ambitions/Features/You/YouScreen.swift", note: "Current You surface"),
            .init(kind: .sourceService, path: "Native/Ambitions/Features/You/YouFeatureService.swift", note: "You projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/You/YouFeatureServiceTests.swift", note: "Focused You tests")
        ]
    )

    private static let lifeAreasOverview = ScreenContract(
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
            .init(kind: .sourceFoundation, path: "Native/Ambitions/Domain/LifeAreaModels.swift", note: "Life Areas model foundation"),
            .init(kind: .sourceService, path: "Native/Ambitions/Services/LifeAreaAtlasProjector.swift", note: "Life Areas Atlas projector"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Services/LifeAreaAtlasProjectorTests.swift", note: "Life Areas Atlas tests")
        ]
    )

    private static let northStarDetail = ScreenContract(
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
            .init(kind: .sourceFoundation, path: "Native/Ambitions/Domain/NorthStarModels.swift", note: "North Star foundation"),
            .init(kind: .sourceService, path: "Native/Ambitions/Services/NorthStarProjector.swift", note: "North Star projector"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/Services/NorthStarProjectorTests.swift", note: "North Star projector tests")
        ]
    )

    private static let oneStepGoalDetail = ScreenContract(
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

    private static let review = ScreenContract(
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

    private static let trustCenter = ScreenContract(
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
            .init(kind: .sourceSurface, path: "Native/Ambitions/Features/You/YouScreen.swift", note: "Current You-hosted trust entry"),
            .init(kind: .sourceService, path: "Native/Ambitions/Features/You/YouFeatureService.swift", note: "Trust projection source"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/You/YouFeatureServiceTests.swift", note: "Trust and profile tests")
        ]
    )

    private static let whatAmbitionsKnows = ScreenContract(
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
            .init(kind: .sourceSurface, path: "Native/Ambitions/Features/You/YouScreen.swift", note: "Current You-hosted memory entry"),
            .init(kind: .testCoverage, path: "Native/AmbitionsTests/You/YouFeatureServiceTests.swift", note: "Memory and You tests")
        ]
    )

    private static let archive = ScreenContract(
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

    private static let externalSurfaces = ScreenContract(
        id: .externalSurfaces,
        dominantQuestion: "What can leave the app safely?",
        requiredFirstScreenContent: ["Shared snapshot privacy defaults", "Stale state", "Sensitive detail hiding", "Deep link fallback", "Receipt boundary"],
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
