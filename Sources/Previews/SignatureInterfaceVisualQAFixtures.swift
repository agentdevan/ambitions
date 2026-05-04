#if canImport(SwiftUI)
import SwiftUI

public enum SI16VisualQAStateFamily: String, CaseIterable, Identifiable, Sendable {
    case normal
    case selected
    case focused
    case loading
    case empty
    case disabled
    case degraded
    case privacySensitive
    case reducedMotion
    case dynamicType
    case staleSource
    case partialSource
    case offlineLocalOnly
    case blocked
    case waiting
    case needsReview
    case recovery
    case overwhelmingDay
    case setupNeeded
    case deniedSource
    case noDataYet

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .normal: "Normal"
        case .selected: "Selected"
        case .focused: "Focused"
        case .loading: "Loading"
        case .empty: "Empty"
        case .disabled: "Disabled"
        case .degraded: "Error or degraded"
        case .privacySensitive: "Privacy-sensitive"
        case .reducedMotion: "Reduced Motion"
        case .dynamicType: "Dynamic Type"
        case .staleSource: "Stale source"
        case .partialSource: "Partial source"
        case .offlineLocalOnly: "Offline or local-only"
        case .blocked: "Blocked"
        case .waiting: "Waiting"
        case .needsReview: "Needs review"
        case .recovery: "Recovery"
        case .overwhelmingDay: "Overwhelming day"
        case .setupNeeded: "Setup needed"
        case .deniedSource: "Denied source"
        case .noDataYet: "No data yet"
        }
    }

    public var loadingState: AmbitionsLoadingState {
        switch self {
        case .normal, .selected, .focused, .dynamicType, .reducedMotion:
            return .empty
        case .loading:
            return .loading
        case .empty:
            return .empty
        case .disabled:
            return .disabledPendingValidation
        case .degraded:
            return .sourceConflict
        case .privacySensitive:
            return .privacySensitive
        case .staleSource:
            return .staleSource
        case .partialSource:
            return .partialSource
        case .offlineLocalOnly:
            return .localOnly
        case .blocked:
            return .unsafeBlocked
        case .waiting:
            return .waiting
        case .needsReview:
            return .needsReview
        case .recovery:
            return .recovery
        case .overwhelmingDay:
            return .overwhelmingDay
        case .setupNeeded:
            return .setupNeeded
        case .deniedSource:
            return .deniedSource
        case .noDataYet:
            return .noDataYet
        }
    }
}

public struct SI16VisualQAFixture: Identifiable, Hashable, Sendable {
    public let id: String
    public let previewName: String
    public let screenshotName: String
    public let ownerSurface: String
    public let stateFamily: SI16VisualQAStateFamily
    public let primaryObject: String
    public let accessibilityNote: String
    public let reduceMotionNote: String
    public let privacyNote: String
    public let ldiHandlingLane: String?

    public init(
        id: String,
        previewName: String,
        screenshotName: String,
        ownerSurface: String,
        stateFamily: SI16VisualQAStateFamily,
        primaryObject: String,
        accessibilityNote: String,
        reduceMotionNote: String,
        privacyNote: String,
        ldiHandlingLane: String? = nil
    ) {
        self.id = id
        self.previewName = previewName
        self.screenshotName = screenshotName
        self.ownerSurface = ownerSurface
        self.stateFamily = stateFamily
        self.primaryObject = primaryObject
        self.accessibilityNote = accessibilityNote
        self.reduceMotionNote = reduceMotionNote
        self.privacyNote = privacyNote
        self.ldiHandlingLane = ldiHandlingLane
    }

    public var loadingState: AmbitionsLoadingState { stateFamily.loadingState }
    public var statusRole: AmbitionsStatusSymbolRole { loadingState.statusSymbolRole }
    public var isFutureLDIVisualHook: Bool { ldiHandlingLane != nil }
    public var claimsHumanApproval: Bool { false }
    public var claimsDeviceProof: Bool { false }
    public var changesRuntimeBehavior: Bool { false }
}

public enum SI16PreviewFixtureCatalog {
    public static let ownerBatch = "SI16"
    public static let screenshotDirectory = "docs/audits/si16-preview-fixture-evidence/"
    public static let claimsHumanApproval = false
    public static let claimsDeviceProof = false
    public static let changesRuntimeBehavior = false

    public static let sourceFiles: [String] = [
        "Sources/Previews/SignatureInterfaceVisualQAFixtures.swift",
        "Sources/Previews/SignatureInterfaceVisualQAPreviews.swift",
        "Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift"
    ]

    public static let fixtures: [SI16VisualQAFixture] = [
        fixture(.normal, "Today", "Reality Rail", lane: nil),
        fixture(.selected, "Goals", "Mission Control lane", lane: nil),
        fixture(.focused, "Capture", "Placement composer", lane: "clarification_needed"),
        fixture(.loading, "Plan", "LifeShape map", lane: "source_check_first"),
        fixture(.empty, "You", "Personal System Center", lane: nil),
        fixture(.disabled, "Today", "Start here decision", lane: "user_review_required"),
        fixture(.degraded, "Goals", "Source review lane", lane: "source_conflict_review"),
        fixture(.privacySensitive, "You", "Trust receipt", lane: "privacy_sensitive_plan"),
        fixture(.reducedMotion, "Plan", "Capacity transition", lane: nil),
        fixture(.dynamicType, "Capture", "Composer route reveal", lane: nil),
        fixture(.staleSource, "Goals", "Requirement source", lane: "source_stale_review"),
        fixture(.partialSource, "Plan", "Pressure source", lane: "source_check_first"),
        fixture(.offlineLocalOnly, "You", "Local-only privacy state", lane: "local_only_private_plan"),
        fixture(.blocked, "Capture", "Unsafe redirect", lane: "unsafe_blocked"),
        fixture(.waiting, "Today", "Waiting closure", lane: nil),
        fixture(.needsReview, "Goals", "Professional boundary review", lane: "professional_boundary_scaffold"),
        fixture(.recovery, "Today", "Still Counts recovery", lane: nil),
        fixture(.overwhelmingDay, "Plan", "Recovery capacity lane", lane: nil),
        fixture(.setupNeeded, "You", "Setup control row", lane: nil),
        fixture(.deniedSource, "Plan", "Denied source state", lane: "source_check_first"),
        fixture(.noDataYet, "Capture", "No placed capture yet", lane: "parked_thought")
    ]

    public static var stateFamilies: Set<SI16VisualQAStateFamily> {
        Set(fixtures.map(\.stateFamily))
    }

    public static var previewNames: [String] {
        fixtures.map(\.previewName)
    }

    public static var screenshotNames: [String] {
        fixtures.map(\.screenshotName)
    }

    public static var ldiFixtures: [SI16VisualQAFixture] {
        fixtures.filter(\.isFutureLDIVisualHook)
    }

    private static func fixture(
        _ state: SI16VisualQAStateFamily,
        _ surface: String,
        _ object: String,
        lane: String?
    ) -> SI16VisualQAFixture {
        let id = "\(surface.lowercased()).\(state.rawValue)"
        return SI16VisualQAFixture(
            id: id,
            previewName: "SI16 \(surface) \(state.title)",
            screenshotName: "si16-\(surface.lowercased())-\(state.rawValue).png",
            ownerSurface: surface,
            stateFamily: state,
            primaryObject: object,
            accessibilityNote: "\(state.title) keeps \(object) paired with a visible label and VoiceOver summary.",
            reduceMotionNote: "Use static status emphasis for \(state.title); do not require motion to understand the state.",
            privacyNote: lane == nil
                ? "No private content is needed for this deterministic fixture."
                : "LDI hook \(lane ?? "") uses lane vocabulary only and no user private data.",
            ldiHandlingLane: lane
        )
    }
}
#endif
