import Foundation

protocol SurfaceLens {
    associatedtype Input
    associatedtype Output

    static var contract: SurfaceLensContract { get }
    static func project(_ input: Input) -> Output
}

struct SurfaceLensContract: Equatable, Sendable {
    let surface: StageMutationTargetSurface
    let surfaceTitle: String
    let primaryObjectTitle: String
    let primaryActionTitle: String
    let runtimeInputs: [String]
    let firstViewportContract: String
    let accessibilityContract: [String]
    let trustInspectionRequirements: [String]
    let failureStateRequirements: [String]

    var satisfiesFinalCanon: Bool {
        surfaceTitle.isEmpty == false &&
            primaryObjectTitle.isEmpty == false &&
            primaryActionTitle.isEmpty == false &&
            runtimeInputs.isEmpty == false &&
            firstViewportContract.localizedCaseInsensitiveContains(primaryObjectTitle) &&
            accessibilityContract.isEmpty == false &&
            trustInspectionRequirements.contains("source") &&
            trustInspectionRequirements.contains("proof") &&
            trustInspectionRequirements.contains("receipt") &&
            failureStateRequirements.isEmpty == false
    }
}

struct SurfaceLensReport: Equatable, Sendable {
    let contract: SurfaceLensContract
    let primaryObjectSummary: String
    let primaryActionSummary: String
    let visibleStateSummary: String
    let accessibilitySummary: String
    let trustSummary: String
    let failureStateSummary: String

    var isProductionReady: Bool {
        contract.satisfiesFinalCanon &&
            primaryObjectSummary.isEmpty == false &&
            primaryActionSummary.isEmpty == false &&
            visibleStateSummary.isEmpty == false &&
            accessibilitySummary.isEmpty == false &&
            trustSummary.isEmpty == false &&
            failureStateSummary.isEmpty == false
    }
}

enum SurfaceLensRegistry {
    static let canonicalContracts: [SurfaceLensContract] = [
        TodayLens.contract,
        GoalsLens.contract,
        TimeLens.contract,
        YouLens.contract
    ]

    static func contract(for surface: StageMutationTargetSurface) -> SurfaceLensContract {
        guard let contract = canonicalContracts.first(where: { $0.surface == surface }) else {
            preconditionFailure("Missing canonical surface lens for \(surface.rawValue)")
        }
        return contract
    }

    static func validate(_ contracts: [SurfaceLensContract] = canonicalContracts) -> [String] {
        var issues: [String] = []
        let expected: [StageMutationTargetSurface] = [.today, .goals, .time, .you]

        if contracts.map(\.surface) != expected {
            issues.append("Surface lenses must be ordered Today, Goals, Time, You.")
        }

        for surface in expected {
            guard let contract = contracts.first(where: { $0.surface == surface }) else {
                issues.append("Missing \(surface.rawValue) surface lens.")
                continue
            }
            if contract.satisfiesFinalCanon == false {
                issues.append("\(surface.rawValue) surface lens is missing a final-canon object, action, state, accessibility, trust, or failure contract.")
            }
        }

        let forbiddenRoots = Set(["Capture", "Motion"])
        let rootTitles = Set(contracts.map(\.surfaceTitle))
        if rootTitles.intersection(forbiddenRoots).isEmpty == false {
            issues.append("Surface lenses must not expose Capture or Motion as top-level roots.")
        }

        return issues
    }
}
