#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionCoreInteractionPrimitiveFamily: String, CaseIterable, Identifiable, Sendable {
    case primaryAction = "Primary action"
    case disclosureRow = "Disclosure row"
    case preferenceToggle = "Preference toggle"
    case statusPill = "Status pill"
    case recoveryAction = "Recovery action"
    case globalCaptureAction = "Global Capture action"
    case destructiveConfirmation = "Destructive confirmation"

    public var id: String { rawValue }

    public var existingPrimitiveBridge: String {
        switch self {
        case .primaryAction:
            return "AmbitionsActionButton + AmbitionButtonStyle"
        case .disclosureRow:
            return "GroupedDisclosureNavigationRow"
        case .preferenceToggle:
            return "GroupedPreferenceRow"
        case .statusPill:
            return "AmbitionChip"
        case .recoveryAction:
            return "AmbitionsActionButton(role: .recovery)"
        case .globalCaptureAction:
            return "AmbitionChromeButton(role: .secondary)"
        case .destructiveConfirmation:
            return "GroupedDestructiveActionRow"
        }
    }
}

public enum AmbitionCoreInteractionState: String, CaseIterable, Identifiable, Sendable {
    case ready = "Ready"
    case selected = "Selected"
    case loading = "Loading"
    case disabled = "Disabled"
    case sourceNeeded = "Context needed"
    case localOnly = "Local only"
    case recovery = "Recovery"
    case waiting = "Waiting"
    case destructiveConfirmation = "Confirm before change"

    public var id: String { rawValue }
    public var title: String { rawValue }

    public var visualState: AmbitionVisualState {
        switch self {
        case .ready: .default
        case .selected: .selected
        case .loading: .loading
        case .disabled: .disabled
        case .sourceNeeded: .warning
        case .localOnly: .selected
        case .recovery: .celebration
        case .waiting: .warning
        case .destructiveConfirmation: .warning
        }
    }

    public var semanticState: AmbitionSemanticState {
        switch self {
        case .ready: .neutral
        case .selected: .focus
        case .loading: .review
        case .disabled: .accessibilityUnverified
        case .sourceNeeded: .caution
        case .localOnly: .protected
        case .recovery: .recovery
        case .waiting: .waiting
        case .destructiveConfirmation: .risk
        }
    }

    public var accessibilityValue: String {
        switch self {
        case .ready:
            return "Ready. Action, source, and owner are visible."
        case .selected:
            return "Selected. This is the current recommended control."
        case .loading:
            return "Loading. Keep the label visible while work completes."
        case .disabled:
            return "Disabled. Explain what is needed before use."
        case .sourceNeeded:
            return "Context needed. SourceRecord, Receipt, or ReplayTrace should be checked."
        case .localOnly:
            return "Local only. Private on this device unless changed by the user."
        case .recovery:
            return "Recovery option. Keeps progress without shame."
        case .waiting:
            return "Waiting. The blocked reason is visible."
        case .destructiveConfirmation:
            return "Confirmation required before anything changes."
        }
    }

    public var nonColorCue: String {
        switch self {
        case .ready:
            return "Text label and symbol identify the available action."
        case .selected:
            return "Selected state uses label, symbol, and structure."
        case .loading:
            return "Loading keeps the original action label and progress symbol."
        case .disabled:
            return "Disabled state includes text that explains the next requirement."
        case .sourceNeeded:
            return "Source-needed state includes source text and attention symbol."
        case .localOnly:
            return "Local-only state includes private text and lock or shield symbol."
        case .recovery:
            return "Recovery state is named and uses the recovery symbol."
        case .waiting:
            return "Waiting state includes waiting text and hourglass symbol."
        case .destructiveConfirmation:
            return "Confirmation state uses warning text and confirmation structure."
        }
    }

    public var isActionEnabled: Bool {
        switch self {
        case .disabled, .loading, .waiting:
            return false
        case .ready, .selected, .sourceNeeded, .localOnly, .recovery, .destructiveConfirmation:
            return true
        }
    }
}

public enum AmbitionCoreInteractionRole: String, CaseIterable, Identifiable, Sendable {
    case startHere
    case startNow
    case openStep
    case openGoalThread
    case reviewTimeFit
    case inspectProof
    case recoveryOption
    case captureContext
    case trustPreference
    case confirmChange

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .startHere: "Start here"
        case .startNow: "Start now"
        case .openStep: "Open step"
        case .openGoalThread: "Open goal thread"
        case .reviewTimeFit: "Review time fit"
        case .inspectProof: "Inspect proof"
        case .recoveryOption: "Recovery option"
        case .captureContext: "Capture context"
        case .trustPreference: "Private by default"
        case .confirmChange: "Confirm change"
        }
    }

    public var ownerSurface: String {
        switch self {
        case .startHere, .startNow, .openStep, .recoveryOption:
            return "Today"
        case .openGoalThread:
            return "Goals"
        case .reviewTimeFit:
            return "Time"
        case .inspectProof:
            return "Motion"
        case .captureContext:
            return "Global Capture"
        case .trustPreference, .confirmChange:
            return "You"
        }
    }

    public var primaryObject: String {
        switch self {
        case .startHere:
            return "Reality Meridian / Start here"
        case .startNow:
            return "Recommended step"
        case .openStep:
            return "Step Detail"
        case .openGoalThread:
            return "Constellation Atlas"
        case .reviewTimeFit:
            return "LifeShape Field / Time Texture"
        case .inspectProof:
            return "Motion Current"
        case .recoveryOption:
            return "Recovery path"
        case .captureContext:
            return "Atmosphere Composer"
        case .trustPreference:
            return "User System Profile"
        case .confirmChange:
            return "Confirmation step"
        }
    }

    public var family: AmbitionCoreInteractionPrimitiveFamily {
        switch self {
        case .startHere, .startNow:
            return .primaryAction
        case .openStep, .openGoalThread, .reviewTimeFit, .inspectProof:
            return .disclosureRow
        case .recoveryOption:
            return .recoveryAction
        case .captureContext:
            return .globalCaptureAction
        case .trustPreference:
            return .preferenceToggle
        case .confirmChange:
            return .destructiveConfirmation
        }
    }

    public var systemImage: String {
        switch self {
        case .startHere: "scope"
        case .startNow: "arrow.right.circle.fill"
        case .openStep: "checklist"
        case .openGoalThread: "sparkle.magnifyingglass"
        case .reviewTimeFit: "clock.badge.checkmark"
        case .inspectProof: "waveform.path.ecg"
        case .recoveryOption: "arrow.uturn.backward.circle"
        case .captureContext: "square.and.pencil"
        case .trustPreference: "lock.shield"
        case .confirmChange: "exclamationmark.triangle"
        }
    }

    public var actionRole: AmbitionsActionRole {
        switch self {
        case .startHere, .startNow:
            return .primary
        case .openStep, .openGoalThread, .reviewTimeFit, .inspectProof, .captureContext:
            return .secondary
        case .recoveryOption:
            return .recovery
        case .trustPreference:
            return .quiet
        case .confirmChange:
            return .destructive
        }
    }

    public var semanticState: AmbitionSemanticState {
        switch self {
        case .startHere, .startNow: .focus
        case .openStep: .confidenceMedium
        case .openGoalThread: .review
        case .reviewTimeFit: .calendarDerived
        case .inspectProof: .trust
        case .recoveryOption: .recovery
        case .captureContext: .capture
        case .trustPreference: .protected
        case .confirmChange: .risk
        }
    }

    public var isTopLevelSurface: Bool {
        ["Today", "Goals", "Time", "Motion", "You"].contains(ownerSurface)
    }

    public var accessibilityHint: String {
        switch self {
        case .startHere:
            return "Reviews the current recommendation and why it fits now."
        case .startNow:
            return "Starts the recommended step when the user chooses it."
        case .openStep:
            return "Opens step detail without starting a session."
        case .openGoalThread:
            return "Opens the related goal thread and proof context."
        case .reviewTimeFit:
            return "Shows time fit, capacity, and protected-time context."
        case .inspectProof:
            return "Shows proof, source, and receipt context."
        case .recoveryOption:
            return "Shows a smaller recovery option without shame."
        case .captureContext:
            return "Opens the global Capture composer."
        case .trustPreference:
            return "Changes a local trust or privacy preference."
        case .confirmChange:
            return "Opens confirmation before anything changes."
        }
    }
}

public struct AmbitionCoreInteractionContract: Identifiable, Equatable, Sendable {
    public let role: AmbitionCoreInteractionRole
    public let supportedStates: [AmbitionCoreInteractionState]
    public let minimumTapTarget: Double
    public let supportsDynamicType: Bool
    public let supportsReduceMotion: Bool
    public let supportsReduceTransparency: Bool
    public let supportsIncreaseContrast: Bool

    public init(
        role: AmbitionCoreInteractionRole,
        supportedStates: [AmbitionCoreInteractionState] = AmbitionCoreInteractionState.allCases,
        minimumTapTarget: Double = 44,
        supportsDynamicType: Bool = true,
        supportsReduceMotion: Bool = true,
        supportsReduceTransparency: Bool = true,
        supportsIncreaseContrast: Bool = true
    ) {
        self.role = role
        self.supportedStates = supportedStates
        self.minimumTapTarget = minimumTapTarget
        self.supportsDynamicType = supportsDynamicType
        self.supportsReduceMotion = supportsReduceMotion
        self.supportsReduceTransparency = supportsReduceTransparency
        self.supportsIncreaseContrast = supportsIncreaseContrast
    }

    public var id: String { role.rawValue }
    public var title: String { role.title }
    public var ownerSurface: String { role.ownerSurface }
    public var primaryObject: String { role.primaryObject }
    public var family: AmbitionCoreInteractionPrimitiveFamily { role.family }
    public var existingPrimitiveBridge: String { family.existingPrimitiveBridge }
    public var isTopLevelSurface: Bool { role.isTopLevelSurface }

    public var accessibilitySummary: String {
        [
            title,
            "Owner: \(ownerSurface)",
            "Primary object: \(primaryObject)",
            "Bridge: \(existingPrimitiveBridge)",
            "Tap target: \(Int(minimumTapTarget)) points",
            "Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, and non-color state supported."
        ].joined(separator: ". ")
    }
}

public enum AmbitionCoreInteractionPrimitiveCatalog {
    public static let ownerBatch = "AMB-1061"
    public static let canonicalTopLevelSurfaces = ["Today", "Goals", "Time", "Motion", "You"]
    public static let contracts = AmbitionCoreInteractionRole.allCases.map { role in
        AmbitionCoreInteractionContract(role: role)
    }
    public static let states = AmbitionCoreInteractionState.allCases

    public static let requiredLaunchPathRoles: [AmbitionCoreInteractionRole] = [
        .startHere,
        .startNow,
        .openStep,
        .openGoalThread,
        .reviewTimeFit,
        .inspectProof,
        .recoveryOption,
        .captureContext,
        .trustPreference,
        .confirmChange
    ]

    public static let forbiddenLanguage = [
        "dash" + "board",
        "task" + " list",
        "chat" + "bot",
        "ui" + " kit",
        "component" + " library",
        "ai" + " model",
        "plan" + " tab",
        "profile" + " tab",
        "capture" + " tab",
        "sixth" + " destination",
        "production ready",
        "release ready",
        "fully accessible",
        "accessibility verified",
        "color-only",
        "color only"
    ]

    public static func contract(for role: AmbitionCoreInteractionRole) -> AmbitionCoreInteractionContract {
        AmbitionCoreInteractionContract(role: role)
    }

    public static func validationFailures() -> [String] {
        contracts.flatMap(validationFailures(for:)) + states.flatMap(validationFailures(for:))
    }

    public static func validationFailures(for contract: AmbitionCoreInteractionContract) -> [String] {
        var failures: [String] = []
        if contract.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing title")
        }
        if contract.ownerSurface.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing owner surface")
        }
        if contract.primaryObject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing primary object")
        }
        if contract.minimumTapTarget < 44 {
            failures.append("tap target below 44")
        }
        if contract.supportedStates.count != states.count {
            failures.append("missing supported state")
        }
        if contract.role == .captureContext && contract.isTopLevelSurface {
            failures.append("Capture must not be a top-level surface")
        }
        if canonicalTopLevelSurfaces.contains("Capture") {
            failures.append("Capture must not be listed as a root destination")
        }

        let searchable = contract.accessibilitySummary.lowercased()
        for phrase in forbiddenLanguage where searchable.contains(phrase) {
            failures.append("forbidden language: \(phrase)")
        }

        return failures
    }

    public static func validationFailures(for state: AmbitionCoreInteractionState) -> [String] {
        var failures: [String] = []
        if state.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing state title")
        }
        if state.accessibilityValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing accessibility value")
        }
        if state.nonColorCue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing non-color cue")
        }

        let searchable = "\(state.title) \(state.accessibilityValue) \(state.nonColorCue)".lowercased()
        for phrase in forbiddenLanguage where searchable.contains(phrase) {
            failures.append("forbidden language: \(phrase)")
        }

        return failures
    }
}

public struct AmbitionCoreInteractionActionButton: View {
    private let role: AmbitionCoreInteractionRole
    private let state: AmbitionCoreInteractionState
    private let titleOverride: String?
    private let action: @MainActor () -> Void

    public init(
        role: AmbitionCoreInteractionRole,
        state: AmbitionCoreInteractionState = .ready,
        title: String? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.role = role
        self.state = state
        self.titleOverride = title
        self.action = action
    }

    public var body: some View {
        AmbitionsActionButton(
            titleOverride ?? role.title,
            icon: role.systemImage,
            role: role.actionRole,
            state: state.visualState,
            isLoading: state == .loading,
            action: action
        )
        .disabled(state.isActionEnabled == false)
        .accessibilityHint(role.accessibilityHint)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityIdentifier("ambition-core-interaction.action.\(role.rawValue)")
    }
}

public struct AmbitionCoreInteractionDisclosureRow: View {
    private let role: AmbitionCoreInteractionRole
    private let state: AmbitionCoreInteractionState
    private let subtitle: String
    private let action: () -> Void

    public init(
        role: AmbitionCoreInteractionRole,
        state: AmbitionCoreInteractionState = .ready,
        subtitle: String,
        action: @escaping () -> Void
    ) {
        self.role = role
        self.state = state
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        GroupedDisclosureNavigationRow(
            title: role.title,
            subtitle: subtitle,
            systemImage: role.systemImage,
            badge: .init(state.title, icon: state.semanticState.icon, state: state.semanticState),
            accessibilityValue: state.accessibilityValue,
            accessibilityHint: role.accessibilityHint,
            action: action
        )
        .disabled(state.isActionEnabled == false)
        .accessibilityIdentifier("ambition-core-interaction.disclosure.\(role.rawValue)")
    }
}

public struct AmbitionCoreInteractionStatusPill: View {
    private let role: AmbitionCoreInteractionRole
    private let state: AmbitionCoreInteractionState

    public init(role: AmbitionCoreInteractionRole, state: AmbitionCoreInteractionState = .ready) {
        self.role = role
        self.state = state
    }

    public var body: some View {
        AmbitionChip(
            state.title,
            icon: state.semanticState.icon,
            role: .state,
            semanticState: state.semanticState
        )
        .accessibilityLabel("\(role.title), \(state.title)")
        .accessibilityValue(state.accessibilityValue)
        .accessibilityIdentifier("ambition-core-interaction.status.\(role.rawValue).\(state.rawValue)")
    }
}

public struct AmbitionCoreInteractionPreferenceRow: View {
    private let role: AmbitionCoreInteractionRole
    private let subtitle: String
    @Binding private var isOn: Bool

    public init(
        role: AmbitionCoreInteractionRole = .trustPreference,
        subtitle: String,
        isOn: Binding<Bool>
    ) {
        self.role = role
        self.subtitle = subtitle
        self._isOn = isOn
    }

    public var body: some View {
        GroupedPreferenceRow(
            title: role.title,
            subtitle: subtitle,
            systemImage: role.systemImage,
            isOn: $isOn,
            accessibilityLabel: role.title,
            accessibilityHint: role.accessibilityHint
        )
        .accessibilityIdentifier("ambition-core-interaction.preference.\(role.rawValue)")
    }
}

public struct AmbitionCoreInteractionPreviewCell: Identifiable, Equatable, Sendable {
    public let role: AmbitionCoreInteractionRole
    public let state: AmbitionCoreInteractionState

    public var id: String { "\(role.rawValue).\(state.rawValue)" }
    public var title: String { role.title }
    public var ownerSurface: String { role.ownerSurface }
    public var accessibilitySummary: String {
        "\(role.title). \(role.ownerSurface). \(state.accessibilityValue). \(state.nonColorCue)"
    }
}

public struct AmbitionCoreInteractionPreviewRow: Identifiable, Equatable, Sendable {
    public let role: AmbitionCoreInteractionRole
    public let cells: [AmbitionCoreInteractionPreviewCell]

    public var id: String { role.rawValue }
    public var accessibilitySummary: String {
        "\(role.title). \(role.ownerSurface). \(cells.count) states. \(role.accessibilityHint)"
    }
}

public enum AmbitionCoreInteractionPreviewMatrix {
    public static let rows: [AmbitionCoreInteractionPreviewRow] = AmbitionCoreInteractionRole.allCases.map { role in
        AmbitionCoreInteractionPreviewRow(
            role: role,
            cells: AmbitionCoreInteractionState.allCases.map { state in
                AmbitionCoreInteractionPreviewCell(role: role, state: state)
            }
        )
    }

    public static let variants = [
        "Component inventory",
        "Dynamic Type",
        "Reduce Motion",
        "Reduce Transparency",
        "Increase Contrast",
        "Non-color state"
    ]

    public static func validationFailures() -> [String] {
        var failures: [String] = []
        if rows.count != AmbitionCoreInteractionRole.allCases.count {
            failures.append("missing role row")
        }
        for row in rows {
            if row.cells.map(\.state) != AmbitionCoreInteractionState.allCases {
                failures.append("state order mismatch for \(row.role.rawValue)")
            }
            if row.accessibilitySummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                failures.append("missing row accessibility summary")
            }
        }
        if variants.count < 6 {
            failures.append("missing accessibility preview variant")
        }
        return failures
    }
}
#endif
