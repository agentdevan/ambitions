#if canImport(SwiftUI)
import SwiftUI

public enum FE04PrimitiveRole: String, CaseIterable, Identifiable, Sendable {
    case graphiteRecess = "Graphite Recess"
    case quietGlassShelf = "Quiet Glass Shelf"
    case inspectableStrip = "Inspectable Strip"
    case ambientVignette = "Ambient Vignette"
    case seamLine = "Seam Line"
    case luminousTrace = "Luminous Trace"
    case meridianNode = "Meridian Node"
    case currentTimeGlow = "Current Time Glow"
    case proofTrail = "Proof Trail"
    case receiptDrawer = "Receipt Drawer"
    case sourceFreshnessBadge = "Source Freshness Badge"
    case closurePrompt = "Closure Prompt"
    case startHere = "Start here"
    case lifeShape = "LifeShape"
    case atmosphereComposer = "Atmosphere Composer"
    case constellationLane = "Constellation lane"
    case userSystemProfile = "User System Profile"

    public var id: String { rawValue }

    public var title: String { rawValue }

    public var ownerSurface: String {
        switch self {
        case .graphiteRecess, .quietGlassShelf, .inspectableStrip, .ambientVignette, .seamLine, .luminousTrace:
            return "Shared materials"
        case .meridianNode, .currentTimeGlow, .closurePrompt, .startHere:
            return "Today"
        case .proofTrail:
            return "Goals"
        case .receiptDrawer:
            return "Capture"
        case .sourceFreshnessBadge:
            return "Why this?"
        case .lifeShape:
            return "Time"
        case .atmosphereComposer:
            return "Capture"
        case .constellationLane:
            return "Goals"
        case .userSystemProfile:
            return "You"
        }
    }

    public var visualState: LivingVisualState {
        switch self {
        case .graphiteRecess, .ambientVignette, .lifeShape:
            return .calm
        case .quietGlassShelf, .seamLine, .luminousTrace, .meridianNode, .atmosphereComposer, .startHere:
            return .active
        case .inspectableStrip, .currentTimeGlow, .proofTrail, .receiptDrawer, .constellationLane, .userSystemProfile:
            return .proof
        case .sourceFreshnessBadge:
            return .stale
        case .closurePrompt:
            return .recovery
        }
    }

    public var summary: String {
        switch self {
        case .graphiteRecess:
            return "Grounded base material for calm depth."
        case .quietGlassShelf:
            return "Elevated inspectable layer for readable content."
        case .inspectableStrip:
            return "Compact source and proof strip for quick review."
        case .ambientVignette:
            return "Semantic background that orients without stealing focus."
        case .seamLine:
            return "Visible seam that shows relationship and change."
        case .luminousTrace:
            return "State and proof continuity drawn along a visible path."
        case .meridianNode:
            return "A scheduled node in the time field."
        case .currentTimeGlow:
            return "Current-time marker that stays calm and inspectable."
        case .proofTrail:
            return "Evidence trail that preserves origin and review."
        case .receiptDrawer:
            return "Confirmed changes and recovery paths stay visible."
        case .sourceFreshnessBadge:
            return "Fresh, stale, local-only, or unresolved source state."
        case .closurePrompt:
            return "Recovery prompt that keeps the next choice visible."
        case .startHere:
            return "The first daily decision object."
        case .lifeShape:
            return "Capacity and protected-time field."
        case .atmosphereComposer:
            return "Capture-first input and suggested path surface."
        case .constellationLane:
            return "Goals lane for threads, proof, and direction."
        case .userSystemProfile:
            return "Trust and control surface for the local runtime."
        }
    }

    public var accessibilitySummary: String {
        [title, ownerSurface, summary, visualState.title]
            .joined(separator: ". ")
    }
}

public enum FE04PrimitiveSystemContract {
    public static let forbiddenLanguage: [String] = [
        "dashboard",
        "task list",
        "chatbot",
        "ai " + "confidence",
        "production " + "ready",
        "release " + "ready"
    ]

    public static var roles: [FE04PrimitiveRole] {
        FE04PrimitiveRole.allCases
    }

    public static func validationFailures() -> [String] {
        roles.flatMap { validationFailures(for: $0) }
    }

    public static func validationFailures(for role: FE04PrimitiveRole) -> [String] {
        var failures: [String] = []

        if role.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing primitive title")
        }
        if role.ownerSurface.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("missing owner surface")
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
}
#endif
