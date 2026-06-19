import AmbitionsDesignSystem
import Foundation

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
    let orbitalLens: GoalsOrbitalLensState
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
        orbitalLens: GoalsOrbitalLensState = .empty,
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
        self.orbitalLens = orbitalLens
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
                "Thread Focus",
                "Source",
                "Receipt",
                "Reason",
                "Feeds Today",
                "Proof available",
                "Source",
                "Why this?",
                "Open thread",
                "Recently moved",
                "Needs recovery",
                "Pinned area",
                "Active goals"
            ],
            panels: [.progress, .lifeAreas, .oneStepGoals, .goalLifecycleRail, .northStarsRail],
            actions: [.openGoal, .createGoal, .promoteTask, .reviewParked],
            drillDowns: ["Goal Detail", "Life Areas Overview", "North Star Detail", "Archive"],
            copySamples: [
                hero.title,
                hero.subtitle,
                lifeAreas.title,
                lifeAreas.subtitle,
                orbitalLens.selectedLifeAreaTitle,
                orbitalLens.activeThreadTitle,
                orbitalLens.whyThisSummary,
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
            "Source: \(constellationAtlasSourceRecordSummary)",
            "Receipt: \(constellationAtlasReceiptSummary)",
            "Reason: \(constellationAtlasReplayTraceSummary)",
            "You / Search Ambitions: \(constellationAtlasYouSummary)"
        ].joined(separator: " · ")
    }

    var constellationAtlasAccessibilityValue: String {
        [
            "Your Direction.",
            constellationAtlasSourceRecordSummary,
            constellationAtlasReceiptSummary,
            constellationAtlasReplayTraceSummary,
            constellationAtlasYouSummary
        ].joined(separator: " ")
    }

    var constellationAtlasCompactInspectionSummary: String {
        "Source, proof receipts, reason, and Today connection stay inspectable through You."
    }

    var constellationAtlasFirstViewportTrustSummary: String {
        "Source, proof, reason, Today link, and You stay visible."
    }

    var constellationAtlasSourceFirstViewportSummary: String {
        "Reason and Today link visible."
    }

    var constellationAtlasProofFirstViewportSummary: String {
        "Proof receipt visible."
    }

    var constellationAtlasSourceRecordSummary: String {
        let visibleGoalCount = bands.reduce(0) { $0 + $1.cards.count }
        let areaCount = lifeAreas.contentAreaCount

        if areaCount == 0 {
            return "\(visibleGoalCount) visible goal threads are arranged from local Goals, drafts, evidence, and capture records."
        }

        return "\(visibleGoalCount) visible goal threads stay grouped across \(areaCount) Life Areas from local Goals, drafts, evidence, and capture records."
    }

    var constellationAtlasReceiptSummary: String {
        let proofCount = lifeAreas.items.reduce(0) { $0 + $1.proofCount }
        let receiptCount = lifeAreas.items.reduce(0) { $0 + $1.receiptCount }

        if proofCount == 0 && receiptCount == 0 {
            return "proof and closure receipts are still thin, so the atlas avoids pretending certainty."
        }

        return "\(proofCount) proof points and \(receiptCount) closure receipts are visible before the atlas asks for more commitment."
    }

    var constellationAtlasReplayTraceSummary: String {
        let primaryLaneTitles = bands
            .filter { $0.cards.isEmpty == false }
            .map(\.title)
            .prefix(3)
            .joined(separator: ", ")
        let visibleLanes = primaryLaneTitles.isEmpty ? "quiet lanes" : primaryLaneTitles

        return "\(visibleLanes) explain why each goal is active, pressured, or quieter."
    }

    var constellationAtlasYouSummaryForProjection: String {
        let activeArea = lifeAreas.items.first {
            $0.activeGoalCount > 0 || $0.parkedGoalCount > 0 || $0.goalThreadCount > 0 || $0.proofCount > 0 || $0.receiptCount > 0
        } ?? lifeAreas.items.first

        if let activeArea {
            return "\(activeArea.title) is the clearest Life Area connection, and Thread Focus keeps one real thread connected to Today."
        }

        return "Thread Focus keeps the clearest available thread connected to Today without adding another top-level destination."
    }

    var constellationAtlasYouSummary: String {
        constellationAtlasYouSummaryForProjection
    }
}

// Compatibility aliases retained for older callers and previews that still import Board names.
typealias GoalsBoardPosture = GoalsAtlasPosture
typealias GoalsBoardBandKind = GoalsAtlasBandKind
typealias GoalsBoardPrimaryActionKind = GoalsAtlasPrimaryActionKind
typealias GoalsBoardHeroState = GoalsAtlasHeroState
typealias GoalsBoardPrimaryAction = GoalsAtlasPrimaryAction
typealias GoalsBoardCardState = GoalsAtlasSurfaceState
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
