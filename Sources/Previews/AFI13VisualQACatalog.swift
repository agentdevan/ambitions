#if canImport(SwiftUI)
import SwiftUI

public struct AFI13VisualQAScorecardEntry: Identifiable, Hashable, Sendable {
    public let id: String
    public let surface: String
    public let primaryObject: String
    public let minimumScore: Int
    public let targetScore: Int
    public let requiredRenderedInventory: [String]
    public let yellowReason: String
    public let hardRedDriftExamples: [String]
    public let hasRenderedScreenshotProof: Bool

    public var status: String {
        hasRenderedScreenshotProof ? "Green" : "Yellow"
    }

    public var isBlockedFromGreen: Bool {
        hasRenderedScreenshotProof == false
    }
}

public struct AFI13VisualDriftGalleryExample: Identifiable, Hashable, Sendable {
    public let id: String
    public let category: String
    public let passPattern: String
    public let failPattern: String
    public let redLabel: String
    public let ownerSurface: String?
}

public enum AFI13VisualQACatalog {
    public static let ownerBatch = "AFI13"
    public static let activeTopLevelSurfaces = ["Today", "Goals", "Time", "You"]
    public static let changesRuntimeBehavior = false
    public static let claimsRenderedScreenshotProof = false
    public static let claimsHumanVisualApproval = false
    public static let claimsDeviceProof = false
    public static let claimsAccessibilityConformance = false

    public static let scorecards: [AFI13VisualQAScorecardEntry] = [
        scorecard(
            "Today",
            object: "Reality Meridian",
            target: 98,
            inventory: [
                "today-reality-meridian-default.png",
                "today-reality-meridian-recovery.png",
                "today-reality-meridian-large-text.png",
                "today-reality-meridian-reduce-motion.png"
            ],
            redExamples: ["task list", "timeline stack", "red badge pressure"]
        ),
        scorecard(
            "Goals",
            object: "Constellation Atlas",
            target: 95,
            inventory: [
                "goals-constellation-atlas-default.png",
                "goals-constellation-atlas-selected-area.png",
                "goals-constellation-atlas-source-unavailable.png"
            ],
            redExamples: ["KPI dashboard", "astrology chart", "ranked life score"]
        ),
        scorecard(
            "Time",
            object: "LifeShape Field",
            target: 95,
            inventory: [
                "time-lifeshape-field-week.png",
                "time-lifeshape-field-pressure.png",
                "time-lifeshape-field-reflow-preview.png",
                "time-lifeshape-field-reduce-motion.png"
            ],
            redExamples: ["calendar clone", "analytics dashboard", "red overload grid"]
        ),
        scorecard(
            "You",
            object: "User System Profile",
            target: 95,
            inventory: [
                "you-user-system-profile-default.png",
                "you-user-system-profile-trust-open.png",
                "you-user-system-profile-privacy-controls.png"
            ],
            redExamples: ["social profile", "admin console", "settings dashboard"]
        )
    ]

    public static let driftGallery: [AFI13VisualDriftGalleryExample] = [
        example("Native shell", pass: "familiar iPhone structure with proprietary objects", fail: "experimental hidden nav", label: "Red: generic productivity", surface: nil),
        example("Celestial Field", pass: "subtle orientation atmosphere", fail: "fantasy space wallpaper", label: "Red: decorative celestial", surface: nil),
        example("Graphite Recess", pass: "embedded product surface", fail: "stacked SaaS cards", label: "Red: SaaS/dashboard", surface: nil),
        example("Luminous Trace", pass: "state, proof, and relationship", fail: "neon decorative lines", label: "Red: sci-fi/HUD", surface: nil),
        example("Quiet Glass", pass: "restrained touch controls", fail: "generic glassmorphism", label: "Yellow: adjacent drift", surface: nil),
        example("Today", pass: "Reality Meridian plus Start Here", fail: "task list or timeline", label: "Red: generic productivity", surface: "Today"),
        example("Goals", pass: "equal-weight atlas", fail: "KPI dashboard or astrology", label: "Red: SaaS/dashboard", surface: "Goals"),
        example("Time", pass: "capacity field", fail: "calendar clone or analytics", label: "Red: canon violation", surface: "Time"),
        example("Motion", pass: "stage behavior for proof, recovery, and re-entry", fail: "activity feed, score, or dashboard", label: "Red: canon violation", surface: nil),
        example("You", pass: "premium user system profile", fail: "social profile or admin console", label: "Red: canon violation", surface: "You"),
        example("Trust", pass: "seam, source, and receipt", fail: "AI assistant drawer", label: "Red: inaccessible visual state", surface: nil),
        example("Continuity Dock", pass: "native four-surface shell with calm markers", fail: "red badges or notification bar", label: "Red: canon violation", surface: nil)
    ]

    public static var missingGreenProofSurfaces: [String] {
        scorecards.filter(\.isBlockedFromGreen).map(\.surface)
    }

    public static var containsPlanTopLevelSurface: Bool {
        activeTopLevelSurfaces.contains("Plan") || scorecards.contains { $0.surface == "Plan" }
    }

    private static func scorecard(
        _ surface: String,
        object: String,
        target: Int,
        inventory: [String],
        redExamples: [String]
    ) -> AFI13VisualQAScorecardEntry {
        AFI13VisualQAScorecardEntry(
            id: surface.lowercased(),
            surface: surface,
            primaryObject: object,
            minimumScore: 95,
            targetScore: target,
            requiredRenderedInventory: inventory,
            yellowReason: "Rendered screenshot and human visual review are required before Green.",
            hardRedDriftExamples: redExamples,
            hasRenderedScreenshotProof: false
        )
    }

    private static func example(
        _ category: String,
        pass: String,
        fail: String,
        label: String,
        surface: String?
    ) -> AFI13VisualDriftGalleryExample {
        AFI13VisualDriftGalleryExample(
            id: category.lowercased().replacingOccurrences(of: " ", with: "-"),
            category: category,
            passPattern: pass,
            failPattern: fail,
            redLabel: label,
            ownerSurface: surface
        )
    }
}
#endif
