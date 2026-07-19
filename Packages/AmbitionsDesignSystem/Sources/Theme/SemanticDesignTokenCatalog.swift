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

    var darkenedForegroundForLightMode: String {
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
        .init(id: "goals.constellationAtlas", surface: "Goals", primaryObject: "Life Area Atlas", role: "Goal-thread linkage, path proof, and ambition direction", foregroundHex: AmbitionTokens.Semantic.goalThread.hex, backgroundHex: AmbitionTokens.Foundation.celestialField.hex, elevatedBackgroundHex: "#182131", strokeHex: "#BBD2E6", symbolName: "sparkle.magnifyingglass", accessibilityLabel: "Life Area Atlas goal thread with proof-gap context.", reducedTransparencyFallback: "Use solid celestial field instead of translucent depth.", increasedContrastFallback: "Pair blue-gray foreground with a strong outline and text status."),
        .init(id: "capture.atmosphereComposer", surface: "Capture", primaryObject: "Atmosphere Composer", role: "Contextual capture entry, placement review, and correction", foregroundHex: AmbitionTokens.Semantic.captureSignal.hex, backgroundHex: "#17120F", elevatedBackgroundHex: "#211914", strokeHex: "#E1B28C", symbolName: "square.and.pencil", accessibilityLabel: "Capture composer with route and correction options.", reducedTransparencyFallback: "Render the composer seam as an opaque warm graphite panel.", increasedContrastFallback: "Use copper foreground with explicit route labels and stroke."),
        .init(id: "time.lifeShapeField", surface: "Time", primaryObject: "Life Calendar / Time Texture", role: "Availability, capacity, protected time, and pressure", foregroundHex: AmbitionTokens.Semantic.timeCapacity.hex, backgroundHex: "#101722", elevatedBackgroundHex: "#172232", strokeHex: "#A9C3DE", symbolName: "clock.badge.checkmark", accessibilityLabel: "Life Calendar capacity and protected-time context.", reducedTransparencyFallback: "Use opaque field bands with shape and label cues.", increasedContrastFallback: "Use stronger blue-gray foreground, outline, and non-color pressure text."),
        .init(id: "motion.motionCurrent", surface: "Motion", primaryObject: "Stage Motion behavior", role: "Inspectable movement, recovery, and return without pressure metrics", foregroundHex: AmbitionTokens.Foundation.recoveryMint.hex, backgroundHex: "#101915", elevatedBackgroundHex: "#17231D", strokeHex: "#A9DDBF", symbolName: "waveform.path.ecg", accessibilityLabel: "Stage Motion movement and recovery inspection.", reducedTransparencyFallback: "Use opaque history rows with visible labels.", increasedContrastFallback: "Use visible recovery states with contrast-safe labels instead of relying on green alone."),
        .init(id: "you.userSystemProfile", surface: "You", primaryObject: "User System Profile", role: "Local runtime trust controls and user-model governance", foregroundHex: AmbitionTokens.Semantic.youTrust.hex, backgroundHex: "#18131B", elevatedBackgroundHex: "#211A25", strokeHex: "#DDB6EA", symbolName: "person.crop.circle.badge.checkmark", accessibilityLabel: "User System Profile trust and privacy controls.", reducedTransparencyFallback: "Use grouped opaque rows and explicit privacy labels.", increasedContrastFallback: "Use solid grouping, high-contrast dividers, and icon plus label."),
        .init(id: "proof.receipt", surface: "Cross-surface", primaryObject: "Proof receipt", role: "Inspectable why, source, freshness, and receipt evidence", foregroundHex: AmbitionTokens.Semantic.proofReceipt.hex, backgroundHex: "#17140D", elevatedBackgroundHex: "#211D13", strokeHex: "#E2CB8D", symbolName: "doc.text.magnifyingglass", accessibilityLabel: "Proof receipt explains source, freshness, and why this recommendation appeared.", reducedTransparencyFallback: "Use opaque receipt rows with persistent source labels.", increasedContrastFallback: "Use strong outline, receipt icon, and readable status text."),
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
                "symbol=\(token.symbolName)",
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

public enum AmbitionFoundationLightingRole: String, CaseIterable, Codable, Sendable {
    case graphiteFocus
    case celestialFocus
    case capacityField
    case proofGlow
    case privacyGlow
    case composerGlow
    case receiptGlow

    public var rule: String {
        switch self {
        case .graphiteFocus: "Use low-glare graphite focus with one warm decision highlight."
        case .celestialFocus: "Use soft directional atlas light without decorative starfield dominance."
        case .capacityField: "Use calm field lighting that preserves pressure and protected-time labels."
        case .proofGlow: "Use restrained proof glow only to clarify receipt and recovery state."
        case .privacyGlow: "Use quiet trust lighting with privacy controls readable before atmosphere."
        case .composerGlow: "Use composer light as an input affordance, not a persistent destination marker."
        case .receiptGlow: "Use receipt light to bind source, freshness, and replay context."
        }
    }
}

public enum AmbitionFoundationDepthRole: String, CaseIterable, Codable, Sendable {
    case canvasBase
    case heroObject
    case fieldBand
    case elevatedObject
    case overlayComposer
    case receiptLayer

    public var rule: String {
        switch self {
        case .canvasBase: "The canvas stays behind product objects and never becomes a dashboard background."
        case .heroObject: "The hero object owns primary depth before controls and metadata."
        case .fieldBand: "Bands communicate capacity and protection without calendar-grid depth."
        case .elevatedObject: "Elevated objects stay scan-friendly and avoid nested card stacks."
        case .overlayComposer: "Overlay depth is contextual and safe-area aware."
        case .receiptLayer: "Receipt depth stays attached to source and history inspection."
        }
    }
}

public enum AmbitionFoundationShapeRole: String, CaseIterable, Codable, Sendable {
    case continuousHero
    case atlasField
    case capacityBand
    case proofRail
    case groupedRows
    case composerSheet
    case receiptRow

    public var rule: String {
        switch self {
        case .continuousHero: "Use a continuous native shape sized for the primary decision object."
        case .atlasField: "Use field shapes to show relationships without ornamental diagrams."
        case .capacityBand: "Use stable bands with text and shape cues beyond color."
        case .proofRail: "Use ordered rails for proof, recovery, and re-entry."
        case .groupedRows: "Use native grouped rows for settings-quality trust controls."
        case .composerSheet: "Use an input-first sheet shape with reachable actions."
        case .receiptRow: "Use compact rows that preserve source and receipt reading order."
        }
    }
}

public enum AmbitionFoundationDynamicTypeSpacingRole: String, CaseIterable, Codable, Sendable {
    case preserveDecisionBeforeMetadata
    case preserveSelectedThread
    case preserveCapacityBeforeDetail
    case groupProofBeforeHistory
    case groupControlsBeforeDescription
    case keepComposerActionsVisible
    case preserveReceiptReadingOrder

    public var rule: String {
        switch self {
        case .preserveDecisionBeforeMetadata: "At large text sizes, preserve Start here and action before metadata."
        case .preserveSelectedThread: "At large text sizes, preserve selected goal thread before atlas detail."
        case .preserveCapacityBeforeDetail: "At large text sizes, preserve capacity and protected time before texture."
        case .groupProofBeforeHistory: "At large text sizes, group current proof and re-entry before history."
        case .groupControlsBeforeDescription: "At large text sizes, keep trust controls before descriptive copy."
        case .keepComposerActionsVisible: "At large text sizes, keep composer input and correction actions visible."
        case .preserveReceiptReadingOrder: "At large text sizes, preserve source, freshness, receipt, and replay order."
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
