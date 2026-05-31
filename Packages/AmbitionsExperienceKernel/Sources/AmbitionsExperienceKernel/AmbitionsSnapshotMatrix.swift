import Foundation

public enum AmbitionsSnapshotVariant: String, CaseIterable, Sendable, Codable {
    case normal
    case constrained
    case protected
    case recovery
    case staleProof
    case privacyBoundary
    case dynamicTypeXXL
    case reduceMotion
}

public struct AmbitionsSnapshotRequirement: Equatable, Identifiable, Sendable, Codable {
    public var id: String { surface.rawValue + "." + variant.rawValue }
    public let surface: AmbitionsSurface
    public let variant: AmbitionsSnapshotVariant
    public let requiresVoiceOver: Bool
    public let requiresMotionReview: Bool
    public let requiresContrastReview: Bool

    public init(surface: AmbitionsSurface, variant: AmbitionsSnapshotVariant, requiresVoiceOver: Bool = true, requiresMotionReview: Bool = true, requiresContrastReview: Bool = true) {
        self.surface = surface
        self.variant = variant
        self.requiresVoiceOver = requiresVoiceOver
        self.requiresMotionReview = requiresMotionReview
        self.requiresContrastReview = requiresContrastReview
    }
}

public enum AmbitionsSnapshotMatrix {
    public static let required: [AmbitionsSnapshotRequirement] = AmbitionsSurface.allCases.flatMap { surface in
        AmbitionsSnapshotVariant.allCases.map { variant in
            AmbitionsSnapshotRequirement(surface: surface, variant: variant)
        }
    }
}
