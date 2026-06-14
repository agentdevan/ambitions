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
    public let nonColorNote: String
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
        nonColorNote: String,
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
        self.nonColorNote = nonColorNote
        self.ldiHandlingLane = ldiHandlingLane
    }

    public var loadingState: AmbitionsLoadingState { stateFamily.loadingState }
    public var statusRole: AmbitionsStatusSymbolRole { loadingState.statusSymbolRole }
    public var isFutureLDIVisualHook: Bool { ldiHandlingLane != nil }
    public var claimsHumanApproval: Bool { false }
    public var claimsDeviceProof: Bool { false }
    public var changesRuntimeBehavior: Bool { false }
}

public struct SI16VisualQAFixtureSnapshotCard: View {
    public let fixture: SI16VisualQAFixture

    public init(fixture: SI16VisualQAFixture) {
        self.fixture = fixture
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [surfaceBase.opacity(0.96), Color(red: 0.05, green: 0.06, blue: 0.07)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(surfaceAccent.opacity(0.16))
                    .frame(width: 230, height: 230)
                    .offset(x: 54, y: -32)
            }
            .overlay(alignment: .bottomTrailing) {
                Path { path in
                    path.move(to: CGPoint(x: 80, y: 630))
                    path.addCurve(
                        to: CGPoint(x: 1120, y: 510),
                        control1: CGPoint(x: 300, y: 530),
                        control2: CGPoint(x: 650, y: 730)
                    )
                }
                .stroke(surfaceAccent.opacity(0.42), lineWidth: 4)
            }

            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 14) {
                    Text("FE-11")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(surfaceAccent)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(surfaceAccent.opacity(0.15)))

                    Text(fixture.ownerSurface)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                }

                Spacer(minLength: 28)

                VStack(alignment: .leading, spacing: 14) {
                    Text(fixture.stateFamily.title)
                        .font(.system(size: 76, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.96, green: 0.94, blue: 0.89))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(fixture.primaryObject)
                        .font(.system(size: 42, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(fixture.id)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(surfaceAccent)

                    Text(fixture.screenshotName)
                        .font(.system(size: 24, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.62))
                }
                .padding(28)
                .frame(maxWidth: 560, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.black.opacity(0.28))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                )

                Spacer(minLength: 30)

                Text("SwiftUI ImageRenderer snapshot from the FE-11 fixture catalog. Inventory proof only; not device proof, release proof, accessibility conformance, or human visual approval.")
                    .font(.system(size: 23, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.66))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(72)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(width: 1200, height: 800)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(fixture.previewName). \(fixture.accessibilityNote)")
        .accessibilityValue("FE-11 SwiftUI snapshot. \(fixture.reduceMotionNote) \(fixture.nonColorNote)")
    }

    private var surfaceBase: Color {
        switch fixture.ownerSurface {
        case "Today": Color(red: 0.08, green: 0.13, blue: 0.12)
        case "Goals": Color(red: 0.10, green: 0.10, blue: 0.18)
        case "Capture": Color(red: 0.14, green: 0.09, blue: 0.15)
        case "Time": Color(red: 0.14, green: 0.13, blue: 0.08)
        case "You": Color(red: 0.08, green: 0.11, blue: 0.16)
        default: Color(red: 0.10, green: 0.10, blue: 0.10)
        }
    }

    private var surfaceAccent: Color {
        switch fixture.ownerSurface {
        case "Today": Color(red: 0.47, green: 0.85, blue: 0.70)
        case "Goals": Color(red: 0.68, green: 0.72, blue: 1.00)
        case "Time": Color(red: 0.86, green: 0.76, blue: 0.42)
        case "Motion": Color(red: 0.90, green: 0.66, blue: 0.84)
        case "You": Color(red: 0.57, green: 0.78, blue: 1.00)
        default: Color.white
        }
    }
}

public enum SI16PreviewFixtureCatalog {
    public static let ownerBatch = "SI16"
    public static let screenshotDirectory = "docs/audits/si16-preview-fixture-evidence/"
    public static let proofArtifactDirectory = "docs/audits/visual-evidence/fe11/"
    public static let screenshotProofDirectory = "docs/audits/visual-evidence/fe11/screenshots/"
    public static let proofManifestName = "fe11-preview-visual-qa-proof.md"
    public static let claimsHumanApproval = false
    public static let claimsDeviceProof = false
    public static let changesRuntimeBehavior = false
    public static let canonicalTopLevelSurfaces = ["Today", "Goals", "Time", "Motion", "You"]

    public static let sourceFiles: [String] = [
        "Sources/Previews/SignatureInterfaceVisualQAFixtures.swift",
        "Sources/Previews/SignatureInterfaceVisualQAPreviews.swift",
        "Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift"
    ]

    public static let fixtureLookup: [String: SI16VisualQAFixture] = Dictionary(
        uniqueKeysWithValues: fixtures.map { ($0.id, $0) }
    )

    public static let fixtures: [SI16VisualQAFixture] = [
        fixture(.normal, "Today", "Reality Meridian", lane: nil),
        fixture(.selected, "Goals", "Constellation Atlas", lane: nil),
        fixture(.focused, "Motion", "Motion Current focus thread", lane: "clarification_needed"),
        fixture(.loading, "Time", "LifeShape Field", lane: "source_check_first"),
        fixture(.empty, "You", "User System Profile", lane: nil),
        fixture(.disabled, "Today", "Start here decision", lane: "user_review_required"),
        fixture(.degraded, "Goals", "Source review lane", lane: "source_conflict_review"),
        fixture(.privacySensitive, "You", "Trust receipt", lane: "privacy_sensitive_plan"),
        fixture(.reducedMotion, "Time", "Capacity transition", lane: nil),
        fixture(.dynamicType, "Motion", "Motion Current large-text proof", lane: nil),
        fixture(.staleSource, "Goals", "Requirement source", lane: "source_stale_review"),
        fixture(.partialSource, "Time", "Pressure source", lane: "source_check_first"),
        fixture(.offlineLocalOnly, "You", "Local-only privacy state", lane: "local_only_private_plan"),
        fixture(.blocked, "Motion", "Unsafe proof redirect", lane: "unsafe_blocked"),
        fixture(.waiting, "Today", "Waiting closure", lane: nil),
        fixture(.needsReview, "Goals", "Professional boundary review", lane: "professional_boundary_scaffold"),
        fixture(.recovery, "Today", "Still Counts recovery", lane: nil),
        fixture(.overwhelmingDay, "Time", "Recovery capacity lane", lane: nil),
        fixture(.setupNeeded, "You", "Setup control row", lane: nil),
        fixture(.deniedSource, "Time", "Denied source state", lane: "source_check_first"),
        fixture(.noDataYet, "Motion", "No proof yet", lane: "parked_thought")
    ]

    public static let surfaceCoverageRows: [SI16PreviewSurfaceCoverageRow] = [
        surfaceRow(
            "Today",
            object: "Reality Meridian / Start Here",
            fixtureIDs: [
                "today.normal",
                "today.disabled",
                "today.recovery",
                "today.waiting"
            ],
            accessibilityNote: "Today keeps Start Here grounded in clear, recommended-step, recovery, and waiting states.",
            nonColorNote: "State meaning stays visible through labels, symbols, and section order rather than color alone."
        ),
        surfaceRow(
            "Goals",
            object: "Constellation Atlas",
            fixtureIDs: [
                "goals.selected",
                "goals.degraded",
                "goals.staleSource",
                "goals.needsReview"
            ],
            accessibilityNote: "Goals keeps mission control, review, and degraded source states inspectable without changing the product shape.",
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
                "time.reducedMotion"
            ],
            accessibilityNote: "Time stays legible in loading, partial-source, denied-source, overwhelmed-day, and reduce-motion states.",
            nonColorNote: "Capacity, source, and recovery cues remain explicit in the surface text, not just the palette."
        ),
        surfaceRow(
            "Motion",
            object: "Motion Current",
            fixtureIDs: [
                "motion.focused",
                "motion.noDataYet",
                "motion.blocked",
                "motion.dynamicType"
            ],
            accessibilityNote: "Motion covers focused proof, empty movement, blocked recovery, and large-text inspection without turning into a feed.",
            nonColorNote: "Proof and recovery state use copy, spacing, and status symbols to avoid color-only meaning."
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

public struct SI16PreviewSurfaceCoverageRow: Identifiable, Hashable, Sendable {
    public let id: String
    public let ownerSurface: String
    public let primaryObject: String
    public let fixtureIDs: [String]
    public let accessibilityNote: String
    public let nonColorNote: String

    public init(
        id: String,
        ownerSurface: String,
        primaryObject: String,
        fixtureIDs: [String],
        accessibilityNote: String,
        nonColorNote: String
    ) {
        self.id = id
        self.ownerSurface = ownerSurface
        self.primaryObject = primaryObject
        self.fixtureIDs = fixtureIDs
        self.accessibilityNote = accessibilityNote
        self.nonColorNote = nonColorNote
    }

    public var fixtures: [SI16VisualQAFixture] {
        fixtureIDs.compactMap { SI16PreviewFixtureCatalog.fixtureLookup[$0] }
    }

    public var accessibilitySummary: String {
        "\(ownerSurface). \(primaryObject). \(accessibilityNote) \(nonColorNote)"
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
    public static let activeTopLevelSurfaces = ["Today", "Goals", "Time", "Motion", "You"]
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
            "Motion",
            object: "Motion Current",
            target: 95,
            inventory: [
                "motion-current-default.png",
                "motion-current-proof-thread.png",
                "motion-current-recovery.png",
                "motion-current-reduce-motion.png"
            ],
            redExamples: ["analytics dashboard", "activity feed", "XP score"]
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
        example("Motion", pass: "proof/recovery current", fail: "activity feed, score, or dashboard", label: "Red: canon violation", surface: "Motion"),
        example("You", pass: "premium user system profile", fail: "social profile or admin console", label: "Red: canon violation", surface: "You"),
        example("Trust", pass: "seam, source, and receipt", fail: "AI assistant drawer", label: "Red: inaccessible visual state", surface: nil),
        example("Continuity Dock", pass: "native five-tab with calm markers", fail: "red badges or notification bar", label: "Red: canon violation", surface: nil)
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
