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
#endif
