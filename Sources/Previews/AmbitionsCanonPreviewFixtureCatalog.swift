#if canImport(SwiftUI)
import SwiftUI

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
        requirement("TodayRecommendedStepReady", "Today", "Start here Surface", coveredBy: "today.disabled"),
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
        requirement("CaptureEmptyQuietField", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureTypingKeyboardVisible", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureDictating", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureCapturedLocal", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureClassifying", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureHighConfidenceRoutes", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureNeedsAPlace", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureReadyToPlace", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureGrowIntoGoal", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureSaveError", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureTrustClassificationOpen", "Capture", "Trust Seam", coveredBy: nil),
        requirement("CaptureLargeTextKeyboard", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("CaptureReduceMotion", "Capture", "Atmosphere Composer", coveredBy: nil),
        requirement("TimeWeekDefault", "Time", "LifeShape Field", coveredBy: "time.normal"),
        requirement("TimeDayPressure", "Time", "LifeShape Field", coveredBy: "time.partialSource"),
        requirement("TimeMonthShaping", "Time", "LifeShape Field", coveredBy: nil),
        requirement("TimeOpenCapacity", "Time", "LifeShape Field", coveredBy: nil),
        requirement("TimeLowCapacity", "Time", "LifeShape Field", coveredBy: nil),
        requirement("TimeProtectedBlocks", "Time", "LifeShape Field", coveredBy: nil),
        requirement("TimePressureFriday", "Time", "LifeShape Field", coveredBy: nil),
        requirement("TimeCalendarDeniedManual", "Time", "LifeShape Field", coveredBy: "time.deniedSource"),
        requirement("TimeSourceConflict", "Time", "Trust Seam", coveredBy: nil),
        requirement("TimeReflowPreview", "Time", "Quiet Reflow", coveredBy: nil),
        requirement("TimeReceiptAdjusted", "Time", "Receipt Surface", coveredBy: nil),
        requirement("TimeLargeText", "Time", "LifeShape Field", coveredBy: nil),
        requirement("TimeReduceMotion", "Time", "LifeShape Field", coveredBy: "time.reducedMotion"),
        requirement("GoalsDefaultLifeAreas", "Goals", "Life Area Atlas", coveredBy: "goals.selected"),
        requirement("GoalsNoGoalsYet", "Goals", "Life Area Atlas", coveredBy: nil),
        requirement("GoalsPinnedArea", "Goals", "Life Area Atlas", coveredBy: nil),
        requirement("GoalsReorderedAreas", "Goals", "Life Area Atlas", coveredBy: nil),
        requirement("GoalsHiddenArea", "Goals", "Life Area Atlas", coveredBy: nil),
        requirement("GoalsSelectedArea", "Goals", "Orbital Lens", coveredBy: "goals.selected"),
        requirement("GoalsOrbitalLensOpen", "Goals", "Orbital Lens", coveredBy: nil),
        requirement("GoalsThreadFeedingToday", "Goals", "Cross-Object Threads", coveredBy: nil),
        requirement("GoalsSourceUnavailable", "Goals", "Trust Seam", coveredBy: "goals.degraded"),
        requirement("GoalsLargeText", "Goals", "Life Area Atlas", coveredBy: "goals.dynamicType"),
        requirement("GoalsReduceMotion", "Goals", "Life Area Atlas", coveredBy: nil),
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
