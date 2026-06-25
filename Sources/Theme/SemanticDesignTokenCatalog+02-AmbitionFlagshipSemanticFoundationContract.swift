import Foundation

public struct AmbitionFlagshipSemanticFoundationContract: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let surface: String
    public let primaryObject: String
    public let semanticTokenID: String
    public let isTopLevelSurface: Bool
    public let materialRole: AmbitionFoundationMaterialRole
    public let lightingRole: AmbitionFoundationLightingRole
    public let depthRole: AmbitionFoundationDepthRole
    public let shapeRole: AmbitionFoundationShapeRole
    public let typographyRole: AmbitionFoundationTypographyRole
    public let spacingRole: AmbitionFoundationSpacingRole
    public let dynamicTypeSpacingRole: AmbitionFoundationDynamicTypeSpacingRole
    public let hierarchyRole: AmbitionFoundationHierarchyRole
    public let minimumTapTarget: Double
    public let reduceTransparencyFallback: String
    public let highContrastFallback: String
    public let accessibilityFallback: String
    public let nativeConsistencyRule: String

    public init(
        id: String,
        surface: String,
        primaryObject: String,
        semanticTokenID: String,
        isTopLevelSurface: Bool,
        materialRole: AmbitionFoundationMaterialRole,
        lightingRole: AmbitionFoundationLightingRole,
        depthRole: AmbitionFoundationDepthRole,
        shapeRole: AmbitionFoundationShapeRole,
        typographyRole: AmbitionFoundationTypographyRole,
        spacingRole: AmbitionFoundationSpacingRole,
        dynamicTypeSpacingRole: AmbitionFoundationDynamicTypeSpacingRole,
        hierarchyRole: AmbitionFoundationHierarchyRole,
        minimumTapTarget: Double,
        reduceTransparencyFallback: String,
        highContrastFallback: String,
        accessibilityFallback: String,
        nativeConsistencyRule: String
    ) {
        self.id = id
        self.surface = surface
        self.primaryObject = primaryObject
        self.semanticTokenID = semanticTokenID
        self.isTopLevelSurface = isTopLevelSurface
        self.materialRole = materialRole
        self.lightingRole = lightingRole
        self.depthRole = depthRole
        self.shapeRole = shapeRole
        self.typographyRole = typographyRole
        self.spacingRole = spacingRole
        self.dynamicTypeSpacingRole = dynamicTypeSpacingRole
        self.hierarchyRole = hierarchyRole
        self.minimumTapTarget = minimumTapTarget
        self.reduceTransparencyFallback = reduceTransparencyFallback
        self.highContrastFallback = highContrastFallback
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
            "lighting=\(lightingRole.rawValue)",
            "depth=\(depthRole.rawValue)",
            "shape=\(shapeRole.rawValue)",
            "type=\(typographyRole.rawValue)->\(typographyRole.themeBridge)",
            "spacing=\(spacingRole.rawValue)->\(spacingRole.themeBridge)",
            "dynamicType=\(dynamicTypeSpacingRole.rawValue)",
            "hierarchy=\(hierarchyRole.rawValue)",
            "tap=\(Int(minimumTapTarget))",
            "reduceTransparency=\(reduceTransparencyFallback)",
            "highContrast=\(highContrastFallback)",
            "fallback=\(accessibilityFallback)",
            "rule=\(nativeConsistencyRule)"
        ].joined(separator: " | ")
    }
}

public enum AmbitionFlagshipSemanticFoundationCatalog {
    public static let activeTopLevelSurfaces = ["Today", "Goals", "Time", "You"]

    public static let requiredMinimumTapTarget: Double = Double(AmbitionTokens.Accessibility.minimumTapTarget.value) ?? 44

    public static let contracts: [AmbitionFlagshipSemanticFoundationContract] = [
        .init(
            id: "today.realityMeridian.foundation",
            surface: "Today",
            primaryObject: "Reality Meridian / Start here",
            semanticTokenID: "today.startHere",
            isTopLevelSurface: true,
            materialRole: .hero,
            lightingRole: .graphiteFocus,
            depthRole: .heroObject,
            shapeRole: .continuousHero,
            typographyRole: .heroDisplay,
            spacingRole: .heroInner,
            dynamicTypeSpacingRole: .preserveDecisionBeforeMetadata,
            hierarchyRole: .primaryObject,
            minimumTapTarget: 48,
            reduceTransparencyFallback: "Opaque graphite hero with visible warm stroke and no blur dependency.",
            highContrastFallback: "High-contrast gold outline, label, and symbol remain visible before metadata.",
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
            lightingRole: .celestialFocus,
            depthRole: .heroObject,
            shapeRole: .atlasField,
            typographyRole: .title,
            spacingRole: .sectionBreak,
            dynamicTypeSpacingRole: .preserveSelectedThread,
            hierarchyRole: .primaryObject,
            minimumTapTarget: 48,
            reduceTransparencyFallback: "Solid celestial field with selected-thread outline and no translucent dependency.",
            highContrastFallback: "High-contrast thread labels, outline, and selected state remain readable without color alone.",
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
            lightingRole: .capacityField,
            depthRole: .fieldBand,
            shapeRole: .capacityBand,
            typographyRole: .title,
            spacingRole: .sectionBreak,
            dynamicTypeSpacingRole: .preserveCapacityBeforeDetail,
            hierarchyRole: .primaryObject,
            minimumTapTarget: 48,
            reduceTransparencyFallback: "Opaque capacity bands with protected-time labels and shape cues.",
            highContrastFallback: "High-contrast outlines and pressure labels show capacity without color alone.",
            accessibilityFallback: "Capacity bands expose text labels, protected-time state, and fallback outlines under contrast or transparency changes.",
            nativeConsistencyRule: "Time texture is rendered as capacity bands and source-aware lanes, never as a free-busy grid."
        ),
        .init(
            id: "motion.motionCurrent.foundation",
            surface: "Motion",
            primaryObject: "Stage Motion behavior",
            semanticTokenID: "motion.motionCurrent",
            isTopLevelSurface: false,
            materialRole: .elevated,
            lightingRole: .proofGlow,
            depthRole: .elevatedObject,
            shapeRole: .proofRail,
            typographyRole: .titleCompact,
            spacingRole: .standard,
            dynamicTypeSpacingRole: .groupProofBeforeHistory,
            hierarchyRole: .sourceTrust,
            minimumTapTarget: 44,
            reduceTransparencyFallback: "Opaque movement rail with history labels and static return states.",
            highContrastFallback: "High-contrast labels and outlines identify blocked, waiting, protected, and recovery states.",
            accessibilityFallback: "Movement and history states are grouped by object with explicit labels and non-color status text.",
            nativeConsistencyRule: "Motion stays Stage/Motion behavior: inspectable movement through object history, not a root destination."
        ),
        .init(
            id: "you.userSystemProfile.foundation",
            surface: "You",
            primaryObject: "User System Profile",
            semanticTokenID: "you.userSystemProfile",
            isTopLevelSurface: true,
            materialRole: .elevated,
            lightingRole: .privacyGlow,
            depthRole: .elevatedObject,
            shapeRole: .groupedRows,
            typographyRole: .sectionTitle,
            spacingRole: .standard,
            dynamicTypeSpacingRole: .groupControlsBeforeDescription,
            hierarchyRole: .sourceTrust,
            minimumTapTarget: 44,
            reduceTransparencyFallback: "Opaque grouped rows with explicit trust and privacy labels.",
            highContrastFallback: "High-contrast dividers, icons, and labels preserve control meaning.",
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
            lightingRole: .composerGlow,
            depthRole: .overlayComposer,
            shapeRole: .composerSheet,
            typographyRole: .titleCompact,
            spacingRole: .standard,
            dynamicTypeSpacingRole: .keepComposerActionsVisible,
            hierarchyRole: .globalActionLayer,
            minimumTapTarget: 48,
            reduceTransparencyFallback: "Opaque composer sheet with placement and correction controls visible.",
            highContrastFallback: "High-contrast input, placement label, correction action, and stroke remain visible.",
            accessibilityFallback: "Composer entry, placement preview, correction, and held-state actions remain labeled when atmosphere is reduced.",
            nativeConsistencyRule: "Capture appears as a contextual global action layer with correction paths and no root-destination treatment."
        ),
        .init(
            id: "crossSurface.proofReceipt.foundation",
            surface: "Cross-surface",
            primaryObject: "Proof receipt",
            semanticTokenID: "proof.receipt",
            isTopLevelSurface: false,
            materialRole: .receipt,
            lightingRole: .receiptGlow,
            depthRole: .receiptLayer,
            shapeRole: .receiptRow,
            typographyRole: .caption,
            spacingRole: .compact,
            dynamicTypeSpacingRole: .preserveReceiptReadingOrder,
            hierarchyRole: .receiptEvidence,
            minimumTapTarget: 44,
            reduceTransparencyFallback: "Opaque receipt rows preserve SourceRecord, Receipt, and ReplayTrace labels.",
            highContrastFallback: "High-contrast source, freshness, receipt, and replay labels remain readable.",
            accessibilityFallback: "Receipt rows expose SourceRecord, Receipt, ReplayTrace, freshness, and what ambitions knows inspection in reading order.",
            nativeConsistencyRule: "Receipt treatment is shared across adaptive surfaces so source, reason, freshness, and replay context remain inspectable."
        )
    ]

    public static var snapshot: String {
        contracts.map(\.snapshotLine).joined(separator: "\n")
    }

    public static var tokenInventoryMarkdown: String {
        let rows = contracts.map { contract in
            "| \(contract.id) | \(contract.surface) | \(contract.semanticTokenID) | \(contract.materialRole.rawValue) | \(contract.lightingRole.rawValue) | \(contract.depthRole.rawValue) | \(contract.shapeRole.rawValue) | \(contract.typographyRole.rawValue) | \(contract.spacingRole.rawValue) | \(contract.dynamicTypeSpacingRole.rawValue) | \(contract.hierarchyRole.rawValue) | \(contract.minimumTapTarget) |"
        }
        return ([
            "| Contract | Surface | Semantic token | Material | Lighting | Depth | Shape | Typography | Spacing | Dynamic Type spacing | Hierarchy | Minimum tap target |",
            "|---|---|---|---|---|---|---|---|---|---|---|---|"
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

        guard let motionContract = contracts.first(where: { $0.surface == "Motion" }) else {
            failures.append("Motion foundation contract must exist as non-root Stage/Motion behavior.")
            return failures
        }
        if motionContract.isTopLevelSurface {
            failures.append("Motion foundation contract must be behavior infrastructure, not a top-level surface.")
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
            if contract.reduceTransparencyFallback.range(of: "opaque", options: .caseInsensitive) == nil && contract.reduceTransparencyFallback.range(of: "solid", options: .caseInsensitive) == nil {
                failures.append("\(contract.id) is missing an opaque or solid Reduce Transparency fallback.")
            }
            let contrastFallback = contract.highContrastFallback
            if contrastFallback.range(of: "contrast", options: .caseInsensitive) == nil
                && contrastFallback.range(of: "outline", options: .caseInsensitive) == nil
                && contrastFallback.range(of: "label", options: .caseInsensitive) == nil
                && contrastFallback.range(of: "stroke", options: .caseInsensitive) == nil {
                failures.append("\(contract.id) is missing a High Contrast fallback.")
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

public enum AmbitionNativeChromeSurfaceRole: String, CaseIterable, Codable, Sendable {
    case rootShell
    case continuityDock
    case globalComposer
    case proofReceipt
    case modalReview
}

public enum AmbitionNativeGlassTreatment: String, CaseIterable, Codable, Sendable {
    case nativeLiquidGlass
    case opaqueMaterial
    case receiptMaterial
    case noGlass

    public var allowsTranslucency: Bool {
        switch self {
        case .nativeLiquidGlass, .receiptMaterial: true
        case .opaqueMaterial, .noGlass: false
        }
    }
}
