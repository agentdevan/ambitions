#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionsAdaptiveAxis: String, CaseIterable, Identifiable, Sendable {
    case dynamicType
    case voiceOver
    case reduceMotion
    case nonColorMeaning
    case tapTarget
    case privacySafeExposure
    case cognitiveLoad

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dynamicType: "Dynamic Type"
        case .voiceOver: "VoiceOver"
        case .reduceMotion: "Reduce Motion"
        case .nonColorMeaning: "Non-color meaning"
        case .tapTarget: "Tap target"
        case .privacySafeExposure: "Privacy-safe exposure"
        case .cognitiveLoad: "Cognitive load"
        }
    }
}

public enum AmbitionsAccessibilityResponsibilityScope: String, CaseIterable, Identifiable, Sendable {
    case globalHelper
    case primitiveResponsibility
    case surfaceSpecific

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .globalHelper:
            return "Global helper"
        case .primitiveResponsibility:
            return "Primitive responsibility"
        case .surfaceSpecific:
            return "Surface-specific"
        }
    }

    public var summary: String {
        switch self {
        case .globalHelper:
            return "Global helper-level adaptation that remains stable across surfaces."
        case .primitiveResponsibility:
            return "Feature-specific primitive strategy shared by surface components."
        case .surfaceSpecific:
            return "Surface-owned detail that must be implemented by each primary object owner."
        }
    }
}

public enum AmbitionsPrimaryObjectSurface: String, CaseIterable, Identifiable, Sendable {
    case today = "todayRealityMeridian"
    case goals = "goalsConstellationAtlas"
    case time = "timeLifeShapeField"
    case motion = "motionCurrent"
    case you = "youSystemProfile"
    case capture = "captureAtmosphereComposer"

    public var id: String { rawValue }

    public var objectTitle: String {
        switch self {
        case .today: "Today / Reality Meridian"
        case .goals: "Goals / Constellation Atlas"
        case .time: "Time / LifeShape Field"
        case .motion: "Motion / Motion Current"
        case .you: "You / User System Profile"
        case .capture: "Global Capture / Atmosphere Composer"
        }
    }
}

public struct AmbitionsPrimaryObjectAccessibilitySummary: Identifiable, Hashable, Sendable {
    public let surface: AmbitionsPrimaryObjectSurface
    public let activeObjectSummary: String
    public let dynamicTypeStrategy: String
    public let staticMotionEquivalent: String
    public let expandedHitAreaStrategy: String
    public let contrastTransparencyStrategy: String

    public var id: String { surface.rawValue }

    public init(
        surface: AmbitionsPrimaryObjectSurface,
        activeObjectSummary: String,
        dynamicTypeStrategy: String,
        staticMotionEquivalent: String,
        expandedHitAreaStrategy: String,
        contrastTransparencyStrategy: String
    ) {
        self.surface = surface
        self.activeObjectSummary = activeObjectSummary
        self.dynamicTypeStrategy = dynamicTypeStrategy
        self.staticMotionEquivalent = staticMotionEquivalent
        self.expandedHitAreaStrategy = expandedHitAreaStrategy
        self.contrastTransparencyStrategy = contrastTransparencyStrategy
    }
}

public enum AmbitionsAdaptiveReviewLane: String, CaseIterable, Identifiable, Sendable {
    case sourceReview
    case privacySensitive
    case professionalBoundary
    case crisisSupport
    case overloadedDay
    case recovery
    case emptyOrNoData

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .sourceReview: "Source review"
        case .privacySensitive: "Privacy-sensitive"
        case .professionalBoundary: "Professional boundary"
        case .crisisSupport: "Crisis support"
        case .overloadedDay: "Overloaded day"
        case .recovery: "Recovery"
        case .emptyOrNoData: "Empty or no data"
        }
    }

    public var loadingState: AmbitionsLoadingState {
        switch self {
        case .sourceReview: .sourceConflict
        case .privacySensitive: .privacySensitive
        case .professionalBoundary: .needsReview
        case .crisisSupport: .crisisSupport
        case .overloadedDay: .overwhelmingDay
        case .recovery: .recovery
        case .emptyOrNoData: .noDataYet
        }
    }

    public var statusRole: AmbitionsStatusSymbolRole {
        switch self {
        case .sourceReview: .sourceConflict
        case .privacySensitive: .privacySensitive
        case .professionalBoundary: .professionalBoundary
        case .crisisSupport: .crisisSupport
        case .overloadedDay: .pressureRising
        case .recovery: .recoveryAvailable
        case .emptyOrNoData: .noDataYet
        }
    }

    public var cognitiveLoadMode: AmbitionCognitiveLoadMode {
        switch self {
        case .sourceReview, .professionalBoundary, .privacySensitive:
            return .calm
        case .crisisSupport, .overloadedDay, .recovery:
            return .recovery
        case .emptyOrNoData:
            return .balanced
        }
    }

    public var isFutureLDIVisualHook: Bool {
        switch self {
        case .sourceReview, .privacySensitive, .professionalBoundary, .crisisSupport:
            return true
        case .overloadedDay, .recovery, .emptyOrNoData:
            return false
        }
    }
}

public struct AmbitionsAdaptiveRequirement: Identifiable, Hashable, Sendable {
    public let lane: AmbitionsAdaptiveReviewLane
    public let axis: AmbitionsAdaptiveAxis
    public let visibleFallback: String
    public let voiceOverSummary: String
    public let responsibilityScope: AmbitionsAccessibilityResponsibilityScope
    public let responsibilitySummary: String
    public let reduceMotionEquivalent: String
    public let manualProofStillRequired: String
    public let staticMotionMeaning: String
    public let hitAreaStrategy: String
    public let contrastTransparencyStrategy: String

    public var id: String { "\(lane.rawValue).\(axis.rawValue)" }

    public init(
        lane: AmbitionsAdaptiveReviewLane,
        axis: AmbitionsAdaptiveAxis,
        visibleFallback: String,
        voiceOverSummary: String,
        responsibilityScope: AmbitionsAccessibilityResponsibilityScope,
        responsibilitySummary: String,
        reduceMotionEquivalent: String,
        manualProofStillRequired: String,
        staticMotionMeaning: String,
        hitAreaStrategy: String,
        contrastTransparencyStrategy: String
    ) {
        self.lane = lane
        self.axis = axis
        self.visibleFallback = visibleFallback
        self.voiceOverSummary = voiceOverSummary
        self.responsibilityScope = responsibilityScope
        self.responsibilitySummary = responsibilitySummary
        self.reduceMotionEquivalent = reduceMotionEquivalent
        self.manualProofStillRequired = manualProofStillRequired
        self.staticMotionMeaning = staticMotionMeaning
        self.hitAreaStrategy = hitAreaStrategy
        self.contrastTransparencyStrategy = contrastTransparencyStrategy
    }

    public var statusRole: AmbitionsStatusSymbolRole { lane.statusRole }
    public var loadingState: AmbitionsLoadingState { lane.loadingState }
    public var cognitiveLoadMode: AmbitionCognitiveLoadMode { lane.cognitiveLoadMode }
    public var nonColorMeaningRequired: Bool { true }
    public var publicClaimAllowed: Bool { false }
    public var changesRuntimeBehavior: Bool { false }
    public var isFutureLDIVisualHook: Bool { lane.isFutureLDIVisualHook }
}

public enum AmbitionsPrimitiveAccessibilityFallbackAxis: String, CaseIterable, Identifiable, Sendable {
    case dynamicType
    case reduceMotion
    case reduceTransparency
    case increaseContrast

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dynamicType:
            return "Dynamic Type"
        case .reduceMotion:
            return "Reduce Motion"
        case .reduceTransparency:
            return "Reduce Transparency"
        case .increaseContrast:
            return "Increase Contrast"
        }
    }
}

public struct AmbitionsPrimitiveAccessibilityFallbackBehavior: Identifiable, Hashable, Sendable {
    public let axis: AmbitionsPrimitiveAccessibilityFallbackAxis
    public let visibleFallback: String
    public let evidenceSummary: String
    public let manualProofStillRequired: String

    public var id: String { axis.rawValue }

    public init(
        axis: AmbitionsPrimitiveAccessibilityFallbackAxis,
        visibleFallback: String,
        evidenceSummary: String,
        manualProofStillRequired: String
    ) {
        self.axis = axis
        self.visibleFallback = visibleFallback
        self.evidenceSummary = evidenceSummary
        self.manualProofStillRequired = manualProofStillRequired
    }
}
#endif
