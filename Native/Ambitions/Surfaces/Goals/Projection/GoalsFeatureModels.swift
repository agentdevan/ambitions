import AmbitionsDesignSystem
import Foundation

enum GoalDetailLens: String, CaseIterable, Hashable, Sendable {
    // This lens displays contained Goal/Path/Plan steps.
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
        case .atRisk: "At risk"
        case .lowerPriority: "Lower priority"
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

enum GoalsScreenshotProofState: String, Hashable, Sendable {
    case defaultAtlas = "default"
    case selectedLifeArea = "selected-life-area"
    case orbitalLensExpanded = "orbital-lens-expanded"
    case proofAvailable = "proof-available"

    var expandsOrbitalLens: Bool {
        switch self {
        case .defaultAtlas, .selectedLifeArea:
            false
        case .orbitalLensExpanded, .proofAvailable:
            true
        }
    }

    var prioritizesOrbitalLens: Bool {
        switch self {
        case .defaultAtlas, .selectedLifeArea:
            false
        case .orbitalLensExpanded, .proofAvailable:
            true
        }
    }

    var highlightsSelectedLifeArea: Bool {
        switch self {
        case .defaultAtlas, .orbitalLensExpanded, .proofAvailable:
            false
        case .selectedLifeArea:
            true
        }
    }

    var highlightsProof: Bool {
        switch self {
        case .defaultAtlas, .selectedLifeArea, .orbitalLensExpanded:
            false
        case .proofAvailable:
            true
        }
    }

    static func fromLaunchArguments(_ arguments: [String] = ProcessInfo.processInfo.arguments) -> GoalsScreenshotProofState {
        guard let flagIndex = arguments.firstIndex(of: "-AmbitionsGoalsRenderState"),
              arguments.indices.contains(arguments.index(after: flagIndex)) else {
            return .defaultAtlas
        }

        let value = arguments[arguments.index(after: flagIndex)].lowercased()
        return GoalsScreenshotProofState(rawValue: value) ?? .defaultAtlas
    }
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
        let stuck = GoalPortfolioMaturitySignal(id: "stuck-work", title: "No stuck work is loud", detail: "No blockers, waiting states, or overloaded One-Step Goals are driving the atlas.", state: .selected)
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

struct GoalsLifeAreaControlState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let systemImage: String
    let accessibilityHint: String
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
