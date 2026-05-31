import AmbitionsDesignSystem
import Foundation

enum GoalDetailLens: String, CaseIterable, Hashable, Sendable {
    // Compatibility case name retained; this lens displays contained Goal/Path/Plan steps.
    case tasks
    case path

    var title: String {
        switch self {
        case .tasks: "Steps"
        case .path: "Path"
        }
    }
}

enum GoalRenderState: String, Hashable, Sendable {
    case active
    case starter
    case clarification
    case blocked
    case onHold
    case achieved

    var title: String {
        switch self {
        case .active: "In motion"
        case .starter: "Starter path"
        case .clarification: "Needs clarity"
        case .blocked: "Blocked"
        case .onHold: "On hold"
        case .achieved: "Achieved"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .active: .selected
        case .starter: .selected
        case .clarification: .warning
        case .blocked: .warning
        case .onHold: .default
        case .achieved: .success
        }
    }
}

enum GoalsAtlasPosture: String, Hashable, Sendable {
    case active
    case stalled
    case crowded
    case atRisk
    case lowerPriority
    case achieved

    var title: String {
        switch self {
        case .active: "Active"
        case .stalled: "Stalled"
        case .crowded: "Crowded"
        case .atRisk: "At Risk"
        case .lowerPriority: "Lower Priority"
        case .achieved: "Achieved"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .active: .selected
        case .stalled: .default
        case .crowded: .warning
        case .atRisk: .warning
        case .lowerPriority: .default
        case .achieved: .success
        }
    }
}

enum GoalsAtlasBandKind: String, Hashable, Sendable {
    case activeDirection = "active_direction"
    case pressure
    case recentMovement = "recent_movement"
    case lowerPriority = "lower_priority"
}

enum GoalPortfolioLifecycleState: String, Hashable, Sendable, CaseIterable {
    case active
    case passive
    case waiting
    case blocked
    case parked
    case protected
    case completed
    case cancelledDropped = "cancelled_dropped"
    case previous
    case future

    var title: String {
        switch self {
        case .active: "Active"
        case .passive: "Passive"
        case .waiting: "Waiting"
        case .blocked: "Blocked"
        case .parked: "Parked"
        case .protected: "Kept in view"
        case .completed: "Completed"
        case .cancelledDropped: "Cancelled"
        case .previous: "Previous"
        case .future: "Future"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .active, .protected: .selected
        case .completed: .success
        case .waiting, .blocked: .warning
        case .cancelledDropped, .parked, .passive, .previous, .future: .default
        }
    }

    var icon: String {
        switch self {
        case .active: "scope"
        case .passive: "moon"
        case .waiting: "hourglass"
        case .blocked: "exclamationmark.triangle"
        case .parked: "pause.circle"
        case .protected: "lock.shield"
        case .completed: "checkmark.circle"
        case .cancelledDropped: "xmark.circle"
        case .previous: "clock.arrow.circlepath"
        case .future: "sparkle"
        }
    }

    var isCurrentPortfolioState: Bool {
        switch self {
        case .active, .passive, .waiting, .blocked, .protected:
            true
        case .parked, .completed, .cancelledDropped, .previous, .future:
            false
        }
    }
}

enum GoalWeatherState: String, Hashable, Sendable {
    case clear
    case cloudy
    case stormy
    case foggy
    case protected

    var title: String {
        switch self {
        case .clear: "Clear"
        case .cloudy: "Cloudy"
        case .stormy: "Stormy"
        case .foggy: "Foggy"
        case .protected: "Kept in view"
        }
    }

    var icon: String {
        switch self {
        case .clear: "circle.lefthalf.filled"
        case .cloudy: "cloud"
        case .stormy: "cloud.bolt"
        case .foggy: "cloud.fog"
        case .protected: "lock.shield"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .clear, .protected: .selected
        case .cloudy, .foggy: .default
        case .stormy: .warning
        }
    }
}

struct GoalProofSummary: Sendable, Hashable {
    let title: String
    let detail: String
    let count: Int
    let latestTitle: String?
    let visualState: AmbitionVisualState
}

struct GoalNextVisibleStep: Sendable, Hashable {
    let title: String
    let detail: String
    let isAvailable: Bool
}

struct GoalMomentumIntegrity: Sendable, Hashable {
    let title: String
    let detail: String
    let visualState: AmbitionVisualState
}

struct GoalLifecycleRailSegment: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let count: Int
    let subtitle: String
    let state: AmbitionVisualState
}

struct GoalStateChipState: Identifiable, Sendable, Hashable {
    let lifecycleState: GoalPortfolioLifecycleState
    let count: Int

    var id: String { lifecycleState.rawValue }
}

struct GoalPortfolioArchiveSummary: Sendable, Hashable {
    let title: String
    let subtitle: String
    let chips: [GoalStateChipState]
    let learningLines: [String]
}

struct GoalPortfolioMaturitySignal: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let state: AmbitionVisualState
}

struct GoalPortfolioMaturitySummary: Sendable, Hashable {
    let title: String
    let subtitle: String
    let scopeSignal: GoalPortfolioMaturitySignal
    let stuckWorkSignal: GoalPortfolioMaturitySignal
    let proofSignal: GoalPortfolioMaturitySignal
    let nextStepSignal: GoalPortfolioMaturitySignal
    let archiveLearning: [String]
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String

    static var empty: GoalPortfolioMaturitySummary {
        let scope = GoalPortfolioMaturitySignal(id: "scope", title: "Scope is quiet", detail: "No live ambitions are competing for attention yet.", state: .default)
        let stuck = GoalPortfolioMaturitySignal(id: "stuck-work", title: "No stuck work is loud", detail: "No blockers, waiting states, or overloaded standalone Tasks are driving the atlas.", state: .selected)
        let proof = GoalPortfolioMaturitySignal(id: "proof", title: "Proof will appear here", detail: "Proof maturity starts after a goal has evidence or receipts.", state: .default)
        let next = GoalPortfolioMaturitySignal(id: "next-step", title: "Next steps will appear here", detail: "Create or shape a goal to make the next step visible.", state: .default)
        return GoalPortfolioMaturitySummary(
            title: "Direction maturity",
            subtitle: "A qualitative read on scope, proof, stuck work, and what should happen next.",
            scopeSignal: scope,
            stuckWorkSignal: stuck,
            proofSignal: proof,
            nextStepSignal: next,
            archiveLearning: ["Archive learning will appear after a goal is completed, parked, or closed."],
            accessibilityLabel: "Direction maturity",
            accessibilityValue: [scope.title, stuck.title, proof.title, next.title].joined(separator: ". "),
            accessibilityHint: "Review scope, stuck work, proof, and next-step clarity before adding more goals."
        )
    }
}

struct GoalAtlasPreviewItem: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let state: AmbitionVisualState
}

struct GoalAtlasPreviewGroup: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let items: [GoalAtlasPreviewItem]
}

struct GoalAtlasPreviewState: Sendable, Hashable {
    let title: String
    let subtitle: String
    let groups: [GoalAtlasPreviewGroup]
}

enum GoalsSemanticZoomMode: String, CaseIterable, Hashable, Sendable {
    case map
    case list

    var title: String {
        switch self {
        case .map:
            return "Map"
        case .list:
            return "List"
        }
    }
}

struct GoalsLifeAreaItemState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let nextFocus: String
    let goalThreadSummary: String?
    let activeGoalCount: Int
    let parkedGoalCount: Int
    let goalThreadCount: Int
    let northStarCount: Int
    let oneStepGoalCount: Int
    let proofCount: Int
    let receiptCount: Int
    let goalReferences: [GoalAtlasPreviewItem]
    let state: AmbitionVisualState
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct GoalsLifeAreasOverviewState: Sendable, Hashable {
    let title: String
    let subtitle: String
    let items: [GoalsLifeAreaItemState]
    let contentAreaCount: Int
    let emptyTitle: String
    let emptyMessage: String
    let availableZoomModes: [GoalsSemanticZoomMode]
    let supportsListFallback: Bool
    let maxVisibleAreas: Int
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String

    static var empty: GoalsLifeAreasOverviewState {
        GoalsLifeAreasOverviewState(
            title: "Life Areas",
            subtitle: "Goals stay organized by the parts of life they belong to.",
            items: [],
            contentAreaCount: 0,
            emptyTitle: "No Life Areas are active yet",
            emptyMessage: "Life Areas will take shape as goals, North Stars, or One-Step Goals appear.",
            availableZoomModes: GoalsSemanticZoomMode.allCases,
            supportsListFallback: true,
            maxVisibleAreas: 6,
            accessibilityLabel: "Life Areas",
            accessibilityValue: "No active Life Areas yet.",
            accessibilityHint: "Map and list views are available when areas have content."
        )
    }
}

struct GoalsNorthStarRailItemState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let lifeAreaLabel: String
    let postureLabel: String
    let readinessLabel: String
    let suggestedNextAction: String
    let linkedActiveGoalCount: Int
    let canBeShaped: Bool
    let shapeIntoGoalLabel: String
    let state: AmbitionVisualState
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct GoalsNorthStarsRailState: Sendable, Hashable {
    let title: String
    let subtitle: String
    let items: [GoalsNorthStarRailItemState]
    let totalCount: Int
    let emptyTitle: String
    let emptyMessage: String
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String

    static var empty: GoalsNorthStarsRailState {
        GoalsNorthStarsRailState(
            title: "North Stars",
            subtitle: "Long-range direction can stay held without pressure.",
            items: [],
            totalCount: 0,
            emptyTitle: "No North Stars here yet",
            emptyMessage: "Save long-range direction under a Life Area without turning it into an active goal.",
            accessibilityLabel: "North Stars",
            accessibilityValue: "No North Stars yet.",
            accessibilityHint: "North Stars are held under Life Areas and do not become goals automatically."
        )
    }
}

struct GoalsOneStepGoalPanelItemState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let areaLabel: String
    let statusLabel: String
    let timingLabel: String?
    let suggestedNextAction: String
    let canPromoteToGoal: Bool
    let canAttachToGoal: Bool
    let promoteLabel: String
    let attachLabel: String
    let state: AmbitionVisualState
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct GoalsOneStepGoalsPanelState: Sendable, Hashable {
    let title: String
    let subtitle: String
    let items: [GoalsOneStepGoalPanelItemState]
    let openCount: Int
    let parkedCount: Int
    let emptyTitle: String
    let emptyMessage: String
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String

    static var empty: GoalsOneStepGoalsPanelState {
        GoalsOneStepGoalsPanelState(
            title: "One-Step Goals",
            subtitle: "Standalone Tasks that do not need a full goal yet.",
            items: [],
            openCount: 0,
            parkedCount: 0,
            emptyTitle: "No One-Step Goals yet",
            emptyMessage: "Small standalone work can stay here without becoming a full goal.",
            accessibilityLabel: "One-Step Goals",
            accessibilityValue: "No One-Step Goals yet.",
            accessibilityHint: "Tasks are standalone One-Step Goals. Steps stay inside Goals, Paths, or Plans."
        )
    }
}

enum GoalsAtlasPrimaryActionKind: String, Hashable, Sendable {
    case openGoal = "open_goal"
    case recoverGoal = "recover_goal"
    case refineStrategy = "refine_strategy"
    case createGoal = "create_goal"
}

struct GoalsHeroPillState: Identifiable, Sendable, Hashable {
    let title: String
    let icon: String?
    let state: AmbitionVisualState

    var id: String { [title, icon ?? "", state.rawValue].joined(separator: "|") }
}

struct GoalsAtlasHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let pressureSummary: String
    let contextPills: [GoalsHeroPillState]
    let attentionPills: [GoalsHeroPillState]
}

struct GoalsAtlasPrimaryAction: Sendable {
    let kind: GoalsAtlasPrimaryActionKind
    let title: String
    let subtitle: String
    let systemImage: String
    let target: GoalRouteTarget?
    let state: AmbitionVisualState
}

struct GoalsWeekPressureSummary: Sendable {
    let title: String
    let subtitle: String
    let leadingMetric: String
    let trailingMetric: String
    let pill: GoalsHeroPillState
}

struct GoalListItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget
    let title: String
    let subtitle: String
    let mode: GoalMode
    let renderState: GoalRenderState
    let progressValue: Double
    let progressLabel: String
    let statusLabel: String
    let timingLabel: String
    let nextStepHint: String
    let modeLabel: String
    let supportLabel: String?
    let relevanceScore: Double
    let momentumScore: Double
    let urgencyScore: Double
    let manualPriorityRank: Int
    let updatedAt: String
    let shellSummary: GoalShellSummaryState?

    init(
        id: String,
        target: GoalRouteTarget,
        title: String,
        subtitle: String,
        mode: GoalMode,
        renderState: GoalRenderState,
        progressValue: Double,
        progressLabel: String,
        statusLabel: String,
        timingLabel: String,
        nextStepHint: String,
        modeLabel: String,
        supportLabel: String?,
        relevanceScore: Double,
        momentumScore: Double,
        urgencyScore: Double,
        manualPriorityRank: Int,
        updatedAt: String,
        shellSummary: GoalShellSummaryState? = nil
    ) {
        self.id = id
        self.target = target
        self.title = title
        self.subtitle = subtitle
        self.mode = mode
        self.renderState = renderState
        self.progressValue = progressValue
        self.progressLabel = progressLabel
        self.statusLabel = statusLabel
        self.timingLabel = timingLabel
        self.nextStepHint = nextStepHint
        self.modeLabel = modeLabel
        self.supportLabel = supportLabel
        self.relevanceScore = relevanceScore
        self.momentumScore = momentumScore
        self.urgencyScore = urgencyScore
        self.manualPriorityRank = manualPriorityRank
        self.updatedAt = updatedAt
        self.shellSummary = shellSummary
    }
}

struct GoalsAtlasCardState: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget
    let title: String
    let subtitle: String
    let modeLabel: String
    let posture: GoalsAtlasPosture
    let renderState: GoalRenderState
    let progressValue: Double
    let progressLabel: String
    let timingLabel: String
    let weekRelationship: String
    let phaseSummary: String
    let milestoneSummary: String
    let pressureSummary: String
    let nextStepHint: String
    let lifecycleState: GoalPortfolioLifecycleState
    let weather: GoalWeatherState
    let weatherSummary: String
    let proofSummary: GoalProofSummary
    let nextVisibleStep: GoalNextVisibleStep
    let momentumIntegrity: GoalMomentumIntegrity
    let supportLabel: String?
    let priorityLabel: String
    let manualPriorityRank: Int
    let shellSummary: GoalShellSummaryState?
}

struct GoalsAtlasBand: Identifiable, Sendable {
    let kind: GoalsAtlasBandKind
    let title: String
    let subtitle: String
    let cards: [GoalsAtlasCardState]

    var id: String { kind.rawValue }
}

struct GoalsHorizonLadderRung: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget
    let title: String
    let summary: String
    let milestoneLabel: String
    let signalLabel: String
    let highlight: String
    let state: AmbitionVisualState
}

struct GoalsHorizonLadderState: Sendable {
    let title: String
    let subtitle: String
    let rungs: [GoalsHorizonLadderRung]
}

struct GoalsLowerPriorityState: Sendable {
    let title: String
    let subtitle: String
    let disclosureTitle: String
    let cards: [GoalsAtlasCardState]
}

struct GoalsOverview: Sendable {
    let hero: GoalsAtlasHeroState
    let heroPrimaryAction: GoalsAtlasPrimaryAction
    let bands: [GoalsAtlasBand]
    let horizonLadder: GoalsHorizonLadderState
    let weekPressureSummary: GoalsWeekPressureSummary
    let lowerPriority: GoalsLowerPriorityState
    let lifecycleRail: [GoalLifecycleRailSegment]
    let stateChips: [GoalStateChipState]
    let lifeAreas: GoalsLifeAreasOverviewState
    let northStars: GoalsNorthStarsRailState
    let oneStepGoals: GoalsOneStepGoalsPanelState
    let atlasPreview: GoalAtlasPreviewState?
    let archiveSummary: GoalPortfolioArchiveSummary
    let maturitySummary: GoalPortfolioMaturitySummary
    let items: [GoalListItem]
    let isSeeded: Bool
    let emptyTitle: String
    let emptyMessage: String

    init(
        hero: GoalsAtlasHeroState,
        heroPrimaryAction: GoalsAtlasPrimaryAction,
        bands: [GoalsAtlasBand],
        horizonLadder: GoalsHorizonLadderState,
        weekPressureSummary: GoalsWeekPressureSummary,
        lowerPriority: GoalsLowerPriorityState,
        lifecycleRail: [GoalLifecycleRailSegment],
        stateChips: [GoalStateChipState],
        lifeAreas: GoalsLifeAreasOverviewState = .empty,
        northStars: GoalsNorthStarsRailState = .empty,
        oneStepGoals: GoalsOneStepGoalsPanelState = .empty,
        atlasPreview: GoalAtlasPreviewState?,
        archiveSummary: GoalPortfolioArchiveSummary,
        maturitySummary: GoalPortfolioMaturitySummary,
        items: [GoalListItem],
        isSeeded: Bool,
        emptyTitle: String,
        emptyMessage: String
    ) {
        self.hero = hero
        self.heroPrimaryAction = heroPrimaryAction
        self.bands = bands
        self.horizonLadder = horizonLadder
        self.weekPressureSummary = weekPressureSummary
        self.lowerPriority = lowerPriority
        self.lifecycleRail = lifecycleRail
        self.stateChips = stateChips
        self.lifeAreas = lifeAreas
        self.northStars = northStars
        self.oneStepGoals = oneStepGoals
        self.atlasPreview = atlasPreview
        self.archiveSummary = archiveSummary
        self.maturitySummary = maturitySummary
        self.items = items
        self.isSeeded = isSeeded
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
    }

    func screenContractSnapshot(
        topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs
    ) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .goals,
            firstScreenContent: [
                "Your Direction",
                "Constellation Atlas",
                "Orbital Lens",
                "Goal Lifecycle Rail",
                "Active goals",
                "North Stars rail",
                "Controlled One-Step Goals"
            ],
            panels: [.progress, .lifeAreas, .oneStepGoals, .goalLifecycleRail, .northStarsRail],
            actions: [.openGoal, .createGoal, .promoteTask, .reviewParked],
            drillDowns: ["Goal Detail", "Life Areas Overview", "North Star Detail", "Archive"],
            copySamples: [
                hero.title,
                hero.subtitle,
                lifeAreas.title,
                lifeAreas.subtitle,
                northStars.title,
                northStars.emptyTitle,
                oneStepGoals.title,
                oneStepGoals.subtitle,
                lowerPriority.disclosureTitle
            ],
            topLevelTabTitles: topLevelTabTitles,
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: lifeAreas.supportsListFallback,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )
    }

    var constellationAtlasInspectionSummary: String {
        [
            "SourceRecord: \(constellationAtlasSourceRecordSummary)",
            "Receipt: \(constellationAtlasReceiptSummary)",
            "ReplayTrace: \(constellationAtlasReplayTraceSummary)",
            "You / What Ambitions knows: \(constellationAtlasYouSummary)"
        ].joined(separator: " · ")
    }

    var constellationAtlasAccessibilityValue: String {
        [
            "Constellation Atlas.",
            constellationAtlasSourceRecordSummary,
            constellationAtlasReceiptSummary,
            constellationAtlasReplayTraceSummary,
            constellationAtlasYouSummary
        ].joined(separator: " ")
    }

    var constellationAtlasCompactInspectionSummary: String {
        "Local source, proof receipts, and replay trace stay inspectable through You."
    }

    private var constellationAtlasSourceRecordSummary: String {
        let visibleGoalCount = bands.reduce(0) { $0 + $1.cards.count }
        let areaCount = lifeAreas.contentAreaCount

        if areaCount == 0 {
            return "\(visibleGoalCount) visible goal threads are arranged from local Goals, drafts, evidence, and capture records."
        }

        return "\(visibleGoalCount) visible goal threads stay grouped across \(areaCount) Life Areas from local Goals, drafts, evidence, and capture records."
    }

    private var constellationAtlasReceiptSummary: String {
        let proofCount = lifeAreas.items.reduce(0) { $0 + $1.proofCount }
        let receiptCount = lifeAreas.items.reduce(0) { $0 + $1.receiptCount }

        if proofCount == 0 && receiptCount == 0 {
            return "proof and closure receipts are still thin, so the atlas avoids pretending certainty."
        }

        return "\(proofCount) proof points and \(receiptCount) closure receipts are visible before the atlas asks for more commitment."
    }

    private var constellationAtlasReplayTraceSummary: String {
        let primaryLaneTitles = bands
            .filter { $0.cards.isEmpty == false }
            .map(\.title)
            .prefix(3)
            .joined(separator: ", ")
        let visibleLanes = primaryLaneTitles.isEmpty ? "quiet lanes" : primaryLaneTitles

        return "\(visibleLanes) explain why each goal is active, pressured, or quieter."
    }

    private var constellationAtlasYouSummary: String {
        if let activeArea = lifeAreas.items.first {
            return "\(activeArea.title) is the clearest Life Area connection, and Orbital Lens keeps one thread connected to Today."
        }

        return "Orbital Lens keeps the clearest available thread connected to Today without adding another top-level destination."
    }
}

// Compatibility aliases retained for older callers and previews that still import Board names.
typealias GoalsBoardPosture = GoalsAtlasPosture
typealias GoalsBoardBandKind = GoalsAtlasBandKind
typealias GoalsBoardPrimaryActionKind = GoalsAtlasPrimaryActionKind
typealias GoalsBoardHeroState = GoalsAtlasHeroState
typealias GoalsBoardPrimaryAction = GoalsAtlasPrimaryAction
typealias GoalsBoardCardState = GoalsAtlasCardState
typealias GoalsBoardBand = GoalsAtlasBand

struct CreateGoalRequest: Sendable {
    let title: String
    let mode: GoalMode?
    let entrySource: ShellCommandEntrySource?
    let clarifiedFields: [MissingFieldKey: String]
    let preferredPace: StrategyComposerPaceChoice?
    let targetDateOverride: String?
    let captureID: String?

    init(
        title: String,
        mode: GoalMode? = nil,
        entrySource: ShellCommandEntrySource? = nil,
        clarifiedFields: [MissingFieldKey: String] = [:],
        preferredPace: StrategyComposerPaceChoice? = nil,
        targetDateOverride: String? = nil,
        captureID: String? = nil
    ) {
        self.title = title
        self.mode = mode
        self.entrySource = entrySource
        self.clarifiedFields = clarifiedFields
        self.preferredPace = preferredPace
        self.targetDateOverride = targetDateOverride
        self.captureID = captureID
    }
}

struct CreateGoalResponse: Sendable {
    let target: GoalRouteTarget
    let blueprint: GoalBlueprint
    let resultKind: GoalOrchestrationResultKind
    let planningEvaluation: PlanningEvaluation?
    let unitOfWorkReceipt: AppUnitOfWorkReceipt?

    init(
        target: GoalRouteTarget,
        blueprint: GoalBlueprint,
        resultKind: GoalOrchestrationResultKind = .planned,
        planningEvaluation: PlanningEvaluation? = nil,
        unitOfWorkReceipt: AppUnitOfWorkReceipt? = nil
    ) {
        self.target = target
        self.blueprint = blueprint
        self.resultKind = resultKind
        self.planningEvaluation = planningEvaluation
        self.unitOfWorkReceipt = unitOfWorkReceipt
    }
}

struct PreparedGoalCreation: Sendable {
    let response: CreateGoalResponse
    let goal: Goal?
    let draft: PersistedGoalDraft
}

enum StrategyComposerPaceChoice: String, CaseIterable, Identifiable, Sendable {
    case conservative
    case balanced
    case aggressive

    var id: String { rawValue }
}

struct StrategyComposerPaceOptionState: Identifiable, Sendable {
    let choice: StrategyComposerPaceChoice
    let title: String
    let subtitle: String
    let badgeTitle: String
    let state: AmbitionVisualState

    var id: StrategyComposerPaceChoice { choice }
}

struct StrategyComposerFeasibilityState: Sendable {
    let title: String
    let summary: String
    let details: [String]
    let state: AmbitionVisualState
}

struct StrategyComposerDeadlineGuidanceState: Sendable {
    let title: String
    let body: String
    let suggestedDate: String
    let badgeTitle: String
    let state: AmbitionVisualState
}

struct StrategyComposerTrustState: Sendable {
    let title: String
    let lines: [String]
    let badgeTitle: String
    let state: AmbitionVisualState
}

struct CreateGoalPreviewRequest: Sendable {
    let title: String
    let mode: GoalMode?
    let entrySource: ShellCommandEntrySource
    let clarifiedFields: [MissingFieldKey: String]
    let preferredPace: StrategyComposerPaceChoice
    let targetDateOverride: String?
    let captureID: String?

    init(
        title: String,
        mode: GoalMode? = nil,
        entrySource: ShellCommandEntrySource,
        clarifiedFields: [MissingFieldKey: String] = [:],
        preferredPace: StrategyComposerPaceChoice = .balanced,
        targetDateOverride: String? = nil,
        captureID: String? = nil
    ) {
        self.title = title
        self.mode = mode
        self.entrySource = entrySource
        self.clarifiedFields = clarifiedFields
        self.preferredPace = preferredPace
        self.targetDateOverride = targetDateOverride
        self.captureID = captureID
    }
}

struct CreateGoalPreviewState: Sendable {
    let normalizedTitle: String
    let summary: String
    let modeLabel: String
    let resultKind: GoalOrchestrationResultKind
    let renderState: GoalRenderState
    let selectedPace: StrategyComposerPaceChoice
    let paceOptions: [StrategyComposerPaceOptionState]
    let feasibility: StrategyComposerFeasibilityState?
    let deadlineGuidance: StrategyComposerDeadlineGuidanceState?
    let pathStages: [GoalPathStage]
    let milestonePreview: [GoalDetailStepItem]
    let clarification: GoalClarificationState?
    let blocked: GoalBlockedState?
    let trust: StrategyComposerTrustState
    let planningEvaluation: PlanningEvaluation?
}

struct GoalSeedReviewState: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let whyGoalLabel: String
    let startingPositionLabel: String
    let firstMilestoneLabel: String
    let firstStepLabel: String
    let proofSourceSeedLabel: String
    let confirmationLabel: String
    let state: AmbitionVisualState

    var accessibilityValue: String {
        [
            whyGoalLabel,
            startingPositionLabel,
            firstMilestoneLabel,
            firstStepLabel,
            proofSourceSeedLabel,
            confirmationLabel
        ].joined(separator: ". ")
    }
}

extension CreateGoalPreviewState {
    var goalSeedReviewState: GoalSeedReviewState {
        let activeStage = pathStages.first { stage in
            stage.position == .current || stage.position == .blocked
        } ?? pathStages.first
        let firstMilestone = milestonePreview.first
        let firstStep = firstMilestone?.title ?? activeStage?.highlight

        return GoalSeedReviewState(
            id: "goal-seed-review-\(normalizedTitle.lowercased().filter { $0.isLetter || $0.isNumber })",
            title: "Goal Seed Incubator",
            whyGoalLabel: whyGoalLabel,
            startingPositionLabel: "Starting position: \(activeStage?.title ?? "Needs one clearer starting point").",
            firstMilestoneLabel: "First milestone: \(firstMilestone?.summary ?? activeStage?.summary ?? "Hold the setup until a first milestone is visible.").",
            firstStepLabel: "First recommended step: \(firstStep ?? "Add one concrete next step before this becomes active.").",
            proofSourceSeedLabel: "Proof/source seed: current setup only; review before saving.",
            confirmationLabel: confirmationLabel,
            state: renderState.visualState
        )
    }

    private var whyGoalLabel: String {
        switch resultKind {
        case .planned, .starterPlanned:
            "Why this might be a goal: \(summary)"
        case .clarificationRequired:
            "Why this might be a goal: the idea has signal, but one clarification is needed first."
        case .blocked:
            "Why this might be a goal: the blocker is visible before anything goes live."
        }
    }

    private var confirmationLabel: String {
        switch resultKind {
        case .planned, .starterPlanned:
            "Confirmation: create the goal only when you choose Create Goal."
        case .clarificationRequired, .blocked:
            "Confirmation: save a draft until the setup is clear enough."
        }
    }
}

struct GoalDetailActionState: Identifiable, Sendable {
    let kind: GoalDetailActionKind
    let title: String
    let systemImage: String
    let state: AmbitionVisualState

    var id: String { kind.rawValue }
}

enum GoalDetailActionKind: String, Sendable {
    case complete
    case delay
    case skip
    case createReminder
    case createCalendarEvent
    case askForSmallerStep
    case askWhyThisMatters
    case markNotRelevant
    case breakThisDownSmaller
    case imStuck
    case showPath
    case switchToUntimed
    case showSupportMode
    case raisePriority
    case lowerPriority
}

struct GoalClarificationQuestionState: Identifiable, Sendable {
    let id: String
    let field: MissingFieldKey
    let prompt: String
    let rationale: String
    let gentleDefault: String
    let existingAnswer: String?
}

struct GoalClarificationAnswerRequest: Sendable {
    let target: GoalRouteTarget
    let questionID: String
    let field: MissingFieldKey
    let answer: String
}

struct GoalDetailActionRequest: Sendable {
    let target: GoalRouteTarget
    let kind: GoalDetailActionKind
    let stepID: String?
}

enum GoalExplainabilityCorrectionControlKind: String, Sendable {
    case markSupportNotRelevant = "mark_support_not_relevant"
    case confirmContradiction = "confirm_contradiction"
    case dismissContradiction = "dismiss_contradiction"
    case requestLighterVersion = "request_lighter_version"
}

struct GoalWhyThisState: Sendable {
    let compactSummary: String
    let lines: [String]
}

struct GoalSourceAuditRowState: Identifiable, Sendable {
    let id: String
    let resourceID: String
    let title: String
    let subtitle: String
    let detailLabels: [String]
    let state: AmbitionVisualState
}

struct GoalSourceAuditSectionState: Sendable {
    let rows: [GoalSourceAuditRowState]
}

struct GoalFreshnessState: Sendable {
    let posture: GoalFreshnessPosture
    let postureLabel: String
    let severityLabel: String
    let detailLabels: [String]
}

struct GoalConfidenceState: Sendable {
    let understandingConfidence: RecommendationConfidence
    let pathConfidence: RecommendationConfidence?
    let detailLabels: [String]
}

struct GoalContradictionSummaryState: Identifiable, Sendable {
    let id: String
    let code: GoalContradictionCode
    let title: String
    let summary: String
    let severityLabel: String
    let state: AmbitionVisualState
}

struct GoalCorrectionControlState: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let kind: GoalExplainabilityCorrectionControlKind
    let artifactKind: GoalTeachingArtifactKind
    let teachingSignalKind: GoalTeachingSignalKind
    let payload: GoalTeachingPayload
    let target: GoalTeachingCaptureTarget
    let state: AmbitionVisualState
}

struct GoalAppliedTeachingBadgeState: Identifiable, Sendable {
    let id: String
    let signalID: String
    let title: String
    let subtitle: String
    let state: AmbitionVisualState
}

struct GoalTrustWhisperPillState: Identifiable, Sendable {
    let id: String
    let title: String
    let icon: String
    let state: AmbitionVisualState
}

struct GoalTrustWhisperState: Sendable {
    let title: String
    let subtitle: String
    let pillLine: String
    let pills: [GoalTrustWhisperPillState]
}

struct GoalExplainabilityState: Sendable {
    let whisper: GoalTrustWhisperState
    let whyThis: GoalWhyThisState
    let sourceAudit: GoalSourceAuditSectionState
    let freshness: GoalFreshnessState
    let confidence: GoalConfidenceState
    let contradictions: [GoalContradictionSummaryState]
    let correctionControls: [GoalCorrectionControlState]
    let appliedTeachingBadges: [GoalAppliedTeachingBadgeState]
}

struct GoalExplainabilityCorrectionRequest: Sendable {
    let target: GoalRouteTarget
    let control: GoalCorrectionControlState
}

struct GoalDetailInlineMessage: Identifiable, Sendable {
    let id: String
    let title: String
    let body: String
    let state: AmbitionVisualState

    init(id: String = UUID().uuidString, title: String, body: String, state: AmbitionVisualState) {
        self.id = id
        self.title = title
        self.body = body
        self.state = state
    }
}

struct GoalDetailActionResponse: Sendable {
    let message: GoalDetailInlineMessage?
    let unitOfWorkReceipt: AppUnitOfWorkReceipt?

    init(
        message: GoalDetailInlineMessage?,
        unitOfWorkReceipt: AppUnitOfWorkReceipt? = nil
    ) {
        self.message = message
        self.unitOfWorkReceipt = unitOfWorkReceipt
    }
}

struct GoalDetailHeadline: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let renderState: GoalRenderState
    let modeLabel: String
    let timingLabel: String
    let supportLabel: String?
}

struct GoalDetailProgress: Sendable {
    let label: String
    let detail: String
    let value: Double
    let evidenceLabel: String
}

struct GoalDetailStrategicStatus: Sendable {
    let title: String
    let summary: String
    let supportingDetail: String
}

enum GoalPathStagePosition: String, Sendable {
    case completed
    case current
    case blocked
    case upcoming

    var title: String {
        switch self {
        case .completed: "Completed"
        case .current: "Current"
        case .blocked: "Blocked"
        case .upcoming: "Upcoming"
        }
    }
}

struct GoalDetailStepItem: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let timingLabel: String
    let statusLabel: String
    let state: AmbitionVisualState
}

struct GoalDetailSectionState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let kindLabel: String
    let steps: [GoalDetailStepItem]
}

struct GoalPathStage: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let stepCountLabel: String
    let position: GoalPathStagePosition
    let statusLabel: String
    let highlight: String?
    let state: AmbitionVisualState
}

extension GoalPathStage {
    var lifecycleMarkerLabel: String {
        switch position {
        case .completed:
            "Proof-backed stage"
        case .current:
            "Current position"
        case .blocked:
            "Friction marker"
        case .upcoming:
            "Horizon marker"
        }
    }

    var progressShapeLabel: String {
        switch position {
        case .completed:
            "Already landed"
        case .current:
            "In motion now"
        case .blocked:
            "Needs recovery"
        case .upcoming:
            "Not yet active"
        }
    }

    var proofMarkerLabel: String? {
        switch position {
        case .completed:
            "Evidence attached"
        case .current:
            "Proof can be added here"
        case .blocked:
            nil
        case .upcoming:
            nil
        }
    }

    var riskMarkerLabel: String? {
        position == .blocked ? "Risk visible" : nil
    }

    var routeIndicatorLabel: String? {
        position == .upcoming ? "Route option" : nil
    }

    var accessibilitySummary: String {
        [
            lifecycleMarkerLabel,
            progressShapeLabel,
            statusLabel,
            stepCountLabel,
            highlight.map { "Highlight: \($0)" },
            proofMarkerLabel,
            riskMarkerLabel,
            routeIndicatorLabel,
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
    }
}

struct GoalPathBuilderPhaseState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let dependencySummary: String
    let proofSummary: String
    let statusLabel: String
    let state: AmbitionVisualState
}

struct GoalPathBuilderForkState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let basisSummary: String
    let decisionPrompt: String
    let freshnessLabel: String
    let state: AmbitionVisualState
}

struct GoalPathTradeoffLaneState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let effortLabel: String
    let timeLabel: String
    let energyLabel: String
    let reviewRequirementLabel: String
    let recoveryLabel: String
    let state: AmbitionVisualState
}

struct GoalPathTradeoffReviewState: Sendable {
    let title: String
    let subtitle: String
    let lanes: [GoalPathTradeoffLaneState]
    let accessibilitySummary: String
}

struct GoalPathBuilderProofState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let handoffLabel: String
    let state: AmbitionVisualState
}

struct GoalPathBuilderState: Sendable {
    let title: String
    let subtitle: String
    let breadcrumbLabels: [String]
    let phases: [GoalPathBuilderPhaseState]
    let forks: [GoalPathBuilderForkState]
    let proofRequirements: [GoalPathBuilderProofState]
    let todayConnectionTitle: String
    let todayConnectionSummary: String
    let planConnectionSummary: String
    let decisionReceiptSummary: String
    let roadmapListTitle: String
    let roadmapListSummary: String
    let performanceBudgetSummary: String
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct LifePathThreadState: Sendable {
    let title: String
    let subtitle: String
    let nodes: [LifePathThreadNode]
    let proofBeads: [LifePathProofBead]
    let riskPinches: [RiskPinch]
    let alternateRouteFolds: [AlternateRouteFold]
    let sourceFold: GoalPathSourceFold
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String

    init(
        stages: [GoalPathStage],
        pathBuilder: GoalPathBuilderState?,
        privacySensitive: Bool = false
    ) {
        let visibleStages = Array(stages.prefix(6))
        let nodes = visibleStages.enumerated().map { index, stage in
            LifePathThreadNode(
                id: stage.id,
                order: index + 1,
                roleLabel: stage.lifecycleMarkerLabel,
                title: privacySensitive ? "Private path stage" : stage.title,
                summary: privacySensitive ? "Stage detail hidden. The path role remains visible." : stage.summary,
                statusLabel: stage.statusLabel,
                stepCountLabel: stage.stepCountLabel,
                markerLabel: stage.progressShapeLabel,
                nonColorMeaning: stage.accessibilitySummary,
                symbolName: LifePathThreadState.symbolName(for: stage.position),
                state: stage.state
            )
        }
        let stageProof = visibleStages.compactMap { stage -> LifePathProofBead? in
            guard let marker = stage.proofMarkerLabel else { return nil }
            return LifePathProofBead(
                id: "stage-proof-\(stage.id)",
                title: marker,
                summary: privacySensitive ? "Proof detail hidden." : stage.highlight ?? stage.summary,
                state: stage.position == .completed ? .success : .default
            )
        }
        let requirementProof = (pathBuilder?.proofRequirements ?? []).prefix(3).map { proof in
            LifePathProofBead(
                id: "requirement-\(proof.id)",
                title: privacySensitive ? "Private proof check" : proof.title,
                summary: privacySensitive ? "Proof detail hidden." : proof.summary,
                state: proof.state
            )
        }
        let stageRiskPinches = visibleStages.compactMap { stage -> RiskPinch? in
            guard let risk = stage.riskMarkerLabel else { return nil }
            return RiskPinch(
                id: "risk-\(stage.id)",
                title: risk,
                summary: privacySensitive ? "Risk detail hidden." : stage.highlight ?? stage.summary,
                state: .warning
            )
        }
        let phaseRiskPinches = (pathBuilder?.phases ?? []).filter { $0.state == .warning }.prefix(3).map { phase in
            RiskPinch(
                id: "phase-risk-\(phase.id)",
                title: "Risk visible",
                summary: privacySensitive ? "Risk detail hidden." : phase.dependencySummary,
                state: .warning
            )
        }
        let forkRiskPinches = (pathBuilder?.forks ?? []).filter { $0.state == .warning }.prefix(2).map { fork in
            RiskPinch(
                id: "fork-risk-\(fork.id)",
                title: "Route needs review",
                summary: privacySensitive ? "Risk detail hidden." : fork.basisSummary,
                state: .warning
            )
        }
        let alternateRouteFolds = (pathBuilder?.forks ?? []).prefix(3).map { fork in
            AlternateRouteFold(
                id: "alternate-\(fork.id)",
                title: privacySensitive ? "Private alternate route" : fork.title,
                summary: privacySensitive ? "Alternate route detail hidden." : fork.summary,
                reviewLabel: fork.decisionPrompt,
                state: fork.state
            )
        }
        let sourceFold = GoalPathSourceFold(
            id: "goal-path-source-fold",
            title: "GoalPathSourceFold",
            summary: pathBuilder?.performanceBudgetSummary ?? "Thread is based on the visible goal path stages.",
            breadcrumbLabels: pathBuilder?.breadcrumbLabels ?? ["Goal Detail", "LifePath Thread"],
            privacyLabel: privacySensitive ? "Private mode hides titles while preserving path roles." : "Source labels stay visible for review.",
            state: .default
        )

        self.title = "LifePath Thread"
        self.subtitle = "Path roles, proof, risk, and alternate routes stay connected before deeper tactics."
        self.nodes = nodes
        self.proofBeads = Array((stageProof + requirementProof).prefix(6))
        self.riskPinches = Array((stageRiskPinches + phaseRiskPinches + forkRiskPinches).prefix(3))
        self.alternateRouteFolds = Array(alternateRouteFolds)
        self.sourceFold = sourceFold
        self.accessibilityLabel = "LifePath Thread"
        self.accessibilityValue = nodes
            .map { "Order \($0.order), \($0.roleLabel), \($0.statusLabel), \($0.title)" }
            .joined(separator: ". ")
        self.accessibilityHint = privacySensitive
            ? "Private mode preserves accessible path order, proof beads, risk pinch, alternate route fold, and source fold roles without exposing titles."
            : "Review the path in order with proof beads, risk pinch, alternate route fold, and source fold."
    }

    private static func symbolName(for position: GoalPathStagePosition) -> String {
        switch position {
        case .completed:
            "checkmark.seal"
        case .current:
            "scope"
        case .blocked:
            "exclamationmark.triangle"
        case .upcoming:
            "arrow.triangle.branch"
        }
    }
}

struct LifePathThreadNode: Identifiable, Sendable {
    let id: String
    let order: Int
    let roleLabel: String
    let title: String
    let summary: String
    let statusLabel: String
    let stepCountLabel: String
    let markerLabel: String
    let nonColorMeaning: String
    let symbolName: String
    let state: AmbitionVisualState
}

struct LifePathProofBead: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let state: AmbitionVisualState
}

struct RiskPinch: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let state: AmbitionVisualState
}

struct AlternateRouteFold: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let reviewLabel: String
    let state: AmbitionVisualState
}

struct GoalPathSourceFold: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let breadcrumbLabels: [String]
    let privacyLabel: String
    let state: AmbitionVisualState
}

extension GoalPathBuilderState {
    var tradeoffReview: GoalPathTradeoffReviewState {
        let blockedPhase = phases.first {
            $0.state == .warning ||
            $0.statusLabel.localizedCaseInsensitiveContains("blocked") ||
            $0.dependencySummary.localizedCaseInsensitiveContains("blocked")
        }
        let recoveryLabel = blockedPhase.map {
            "Recovery: review \($0.title) before changing route."
        } ?? "Recovery: park or edit before changing route."
        let lanes = forks.map { fork in
            GoalPathTradeoffLaneState(
                id: "tradeoff-\(fork.id)",
                title: fork.title,
                summary: fork.summary,
                effortLabel: "Effort: compare setup cost before choosing.",
                timeLabel: fork.freshnessLabel == "Current"
                    ? "Time: current context still needs review."
                    : "Time: review the source before using it.",
                energyLabel: "Energy: choose the sustainable path, not the biggest one.",
                reviewRequirementLabel: "User review required before this changes Today or Plan.",
                recoveryLabel: recoveryLabel,
                state: fork.state
            )
        }

        return GoalPathTradeoffReviewState(
            title: "Tradeoff review",
            subtitle: "Route options stay comparable and reversible before any path changes.",
            lanes: lanes,
            accessibilitySummary: lanes.map {
                "\($0.title). \($0.effortLabel) \($0.timeLabel) \($0.energyLabel) \($0.reviewRequirementLabel)"
            }.joined(separator: " ")
        )
    }
}

struct GoalDetailNextMovement: Sendable {
    let title: String
    let summary: String
    let timingLabel: String
    let rationale: String
    let state: AmbitionVisualState
}

struct GoalDetailTrajectoryState: Sendable {
    let phaseTitle: String
    let phaseSummary: String
    let milestoneSummary: String
    let momentumSummary: String
    let timelineSummary: String
}

struct GoalEvidenceItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalFeedbackItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalDetailRecentMovementItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let categoryLabel: String
    let state: AmbitionVisualState
}

struct GoalDetailRecentMovementState: Sendable {
    let title: String
    let summary: String
    let items: [GoalDetailRecentMovementItem]
}

enum GoalDetailMissionLaneKind: String, Sendable, CaseIterable {
    case overview
    case path
    case steps
    case proof
    case decisions
    case risks
    case archive

    var title: String {
        switch self {
        case .overview: "Overview"
        case .path: "Path"
        case .steps: "Steps"
        case .proof: "Proof"
        case .decisions: "Decisions"
        case .risks: "Risks"
        case .archive: "Archive"
        }
    }

    var accessibilityIdentifier: String {
        "goal-detail.lane.\(rawValue)"
    }
}

struct GoalDetailMissionLaneState: Identifiable, Sendable {
    let kind: GoalDetailMissionLaneKind
    let title: String
    let headline: String
    let summary: String
    let detail: String
    let badgeTitle: String
    let systemImage: String
    let state: AmbitionVisualState

    var id: String { kind.rawValue }
}

struct GoalDetailBreadcrumbState: Sendable {
    let title: String
    let labels: [String]
    let fallbackUsed: Bool
}

enum GoalDetailTimelineItemKind: String, Sendable {
    case started
    case previous
    case current
    case next
    case proof
    case decision
    case waiting
    case parked
    case completed
    case cancelled

    var title: String {
        switch self {
        case .started: "Started"
        case .previous: "Previous"
        case .current: "Current"
        case .next: "Next"
        case .proof: "Proof"
        case .decision: "Decision"
        case .waiting: "Waiting"
        case .parked: "Parked"
        case .completed: "Completed"
        case .cancelled: "Cancelled"
        }
    }
}

struct GoalDetailTimelineItemState: Identifiable, Sendable {
    let id: String
    let kind: GoalDetailTimelineItemKind
    let title: String
    let summary: String
    let timestamp: String?
    let state: AmbitionVisualState
    let isFuture: Bool
}

struct GoalDetailTimelineState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailTimelineItemState]
}

struct GoalDetailAssumptionState: Identifiable, Sendable {
    let id: String
    let title: String
    let status: String
    let whyItMatters: String
    let correctionLabel: String?
    let state: AmbitionVisualState
}

struct GoalDetailProofRailState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalEvidenceItem]
    let spineBeads: [ProofBead]
    let emptyTitle: String
    let emptyMessage: String
}

struct GoalDetailReceiptItemState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalDetailReceiptsState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailReceiptItemState]
    let emptyTitle: String
    let emptyMessage: String
}

struct GoalDetailDecisionItemState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalDetailDecisionsState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailDecisionItemState]
    let emptyTitle: String
    let emptyMessage: String
}

enum GoalAlternatePathDecisionBranchKind: String, Sendable {
    case alternatePath
    case decisionHistory

    var title: String {
        switch self {
        case .alternatePath: "Alternate path"
        case .decisionHistory: "Decision history"
        }
    }

    var symbolName: String {
        switch self {
        case .alternatePath: "arrow.triangle.branch"
        case .decisionHistory: "clock.arrow.circlepath"
        }
    }
}

struct GoalAlternatePathDecisionBranchState: Identifiable, Sendable {
    let id: String
    let kind: GoalAlternatePathDecisionBranchKind
    let title: String
    let summary: String
    let basisLabel: String
    let reviewLabel: String
    let consequenceLabel: String
    let mutationBoundaryLabel: String
    let freshnessLabel: String
    let state: AmbitionVisualState
}

struct GoalAlternatePathDecisionSpineState: Sendable {
    let title: String
    let subtitle: String
    let branches: [GoalAlternatePathDecisionBranchState]
    let emptyTitle: String
    let emptyMessage: String
    let boundaryLabel: String
    let accessibilitySummary: String

    init(
        decisions: GoalDetailDecisionsState,
        pathBuilder: GoalPathBuilderState?
    ) {
        let alternateBranches = (pathBuilder?.forks ?? []).prefix(3).map { fork in
            GoalAlternatePathDecisionBranchState(
                id: "alternate-path-\(fork.id)",
                kind: .alternatePath,
                title: fork.title,
                summary: fork.summary,
                basisLabel: fork.basisSummary,
                reviewLabel: fork.decisionPrompt.localizedCaseInsensitiveContains("review")
                    ? fork.decisionPrompt
                    : "Review first: \(fork.decisionPrompt)",
                consequenceLabel: "Review tradeoffs before this branch changes Today or Plan.",
                mutationBoundaryLabel: "No automated reroute; no plan changed.",
                freshnessLabel: fork.freshnessLabel,
                state: fork.state
            )
        }

        let decisionBranches = decisions.items.prefix(4).map { item in
            GoalAlternatePathDecisionBranchState(
                id: "decision-history-\(item.id)",
                kind: .decisionHistory,
                title: item.title,
                summary: item.summary,
                basisLabel: "Recorded \(item.timestamp)",
                reviewLabel: "Review why this changed before using it as a route signal.",
                consequenceLabel: "This remains history unless the user changes the goal.",
                mutationBoundaryLabel: "No hidden path mutation.",
                freshnessLabel: "History",
                state: item.state
            )
        }

        let branches = Array((alternateBranches + decisionBranches).prefix(7))
        let boundaryLabel = "Review only. No automated reroute; no hidden plan or path mutation."

        self.title = "Decision Spine"
        self.subtitle = branches.isEmpty
            ? "Alternate path and decision history folds appear here when the goal has real signals."
            : "Alternate paths and real decisions stay folded together before anything changes."
        self.branches = branches
        self.emptyTitle = decisions.emptyTitle
        self.emptyMessage = decisions.emptyMessage
        self.boundaryLabel = boundaryLabel
        self.accessibilitySummary = branches.isEmpty
            ? "\(self.title). \(self.subtitle). \(boundaryLabel)"
            : branches.map {
                "\($0.kind.title): \($0.title). \($0.reviewLabel) \($0.mutationBoundaryLabel)"
            }.joined(separator: " ") + " \(boundaryLabel)"
    }
}

enum GoalDetailReviewTrailKind: String, Sendable {
    case proof
    case decision
    case assumption
    case receipt

    var title: String {
        switch self {
        case .proof: "Proof"
        case .decision: "Decision"
        case .assumption: "Assumption"
        case .receipt: "Receipt"
        }
    }

    var symbolName: String {
        switch self {
        case .proof: "checkmark.seal"
        case .decision: "arrow.triangle.branch"
        case .assumption: "scope"
        case .receipt: "doc.text.magnifyingglass"
        }
    }
}

struct GoalDetailReviewTrailItemState: Identifiable, Sendable {
    let id: String
    let kind: GoalDetailReviewTrailKind
    let title: String
    let summary: String
    let sourceLabel: String
    let reviewLabel: String
    let reversibilityLabel: String
    let state: AmbitionVisualState
}

struct GoalDetailReviewTrailState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailReviewTrailItemState]
    let accessibilitySummary: String
}

struct GoalDetailRiskState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let state: AmbitionVisualState
}

struct GoalDetailRisksState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailRiskState]
    let emptyTitle: String
    let emptyMessage: String
}

struct GoalDetailArchiveState: Sendable {
    let title: String
    let statusLabel: String
    let summary: String
    let learning: String
    let state: AmbitionVisualState
}

struct GoalDetailMissionControlState: Sendable {
    let currentTruth: String
    let primaryNextMove: GoalNextVisibleStep
    let sourceLabel: String
    let proofBoundaryLabel: String
    let ownershipLabel: String
    let breadcrumb: GoalDetailBreadcrumbState
    let lanes: [GoalDetailMissionLaneState]
    let timeline: GoalDetailTimelineState
    let assumptions: [GoalDetailAssumptionState]
    let proofRail: GoalDetailProofRailState
    let decisions: GoalDetailDecisionsState
    let risks: GoalDetailRisksState
    let archive: GoalDetailArchiveState
    let receipts: GoalDetailReceiptsState
}

extension GoalDetailMissionControlState {
    var reviewTrail: GoalDetailReviewTrailState {
        let proofSummary = proofRail.items.first.map {
            "\($0.title): \($0.subtitle)"
        } ?? proofRail.emptyMessage
        let decisionSummary = decisions.items.first.map {
            "\($0.title): \($0.summary)"
        } ?? decisions.emptyMessage
        let assumption = assumptions.first(where: { $0.state == .warning }) ?? assumptions.first
        let assumptionSummary = assumption.map {
            "\($0.title) \($0.status). \($0.whyItMatters)"
        } ?? "No assumptions are visible for review."
        let receiptSummary = receipts.items.first.map {
            "\($0.title): \($0.summary)"
        } ?? receipts.emptyMessage

        let items = [
            GoalDetailReviewTrailItemState(
                id: "review-proof",
                kind: .proof,
                title: proofRail.items.isEmpty ? proofRail.emptyTitle : "Proof attached",
                summary: proofSummary,
                sourceLabel: "Evidence",
                reviewLabel: "Review proof",
                reversibilityLabel: "Proof is attached when saved",
                state: proofRail.items.isEmpty ? .default : .selected
            ),
            GoalDetailReviewTrailItemState(
                id: "review-decision",
                kind: .decision,
                title: decisions.items.isEmpty ? decisions.emptyTitle : "Decision recorded",
                summary: decisionSummary,
                sourceLabel: "Decision",
                reviewLabel: "Review decision trail",
                reversibilityLabel: "Change reasons stay visible",
                state: decisions.items.isEmpty ? .default : .selected
            ),
            GoalDetailReviewTrailItemState(
                id: "review-assumption",
                kind: .assumption,
                title: assumption?.title ?? "No assumptions visible",
                summary: assumptionSummary,
                sourceLabel: "Assumption",
                reviewLabel: assumption?.correctionLabel.map { "Review: \($0)" } ?? "Review assumption",
                reversibilityLabel: "Review before changing the path",
                state: assumption?.state ?? .default
            ),
            GoalDetailReviewTrailItemState(
                id: "review-receipt",
                kind: .receipt,
                title: receipts.items.isEmpty ? receipts.emptyTitle : "Receipt recorded",
                summary: receiptSummary,
                sourceLabel: "Receipt",
                reviewLabel: "Review receipts",
                reversibilityLabel: "Reversibility only when available",
                state: receipts.items.isEmpty ? .default : .selected
            )
        ]

        return GoalDetailReviewTrailState(
            title: "Review trail",
            subtitle: "Proof, decisions, assumptions, and receipts stay separated before anything changes.",
            items: items,
            accessibilitySummary: items.map {
                "\($0.kind.title): \($0.title). \($0.summary). \($0.reversibilityLabel)"
            }.joined(separator: " ")
        )
    }
}

struct GoalClarificationState: Sendable {
    let title: String
    let subtitle: String
    let questions: [GoalClarificationQuestionState]
}

struct GoalBlockedState: Sendable {
    let title: String
    let subtitle: String
    let blockers: [String]
}

struct GoalDetailPresentation: Sendable {
    let target: GoalRouteTarget
    let headline: GoalDetailHeadline
    let outcome: String
    let intent: String
    let progress: GoalDetailProgress
    let strategicStatus: GoalDetailStrategicStatus
    let nextMovement: GoalDetailNextMovement?
    let trajectory: GoalDetailTrajectoryState
    let timingNote: String
    let progressNote: String
    let manualPriorityLabel: String
    let assumptions: [String]
    let suggestions: [GoalDetailStepItem]
    let pathStages: [GoalPathStage]
    let sections: [GoalDetailSectionState]
    let clarification: GoalClarificationState?
    let blocked: GoalBlockedState?
    let evidence: [GoalEvidenceItem]
    let history: [GoalFeedbackItem]
    let recentMovement: GoalDetailRecentMovementState
    let actions: [GoalDetailActionState]
    let explainability: GoalExplainabilityState?
    let primaryStepID: String?
    let canSwitchToUntimed: Bool
    let supportModeActive: Bool
    let defaultLens: GoalDetailLens
    let missionControl: GoalDetailMissionControlState?
    let pathBuilder: GoalPathBuilderState?

    init(
        target: GoalRouteTarget,
        headline: GoalDetailHeadline,
        outcome: String,
        intent: String,
        progress: GoalDetailProgress,
        strategicStatus: GoalDetailStrategicStatus,
        nextMovement: GoalDetailNextMovement?,
        trajectory: GoalDetailTrajectoryState,
        timingNote: String,
        progressNote: String,
        manualPriorityLabel: String,
        assumptions: [String],
        suggestions: [GoalDetailStepItem],
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        clarification: GoalClarificationState?,
        blocked: GoalBlockedState?,
        evidence: [GoalEvidenceItem],
        history: [GoalFeedbackItem],
        recentMovement: GoalDetailRecentMovementState,
        actions: [GoalDetailActionState],
        explainability: GoalExplainabilityState?,
        primaryStepID: String?,
        canSwitchToUntimed: Bool,
        supportModeActive: Bool,
        defaultLens: GoalDetailLens,
        missionControl: GoalDetailMissionControlState? = nil,
        pathBuilder: GoalPathBuilderState? = nil
    ) {
        self.target = target
        self.headline = headline
        self.outcome = outcome
        self.intent = intent
        self.progress = progress
        self.strategicStatus = strategicStatus
        self.nextMovement = nextMovement
        self.trajectory = trajectory
        self.timingNote = timingNote
        self.progressNote = progressNote
        self.manualPriorityLabel = manualPriorityLabel
        self.assumptions = assumptions
        self.suggestions = suggestions
        self.pathStages = pathStages
        self.sections = sections
        self.clarification = clarification
        self.blocked = blocked
        self.evidence = evidence
        self.history = history
        self.recentMovement = recentMovement
        self.actions = actions
        self.explainability = explainability
        self.primaryStepID = primaryStepID
        self.canSwitchToUntimed = canSwitchToUntimed
        self.supportModeActive = supportModeActive
        self.defaultLens = defaultLens
        self.missionControl = missionControl
        self.pathBuilder = pathBuilder
    }

    func screenContractSnapshot(
        topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs
    ) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .goalDetail,
            firstScreenContent: [
                "Object identity header",
                "Goal detail lanes"
            ],
            panels: [
                .objectIdentityHeader,
                .missionControlLanes,
                .progress,
                .timeline,
                .proofRail,
                .recovery,
                .trust,
                .receipt
            ],
            actions: [.startStep, .addProof, .changePath, .park, .archive],
            drillDowns: GoalDetailMissionLaneKind.allCases.map(\.title),
            copySamples: [
                headline.title,
                headline.subtitle,
                strategicStatus.title,
                strategicStatus.summary,
                missionControl?.lanes.map(\.title).joined(separator: " ") ?? "",
                missionControl?.proofRail.title ?? "",
                missionControl?.decisions.title ?? "",
                missionControl?.risks.title ?? "",
                missionControl?.archive.title ?? "",
                missionControl?.receipts.title ?? "",
                pathBuilder?.title ?? "",
                pathBuilder?.todayConnectionTitle ?? ""
            ],
            topLevelTabTitles: topLevelTabTitles,
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: missionControl?.lanes.isEmpty == false,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )
    }
}
