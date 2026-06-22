import XCTest
@testable import Ambitions

final class LifeShapeFieldViewReconstructionTests: XCTestCase {
    func testTimeObjectStageContractOwnsLifeShapeField() {
        let contract = TimeObjectStagePrimitiveContract.current
        XCTAssertEqual(contract.ownerSurface, "Time")
        XCTAssertEqual(contract.productObject, "LifeShape Field")
        XCTAssertTrue(contract.firstViewportAvoidsCalendarCardStackGeometry)
    }

    func testTimeObjectStageContractNamesCapacityPressureAndProtectedReality() {
        let structure = TimeObjectStagePrimitiveContract.current.firstViewportStructure
        XCTAssertTrue(structure.contains("capacity contours"))
        XCTAssertTrue(structure.contains("pressure texture"))
        XCTAssertTrue(structure.contains("protected windows"))
        XCTAssertTrue(structure.contains("fixed points"))
        XCTAssertTrue(structure.contains("horizons"))
        XCTAssertTrue(structure.contains("confirmation-first shaping actions"))
    }

    func testTimeObjectStageContractRejectsCalendarCloneGeometry() {
        let replaced = Set(TimeObjectStagePrimitiveContract.current.replacesFirstViewportStructures)
        XCTAssertTrue(replaced.contains("calendar clone"))
        XCTAssertTrue(replaced.contains("agenda clone"))
        XCTAssertTrue(replaced.contains("free/busy grid"))
        XCTAssertTrue(replaced.contains("metric-row stack"))
    }

    func testSwiftUIFirstLifeShapeRootUsesFirstClassComponents() throws {
        let root = repoRoot()
        let requiredPaths = [
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeLayerSelector.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeNowInstrument.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeHorizonRow.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeBucketDetail.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeCorrectionMenu.swift"
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        let rootView = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        XCTAssertTrue(rootView.contains("LifeShapeLayerSelector"))
        XCTAssertTrue(rootView.contains("LifeShapeNowInstrument"))
        XCTAssertTrue(rootView.contains("LifeShapeHorizonRowView"))
        XCTAssertTrue(rootView.contains("LifeShapeBucketDetail"))
        XCTAssertTrue(rootView.contains("LifeShapeCorrectionMenu"))
        XCTAssertTrue(rootView.contains("LifeShapeMutationProofBanner"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.placeStep"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.protectWindow"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.notUsable"))
        XCTAssertTrue(rootView.contains("onMutationAction?(.keepClear"))
        XCTAssertFalse(rootView.contains("sourceReceiptRow"))
        XCTAssertFalse(rootView.contains("LifeShape zoom"))
        XCTAssertFalse(rootView.contains("horizonControl"))
    }

    func testLifeShapeFieldDoesNotPerformLocalOnlyVisualMutation() throws {
        let root = repoRoot()
        let rootView = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        let viewModel = try source("Native/Ambitions/Surfaces/Time/TimeViewModel.swift", root: root)
        let coordinator = try source("Native/Ambitions/Projection/Mutations/TimeFieldMutationCoordinator.swift", root: root)
        let stateProjection = try source("Native/Ambitions/Projection/Mutations/TimeFieldMutationStateProjection.swift", root: root)
        let visibleProjection = try source("Native/Ambitions/Projection/Mutations/TimeFieldVisibleProjectionAdapter.swift", root: root)
        let mutationChain = [coordinator, stateProjection, visibleProjection].joined(separator: "\n")

        XCTAssertTrue(rootView.contains("onMutationAction?"))
        XCTAssertFalse(rootView.contains("selectedMarkID = selectedLayerMarks.first?.id"))
        XCTAssertTrue(rootView.contains("LifeShapeMutationHapticModifier"))
        XCTAssertTrue(rootView.contains(".ambitionHaptic"))
        XCTAssertTrue(rootView.contains("case \"confirmation\":"))
        XCTAssertTrue(viewModel.contains("TimeFieldMutationCoordinator().perform"))
        XCTAssertTrue(viewModel.contains("undoLastLifeShapeMutation"))
        XCTAssertTrue(mutationChain.contains("TimeMutation.make"))
        XCTAssertTrue(mutationChain.contains("runtime.mutation"))
        XCTAssertTrue(mutationChain.contains("Today recomputed"))
        XCTAssertTrue(mutationChain.contains("MutationProof"))
        XCTAssertTrue(mutationChain.contains("MutationAccessibilityAnnouncement"))
    }

    func testFirstGreenExposesOnlyOpenAndProtectedLayersWithMinimumHitTargets() throws {
        let root = repoRoot()
        let selector = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeLayerSelector.swift", root: root)
        let now = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeNowInstrument.swift", root: root)
        let correction = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeCorrectionMenu.swift", root: root)

        XCTAssertTrue(selector.contains("private let layers: [LifeShapeLayer] = [.open, .protected]"))
        XCTAssertFalse(selector.contains(".pressure"))
        XCTAssertFalse(selector.contains(".buffer"))
        XCTAssertTrue(selector.contains("minHeight: 44"))
        XCTAssertTrue(now.contains("minHeight: 44"))
        XCTAssertTrue(correction.contains("minHeight: 44"))
    }

    func testLifeShapeSemanticMirrorRootOrderDoesNotExposeSourceReceiptAsFirstViewport() {
        let mirror = LifeShapeSemanticModel(
            stageName: UserFacingLanguage.Object.lifeShapeField,
            currentDateSummary: "Today",
            capacitySummary: "Open capacity is visible.",
            protectedWindowSummary: "Protected windows are visible.",
            pressureSummary: "Pressure is reviewable.",
            horizonSummary: "This week stays inside Time.",
            accessibilityFallbacks: []
        )

        XCTAssertTrue(mirror.accessibilityOrder.contains("now instrument"))
        XCTAssertTrue(mirror.accessibilityOrder.contains("Open layer"))
        XCTAssertTrue(mirror.accessibilityOrder.contains("Protected layer"))
        XCTAssertFalse(mirror.accessibilityOrder.contains("source"))
        XCTAssertFalse(mirror.accessibilityOrder.contains("receipt"))
    }

    private func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
