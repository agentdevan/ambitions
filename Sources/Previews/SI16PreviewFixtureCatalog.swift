#if canImport(SwiftUI)
import SwiftUI

public enum SI16PreviewFixtureCatalog {
    public static let ownerBatch = "SI16"
    public static let screenshotDirectory = "docs/audits/si16-preview-fixture-evidence/"
    public static let proofArtifactDirectory = "docs/audits/visual-evidence/fe11/"
    public static let screenshotProofDirectory = "docs/audits/visual-evidence/fe11/screenshots/"
    public static let proofManifestName = "fe11-preview-visual-qa-proof.md"
    public static let claimsHumanApproval = false
    public static let claimsDeviceProof = false
    public static let changesRuntimeBehavior = false
    public static let canonicalTopLevelSurfaces = ["Today", "Goals", "Time", "You"]

    public static let sourceFiles: [String] = [
        "Sources/Previews/SI16VisualQAStateFamily.swift",
        "Sources/Previews/SI16VisualQAFixture.swift",
        "Sources/Previews/SI16VisualQAFixtureSnapshotCard.swift",
        "Sources/Previews/SI16PreviewFixtureCatalog.swift",
        "Sources/Previews/SI16PreviewSurfaceCoverageRow.swift",
        "Sources/Previews/AmbitionsCanonPreviewFixtureCatalog.swift",
        "Sources/Previews/AFI13VisualQACatalog.swift",
        "Sources/Previews/SignatureInterfaceVisualQAPreviews.swift",
        "Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift"
    ]

    public static let fixtureLookup: [String: SI16VisualQAFixture] = Dictionary(
        uniqueKeysWithValues: fixtures.map { ($0.id, $0) }
    )

    public static let fixtures: [SI16VisualQAFixture] = [
        fixture(.normal, "Today", "Reality Meridian", lane: nil),
        fixture(.selected, "Goals", "Life Area Atlas", lane: nil),
        fixture(.focused, "Goals", "Life Area Atlas focus thread", lane: "clarification_needed"),
        fixture(.loading, "Time", "LifeShape Field", lane: "source_check_first"),
        fixture(.empty, "You", "User System Profile", lane: nil),
        fixture(.disabled, "Today", "Start here decision", lane: "user_review_required"),
        fixture(.degraded, "Goals", "Source review lane", lane: "source_conflict_review"),
        fixture(.privacySensitive, "You", "Trust receipt", lane: "privacy_sensitive_plan"),
        fixture(.reducedMotion, "Time", "Capacity transition", lane: nil),
        fixture(.dynamicType, "Goals", "Life Area Atlas large-text proof", lane: nil),
        fixture(.staleSource, "Goals", "Requirement source", lane: "source_stale_review"),
        fixture(.partialSource, "Time", "Pressure source", lane: "source_check_first"),
        fixture(.offlineLocalOnly, "You", "Local-only privacy state", lane: "local_only_private_plan"),
        fixture(.blocked, "Time", "Blocked capacity recovery", lane: "unsafe_blocked"),
        fixture(.waiting, "Today", "Waiting closure", lane: nil),
        fixture(.needsReview, "Goals", "Professional boundary review", lane: "professional_boundary_scaffold"),
        fixture(.recovery, "Today", "Still Counts recovery", lane: nil),
        fixture(.overwhelmingDay, "Time", "Recovery capacity lane", lane: nil),
        fixture(.setupNeeded, "You", "Setup control row", lane: nil),
        fixture(.deniedSource, "Time", "Denied source state", lane: "source_check_first"),
        fixture(.noDataYet, "Today", "No proof yet", lane: "parked_thought")
    ]

    public static let surfaceCoverageRows: [SI16PreviewSurfaceCoverageRow] = [
        surfaceRow(
            "Today",
            object: "Reality Meridian / Start here",
            fixtureIDs: [
                "today.normal",
                "today.disabled",
                "today.recovery",
                "today.waiting",
                "today.noDataYet"
            ],
            accessibilityNote: "Today keeps Start here grounded in clear, recommended-step, recovery, waiting, and no-proof-yet states.",
            nonColorNote: "State meaning stays visible through labels, symbols, and section order rather than color alone."
        ),
        surfaceRow(
            "Goals",
            object: "Life Area Atlas",
            fixtureIDs: [
                "goals.selected",
                "goals.focused",
                "goals.degraded",
                "goals.staleSource",
                "goals.needsReview",
                "goals.dynamicType"
            ],
            accessibilityNote: "Goals keeps atlas focus, review, large text, and degraded source states inspectable without changing the product shape.",
            nonColorNote: "The atlas remains readable through text hierarchy and status symbols even when the state is degraded."
        ),
        surfaceRow(
            "Time",
            object: "LifeShape Field",
            fixtureIDs: [
                "time.loading",
                "time.partialSource",
                "time.deniedSource",
                "time.overwhelmingDay",
                "time.reducedMotion",
                "time.blocked"
            ],
            accessibilityNote: "Time stays legible in loading, partial-source, denied-source, overwhelmed-day, blocked, and reduce-motion states.",
            nonColorNote: "Capacity, source, and recovery cues remain explicit in the surface text, not just the palette."
        ),
        surfaceRow(
            "You",
            object: "User System Profile",
            fixtureIDs: [
                "you.empty",
                "you.privacySensitive",
                "you.setupNeeded",
                "you.offlineLocalOnly"
            ],
            accessibilityNote: "You keeps trust, setup, privacy, and local-only states inspectable in a settings-style shell.",
            nonColorNote: "Private and local-only states stay understandable even with reduced contrast or color-blind viewing."
        )
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
            nonColorNote: "State meaning stays visible without relying on color alone.",
            ldiHandlingLane: lane
        )
    }

    private static func surfaceRow(
        _ ownerSurface: String,
        object: String,
        fixtureIDs: [String],
        accessibilityNote: String,
        nonColorNote: String
    ) -> SI16PreviewSurfaceCoverageRow {
        SI16PreviewSurfaceCoverageRow(
            id: ownerSurface.lowercased(),
            ownerSurface: ownerSurface,
            primaryObject: object,
            fixtureIDs: fixtureIDs,
            accessibilityNote: accessibilityNote,
            nonColorNote: nonColorNote
        )
    }
}
#endif
