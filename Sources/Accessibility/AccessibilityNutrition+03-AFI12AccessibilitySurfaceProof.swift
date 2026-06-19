import Foundation

public struct AFI12AccessibilitySurfaceProof: Identifiable, Hashable, Sendable {
    public let id: String
    public let surface: String
    public let primaryObject: String
    public let voiceOverSummary: String
    public let dynamicTypeFallback: String
    public let reduceMotionFallback: String
    public let nonColorStateSupport: String
    public let trustReceiptPath: String
    public let manualProofStillRequired: String

    public init(
        id: String,
        surface: String,
        primaryObject: String,
        voiceOverSummary: String,
        dynamicTypeFallback: String,
        reduceMotionFallback: String,
        nonColorStateSupport: String,
        trustReceiptPath: String,
        manualProofStillRequired: String
    ) {
        self.id = id
        self.surface = surface
        self.primaryObject = primaryObject
        self.voiceOverSummary = voiceOverSummary
        self.dynamicTypeFallback = dynamicTypeFallback
        self.reduceMotionFallback = reduceMotionFallback
        self.nonColorStateSupport = nonColorStateSupport
        self.trustReceiptPath = trustReceiptPath
        self.manualProofStillRequired = manualProofStillRequired
    }

    public var publicAccessibilityClaimAllowed: Bool { false }
}

public enum AFI12AccessibilityStateProof {
    public static let ownerBatch = "AFI12"
    public static let userFacingClaimsAllowed = false

    public static let activeTopLevelSurfaces = [
        "Today",
        "Goals",
        "Time",
        "You"
    ]

    public static let supportObjects = [
        "Trust Seam",
        "Quiet Reflow",
        "Receipt Surface"
    ]

    public static let surfaceProofs: [AFI12AccessibilitySurfaceProof] = [
        AFI12AccessibilitySurfaceProof(
            id: "afi12-today",
            surface: "Today",
            primaryObject: "Reality Meridian",
            voiceOverSummary: "Today. Reality Meridian names Now, Next, Later, active step, source, closure state, and receipt availability.",
            dynamicTypeFallback: "At large text sizes Today preserves the active decision, source, recovery path, and primary action before supporting detail.",
            reduceMotionFallback: "Meridian movement becomes static Now, Next, Later labels with source and receipt text.",
            nonColorStateSupport: "Now, protected, waiting, blocked, and recovery states require text and symbols in addition to tint.",
            trustReceiptPath: "Why This? and closure receipts remain reachable from Start Here and closure surfaces.",
            manualProofStillRequired: "Manual VoiceOver, Dynamic Type screenshot, Reduce Motion walkthrough, contrast, and motor review remain required."
        ),
        AFI12AccessibilitySurfaceProof(
            id: "afi12-goals",
            surface: "Goals",
            primaryObject: "Constellation Atlas",
            voiceOverSummary: "Goals. Constellation Atlas names life areas, selected area, goal threads, Today connection, and source path.",
            dynamicTypeFallback: "Large text collapses decorative geometry before selected area, thread, and next meaningful action.",
            reduceMotionFallback: "Constellation focus becomes static selected state and native drill-down instead of motion-dependent orientation.",
            nonColorStateSupport: "Pinned, selected, stale, blocked, and Today-linked states require labels or symbols beyond color.",
            trustReceiptPath: "Goal thread proof and decision receipts remain available through Goal Detail and proof lanes.",
            manualProofStillRequired: "Manual VoiceOver, Dynamic Type screenshot, Reduce Motion walkthrough, contrast, and motor review remain required."
        ),
        AFI12AccessibilitySurfaceProof(
            id: "afi12-time",
            surface: "Time",
            primaryObject: "LifeShape Field",
            voiceOverSummary: "Time. LifeShape Field names horizon, open time, goal time, protected time, pressure, shaping actions, and manual mode.",
            dynamicTypeFallback: "Large text preserves horizon, pressure source, protected time, and Shape week or Review pressure actions before visual contour detail.",
            reduceMotionFallback: "LifeShape morph and reflow preview become a static before/after summary with explicit confirmation.",
            nonColorStateSupport: "Pressure, protected, open, unavailable, and source-review states require text and shape cues beyond color.",
            trustReceiptPath: "Quiet Reflow keeps preview, source, user choice, confirmation, and receipt behavior visible.",
            manualProofStillRequired: "Manual VoiceOver, Dynamic Type screenshot, Reduce Motion walkthrough, contrast, calendar-denied, and motor review remain required."
        ),
        AFI12AccessibilitySurfaceProof(
            id: "afi12-you",
            surface: "You",
            primaryObject: "User System Profile",
            voiceOverSummary: "You. User System Profile names Planning Setup, Trust & Automation, Privacy, Receipts & History, and Defaults.",
            dynamicTypeFallback: "You follows grouped-navigation behavior at large text sizes and keeps trust, privacy, receipts, setup, and defaults findable.",
            reduceMotionFallback: "Grouped disclosure and trust routes use native disclosure state rather than motion-only meaning.",
            nonColorStateSupport: "Trust, private, unavailable, manual, review, and future-owned states require labels and symbols beyond color.",
            trustReceiptPath: "Trust Center, What Ambitions Knows, and Receipts & History remain discoverable without hidden account or sync claims.",
            manualProofStillRequired: "Manual VoiceOver, Dynamic Type screenshot, Reduce Motion walkthrough, contrast, privacy, and motor review remain required."
        )
    ]

    public static let captureSurfaceProof: AFI12AccessibilitySurfaceProof = AFI12AccessibilitySurfaceProof(
        id: "afi12-capture",
        surface: "Capture Composer",
        primaryObject: "Atmosphere Composer",
        voiceOverSummary: "Capture Composer. Atmosphere Composer names input purpose, text or voice action, route result, uncertainty, and correction path.",
        dynamicTypeFallback: "The composer, add action, route result, and correction choices stay visible before ambient detail.",
        reduceMotionFallback: "Suggested path becomes static Needs a Place, Ready to Place, or Grow into Goal state text.",
        nonColorStateSupport: "Route confidence, private item, needs-place, and correction states require labels and visible controls.",
        trustReceiptPath: "Capture placement and correction receipts show what changed, source, and undo or review path.",
        manualProofStillRequired: "Manual VoiceOver, Dynamic Type screenshot, Reduce Motion walkthrough, keyboard, contrast, and motor review remain required."
    )

    public static let motionBehaviorProof: AFI12AccessibilitySurfaceProof = AFI12AccessibilitySurfaceProof(
        id: "afi12-stage-motion",
        surface: "Stage Motion",
        primaryObject: "Stage Motion",
        voiceOverSummary: "Stage Motion behavior announces activity path, source, proof density, trust links, and focus recovery without becoming a destination.",
        dynamicTypeFallback: "Large text keeps path, trace summary, trust route, and primary action before detail.",
        reduceMotionFallback: "Motion traces become static path and proof summary states with explicit next-action confirmation.",
        nonColorStateSupport: "Active, blocked, stalled, pending, and recovery states require labels, symbols, and line-order cues.",
        trustReceiptPath: "Stage Motion routes to Goal and Time proofs before closure so source and receipt remain visible without a Motion surface.",
        manualProofStillRequired: "Manual VoiceOver, Dynamic Type screenshot, Reduce Motion walkthrough, contrast, and motor review remain required."
    )

    public static var missingActiveSurfaceProofs: [String] {
        let covered = Set(surfaceProofs.map(\.surface))
        return activeTopLevelSurfaces.filter { covered.contains($0) == false }
    }

    public static var containsRetiredPlanTopLevelProof: Bool {
        surfaceProofs.contains { $0.surface == "Plan" || $0.primaryObject == "Plan" }
    }
}
