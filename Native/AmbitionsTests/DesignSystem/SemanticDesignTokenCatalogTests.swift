import AmbitionsDesignSystem
import XCTest

final class SemanticDesignTokenCatalogTests: XCTestCase {
    func testSemanticTokenSnapshotIsStableAndCanonical() {
        XCTAssertEqual(
            AmbitionSemanticDesignTokenCatalog.snapshot,
            """
today.startHere | Today | Reality Meridian / Start here | Recommended step and current-reality decision object | dark=#C8A96B/#0F1114/#DCC27E | increased=#C8A96B/#0B0D10/#F1DEAA | reduceTransparency=Replace glass wash with opaque graphite elevated fill and visible stroke. | symbol=arrow.right.circle.fill
goals.constellationAtlas | Goals | Constellation Atlas | Goal-thread linkage, path proof, and ambition direction | dark=#A9C0D6/#141A24/#BBD2E6 | increased=#A9C0D6/#0B0D10/#F1DEAA | reduceTransparency=Use solid celestial field instead of translucent depth. | symbol=sparkle.magnifyingglass
capture.atmosphereComposer | Capture | Atmosphere Composer | Contextual capture entry, route reveal, and correction | dark=#D29D72/#17120F/#E1B28C | increased=#D29D72/#0B0D10/#F1DEAA | reduceTransparency=Render the composer seam as an opaque warm graphite panel. | symbol=square.and.pencil
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
}
