import AmbitionsDesignSystem
import XCTest

final class SemanticDesignTokenCatalogTests: XCTestCase {
    func testSemanticTokenSnapshotIsStableAndCanonical() {
        XCTAssertEqual(
            AmbitionSemanticDesignTokenCatalog.snapshot,
            """
today.startHere | Today | Reality Meridian / Start here | Recommended step and current-reality decision object | dark=#C8A96B/#0F1114/#DCC27E | increased=#C8A96B/#0B0D10/#F1DEAA | reduceTransparency=Replace glass wash with opaque graphite elevated fill and visible stroke. | symbol=arrow.right.circle.fill
goals.constellationAtlas | Goals | Constellation Atlas | Goal-thread linkage, path proof, and ambition direction | dark=#A9C0D6/#141A24/#BBD2E6 | increased=#A9C0D6/#0B0D10/#F1DEAA | reduceTransparency=Use solid celestial field instead of translucent depth. | symbol=sparkle.magnifyingglass
capture.atmosphereComposer | Capture | Atmosphere Composer | Contextual capture entry, placement review, and correction | dark=#D29D72/#17120F/#E1B28C | increased=#D29D72/#0B0D10/#F1DEAA | reduceTransparency=Render the composer seam as an opaque warm graphite panel. | symbol=square.and.pencil
time.lifeShapeField | Time | LifeShape Field / Time Texture | Availability, capacity, protected time, and pressure | dark=#89A4C2/#101722/#A9C3DE | increased=#89A4C2/#0B0D10/#F1DEAA | reduceTransparency=Use opaque field bands with shape and label cues. | symbol=clock.badge.checkmark
motion.motionCurrent | Motion | Motion Current | Inspectable proof and progress without pressure metrics | dark=#8BC6A8/#101915/#A9DDBF | increased=#8BC6A8/#0B0D10/#F1DEAA | reduceTransparency=Use opaque proof rows with receipt labels. | symbol=waveform.path.ecg
you.userSystemProfile | You | User System Profile | Local runtime trust controls and user-model governance | dark=#C6A3D4/#18131B/#DDB6EA | increased=#C6A3D4/#0B0D10/#F1DEAA | reduceTransparency=Use grouped opaque rows and explicit privacy labels. | symbol=person.crop.circle.badge.checkmark
proof.receipt | Cross-surface | Proof receipt | Inspectable why, source, freshness, and receipt evidence | dark=#D4BC7D/#17140D/#E2CB8D | increased=#D4BC7D/#0B0D10/#F1DEAA | reduceTransparency=Use opaque receipt rows with persistent source labels. | symbol=doc.text.magnifyingglass
"""
        )
    }

    func testContrastValidatorPassesBodyTextAcrossDarkLightIncreasedContrastAndReduceTransparency() {
        let failures = AmbitionSemanticContrastValidator.failures()
        XCTAssertTrue(failures.isEmpty, failures.map { "\($0.tokenID) \($0.appearance.rawValue) \($0.ratio)" }.joined(separator: "\n"))

        for result in AmbitionSemanticContrastValidator.validate() {
            XCTAssertGreaterThanOrEqual(result.ratio, AmbitionSemanticContrastValidator.minimumBodyContrast)
            XCTAssertTrue(result.passesBodyText)
            XCTAssertTrue(result.passesLargeText)
        }
    }

    func testPreviewCatalogCoversAllCanonicalSurfacesAndAccessibilityFallbacks() {
        let tokens = AmbitionSemanticDesignTokenCatalog.allTokens
        XCTAssertEqual(tokens.map(\.surface), ["Today", "Goals", "Capture", "Time", "Motion", "You", "Cross-surface"])
        XCTAssertEqual(Set(tokens.map(\.id)).count, tokens.count)

        for token in tokens {
            XCTAssertFalse(token.symbolName.isEmpty)
            XCTAssertFalse(token.accessibilityLabel.isEmpty)
            XCTAssertTrue(token.reducedTransparencyFallback.localizedCaseInsensitiveContains("opaque") || token.reducedTransparencyFallback.localizedCaseInsensitiveContains("solid"))
            XCTAssertTrue(token.increasedContrastFallback.localizedCaseInsensitiveContains("contrast") || token.increasedContrastFallback.localizedCaseInsensitiveContains("outline") || token.increasedContrastFallback.localizedCaseInsensitiveContains("stroke"))
        }
    }

    func testSemanticTokensAvoidForbiddenTopLevelAndAccessibilityBreakingTheming() {
        let searchable = AmbitionSemanticDesignTokenCatalog.snapshot + " " + AmbitionSemanticDesignTokenCatalog.allTokens.map { $0.accessibilityLabel }.joined(separator: " ")

        XCTAssertFalse(searchable.localizedCaseInsensitiveContains("Pulse"))
        XCTAssertFalse(searchable.localizedCaseInsensitiveContains("Plan tab"))
        XCTAssertFalse(searchable.localizedCaseInsensitiveContains("Dashboard"))
        XCTAssertFalse(searchable.localizedCaseInsensitiveContains("Streak"))
        XCTAssertFalse(searchable.localizedCaseInsensitiveContains("Score"))
        XCTAssertFalse(searchable.localizedCaseInsensitiveContains("Custom theme"))
    }

    func testFlagshipSemanticFoundationSnapshotIsStableAndThemeBacked() {
        XCTAssertEqual(
            AmbitionFlagshipSemanticFoundationCatalog.snapshot,
            """
today.realityMeridian.foundation | Today | Reality Meridian / Start here | topLevel=true | token=today.startHere | material=hero->AmbitionTheme.Materials.heroGradient | lighting=graphiteFocus | depth=heroObject | shape=continuousHero | type=heroDisplay->AmbitionTheme.Typography.heroDisplay | spacing=heroInner->AmbitionTheme.Spacing.heroInner | dynamicType=preserveDecisionBeforeMetadata | hierarchy=primaryObject | tap=48 | reduceTransparency=Opaque graphite hero with visible warm stroke and no blur dependency. | highContrast=High-contrast gold outline, label, and symbol remain visible before metadata. | fallback=VoiceOver summarizes current reality, source, receipt path, and action before secondary context. | rule=Hero instrument must stay state-led, source-aware, receipt-backed, and reachable without custom gesture dependence.
goals.constellationAtlas.foundation | Goals | Constellation Atlas | topLevel=true | token=goals.constellationAtlas | material=hero->AmbitionTheme.Materials.heroGradient | lighting=celestialFocus | depth=heroObject | shape=atlasField | type=title->AmbitionTheme.Typography.title | spacing=sectionBreak->AmbitionTheme.Spacing.sectionBreak | dynamicType=preserveSelectedThread | hierarchy=primaryObject | tap=48 | reduceTransparency=Solid celestial field with selected-thread outline and no translucent dependency. | highContrast=High-contrast thread labels, outline, and selected state remain readable without color alone. | fallback=Relationships expose labels, selected thread, proof gap, and open detail action without relying on position or color. | rule=Atlas relationship depth uses shared hero material and title scale before compact supporting evidence.
time.lifeShapeField.foundation | Time | LifeShape Field / Time Texture | topLevel=true | token=time.lifeShapeField | material=band->AmbitionTheme.Materials.bandGradient | lighting=capacityField | depth=fieldBand | shape=capacityBand | type=title->AmbitionTheme.Typography.title | spacing=sectionBreak->AmbitionTheme.Spacing.sectionBreak | dynamicType=preserveCapacityBeforeDetail | hierarchy=primaryObject | tap=48 | reduceTransparency=Opaque capacity bands with protected-time labels and shape cues. | highContrast=High-contrast outlines and pressure labels show capacity without color alone. | fallback=Capacity bands expose text labels, protected-time state, and fallback outlines under contrast or transparency changes. | rule=Time texture is rendered as capacity bands and source-aware lanes, never as a free-busy grid.
motion.motionCurrent.foundation | Motion | Motion Current | topLevel=false | token=motion.motionCurrent | material=elevated->AmbitionTheme.Materials.elevatedGradient | lighting=proofGlow | depth=elevatedObject | shape=proofRail | type=titleCompact->AmbitionTheme.Typography.titleCompact | spacing=standard->AmbitionTheme.Spacing.standard | dynamicType=groupProofBeforeHistory | hierarchy=sourceTrust | tap=44 | reduceTransparency=Opaque proof rail with receipt labels and static re-entry states. | highContrast=High-contrast labels and outlines identify blocked, waiting, protected, and recovery states. | fallback=Progress and receipt states are grouped by object with explicit labels and non-color status text. | rule=Motion stays Stage/Motion behavior: inspectable movement through object evidence and receipts, not a root destination.
you.userSystemProfile.foundation | You | User System Profile | topLevel=true | token=you.userSystemProfile | material=elevated->AmbitionTheme.Materials.elevatedGradient | lighting=privacyGlow | depth=elevatedObject | shape=groupedRows | type=sectionTitle->AmbitionTheme.Typography.sectionTitle | spacing=standard->AmbitionTheme.Spacing.standard | dynamicType=groupControlsBeforeDescription | hierarchy=sourceTrust | tap=44 | reduceTransparency=Opaque grouped rows with explicit trust and privacy labels. | highContrast=High-contrast dividers, icons, and labels preserve control meaning. | fallback=Grouped controls expose local learning, reset, delete, receipt, and what ambitions knows inspection order. | rule=System profile controls use grouped native rows, explicit trust language, and reversible local learning actions.
capture.atmosphereComposer.foundation | Capture | Atmosphere Composer | topLevel=false | token=capture.atmosphereComposer | material=overlay->AmbitionTheme.Materials.overlayGradient | lighting=composerGlow | depth=overlayComposer | shape=composerSheet | type=titleCompact->AmbitionTheme.Typography.titleCompact | spacing=standard->AmbitionTheme.Spacing.standard | dynamicType=keepComposerActionsVisible | hierarchy=globalActionLayer | tap=48 | reduceTransparency=Opaque composer sheet with route and correction controls visible. | highContrast=High-contrast input, route label, correction action, and stroke remain visible. | fallback=Composer entry, route reveal, correction, and held-state actions remain labeled when atmosphere is reduced. | rule=Capture appears as a contextual global action layer with correction paths and no root-destination treatment.
crossSurface.proofReceipt.foundation | Cross-surface | Proof receipt | topLevel=false | token=proof.receipt | material=receipt->AmbitionTheme.ShellTokens.receiptMaterial | lighting=receiptGlow | depth=receiptLayer | shape=receiptRow | type=caption->AmbitionTheme.Typography.caption | spacing=compact->AmbitionTheme.Spacing.compact | dynamicType=preserveReceiptReadingOrder | hierarchy=receiptEvidence | tap=44 | reduceTransparency=Opaque receipt rows preserve SourceRecord, Receipt, and ReplayTrace labels. | highContrast=High-contrast source, freshness, receipt, and replay labels remain readable. | fallback=Receipt rows expose SourceRecord, Receipt, ReplayTrace, freshness, and what ambitions knows inspection in reading order. | rule=Receipt treatment is shared across adaptive surfaces so source, reason, freshness, and replay context remain inspectable.
"""
        )
    }

    func testFlagshipSemanticFoundationValidationPassesAndPreservesCaptureAsGlobalAction() throws {
        XCTAssertTrue(
            AmbitionFlagshipSemanticFoundationCatalog.validationFailures().isEmpty,
            AmbitionFlagshipSemanticFoundationCatalog.validationFailures().joined(separator: "\n")
        )

        let rootSurfaces = AmbitionFlagshipSemanticFoundationCatalog.contracts
            .filter(\.isTopLevelSurface)
            .map(\.surface)
        XCTAssertEqual(rootSurfaces, ["Today", "Goals", "Time", "You"])

        let captureContract = try XCTUnwrap(AmbitionFlagshipSemanticFoundationCatalog.contracts.first { $0.surface == "Capture" })
        XCTAssertFalse(captureContract.isTopLevelSurface)
        XCTAssertEqual(captureContract.hierarchyRole, .globalActionLayer)

        let motionContract = try XCTUnwrap(AmbitionFlagshipSemanticFoundationCatalog.contracts.first { $0.surface == "Motion" })
        XCTAssertFalse(motionContract.isTopLevelSurface)
        XCTAssertEqual(motionContract.hierarchyRole, .sourceTrust)
    }

    func testFlagshipSemanticFoundationUsesExistingTokensThemeAndNativeTapTargets() {
        let semanticTokenIDs = Set(AmbitionSemanticDesignTokenCatalog.allTokens.map(\.id))
        for contract in AmbitionFlagshipSemanticFoundationCatalog.contracts {
            XCTAssertTrue(semanticTokenIDs.contains(contract.semanticTokenID), contract.id)
            XCTAssertGreaterThanOrEqual(contract.minimumTapTarget, AmbitionFlagshipSemanticFoundationCatalog.requiredMinimumTapTarget, contract.id)
            XCTAssertTrue(contract.materialRole.themeBridge.hasPrefix("AmbitionTheme."), contract.id)
            XCTAssertTrue(contract.typographyRole.themeBridge.hasPrefix("AmbitionTheme."), contract.id)
            XCTAssertTrue(contract.spacingRole.themeBridge.hasPrefix("AmbitionTheme."), contract.id)
            XCTAssertFalse(contract.lightingRole.rule.isEmpty, contract.id)
            XCTAssertFalse(contract.depthRole.rule.isEmpty, contract.id)
            XCTAssertFalse(contract.shapeRole.rule.isEmpty, contract.id)
            XCTAssertFalse(contract.dynamicTypeSpacingRole.rule.isEmpty, contract.id)
            XCTAssertTrue(
                contract.reduceTransparencyFallback.localizedCaseInsensitiveContains("opaque")
                    || contract.reduceTransparencyFallback.localizedCaseInsensitiveContains("solid"),
                contract.id
            )
            XCTAssertTrue(
                contract.highContrastFallback.localizedCaseInsensitiveContains("contrast")
                    || contract.highContrastFallback.localizedCaseInsensitiveContains("outline")
                    || contract.highContrastFallback.localizedCaseInsensitiveContains("label")
                    || contract.highContrastFallback.localizedCaseInsensitiveContains("stroke"),
                contract.id
            )
        }
    }

    func testNativeChromePolicySnapshotIsStableAndAccessibilityBacked() {
        XCTAssertEqual(
            AmbitionNativeChromePolicyCatalog.snapshot,
            """
root-shell.chrome | rootShell | glass=nativeLiquidGlass | material=canvas | depth=canvasBase | shape=continuousHero | tap=48 | safeArea=Root shell content clears sensor, home indicator, keyboard, and Dynamic Island safe areas. | reduceTransparency=Opaque canvas and dock surfaces replace liquid glass while keeping selected labels visible. | highContrast=High-contrast selected surface label and outline remain visible without tint dependence. | reduceMotion=Chrome transitions use native opacity/position changes without meaning carried by morphing alone. | dynamicType=Root navigation preserves Today, Goals, Time, and You labels or accessible names at large text sizes.
continuity-dock.chrome | continuityDock | glass=nativeLiquidGlass | material=overlay | depth=elevatedObject | shape=groupedRows | tap=48 | safeArea=Dock stays thumb-zone reachable and never overlaps primary action, keyboard, or composer confirmation. | reduceTransparency=Opaque dock background with selected-state outline replaces blur. | highContrast=High-contrast icon, label, outline, and selected state are readable without color alone. | reduceMotion=Selected-state movement becomes static label, symbol, and outline. | dynamicType=Dock labels may compact, but accessible names and tap targets remain stable.
global-composer.chrome | globalComposer | glass=nativeLiquidGlass | material=overlay | depth=overlayComposer | shape=composerSheet | tap=48 | safeArea=Composer respects keyboard, dictation, home indicator, and one-handed reach. | reduceTransparency=Opaque composer sheet keeps input, route label, correction, and cancel visible. | highContrast=High-contrast input border, action label, and correction state stay visible. | reduceMotion=Composer expansion uses static placement and explicit state labels when motion is reduced. | dynamicType=Input, route review, correction, and primary action stay visible before ambient detail.
proof-receipt.chrome | proofReceipt | glass=receiptMaterial | material=receipt | depth=receiptLayer | shape=receiptRow | tap=44 | safeArea=Receipt rows stay attached to their source object, remain within safe areas, and never hide under chrome. | reduceTransparency=Opaque receipt rows preserve SourceRecord, Receipt, ReplayTrace, and freshness labels. | highContrast=High-contrast receipt labels, dividers, and source icons remain visible. | reduceMotion=Replay context becomes static before/after receipt text. | dynamicType=Source, reason, freshness, receipt, and replay remain in reading order.
review-modal.chrome | modalReview | glass=opaqueMaterial | material=elevated | depth=elevatedObject | shape=groupedRows | tap=48 | safeArea=Review modals preserve cancel, undo, and confirmation controls within safe areas. | reduceTransparency=Already opaque review surface; no blur required. | highContrast=High-contrast labels and outlines identify destructive, confirm, undo, and cancel actions. | reduceMotion=Modal presentation uses static state changes and explicit confirmation copy. | dynamicType=Primary decision, consequence, undo, and cancel remain visible before secondary explanation.
"""
        )

        XCTAssertTrue(
            AmbitionNativeChromePolicyCatalog.validationFailures().isEmpty,
            AmbitionNativeChromePolicyCatalog.validationFailures().joined(separator: "\n")
        )
    }

    func testFlagshipSemanticFoundationDetectsForbiddenActiveLanguageWhenProvidedByCaller() {
        var mutated = AmbitionFlagshipSemanticFoundationCatalog.contracts
        mutated[0] = AmbitionFlagshipSemanticFoundationContract(
            id: mutated[0].id,
            surface: mutated[0].surface,
            primaryObject: mutated[0].primaryObject,
            semanticTokenID: mutated[0].semanticTokenID,
            isTopLevelSurface: mutated[0].isTopLevelSurface,
            materialRole: mutated[0].materialRole,
            lightingRole: mutated[0].lightingRole,
            depthRole: mutated[0].depthRole,
            shapeRole: mutated[0].shapeRole,
            typographyRole: mutated[0].typographyRole,
            spacingRole: mutated[0].spacingRole,
            dynamicTypeSpacingRole: mutated[0].dynamicTypeSpacingRole,
            hierarchyRole: mutated[0].hierarchyRole,
            minimumTapTarget: mutated[0].minimumTapTarget,
            reduceTransparencyFallback: mutated[0].reduceTransparencyFallback,
            highContrastFallback: mutated[0].highContrastFallback,
            accessibilityFallback: mutated[0].accessibilityFallback,
            nativeConsistencyRule: "Forbidden term fixture"
        )

        let failures = AmbitionFlagshipSemanticFoundationCatalog.validationFailures(
            contracts: mutated,
            forbiddenTerms: ["forbidden term"]
        )
        XCTAssertEqual(failures, ["Foundation contract contains forbidden active language term: forbidden term."])
    }
}
