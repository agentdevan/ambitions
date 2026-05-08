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
        fixture(.normal, "Today", "Reality Meridian", lane: nil),
        fixture(.selected, "Goals", "Constellation Atlas", lane: nil),
        fixture(.focused, "Capture", "Atmosphere Composer", lane: "clarification_needed"),
        fixture(.loading, "Plan", "LifeShape map", lane: "source_check_first"),
        fixture(.empty, "You", "Personal System Center", lane: nil),
        fixture(.disabled, "Today", "Start here decision", lane: "user_review_required"),
        fixture(.degraded, "Goals", "Source review lane", lane: "source_conflict_review"),
        fixture(.privacySensitive, "You", "Trust receipt", lane: "privacy_sensitive_plan"),
        fixture(.reducedMotion, "Plan", "Capacity transition", lane: nil),
        fixture(.dynamicType, "Capture", "Atmosphere Composer route reveal", lane: nil),
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

public struct AmbitionsCanonPreviewFixtureRequirement: Identifiable, Hashable, Sendable {
    public let id: String
    public let ownerSurface: String
    public let canonObject: String
    public let currentlyCoveredBySI16FixtureID: String?

    public var isCurrentlyCovered: Bool {
        currentlyCoveredBySI16FixtureID != nil
    }
}

public enum AmbitionsCanonPreviewFixtureCatalog {
    public static let changesRuntimeBehavior = false
    public static let claimsScreenshotProof = false
    public static let claimsAccessibilityConformance = false
    public static let claimsDeviceProof = false

    public static let requiredFixtures: [AmbitionsCanonPreviewFixtureRequirement] = [
        requirement("TodayEmptyManual", "Today", "Reality Meridian", coveredBy: "today.empty"),
        requirement("TodayNowOpenCapacity", "Today", "Reality Meridian", coveredBy: "today.normal"),
        requirement("TodayRecommendedStepReady", "Today", "Start Here Surface", coveredBy: "today.disabled"),
        requirement("TodayActiveStepLive", "Today", "Reality Meridian", coveredBy: "today.selected"),
        requirement("TodayNextSoon", "Today", "Reality Meridian", coveredBy: nil),
        requirement("TodayProtectedBlockActive", "Today", "Reality Meridian", coveredBy: nil),
        requirement("TodayPressureSoon", "Today", "Reality Meridian", coveredBy: nil),
        requirement("TodayMissedStillCounts", "Today", "Reality Meridian", coveredBy: "today.recovery"),
        requirement("TodayBlocked", "Today", "Reality Meridian", coveredBy: nil),
        requirement("TodayWaiting", "Today", "Reality Meridian", coveredBy: "today.waiting"),
        requirement("TodayNeedsRecovery", "Today", "Reality Meridian", coveredBy: "today.recovery"),
        requirement("TodayReceiptPlanAdjusted", "Today", "Trust Seam / Receipt Surface", coveredBy: nil),
        requirement("TodayTrustWhyThisOpen", "Today", "Trust Seam", coveredBy: nil),
        requirement("TodayCalendarDeniedManualFallback", "Today", "Reality Meridian", coveredBy: nil),
        requirement("TodayLargeText", "Today", "Reality Meridian", coveredBy: nil),
        requirement("TodayReduceMotion", "Today", "Reality Meridian", coveredBy: nil),
        requirement("CaptureEmptyQuietField", "Capture", "Atmosphere Composer", coveredBy: "capture.noDataYet"),
        requirement("CaptureTypingKeyboardVisible", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureDictating", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureCapturedLocal", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureClassifying", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureHighConfidenceRoutes", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureNeedsAPlace", "Capture", "Atmosphere Composer", coveredBy: "capture.focused"),
        requirement("CaptureReadyToPlace", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureGrowIntoGoal", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureSaveError", "Capture", "Atmosphere Composer", coveredBy: "capture.blocked"),
        requirement("CaptureTrustClassificationOpen", "Capture", "Trust Seam", coveredBy: nil),
        requirement("CaptureLargeTextKeyboard", "Capture", "Atmosphere Composer", coveredBy: "capture.dynamicType"),
        requirement("CaptureReduceMotion", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("PlanWeekDefault", "Plan", "LifeShape Field", coveredBy: "plan.normal"),
        requirement("PlanDayPressure", "Plan", "LifeShape Field", coveredBy: "plan.partialSource"),
        requirement("PlanMonthShaping", "Plan", "LifeShape Field", coveredBy: nil),
        requirement("PlanOpenCapacity", "Plan", "LifeShape Field", coveredBy: nil),
        requirement("PlanLowCapacity", "Plan", "LifeShape Field", coveredBy: nil),
        requirement("PlanProtectedBlocks", "Plan", "LifeShape Field", coveredBy: nil),
        requirement("PlanPressureFriday", "Plan", "LifeShape Field", coveredBy: nil),
        requirement("PlanCalendarDeniedManual", "Plan", "LifeShape Field", coveredBy: "plan.deniedSource"),
        requirement("PlanSourceConflict", "Plan", "Trust Seam", coveredBy: nil),
        requirement("PlanReflowPreview", "Plan", "Quiet Reflow", coveredBy: nil),
        requirement("PlanReceiptAdjusted", "Plan", "Receipt Surface", coveredBy: nil),
        requirement("PlanLargeText", "Plan", "LifeShape Field", coveredBy: nil),
        requirement("PlanReduceMotion", "Plan", "LifeShape Field", coveredBy: "plan.reducedMotion"),
        requirement("GoalsDefaultLifeAreas", "Goals", "Constellation Atlas", coveredBy: "goals.selected"),
        requirement("GoalsNoGoalsYet", "Goals", "Constellation Atlas", coveredBy: nil),
        requirement("GoalsPinnedArea", "Goals", "Constellation Atlas", coveredBy: nil),
        requirement("GoalsReorderedAreas", "Goals", "Constellation Atlas", coveredBy: nil),
        requirement("GoalsHiddenArea", "Goals", "Constellation Atlas", coveredBy: nil),
        requirement("GoalsSelectedArea", "Goals", "Orbital Lens", coveredBy: "goals.selected"),
        requirement("GoalsOrbitalLensOpen", "Goals", "Orbital Lens", coveredBy: nil),
        requirement("GoalsThreadFeedingToday", "Goals", "Cross-Object Threads", coveredBy: nil),
        requirement("GoalsSourceUnavailable", "Goals", "Trust Seam", coveredBy: "goals.degraded"),
        requirement("GoalsLargeText", "Goals", "Constellation Atlas", coveredBy: nil),
        requirement("GoalsReduceMotion", "Goals", "Constellation Atlas", coveredBy: nil),
        requirement("YouDefault", "You", "User System Profile", coveredBy: "you.empty"),
        requirement("YouManualAutomation", "You", "Automation & Trust", coveredBy: nil),
        requirement("YouSuggestAutomation", "You", "Automation & Trust", coveredBy: nil),
        requirement("YouPreviewReflowAutomation", "You", "Automation & Trust", coveredBy: nil),
        requirement("YouCalendarDenied", "You", "User System Profile", coveredBy: nil),
        requirement("YouCalendarGranted", "You", "User System Profile", coveredBy: nil),
        requirement("YouReceiptArchive", "You", "Receipt Surface", coveredBy: nil),
        requirement("YouPrivacyControls", "You", "User System Profile", coveredBy: "you.privacySensitive"),
        requirement("YouLargeText", "You", "User System Profile", coveredBy: nil),
        requirement("YouIncreaseContrast", "You", "User System Profile", coveredBy: nil)
    ]

    public static var coveredRequirements: [AmbitionsCanonPreviewFixtureRequirement] {
        requiredFixtures.filter(\.isCurrentlyCovered)
    }

    public static var missingRequirements: [AmbitionsCanonPreviewFixtureRequirement] {
        requiredFixtures.filter { $0.isCurrentlyCovered == false }
    }

    public static var coverageSummary: String {
        "\(coveredRequirements.count) of \(requiredFixtures.count) AmbitionsCanon fixture requirements have a current SI16 inventory mapping."
    }

    private static func requirement(
        _ id: String,
        _ ownerSurface: String,
        _ canonObject: String,
        coveredBy: String?
    ) -> AmbitionsCanonPreviewFixtureRequirement {
        AmbitionsCanonPreviewFixtureRequirement(
            id: id,
            ownerSurface: ownerSurface,
            canonObject: canonObject,
            currentlyCoveredBySI16FixtureID: coveredBy
        )
    }
}
#endif
