#if canImport(SwiftUI)
import SwiftUI

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
    let role: AmbitionCoreInteractionRole
    let state: AmbitionCoreInteractionState
    let titleOverride: String?
    let action: @MainActor () -> Void

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
    let role: AmbitionCoreInteractionRole
    let state: AmbitionCoreInteractionState
    let subtitle: String
    let action: () -> Void

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
    let role: AmbitionCoreInteractionRole
    let state: AmbitionCoreInteractionState

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
    let role: AmbitionCoreInteractionRole
    let subtitle: String
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
