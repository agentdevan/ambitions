import AmbitionsDesignSystem
import Foundation

enum FlagshipObjectStateOwner: String, CaseIterable, Sendable, Equatable {
    case startHere
    case realityRail
    case missionControlTimeSpine
    case proofSpine
    case capturePlacementShelf
    case lifeShapeContourMap
    case personalSystemCenter
    case memoryLens

    var title: String {
        switch self {
        case .startHere: "Start Here"
        case .realityRail: "Reality Meridian"
        case .missionControlTimeSpine: "Your Direction"
        case .proofSpine: "Proof Spine"
        case .capturePlacementShelf: "Atmosphere Composer"
        case .lifeShapeContourMap: "LifeShape Field"
        case .personalSystemCenter: "User System Profile"
        case .memoryLens: "Search"
        }
    }

    var icon: String {
        switch self {
        case .startHere: "scope"
        case .realityRail: "point.3.connected.trianglepath.dotted"
        case .missionControlTimeSpine: "arrow.triangle.branch"
        case .proofSpine: "checkmark.seal"
        case .capturePlacementShelf: "tray.and.arrow.down"
        case .lifeShapeContourMap: "map"
        case .personalSystemCenter: "person.crop.circle"
        case .memoryLens: "memories"
        }
    }

    var loadingExplanation: String {
        switch self {
        case .startHere:
            "Ambitions is preserving the Start Here slot while it reads the local day."
        case .realityRail:
            "The rail keeps its order while local steps, waiting points, and recovery signals settle."
        case .missionControlTimeSpine:
            "Goals keeps the direction object stable while life areas, proof, pressure, and recommended steps load."
        case .proofSpine:
            "Proof stays hidden until source, freshness, privacy, and correction posture are ready."
        case .capturePlacementShelf:
            "Capture keeps the Atmosphere Composer available while placement, privacy, and correction signals settle."
        case .lifeShapeContourMap:
            "Time preserves the LifeShape Field while capacity, pressure, and protected pockets load."
        case .personalSystemCenter:
            "You keeps Your System stable while setup, trust, privacy, receipts, and defaults load."
        case .memoryLens:
            "Search waits for local source age, privacy, and correction posture before showing detail."
        }
    }

    var emptyExplanation: String {
        switch self {
        case .startHere:
            "No recommended step fits right now. Ambitions will stay quiet instead of inventing urgency."
        case .realityRail:
            "The Reality Meridian can stay open; quiet space is part of the day."
        case .missionControlTimeSpine:
            "Your Direction waits for a goal thread with enough shape to inspect."
        case .proofSpine:
            "No proof is shown until the user saves evidence or a local receipt exists."
        case .capturePlacementShelf:
            "The composer stays quiet until something needs a place."
        case .lifeShapeContourMap:
            "The LifeShape Field can stay open when no real pressure needs shaping."
        case .personalSystemCenter:
            "Your System starts with profile, defaults, privacy, and history controls."
        case .memoryLens:
            "Search stays quiet until local evidence makes recall useful."
        }
    }

    var degradedExplanation: String {
        switch self {
        case .startHere:
            "Start Here can retry without moving commitments or pretending the recommendation is current."
        case .realityRail:
            "The rail stays readable and does not silently reorder steps while source state is uncertain."
        case .missionControlTimeSpine:
            "Goals can retry without changing the path, decisions, or proof."
        case .proofSpine:
            "Proof remains review-bound until source freshness and privacy posture are clear."
        case .capturePlacementShelf:
            "Capture can keep the text local and wait for placement review instead of saving silently."
        case .lifeShapeContourMap:
            "Time can retry without reshaping protected time or writing calendar changes."
        case .personalSystemCenter:
            "You can retry without changing setup, trust, memory, or receipts."
        case .memoryLens:
            "Search hides detail until stale or sensitive source state is reviewed."
        }
    }
}

struct FlagshipObjectStateMatrixEntry: Identifiable, Sendable, Equatable {
    let owner: FlagshipObjectStateOwner
    let normalState: AmbitionsLoadingState
    let loadingState: AmbitionsLoadingState
    let emptyState: AmbitionsLoadingState
    let degradedState: AmbitionsLoadingState
    let boundary: String

    var id: String { owner.rawValue }

    var accessibilitySummary: String {
        "\(owner.title). Normal: \(normalState.title). Loading: \(loadingState.title). Empty: \(emptyState.title). Degraded: \(degradedState.title). \(boundary)"
    }
}

enum FlagshipObjectStateMatrix {
    static let entries: [FlagshipObjectStateMatrixEntry] = FlagshipObjectStateOwner.allCases.map { owner in
        FlagshipObjectStateMatrixEntry(
            owner: owner,
            normalState: .localOnly,
            loadingState: .loading,
            emptyState: owner == .proofSpine || owner == .memoryLens ? .noDataYet : .empty,
            degradedState: degradedState(for: owner),
            boundary: boundary(for: owner)
        )
    }

    static func entry(for owner: FlagshipObjectStateOwner) -> FlagshipObjectStateMatrixEntry {
        entries.first { $0.owner == owner }!
    }

    private static func degradedState(for owner: FlagshipObjectStateOwner) -> AmbitionsLoadingState {
        switch owner {
        case .proofSpine, .memoryLens:
            .staleSource
        case .capturePlacementShelf, .lifeShapeContourMap, .missionControlTimeSpine:
            .needsReview
        case .startHere, .realityRail:
            .recovery
        case .personalSystemCenter:
            .privacySensitive
        }
    }

    private static func boundary(for owner: FlagshipObjectStateOwner) -> String {
        switch owner {
        case .startHere, .realityRail:
            "Progress stays source-bound, recovery stays non-shaming, and there is no silent commitment mutation."
        case .missionControlTimeSpine:
            "Routes stay user-reviewed, path changes stay visible, and thread detail stays out of project-board posture."
        case .proofSpine:
            "Proof stays source-bound and never becomes a trophy shelf, activity feed, or certification claim."
        case .capturePlacementShelf:
            "Capture stays composer-first with review before placement, learning, or goal creation."
        case .lifeShapeContourMap:
            "Time stays contour-first with reviewed reflow and grounded time language."
        case .personalSystemCenter:
            "Setup, trust, memory, and receipts stay explicit and user-owned."
        case .memoryLens:
            "Recall stays source-bound, privacy-preserving, and correction-ready."
        }
    }
}
