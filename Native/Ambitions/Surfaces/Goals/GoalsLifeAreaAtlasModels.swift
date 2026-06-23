import AmbitionsDesignSystem
import Foundation

struct GoalsLifeAreaAtlasRegion: Identifiable, Hashable {
    let id: String
    let title: String
    let symbolName: String
    let summary: String
    let activeGoalCount: Int
    let looseStepCount: Int
    let thoughtCount: Int
    let proofCount: Int
    let receiptCount: Int
    let goalReferences: [GoalAtlasPreviewItem]
    let state: AmbitionVisualState
    let isOpenField: Bool
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String

    var hasActivity: Bool {
        activeGoalCount > 0 || looseStepCount > 0 || thoughtCount > 0 || proofCount > 0 || receiptCount > 0 || goalReferences.isEmpty == false
    }

    var primaryCountLabel: String {
        if activeGoalCount > 0 {
            return "\(activeGoalCount) active"
        }
        if looseStepCount > 0 {
            return "\(looseStepCount) steps"
        }
        if thoughtCount > 0 {
            return "\(thoughtCount) thoughts"
        }
        return "Quiet"
    }

    var firstGoalTarget: GoalRouteTarget? {
        guard let reference = goalReferences.first else { return nil }
        return GoalRouteTarget(goalID: reference.id)
    }

    static func regions(from overview: GoalsOverview) -> [GoalsLifeAreaAtlasRegion] {
        let items = overview.lifeAreas.items
        let regions = blueprint.map { blueprint in
            let item = items.first { blueprint.matches($0) }
            let activeGoalCount = item?.activeGoalCount ?? 0
            let looseStepCount = item?.oneStepGoalCount ?? 0
            let proofCount = item?.proofCount ?? 0
            let receiptCount = item?.receiptCount ?? 0
            let goalReferences = item?.goalReferences ?? []
            let state: AmbitionVisualState = {
                if activeGoalCount > 0 { return .selected }
                if looseStepCount > 0 || proofCount > 0 || receiptCount > 0 || goalReferences.isEmpty == false { return .default }
                return .default
            }()
            let value = [
                activeGoalCount > 0 ? "\(activeGoalCount) active goals" : nil,
                looseStepCount > 0 ? "\(looseStepCount) loose steps" : nil,
                proofCount > 0 ? "\(proofCount) proof stitches" : nil,
                receiptCount > 0 ? "\(receiptCount) receipts" : nil,
                activeGoalCount == 0 && looseStepCount == 0 && proofCount == 0 && receiptCount == 0 ? "empty" : nil
            ].compactMap { $0 }.joined(separator: ", ")

            return GoalsLifeAreaAtlasRegion(
                id: blueprint.id,
                title: blueprint.title,
                symbolName: blueprint.symbolName,
                summary: item?.nextFocus.isEmpty == false ? item?.nextFocus ?? blueprint.emptySummary : blueprint.emptySummary,
                activeGoalCount: activeGoalCount,
                looseStepCount: looseStepCount,
                thoughtCount: 0,
                proofCount: proofCount,
                receiptCount: receiptCount,
                goalReferences: goalReferences,
                state: state,
                isOpenField: false,
                accessibilityLabel: "\(blueprint.title) life area",
                accessibilityValue: value,
                accessibilityHint: "Opens full-screen area detail."
            )
        }

        return regions + [openFieldRegion(from: overview)]
    }

    static func region(id: String, in overview: GoalsOverview) -> GoalsLifeAreaAtlasRegion? {
        regions(from: overview).first { $0.id == id }
    }

    private static func openFieldRegion(from overview: GoalsOverview) -> GoalsLifeAreaAtlasRegion {
        GoalsLifeAreaAtlasRegion(
            id: "open-field",
            title: "Open Field",
            symbolName: "sparkles.rectangle.stack",
            summary: overview.emptyMessage.isEmpty ? "Unplaced captures and thoughts can wait here without becoming clutter." : overview.emptyMessage,
            activeGoalCount: 0,
            looseStepCount: overview.oneStepGoals.openCount,
            thoughtCount: 0,
            proofCount: 0,
            receiptCount: 0,
            goalReferences: [],
            state: .default,
            isOpenField: true,
            accessibilityLabel: "Open Field",
            accessibilityValue: overview.oneStepGoals.openCount > 0 ? "\(overview.oneStepGoals.openCount) loose steps" : "empty",
            accessibilityHint: "Opens the holding area for unplaced captures, steps, and thoughts."
        )
    }

    private static let blueprint: [GoalsLifeAreaBlueprint] = [
        GoalsLifeAreaBlueprint(id: "work", title: "Work", symbolName: "briefcase", emptySummary: "Direction for work, craft, and contribution.", aliases: ["work", "career"]),
        GoalsLifeAreaBlueprint(id: "body", title: "Body", symbolName: "figure.mind.and.body", emptySummary: "Health, energy, care, and recovery.", aliases: ["body", "health"]),
        GoalsLifeAreaBlueprint(id: "home", title: "Home", symbolName: "house", emptySummary: "The place, systems, and responsibilities around home.", aliases: ["home"]),
        GoalsLifeAreaBlueprint(id: "people", title: "People", symbolName: "person.2", emptySummary: "Relationships, care, and shared life.", aliases: ["people", "relationships"]),
        GoalsLifeAreaBlueprint(id: "self", title: "Self", symbolName: "person.crop.circle", emptySummary: "Identity, reflection, and becoming more yourself.", aliases: ["self", "personal_growth", "personal growth"]),
        GoalsLifeAreaBlueprint(id: "future", title: "Future", symbolName: "map", emptySummary: "Longer direction that is not ready to become active yet.", aliases: ["future", "education", "finance", "creativity"])
    ]
}

private struct GoalsLifeAreaBlueprint: Hashable {
    let id: String
    let title: String
    let symbolName: String
    let emptySummary: String
    let aliases: Set<String>

    init(id: String, title: String, symbolName: String, emptySummary: String, aliases: [String]) {
        self.id = id
        self.title = title
        self.symbolName = symbolName
        self.emptySummary = emptySummary
        self.aliases = Set(aliases.map(Self.normalize))
    }

    func matches(_ item: GoalsLifeAreaItemState) -> Bool {
        aliases.contains(Self.normalize(item.id)) || aliases.contains(Self.normalize(item.title))
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
    }
}
