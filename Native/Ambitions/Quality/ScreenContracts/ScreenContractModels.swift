import Foundation

enum ScreenContractID: String, CaseIterable, Codable, Hashable, Sendable {
    case today
    case goals
    case goalDetail
    case capture
    case time
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
        case .capture: "Capture Composer"
        case .time: "Time"
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
        case .time: "Time"
        case .you: "You"
        case .capture,
             .goalDetail,
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
    case composerOverlay
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
    case weekShapeStrip
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
    case noCalendarPromptOutsideTime
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
    case sourceComposer
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
