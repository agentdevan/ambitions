import Foundation

public enum AmbitionFoundationTokenFamily: String, CaseIterable, Codable, Sendable {
    case color
    case material
    case typography
    case spacing
    case motion
    case haptics
    case semanticGlyph
}

public enum AmbitionFoundationMotionRole: String, CaseIterable, Codable, Sendable {
    case rootSurfaceTransition
    case primaryObjectTransition
    case overlayPresentation
    case receiptReveal
    case reducedMotionFallback

    public var themeBridge: String {
        switch self {
        case .rootSurfaceTransition:
            "AmbitionTheme.Motion.routeAnimation"
        case .primaryObjectTransition:
            "AmbitionTheme.Motion.animation"
        case .overlayPresentation:
            "AmbitionTheme.Motion.routeAnimation"
        case .receiptReveal:
            "AmbitionTheme.Motion.animation"
        case .reducedMotionFallback:
            "AmbitionTheme.Motion.animation reduceMotion:true"
        }
    }

    public var rule: String {
        switch self {
        case .rootSurfaceTransition:
            "Surface changes may animate only to clarify route depth and preserve focus."
        case .primaryObjectTransition:
            "Primary object movement must preserve hierarchy and avoid carrying meaning through motion alone."
        case .overlayPresentation:
            "Capture, Search, Closure, and inspection overlays appear from explicit user intent."
        case .receiptReveal:
            "Receipt movement stays attached to the object that changed."
        case .reducedMotionFallback:
            "Reduced Motion uses static placement, opacity, labels, and accessibility announcements."
        }
    }
}

public enum AmbitionFoundationHapticRole: String, CaseIterable, Codable, Sendable {
    case surfaceSelection
    case captureOpen
    case commitReceipt
    case invalidAction
    case protectionSet
    case disabledBySettings

    public var themeBridge: String {
        switch self {
        case .surfaceSelection:
            "AmbitionTheme.Haptics.routeChange"
        case .captureOpen:
            "AmbitionTheme.Haptics.routeChange"
        case .commitReceipt:
            "AmbitionTheme.Haptics.completion"
        case .invalidAction:
            "AmbitionTheme.Haptics.warning"
        case .protectionSet:
            "AmbitionTheme.Haptics.correction"
        case .disabledBySettings:
            "AmbitionTheme.Haptics.enabled"
        }
    }

    public var rule: String {
        switch self {
        case .surfaceSelection:
            "Selection feedback follows an explicit root-surface change."
        case .captureOpen:
            "Capture feedback follows user invocation and never advertises Capture as a root tab."
        case .commitReceipt:
            "Commit feedback pairs with a visible receipt or mutation."
        case .invalidAction:
            "Invalid feedback pairs with an accessible explanation or unavailable state."
        case .protectionSet:
            "Protection feedback follows a real protected-time state change."
        case .disabledBySettings:
            "Haptics must be suppressible by system or user settings."
        }
    }
}

public enum AmbitionSemanticGlyphRole: String, CaseIterable, Codable, Sendable, Identifiable {
    case startHere
    case goalsAtlas
    case globalCapture
    case timeCapacity
    case stageMotion
    case userProfile
    case proofReceipt
    case search
    case closure
    case protectedTime
    case review
    case waiting
    case blocked
    case undo

    public var id: String {
        rawValue
    }

    public var symbolName: String {
        switch self {
        case .startHere:
            "arrow.right.circle.fill"
        case .goalsAtlas:
            "scope"
        case .globalCapture:
            "square.and.pencil"
        case .timeCapacity:
            "calendar.badge.clock"
        case .stageMotion:
            "waveform.path.ecg"
        case .userProfile:
            "person.crop.circle"
        case .proofReceipt:
            "doc.text.magnifyingglass"
        case .search:
            "magnifyingglass"
        case .closure:
            "checkmark.seal"
        case .protectedTime:
            "lock.shield"
        case .review:
            "questionmark.circle"
        case .waiting:
            "pause.circle"
        case .blocked:
            "hand.raised"
        case .undo:
            "arrow.uturn.backward.circle"
        }
    }

    public var accessibilityLabel: String {
        switch self {
        case .startHere:
            "Start here"
        case .goalsAtlas:
            "Goals"
        case .globalCapture:
            "Capture"
        case .timeCapacity:
            "Time"
        case .stageMotion:
            "Motion state"
        case .userProfile:
            "You"
        case .proofReceipt:
            "Proof receipt"
        case .search:
            "Search"
        case .closure:
            "Closure"
        case .protectedTime:
            "Protected time"
        case .review:
            "Review"
        case .waiting:
            "Waiting"
        case .blocked:
            "Blocked"
        case .undo:
            "Undo"
        }
    }

    public var productionUse: String {
        switch self {
        case .startHere:
            "Recommended step and Start here controls."
        case .goalsAtlas:
            "Goal relationship and life-area direction controls."
        case .globalCapture:
            "Global Capture access and composer controls."
        case .timeCapacity:
            "Time capacity, weekly review, and protected-window controls."
        case .stageMotion:
            "Stage/Motion behavior and receipt movement states."
        case .userProfile:
            "You and local user-system controls."
        case .proofReceipt:
            "Proof, source, history, and receipt inspection."
        case .search:
            "Local Search invocation and results."
        case .closure:
            "Closure and saved-progress controls."
        case .protectedTime:
            "Protected boundary and privacy-adjacent state."
        case .review:
            "Inspectable explanation or user review."
        case .waiting:
            "Waiting state that depends on outside change."
        case .blocked:
            "Blocked state and unavailable action explanation."
        case .undo:
            "Undo and rollback controls."
        }
    }
}

public enum AmbitionSemanticFoundationTokenAudit {
    public static let requiredFamilies = Set(AmbitionFoundationTokenFamily.allCases)

    public static var snapshot: String {
        let familyLine = AmbitionFoundationTokenFamily.allCases.map(\.rawValue).joined(separator: " / ")
        let motionLine = AmbitionFoundationMotionRole.allCases.map { "\($0.rawValue)->\($0.themeBridge)" }.joined(separator: " | ")
        let hapticLine = AmbitionFoundationHapticRole.allCases.map { "\($0.rawValue)->\($0.themeBridge)" }.joined(separator: " | ")
        let glyphLine = AmbitionSemanticGlyphRole.allCases.map { "\($0.rawValue)=\($0.symbolName)" }.joined(separator: " | ")
        return [
            "families=\(familyLine)",
            "motion=\(motionLine)",
            "haptics=\(hapticLine)",
            "glyphs=\(glyphLine)",
        ].joined(separator: "\n")
    }

    public static func validationFailures() -> [String] {
        var failures: [String] = []
        let actualFamilies = Set(AmbitionFoundationTokenFamily.allCases)
        if actualFamilies != requiredFamilies {
            failures.append("Semantic foundation token families do not cover color/material/typography/spacing/motion/haptics/glyphs.")
        }
        if AmbitionFoundationMotionRole.allCases.contains(where: { $0.themeBridge.hasPrefix("AmbitionTheme.") == false }) {
            failures.append("Motion roles must bridge through AmbitionTheme.")
        }
        if AmbitionFoundationHapticRole.allCases.contains(where: { $0.themeBridge.hasPrefix("AmbitionTheme.") == false }) {
            failures.append("Haptic roles must bridge through AmbitionTheme.")
        }
        if AmbitionSemanticGlyphRole.allCases.contains(where: { $0.symbolName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            failures.append("Semantic glyph roles require production SF Symbol names.")
        }
        if AmbitionSemanticGlyphRole.allCases.contains(where: { $0.symbolName.localizedCaseInsensitiveContains("beta") }) {
            failures.append("Semantic glyph roles must not use beta-only symbol names.")
        }
        return failures
    }
}
