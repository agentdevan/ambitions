#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionsTopLevelSurfaceComposition: String, CaseIterable, Sendable, Identifiable {
    case today
    case goals
    case capture
    case plan
    case you

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .capture: "Capture"
        case .plan: "Time"
        case .you: "You"
        }
    }

    public var primaryObject: String {
        switch self {
        case .today: "Reality Meridian"
        case .goals: "Constellation Atlas + Orbital Lens"
        case .capture: "Atmosphere Composer"
        case .plan: "LifeShape Field"
        case .you: "Personal System Center"
        }
    }

    public var orientation: String {
        switch self {
        case .today: "One calm execution path with Start here, Now, Next, Later, closure, and proof."
        case .goals: "Strategic direction, path pressure, proof lanes, and goal drill-downs stay connected."
        case .capture: "Capture Anything stays composer-first; placement appears only after input."
        case .plan: "Capacity, pressure, protected time, and reflow stay visible without becoming a calendar clone."
        case .you: "Trust, setup, data, preferences, and receipts stay user-controlled."
        }
    }

    public var lens: AmbitionModeLens {
        switch self {
        case .today: .focus
        case .goals: .review
        case .capture: .triage
        case .plan: .plan
        case .you: .review
        }
    }

    public var ambientStatus: AmbitionAmbientStatus {
        switch self {
        case .today: .steady
        case .goals: .clear
        case .capture: .protected
        case .plan: .tight
        case .you: .protected
        }
    }

    public var supportingModules: [String] {
        switch self {
        case .today:
            ["Start here", "Now / Next / Later", "Close the loop"]
        case .goals:
            ["Life Path", "Lanes", "Proof"]
        case .capture:
            ["Needs a Place", "Ready to Place", "Grow into Goal"]
        case .plan:
            ["Capacity", "Pressure", "Reflow"]
        case .you:
            ["Trust", "Data", "Setup"]
        }
    }

    public var accessibilitySummary: String {
        "\(title). Primary object: \(primaryObject). \(orientation)"
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
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(spacing: theme.spacing.xs) {
                    AmbitionModeLensPill(surface.lens)
                    AmbitionAmbientStatusOrb(surface.ambientStatus)
                }

                Text(surface.primaryObject)
                    .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.titleCompact : theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(surface.orientation)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.xs)
        }
    }

    private var supportingModuleRail: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: theme.spacing.xs) {
                supportingModuleChips
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                supportingModuleChips
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var supportingModuleChips: some View {
        ForEach(surface.supportingModules, id: \.self) { module in
            AmbitionChip(module, icon: "point.topleft.down.curvedto.point.bottomright.up", role: .state)
        }
    }
}
#endif
