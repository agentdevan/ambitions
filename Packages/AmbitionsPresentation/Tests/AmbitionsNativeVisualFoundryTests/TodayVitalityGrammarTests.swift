import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalityGrammarTests: XCTestCase {
    func testUsesFiveSemanticTypeRolesAndNonColorNodes() {
        XCTAssertEqual(
            TodayVitalityTypographyRole.allCases.map(\.semanticName),
            ["Object identity", "State truth", "Relationship", "Metadata", "Action"]
        )

        let shapeLabels = TodayVitalityNodeKind.allCases.map(\.nonColorShapeLabel)
        XCTAssertEqual(shapeLabels.count, 9)
        XCTAssertEqual(Set(shapeLabels).count, shapeLabels.count)
        XCTAssertFalse(shapeLabels.contains(where: \.isEmpty))
    }

    func testKeepsContentOpaqueAndGlassInFunctionalChrome() {
        XCTAssertTrue(TodayVitalitySurfaceClass.openPlane.isOpaque)
        XCTAssertFalse(TodayVitalitySurfaceClass.openPlane.allowsLiquidGlass)
        XCTAssertTrue(TodayVitalitySurfaceClass.openRelief.isOpaque)
        XCTAssertFalse(TodayVitalitySurfaceClass.openRelief.allowsLiquidGlass)
        XCTAssertTrue(TodayVitalitySurfaceClass.functionalChrome.allowsLiquidGlass)

        let transparent = TodayVitalityPalette(
            colorScheme: .dark,
            contrast: .standard,
            differentiateWithoutColor: false,
            reduceTransparency: false
        )
        let opaque = TodayVitalityPalette(
            colorScheme: .dark,
            contrast: .standard,
            differentiateWithoutColor: false,
            reduceTransparency: true
        )
        XCTAssertEqual(transparent.chromeTreatment, .nativeGlass)
        XCTAssertEqual(opaque.chromeTreatment, .opaque)
    }

    func testSeparatesActionRolesAndAuthorsContrast() {
        XCTAssertEqual(
            TodayVitalityActionRole.allCases.map(\.purposeLabel),
            [
                "Continue",
                "Outcome selection",
                "Consequential commitment",
                "Secondary cancellation",
                "Navigation and disclosure"
            ]
        )
        XCTAssertEqual(
            TodayVitalityActionRole.allCases.filter(\.isCommitment),
            [.commitment]
        )

        let standard = TodayVitalityPalette(
            colorScheme: .dark,
            contrast: .standard,
            differentiateWithoutColor: false,
            reduceTransparency: false
        )
        let increased = TodayVitalityPalette(
            colorScheme: .dark,
            contrast: .increased,
            differentiateWithoutColor: true,
            reduceTransparency: false
        )
        XCTAssertGreaterThan(increased.nodeStrokeWidth, standard.nodeStrokeWidth)
        XCTAssertGreaterThan(increased.separatorStrokeWidth, standard.separatorStrokeWidth)
        XCTAssertTrue(increased.differentiateWithoutColor)
    }

    func testSourceRejectsVisualShortcutsAndProvidesPreviewMatrix() throws {
        let grammarSource = try foundrySource(named: "TodayVitalityGrammar.swift")
        let previewSource = try foundrySource(named: "TodayVitalityPreviewSupport.swift")
        let sources = grammarSource + previewSource

        for prohibited in [
            "Font.custom",
            ".custom(",
            "LinearGradient",
            "RadialGradient",
            "AngularGradient",
            ".shadow(",
            ".blur(",
            "ultraThinMaterial",
            "thinMaterial"
        ] {
            XCTAssertFalse(sources.contains(prohibited), "R13 grammar contains \(prohibited)")
        }
        XCTAssertEqual(
            grammarSource.components(separatedBy: ".glassEffect(").count - 1,
            1,
            "Liquid Glass is reserved for the functional-chrome wrapper"
        )
        let glassOffset = try XCTUnwrap(grammarSource.range(of: ".glassEffect(")?.lowerBound)
        let chromeOffset = try XCTUnwrap(
            grammarSource.range(of: "struct TodayVitalityFunctionalChrome")?.lowerBound
        )
        XCTAssertGreaterThan(glassOffset, chromeOffset)

        for preview in [
            "R13 Grammar — Light",
            "R13 Grammar — Dark",
            "R13 Grammar — Increased Contrast",
            "R13 Grammar — Differentiate Without Color",
            "R13 Grammar — Dynamic Type"
        ] {
            XCTAssertTrue(previewSource.contains(preview), "Missing preview: \(preview)")
        }
    }

    private func foundrySource(named filename: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: packageRoot
                .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
                .appendingPathComponent(filename),
            encoding: .utf8
        )
    }
}
