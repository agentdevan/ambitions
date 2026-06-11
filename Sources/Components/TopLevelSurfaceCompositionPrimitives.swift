#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionsTopLevelSurfaceComposition: String, CaseIterable, Sendable, Identifiable {
    case today
    case goals
    case capture
    case time
    case you

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .capture: "Capture"
        case .time: "Time"
        case .you: "You"
        }
    }

    public var primaryObject: String {
        switch self {
        case .today: "Reality Meridian"
        case .goals: "Constellation Atlas"
        case .capture: "Atmosphere Composer"
        case .time: "LifeShape Field"
        case .you: "User System Profile"
        }
    }

    public var leadPhrase: String {
        switch self {
        case .today: "Start here"
        case .goals: "Direction"
        case .capture: "Compose"
        case .time: "Shape Time"
        case .you: "Trust & Continuity"
        }
    }

    public var symbolName: String {
        switch self {
        case .today: "sun.max"
        case .goals: "scope"
        case .capture: "tray.and.arrow.down"
        case .time: "clock"
        case .you: "person.crop.circle"
        }
    }

    public var supportingModuleIcon: String {
        switch self {
        case .today: "sun.max"
        case .goals: "scope"
        case .capture: "tray.and.arrow.down"
        case .time: "clock"
        case .you: "person.crop.circle"
        }
    }

    public var orientation: String {
        switch self {
        case .today: "One calm execution path with Start here, Now, Next, Later, closure, and proof."
        case .goals: "Strategic direction, path pressure, proof lanes, and goal drill-downs stay connected."
        case .capture: "Capture Anything stays composer-first; placement appears only after input."
        case .time: "Capacity, pressure, protected time, and reflow stay visible without becoming a calendar clone."
        case .you: "Trust, setup, data, preferences, and receipts stay user-controlled."
        }
    }

    public var lens: AmbitionModeLens {
        switch self {
        case .today: .focus
        case .goals: .review
        case .capture: .triage
        case .time: .plan
        case .you: .review
        }
    }

    public var ambientStatus: AmbitionAmbientStatus {
        switch self {
        case .today: .steady
        case .goals: .clear
        case .capture: .protected
        case .time: .tight
        case .you: .protected
        }
    }

    public var supportingModules: [String] {
        switch self {
        case .today:
            ["Start here", "Now / Next / Later", "Close the loop"]
        case .goals:
            ["Orbital Lens", "Life Path", "Proof"]
        case .capture:
            ["Needs a Place", "Ready to Place", "Grow into Goal"]
        case .time:
            ["Open time", "Goal time", "Protected time"]
        case .you:
            ["Trust", "Data", "Setup"]
        }
    }

    public var accessibilitySummary: String {
        "\(leadPhrase). \(title). Primary object: \(primaryObject). \(orientation)"
    }
}

public struct AFI14ProductGrammarStage: Identifiable, Hashable, Sendable {
    public let id: String
    public let verb: String
    public let promise: String
    public let ownerSurfaces: [String]
    public let evidenceObject: String
}

public struct AFI14CrossSurfaceHandoff: Identifiable, Hashable, Sendable {
    public let id: String
    public let fromSurface: String
    public let toSurface: String
    public let thread: String
    public let trustRoute: String
}

public enum AFI14CrossSurfaceCoherenceCatalog {
    public static let ownerBatch = "AFI14"
    public static let activeTopLevelSurfaces = ["Today", "Goals", "Capture", "Time", "You"]
    public static let productGrammar = ["Capture", "Clarify", "Shape", "Start", "Close", "Remember"]
    public static let changesRuntimeBehavior = false
    public static let claimsRenderedProof = false
    public static let claimsHumanApproval = false
    public static let claimsReleaseReadiness = false

    public static let stages: [AFI14ProductGrammarStage] = [
        stage("Capture", promise: "Capture anything.", surfaces: ["Capture"], object: "Atmosphere Composer"),
        stage("Clarify", promise: "Give it a place.", surfaces: ["Capture", "Goals"], object: "Needs a Place / Grow into Goal"),
        stage("Shape", promise: "Shape your time around what matters.", surfaces: ["Time"], object: "LifeShape Field"),
        stage("Start", promise: "Start where reality allows.", surfaces: ["Today"], object: "Start Here / Reality Meridian"),
        stage("Close", promise: "Close the loop without shame.", surfaces: ["Today"], object: "Receipt Surface"),
        stage("Remember", promise: "Trust what changed.", surfaces: ["You"], object: "Trust Seam / Receipts & History")
    ]

    public static let handoffs: [AFI14CrossSurfaceHandoff] = [
        handoff("Capture", "Goals", thread: "Grow into Goal / place into life area", trust: "route explanation before placement"),
        handoff("Capture", "Time", thread: "captured commitment influences capacity after user confirms", trust: "manual confirmation and receipt"),
        handoff("Capture", "Today", thread: "quick step can become Start Here candidate after placement", trust: "source visible before start"),
        handoff("Goals", "Time", thread: "goal thread asks for capacity", trust: "capacity source visible"),
        handoff("Goals", "Today", thread: "thread feeds Recommended step", trust: "Why this? route"),
        handoff("Time", "Today", thread: "capacity informs what fits now", trust: "pressure source and user choice"),
        handoff("Today", "Time", thread: "pressure or reflow sends user to Shape Time", trust: "Quiet Reflow preview"),
        handoff("Today", "Goals", thread: "closed step updates goal thread proof", trust: "receipt and proof path"),
        handoff("Any", "You", thread: "Trust Seam routes to Trust & Automation / Privacy / Receipts & History", trust: "user-controlled review")
    ]

    public static var missingStageSurfaces: [String] {
        activeTopLevelSurfaces.filter { surface in
            stages.allSatisfy { $0.ownerSurfaces.contains(surface) == false }
        }
    }

    public static var disconnectedOneOffRisk: Bool {
        missingStageSurfaces.isEmpty == false || handoffs.isEmpty
    }

    private static func stage(
        _ verb: String,
        promise: String,
        surfaces: [String],
        object: String
    ) -> AFI14ProductGrammarStage {
        AFI14ProductGrammarStage(
            id: verb.lowercased(),
            verb: verb,
            promise: promise,
            ownerSurfaces: surfaces,
            evidenceObject: object
        )
    }

    private static func handoff(
        _ from: String,
        _ to: String,
        thread: String,
        trust: String
    ) -> AFI14CrossSurfaceHandoff {
        AFI14CrossSurfaceHandoff(
            id: "\(from.lowercased())-\(to.lowercased())",
            fromSurface: from,
            toSurface: to,
            thread: thread,
            trustRoute: trust
        )
    }
}

public struct TopLevelSurfaceCompositionBar: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let surface: AmbitionsTopLevelSurfaceComposition
    private let state: AmbitionVisualState

    public init(
        surface: AmbitionsTopLevelSurfaceComposition,
        state: AmbitionVisualState = .default
    ) {
        self.surface = surface
        self.state = state
    }

    public var body: some View {
        ContextBand(state: state) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                header
                supportingModuleRail
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(surface.accessibilitySummary)
        .accessibilityValue("Supporting modules: \(surface.supportingModules.joined(separator: ", "))")
        .accessibilityIdentifier("si17.top-level-composition.\(surface.rawValue)")
    }

    private var header: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            surfaceMark
            identityBlock
        }
    }

    @ViewBuilder
    private var supportingModuleRail: some View {
        Group {
            switch surface {
            case .today:
                HStack(spacing: theme.spacing.xs) {
                    supportingModuleChips
                }
            case .goals:
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack(spacing: theme.spacing.xs) {
                        supportingModuleChips
                    }
                }
            case .capture:
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    EvidenceLabel(
                        surface.primaryObject,
                        detail: surface.orientation,
                        source: surface.title,
                        state: state == .selected ? .active : .calm,
                        context: .capture
                    )

                    HStack(spacing: theme.spacing.xs) {
                        supportingModuleChips
                    }
                }
            case .time:
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    EvidenceLabel(
                        surface.primaryObject,
                        detail: surface.orientation,
                        source: surface.title,
                        state: state == .warning ? .stale : .active,
                        context: .plan
                    )

                    HStack(spacing: theme.spacing.xs) {
                        supportingModuleChips
                    }
                }
            case .you:
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: theme.spacing.xs) {
                    supportingModuleChips
                }
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var supportingModuleChips: some View {
        ForEach(surface.supportingModules, id: \.self) { module in
            AmbitionChip(module, icon: surface.supportingModuleIcon, role: .state)
        }
    }

    private var surfaceMark: some View {
        Image(systemName: surface.symbolName)
            .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
            .foregroundStyle(surface.ambientStatus == .tight ? theme.semanticColors.waiting : theme.colors.accentPrimary)
            .frame(width: 34, height: 34)
            .background(
                Circle()
                    .fill(theme.colors.surfaceOverlay)
            )
            .overlay(
                Circle()
                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
            )
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var identityBlock: some View {
        switch surface {
        case .today:
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                surfaceLead
                primaryText
                orientationText
            }
        case .goals:
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(spacing: theme.spacing.xs) {
                    surfaceLead
                    AmbitionModeLensPill(surface.lens)
                }
                primaryText
                orientationText
            }
        case .capture:
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(spacing: theme.spacing.xs) {
                    surfaceLead
                    AmbitionAmbientStatusOrb(surface.ambientStatus)
                }
                primaryText
                orientationText
            }
        case .time:
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(spacing: theme.spacing.xs) {
                    surfaceLead
                    AmbitionAmbientStatusOrb(surface.ambientStatus)
                }
                primaryText
                orientationText
            }
        case .you:
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(spacing: theme.spacing.xs) {
                    surfaceLead
                    AmbitionAmbientStatusOrb(surface.ambientStatus)
                }
                primaryText
                orientationText
            }
        }
    }

    private var surfaceLead: some View {
        Text(surface.leadPhrase)
            .font(theme.typography.micro)
            .foregroundStyle(theme.colors.accentPrimary)
            .textCase(.uppercase)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var primaryText: some View {
        Text(surface.primaryObject)
            .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.titleCompact : theme.typography.section)
            .foregroundStyle(theme.colors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var orientationText: some View {
        Text(surface.orientation)
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
#endif
