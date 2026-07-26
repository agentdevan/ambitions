import SwiftUI
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

    func testNodeKindsMapToTheExactR13NonColorGeometry() {
        XCTAssertEqual(
            TodayVitalityNodeKind.allCases.map(\.geometry),
            [
                .openRingWithStableCenter,
                .pairedOffsetRings,
                .activeConnector,
                .resolvedDoubleRing,
                .retainedBrokenRing,
                .boundedShield,
                .anchoredDiamond,
                .openSquare,
                .dashedOpenRing
            ]
        )
        XCTAssertEqual(
            TodayVitalityNodeKind.allCases.map(\.nonColorShapeLabel),
            [
                "Open ring with stable center",
                "Paired offset rings",
                "Active connector",
                "Resolved double ring",
                "Retained broken ring",
                "Bounded shield",
                "Anchored diamond",
                "Open square",
                "Dashed open ring"
            ]
        )
    }

    func testOpenReliefMapsTruthToSemanticColorAndNonColorSeamGeometry() {
        XCTAssertEqual(
            TodayVitalityTruthKind.allCases.map(\.seamRole),
            [.neutral, .violetProposal, .mossSettlement, .amberInterruption]
        )
        let geometries = TodayVitalityTruthKind.allCases.map(\.seamGeometry)
        XCTAssertEqual(
            geometries,
            [.stableLine, .pairedLine, .resolvedDoubleLine, .retainedBrokenLine]
        )
        XCTAssertEqual(Set(geometries).count, TodayVitalityTruthKind.allCases.count)
    }

    @MainActor
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

        let staticChrome = TodayVitalityFunctionalChrome(palette: transparent) {
            Text("Static chrome")
        }
        let interactiveChrome = TodayVitalityFunctionalChrome(
            palette: transparent,
            isInteractive: true
        ) {
            Button("Interactive chrome") {}
        }
        XCTAssertFalse(staticChrome.isInteractive)
        XCTAssertTrue(interactiveChrome.isInteractive)
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
        XCTAssertTrue(grammarSource.contains("isInteractive: Bool = false"))
        XCTAssertTrue(previewSource.contains("isInteractive: true"))
        let interactiveOffset = try XCTUnwrap(
            previewSource.range(of: "isInteractive: true")?.lowerBound
        )
        let buttonOffset = try XCTUnwrap(previewSource.range(of: "Button {")?.lowerBound)
        let labelOffset = try XCTUnwrap(
            previewSource.range(of: "Label(\"Functional chrome\"")?.lowerBound
        )
        XCTAssertLessThan(interactiveOffset, buttonOffset)
        XCTAssertLessThan(buttonOffset, labelOffset)

        for preview in [
            "R13 Grammar — Light",
            "R13 Grammar — Dark",
            "R13 Grammar — Increased Contrast",
            "R13 Grammar — Differentiate Without Color",
            "R13 Grammar — Accessibility Dynamic Type"
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
