import Foundation

public enum AmbitionsSurface: String, CaseIterable, Sendable, Codable {
    case today
    case goals
    case time
    case you
}

public enum AmbitionsPrimaryObject: String, CaseIterable, Sendable, Codable {
    case realityMeridian
    case constellationAtlas
    case atmosphereComposer
    case lifeShapeField
    case userSystemProfile
}

public enum AmbitionsDecisionLayer: String, CaseIterable, Sendable, Codable {
    case startHere
    case receipt
    case closure
    case trust
}

public enum AmbitionsHardContext: String, CaseIterable, Sendable, Codable {
    case work
    case school
    case event
    case commute
    case protected
    case away
    case open
}

public enum AmbitionsAvailabilityContext: String, CaseIterable, Sendable, Codable {
    case free
    case flexible
    case constrained
    case unavailable
}

public enum AmbitionsCognitiveContext: String, CaseIterable, Sendable, Codable {
    case deepWork
    case admin
    case creative
    case recovery
    case social
    case neutral
}

public enum AmbitionsActionClosureState: String, CaseIterable, Sendable, Codable {
    case completed
    case stillCounts
    case moved
    case skippedNotNeeded
    case blocked
    case waiting
    case needsRecovery
    case needsReview
}

public enum AmbitionsSourceQuality: Int, CaseIterable, Sendable, Codable, Comparable {
    case directUserCommitment = 100
    case acceptedSchedule = 90
    case calendarEvent = 80
    case recentClosure = 70
    case historicalPattern = 60
    case inferredContext = 40
    case staleSignal = 20

    public static func < (lhs: AmbitionsSourceQuality, rhs: AmbitionsSourceQuality) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct AmbitionsSurfaceContract: Equatable, Sendable, Codable {
    public let surface: AmbitionsSurface
    public let primaryObject: AmbitionsPrimaryObject
    public let decisionLayers: [AmbitionsDecisionLayer]
    public let requiresProofPath: Bool
    public let requiresClosurePath: Bool

    public init(
        surface: AmbitionsSurface,
        primaryObject: AmbitionsPrimaryObject,
        decisionLayers: [AmbitionsDecisionLayer],
        requiresProofPath: Bool,
        requiresClosurePath: Bool
    ) {
        self.surface = surface
        self.primaryObject = primaryObject
        self.decisionLayers = decisionLayers
        self.requiresProofPath = requiresProofPath
        self.requiresClosurePath = requiresClosurePath
    }
}

public enum AmbitionsSurfaceContracts {
    public static let canonical: [AmbitionsSurface: AmbitionsSurfaceContract] = [
        .today: .init(surface: .today, primaryObject: .realityMeridian, decisionLayers: [.startHere, .receipt, .closure, .trust], requiresProofPath: true, requiresClosurePath: true),
        .goals: .init(surface: .goals, primaryObject: .constellationAtlas, decisionLayers: [.receipt, .trust], requiresProofPath: true, requiresClosurePath: false),
        .time: .init(surface: .time, primaryObject: .lifeShapeField, decisionLayers: [.receipt, .trust], requiresProofPath: true, requiresClosurePath: false),
        .you: .init(surface: .you, primaryObject: .userSystemProfile, decisionLayers: [.trust], requiresProofPath: true, requiresClosurePath: false)
    ]

    public static func contract(for surface: AmbitionsSurface) -> AmbitionsSurfaceContract {
        canonical[surface]!
    }
}
