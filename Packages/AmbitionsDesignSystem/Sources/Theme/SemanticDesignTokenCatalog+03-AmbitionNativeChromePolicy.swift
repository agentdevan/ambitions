import Foundation

public struct AmbitionNativeChromePolicy: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let role: AmbitionNativeChromeSurfaceRole
    public let glassTreatment: AmbitionNativeGlassTreatment
    public let materialRole: AmbitionFoundationMaterialRole
    public let depthRole: AmbitionFoundationDepthRole
    public let shapeRole: AmbitionFoundationShapeRole
    public let minimumTapTarget: Double
    public let safeAreaRule: String
    public let reduceTransparencyFallback: String
    public let highContrastFallback: String
    public let reduceMotionFallback: String
    public let dynamicTypeRule: String

    public init(
        id: String,
        role: AmbitionNativeChromeSurfaceRole,
        glassTreatment: AmbitionNativeGlassTreatment,
        materialRole: AmbitionFoundationMaterialRole,
        depthRole: AmbitionFoundationDepthRole,
        shapeRole: AmbitionFoundationShapeRole,
        minimumTapTarget: Double,
        safeAreaRule: String,
        reduceTransparencyFallback: String,
        highContrastFallback: String,
        reduceMotionFallback: String,
        dynamicTypeRule: String
    ) {
        self.id = id
        self.role = role
        self.glassTreatment = glassTreatment
        self.materialRole = materialRole
        self.depthRole = depthRole
        self.shapeRole = shapeRole
        self.minimumTapTarget = minimumTapTarget
        self.safeAreaRule = safeAreaRule
        self.reduceTransparencyFallback = reduceTransparencyFallback
        self.highContrastFallback = highContrastFallback
        self.reduceMotionFallback = reduceMotionFallback
        self.dynamicTypeRule = dynamicTypeRule
    }

    public var snapshotLine: String {
        [
            id,
            role.rawValue,
            "glass=\(glassTreatment.rawValue)",
            "material=\(materialRole.rawValue)",
            "depth=\(depthRole.rawValue)",
            "shape=\(shapeRole.rawValue)",
            "tap=\(Int(minimumTapTarget))",
            "safeArea=\(safeAreaRule)",
            "reduceTransparency=\(reduceTransparencyFallback)",
            "highContrast=\(highContrastFallback)",
            "reduceMotion=\(reduceMotionFallback)",
            "dynamicType=\(dynamicTypeRule)"
        ].joined(separator: " | ")
    }
}

public enum AmbitionNativeChromePolicyCatalog {
    public static let policies: [AmbitionNativeChromePolicy] = [
        .init(
            id: "root-shell.chrome",
            role: .rootShell,
            glassTreatment: .nativeLiquidGlass,
            materialRole: .canvas,
            depthRole: .canvasBase,
            shapeRole: .continuousHero,
            minimumTapTarget: 48,
            safeAreaRule: "Root shell content clears sensor, home indicator, keyboard, and Dynamic Island safe areas.",
            reduceTransparencyFallback: "Opaque canvas and dock surfaces replace liquid glass while keeping selected labels visible.",
            highContrastFallback: "High-contrast selected surface label and outline remain visible without tint dependence.",
            reduceMotionFallback: "Chrome transitions use native opacity/position changes without meaning carried by morphing alone.",
            dynamicTypeRule: "Root navigation preserves Today, Goals, Time, and You labels or accessible names at large text sizes."
        ),
        .init(
            id: "continuity-dock.chrome",
            role: .continuityDock,
            glassTreatment: .nativeLiquidGlass,
            materialRole: .overlay,
            depthRole: .elevatedObject,
            shapeRole: .groupedRows,
            minimumTapTarget: 48,
            safeAreaRule: "Dock stays thumb-zone reachable and never overlaps primary action, keyboard, or composer confirmation.",
            reduceTransparencyFallback: "Opaque dock background with selected-state outline replaces blur.",
            highContrastFallback: "High-contrast icon, label, outline, and selected state are readable without color alone.",
            reduceMotionFallback: "Selected-state movement becomes static label, symbol, and outline.",
            dynamicTypeRule: "Dock labels may compact, but accessible names and tap targets remain stable."
        ),
        .init(
            id: "global-composer.chrome",
            role: .globalComposer,
            glassTreatment: .nativeLiquidGlass,
            materialRole: .overlay,
            depthRole: .overlayComposer,
            shapeRole: .composerSheet,
            minimumTapTarget: 48,
            safeAreaRule: "Composer respects keyboard, dictation, home indicator, and one-handed reach.",
            reduceTransparencyFallback: "Opaque composer sheet keeps input, route label, correction, and cancel visible.",
            highContrastFallback: "High-contrast input border, action label, and correction state stay visible.",
            reduceMotionFallback: "Composer expansion uses static placement and explicit state labels when motion is reduced.",
            dynamicTypeRule: "Input, route review, correction, and primary action stay visible before ambient detail."
        ),
        .init(
            id: "proof-receipt.chrome",
            role: .proofReceipt,
            glassTreatment: .receiptMaterial,
            materialRole: .receipt,
            depthRole: .receiptLayer,
            shapeRole: .receiptRow,
            minimumTapTarget: 44,
            safeAreaRule: "Receipt rows stay attached to their source object, remain within safe areas, and never hide under chrome.",
            reduceTransparencyFallback: "Opaque receipt rows preserve SourceRecord, Receipt, ReplayTrace, and freshness labels.",
            highContrastFallback: "High-contrast receipt labels, dividers, and source icons remain visible.",
            reduceMotionFallback: "Replay context becomes static before/after receipt text.",
            dynamicTypeRule: "Source, reason, freshness, receipt, and replay remain in reading order."
        ),
        .init(
            id: "review-modal.chrome",
            role: .modalReview,
            glassTreatment: .opaqueMaterial,
            materialRole: .elevated,
            depthRole: .elevatedObject,
            shapeRole: .groupedRows,
            minimumTapTarget: 48,
            safeAreaRule: "Review modals preserve cancel, undo, and confirmation controls within safe areas.",
            reduceTransparencyFallback: "Already opaque review surface; no blur required.",
            highContrastFallback: "High-contrast labels and outlines identify destructive, confirm, undo, and cancel actions.",
            reduceMotionFallback: "Modal presentation uses static state changes and explicit confirmation copy.",
            dynamicTypeRule: "Primary decision, consequence, undo, and cancel remain visible before secondary explanation."
        )
    ]

    public static var snapshot: String {
        policies.map(\.snapshotLine).joined(separator: "\n")
    }

    public static func validationFailures(
        policies: [AmbitionNativeChromePolicy] = Self.policies
    ) -> [String] {
        var failures: [String] = []
        let requiredRoles = Set(AmbitionNativeChromeSurfaceRole.allCases)
        let actualRoles = Set(policies.map(\.role))
        if actualRoles != requiredRoles {
            let missing = requiredRoles.subtracting(actualRoles).map(\.rawValue).sorted().joined(separator: ", ")
            failures.append("Native chrome policy missing roles: \(missing).")
        }

        for policy in policies {
            if policy.minimumTapTarget < AmbitionFlagshipSemanticFoundationCatalog.requiredMinimumTapTarget {
                failures.append("\(policy.id) tap target \(policy.minimumTapTarget) is below \(AmbitionFlagshipSemanticFoundationCatalog.requiredMinimumTapTarget).")
            }
            if policy.glassTreatment.allowsTranslucency
                && policy.reduceTransparencyFallback.range(of: "opaque", options: .caseInsensitive) == nil {
                failures.append("\(policy.id) translucent glass requires an opaque Reduce Transparency fallback.")
            }
            let contrastFallback = policy.highContrastFallback
            if contrastFallback.range(of: "contrast", options: .caseInsensitive) == nil
                && contrastFallback.range(of: "outline", options: .caseInsensitive) == nil
                && contrastFallback.range(of: "label", options: .caseInsensitive) == nil {
                failures.append("\(policy.id) is missing a High Contrast fallback.")
            }
            if policy.safeAreaRule.range(of: "safe", options: .caseInsensitive) == nil
                && policy.safeAreaRule.range(of: "keyboard", options: .caseInsensitive) == nil {
                failures.append("\(policy.id) is missing a safe-area or keyboard rule.")
            }
            if policy.dynamicTypeRule.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                failures.append("\(policy.id) is missing a Dynamic Type rule.")
            }
            if policy.reduceMotionFallback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                failures.append("\(policy.id) is missing a Reduce Motion fallback.")
            }
        }

        return failures
    }
}

public enum AmbitionSemanticContrastValidator {
    public static let minimumBodyContrast: Double = 4.5
    public static let minimumLargeTextContrast: Double = 3.0

    public struct Result: Equatable, Sendable {
        public let tokenID: String
        public let appearance: AmbitionDesignAppearance
        public let ratio: Double
        public let passesBodyText: Bool
        public let passesLargeText: Bool
    }

    public static func validate(
        tokens: [AmbitionSemanticDesignToken] = AmbitionSemanticDesignTokenCatalog.allTokens,
        appearances: [AmbitionDesignAppearance] = AmbitionDesignAppearance.allCases
    ) -> [Result] {
        tokens.flatMap { token in
            appearances.map { appearance in
                let colors = token.colors(for: appearance)
                let ratio = contrastRatio(foregroundHex: colors.foregroundHex, backgroundHex: colors.backgroundHex)
                return Result(tokenID: token.id, appearance: appearance, ratio: ratio, passesBodyText: ratio >= minimumBodyContrast, passesLargeText: ratio >= minimumLargeTextContrast)
            }
        }
    }

    public static func failures() -> [Result] {
        validate().filter { !$0.passesBodyText }
    }

    public static func contrastRatio(foregroundHex: String, backgroundHex: String) -> Double {
        let foreground = RGBColor(hex: foregroundHex)
        let background = RGBColor(hex: backgroundHex)
        let lighter = max(foreground.relativeLuminance, background.relativeLuminance)
        let darker = min(foreground.relativeLuminance, background.relativeLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    struct RGBColor {
        let red: Double
        let green: Double
        let blue: Double

        init(hex: String) {
            let clean = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
            let value = Int(clean, radix: 16) ?? 0
            red = Double((value >> 16) & 0xFF) / 255
            green = Double((value >> 8) & 0xFF) / 255
            blue = Double(value & 0xFF) / 255
        }

        var relativeLuminance: Double {
            0.2126 * component(red) + 0.7152 * component(green) + 0.0722 * component(blue)
        }

        func component(_ value: Double) -> Double {
            if value <= 0.03928 {
                return value / 12.92
            }
            return pow((value + 0.055) / 1.055, 2.4)
        }
    }
}
