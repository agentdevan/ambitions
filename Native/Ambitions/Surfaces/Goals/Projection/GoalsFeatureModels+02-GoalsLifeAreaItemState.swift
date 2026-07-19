import AmbitionsDesignSystem
import Foundation

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
    let isDefaultFixture: Bool
    let controlSummary: String
    let todayTraceSummary: String
    let openThreadLabel: String
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
    let controls: [GoalsLifeAreaControlState]
    let supportsListFallback: Bool
    let maxVisibleAreas: Int
    let equalWeightSummary: String
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
            controls: [],
            supportsListFallback: true,
            maxVisibleAreas: 6,
            equalWeightSummary: "Life Areas remain equal-weight by default.",
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
            subtitle: "One-Step Goals that do not need a fuller goal yet.",
            items: [],
            openCount: 0,
            parkedCount: 0,
            emptyTitle: "No One-Step Goals yet",
            emptyMessage: "Small standalone work can stay here without becoming a full goal.",
            accessibilityLabel: "One-Step Goals",
            accessibilityValue: "No One-Step Goals yet.",
            accessibilityHint: "One-Step Goals can stand alone. Steps stay inside Goals or Paths."
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

struct GoalsAtlasSurfaceState: Identifiable, Sendable {
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
    let cards: [GoalsAtlasSurfaceState]

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
    let cards: [GoalsAtlasSurfaceState]
}

struct GoalsOrbitalLensState: Sendable {
    let title: String
    let collapsedSummary: String
    let selectedLifeAreaTitle: String
    let selectedLifeAreaSummary: String
    let activeThreadTitle: String
    let recommendedStepTitle: String
    let feedsTodaySummary: String
    let proofSummary: String
    let sourceSummary: String
    let whyThisSummary: String
    let statusSummary: String
    let openThreadLabel: String
    let target: GoalRouteTarget?
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String

    static var empty: GoalsOrbitalLensState {
        GoalsOrbitalLensState(
            title: "Thread Focus",
            collapsedSummary: "Select a life area or goal thread to inspect the direction state.",
            selectedLifeAreaTitle: "No selected Life Area",
            selectedLifeAreaSummary: "The lens will attach to the clearest Life Area once source exists.",
            activeThreadTitle: "No active thread yet",
            recommendedStepTitle: "No recommended step yet",
            feedsTodaySummary: "Today trace will appear when a thread feeds execution.",
            proofSummary: "Proof stays thin until evidence or receipts exist.",
            sourceSummary: "Source will remain local and inspectable.",
            whyThisSummary: "Thread Focus avoids pretending certainty before the direction has source.",
            statusSummary: "Quiet",
            openThreadLabel: "Open thread when ready",
            target: nil,
            accessibilityLabel: "Thread Focus",
            accessibilityValue: "No selected Life Area or active goal thread yet.",
            accessibilityHint: "Expands inspection without leaving Your Direction."
        )
    }
}
