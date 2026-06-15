import Foundation

public enum AmbitionDesignAppearance: String, CaseIterable, Codable, Sendable {
    case dark
    case light
    case increasedContrastDark
    case increasedContrastLight
    case reduceTransparencyDark
    case reduceTransparencyLight
}

public struct AmbitionSemanticDesignToken: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let surface: String
    public let primaryObject: String
    public let role: String
    public let foregroundHex: String
    public let backgroundHex: String
    public let elevatedBackgroundHex: String
    public let strokeHex: String
    public let symbolName: String
    public let accessibilityLabel: String
    public let reducedTransparencyFallback: String
    public let increasedContrastFallback: String

    public init(
        id: String,
        surface: String,
        primaryObject: String,
        role: String,
        foregroundHex: String,
        backgroundHex: String,
        elevatedBackgroundHex: String,
        strokeHex: String,
        symbolName: String,
        accessibilityLabel: String,
        reducedTransparencyFallback: String,
        increasedContrastFallback: String
    ) {
        self.id = id
        self.surface = surface
        self.primaryObject = primaryObject
        self.role = role
        self.foregroundHex = foregroundHex
        self.backgroundHex = backgroundHex
        self.elevatedBackgroundHex = elevatedBackgroundHex
        self.strokeHex = strokeHex
        self.symbolName = symbolName
        self.accessibilityLabel = accessibilityLabel
        self.reducedTransparencyFallback = reducedTransparencyFallback
        self.increasedContrastFallback = increasedContrastFallback
    }

    public func colors(for appearance: AmbitionDesignAppearance) -> AmbitionSemanticDesignTokenColors {
        switch appearance {
        case .dark:
            .init(foregroundHex: foregroundHex, backgroundHex: backgroundHex, strokeHex: strokeHex, materialOpacity: 0.82)
        case .light:
            .init(foregroundHex: darkenedForegroundForLightMode, backgroundHex: "#F3EEE8", strokeHex: "#76613A", materialOpacity: 0.92)
        case .increasedContrastDark:
            .init(foregroundHex: foregroundHex, backgroundHex: "#0B0D10", strokeHex: "#F1DEAA", materialOpacity: 1.0)
        case .increasedContrastLight:
            .init(foregroundHex: "#2C2416", backgroundHex: "#FFF9EF", strokeHex: "#5B4723", materialOpacity: 1.0)
        case .reduceTransparencyDark:
            .init(foregroundHex: foregroundHex, backgroundHex: elevatedBackgroundHex, strokeHex: strokeHex, materialOpacity: 1.0)
        case .reduceTransparencyLight:
            .init(foregroundHex: darkenedForegroundForLightMode, backgroundHex: "#F8F2EA", strokeHex: "#76613A", materialOpacity: 1.0)
        }
    }

    private var darkenedForegroundForLightMode: String {
        switch id {
        case "today.startHere": "#5D4616"
        case "goals.constellationAtlas": "#294A62"
        case "capture.atmosphereComposer": "#663B1E"
        case "time.lifeShapeField": "#274A68"
        case "motion.motionCurrent": "#315847"
        case "you.userSystemProfile": "#553662"
        case "proof.receipt": "#5C481F"
        default: "#2C2416"
        }
    }
}

public struct AmbitionSemanticDesignTokenColors: Codable, Equatable, Sendable {
    public let foregroundHex: String
    public let backgroundHex: String
    public let strokeHex: String
    public let materialOpacity: Double
}

public enum AmbitionSemanticDesignTokenCatalog {
    public static let allTokens: [AmbitionSemanticDesignToken] = [
        .init(id: "today.startHere", surface: "Today", primaryObject: "Reality Meridian / Start here", role: "Recommended step and current-reality decision object", foregroundHex: AmbitionTokens.Semantic.todayFocus.hex, backgroundHex: AmbitionTokens.Foundation.graphiteInk.hex, elevatedBackgroundHex: AmbitionTokens.Foundation.graphiteRise.hex, strokeHex: "#DCC27E", symbolName: "arrow.right.circle.fill", accessibilityLabel: "Start here recommendation, includes proof and time reality context.", reducedTransparencyFallback: "Replace glass wash with opaque graphite elevated fill and visible stroke.", increasedContrastFallback: "Use solid graphite, high-contrast gold stroke, and label plus symbol."),
        .init(id: "goals.constellationAtlas", surface: "Goals", primaryObject: "Constellation Atlas", role: "Goal-thread linkage, path proof, and ambition direction", foregroundHex: AmbitionTokens.Semantic.goalThread.hex, backgroundHex: AmbitionTokens.Foundation.celestialField.hex, elevatedBackgroundHex: "#182131", strokeHex: "#BBD2E6", symbolName: "sparkle.magnifyingglass", accessibilityLabel: "Constellation Atlas goal thread with proof-gap context.", reducedTransparencyFallback: "Use solid celestial field instead of translucent depth.", increasedContrastFallback: "Pair blue-gray foreground with a strong outline and text status."),
        .init(id: "capture.atmosphereComposer", surface: "Capture", primaryObject: "Atmosphere Composer", role: "Contextual capture entry, route reveal, and correction", foregroundHex: AmbitionTokens.Semantic.captureSignal.hex, backgroundHex: "#17120F", elevatedBackgroundHex: "#211914", strokeHex: "#E1B28C", symbolName: "square.and.pencil", accessibilityLabel: "Capture composer with route and correction options.", reducedTransparencyFallback: "Render the composer seam as an opaque warm graphite panel.", increasedContrastFallback: "Use copper foreground with explicit route labels and stroke."),
        .init(id: "time.lifeShapeField", surface: "Time", primaryObject: "LifeShape Field / Time Texture", role: "Availability, capacity, protected time, and pressure", foregroundHex: AmbitionTokens.Semantic.timeCapacity.hex, backgroundHex: "#101722", elevatedBackgroundHex: "#172232", strokeHex: "#A9C3DE", symbolName: "clock.badge.checkmark", accessibilityLabel: "LifeShape Field capacity and protected-time context.", reducedTransparencyFallback: "Use opaque field bands with shape and label cues.", increasedContrastFallback: "Use stronger blue-gray foreground, outline, and non-color pressure text."),
        .init(id: "motion.motionCurrent", surface: "Motion", primaryObject: "Motion Current", role: "Inspectable proof and progress without pressure metrics", foregroundHex: AmbitionTokens.Foundation.recoveryMint.hex, backgroundHex: "#101915", elevatedBackgroundHex: "#17231D", strokeHex: "#A9DDBF", symbolName: "waveform.path.ecg", accessibilityLabel: "Motion Current proof and progress inspection.", reducedTransparencyFallback: "Use opaque proof rows with receipt labels.", increasedContrastFallback: "Use visible receipt states with contrast-safe labels instead of relying on green alone."),
        .init(id: "you.userSystemProfile", surface: "You", primaryObject: "User System Profile", role: "Local runtime trust controls and user-model governance", foregroundHex: AmbitionTokens.Semantic.youTrust.hex, backgroundHex: "#18131B", elevatedBackgroundHex: "#211A25", strokeHex: "#DDB6EA", symbolName: "person.crop.circle.badge.checkmark", accessibilityLabel: "User System Profile trust and privacy controls.", reducedTransparencyFallback: "Use grouped opaque rows and explicit privacy labels.", increasedContrastFallback: "Use solid grouping, high-contrast dividers, and icon plus label."),
        .init(id: "proof.receipt", surface: "Cross-surface", primaryObject: "Proof receipt", role: "Inspectable why, source, freshness, and receipt evidence", foregroundHex: AmbitionTokens.Semantic.proofReceipt.hex, backgroundHex: "#17140D", elevatedBackgroundHex: "#211D13", strokeHex: "#E2CB8D", symbolName: "doc.text.magnifyingglass", accessibilityLabel: "Proof receipt explains source, freshness, and why this recommendation appeared.", reducedTransparencyFallback: "Use opaque receipt rows with persistent source labels.", increasedContrastFallback: "Use strong outline, receipt icon, and readable status text.")
    ]

    public static var snapshot: String {
        allTokens.map { token in
            let dark = token.colors(for: .dark)
            let increased = token.colors(for: .increasedContrastDark)
            return [
                token.id,
                token.surface,
                token.primaryObject,
                token.role,
                "dark=\(dark.foregroundHex)/\(dark.backgroundHex)/\(dark.strokeHex)",
                "increased=\(increased.foregroundHex)/\(increased.backgroundHex)/\(increased.strokeHex)",
                "reduceTransparency=\(token.reducedTransparencyFallback)",
                "symbol=\(token.symbolName)"
            ].joined(separator: " | ")
        }.joined(separator: "\n")
    }
}

public enum AmbitionFoundationMaterialRole: String, CaseIterable, Codable, Sendable {
    case canvas
    case elevated
    case overlay
    case hero
    case band
    case receipt

    public var themeBridge: String {
        switch self {
        case .canvas: "AmbitionTheme.Materials.canvasGradient"
        case .elevated: "AmbitionTheme.Materials.elevatedGradient"
        case .overlay: "AmbitionTheme.Materials.overlayGradient"
        case .hero: "AmbitionTheme.Materials.heroGradient"
        case .band: "AmbitionTheme.Materials.bandGradient"
        case .receipt: "AmbitionTheme.ShellTokens.receiptMaterial"
        }
    }
}

public enum AmbitionFoundationTypographyRole: String, CaseIterable, Codable, Sendable {
    case heroDisplay
    case title
    case titleCompact
    case sectionTitle
    case bodyPrimary
    case caption
    case micro

    public var themeBridge: String {
        switch self {
        case .heroDisplay: "AmbitionTheme.Typography.heroDisplay"
        case .title: "AmbitionTheme.Typography.title"
        case .titleCompact: "AmbitionTheme.Typography.titleCompact"
        case .sectionTitle: "AmbitionTheme.Typography.sectionTitle"
        case .bodyPrimary: "AmbitionTheme.Typography.bodyPrimary"
        case .caption: "AmbitionTheme.Typography.caption"
        case .micro: "AmbitionTheme.Typography.micro"
        }
    }
}

public enum AmbitionFoundationSpacingRole: String, CaseIterable, Codable, Sendable {
    case compact
    case standard
    case heroInner
    case sectionBreak
    case majorBreak

    public var themeBridge: String {
        switch self {
        case .compact: "AmbitionTheme.Spacing.compact"
        case .standard: "AmbitionTheme.Spacing.standard"
        case .heroInner: "AmbitionTheme.Spacing.heroInner"
        case .sectionBreak: "AmbitionTheme.Spacing.sectionBreak"
        case .majorBreak: "AmbitionTheme.Spacing.majorBreak"
        }
    }
}

public enum AmbitionFoundationHierarchyRole: String, CaseIterable, Codable, Sendable {
    case primaryObject
    case primaryAction
    case sourceTrust
    case secondaryMetadata
    case globalActionLayer
    case receiptEvidence

    public var rule: String {
        switch self {
        case .primaryObject: "Primary object before action, source, and metadata."
        case .primaryAction: "Primary command follows object state and remains thumb-zone reachable."
        case .sourceTrust: "Source and trust context stay adjacent to adaptive claims."
        case .secondaryMetadata: "Secondary metadata stays compact and subordinate."
        case .globalActionLayer: "Global action layer is invoked contextually and is not a root destination."
        case .receiptEvidence: "Receipt evidence binds SourceRecord, Receipt, ReplayTrace, and what ambitions knows inspection."
        }
    }
}

public struct AmbitionFlagshipSemanticFoundationContract: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let surface: String
    public let primaryObject: String
    public let semanticTokenID: String
    public let isTopLevelSurface: Bool
    public let materialRole: AmbitionFoundationMaterialRole
    public let typographyRole: AmbitionFoundationTypographyRole
    public let spacingRole: AmbitionFoundationSpacingRole
    public let hierarchyRole: AmbitionFoundationHierarchyRole
    public let minimumTapTarget: Double
    public let accessibilityFallback: String
    public let nativeConsistencyRule: String

    public init(
        id: String,
        surface: String,
        primaryObject: String,
        semanticTokenID: String,
        isTopLevelSurface: Bool,
        materialRole: AmbitionFoundationMaterialRole,
        typographyRole: AmbitionFoundationTypographyRole,
        spacingRole: AmbitionFoundationSpacingRole,
        hierarchyRole: AmbitionFoundationHierarchyRole,
        minimumTapTarget: Double,
        accessibilityFallback: String,
        nativeConsistencyRule: String
    ) {
        self.id = id
        self.surface = surface
        self.primaryObject = primaryObject
        self.semanticTokenID = semanticTokenID
        self.isTopLevelSurface = isTopLevelSurface
        self.materialRole = materialRole
        self.typographyRole = typographyRole
        self.spacingRole = spacingRole
        self.hierarchyRole = hierarchyRole
        self.minimumTapTarget = minimumTapTarget
        self.accessibilityFallback = accessibilityFallback
        self.nativeConsistencyRule = nativeConsistencyRule
    }

    public var snapshotLine: String {
        [
            id,
            surface,
            primaryObject,
            "topLevel=\(isTopLevelSurface)",
            "token=\(semanticTokenID)",
            "material=\(materialRole.rawValue)->\(materialRole.themeBridge)",
            "type=\(typographyRole.rawValue)->\(typographyRole.themeBridge)",
            "spacing=\(spacingRole.rawValue)->\(spacingRole.themeBridge)",
            "hierarchy=\(hierarchyRole.rawValue)",
            "tap=\(Int(minimumTapTarget))",
            "fallback=\(accessibilityFallback)",
            "rule=\(nativeConsistencyRule)"
        ].joined(separator: " | ")
    }
}

public enum AmbitionFlagshipSemanticFoundationCatalog {
    public static let activeTopLevelSurfaces = ["Today", "Goals", "Time", "Motion", "You"]

    public static let requiredMinimumTapTarget: Double = Double(AmbitionTokens.Accessibility.minimumTapTarget.value) ?? 44

    public static let contracts: [AmbitionFlagshipSemanticFoundationContract] = [
        .init(
            id: "today.realityMeridian.foundation",
            surface: "Today",
            primaryObject: "Reality Meridian / Start here",
            semanticTokenID: "today.startHere",
            isTopLevelSurface: true,
            materialRole: .hero,
            typographyRole: .heroDisplay,
            spacingRole: .heroInner,
            hierarchyRole: .primaryObject,
            minimumTapTarget: 48,
            accessibilityFallback: "VoiceOver summarizes current reality, source, receipt path, and action before secondary context.",
            nativeConsistencyRule: "Hero instrument must stay state-led, source-aware, receipt-backed, and reachable without custom gesture dependence."
        ),
        .init(
            id: "goals.constellationAtlas.foundation",
            surface: "Goals",
            primaryObject: "Constellation Atlas",
            semanticTokenID: "goals.constellationAtlas",
            isTopLevelSurface: true,
            materialRole: .hero,
            typographyRole: .title,
            spacingRole: .sectionBreak,
            hierarchyRole: .primaryObject,
            minimumTapTarget: 48,
            accessibilityFallback: "Relationships expose labels, selected thread, proof gap, and open detail action without relying on position or color.",
            nativeConsistencyRule: "Atlas relationship depth uses shared hero material and title scale before compact supporting evidence."
        ),
        .init(
            id: "time.lifeShapeField.foundation",
            surface: "Time",
            primaryObject: "LifeShape Field / Time Texture",
            semanticTokenID: "time.lifeShapeField",
            isTopLevelSurface: true,
            materialRole: .band,
            typographyRole: .title,
            spacingRole: .sectionBreak,
            hierarchyRole: .primaryObject,
            minimumTapTarget: 48,
            accessibilityFallback: "Capacity bands expose text labels, protected-time state, and fallback outlines under contrast or transparency changes.",
            nativeConsistencyRule: "Time texture is rendered as capacity bands and source-aware lanes, never as a free-busy grid."
        ),
        .init(
            id: "motion.motionCurrent.foundation",
            surface: "Motion",
            primaryObject: "Motion Current",
            semanticTokenID: "motion.motionCurrent",
            isTopLevelSurface: true,
            materialRole: .elevated,
            typographyRole: .titleCompact,
            spacingRole: .standard,
            hierarchyRole: .sourceTrust,
            minimumTapTarget: 44,
            accessibilityFallback: "Progress and receipt states are grouped by object with explicit labels and non-color status text.",
            nativeConsistencyRule: "Motion shows inspectable movement through object evidence and receipts, not competitive pressure or vanity metrics."
        ),
        .init(
            id: "you.userSystemProfile.foundation",
            surface: "You",
            primaryObject: "User System Profile",
            semanticTokenID: "you.userSystemProfile",
            isTopLevelSurface: true,
            materialRole: .elevated,
            typographyRole: .sectionTitle,
            spacingRole: .standard,
            hierarchyRole: .sourceTrust,
            minimumTapTarget: 44,
            accessibilityFallback: "Grouped controls expose local learning, reset, delete, receipt, and what ambitions knows inspection order.",
            nativeConsistencyRule: "System profile controls use grouped native rows, explicit trust language, and reversible local learning actions."
        ),
        .init(
            id: "capture.atmosphereComposer.foundation",
            surface: "Capture",
            primaryObject: "Atmosphere Composer",
            semanticTokenID: "capture.atmosphereComposer",
            isTopLevelSurface: false,
            materialRole: .overlay,
            typographyRole: .titleCompact,
            spacingRole: .standard,
            hierarchyRole: .globalActionLayer,
            minimumTapTarget: 48,
            accessibilityFallback: "Composer entry, route reveal, correction, and held-state actions remain labeled when atmosphere is reduced.",
            nativeConsistencyRule: "Capture appears as a contextual global action layer with correction paths and no root-destination treatment."
        ),
        .init(
            id: "crossSurface.proofReceipt.foundation",
            surface: "Cross-surface",
            primaryObject: "Proof receipt",
            semanticTokenID: "proof.receipt",
            isTopLevelSurface: false,
            materialRole: .receipt,
            typographyRole: .caption,
            spacingRole: .compact,
            hierarchyRole: .receiptEvidence,
            minimumTapTarget: 44,
            accessibilityFallback: "Receipt rows expose SourceRecord, Receipt, ReplayTrace, freshness, and what ambitions knows inspection in reading order.",
            nativeConsistencyRule: "Receipt treatment is shared across adaptive surfaces so source, reason, freshness, and replay context remain inspectable."
        )
    ]

    public static var snapshot: String {
        contracts.map(\.snapshotLine).joined(separator: "\n")
    }

    public static var tokenInventoryMarkdown: String {
        let rows = contracts.map { contract in
            "| \(contract.id) | \(contract.surface) | \(contract.semanticTokenID) | \(contract.materialRole.rawValue) | \(contract.typographyRole.rawValue) | \(contract.spacingRole.rawValue) | \(contract.hierarchyRole.rawValue) | \(contract.minimumTapTarget) |"
        }
        return ([
            "| Contract | Surface | Semantic token | Material | Typography | Spacing | Hierarchy | Minimum tap target |",
            "|---|---|---|---|---|---|---|---|"
        ] + rows).joined(separator: "\n")
    }

    public static var forbiddenActiveLanguageTerms: [String] {
        [
            "dash" + "board",
            "st" + "reak",
            "sc" + "ore",
            "chat" + "bot",
            "Plan" + " tab",
            "Pul" + "se"
        ]
    }

    public static func validationFailures(
        contracts: [AmbitionFlagshipSemanticFoundationContract] = Self.contracts,
        tokens: [AmbitionSemanticDesignToken] = AmbitionSemanticDesignTokenCatalog.allTokens,
        forbiddenTerms: [String] = Self.forbiddenActiveLanguageTerms
    ) -> [String] {
        var failures: [String] = []
        let topLevelSurfaces = contracts.filter(\.isTopLevelSurface).map(\.surface)
        if topLevelSurfaces != activeTopLevelSurfaces {
            failures.append("Top-level surfaces are \(topLevelSurfaces.joined(separator: " / ")); expected \(activeTopLevelSurfaces.joined(separator: " / ")).")
        }

        if contracts.contains(where: { $0.surface == "Capture" && $0.isTopLevelSurface == false }) == false {
            failures.append("Capture foundation contract must exist as a non-root global action layer.")
        }

        let tokenIDs = Set(tokens.map(\.id))
        for contract in contracts {
            if tokenIDs.contains(contract.semanticTokenID) == false {
                failures.append("\(contract.id) references missing semantic token \(contract.semanticTokenID).")
            }
            if contract.minimumTapTarget < requiredMinimumTapTarget {
                failures.append("\(contract.id) tap target \(contract.minimumTapTarget) is below \(requiredMinimumTapTarget).")
            }
            if contract.accessibilityFallback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                failures.append("\(contract.id) is missing an accessibility fallback.")
            }
            if contract.nativeConsistencyRule.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                failures.append("\(contract.id) is missing a native consistency rule.")
            }
            if contract.materialRole.themeBridge.hasPrefix("AmbitionTheme.") == false {
                failures.append("\(contract.id) material role is not bridged to AmbitionTheme.")
            }
            if contract.typographyRole.themeBridge.hasPrefix("AmbitionTheme.") == false {
                failures.append("\(contract.id) typography role is not bridged to AmbitionTheme.")
            }
            if contract.spacingRole.themeBridge.hasPrefix("AmbitionTheme.") == false {
                failures.append("\(contract.id) spacing role is not bridged to AmbitionTheme.")
            }
        }

        let searchable = contracts.map(\.snapshotLine).joined(separator: "\n")
        for term in forbiddenTerms where searchable.range(of: term, options: [.caseInsensitive, .diacriticInsensitive]) != nil {
            failures.append("Foundation contract contains forbidden active language term: \(term).")
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

    private struct RGBColor {
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

        private func component(_ value: Double) -> Double {
            if value <= 0.03928 {
                return value / 12.92
            }
            return pow((value + 0.055) / 1.055, 2.4)
        }
    }
}
