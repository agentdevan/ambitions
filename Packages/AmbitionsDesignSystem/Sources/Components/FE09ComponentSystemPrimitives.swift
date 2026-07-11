#if canImport(SwiftUI)
import SwiftUI

public enum FE09ComponentSystemState: String, CaseIterable, Identifiable, Sendable {
    case normal = "Normal"
    case staleSourceNeeded = "Stale / context needed"
    case localOnlyPrivacy = "Local only / privacy"
    case recovery = "Recovery"
    case blockedWaiting = "Blocked / waiting"
    case dynamicType = "Dynamic Type"
    case reduceMotion = "Reduce Motion"
    case nonColorState = "Non-color state"

    public var id: String { rawValue }
    public var title: String { rawValue }

    public var summary: String {
        switch self {
        case .normal:
            return "Default state with source, title, and action all readable."
        case .staleSourceNeeded:
            return "Source should be checked before this is reused."
        case .localOnlyPrivacy:
            return "Private to this device unless the user changes it."
        case .recovery:
            return "A smaller recovery path stays visible."
        case .blockedWaiting:
            return "Blocked safely; waiting is explicit."
        case .dynamicType:
            return "Large text keeps hierarchy and action visible."
        case .reduceMotion:
            return "Static equivalents keep meaning without motion."
        case .nonColorState:
            return "Text, symbol, and structure carry the meaning."
        }
    }

    public var symbolName: String {
        switch self {
        case .normal:
            return "checkmark.circle.fill"
        case .staleSourceNeeded:
            return "clock.badge.exclamationmark"
        case .localOnlyPrivacy:
            return "lock.shield"
        case .recovery:
            return "arrow.uturn.backward.circle"
        case .blockedWaiting:
            return "hand.raised.circle"
        case .dynamicType:
            return "textformat.size"
        case .reduceMotion:
            return "pause.circle"
        case .nonColorState:
            return "circle.grid.3x3"
        }
    }

    public var visualState: LivingVisualState {
        switch self {
        case .normal, .dynamicType, .reduceMotion:
            return .calm
        case .staleSourceNeeded:
            return .stale
        case .localOnlyPrivacy:
            return .sensitive
        case .recovery:
            return .recovery
        case .blockedWaiting:
            return .pressured
        case .nonColorState:
            return .proof
        }
    }

    public var nonColorCue: String {
        switch self {
        case .normal:
            return "Title, source, and action stay visible."
        case .staleSourceNeeded:
            return "Stale source is explained in text."
        case .localOnlyPrivacy:
            return "Privacy is visible without color alone."
        case .recovery:
            return "Recovery is named and icon-led."
        case .blockedWaiting:
            return "Waiting is visible in text and symbol."
        case .dynamicType:
            return "Large text keeps the state understandable."
        case .reduceMotion:
            return "Static equivalents keep the state readable."
        case .nonColorState:
            return "Shape, icon, and text carry the state."
        }
    }

    public var accessibilitySummary: String {
        "\(title). \(summary). \(nonColorCue)"
    }
}

public enum FE09ComponentSystemRole: String, CaseIterable, Identifiable, Sendable {
    case trustSeam = "Trust Seam"
    case receipt = "Receipt"
    case sourceFreshness = "Source Freshness"
    case primaryCTA = "Primary CTA"
    case disclosureRow = "Disclosure Row"
    case proof = "Proof"
    case recovery = "Recovery"
    case realityMeridian = "Reality Meridian"
    case lifeShapeField = "Life Calendar"
    case atmosphereComposer = "Atmosphere Composer"
    case constellationAtlas = "Life Area Atlas"
    case userSystemProfile = "User System Profile"

    public var id: String { rawValue }
    public var title: String { rawValue }

    public var ownerSurface: String {
        switch self {
        case .trustSeam, .sourceFreshness, .disclosureRow, .userSystemProfile:
            return "You"
        case .receipt, .primaryCTA, .realityMeridian, .recovery:
            return "Today"
        case .proof, .constellationAtlas:
            return "Goals"
        case .lifeShapeField:
            return "Time"
        case .atmosphereComposer:
            return "Capture"
        }
    }

    public var context: LivingTabContext {
        switch self {
        case .trustSeam, .sourceFreshness, .disclosureRow:
            return .trust
        case .receipt, .primaryCTA, .realityMeridian, .recovery:
            return .today
        case .proof, .constellationAtlas:
            return .goals
        case .lifeShapeField:
            return .plan
        case .atmosphereComposer:
            return .capture
        case .userSystemProfile:
            return .you
        }
    }

    public var primaryObject: String {
        switch self {
        case .trustSeam:
            return "Trust Seam"
        case .receipt:
            return "Receipt Surface"
        case .sourceFreshness:
            return "Source Freshness Badge"
        case .primaryCTA:
            return "Start here"
        case .disclosureRow:
            return "Disclosure Row"
        case .proof:
            return "Proof Trail"
        case .recovery:
            return "Recovery Path"
        case .realityMeridian:
            return "Reality Meridian"
        case .lifeShapeField:
            return "Life Calendar"
        case .atmosphereComposer:
            return "Atmosphere Composer"
        case .constellationAtlas:
            return "Life Area Atlas"
        case .userSystemProfile:
            return "User System Profile"
        }
    }

    public var summary: String {
        switch self {
        case .trustSeam:
            return "Inspectable trust route for privacy, receipts, and corrections."
        case .receipt:
            return "Confirmed changes stay visible without mutating the source silently."
        case .sourceFreshness:
            return "Fresh, stale, local-only, and blocked evidence stay explicit."
        case .primaryCTA:
            return "One decisive action keeps the surface focused."
        case .disclosureRow:
            return "Secondary details open only when the user asks."
        case .proof:
            return "Evidence stays attached to the goal thread."
        case .recovery:
            return "Smaller recovery choices keep the loop calm."
        case .realityMeridian:
            return "Current state and start-here orientation stay visible."
        case .lifeShapeField:
            return "Capacity, pressure, and protected time remain inspectable."
        case .atmosphereComposer:
            return "Capture stays composer-first until placement is chosen."
        case .constellationAtlas:
            return "Goal threads and directional context stay readable."
        case .userSystemProfile:
            return "Settings-style controls stay local, inspectable, and user-owned."
        }
    }

    public var previewState: LivingVisualState {
        switch self {
        case .trustSeam, .receipt, .proof, .constellationAtlas, .userSystemProfile:
            return .proof
        case .sourceFreshness:
            return .stale
        case .primaryCTA, .realityMeridian, .atmosphereComposer:
            return .active
        case .disclosureRow, .lifeShapeField:
            return .calm
        case .recovery:
            return .recovery
        }
    }

    public var accessibilitySummary: String {
        "\(title). Owner surface: \(ownerSurface). Primary object: \(primaryObject). \(summary)"
    }
}

public enum FE09ComponentSystemContract {
    public static let ownerBatch = "FE09"
    public static let roles: [FE09ComponentSystemRole] = FE09ComponentSystemRole.allCases
    public static let states: [FE09ComponentSystemState] = FE09ComponentSystemState.allCases

    public static let forbiddenLanguage: [String] = [
        "dashboard",
        "ui kit",
        "component library",
        "task list",
        "chatbot",
        "ai model",
        "model",
        "plan " + "tab",
        "profile " + "tab",
        "sixth destination",
        "production " + "ready",
        "release " + "ready",
        "accessibility verified",
        "fully accessible",
        "color-only",
        "color only"
    ]

    public static func validationFailures() -> [String] {
        roles.flatMap(validationFailures(for:)) + states.flatMap(validationFailures(for:))
    }

    public static func validationFailures(for role: FE09ComponentSystemRole) -> [String] {
        var failures: [String] = []

        if role.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing role title")
        }
        if role.ownerSurface.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing owner surface")
        }
        if role.primaryObject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing primary object")
        }
        if role.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing summary")
        }

        let searchable = role.accessibilitySummary.lowercased()
        for phrase in forbiddenLanguage where searchable.contains(phrase) {
            failures.append("forbidden language: \(phrase)")
        }

        return failures
    }

    public static func validationFailures(for state: FE09ComponentSystemState) -> [String] {
        var failures: [String] = []

        if state.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing state title")
        }
        if state.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing state summary")
        }
        if state.nonColorCue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing non-color cue")
        }

        let searchable = state.accessibilitySummary.lowercased()
        for phrase in forbiddenLanguage where searchable.contains(phrase) {
            failures.append("forbidden language: \(phrase)")
        }

        if searchable.contains("verified accessible") || searchable.contains("accessibility proof") {
            failures.append("unsupported accessibility overclaim")
        }

        return failures
    }
}
#endif
