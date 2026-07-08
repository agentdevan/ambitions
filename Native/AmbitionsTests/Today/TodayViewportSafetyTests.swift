@testable import Ambitions
import Foundation
import SwiftUI
import XCTest

final class TodayViewportSafetyTests: XCTestCase {
    func testRootTodayClearanceReservesFloatingDockBand() {
        let normal = TodayViewportSafety.layout(dynamicTypeSize: .large, showsNavigationChrome: false)
        let accessibility = TodayViewportSafety.layout(dynamicTypeSize: .accessibility3, showsNavigationChrome: false)

        XCTAssertGreaterThanOrEqual(normal.rootBottomChromeClearance, 420)
        XCTAssertGreaterThanOrEqual(accessibility.rootBottomChromeClearance, 560)
        XCTAssertGreaterThan(accessibility.rootBottomChromeClearance, normal.rootBottomChromeClearance)
    }

    func testNavigationTodayClearanceReservesRootDockBand() {
        let normal = TodayViewportSafety.layout(dynamicTypeSize: .large, showsNavigationChrome: true)
        let accessibility = TodayViewportSafety.layout(dynamicTypeSize: .accessibility3, showsNavigationChrome: true)

        XCTAssertGreaterThanOrEqual(normal.rootBottomChromeClearance, 128)
        XCTAssertGreaterThanOrEqual(accessibility.rootBottomChromeClearance, 160)
        XCTAssertGreaterThan(accessibility.rootBottomChromeClearance, normal.rootBottomChromeClearance)
    }

    func testAccessibilityDynamicTypeUsesStackedRailAndSuppressesStageMetrics() {
        let normal = TodayViewportSafety.layout(dynamicTypeSize: .large, showsNavigationChrome: false)
        let largeText = TodayViewportSafety.layout(dynamicTypeSize: .xxLarge, showsNavigationChrome: false)
        let accessibility = TodayViewportSafety.layout(dynamicTypeSize: .accessibility3, showsNavigationChrome: false)

        XCTAssertFalse(normal.usesStackedAccessibilityRail)
        XCTAssertTrue(largeText.usesStackedAccessibilityRail)
        XCTAssertTrue(accessibility.usesStackedAccessibilityRail)
        XCTAssertTrue(normal.showsStageMetrics)
        XCTAssertFalse(largeText.showsStageMetrics)
        XCTAssertFalse(accessibility.showsStageMetrics)
        XCTAssertGreaterThanOrEqual(largeText.railMinHeight, 980)
        XCTAssertGreaterThanOrEqual(accessibility.railMinHeight, 980)
    }

    func testStatusCrownAndNoStepClearanceAreExplicitViewportPolicy() {
        let normal = TodayViewportSafety.layout(dynamicTypeSize: .large, showsNavigationChrome: false)
        let largeText = TodayViewportSafety.layout(dynamicTypeSize: .xxLarge, showsNavigationChrome: false)
        let accessibility = TodayViewportSafety.layout(dynamicTypeSize: .accessibility3, showsNavigationChrome: false)

        XCTAssertGreaterThanOrEqual(normal.topChromeClearance, 40)
        XCTAssertLessThanOrEqual(normal.topChromeClearance, 88)
        XCTAssertGreaterThanOrEqual(largeText.topChromeClearance, 72)
        XCTAssertLessThanOrEqual(largeText.topChromeClearance, 120)
        XCTAssertGreaterThanOrEqual(accessibility.topChromeClearance, 72)
        XCTAssertLessThanOrEqual(accessibility.topChromeClearance, 120)
        XCTAssertGreaterThanOrEqual(normal.emptyActionBottomClearance, 120)
        XCTAssertGreaterThanOrEqual(largeText.emptyActionBottomClearance, 240)
        XCTAssertGreaterThanOrEqual(accessibility.emptyActionBottomClearance, 240)
        XCTAssertGreaterThanOrEqual(normal.railBottomContentClearance, 148)
        XCTAssertGreaterThanOrEqual(largeText.railBottomContentClearance, 260)
        XCTAssertGreaterThanOrEqual(accessibility.railBottomContentClearance, 260)
    }

    func testTodaySurfaceAndRailRouteLayoutThroughViewportPolicy() throws {
        let screenSource = try source("Native/Ambitions/Surfaces/Today/TodaySurface+02-autoLoad.swift")
        let railSource = try source("Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailView.swift")
        let policySource = try source("Native/Ambitions/Stage/Chrome/TodayViewportSafety.swift")
        let objectSource = try source("Native/Ambitions/Surfaces/Today/TodayObjectView.swift")
        let rootHostSource = try source("Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift")

        XCTAssertTrue(screenSource.contains("rootBottomChromeClearance"))
        XCTAssertTrue(screenSource.contains("StageSafeAreaPolicy.rootSurfaceContentBottomInset"))
        XCTAssertTrue(railSource.contains("usesStackedAccessibilityRail"))
        XCTAssertTrue(policySource.contains("emptyActionBottomClearance"))
        XCTAssertTrue(objectSource.contains("RealityMeridianView"))
        XCTAssertTrue(rootHostSource.contains("TodayBackgroundView()"))
        XCTAssertFalse(objectSource.contains("FlagshipRuntimeStage"))
    }

    func testTodayMeridianAtmosphereDoesNotPaintLowerViewportBlack() throws {
        let source = try source("Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailViewStateRendering.swift")

        XCTAssertTrue(source.contains("Color.clear"))
        XCTAssertFalse(source.contains("theme.colors.canvas.opacity(0.52)"))
        XCTAssertFalse(source.contains("theme.colors.canvasElevated.opacity(0.54)"))
        XCTAssertFalse(source.contains("theme.colors.canvas,"))
    }

    func source(_ relativePath: String) throws -> String {
        let url = repoRoot().appendingPathComponent(relativePath)
        return try String(contentsOf: url, encoding: .utf8)
    }

    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Stage/Chrome/TodayViewportSafety.swift")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
